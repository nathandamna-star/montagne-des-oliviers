import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp as supprimerAdmin, initializeApp as initAdmin } from 'firebase-admin/app';
import { getAuth as authAdmin } from 'firebase-admin/auth';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-mdo';
const admin = initAdmin({ projectId: PROJET }, 'tests-compte');
const db = getFirestore(admin);
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'compte');
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const exporter = httpsCallable(fonctions, 'exporterMesDonnees');
const supprimer = httpsCallable(fonctions, 'supprimerMonCompte');

after(async () => { await signOut(auth); await deleteApp(app); await supprimerAdmin(admin); });

async function vider() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

const t = Timestamp.fromDate(new Date(2026, 9, 5, 10));

/** Marie, membre active : un peu de tout dans l'app. */
async function marie() {
  const { uid } = (await createUserWithEmailAndPassword(auth, 'marie@exemple.be', 'motdepasse1')).user;
  const docs = {
    [`users/${uid}`]: { nom: 'Marie', email: 'marie@exemple.be', langue: 'fr', jetonsNotif: ['jeton'] },
    'membres/m1': { nom: 'Dupont', prenom: 'Marie', statut: 'membre', uid },
    'demandes/d1': { uid, nom: 'Marie', type: 'bapteme', statut: 'nouvelle' },
    'prieres/p1': { uid, nom: 'Marie', texte: 'Pour ma santé' },
    'prieres/p2': { uid: 'paul', nom: 'Paul', texte: 'Pour mon travail' },
    [`prieres/p2/priants/${uid}`]: { le: t },
    'groupes/g1': { nom: 'Louange', membres: [uid, 'paul'], admins: [uid, 'paul'] },
    'groupes/g1/messages/a': { auteur: uid, nom: 'Marie', texte: 'Bonjour', createdAt: t },
    'groupes/g1/messages/b': { auteur: 'paul', nom: 'Paul', texte: 'Salut', createdAt: t },
    'groupes/g1/rencontres/r1': { titre: 'Répétition', debut: t },
    [`groupes/g1/rencontres/r1/presences/${uid}`]: { reponse: 'oui' },
    'equipes/e1': { nom: 'Accueil', membres: [uid, 'paul'], responsables: [uid] },
    'equipes/e1/affectations/x': { uid, nom: 'Marie', titre: 'Culte', date: t, statut: 'prevu' },
    'evenements/ev1': { titre: { fr: 'Conférence' } },
    [`evenements/ev1/inscriptions/${uid}`]: { nom: 'Marie', personnes: 2 },
    'nettoyages/n1': { titre: 'Grand nettoyage', date: t },
    [`nettoyages/n1/inscrits/${uid}`]: { nom: 'Marie' },
    'reservations/r1': { uid, nom: 'Marie', salleId: 's1', statut: 'demandee' },
    'dons/100000000034': { uid, nom: 'Marie', montant: 50, affectation: 'dime', mode: 'virement', statut: 'recu' },
    'dons/200000000068': { uid, nom: 'Marie', montant: 20, affectation: 'dime', mode: 'virement', statut: 'en_attente' },
    'commandes/c1': { uid, nom: 'Marie', total: 12, mode: 'en_ligne', statut: 'remise' },
  };
  for (const [chemin, d] of Object.entries(docs)) await db.doc(chemin).set(d);
  return uid;
}

describe('mes données (RGPD)', () => {
  beforeEach(vider);

  it('export : tout ce qui concerne la personne, sans jetons techniques', async () => {
    await marie();
    const { data } = await exporter();
    assert.equal(data.profil.nom, 'Marie');
    assert.equal(data.profil.jetonsNotif, undefined);
    assert.equal(data.ficheMembre[0].prenom, 'Marie');
    assert.deepEqual(data.groupes, [{ id: 'g1', nom: 'Louange' }]);
    assert.deepEqual(data.messagesGroupes.map((m) => m.texte), ['Bonjour']);
    assert.deepEqual(data.jaiPrie, ['p2']);
    assert.equal(data.inscriptionsEvenements[0].personnes, 2);
    assert.equal(data.presences[0].reponse, 'oui');
    assert.equal(data.dons.length, 2);
    assert.equal(data.services[0].titre, 'Culte');
  });

  it('suppression : tout est effacé, dons et commandes anonymisés, fiche détachée', async () => {
    const uid = await marie();
    await supprimer();
    const existe = async (c) => (await db.doc(c).get()).exists;
    for (const c of [`users/${uid}`, 'demandes/d1', 'prieres/p1', `prieres/p2/priants/${uid}`, 'groupes/g1/messages/a',
      `groupes/g1/rencontres/r1/presences/${uid}`, 'equipes/e1/affectations/x', `evenements/ev1/inscriptions/${uid}`,
      `nettoyages/n1/inscrits/${uid}`, 'reservations/r1']) {
      assert.equal(await existe(c), false, c);
    }
    assert.equal(await existe('groupes/g1/messages/b'), true);
    assert.equal(await existe('prieres/p2'), true);
    const g = (await db.doc('groupes/g1').get()).data();
    assert.deepEqual([g.membres, g.admins], [['paul'], ['paul']]);
    assert.deepEqual((await db.doc('equipes/e1').get()).data().responsables, []);
    const fiche = (await db.doc('membres/m1').get()).data();
    assert.equal(fiche.uid, undefined);
    assert.equal(fiche.prenom, 'Marie');
    const recu = (await db.doc('dons/100000000034').get()).data();
    assert.deepEqual([recu.uid, recu.nom, recu.statut, recu.montant], ['compte-supprime', '', 'recu', 50]);
    assert.equal((await db.doc('dons/200000000068').get()).data().statut, 'annule');
    assert.equal((await db.doc('commandes/c1').get()).data().uid, 'compte-supprime');
    await assert.rejects(authAdmin(admin).getUser(uid));
  });

  it('refusée tant qu\'un livre payé attend d\'être retiré', async () => {
    const uid = await marie();
    await db.doc('commandes/c2').set({ uid, nom: 'Marie', total: 8, mode: 'en_ligne', statut: 'payee' });
    await assert.rejects(supprimer(), (e) => e.code === 'functions/failed-precondition' && e.details?.code === 'commande-a-retirer');
    assert.equal((await db.doc(`users/${uid}`).get()).exists, true);
  });

  it('refusée pour le seul administrateur', async () => {
    const uid = await marie();
    await authAdmin(admin).setCustomUserClaims(uid, { admin: true });
    await auth.currentUser.getIdToken(true);
    await assert.rejects(supprimer(), (e) => e.details?.code === 'dernier-admin');
  });
});

describe('pages légales', () => {
  beforeEach(vider);

  it('servies en français et en néerlandais, avec l\'e-mail de contact de l\'église', async () => {
    await db.doc('parametres/eglise').set({ emailContact: 'info@montagne.be' });
    const base = `http://127.0.0.1:5001/${PROJET}/europe-west1/legal`;
    const fr = await (await fetch(`${base}/legal/confidentialite`)).text();
    assert.match(fr, /Politique de confidentialité/);
    assert.match(fr, /info@montagne\.be/);
    const nl = await (await fetch(`${base}/legal/conditions?langue=nl`)).text();
    assert.match(nl, /Gebruiksvoorwaarden/);
  });
});
