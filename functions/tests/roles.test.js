import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signInWithEmailAndPassword, signOut,
} from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-mdo';
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' });
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const revendiquer = httpsCallable(fonctions, 'revendiquerAdmin');
const definir = httpsCallable(fonctions, 'definirRoles');

async function vider() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

const compte = async (email) => (await createUserWithEmailAndPassword(auth, email, 'motdepasse1')).user;
const connecter = async (email) => (await signInWithEmailAndPassword(auth, email, 'motdepasse1')).user;
const claims = async (user) => (await user.getIdTokenResult(true)).claims;
const refuse = (p, code) => assert.rejects(p, (e) => e.code === `functions/${code}`);

after(async () => { await signOut(auth); await deleteApp(app); });

describe('administrateur', () => {
  beforeEach(vider);

  it('le compte configuré devient administrateur (majuscules tolérées)', async () => {
    const user = await compte('Pasteur@Exemple.be');
    assert.notEqual((await claims(user)).admin, true);
    await revendiquer();
    assert.equal((await claims(user)).admin, true);
    await revendiquer(); // Sans effet la deuxième fois.
  });

  it('un autre compte est refusé, et sans connexion aussi', async () => {
    await compte('intrus@exemple.be');
    await refuse(revendiquer(), 'permission-denied');
    await signOut(auth);
    await refuse(revendiquer(), 'unauthenticated');
  });
});

describe('rôles', () => {
  beforeEach(vider);

  it('l\'administrateur attribue puis retire des rôles', async () => {
    const jean = await compte('jean@exemple.be');
    await compte('pasteur@exemple.be');
    await revendiquer();
    await connecter('pasteur@exemple.be');

    const res = await definir({ email: ' Jean@Exemple.be ', roles: ['tresorier', 'secretariat'] });
    assert.deepEqual(res.data.roles, ['secretariat', 'tresorier']);
    let c = await claims(await connecter('jean@exemple.be'));
    assert.equal(c.tresorier, true);
    assert.equal(c.secretariat, true);
    assert.equal(jean.uid, auth.currentUser.uid);

    await connecter('pasteur@exemple.be');
    await definir({ email: 'jean@exemple.be', roles: [] });
    c = await claims(await connecter('jean@exemple.be'));
    assert.equal(c.tresorier, undefined);
    assert.equal(c.secretariat, undefined);
  });

  it('refus : non-administrateur, compte inconnu, rôle inconnu, retrait de soi-même', async () => {
    await compte('jean@exemple.be');
    await refuse(definir({ email: 'jean@exemple.be', roles: ['admin'] }), 'permission-denied');

    await compte('pasteur@exemple.be');
    await revendiquer();
    await connecter('pasteur@exemple.be');
    await refuse(definir({ email: 'personne@exemple.be', roles: [] }), 'not-found');
    await refuse(definir({ email: 'jean@exemple.be', roles: ['coach'] }), 'invalid-argument');
    await refuse(definir({ email: 'pasteur@exemple.be', roles: [] }), 'failed-precondition');
  });
});

describe('annuaire', () => {
  beforeEach(vider);

  it('reconstruit par le secrétariat ou l\'administrateur seulement', async () => {
    const reconstruire = httpsCallable(fonctions, 'reconstruireAnnuaire');
    await compte('jean@exemple.be');
    await refuse(reconstruire(), 'permission-denied');
    await compte('pasteur@exemple.be');
    await revendiquer();
    await connecter('pasteur@exemple.be');
    const res = await reconstruire();
    assert.equal(typeof res.data.misAJour, 'number');
  });
});
