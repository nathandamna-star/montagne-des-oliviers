// Fonctions serveur Montagne des Oliviers.
// Elles s'exécutent avec les droits du SDK Admin, hors règles de sécurité :
// chaque fonction vérifie elle-même qui l'appelle.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { defineString } from 'firebase-functions/params';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { nouveauxClaims, normaliser, rolesDe } from './roles.js';

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
