// Textes des notifications : demandes, prières, fêtes (logique pure, testée sans émulateur).

const l2 = (l) => (l === 'nl' ? 'nl' : 'fr');

const DEMANDES = {
  fr: { bapteme: 'Baptême', presentation: "Présentation d'enfant", mariage: 'Mariage', rendezvous: 'Rendez-vous avec un pasteur', visite: 'Visite à domicile' },
  nl: { bapteme: 'Doop', presentation: 'Opdracht van een kind', mariage: 'Huwelijk', rendezvous: 'Afspraak met een pastoor', visite: 'Huisbezoek' },
};
const STATUTS = {
  fr: { nouvelle: 'envoyée', en_cours: 'en cours', acceptee: 'acceptée', refusee: 'refusée', terminee: 'terminée' },
  nl: { nouvelle: 'verzonden', en_cours: 'in behandeling', acceptee: 'aanvaard', refusee: 'geweigerd', terminee: 'afgerond' },
};
const APPORTS = {
  fr: { nourriture: 'nourriture', gateau: 'gâteau', boisson: 'boissons', autre: 'autre' },
  nl: { nourriture: 'eten', gateau: 'taart', boisson: 'drank', autre: 'andere' },
};
const T = {
  fr: {
    nouvelleDemande: 'Nouvelle demande',
    votreDemande: (type, statut) => `Votre demande (${type}) : ${statut}`,
    nouvellePriere: 'Nouveau sujet de prière',
    anonyme: 'Anonyme',
    apporte: (nom, quoi) => `${nom} apporte : ${quoi}`,
  },
  nl: {
    nouvelleDemande: 'Nieuwe aanvraag',
    votreDemande: (type, statut) => `Je aanvraag (${type}): ${statut}`,
    nouvellePriere: 'Nieuwe gebedsintentie',
    anonyme: 'Anoniem',
    apporte: (nom, quoi) => `${nom} brengt mee: ${quoi}`,
  },
};

const court = (s, n = 120) => {
  const t = (s ?? '').trim();
  return t.length > n ? `${t.slice(0, n - 1)}…` : t;
};

/** Au secrétariat et aux pasteurs : une nouvelle demande est arrivée. */
export function notificationNouvelleDemande(id, d, langue) {
  const l = l2(langue);
  return {
    notification: { title: T[l].nouvelleDemande, body: `${DEMANDES[l][d.type] ?? d.type} · ${d.nom}` },
    data: { type: 'demande', id, vue: 'gestion' },
  };
}

/** À la personne : sa demande a avancé (statut ou réponse). */
export function notificationSuiviDemande(id, d, langue) {
  const l = l2(langue);
  return {
    notification: {
      title: T[l].votreDemande(DEMANDES[l][d.type] ?? d.type, STATUTS[l][d.statut] ?? d.statut),
      body: court(d.reponse),
    },
    data: { type: 'demande', id },
  };
}

/** La demande a-t-elle changé pour la personne ? */
export const demandeAvancee = (avant, apres) =>
  !!avant && !!apres && (avant.statut !== apres.statut || (avant.reponse ?? '') !== (apres.reponse ?? ''));

/**
 * Nouveau sujet de prière. [pourPasteur] : les pasteurs voient toujours le nom ;
 * l'équipe d'intercession ne le voit pas si la personne reste anonyme.
 */
export function notificationPriere(id, p, langue, { pourPasteur }) {
  const l = l2(langue);
  const nom = p.anonyme && !pourPasteur ? T[l].anonyme : p.nom;
  return {
    notification: { title: T[l].nouvellePriere, body: `${nom} : ${court(p.texte)}` },
    data: { type: 'priere', id },
  };
}

/** Annonce d'une fête à tous les membres (sujet FCM), dans les deux langues. */
export function messagesFete(id, f, quand) {
  return ['fr', 'nl'].map((l) => ({
    topic: `membres_${l}`,
    notification: { title: `🎉 ${f.titre}`, body: [quand(l), f.lieu].filter(Boolean).join(' · ') },
    data: { type: 'fete', id },
  }));
}

/** Aux responsables cuisine : ce qu'une personne apporte. */
export function notificationApport(feteId, fete, a, langue) {
  const l = l2(langue);
  const quoi = (a.apporte ?? []).map((x) => APPORTS[l][x] ?? x).join(', ');
  return {
    notification: {
      title: fete.titre,
      body: T[l].apporte(a.nom, a.precision ? `${quoi} (${court(a.precision, 80)})` : quoi),
    },
    data: { type: 'fete', id: feteId },
  };
}
