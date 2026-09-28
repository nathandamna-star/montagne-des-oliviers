import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { normaliser, nouveauxClaims, rolesDe } from '../../roles.js';

describe('rôles', () => {
  it('remplace les rôles et garde les autres claims', () => {
    assert.deepEqual(
      nouveauxClaims({ admin: true, autre: 1 }, ['tresorier']),
      { autre: 1, tresorier: true },
    );
    assert.deepEqual(nouveauxClaims(undefined, []), {});
    assert.deepEqual(nouveauxClaims({}, ['admin', 'admin']), { admin: true });
  });

  it('refuse un rôle inconnu ou une liste absente', () => {
    assert.equal(nouveauxClaims({}, ['coach']), null);
    assert.equal(nouveauxClaims({}, 'admin'), null);
    assert.equal(nouveauxClaims({}, undefined), null);
  });

  it('lit les rôles dans l\'ordre', () => {
    assert.deepEqual(rolesDe({ tresorier: true, admin: true, x: true }), ['admin', 'tresorier']);
    assert.deepEqual(rolesDe(undefined), []);
  });

  it('normalise les e-mails', () => {
    assert.equal(normaliser('  Pasteur@Exemple.BE '), 'pasteur@exemple.be');
    assert.equal(normaliser(undefined), '');
  });
});
