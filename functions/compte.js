// Export et suppression du compte (RGPD) : logique pure, testée seule.

export const ANONYME = 'compte-supprime';

/** Rend un document Firestore lisible en JSON (dates en ISO, références en chemin). */
export function versJson(valeur) {
  if (valeur === null || valeur === undefined) return null;
  if (typeof valeur?.toDate === 'function') return valeur.toDate().toISOString();
  if (valeur instanceof Date) return valeur.toISOString();
  if (typeof valeur?.path === 'string' && typeof valeur?.id === 'string') return valeur.path;
  if (Array.isArray(valeur)) return valeur.map(versJson);
  if (typeof valeur === 'object') {
    return Object.fromEntries(Object.entries(valeur).map(([k, v]) => [k, versJson(v)]));
  }
  return valeur;
}

/** Profil exporté : sans les jetons techniques de notification. */
export function profilExporte(profil) {
  if (!profil) return null;
  const { jetonsNotif: _jetons, ...reste } = profil;
  return versJson(reste);
}

/**
 * Suppression refusée :
 * - 'dernier-admin' : le seul pasteur administrateur doit d'abord en nommer un autre ;
 * - 'commande-a-retirer' : un livre payé attend encore d'être retiré à l'église.
 */
export function refusSuppression({ estAdmin, autresAdmins, commandes }) {
  if (estAdmin && autresAdmins === 0) return 'dernier-admin';
  if (commandes.some((c) => c.statut === 'payee')) return 'commande-a-retirer';
  return null;
}

/**
 * Dons et commandes : gardés pour la comptabilité (7 ans), sans nom ni lien
 * vers le compte ; ce qui était en attente est annulé.
 */
export function donAnonymise(d) {
  return { uid: ANONYME, nom: '', ...(d.statut === 'en_attente' ? { statut: 'annule' } : {}) };
}

export function commandeAnonymisee(c) {
  return { uid: ANONYME, nom: '', ...(c.statut === 'en_attente' ? { statut: 'annulee' } : {}) };
}

/** Groupe ou équipe : la personne est retirée de toutes les listes. */
export function sansLaPersonne(doc, uid, champs) {
  const maj = {};
  for (const champ of champs) {
    const liste = doc[champ];
    if (Array.isArray(liste) && liste.includes(uid)) maj[champ] = liste.filter((x) => x !== uid);
  }
  return Object.keys(maj).length ? maj : null;
}
