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
import {
  demandeAvancee, messagesFete, notificationApport, notificationNouvelleDemande, notificationPriere,
  notificationInscription, notificationQuestion, notificationReponse, notificationSuiviDemande,
  reponseDonnee,
} from './vie.js';
import {
  changementService, notificationAffectation, notificationChangement, notificationRappelService,
  rappelsServicesDus, messagesNettoyage, notificationRappelNettoyage,
} from './planning.js';
import {
  conflitsReservation, decisionPrise, notificationDecisionReservation,
  notificationDemandeReservation,
} from './salles.js';

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

/** Comptes ayant un des rôles (copie des rôles dans `users.roles`). */
async function comptesAvecRoles(roles) {
  const snap = await getFirestore().collection('users').where('roles', 'array-contains-any', roles).get();
  return snap.docs.map((d) => d.id);
}

/** Nouvelle demande : le secrétariat et les pasteurs sont prévenus. */
export const nouvelleDemande = onDocumentCreated('demandes/{id}', async (event) => {
  const d = event.data?.data();
  if (!d) return;
  await envoyerAuxComptes(
    await comptesAvecRoles(['admin', 'secretariat']),
    (langue) => notificationNouvelleDemande(event.params.id, d, langue),
  );
});

/** Réponse ou nouveau statut : la personne est prévenue. */
export const suiviDemande = onDocumentUpdated('demandes/{id}', async (event) => {
  const avant = event.data?.before.data();
  const apres = event.data?.after.data();
  if (!demandeAvancee(avant, apres)) return;
  await envoyerAuxComptes([apres.uid], (langue) => notificationSuiviDemande(event.params.id, apres, langue));
});

/** Nouveau sujet de prière : les pasteurs, et l'équipe d'intercession s'il est partagé. */
export const nouvellePriere = onDocumentCreated('prieres/{id}', async (event) => {
  const p = event.data?.data();
  if (!p) return;
  const pasteurs = (await comptesAvecRoles(['admin'])).filter((u) => u !== p.uid);
  await envoyerAuxComptes(pasteurs, (langue) =>
    notificationPriere(event.params.id, p, langue, { pourPasteur: true }));
  if (p.partage !== 'intercession' || !p.groupeId) return;
  const groupe = (await getFirestore().doc(`groupes/${p.groupeId}`).get()).data();
  if (!groupe) return;
  const equipe = destinataires(groupe.membres, p.uid).filter((u) => !pasteurs.includes(u));
  await envoyerAuxComptes(equipe, (langue) =>
    notificationPriere(event.params.id, p, langue, { pourPasteur: false }));
});

/** « J'ai prié » : nombre de personnes qui ont prié pour ce sujet. */
export const compterPriants = onDocumentWritten('prieres/{id}/priants/{uid}', async (event) => {
  const ref = getFirestore().doc(`prieres/${event.params.id}`);
  const n = (await ref.collection('priants').count().get()).data().count;
  if ((await ref.get()).exists) await ref.update({ nbPrieres: n });
});

/** Fête annoncée : notification aux membres connectés. */
export const nouvelleFete = onDocumentCreated('fetes/{id}', async (event) => {
  const f = event.data?.data();
  if (!f?.date) return;
  if (process.env.FUNCTIONS_EMULATOR === 'true') return;
  await getMessaging().sendEach(messagesFete(event.params.id, f, (l) => quand(f.date.toDate(), l)));
});

/** Quelqu'un indique ce qu'il apporte : les responsables cuisine sont prévenus. */
export const nouvelApport = onDocumentWritten('fetes/{id}/apports/{uid}', async (event) => {
  const a = event.data?.after?.data();
  if (!a) return;
  const db = getFirestore();
  const cuisineId = (await db.doc('parametres/eglise').get()).data()?.groupeCuisineId;
  if (!cuisineId) return;
  const [cuisine, fete] = await Promise.all([
    db.doc(`groupes/${cuisineId}`).get(), db.doc(`fetes/${event.params.id}`).get(),
  ]);
  if (!cuisine.exists || !fete.exists) return;
  await envoyerAuxComptes(
    destinataires(cuisine.data().membres, event.params.uid),
    (langue) => notificationApport(event.params.id, fete.data(), a, langue),
  );
});

/** Candidat inscrit à une préparation : il est prévenu. */
export const inscriptionPreparation = onDocumentCreated(
  'preparations/{prid}/inscrits/{uid}',
  async (event) => {
    const prep = (await getFirestore().doc(`preparations/${event.params.prid}`).get()).data();
    if (!prep) return;
    await envoyerAuxComptes([event.params.uid], (langue) =>
      notificationInscription(event.params.prid, prep, langue));
  },
);

/** Question d'un candidat : les pasteurs sont prévenus. */
export const questionPreparation = onDocumentCreated(
  'preparations/{prid}/inscrits/{uid}/questions/{qid}',
  async (event) => {
    const q = event.data?.data();
    if (!q) return;
    const inscrit = (await event.data.ref.parent.parent.get()).data();
    await envoyerAuxComptes(await comptesAvecRoles(['admin']), (langue) =>
      notificationQuestion(event.params.prid, event.params.uid, inscrit?.nom ?? '', q, langue));
  },
);

/** Réponse du pasteur : le candidat est prévenu. */
export const reponsePreparation = onDocumentUpdated(
  'preparations/{prid}/inscrits/{uid}/questions/{qid}',
  async (event) => {
    const avant = event.data?.before.data();
    const apres = event.data?.after.data();
    if (!reponseDonnee(avant, apres)) return;
    await envoyerAuxComptes([event.params.uid], (langue) =>
      notificationReponse(event.params.prid, apres, langue));
  },
);

/**
 * Secrétariat / pasteurs : reconstruit l'annuaire (nom de chaque compte) à
 * partir des profils, pour les comptes créés avant l'annuaire ou jamais mis à jour.
 */
export const reconstruireAnnuaire = onCall(async (requete) => {
  const t = requete.auth?.token;
  if (t?.admin !== true && t?.secretariat !== true) {
    throw new HttpsError('permission-denied', 'Réservé au secrétariat.');
  }
  const db = getFirestore();
  const [users, annuaire] = await Promise.all([
    db.collection('users').get(), db.collection('annuaire').get(),
  ]);
  const actuels = new Map(annuaire.docs.map((d) => [d.id, d.data().nom]));
  const lot = db.batch();
  let n = 0;
  for (const u of users.docs) {
    const nom = u.data().nom ?? '';
    if (actuels.get(u.id) !== nom) {
      lot.set(db.doc(`annuaire/${u.id}`), { nom });
      n += 1;
    }
    actuels.delete(u.id);
  }
  // Comptes supprimés : on retire leur nom.
  for (const id of actuels.keys()) {
    lot.delete(db.doc(`annuaire/${id}`));
    n += 1;
  }
  if (n > 0) await lot.commit();
  return { misAJour: n };
});

const quandL = (date, langue) => quand(date, langue === 'nl' ? 'nl' : 'fr');

/** Quelqu'un est mis au planning : il est prévenu. */
export const nouvelleAffectation = onDocumentCreated(
  'equipes/{eid}/affectations/{aid}',
  async (event) => {
    const a = event.data?.data();
    if (!a?.date) return;
    const equipe = (await getFirestore().doc(`equipes/${event.params.eid}`).get()).data();
    if (!equipe) return;
    await envoyerAuxComptes([a.uid], (langue) =>
      notificationAffectation(event.params.eid, equipe, a, langue, quandL(a.date.toDate(), langue)));
  },
);

/** Indisponible, remplaçant recherché ou remplacé : les bonnes personnes sont prévenues. */
export const changementAffectation = onDocumentUpdated(
  'equipes/{eid}/affectations/{aid}',
  async (event) => {
    const avant = event.data?.before.data();
    const apres = event.data?.after.data();
    const c = changementService(avant, apres);
    if (!c) return;
    const equipe = (await getFirestore().doc(`equipes/${event.params.eid}`).get()).data();
    if (!equipe) return;
    const cibles = c.cible === 'responsables'
      ? destinataires(equipe.responsables, apres.uid)
      : destinataires(equipe.membres, apres.uid);
    await envoyerAuxComptes(cibles, (langue) => notificationChangement(
      event.params.eid, c.genre, avant, apres, langue, quandL(apres.date.toDate(), langue)));
  },
);

/** Toutes les heures : rappel la veille de chaque service. */
export const rappelsServices = onSchedule(
  { schedule: 'every 60 minutes', timeZone: 'Europe/Brussels' },
  async () => {
    const db = getFirestore();
    const maintenant = new Date();
    const snap = await db.collectionGroup('affectations')
      .where('date', '>', Timestamp.fromDate(maintenant))
      .where('date', '<=', Timestamp.fromDate(new Date(maintenant.getTime() + 24 * 3600 * 1000)))
      .get();
    const liste = snap.docs.map((d) => ({ ...d.data(), ref: d.ref, date: d.data().date.toDate() }));
    for (const a of rappelsServicesDus(liste, maintenant)) {
      await a.ref.update({ rappelEnvoye: true });
      const refEquipe = a.ref.parent.parent;
      const equipe = (await refEquipe.get()).data();
      if (!equipe) continue;
      await envoyerAuxComptes([a.uid], (langue) => notificationRappelService(
        refEquipe.id, equipe, a, langue,
        new Intl.DateTimeFormat(langue === 'nl' ? 'nl-BE' : 'fr-BE', {
          hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Brussels',
        }).format(a.date),
      ));
    }
  },
);

/** Nouvelle séance de nettoyage : annonce aux membres. */
export const nouveauNettoyage = onDocumentCreated('nettoyages/{id}', async (event) => {
  const n = event.data?.data();
  if (!n?.date) return;
  if (process.env.FUNCTIONS_EMULATOR === 'true') return;
  await getMessaging().sendEach(messagesNettoyage(event.params.id, n, (l) => quand(n.date.toDate(), l)));
});

/** Nombre d'inscrits à une séance de nettoyage. */
export const compterNettoyage = onDocumentWritten('nettoyages/{id}/inscrits/{uid}', async (event) => {
  const ref = getFirestore().doc(`nettoyages/${event.params.id}`);
  const n = (await ref.collection('inscrits').count().get()).data().count;
  if ((await ref.get()).exists) await ref.update({ nbInscrits: n });
});

/** Toutes les heures : rappel la veille aux inscrits du nettoyage. */
export const rappelsNettoyage = onSchedule(
  { schedule: 'every 60 minutes', timeZone: 'Europe/Brussels' },
  async () => {
    const db = getFirestore();
    const maintenant = new Date();
    const snap = await db.collection('nettoyages')
      .where('date', '>', Timestamp.fromDate(maintenant))
      .where('date', '<=', Timestamp.fromDate(new Date(maintenant.getTime() + 24 * 3600 * 1000)))
      .get();
    for (const d of snap.docs) {
      const n = d.data();
      if (n.rappelEnvoye === true) continue;
      await d.ref.update({ rappelEnvoye: true });
      const inscrits = await d.ref.collection('inscrits').get();
      await envoyerAuxComptes(inscrits.docs.map((x) => x.id), (langue) => notificationRappelNettoyage(
        d.id, n, langue,
        new Intl.DateTimeFormat(langue === 'nl' ? 'nl-BE' : 'fr-BE', {
          hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Brussels',
        }).format(n.date.toDate()),
      ));
    }
  },
);

/** Demande de réservation : le secrétariat est prévenu. */
export const nouvelleReservation = onDocumentCreated('reservations/{id}', async (event) => {
  const r = event.data?.data();
  if (!r?.debut) return;
  await envoyerAuxComptes(await comptesAvecRoles(['admin', 'secretariat']), (langue) =>
    notificationDemandeReservation(event.params.id, r, langue, quandL(r.debut.toDate(), langue)));
});

/**
 * Décision du secrétariat. Filet de sécurité : si une autre réservation validée
 * occupe déjà le créneau (deux validations en même temps), la demande repasse
 * « en attente ». Sinon la personne est prévenue.
 */
export const decisionReservation = onDocumentUpdated('reservations/{id}', async (event) => {
  const avant = event.data?.before.data();
  const apres = event.data?.after.data();
  if (!decisionPrise(avant, apres)) return;
  if (apres.statut === 'validee') {
    const snap = await getFirestore().collection('reservations')
      .where('salleId', '==', apres.salleId).where('statut', '==', 'validee').get();
    const validees = snap.docs.map((d) => ({
      id: d.id, salleId: d.data().salleId, debut: d.data().debut.toDate(), fin: d.data().fin.toDate(),
    }));
    const r = { id: event.params.id, salleId: apres.salleId, debut: apres.debut.toDate(), fin: apres.fin.toDate() };
    if (conflitsReservation(r, validees).length > 0) {
      await event.data.after.ref.update({ statut: 'demandee', reponse: 'Conflit : créneau déjà réservé.' });
      return;
    }
  }
  await envoyerAuxComptes([apres.uid], (langue) =>
    notificationDecisionReservation(event.params.id, apres, langue, quandL(apres.debut.toDate(), langue)));
});
