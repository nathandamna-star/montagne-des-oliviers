import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  chevauche, conflitsReservation, decisionPrise, notificationDecisionReservation,
  notificationDemandeReservation,
} from '../../salles.js';

const h = (n) => new Date(Date.UTC(2026, 9, 10, n));

describe('réservation des salles', () => {
  it('chevauchements', () => {
    assert.equal(chevauche({ debut: h(10), fin: h(12) }, { debut: h(11), fin: h(13) }), true);
    assert.equal(chevauche({ debut: h(10), fin: h(12) }, { debut: h(12), fin: h(14) }), false);
    const r = { id: 'r', salleId: 's1', debut: h(10), fin: h(12) };
    const c = conflitsReservation(r, [
      { id: 'a', salleId: 's1', debut: h(11), fin: h(13) },
      { id: 'b', salleId: 's2', debut: h(11), fin: h(13) },
      { id: 'r', salleId: 's1', debut: h(10), fin: h(12) },
    ]);
    assert.deepEqual(c.map((x) => x.id), ['a']);
  });

  it('notifications', () => {
    const r = { nom: 'Marie', salleNom: 'Grande salle', motif: 'Chorale', statut: 'validee', reponse: 'Clé chez Paul' };
    assert.equal(notificationDemandeReservation('x', r, 'fr', 'samedi').notification.title, 'Réservation demandée par Marie');
    assert.deepEqual(notificationDemandeReservation('x', r, 'fr', 'samedi').data, { type: 'reservation', id: 'x', vue: 'gestion' });
    assert.equal(notificationDecisionReservation('x', r, 'fr', 'samedi').notification.body, 'Grande salle · samedi — Clé chez Paul');
    assert.equal(decisionPrise({ statut: 'demandee' }, { statut: 'validee' }), true);
    assert.equal(decisionPrise({ statut: 'validee' }, { statut: 'annulee' }), false);
  });
});
