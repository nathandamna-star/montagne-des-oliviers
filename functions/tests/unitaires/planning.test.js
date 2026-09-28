import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  changementService, notificationAffectation, notificationChangement, notificationRappelService,
  rappelsServicesDus,
} from '../../planning.js';

describe('planning des services', () => {
  const a = { uid: 'm', nom: 'Marie', titre: 'Culte du dimanche', role: 'Table de mixage', statut: 'prevu' };

  it('mise au planning et rappel', () => {
    const n = notificationAffectation('sono', { nom: 'Sono' }, a, 'fr', 'dimanche 11 octobre à 10:00');
    assert.equal(n.notification.title, 'Vous servez : Sono');
    assert.equal(n.notification.body, 'Culte du dimanche · dimanche 11 octobre à 10:00 · Table de mixage');
    assert.deepEqual(n.data, { type: 'service', id: 'sono' });
    assert.equal(notificationRappelService('sono', { nom: 'Sono' }, a, 'nl', '10:00').notification.title, 'Morgen dien je: Sono');
  });

  it('changements : à qui prévenir', () => {
    assert.deepEqual(changementService(a, { ...a, statut: 'indisponible' }), { cible: 'responsables', genre: 'indisponible' });
    assert.deepEqual(changementService(a, { ...a, statut: 'remplacement' }), { cible: 'equipe', genre: 'remplacement' });
    assert.deepEqual(
      changementService({ ...a, statut: 'remplacement' }, { ...a, uid: 'p', nom: 'Paul', statut: 'confirme' }),
      { cible: 'responsables', genre: 'remplace' },
    );
    assert.equal(changementService(a, { ...a, statut: 'confirme' }), null);
    assert.equal(changementService(a, { ...a }), null);
    const n = notificationChangement('sono', 'remplace', a, { ...a, nom: 'Paul' }, 'fr', 'dimanche');
    assert.equal(n.notification.title, 'Paul remplace Marie');
  });

  it('rappels dus', () => {
    const maintenant = new Date(Date.UTC(2026, 9, 10, 9));
    const h = (n) => new Date(maintenant.getTime() + n * 3600 * 1000);
    const dus = rappelsServicesDus([
      { id: 'a', date: h(23), statut: 'confirme' },
      { id: 'b', date: h(23), statut: 'indisponible' },
      { id: 'c', date: h(30), statut: 'prevu' },
      { id: 'd', date: h(5), statut: 'prevu', rappelEnvoye: true },
    ], maintenant);
    assert.deepEqual(dus.map((x) => x.id), ['a']);
  });
});

import { messagesNettoyage, notificationRappelNettoyage } from '../../planning.js';

describe('entretien de la salle', () => {
  it('annonce et rappel', () => {
    const m = messagesNettoyage('n1', { titre: 'Nettoyage de la salle' }, (l) => (l === 'fr' ? 'samedi à 10:00' : 'zaterdag om 10:00'));
    assert.deepEqual(m.map((x) => x.topic), ['membres_fr', 'membres_nl']);
    assert.equal(m[0].notification.body, 'Nettoyage de la salle · samedi à 10:00');
    assert.equal(notificationRappelNettoyage('n1', { titre: 'Nettoyage' }, 'nl', '10:00').notification.title, 'Morgen: schoonmaak van de zaal');
  });
});
