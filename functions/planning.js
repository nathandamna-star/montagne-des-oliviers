// Planning des services : textes des notifications (logique pure, testée sans émulateur).

const l2 = (l) => (l === 'nl' ? 'nl' : 'fr');

const T = {
  fr: {
    vousServez: (equipe) => `Vous servez : ${equipe}`,
    indisponible: (nom) => `${nom} n'est pas disponible`,
    remplacant: 'Remplaçant recherché',
    remplace: (nom, ancien) => `${nom} remplace ${ancien}`,
    demain: (equipe) => `Demain, vous servez : ${equipe}`,
  },
  nl: {
    vousServez: (equipe) => `Je dient: ${equipe}`,
    indisponible: (nom) => `${nom} is niet beschikbaar`,
    remplacant: 'Vervanger gezocht',
    remplace: (nom, ancien) => `${nom} vervangt ${ancien}`,
    demain: (equipe) => `Morgen dien je: ${equipe}`,
  },
};

const details = (a, quand) => [a.titre, quand, a.role].filter(Boolean).join(' · ');
const data = (eid) => ({ type: 'service', id: eid });

/** À la personne mise au planning. */
export function notificationAffectation(eid, equipe, a, langue, quand) {
  const l = l2(langue);
  return { notification: { title: T[l].vousServez(equipe.nom), body: details(a, quand) }, data: data(eid) };
}

/**
 * Changement de statut : que faut-il envoyer, et à qui ?
 * Renvoie { cible: 'responsables' | 'equipe', genre } ou null.
 */
export function changementService(avant, apres) {
  if (!avant || !apres) return null;
  if (avant.uid !== apres.uid && apres.statut === 'confirme') return { cible: 'responsables', genre: 'remplace' };
  if (avant.statut === apres.statut) return null;
  if (apres.statut === 'indisponible') return { cible: 'responsables', genre: 'indisponible' };
  if (apres.statut === 'remplacement') return { cible: 'equipe', genre: 'remplacement' };
  return null;
}

export function notificationChangement(eid, genre, avant, apres, langue, quand) {
  const l = l2(langue);
  const title = {
    indisponible: T[l].indisponible(apres.nom),
    remplacement: T[l].remplacant,
    remplace: T[l].remplace(apres.nom, avant.nom),
  }[genre];
  return { notification: { title, body: details(apres, quand) }, data: data(eid) };
}

/** Rappel la veille. */
export function notificationRappelService(eid, equipe, a, langue, heure) {
  const l = l2(langue);
  return { notification: { title: T[l].demain(equipe.nom), body: details(a, heure) }, data: data(eid) };
}

/** Services dont le rappel est dû : dans les 24 h, prévus ou confirmés, pas encore rappelés. */
export function rappelsServicesDus(affectations, maintenant) {
  const limite = maintenant.getTime() + 24 * 3600 * 1000;
  return affectations.filter((a) => a.rappelEnvoye !== true
    && (a.statut === 'prevu' || a.statut === 'confirme')
    && a.date.getTime() > maintenant.getTime() && a.date.getTime() <= limite);
}

const N = {
  fr: { aide: 'On cherche des bras pour le nettoyage 🧹', demain: 'Demain : nettoyage de la salle' },
  nl: { aide: 'Helpers gezocht voor de schoonmaak 🧹', demain: 'Morgen: schoonmaak van de zaal' },
};

/** Nouvelle séance de nettoyage : annonce aux membres (sujets FCM). */
export function messagesNettoyage(id, n, quand) {
  return ['fr', 'nl'].map((l) => ({
    topic: `membres_${l}`,
    notification: { title: N[l].aide, body: `${n.titre} · ${quand(l)}` },
    data: { type: 'nettoyage', id },
  }));
}

/** Rappel la veille aux inscrits. */
export function notificationRappelNettoyage(id, n, langue, heure) {
  const l = l2(langue);
  return { notification: { title: N[l].demain, body: `${n.titre} · ${heure}` }, data: { type: 'nettoyage', id } };
}
