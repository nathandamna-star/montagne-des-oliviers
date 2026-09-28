// Réservation des salles : conflits et textes (logique pure, testée sans émulateur).

const l2 = (l) => (l === 'nl' ? 'nl' : 'fr');

/** Deux créneaux se chevauchent (bords qui se touchent autorisés). */
export const chevauche = (a, b) => a.debut < b.fin && b.debut < a.fin;

/** Réservations validées de la même salle qui chevauchent [r]. */
export function conflitsReservation(r, validees) {
  return validees.filter((v) => v.id !== r.id && v.salleId === r.salleId && chevauche(r, v));
}

const T = {
  fr: {
    nouvelle: (nom) => `Réservation demandée par ${nom}`,
    validee: 'Réservation validée',
    refusee: 'Réservation refusée',
  },
  nl: {
    nouvelle: (nom) => `Reservatie aangevraagd door ${nom}`,
    validee: 'Reservatie goedgekeurd',
    refusee: 'Reservatie geweigerd',
  },
};

export function notificationDemandeReservation(id, r, langue, quand) {
  const l = l2(langue);
  return {
    notification: { title: T[l].nouvelle(r.nom), body: `${r.salleNom} · ${quand} · ${r.motif}` },
    data: { type: 'reservation', id, vue: 'gestion' },
  };
}

export function notificationDecisionReservation(id, r, langue, quand) {
  const l = l2(langue);
  return {
    notification: {
      title: r.statut === 'validee' ? T[l].validee : T[l].refusee,
      body: [`${r.salleNom} · ${quand}`, r.reponse].filter(Boolean).join(' — '),
    },
    data: { type: 'reservation', id },
  };
}

/** La décision vient d'être prise (validée ou refusée) ? */
export const decisionPrise = (avant, apres) =>
  avant?.statut === 'demandee' && (apres?.statut === 'validee' || apres?.statut === 'refusee');
