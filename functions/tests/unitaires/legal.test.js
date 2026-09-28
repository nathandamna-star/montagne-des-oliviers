import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { describe, it } from 'node:test';
import { PAGES_LEGALES, pageLegaleHtml } from '../../legal.js';

describe('pages légales', () => {
  it('toutes les pages existent en français et en néerlandais', () => {
    for (const p of PAGES_LEGALES) {
      for (const l of ['fr', 'nl']) {
        const t = readFileSync(new URL(`../../legal/${p}_${l}.md`, import.meta.url), 'utf8');
        assert.match(t, /^# /);
        assert.match(t, /Hoegaarden/);
      }
    }
  });

  it('HTML échappé, e-mail de contact inséré (ou courrier à défaut)', () => {
    const h = pageLegaleHtml('# Titre\n- <b>puce</b>\nÉcrivez à {{email}}.', { nom: 'aide', langue: 'fr', email: 'info@eglise.be' });
    assert.match(h, /<h1>Titre<\/h1>/);
    assert.match(h, /<li>&lt;b&gt;puce&lt;\/b&gt;<\/li>/);
    assert.match(h, /Écrivez à info@eglise.be\./);
    assert.match(h, /href="\/legal\/aide\?langue=nl"/);
    const sans = pageLegaleHtml('Écrivez à {{email}}.', { nom: 'aide', langue: 'nl', email: '"><script>' });
    assert.match(sans, /per post/);
    assert.doesNotMatch(sans, /<script>/);
  });
});
