import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp as supprimerAdmin, initializeApp as initAdmin } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import Stripe from 'stripe';

// Secret factice de functions/.secret.local : le webhook signé ainsi est accepté.
const SECRET = 'whsec_emulateur';
const PROJET = 'demo-mdo';
const WEBHOOK = `http://127.0.0.1:5001/${PROJET}/europe-west1/stripeWebhook`;
const stripe = new Stripe('sk_test_factice');

const admin = initAdminApp();
const db = getFirestore(admin);
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'paiements');
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const passerCommande = httpsCallable(fonctions, 'passerCommande');
const payerDon = httpsCallable(fonctions, 'payerDon');
const arreter = httpsCallable(fonctions, 'arreterDonMensuel');

function initAdminApp() {
  return initAdmin({ projectId: PROJET }, 'tests-paiements');
}

after(async () => { await signOut(auth); await deleteApp(app); await supprimerAdmin(admin); });

async function vider() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

/** Marie : compte et profil. */
async function marie() {
  const user = (await createUserWithEmailAndPassword(auth, 'marie@exemple.be', 'motdepasse1')).user;
  await db.doc(`users/${user.uid}`).set({ nom: 'Marie', email: 'marie@exemple.be', langue: 'fr' });
  return user;
}

async function envoyer(evenement, secret = SECRET) {
  const corps = JSON.stringify(evenement);
  const signature = stripe.webhooks.generateTestHeaderString({ payload: corps, secret });
  return fetch(WEBHOOK, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'stripe-signature': signature },
    body: corps,
  });
}

const refuse = (p, code) => assert.rejects(p, (e) => e.code === `functions/${code}`);

describe('boutique : commandes', () => {
  beforeEach(async () => {
    await vider();
    await db.doc('livres/priere').set({ titre: 'La prière', prix: 12.5, disponible: true });
    await db.doc('livres/epuise').set({ titre: 'Épuisé', prix: 8, disponible: false });
  });

  it('par virement : prix du catalogue, identifiant = communication structurée', async () => {
    const user = await marie();
    const res = await passerCommande({ mode: 'virement', lignes: [{ livreId: 'priere', quantite: 2, prix: 0.01 }] });
    assert.match(res.data.id, /^[1-9]\d{11}$/);
    assert.equal(res.data.url, undefined);
    const c = (await db.doc(`commandes/${res.data.id}`).get()).data();
    assert.equal(c.uid, user.uid);
    assert.equal(c.nom, 'Marie');
    assert.equal(c.total, 25);
    assert.equal(c.statut, 'en_attente');
    assert.equal(c.mode, 'virement');
  });

  it('en ligne : page de paiement, puis payée par le webhook', async () => {
    await marie();
    const res = await passerCommande({ mode: 'en_ligne', lignes: [{ livreId: 'priere', quantite: 1 }] });
    assert.equal(res.data.url, `https://stripe.test/commande-${res.data.id}`);
    const r = await envoyer({
      id: 'evt_1', object: 'event', type: 'checkout.session.completed',
      data: { object: {
        id: 'cs_1', mode: 'payment', payment_status: 'paid', payment_intent: 'pi_1',
        metadata: { type: 'commande', commandeId: res.data.id },
      } },
    });
    assert.equal(r.status, 200);
    const c = (await db.doc(`commandes/${res.data.id}`).get()).data();
    assert.equal(c.statut, 'payee');
    assert.equal(c.reference, 'pi_1');
    assert.ok(c.payeeLe);
  });

  it('refusée : livre épuisé, sans profil, sans connexion', async () => {
    await marie();
    await refuse(passerCommande({ mode: 'virement', lignes: [{ livreId: 'epuise', quantite: 1 }] }), 'invalid-argument');
    await refuse(passerCommande({ mode: 'cheque', lignes: [{ livreId: 'priere', quantite: 1 }] }), 'invalid-argument');
    await signOut(auth);
    await refuse(passerCommande({ mode: 'virement', lignes: [{ livreId: 'priere', quantite: 1 }] }), 'unauthenticated');
    await createUserWithEmailAndPassword(auth, 'jean@exemple.be', 'motdepasse1');
    await refuse(passerCommande({ mode: 'virement', lignes: [{ livreId: 'priere', quantite: 1 }] }), 'permission-denied');
  });
});

describe('dons en ligne', () => {
  beforeEach(vider);

  it('page de paiement pour un don valide seulement', async () => {
    await marie();
    const res = await payerDon({ montant: 50, affectation: 'dime', mensuel: false });
    assert.match(res.data.url, /^https:\/\/stripe\.test\/don-/);
    await refuse(payerDon({ montant: 0, affectation: 'dime' }), 'invalid-argument');
  });

  it('webhook : don reçu, don mensuel, arrêt par le donateur', async () => {
    const user = await marie();
    const meta = { type: 'don', uid: user.uid, nom: 'Marie', affectation: 'mission' };
    await envoyer({
      id: 'evt_2', object: 'event', type: 'checkout.session.completed',
      data: { object: { id: 'cs_2', mode: 'payment', payment_status: 'paid', amount_total: 3000, payment_intent: 'pi_2', metadata: meta } },
    });
    const d = (await db.doc('dons/cs_2').get()).data();
    assert.equal(d.montant, 30);
    assert.equal(d.statut, 'recu');
    assert.equal(d.mode, 'en_ligne');

    await envoyer({
      id: 'evt_3', object: 'event', type: 'checkout.session.completed',
      data: { object: { id: 'cs_3', mode: 'subscription', payment_status: 'paid', amount_total: 2000, subscription: 'sub_1', metadata: meta } },
    });
    assert.equal((await db.doc('donsMensuels/sub_1').get()).data().actif, true);
    await envoyer({
      id: 'evt_4', object: 'event', type: 'invoice.paid',
      data: { object: { id: 'in_1', amount_paid: 2000, parent: { subscription_details: { subscription: 'sub_1', metadata: meta } } } },
    });
    assert.equal((await db.doc('dons/in_1').get()).data().mode, 'mensuel');

    await arreter({ id: 'sub_1' });
    const m = (await db.doc('donsMensuels/sub_1').get()).data();
    assert.equal(m.actif, false);
    assert.ok(m.finLe);
  });

  it('signature invalide : refusée, rien n\'est écrit', async () => {
    const r = await envoyer({
      id: 'evt_5', object: 'event', type: 'checkout.session.completed',
      data: { object: { id: 'cs_5', mode: 'payment', payment_status: 'paid', amount_total: 100, metadata: { type: 'don', uid: 'x' } } },
    }, 'whsec_pirate');
    assert.equal(r.status, 400);
    assert.equal((await db.doc('dons/cs_5').get()).exists, false);
  });

  it('on ne peut pas arrêter le don mensuel de quelqu\'un d\'autre', async () => {
    await marie();
    await db.doc('donsMensuels/sub_9').set({ uid: 'paul', actif: true });
    await refuse(arreter({ id: 'sub_9' }), 'permission-denied');
  });
});
