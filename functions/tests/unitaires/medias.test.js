import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { messagesMedia, pageMediaHtml, pagePublique } from '../../medias.js';

describe('médias', () => {
  const m = {
    type: 'audio', titre: { fr: 'La foi <qui> déplace', nl: 'Het geloof' }, description: { fr: 'Exhortation du dimanche' },
    predicateur: 'Pasteur Jean', url: 'https://firebasestorage.googleapis.com/x.m4a', visibilite: 'public', publie: true,
  };

  it('page publique seulement si publié et public', () => {
    assert.equal(pagePublique(m), true);
    assert.equal(pagePublique({ ...m, visibilite: 'membres' }), false);
    assert.equal(pagePublique({ ...m, publie: false }), false);
  });

  it('HTML : aperçu WhatsApp, lecteur audio, texte échappé', () => {
    const html = pageMediaHtml('abc', m, new Date(Date.UTC(2026, 9, 11, 8)));
    assert.match(html, /<meta property="og:title" content="La foi &lt;qui&gt; déplace">/);
    assert.match(html, /<audio controls/);
    assert.match(html, /Pasteur Jean · dimanche 11 octobre 2026/);
    assert.doesNotMatch(html, /<qui>/);
  });

  it('YouTube : bouton vers la vidéo', () => {
    const html = pageMediaHtml('abc', { ...m, type: 'video', url: 'https://www.youtube.com/watch?v=1' }, new Date());
    assert.match(html, /href="https:\/\/www.youtube.com\/watch\?v=1"/);
    assert.doesNotMatch(html, /<video/);
  });

  it('notification : sujets selon la visibilité', () => {
    const n = messagesMedia('abc', { ...m, visibilite: 'membres' });
    assert.deepEqual(n.map((x) => x.topic), ['membres_fr', 'membres_nl']);
    assert.equal(n[1].notification.body, 'Het geloof');
    assert.equal(n[0].notification.title, 'Nouvelle prédication');
  });
});
