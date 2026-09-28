// Logique pure des notifications d'annonces et d'événements (testée sans émulateur).

export const LANGUES = ['fr', 'nl'];

const TEXTES = {
  fr: { annonce: 'Nouvelle annonce', evenement: 'Agenda', le: 'le', a: 'à' },
  nl: { annonce: 'Nieuwe aankondiging', evenement: 'Agenda', le: 'op', a: 'om' },
};

/** Texte dans la langue, sinon en français. */
export const traduire = (m, langue) => m?.[langue] || m?.fr || '';

/**
 * Faut-il envoyer la notification ? Une seule fois : au moment où le document
 * est publié avec « prévenir par notification », et jamais s'il l'a déjà été.
 */
export function doitNotifier(apres) {
  return !!apres && apres.publie === true && apres.notifier === true && !apres.notifieLe;
}

/** Sujet FCM : tous (public) ou seulement les membres connectés. */
export const sujet = (visibilite, langue) =>
  `${visibilite === 'membres' ? 'membres' : 'annonces'}_${langue}`;

/** « dimanche 11 octobre à 10:00 » à l'heure de Bruxelles. */
export function quand(date, langue) {
  const locale = langue === 'nl' ? 'nl-BE' : 'fr-BE';
  const jour = new Intl.DateTimeFormat(locale, {
    weekday: 'long', day: 'numeric', month: 'long', timeZone: 'Europe/Brussels',
  }).format(date);
  const heure = new Intl.DateTimeFormat(locale, {
    hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Brussels',
  }).format(date);
  return `${jour} ${TEXTES[langue].a} ${heure}`;
}

/** Messages FCM (un par langue) pour une annonce. */
export function messagesActualite(id, a) {
  return LANGUES.map((l) => ({
    topic: sujet(a.visibilite, l),
    notification: {
      title: TEXTES[l].annonce,
      body: traduire(a.titre, l),
    },
    data: { type: 'actualite', id },
  }));
}

/** Messages FCM (un par langue) pour un événement. */
export function messagesEvenement(id, e, debut) {
  return LANGUES.map((l) => ({
    topic: sujet(e.visibilite, l),
    notification: {
      title: traduire(e.titre, l),
      body: [quand(debut, l), e.lieu].filter(Boolean).join(' · '),
    },
    data: { type: 'evenement', id },
  }));
}

/** Nombre de personnes inscrites (chaque inscription compte 1 à 10 personnes). */
export function totalInscrits(inscriptions) {
  return inscriptions.reduce((s, i) => {
    const n = Number.isInteger(i.personnes) ? i.personnes : 1;
    return s + Math.min(Math.max(n, 1), 10);
  }, 0);
}
