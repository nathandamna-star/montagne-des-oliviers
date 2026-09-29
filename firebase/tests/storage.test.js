import { readFileSync } from 'node:fs';
import { after, before, describe, it } from 'node:test';
import {
  assertFails, assertSucceeds, initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
import { getBytes, ref, uploadBytes } from 'firebase/storage';

let env;
const ctx = (uid, claims) => env.authenticatedContext(uid, claims).storage();
const secretariat = () => ctx('secr', { secretariat: true });
const admin = () => ctx('pasteur', { admin: true });
const marie = () => ctx('marie');
const paul = () => ctx('paul');
const visiteur = () => env.unauthenticatedContext().storage();
const octets = new Uint8Array([1, 2, 3]);
const envoyer = (s, chemin, type) => uploadBytes(ref(s, chemin), octets, { contentType: type });

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mdo',
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: readFileSync(new URL('../storage.rules', import.meta.url), 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
  await env.withSecurityRulesDisabled(async (c) => {
    const db = c.firestore();
    await setDoc(doc(db, 'groupes/g1'), { membres: ['marie', 'paul'], admins: ['marie'] });
    await setDoc(doc(db, 'preparations/bap/inscrits/marie'), { faites: [] });
    await setDoc(doc(db, 'preparations/bap/lecons/l1'), { publique: false });
    await setDoc(doc(db, 'preparations/bap/lecons/l2'), { publique: true });
  });
});
after(async () => { await env.cleanup(); });

describe('fichiers', () => {
  it('photo de profil : chacun la sienne, images seulement', async () => {
    await assertSucceeds(envoyer(marie(), 'users/marie/profil.jpg', 'image/jpeg'));
    await assertFails(envoyer(marie(), 'users/paul/profil.jpg', 'image/jpeg'));
    await assertFails(envoyer(marie(), 'users/marie/film.mp4', 'video/mp4'));
  });

  it('médias : envoyés par le secrétariat, publics', async () => {
    await assertSucceeds(envoyer(secretariat(), 'medias/m1/exhortation.m4a', 'audio/mp4'));
    await assertSucceeds(envoyer(secretariat(), 'medias/m1/culte.mp4', 'video/mp4'));
    await assertFails(envoyer(secretariat(), 'medias/m1/x.zip', 'application/zip'));
    await assertFails(envoyer(marie(), 'medias/m1/a.m4a', 'audio/mp4'));
    await assertSucceeds(getBytes(ref(visiteur(), 'medias/m1/exhortation.m4a')));
    await assertSucceeds(envoyer(secretariat(), 'actualites/a1/photo.jpg', 'image/jpeg'));
    await assertFails(envoyer(marie(), 'actualites/a1/photo.jpg', 'image/jpeg'));
  });

  it('préparations : le pasteur envoie ; les inscrits lisent (tous si leçon publique)', async () => {
    await assertSucceeds(envoyer(admin(), 'preparations/bap/l1/lecon.mp4', 'video/mp4'));
    await assertSucceeds(envoyer(admin(), 'preparations/bap/l1/support.pdf', 'application/pdf'));
    await assertSucceeds(envoyer(admin(), 'preparations/bap/l2/intro.m4a', 'audio/mp4'));
    await assertFails(envoyer(secretariat(), 'preparations/bap/l1/x.mp4', 'video/mp4'));
    await assertSucceeds(getBytes(ref(marie(), 'preparations/bap/l1/lecon.mp4')));
    await assertFails(getBytes(ref(paul(), 'preparations/bap/l1/lecon.mp4')));
    await assertSucceeds(getBytes(ref(paul(), 'preparations/bap/l2/intro.m4a')));
  });

  it('boutique : couvertures envoyées par le trésorier ou le secrétariat, publiques', async () => {
    const tresorier = () => env.authenticatedContext('tres', { tresorier: true }).storage();
    await assertSucceeds(envoyer(tresorier(), 'livres/l1/couverture.jpg', 'image/jpeg'));
    await assertSucceeds(envoyer(secretariat(), 'livres/l1/couverture.jpg', 'image/jpeg'));
    await assertFails(envoyer(marie(), 'livres/l1/couverture.jpg', 'image/jpeg'));
    await assertFails(envoyer(tresorier(), 'livres/l1/livre.pdf', 'application/pdf'));
    await assertSucceeds(getBytes(ref(visiteur(), 'livres/l1/couverture.jpg')));
  });

  it('photo du pasteur : envoyée par un administrateur, publique', async () => {
    await assertSucceeds(envoyer(admin(), 'parametres/pasteur.jpg', 'image/jpeg'));
    await assertFails(envoyer(secretariat(), 'parametres/pasteur.jpg', 'image/jpeg'));
    await assertSucceeds(getBytes(ref(visiteur(), 'parametres/pasteur.jpg')));
  });

  it('groupes : les membres partagent photos, documents, audios', async () => {
    await assertSucceeds(envoyer(paul(), 'groupes/g1/partition.pdf', 'application/pdf'));
    await assertFails(envoyer(ctx('luc'), 'groupes/g1/x.pdf', 'application/pdf'));
    await assertFails(getBytes(ref(ctx('luc'), 'groupes/g1/partition.pdf')));
    await assertSucceeds(getBytes(ref(marie(), 'groupes/g1/partition.pdf')));
  });
});
