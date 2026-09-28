// Fonctions serveur Montagne des Oliviers.
// Elles s'exécutent avec les droits du SDK Admin, hors règles de sécurité :
// chaque fonction vérifie elle-même qui l'appelle.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, Timestamp, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { defineString } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { getMessaging } from 'firebase-admin/messaging';
import { logger } from 'firebase-functions';
import { nouveauxClaims, normaliser, rolesDe } from './roles.js';
import {
  doitNotifier, messagesActualite, messagesEvenement, totalInscrits,
  quand,
} from './notifications.js';
import {
  apercu, destinataires, destinatairesRappel, notificationMessage, notificationRappel,
  notificationRemplacement, notificationRencontre, rappelsDus, remplacementVientDEtreDemande,
} from './groupes.js';

initializeApp();

// Données en Europe (RGPD) et plafond de coût.
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const EMAIL_ADMIN = defineString('EMAIL_ADMIN', {
  description: 'Adresse e-mail du premier administrateur (pasteur) dans l\'app',
});

/** Enregistre les rôles dans les claims et les recopie dans le profil. */
async function appliquerRoles(uid, roles) {
  const user = await getAuth().getUser(uid);
  const claims = nouveauxClaims(user.customClaims, roles);
  if (claims === null) throw new HttpsError('invalid-argument', 'Rôle inconnu.');
  await getAuth().setCustomUserClaims(uid, claims);
  const profil = getFirestore().doc(`users/${uid}`);
  if ((await profil.get()).exists) {
    await profil.update({ roles: rolesDe(claims) });
  }
}

/**
 * Premier administrateur : le compte dont l'e-mail a été indiqué au
 * déploiement. Une seule fois ; ensuite, les rôles se donnent dans l'app.
 */
export const revendiquerAdmin = onCall(async (requete) => {
  if (!requete.auth) {
    throw new HttpsError('unauthenticated', 'Connexion requise.');
  }
  const attendu = normaliser(EMAIL_ADMIN.value());
  if (!attendu || normaliser(requete.auth.token.email) !== attendu) {
    throw new HttpsError('permission-denied', 'Ce compte ne peut pas devenir administrateur.');
  }
  const uid = requete.auth.uid;
  const db = getFirestore();
  await db.runTransaction(async (t) => {
    const ref = db.doc('systeme/admin');
    const doc = await t.get(ref);
    if (doc.exists && doc.data().uid !== uid) {
      throw new HttpsError('failed-precondition', 'L\'administrateur est déjà désigné.');
    }
    t.set(ref, { uid, designeLe: FieldValue.serverTimestamp() });
  });
  const actuels = rolesDe((await getAuth().getUser(uid)).customClaims);
  await appliquerRoles(uid, [...actuels, 'admin']);
  return { admin: true };
});

/**
 * Administrateur : fixe les rôles d'un compte désigné par son e-mail.
 * Un administrateur ne peut pas retirer son propre rôle d'administrateur.
 */
export const definirRoles = onCall(async (requete) => {
  if (requete.auth?.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Réservé à l\'administrateur.');
  }
  const email = normaliser(requete.data?.email);
  const roles = requete.data?.roles;
  if (!email || nouveauxClaims({}, roles) === null) {
    throw new HttpsError('invalid-argument', 'E-mail ou rôles invalides.');
  }
  let cible;
  try {
    cible = await getAuth().getUserByEmail(email);
  } catch {
    throw new HttpsError('not-found', 'Aucun compte avec cette adresse.');
  }
  if (cible.uid === requete.auth.uid && !roles.includes('admin')) {
    throw new HttpsError('failed-precondition', 'Impossible de retirer son propre rôle d\'administrateur.');
  }
  await appliquerRoles(cible.uid, roles);
  return { roles: rolesDe(nouveauxClaims({}, roles)) };
});

/** Envoie les messages (sauf dans l'émulateur) puis marque le document comme notifié. */
async function envoyer(ref, messages) {
  // Marqué d'abord : une nouvelle exécution ne renverra rien.
  await ref.update({ notifieLe: FieldValue.serverTimestamp() });
  if (process.env.FUNCTIONS_EMULATOR === 'true') {
    logger.info('Émulateur : notifications non envoyées', { messages });
    return;
  }
  const resultat = await getMessaging().sendEach(messages);
  if (resultat.failureCount > 0) {
    logger.warn('Notifications en échec', { echecs: resultat.failureCount });
  }
}

/** Annonce publiée avec « prévenir » : notification à tous, ou aux membres. */
export const notifierActualite = onDocumentWritten('actualites/{id}', async (event) => {
  const apres = event.data?.after;
  if (!apres?.exists || !doitNotifier(apres.data())) return;
  await envoyer(apres.ref, messagesActualite(event.params.id, apres.data()));
});

/** Événement publié avec « prévenir ». */
export const notifierEvenement = onDocumentWritten('evenements/{id}', async (event) => {
  const apres = event.data?.after;
  if (!apres?.exists || !doitNotifier(apres.data())) return;
  const e = apres.data();
  await envoyer(apres.ref, messagesEvenement(event.params.id, e, e.debut.toDate()));
});

/** Tient à jour le nombre de personnes inscrites à un événement. */
export const compterInscrits = onDocumentWritten(
  'evenements/{id}/inscriptions/{uid}',
  async (event) => {
    const ref = getFirestore().doc(`evenements/${event.params.id}`);
    const inscriptions = await ref.collection('inscriptions').get();
    const evenement = await ref.get();
    if (!evenement.exists) return;
    await ref.update({ inscrits: totalInscrits(inscriptions.docs.map((d) => d.data())) });
  },
);

/**
 * Annuaire : seulement le nom de chaque compte, lisible par les membres de
 * l'église (pour composer les groupes). Suit le profil `users/{uid}`.
 */
export const synchroniserAnnuaire = onDocumentWritten('users/{uid}', async (event) => {
  const ref = getFirestore().doc(`annuaire/${event.params.uid}`);
  const apres = event.data?.after;
  if (!apres?.exists) {
    await ref.delete();
    return;
  }
  const nom = apres.data().nom ?? '';
  if (event.data?.before?.data()?.nom === nom && (await ref.get()).exists) return;
  await ref.set({ nom });
});

/** Nouveau message de groupe : aperçu dans le groupe et notification aux membres. */
export const nouveauMessageGroupe = onDocumentCreated(
  'groupes/{gid}/messages/{mid}',
  async (event) => {
    const message = event.data?.data();
    if (!message) return;
    const db = getFirestore();
    const refGroupe = db.doc(`groupes/${event.params.gid}`);
    const groupe = (await refGroupe.get()).data();
    if (!groupe) return;
    await refGroupe.update({
      dernierMessage: {
        auteur: message.auteur,
        nom: message.nom,
        texte: apercu(message),
        le: message.createdAt ?? FieldValue.serverTimestamp(),
      },
    });
    await envoyerAuxComptes(
      destinataires(groupe.membres, message.auteur),
      (langue) => notificationMessage(groupe, event.params.gid, message, langue),
    );
  },
);

/**
 * Envoie une notification sur les téléphones de chaque compte, dans sa langue
 * ([construire] reçoit la langue). Retire les jetons expirés.
 */
async function envoyerAuxComptes(uids, construire) {
  if (process.env.FUNCTIONS_EMULATOR === 'true') {
    logger.info('Émulateur : notifications non envoyées', { uids });
    return;
  }
  const db = getFirestore();
  for (const uid of uids) {
    const refProfil = db.doc(`users/${uid}`);
    const profil = (await refProfil.get()).data();
    const jetons = profil?.jetonsNotif ?? [];
    if (jetons.length === 0) continue;
    const { notification, data } = construire(profil.langue);
    const res = await getMessaging().sendEachForMulticast({ tokens: jetons, notification, data });
    const invalides = jetons.filter((_, i) => {
      const code = res.responses[i].error?.code;
      return code === 'messaging/registration-token-not-registered'
        || code === 'messaging/invalid-registration-token';
    });
    if (invalides.length > 0) {
      await refProfil.update({ jetonsNotif: FieldValue.arrayRemove(...invalides) });
    }
  }
}

/** Nouveau rendez-vous dans le calendrier d'un groupe : les membres sont prévenus. */
export const nouvelleRencontre = onDocumentCreated(
  'groupes/{gid}/rencontres/{rid}',
  async (event) => {
    const r = event.data?.data();
    if (!r?.debut) return;
    const groupe = (await getFirestore().doc(`groupes/${event.params.gid}`).get()).data();
    if (!groupe) return;
    await envoyerAuxComptes(groupe.membres ?? [], (langue) => notificationRencontre(
      groupe, event.params.gid, event.params.rid, r, langue,
      quand(r.debut.toDate(), langue === 'nl' ? 'nl' : 'fr'),
    ));
  },
);

/** Un modérateur demande un remplaçant : les autres membres du groupe sont prévenus. */
export const demandeRemplacement = onDocumentUpdated(
  'groupes/{gid}/rencontres/{rid}',
  async (event) => {
    const avant = event.data?.before.data();
    const apres = event.data?.after.data();
    if (!remplacementVientDEtreDemande(avant, apres)) return;
    const db = getFirestore();
    const groupe = (await db.doc(`groupes/${event.params.gid}`).get()).data();
    if (!groupe) return;
    const nom = (await db.doc(`annuaire/${apres.moderateur}`).get()).data()?.nom ?? '';
    await envoyerAuxComptes(
      destinataires(groupe.membres, apres.moderateur),
      (langue) => notificationRemplacement(
        event.params.gid, event.params.rid, apres, nom, langue,
        quand(apres.debut.toDate(), langue === 'nl' ? 'nl' : 'fr'),
      ),
    );
  },
);

/** Toutes les heures : rappel la veille des rendez-vous des groupes. */
export const rappelsRencontres = onSchedule(
  { schedule: 'every 60 minutes', timeZone: 'Europe/Brussels' },
  async () => {
    const db = getFirestore();
    const maintenant = new Date();
    const snap = await db.collectionGroup('rencontres')
      .where('debut', '>', Timestamp.fromDate(maintenant))
      .where('debut', '<=', Timestamp.fromDate(new Date(maintenant.getTime() + 24 * 3600 * 1000)))
      .get();
    const liste = snap.docs.map((d) => ({ ...d.data(), ref: d.ref, id: d.id, debut: d.data().debut.toDate() }));
    for (const r of rappelsDus(liste, maintenant)) {
      // Marqué d'abord : pas de double rappel si la fonction est relancée.
      await r.ref.update({ rappelEnvoye: true });
      const refGroupe = r.ref.parent.parent;
      const groupe = (await refGroupe.get()).data();
      if (!groupe) continue;
      await envoyerAuxComptes(destinatairesRappel(groupe, r), (langue) => notificationRappel(
        groupe, refGroupe.id, r.id, r, langue,
        new Intl.DateTimeFormat(langue === 'nl' ? 'nl-BE' : 'fr-BE', {
          hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Brussels',
        }).format(r.debut),
      ));
    }
  },
);
