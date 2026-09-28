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
