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

const TYPES = {
  fr: { reunion: 'Réunion', repetition: 'Répétition', moderation: 'Modération', appel: 'Appel de groupe' },
  nl: { reunion: 'Samenkomst', repetition: 'Repetitie', moderation: 'Leiding van de dienst', appel: 'Groepsoproep' },
};

const TEXTES = {
  fr: {
    demain: (t) => `Demain : ${t}`,
    remplacant: 'Remplaçant recherché',
    indisponible: (nom, titre, quand) => `${nom} n'est pas disponible pour « ${titre} » (${quand}).`,
  },
  nl: {
    demain: (t) => `Morgen: ${t}`,
    remplacant: 'Vervanger gezocht',
    indisponible: (nom, titre, quand) => `${nom} is niet beschikbaar voor « ${titre} » (${quand}).`,
  },
};

const langueDe = (l) => (l === 'nl' ? 'nl' : 'fr');

/** Nouveau rendez-vous dans le calendrier d'un groupe. */
export function notificationRencontre(groupe, groupeId, rid, r, langue, quand) {
  const l = langueDe(langue);
  return {
    notification: {
      title: `${groupe.nom} · ${TYPES[l][r.type] ?? ''}`,
      body: `${r.titre} · ${quand}`,
    },
    data: { type: 'rencontre', id: groupeId, rid },
  };
}

/** Rappel la veille. */
export function notificationRappel(groupe, groupeId, rid, r, langue, heure) {
  const l = langueDe(langue);
  return {
    notification: {
      title: TEXTES[l].demain(r.titre),
      body: [groupe.nom, heure, r.lieu].filter(Boolean).join(' · '),
    },
    data: { type: 'rencontre', id: groupeId, rid },
  };
}

/** Un modérateur n'est pas disponible : on prévient les autres membres. */
export function notificationRemplacement(groupeId, rid, r, nomModerateur, langue, quand) {
  const l = langueDe(langue);
  return {
    notification: {
      title: TEXTES[l].remplacant,
      body: TEXTES[l].indisponible(nomModerateur, r.titre, quand),
    },
    data: { type: 'rencontre', id: groupeId, rid },
  };
}

/** Le remplacement vient d'être demandé ? */
export const remplacementVientDEtreDemande = (avant, apres) =>
  apres?.remplacement === 'demande' && avant?.remplacement !== 'demande';

/**
 * Rendez-vous dont le rappel est dû : dans les prochaines 24 heures et pas
 * encore rappelés. [rencontres] : [{ id, debut: Date, rappelEnvoye }].
 */
export function rappelsDus(rencontres, maintenant) {
  const limite = maintenant.getTime() + 24 * 3600 * 1000;
  return rencontres.filter((r) => r.rappelEnvoye !== true
    && r.debut.getTime() > maintenant.getTime() && r.debut.getTime() <= limite);
}

/** Qui reçoit le rappel : le modérateur pour une modération, sinon tout le groupe. */
export function destinatairesRappel(groupe, r) {
  if (r.type === 'moderation') return r.moderateur ? [r.moderateur] : [];
  return [...new Set(groupe.membres ?? [])];
}
