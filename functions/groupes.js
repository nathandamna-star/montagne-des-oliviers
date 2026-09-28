// Logique pure des groupes (testée sans émulateur).

const PHOTO = { fr: '📷 Photo', nl: '📷 Foto' };

/** Aperçu du dernier message (affiché dans la liste des groupes). */
export function apercu(message) {
  const texte = (message.texte ?? '').trim();
  return texte.length > 140 ? `${texte.slice(0, 139)}…` : texte;
}

/** Destinataires : les membres du groupe, sauf l'auteur. */
export const destinataires = (membres, auteur) =>
  [...new Set(membres ?? [])].filter((u) => u !== auteur);

/** Notification d'un message de groupe, dans la langue du destinataire. */
export function notificationMessage(groupe, groupeId, message, langue) {
  const l = langue === 'nl' ? 'nl' : 'fr';
  const texte = apercu(message) || PHOTO[l];
  return {
    notification: { title: groupe.nom ?? '', body: `${message.nom} : ${texte}` },
    data: { type: 'groupe', id: groupeId },
  };
}
