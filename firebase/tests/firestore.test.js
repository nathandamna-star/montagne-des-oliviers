import { readFileSync } from 'node:fs';
import { after, afterEach, before, describe, it } from 'node:test';
import {
  assertFails, assertSucceeds, initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc,
} from 'firebase/firestore';

let env;
const marie = () => env.authenticatedContext('marie').firestore();
const paul = () => env.authenticatedContext('paul').firestore();
const admin = () => env.authenticatedContext('pasteur', { admin: true }).firestore();
const secretariat = () => env.authenticatedContext('secr', { secretariat: true }).firestore();
const tresorier = () => env.authenticatedContext('tres', { tresorier: true }).firestore();
const visiteur = () => env.unauthenticatedContext().firestore();

const profil = (extra = {}) => ({
  nom: 'Marie', email: 'marie@x.be', langue: 'fr',
  consentementLe: serverTimestamp(), createdAt: serverTimestamp(), ...extra,
});

async function existant() {
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'users/marie'), {
      nom: 'Marie', email: 'marie@x.be', langue: 'fr', consentementLe: new Date(2026, 0, 1),
    });
  });
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mdo',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});
afterEach(async () => { await env.clearFirestore(); });
after(async () => { await env.cleanup(); });

describe('profils', () => {
  it('chacun crée son profil avec un consentement daté par le serveur', async () => {
    await assertSucceeds(setDoc(doc(marie(), 'users/marie'), profil()));
    await assertSucceeds(setDoc(doc(paul(), 'users/paul'), profil({ nom: 'Paul', langue: 'nl' })));
  });

  it('création refusée : sans consentement, date inventée, rôle, autre langue, pour un autre', async () => {
    const sansConsentement = profil();
    delete sansConsentement.consentementLe;
    await assertFails(setDoc(doc(marie(), 'users/marie'), sansConsentement));
    await assertFails(setDoc(doc(marie(), 'users/marie'), profil({ consentementLe: new Date(2020, 0, 1) })));
    await assertFails(setDoc(doc(marie(), 'users/marie'), profil({ roles: ['admin'] })));
    await assertFails(setDoc(doc(marie(), 'users/marie'), profil({ langue: 'en' })));
    await assertFails(setDoc(doc(marie(), 'users/marie'), profil({ nom: '' })));
    await assertFails(setDoc(doc(paul(), 'users/marie'), profil()));
    await assertFails(setDoc(doc(visiteur(), 'users/marie'), profil()));
  });

  it('lecture : soi-même, le secrétariat et l\'administrateur', async () => {
    await existant();
    await assertSucceeds(getDoc(doc(marie(), 'users/marie')));
    await assertSucceeds(getDoc(doc(secretariat(), 'users/marie')));
    await assertSucceeds(getDoc(doc(admin(), 'users/marie')));
    await assertFails(getDoc(doc(tresorier(), 'users/marie')));
    await assertFails(getDoc(doc(paul(), 'users/marie')));
    await assertFails(getDoc(doc(visiteur(), 'users/marie')));
  });

  it('modification limitée à ses propres informations', async () => {
    await existant();
    await assertSucceeds(updateDoc(doc(marie(), 'users/marie'), { nom: 'Marie D.', langue: 'nl' }));
    await assertSucceeds(updateDoc(doc(marie(), 'users/marie'), { jetonsNotif: ['abc'], decalageMin: 120 }));
    await assertFails(updateDoc(doc(marie(), 'users/marie'), { roles: ['admin'] }));
    await assertFails(updateDoc(doc(marie(), 'users/marie'), { consentementLe: new Date() }));
    await assertFails(updateDoc(doc(marie(), 'users/marie'), { photoUrl: 'javascript:x' }));
    await assertFails(updateDoc(doc(paul(), 'users/marie'), { nom: 'Pirate' }));
    await assertFails(updateDoc(doc(secretariat(), 'users/marie'), { nom: 'Autre' }));
  });

  it('suppression par soi-même uniquement', async () => {
    await existant();
    await assertFails(deleteDoc(doc(paul(), 'users/marie')));
    await assertFails(deleteDoc(doc(admin(), 'users/marie')));
    await assertSucceeds(deleteDoc(doc(marie(), 'users/marie')));
  });
});

describe('système', () => {
  it('inaccessible depuis l\'app, même pour l\'administrateur', async () => {
    await assertFails(getDoc(doc(admin(), 'systeme/admin')));
    await assertFails(setDoc(doc(admin(), 'systeme/admin'), { uid: 'pasteur' }));
  });
});
