// Fonctions serveur Montagne des Oliviers.
// Elles s'exécutent avec les droits du SDK Admin, hors règles de sécurité :
// chaque fonction vérifie elle-même qui l'appelle.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { defineString } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { onDocumentCreated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { logger } from 'firebase-functions';
import { nouveauxClaims, normaliser, rolesDe } from './roles.js';
import {
  doitNotifier, messagesActualite, messagesEvenement, totalInscrits,
} from './notifications.js';
import { apercu, destinataires, notificationMessage } from './groupes.js';

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
    if (process.env.FUNCTIONS_EMULATOR === 'true') return;
    for (const uid of destinataires(groupe.membres, message.auteur)) {
      const refProfil = db.doc(`users/${uid}`);
      const profil = (await refProfil.get()).data();
      const jetons = profil?.jetonsNotif ?? [];
      if (jetons.length === 0) continue;
      const { notification, data } = notificationMessage(
        groupe, event.params.gid, message, profil.langue,
      );
      const res = await getMessaging().sendEachForMulticast({ tokens: jetons, notification, data });
      // Jetons expirés : on les retire du profil.
      const invalides = jetons.filter((_, i) => {
        const code = res.responses[i].error?.code;
        return code === 'messaging/registration-token-not-registered'
          || code === 'messaging/invalid-registration-token';
      });
      if (invalides.length > 0) {
        await refProfil.update({ jetonsNotif: FieldValue.arrayRemove(...invalides) });
      }
    }
  },
);
