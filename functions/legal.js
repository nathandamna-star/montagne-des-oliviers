// Pages légales publiques (adresses exigées par l'App Store et Google Play),
// en français et en néerlandais. Textes : functions/legal/*.md.

export const PAGES_LEGALES = ['confidentialite', 'conditions', 'aide'];

const TITRES = {
  fr: { confidentialite: 'Politique de confidentialité', conditions: 'Conditions d\'utilisation', aide: 'Aide et contact' },
  nl: { confidentialite: 'Privacybeleid', conditions: 'Gebruiksvoorwaarden', aide: 'Hulp en contact' },
};

const SANS_EMAIL = {
  fr: 'par courrier à l\'adresse ci-dessus, ou dans l\'application (Profil → Mes demandes)',
  nl: 'per post naar het adres hierboven, of in de app (Profiel → Mijn aanvragen)',
};

const echapper = (t) => t.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

/** Convertit le format simple des pages (# ## - >) en HTML ; {{email}} : adresse de contact. */
export function pageLegaleHtml(texte, { nom, langue, email }) {
  const l = langue === 'nl' ? 'nl' : 'fr';
  const contact = /^[^\s@<>"]+@[^\s@<>"]+\.[a-z]{2,}$/i.test(email ?? '') ? email : SANS_EMAIL[l];
  const corps = [];
  let liste = false;
  for (const brute of texte.split('\n')) {
    const ligne = echapper(brute).replaceAll('{{email}}', echapper(contact));
    const estPuce = ligne.startsWith('- ');
    if (liste && !estPuce) { corps.push('</ul>'); liste = false; }
    if (ligne.startsWith('# ')) corps.push(`<h1>${ligne.slice(2)}</h1>`);
    else if (ligne.startsWith('## ')) corps.push(`<h2>${ligne.slice(3)}</h2>`);
    else if (ligne.startsWith('&gt; ')) corps.push(`<aside>${ligne.slice(5)}</aside>`);
    else if (estPuce) {
      if (!liste) { corps.push('<ul>'); liste = true; }
      corps.push(`<li>${ligne.slice(2)}</li>`);
    } else if (ligne.trim()) corps.push(`<p>${ligne}</p>`);
  }
  if (liste) corps.push('</ul>');
  const autre = l === 'fr' ? 'nl' : 'fr';
  const liens = PAGES_LEGALES.map((p) =>
    `<a href="/legal/${p}${l === 'nl' ? '?langue=nl' : ''}">${TITRES[l][p]}</a>`).join(' · ');
  return `<!doctype html>
<html lang="${l}"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${TITRES[l][nom]} · Montagne des Oliviers</title>
<style>
:root{--fond:#F7F4EC;--texte:#1F2A1F;--second:#5A6453;--accent:#3D5A2A;--carte:#FFFFFF}
@media (prefers-color-scheme:dark){:root{--fond:#141A12;--texte:#EEF1E8;--second:#B7C0AE;--accent:#A9C98E;--carte:#1D251A}}
body{background:var(--fond);color:var(--texte);font:16px/1.6 -apple-system,system-ui,sans-serif;margin:0;padding:24px 16px}
main{max-width:720px;margin:0 auto}
h1{color:var(--accent);font-size:1.6rem;line-height:1.25}
h2{font-size:1.15rem;margin-top:1.8em}
a{color:var(--accent)}
nav{font-size:.9rem;margin-bottom:24px}
aside{background:var(--carte);border-left:4px solid var(--accent);padding:12px 16px;border-radius:8px;color:var(--second)}
</style></head>
<body><main>
<nav>${liens} · <a href="/legal/${nom}${autre === 'nl' ? '?langue=nl' : ''}" lang="${autre}">${autre === 'nl' ? 'Nederlands' : 'Français'}</a></nav>
${corps.join('\n')}
</main></body></html>`;
}
