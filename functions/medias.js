// Page web publique d'un média (lien partagé sur WhatsApp) et notifications.

export const SITE = 'https://montagne-des-oliviers.web.app';

const echapper = (s) => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

const texte = (m, l = 'fr') => m?.[l] || m?.fr || '';

const lienExterne = (url) => /(^|\.)(youtube\.com|youtu\.be|facebook\.com|fb\.watch)$/
  .test((() => { try { return new URL(url).hostname; } catch { return ''; } })());

/** Visible sur le web ? Seulement publié et public. */
export const pagePublique = (m) => m?.publie === true && m?.visibilite === 'public';

/** HTML de la page d'un média, avec aperçu (Open Graph) pour WhatsApp. */
export function pageMediaHtml(id, m, date) {
  const titre = texte(m.titre);
  const description = texte(m.description);
  const resume = description.length > 200 ? `${description.slice(0, 199)}…` : description;
  const quand = new Intl.DateTimeFormat('fr-BE', {
    weekday: 'long', day: 'numeric', month: 'long', year: 'numeric', timeZone: 'Europe/Brussels',
  }).format(date);
  let lecteur = '';
  if (m.url && lienExterne(m.url)) {
    lecteur = `<p><a class="bouton" href="${echapper(m.url)}">▶ Regarder</a></p>`;
  } else if (m.url && m.type === 'video') {
    lecteur = `<video controls playsinline preload="metadata" src="${echapper(m.url)}"></video>`;
  } else if (m.url) {
    lecteur = `<audio controls preload="metadata" src="${echapper(m.url)}"></audio>`;
  }
  const url = `${SITE}/m/${encodeURIComponent(id)}`;
  return `<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${echapper(titre)} · Montagne des Oliviers</title>
<meta name="description" content="${echapper(resume)}">
<meta property="og:type" content="${m.type === 'audio' ? 'music.song' : 'video.other'}">
<meta property="og:title" content="${echapper(titre)}">
<meta property="og:description" content="${echapper(resume || 'Centre Évangélique Montagne des Oliviers, Tienen')}">
<meta property="og:image" content="${SITE}/icons/Icon-512.png">
<meta property="og:url" content="${url}">
<style>
body{margin:0;font-family:system-ui,-apple-system,sans-serif;background:#F7F9FA;color:#2C3440}
header{background:linear-gradient(135deg,#1F4E8C,#3AA0B5);color:#fff;padding:24px 16px;text-align:center}
header img{width:72px;height:72px;border-radius:50%}
main{max-width:720px;margin:0 auto;padding:16px}
h1{font-size:1.5rem;margin:.5rem 0}
.meta{color:#5B6570}
audio,video{width:100%;margin:16px 0;border-radius:12px}
.bouton{display:inline-block;background:#1F4E8C;color:#fff;padding:12px 20px;border-radius:12px;text-decoration:none}
p.description{white-space:pre-wrap;line-height:1.5}
footer{text-align:center;padding:24px 16px}
</style>
</head>
<body>
<header><img src="${SITE}/icons/Icon-192.png" alt=""><div>Centre Évangélique Montagne des Oliviers</div></header>
<main>
<h1>${echapper(titre)}</h1>
<div class="meta">${echapper([m.predicateur, quand].filter(Boolean).join(' · '))}</div>
${lecteur}
${description ? `<p class="description">${echapper(description)}</p>` : ''}
</main>
<footer><a class="bouton" href="${SITE}">Découvrir l'application de l'église</a></footer>
</body>
</html>`;
}

export const pageIntrouvable = `<!doctype html><html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><title>Montagne des Oliviers</title></head>
<body style="font-family:system-ui;text-align:center;padding:48px 16px">
<p>Ce contenu n'est pas disponible.</p><p><a href="${SITE}">Montagne des Oliviers</a></p></body></html>`;

/** Notification d'un nouveau média (un message par langue, sujets FCM). */
export function messagesMedia(id, m) {
  const T = {
    fr: { audio: 'Nouvelle prédication', video: 'Nouvelle vidéo', direct: 'Direct' },
    nl: { audio: 'Nieuwe preek', video: 'Nieuwe video', direct: 'Livestream' },
  };
  return ['fr', 'nl'].map((l) => ({
    topic: `${m.visibilite === 'membres' ? 'membres' : 'annonces'}_${l}`,
    notification: { title: T[l][m.type] ?? T[l].audio, body: texte(m.titre, l) },
    data: { type: 'media', id },
  }));
}
