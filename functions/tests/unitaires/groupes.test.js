import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { apercu, destinataires, notificationMessage } from '../../groupes.js';

describe('groupes', () => {
  it('destinataires : membres sauf l\'auteur, sans doublon', () => {
    assert.deepEqual(destinataires(['a', 'b', 'c', 'b'], 'b'), ['a', 'c']);
    assert.deepEqual(destinataires(undefined, 'a'), []);
  });

  it('aperçu court', () => {
    assert.equal(apercu({ texte: '  Bonjour  ' }), 'Bonjour');
    assert.equal(apercu({ texte: 'x'.repeat(200) }).length, 140);
    assert.equal(apercu({}), '');
  });

  it('notification : nom du groupe, auteur, photo traduite', () => {
    const g = { nom: 'Intercession' };
    assert.deepEqual(notificationMessage(g, 'g1', { nom: 'Marie', texte: 'Prions' }, 'fr'), {
      notification: { title: 'Intercession', body: 'Marie : Prions' },
      data: { type: 'groupe', id: 'g1' },
    });
    assert.equal(
      notificationMessage(g, 'g1', { nom: 'Paul', texte: '', fichierUrl: 'https://x' }, 'nl').notification.body,
      'Paul : 📷 Foto',
    );
  });
});

import {
  destinatairesRappel, notificationRappel, notificationRemplacement, notificationRencontre,
  rappelsDus, remplacementVientDEtreDemande,
} from '../../groupes.js';

describe('calendrier des groupes', () => {
  const r = { type: 'repetition', titre: 'Répétition', lieu: 'Salle 2' };

  it('nouveau rendez-vous et rappel, dans la langue', () => {
    const n = notificationRencontre({ nom: 'Louange' }, 'g1', 'r1', r, 'nl', 'donderdag 8 oktober om 19:00');
    assert.equal(n.notification.title, 'Louange · Repetitie');
    assert.equal(n.notification.body, 'Répétition · donderdag 8 oktober om 19:00');
    assert.deepEqual(n.data, { type: 'rencontre', id: 'g1', rid: 'r1' });
    const rap = notificationRappel({ nom: 'Louange' }, 'g1', 'r1', r, 'fr', '19:00');
    assert.equal(rap.notification.title, 'Demain : Répétition');
    assert.equal(rap.notification.body, 'Louange · 19:00 · Salle 2');
  });

  it('remplacement : seulement au moment de la demande', () => {
    assert.equal(remplacementVientDEtreDemande({ remplacement: 'aucun' }, { remplacement: 'demande' }), true);
    assert.equal(remplacementVientDEtreDemande({ remplacement: 'demande' }, { remplacement: 'demande' }), false);
    assert.equal(remplacementVientDEtreDemande({ remplacement: 'demande' }, { remplacement: 'aucun' }), false);
    const n = notificationRemplacement('g1', 'r1', { titre: 'Culte du dimanche' }, 'Paul', 'fr', 'dimanche 11 octobre à 10:00');
    assert.equal(n.notification.body, 'Paul n\'est pas disponible pour « Culte du dimanche » (dimanche 11 octobre à 10:00).');
  });

  it('rappels dus : dans les 24 h, une seule fois', () => {
    const maintenant = new Date(Date.UTC(2026, 9, 5, 8));
    const h = (n) => new Date(maintenant.getTime() + n * 3600 * 1000);
    const dus = rappelsDus([
      { id: 'a', debut: h(23) },
      { id: 'b', debut: h(25) },
      { id: 'c', debut: h(10), rappelEnvoye: true },
      { id: 'd', debut: h(-1) },
    ], maintenant);
    assert.deepEqual(dus.map((x) => x.id), ['a']);
  });

  it('rappel de modération : au modérateur seulement', () => {
    const g = { membres: ['a', 'b', 'c'] };
    assert.deepEqual(destinatairesRappel(g, { type: 'moderation', moderateur: 'b' }), ['b']);
    assert.deepEqual(destinatairesRappel(g, { type: 'moderation' }), []);
    assert.deepEqual(destinatairesRappel(g, { type: 'reunion' }), ['a', 'b', 'c']);
  });
});
