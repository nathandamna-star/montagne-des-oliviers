import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  ANONYME, commandeAnonymisee, donAnonymise, profilExporte, refusSuppression, sansLaPersonne, versJson,
} from '../../compte.js';

describe('export', () => {
  it('dates en ISO, sans jetons de notification', () => {
    const date = { toDate: () => new Date('2026-10-05T09:00:00Z') };
    assert.deepEqual(versJson({ a: [date], b: { c: null } }), { a: ['2026-10-05T09:00:00.000Z'], b: { c: null } });
    assert.deepEqual(profilExporte({ nom: 'Marie', jetonsNotif: ['x'] }), { nom: 'Marie' });
    assert.equal(profilExporte(undefined), null);
  });
});

describe('suppression', () => {
  it('refusée pour le dernier administrateur ou un livre à retirer', () => {
    assert.equal(refusSuppression({ estAdmin: true, autresAdmins: 0, commandes: [] }), 'dernier-admin');
    assert.equal(refusSuppression({ estAdmin: true, autresAdmins: 1, commandes: [] }), null);
    assert.equal(refusSuppression({ estAdmin: false, autresAdmins: 0, commandes: [{ statut: 'payee' }] }), 'commande-a-retirer');
    assert.equal(refusSuppression({ estAdmin: false, autresAdmins: 0, commandes: [{ statut: 'remise' }] }), null);
  });

  it('dons et commandes anonymisés, attentes annulées', () => {
    assert.deepEqual(donAnonymise({ statut: 'recu' }), { uid: ANONYME, nom: '' });
    assert.deepEqual(donAnonymise({ statut: 'en_attente' }), { uid: ANONYME, nom: '', statut: 'annule' });
    assert.deepEqual(commandeAnonymisee({ statut: 'en_attente' }), { uid: ANONYME, nom: '', statut: 'annulee' });
  });

  it('retiré des groupes et des équipes', () => {
    assert.deepEqual(sansLaPersonne({ membres: ['a', 'b'], admins: ['a'] }, 'a', ['membres', 'admins']),
      { membres: ['b'], admins: [] });
    assert.equal(sansLaPersonne({ membres: ['b'] }, 'a', ['membres', 'admins']), null);
  });
});
