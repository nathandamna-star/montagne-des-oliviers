import { readFileSync } from 'node:fs';
import { after, afterEach, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails, assertSucceeds, initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp, collection, collectionGroup, deleteDoc, doc, getDoc, getDocs, query, serverTimestamp, setDoc,
  updateDoc, where,
} from 'firebase/firestore';

let env;
const marie = () => env.authenticatedContext('marie').firestore();
const paul = () => env.authenticatedContext('paul').firestore();
const admin = () => env.authenticatedContext('pasteur', { admin: true }).firestore();
const secretariat = () => env.authenticatedContext('secr', { secretariat: true }).firestore();
const tresorier = () => env.authenticatedContext('tres', { tresorier: true }).firestore();
const visiteur = () => env.unauthenticatedContext().firestore();
// Connecté mais sans profil (consentement pas encore donné).
const sansProfil = () => env.authenticatedContext('jean').firestore();

/** Écrit des documents sans passer par les règles. */
async function semer(docs) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    for (const [chemin, donnees] of Object.entries(docs)) {
      await setDoc(doc(ctx.firestore(), chemin), donnees);
    }
  });
}

// Marie et Paul sont membres (profil créé) ; Jean n'a pas de profil.
const MEMBRES = {
  'users/marie': { nom: 'Marie', email: 'marie@x.be', langue: 'fr' },
  'users/paul': { nom: 'Paul', email: 'paul@x.be', langue: 'nl' },
};
const t = (j) => Timestamp.fromDate(new Date(2026, 9, j, 10));

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

describe('fichier des membres et familles', () => {
  const fiche = { nom: 'Dubois', prenom: 'Marie', statut: 'actif', uid: 'marie' };

  it('secrétariat et administrateur seulement ; la personne voit sa fiche', async () => {
    await assertSucceeds(setDoc(doc(secretariat(), 'membres/m1'), fiche));
    await assertSucceeds(getDoc(doc(admin(), 'membres/m1')));
    await assertSucceeds(getDoc(doc(marie(), 'membres/m1')));
    await assertFails(getDoc(doc(paul(), 'membres/m1')));
    await assertFails(getDoc(doc(tresorier(), 'membres/m1')));
    await assertFails(setDoc(doc(marie(), 'membres/m2'), { ...fiche, uid: 'marie' }));
    await assertFails(setDoc(doc(secretariat(), 'membres/m3'), { ...fiche, statut: 'ancien' }));
    await assertSucceeds(setDoc(doc(secretariat(), 'familles/f1'), { nom: 'Famille Dubois' }));
    await assertFails(getDoc(doc(marie(), 'familles/f1')));
  });
});

describe('paramètres de l\'église', () => {
  it('lisibles par tous, modifiés par le trésorier ou l\'administrateur', async () => {
    await assertSucceeds(setDoc(doc(tresorier(), 'parametres/eglise'), { iban: 'BE00' }));
    await assertSucceeds(getDoc(doc(visiteur(), 'parametres/eglise')));
    await assertFails(setDoc(doc(secretariat(), 'parametres/eglise'), { iban: 'BE11' }));
    await assertFails(setDoc(doc(marie(), 'parametres/eglise'), { iban: 'BE11' }));
  });
});

describe('actualités, médias et versets', () => {
  const actu = (extra = {}) => ({
    titre: { fr: 'Culte de Noël', nl: 'Kerstdienst' }, texte: { fr: 'Bienvenue à tous' },
    visibilite: 'public', publie: true, epingle: false, ...extra,
  });

  it('le secrétariat publie ; les autres non', async () => {
    await assertSucceeds(setDoc(doc(secretariat(), 'actualites/a1'), actu()));
    await assertFails(setDoc(doc(marie(), 'actualites/a2'), actu()));
    await assertFails(setDoc(doc(secretariat(), 'actualites/a3'), actu({ titre: { nl: 'Alleen NL' } })));
    await assertFails(setDoc(doc(secretariat(), 'actualites/a4'), actu({ photoUrl: 'http://x' })));
  });

  it('public : tout le monde ; membres : membres connectés ; brouillon : secrétariat', async () => {
    await semer({
      ...MEMBRES,
      'actualites/pub': actu(),
      'actualites/mem': actu({ visibilite: 'membres' }),
      'actualites/brouillon': actu({ publie: false }),
    });
    await assertSucceeds(getDoc(doc(visiteur(), 'actualites/pub')));
    await assertFails(getDoc(doc(visiteur(), 'actualites/mem')));
    await assertFails(getDoc(doc(sansProfil(), 'actualites/mem')));
    await assertSucceeds(getDoc(doc(marie(), 'actualites/mem')));
    await assertFails(getDoc(doc(marie(), 'actualites/brouillon')));
    await assertSucceeds(getDoc(doc(secretariat(), 'actualites/brouillon')));
    // Liste des visiteurs : la requête doit filtrer ce qu'ils peuvent lire.
    await assertSucceeds(getDocs(query(collection(visiteur(), 'actualites'),
      where('publie', '==', true), where('visibilite', '==', 'public'))));
    await assertFails(getDocs(collection(visiteur(), 'actualites')));
  });

  it('médias et verset du jour', async () => {
    const media = { type: 'audio', titre: { fr: 'Exhortation' }, visibilite: 'public', publie: true, url: 'https://x/a.m4a' };
    await assertSucceeds(setDoc(doc(secretariat(), 'medias/m1'), media));
    await assertFails(setDoc(doc(secretariat(), 'medias/m2'), { ...media, type: 'podcast' }));
    await assertFails(setDoc(doc(marie(), 'medias/m3'), media));
    await assertSucceeds(getDoc(doc(visiteur(), 'medias/m1')));
    const verset = { reference: 'Jean 3:16', texte: { fr: 'Car Dieu a tant aimé…' }, ordre: 1 };
    await assertSucceeds(setDoc(doc(secretariat(), 'versets/v1'), verset));
    await assertSucceeds(getDoc(doc(visiteur(), 'versets/v1')));
    await assertFails(setDoc(doc(marie(), 'versets/v2'), verset));
  });
});

describe('calendrier et inscriptions', () => {
  const evt = (extra = {}) => ({
    titre: { fr: 'Conférence' }, type: 'conference', debut: t(10), fin: t(11),
    visibilite: 'public', publie: true, inscription: true, ...extra,
  });

  it('le secrétariat crée les événements (dates cohérentes)', async () => {
    await assertSucceeds(setDoc(doc(secretariat(), 'evenements/e1'), evt()));
    await assertFails(setDoc(doc(secretariat(), 'evenements/e2'), evt({ fin: t(9) })));
    await assertFails(setDoc(doc(secretariat(), 'evenements/e3'), evt({ type: 'fete' })));
    await assertFails(setDoc(doc(marie(), 'evenements/e4'), evt()));
    await assertSucceeds(getDoc(doc(visiteur(), 'evenements/e1')));
  });

  it('chacun s\'inscrit soi-même, si l\'inscription est ouverte', async () => {
    await semer({ ...MEMBRES, 'evenements/e1': evt(), 'evenements/ferme': evt({ inscription: false }) });
    const insc = { nom: 'Marie', personnes: 2, createdAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(marie(), 'evenements/e1/inscriptions/marie'), insc));
    await assertFails(setDoc(doc(marie(), 'evenements/e1/inscriptions/paul'), insc));
    await assertFails(setDoc(doc(marie(), 'evenements/ferme/inscriptions/marie'), insc));
    await assertFails(setDoc(doc(sansProfil(), 'evenements/e1/inscriptions/jean'), insc));
    await assertFails(setDoc(doc(paul(), 'evenements/e1/inscriptions/paul'), { ...insc, personnes: 50 }));
    await assertFails(getDoc(doc(paul(), 'evenements/e1/inscriptions/marie')));
    await assertSucceeds(getDoc(doc(secretariat(), 'evenements/e1/inscriptions/marie')));
    await assertSucceeds(deleteDoc(doc(marie(), 'evenements/e1/inscriptions/marie')));
  });
});

describe('demandes', () => {
  const demande = (extra = {}) => ({
    uid: 'marie', nom: 'Marie', type: 'bapteme', message: 'Je souhaite être baptisée',
    statut: 'nouvelle', createdAt: serverTimestamp(), ...extra,
  });

  it('un membre fait sa demande ; le secrétariat la suit', async () => {
    await semer(MEMBRES);
    await assertSucceeds(setDoc(doc(marie(), 'demandes/d1'), demande()));
    await assertFails(setDoc(doc(marie(), 'demandes/d2'), demande({ uid: 'paul' })));
    await assertFails(setDoc(doc(marie(), 'demandes/d3'), demande({ statut: 'acceptee' })));
    await assertFails(setDoc(doc(marie(), 'demandes/d4'), demande({ type: 'divorce' })));
    await assertFails(setDoc(doc(sansProfil(), 'demandes/d5'), demande({ uid: 'jean' })));
    await assertFails(getDoc(doc(paul(), 'demandes/d1')));
    await assertSucceeds(getDoc(doc(marie(), 'demandes/d1')));
    await assertFails(updateDoc(doc(marie(), 'demandes/d1'), { statut: 'acceptee' }));
    await assertSucceeds(updateDoc(doc(secretariat(), 'demandes/d1'), { statut: 'en_cours', reponse: 'Rendez-vous dimanche' }));
    // Plus retirable une fois prise en charge.
    await assertFails(deleteDoc(doc(marie(), 'demandes/d1')));
  });
});

describe('groupes', () => {
  const grp = (extra = {}) => ({
    nom: 'Intercession du mardi', type: 'intercession', prive: true,
    membres: ['marie', 'paul'], admins: ['marie'], lienAppel: '', ...extra,
  });

  it('le secrétariat crée un groupe avec au moins un administrateur membre', async () => {
    await assertSucceeds(setDoc(doc(secretariat(), 'groupes/g1'), grp()));
    await assertFails(setDoc(doc(secretariat(), 'groupes/g2'), grp({ admins: [] })));
    await assertFails(setDoc(doc(secretariat(), 'groupes/g3'), grp({ admins: ['jean'] })));
    await assertFails(setDoc(doc(marie(), 'groupes/g4'), grp()));
  });

  it('lecture : membres du groupe privé ; groupe ouvert pour les membres de l\'église', async () => {
    await semer({
      ...MEMBRES, 'users/luc': { nom: 'Luc' },
      'groupes/prive': grp(), 'groupes/ouvert': grp({ prive: false, type: 'jeunes' }),
    });
    const luc = env.authenticatedContext('luc').firestore();
    await assertSucceeds(getDoc(doc(paul(), 'groupes/prive')));
    await assertFails(getDoc(doc(luc, 'groupes/prive')));
    await assertSucceeds(getDoc(doc(luc, 'groupes/ouvert')));
    await assertFails(getDoc(doc(visiteur(), 'groupes/ouvert')));
    await assertSucceeds(getDoc(doc(secretariat(), 'groupes/prive')));
  });

  it('l\'administrateur du groupe ajoute, retire et nomme ; un membre non', async () => {
    await semer({ 'groupes/g1': grp() });
    await assertSucceeds(updateDoc(doc(marie(), 'groupes/g1'), { membres: ['marie', 'paul', 'luc'] }));
    await assertSucceeds(updateDoc(doc(marie(), 'groupes/g1'), { admins: ['marie', 'paul'], lienAppel: 'https://meet.google.com/abc' }));
    await assertFails(updateDoc(doc(marie(), 'groupes/g1'), { lienAppel: 'http://pas-sur' }));
    await assertFails(updateDoc(doc(marie(), 'groupes/g1'), { type: 'louange' }));
    await semer({ 'groupes/g2': grp() });
    await assertFails(updateDoc(doc(paul(), 'groupes/g2'), { membres: ['paul', 'luc', 'marie'] }));
    await assertFails(updateDoc(doc(paul(), 'groupes/g2'), { admins: ['marie', 'paul'] }));
  });

  it('un membre peut quitter le groupe (seulement lui-même)', async () => {
    await semer({ 'groupes/g1': grp({ membres: ['marie', 'paul', 'luc'] }) });
    await assertFails(updateDoc(doc(paul(), 'groupes/g1'), { membres: ['marie'] }));
    await assertSucceeds(updateDoc(doc(paul(), 'groupes/g1'), { membres: ['marie', 'luc'] }));
    // Le dernier administrateur ne peut pas partir ainsi.
    await assertFails(updateDoc(doc(marie(), 'groupes/g1'), { membres: ['luc'], admins: [] }));
  });

  it('messagerie : membres seulement, à son nom', async () => {
    await semer({ 'groupes/g1': grp() });
    const msg = (auteur) => ({ auteur, nom: 'X', texte: 'Prions ensemble', createdAt: serverTimestamp() });
    await assertSucceeds(setDoc(doc(paul(), 'groupes/g1/messages/m1'), msg('paul')));
    await assertFails(setDoc(doc(paul(), 'groupes/g1/messages/m2'), msg('marie')));
    const luc = env.authenticatedContext('luc').firestore();
    await assertFails(setDoc(doc(luc, 'groupes/g1/messages/m3'), msg('luc')));
    await assertFails(getDoc(doc(luc, 'groupes/g1/messages/m1')));
    await assertSucceeds(getDoc(doc(marie(), 'groupes/g1/messages/m1')));
    // L'administrateur du groupe peut effacer un message.
    await assertSucceeds(deleteDoc(doc(marie(), 'groupes/g1/messages/m1')));
  });

  it('calendrier : répétitions, présences, modération et remplacement', async () => {
    await semer({ 'groupes/g1': grp({ type: 'moderation', membres: ['marie', 'paul', 'luc'] }) });
    const rencontre = {
      type: 'moderation', titre: 'Culte du dimanche', debut: t(12), modeAppel: 'aucun',
      moderateur: 'paul', remplacement: 'aucun',
    };
    await assertSucceeds(setDoc(doc(marie(), 'groupes/g1/rencontres/r1'), rencontre));
    await assertFails(setDoc(doc(paul(), 'groupes/g1/rencontres/r2'), rencontre));
    await assertSucceeds(setDoc(doc(paul(), 'groupes/g1/rencontres/r1/presences/paul'), { reponse: 'non', nom: 'Paul' }));
    await assertFails(setDoc(doc(paul(), 'groupes/g1/rencontres/r1/presences/luc'), { reponse: 'oui', nom: 'Luc' }));
    await assertFails(setDoc(doc(paul(), 'groupes/g1/rencontres/r1/presences/paul'), { reponse: 'jamais', nom: 'Paul' }));

    const luc = env.authenticatedContext('luc').firestore();
    // Luc ne peut pas prendre la place tant que Paul n'a pas demandé de remplacement.
    await assertFails(updateDoc(doc(luc, 'groupes/g1/rencontres/r1'), { moderateur: 'luc', remplacement: 'aucun' }));
    await assertSucceeds(updateDoc(doc(paul(), 'groupes/g1/rencontres/r1'), { remplacement: 'demande' }));
    await assertFails(updateDoc(doc(luc, 'groupes/g1/rencontres/r1'), { moderateur: 'luc', remplacement: 'aucun', titre: 'Autre' }));
    await assertSucceeds(updateDoc(doc(luc, 'groupes/g1/rencontres/r1'), { moderateur: 'luc', remplacement: 'aucun' }));
  });

  it('appel de groupe : lancé par un administrateur, vu par les membres', async () => {
    await semer({ 'groupes/g1': grp() });
    await assertSucceeds(setDoc(doc(marie(), 'groupes/g1/appels/actuel'), { mode: 'app', enCours: true }));
    await assertFails(setDoc(doc(paul(), 'groupes/g1/appels/actuel'), { mode: 'app', enCours: false }));
    await assertSucceeds(getDoc(doc(paul(), 'groupes/g1/appels/actuel')));
  });
});

describe('sujets de prière', () => {
  const priere = (extra = {}) => ({
    uid: 'marie', nom: 'Marie', anonyme: false, texte: 'Pour ma famille',
    partage: 'pasteurs', groupeId: null, statut: 'ouverte', createdAt: serverTimestamp(), ...extra,
  });

  beforeEach(async () => {
    await semer({
      ...MEMBRES, 'users/luc': { nom: 'Luc' },
      'groupes/inter': { nom: 'Intercession', type: 'intercession', prive: true, membres: ['paul'], admins: ['paul'] },
      'groupes/jeunes': { nom: 'Jeunes', type: 'jeunes', prive: false, membres: ['paul'], admins: ['paul'] },
    });
  });

  it('confidentiel : l\'auteur et les pasteurs seulement', async () => {
    await assertSucceeds(setDoc(doc(marie(), 'prieres/p1'), priere()));
    await assertSucceeds(getDoc(doc(admin(), 'prieres/p1')));
    await assertFails(getDoc(doc(paul(), 'prieres/p1')));
    await assertFails(getDoc(doc(secretariat(), 'prieres/p1')));
  });

  it('partagé : aussi l\'équipe d\'intercession choisie', async () => {
    await assertSucceeds(setDoc(doc(marie(), 'prieres/p2'), priere({ partage: 'intercession', groupeId: 'inter' })));
    await assertFails(setDoc(doc(marie(), 'prieres/p3'), priere({ partage: 'intercession', groupeId: 'jeunes' })));
    await assertFails(setDoc(doc(marie(), 'prieres/p4'), priere({ uid: 'paul' })));
    await assertSucceeds(getDoc(doc(paul(), 'prieres/p2')));
    const luc = env.authenticatedContext('luc').firestore();
    await assertFails(getDoc(doc(luc, 'prieres/p2')));
    // « J'ai prié » : une marque par personne qui peut lire la prière.
    await assertSucceeds(setDoc(doc(paul(), 'prieres/p2/priants/paul'), { le: serverTimestamp() }));
    await assertFails(setDoc(doc(paul(), 'prieres/p2/priants/marie'), { le: serverTimestamp() }));
    await assertFails(setDoc(doc(luc, 'prieres/p2/priants/luc'), { le: serverTimestamp() }));
  });

  it('l\'auteur annonce l\'exaucement avec un témoignage', async () => {
    await semer({ 'prieres/p1': priere({ createdAt: t(1) }) });
    await assertSucceeds(updateDoc(doc(marie(), 'prieres/p1'), { statut: 'exaucee', temoignage: 'Merci Seigneur !' }));
    await assertFails(updateDoc(doc(marie(), 'prieres/p1'), { partage: 'intercession' }));
    await assertFails(updateDoc(doc(paul(), 'prieres/p1'), { statut: 'ouverte' }));
  });
});

describe('préparations au mariage et au baptême', () => {
  beforeEach(async () => {
    await semer({
      'preparations/bap': { type: 'bapteme', titre: { fr: 'Préparation au baptême' }, publie: false },
      'preparations/bap/lecons/l1': { titre: { fr: 'La repentance' }, ordre: 1, publique: false },
      'preparations/bap/lecons/l2': { titre: { fr: 'Pourquoi le baptême ?' }, ordre: 2, publique: true },
      'preparations/bap/inscrits/marie': { nom: 'Marie', faites: [] },
    });
  });

  it('le pasteur crée parcours et leçons (audio, vidéo, document)', async () => {
    await assertSucceeds(setDoc(doc(admin(), 'preparations/mar'), { type: 'mariage', titre: { fr: 'Mariage' }, publie: true }));
    await assertSucceeds(setDoc(doc(admin(), 'preparations/bap/lecons/l3'), {
      titre: { fr: 'La sanctification' }, ordre: 3, publique: false,
      audioUrl: 'https://x/a.m4a', videoUrl: 'https://x/v.mp4', documentUrl: 'https://x/d.pdf',
    }));
    await assertFails(setDoc(doc(secretariat(), 'preparations/bap/lecons/l4'), { titre: { fr: 'X' }, ordre: 4, publique: false }));
    await assertFails(setDoc(doc(marie(), 'preparations/bap/lecons/l4'), { titre: { fr: 'X' }, ordre: 4, publique: false }));
  });

  it('les leçons sont réservées aux inscrits, sauf les publiques', async () => {
    await assertSucceeds(getDoc(doc(marie(), 'preparations/bap/lecons/l1')));
    await assertFails(getDoc(doc(paul(), 'preparations/bap/lecons/l1')));
    await assertSucceeds(getDoc(doc(paul(), 'preparations/bap/lecons/l2')));
    await assertSucceeds(getDoc(doc(visiteur(), 'preparations/bap/lecons/l2')));
  });

  it('le candidat coche ses leçons et pose des questions', async () => {
    await assertSucceeds(updateDoc(doc(marie(), 'preparations/bap/inscrits/marie'), { faites: ['l1'] }));
    await assertFails(updateDoc(doc(marie(), 'preparations/bap/inscrits/marie'), { rencontres: [] }));
    await assertFails(setDoc(doc(paul(), 'preparations/bap/inscrits/paul'), { nom: 'Paul', faites: [] }));
    await assertFails(getDoc(doc(paul(), 'preparations/bap/inscrits/marie')));
    const q = { texte: 'Faut-il être membre ?', leconId: 'l1', createdAt: serverTimestamp() };
    await assertSucceeds(setDoc(doc(marie(), 'preparations/bap/inscrits/marie/questions/q1'), q));
    await assertFails(setDoc(doc(paul(), 'preparations/bap/inscrits/marie/questions/q2'), q));
    await assertSucceeds(updateDoc(doc(admin(), 'preparations/bap/inscrits/marie/questions/q1'), { reponse: 'Oui', reponduLe: serverTimestamp() }));
  });
});

describe('planning des services', () => {
  const aff = (extra = {}) => ({
    uid: 'marie', nom: 'Marie', date: t(12), titre: 'Culte du dimanche', role: 'Table de mixage',
    statut: 'prevu', ...extra,
  });

  beforeEach(async () => {
    await semer({ ...MEMBRES, 'users/luc': { nom: 'Luc' } });
  });

  it('équipes : le secrétariat les crée ; les responsables gèrent les membres', async () => {
    const sono = { nom: 'Sono', membres: ['marie', 'paul'], responsables: ['paul'] };
    await assertSucceeds(setDoc(doc(secretariat(), 'equipes/sono'), sono));
    await assertFails(setDoc(doc(secretariat(), 'equipes/x'), { ...sono, responsables: ['luc'] }));
    await assertFails(setDoc(doc(marie(), 'equipes/x'), sono));
    await assertSucceeds(getDoc(doc(marie(), 'equipes/sono')));
    await assertSucceeds(updateDoc(doc(paul(), 'equipes/sono'), { membres: ['marie', 'paul', 'luc'] }));
    await assertFails(updateDoc(doc(paul(), 'equipes/sono'), { responsables: ['paul', 'marie'] }));
    await assertFails(updateDoc(doc(marie(), 'equipes/sono'), { membres: ['marie'] }));
  });

  it('affectations : créées par un responsable, pour un membre de l\'équipe', async () => {
    await semer({ 'equipes/sono': { nom: 'Sono', membres: ['marie', 'paul'], responsables: ['paul'] } });
    await assertSucceeds(setDoc(doc(paul(), 'equipes/sono/affectations/a1'), aff()));
    await assertFails(setDoc(doc(paul(), 'equipes/sono/affectations/a2'), aff({ uid: 'luc', nom: 'Luc' })));
    await assertFails(setDoc(doc(paul(), 'equipes/sono/affectations/a3'), aff({ titre: '' })));
    await assertFails(setDoc(doc(marie(), 'equipes/sono/affectations/a4'), aff()));
    const luc = env.authenticatedContext('luc').firestore();
    await assertFails(getDoc(doc(luc, 'equipes/sono/affectations/a1')));
  });

  it('la personne confirme ou demande un remplacement ; un autre reprend', async () => {
    await semer({
      'equipes/sono': { nom: 'Sono', membres: ['marie', 'paul', 'luc'], responsables: ['luc'] },
      'equipes/sono/affectations/a1': aff(),
    });
    await assertSucceeds(updateDoc(doc(marie(), 'equipes/sono/affectations/a1'), { statut: 'confirme' }));
    await assertFails(updateDoc(doc(marie(), 'equipes/sono/affectations/a1'), { role: 'Autre' }));
    await assertFails(updateDoc(doc(paul(), 'equipes/sono/affectations/a1'), { uid: 'paul', nom: 'Paul', statut: 'confirme' }));
    await assertSucceeds(updateDoc(doc(marie(), 'equipes/sono/affectations/a1'), { statut: 'remplacement' }));
    await assertFails(updateDoc(doc(paul(), 'equipes/sono/affectations/a1'), { uid: 'paul', nom: 'Paul', statut: 'prevu' }));
    await assertSucceeds(updateDoc(doc(paul(), 'equipes/sono/affectations/a1'), {
      uid: 'paul', nom: 'Paul', statut: 'confirme', remplace: 'Marie',
    }));
  });

  it('mon planning : mes affectations dans toutes les équipes', async () => {
    await semer({
      'equipes/sono': { nom: 'Sono', membres: ['marie', 'paul'], responsables: ['paul'] },
      'equipes/sono/affectations/a1': aff(),
      'equipes/sono/affectations/a2': aff({ uid: 'paul', nom: 'Paul' }),
    });
    await assertSucceeds(getDocs(query(collectionGroup(marie(), 'affectations'), where('uid', '==', 'marie'))));
    await assertFails(getDocs(query(collectionGroup(marie(), 'affectations'), where('uid', '==', 'paul'))));
  });
});

describe('salles et réservations', () => {
  const resa = (extra = {}) => ({
    uid: 'marie', nom: 'Marie', salleId: 's1', debut: t(10), fin: t(11), motif: 'Répétition chorale',
    statut: 'demandee', createdAt: serverTimestamp(), ...extra,
  });

  it('demande par un membre, validation par le secrétariat', async () => {
    await semer({ ...MEMBRES, 'salles/s1': { nom: 'Grande salle' } });
    await assertSucceeds(getDoc(doc(marie(), 'salles/s1')));
    await assertFails(setDoc(doc(marie(), 'salles/s2'), { nom: 'Ma salle' }));
    await assertSucceeds(setDoc(doc(marie(), 'reservations/r1'), resa()));
    await assertFails(setDoc(doc(marie(), 'reservations/r2'), resa({ statut: 'validee' })));
    await assertFails(setDoc(doc(marie(), 'reservations/r3'), resa({ fin: t(9) })));
    await assertFails(getDoc(doc(paul(), 'reservations/r1')));
    await assertFails(updateDoc(doc(marie(), 'reservations/r1'), { statut: 'validee' }));
    await assertSucceeds(updateDoc(doc(secretariat(), 'reservations/r1'), { statut: 'validee' }));
    // Validée : visible par les membres (créneau occupé).
    await assertSucceeds(getDoc(doc(paul(), 'reservations/r1')));
    await assertSucceeds(updateDoc(doc(marie(), 'reservations/r1'), { statut: 'annulee' }));
  });
});

describe('dîmes et offrandes', () => {
  // 000000012345 → 123 % 97 = 26 ; 100000000034 : 1000000000 % 97 = 9.
  const COMM = '100000000034';
  const don = (extra = {}) => ({
    uid: 'marie', nom: 'Marie', montant: 50, devise: 'EUR', affectation: 'dime',
    mode: 'virement', statut: 'en_attente', createdAt: serverTimestamp(), ...extra,
  });

  it('un membre annonce un virement avec une communication valide', async () => {
    await semer(MEMBRES);
    await assertSucceeds(setDoc(doc(marie(), `dons/${COMM}`), don()));
    await assertFails(setDoc(doc(marie(), 'dons/100000000035'), don()));
    await assertFails(setDoc(doc(marie(), 'dons/200000000068'), don({ statut: 'recu' })));
    await assertFails(setDoc(doc(marie(), 'dons/200000000068'), don({ mode: 'carte' })));
    await assertFails(setDoc(doc(marie(), 'dons/200000000068'), don({ montant: -5 })));
    await assertFails(setDoc(doc(marie(), 'dons/200000000068'), don({ uid: 'paul' })));
  });

  it('le trésorier confirme ; le donateur voit les siens et peut renoncer', async () => {
    await semer({ [`dons/${COMM}`]: don({ createdAt: t(1) }), 'dons/200000000068': don({ createdAt: t(1) }) });
    await assertFails(getDoc(doc(paul(), `dons/${COMM}`)));
    await assertFails(getDoc(doc(secretariat(), `dons/${COMM}`)));
    await assertSucceeds(getDoc(doc(tresorier(), `dons/${COMM}`)));
    await assertFails(updateDoc(doc(marie(), `dons/${COMM}`), { statut: 'recu' }));
    await assertSucceeds(updateDoc(doc(tresorier(), `dons/${COMM}`), { statut: 'recu', confirmeLe: serverTimestamp() }));
    await assertFails(updateDoc(doc(marie(), `dons/${COMM}`), { statut: 'annule' }));
    await assertSucceeds(updateDoc(doc(marie(), 'dons/200000000068'), { statut: 'annule' }));
    await assertFails(deleteDoc(doc(tresorier(), 'dons/200000000068')));
  });
});

describe('équipe média', () => {
  it('groupe de type « media » avec sa discussion privée', async () => {
    await assertSucceeds(setDoc(doc(secretariat(), 'groupes/media'), {
      nom: 'Équipe média', type: 'media', prive: true, membres: ['marie', 'paul'], admins: ['marie'],
    }));
    await assertSucceeds(setDoc(doc(paul(), 'groupes/media/messages/m1'), {
      auteur: 'paul', nom: 'Paul', texte: 'Caméra 2 à recharger avant dimanche', createdAt: serverTimestamp(),
    }));
    const luc = env.authenticatedContext('luc').firestore();
    await assertFails(getDoc(doc(luc, 'groupes/media/messages/m1')));
  });
});

describe('requêtes de l\'app (annonces et agenda)', () => {
  it('visiteur : public seulement ; membre : public et membres', async () => {
    await semer(MEMBRES);
    const q = (db, col, vis) => getDocs(query(collection(db, col),
      where('publie', '==', true), where('visibilite', 'in', vis)));
    await assertSucceeds(q(visiteur(), 'actualites', ['public']));
    await assertFails(q(visiteur(), 'actualites', ['public', 'membres']));
    await assertSucceeds(q(marie(), 'actualites', ['public', 'membres']));
    await assertSucceeds(q(visiteur(), 'evenements', ['public']));
    await assertSucceeds(q(marie(), 'evenements', ['public', 'membres']));
    await assertFails(q(sansProfil(), 'evenements', ['public', 'membres']));
    // Secrétariat : tout, brouillons compris.
    await assertSucceeds(getDocs(collection(secretariat(), 'actualites')));
  });
});

describe('annuaire et listes de groupes', () => {
  it('annuaire lisible par les membres de l\'église, écrit par le serveur seulement', async () => {
    await semer({ ...MEMBRES, 'annuaire/paul': { nom: 'Paul' } });
    await assertSucceeds(getDocs(collection(marie(), 'annuaire')));
    await assertFails(getDocs(collection(sansProfil(), 'annuaire')));
    await assertFails(getDocs(collection(visiteur(), 'annuaire')));
    await assertFails(setDoc(doc(marie(), 'annuaire/marie'), { nom: 'Reine Marie' }));
  });

  it('requêtes : mes groupes, groupes ouverts, tous (secrétariat)', async () => {
    await semer({
      ...MEMBRES,
      'groupes/g1': { nom: 'A', type: 'cellule', prive: true, membres: ['marie'], admins: ['marie'] },
      'groupes/g2': { nom: 'B', type: 'jeunes', prive: false, membres: ['paul'], admins: ['paul'] },
    });
    await assertSucceeds(getDocs(query(collection(marie(), 'groupes'), where('membres', 'array-contains', 'marie'))));
    await assertFails(getDocs(query(collection(marie(), 'groupes'), where('membres', 'array-contains', 'paul'))));
    await assertSucceeds(getDocs(query(collection(marie(), 'groupes'), where('prive', '==', false))));
    await assertFails(getDocs(collection(marie(), 'groupes')));
    await assertSucceeds(getDocs(collection(secretariat(), 'groupes')));
  });
});

describe('divers : fêtes et ce que chacun apporte', () => {
  const fete = (extra = {}) => ({
    titre: 'Anniversaire de Maman Esther', type: 'anniversaire', date: t(10), lieu: 'Tienen',
    description: '', uid: 'marie', nom: 'Marie', createdAt: serverTimestamp(), ...extra,
  });

  beforeEach(async () => {
    await semer({
      ...MEMBRES, 'users/luc': { nom: 'Luc' },
      'parametres/eglise': { groupeCuisineId: 'cuisine' },
      'groupes/cuisine': { nom: 'Cuisine', type: 'cuisine', prive: true, membres: ['luc'], admins: ['luc'] },
    });
  });

  it('un membre annonce une fête ; les membres la voient', async () => {
    await assertSucceeds(setDoc(doc(marie(), 'fetes/f1'), fete()));
    await assertFails(setDoc(doc(marie(), 'fetes/f2'), fete({ uid: 'paul' })));
    await assertFails(setDoc(doc(marie(), 'fetes/f3'), fete({ type: 'concert' })));
    await assertFails(setDoc(doc(sansProfil(), 'fetes/f4'), fete({ uid: 'jean' })));
    await assertSucceeds(getDoc(doc(paul(), 'fetes/f1')));
    await assertFails(getDoc(doc(visiteur(), 'fetes/f1')));
    await assertFails(updateDoc(doc(paul(), 'fetes/f1'), { titre: 'Autre' }));
    await assertSucceeds(updateDoc(doc(marie(), 'fetes/f1'), { lieu: 'Hoegaarden' }));
    await assertSucceeds(updateDoc(doc(secretariat(), 'fetes/f1'), { titre: 'Anniversaire d\'Esther' }));
  });

  it('ce que chacun apporte : soi, la cuisine et le secrétariat', async () => {
    await semer({ 'fetes/f1': fete({ createdAt: t(1) }) });
    const luc = env.authenticatedContext('luc').firestore();
    const apport = { nom: 'Paul', apporte: ['gateau', 'boisson'], precision: 'Gâteau au chocolat' };
    await assertSucceeds(setDoc(doc(paul(), 'fetes/f1/apports/paul'), apport));
    await assertFails(setDoc(doc(paul(), 'fetes/f1/apports/marie'), apport));
    await assertFails(setDoc(doc(paul(), 'fetes/f1/apports/paul'), { ...apport, apporte: ['argent'] }));
    await assertFails(setDoc(doc(paul(), 'fetes/f1/apports/paul'), { ...apport, apporte: [] }));
    await assertSucceeds(getDoc(doc(paul(), 'fetes/f1/apports/paul')));
    await assertSucceeds(getDocs(collection(luc, 'fetes/f1/apports')));
    await assertSucceeds(getDocs(collection(secretariat(), 'fetes/f1/apports')));
    await assertFails(getDoc(doc(marie(), 'fetes/f1/apports/paul')));
  });
});
