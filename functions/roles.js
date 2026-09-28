// Logique pure des rôles (testée sans émulateur).

export const ROLES = ['admin', 'secretariat', 'tresorier'];

export const normaliser = (v) => (v ?? '').trim().toLowerCase();

/**
 * Nouveaux custom claims : les rôles demandés remplacent les anciens rôles,
 * les autres claims éventuels sont conservés. Renvoie null si la demande est
 * invalide (rôle inconnu, liste absente).
 */
export function nouveauxClaims(actuels, demandes) {
  if (!Array.isArray(demandes) || demandes.some((r) => !ROLES.includes(r))) {
    return null;
  }
  const claims = { ...(actuels ?? {}) };
  for (const r of ROLES) delete claims[r];
  for (const r of new Set(demandes)) claims[r] = true;
  return claims;
}

/** Rôles présents dans des claims, dans l'ordre de ROLES. */
export const rolesDe = (claims) => ROLES.filter((r) => claims?.[r] === true);
