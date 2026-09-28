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
