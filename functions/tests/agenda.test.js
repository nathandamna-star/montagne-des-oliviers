import assert from 'node:assert/strict';
import { after, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase-admin/app';
import { Timestamp, getFirestore } from 'firebase-admin/firestore';

// SDK Admin branché sur l'émulateur (FIRESTORE_EMULATOR_HOST fourni par emulators:exec).
const app = initializeApp({ projectId: 'demo-mdo' }, 'tests-agenda');
const db = getFirestore(app);
after(() => deleteApp(app));

/** Attend qu'une condition soit vraie (les déclencheurs sont asynchrones). */
async function attendre(lire, condition, essais = 60) {
  for (let i = 0; i < essais; i++) {
    const v = await lire();
    if (condition(v)) return v;
    await new Promise((r) => setTimeout(r, 250));
  }
  throw new Error('Délai dépassé');
}

describe('agenda et annonces (déclencheurs)', () => {
  it('compte les personnes inscrites', async () => {
    const ref = db.doc('evenements/e-test');
    await ref.set({
      titre: { fr: 'Conférence' }, type: 'conference', publie: false, visibilite: 'public',
      debut: Timestamp.fromDate(new Date(2026, 9, 17, 14)), fin: Timestamp.fromDate(new Date(2026, 9, 17, 16)),
      inscription: true,
    });
    await ref.collection('inscriptions').doc('marie').set({ nom: 'Marie', personnes: 2 });
    await ref.collection('inscriptions').doc('paul').set({ nom: 'Paul', personnes: 3 });
    await attendre(() => ref.get(), (d) => d.data().inscrits === 5);
    await ref.collection('inscriptions').doc('paul').delete();
    await attendre(() => ref.get(), (d) => d.data().inscrits === 2);
  });

  it('annonce publiée avec « prévenir » : notifiée une seule fois', async () => {
    const ref = db.doc('actualites/a-test');
    await ref.set({ titre: { fr: 'Baptêmes' }, visibilite: 'public', publie: false, notifier: true });
    await new Promise((r) => setTimeout(r, 1500));
    assert.equal((await ref.get()).data().notifieLe, undefined);
    await ref.update({ publie: true });
    const d = await attendre(() => ref.get(), (x) => x.data().notifieLe !== undefined);
    assert.ok(d.data().notifieLe);
  });

  it('annonce sans « prévenir » : pas de notification', async () => {
    const ref = db.doc('actualites/a-silence');
    await ref.set({ titre: { fr: 'Info' }, visibilite: 'public', publie: true, notifier: false });
    await new Promise((r) => setTimeout(r, 2000));
    assert.equal((await ref.get()).data().notifieLe, undefined);
  });
});

describe('groupes (déclencheurs)', () => {
  it('annuaire : nom recopié du profil, effacé avec lui', async () => {
    await db.doc('users/u-annu').set({ nom: 'Hélène', email: 'h@x.be', langue: 'fr' });
    await attendre(() => db.doc('annuaire/u-annu').get(), (d) => d.exists && d.data().nom === 'Hélène');
    const d = await db.doc('annuaire/u-annu').get();
    assert.deepEqual(Object.keys(d.data()), ['nom']);
    await db.doc('users/u-annu').delete();
    await attendre(() => db.doc('annuaire/u-annu').get(), (x) => !x.exists);
  });

  it('nouveau message : aperçu du dernier message dans le groupe', async () => {
    await db.doc('groupes/g-test').set({ nom: 'Louange', membres: ['a', 'b'], admins: ['a'] });
    await db.collection('groupes/g-test/messages').add({
      auteur: 'a', nom: 'Anne', texte: 'Répétition jeudi 19 h', createdAt: Timestamp.now(),
    });
    const g = await attendre(() => db.doc('groupes/g-test').get(), (x) => x.data().dernierMessage);
    assert.equal(g.data().dernierMessage.texte, 'Répétition jeudi 19 h');
    assert.equal(g.data().dernierMessage.nom, 'Anne');
  });
});

describe('prières (déclencheurs)', () => {
  it("compte les « J'ai prié »", async () => {
    const ref = db.doc('prieres/p-test');
    await ref.set({ uid: 'x', nom: 'X', texte: 'Pour la paix', partage: 'pasteurs', statut: 'ouverte' });
    await ref.collection('priants').doc('a').set({ le: Timestamp.now() });
    await ref.collection('priants').doc('b').set({ le: Timestamp.now() });
    await attendre(() => ref.get(), (d) => d.data().nbPrieres === 2);
  });
});
