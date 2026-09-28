// Dîmes, offrandes et boutique de livres : logique pure (sans appel à Stripe
// ni à Firebase), testée seule.
//
// Paiement en ligne : Stripe Checkout (page de paiement hébergée par Stripe),
// sur le compte Stripe de l'église. Carte et Bancontact pour un paiement
// unique ; carte pour un don mensuel (abonnement).
import { randomInt } from 'node:crypto';

export const AFFECTATIONS = ['dime', 'offrande', 'mission', 'construction', 'entraide'];

const l2 = (l) => (l === 'nl' ? 'nl' : 'fr');

const LIBELLES = {
  fr: {
    dime: 'Dîme', offrande: 'Offrande', mission: 'Mission', construction: 'Construction', entraide: 'Entraide',
    donMensuel: 'Don mensuel', commande: 'Commande de livres',
  },
  nl: {
    dime: 'Tiende', offrande: 'Offergave', mission: 'Zending', construction: 'Bouwproject', entraide: 'Onderlinge hulp',
    donMensuel: 'Maandelijkse gift', commande: 'Bestelling van boeken',
  },
};

// ----- Communication structurée belge (+++123/4567/89002+++) -----

function controle(base) {
  const reste = Number(BigInt(base) % 97n);
  return String(reste === 0 ? 97 : reste).padStart(2, '0');
}

/** 12 chiffres : 10 chiffres (le premier non nul) + reste de la division par 97. */
export function genererCommunication(hasard = randomInt) {
  const base = [1 + hasard(9), ...Array.from({ length: 9 }, () => hasard(10))].join('');
  return base + controle(base);
}

export const communicationValide = (c) =>
  typeof c === 'string' && /^[1-9]\d{11}$/.test(c) && controle(c.slice(0, 10)) === c.slice(10);

// ----- Vérification des demandes de l'app -----

/** Montant en euros → centimes ; null si invalide (entre 1 € et 10 000 €). */
export function centimes(montant) {
  const n = Number(montant);
  if (!Number.isFinite(n) || n < 1 || n > 10000) return null;
  const c = Math.round(n * 100);
  return Math.abs(c - n * 100) < 1e-6 ? c : null;
}

/** Don en ligne demandé par l'app ; null si invalide. */
export function verifierDon(d) {
  const c = centimes(d?.montant);
  if (c === null || !AFFECTATIONS.includes(d?.affectation)) return null;
  return { centimes: c, affectation: d.affectation, mensuel: d?.mensuel === true };
}

/**
 * Lignes d'une commande calculées avec les prix du catalogue (jamais ceux
 * envoyés par l'app). [livres] : { id → données du livre }. Null si invalide.
 */
export function lignesCommande(demandees, livres) {
  if (!Array.isArray(demandees) || demandees.length === 0 || demandees.length > 20) return null;
  const lignes = [];
  const vus = new Set();
  for (const d of demandees) {
    const livre = livres[d?.livreId];
    const q = d?.quantite;
    if (!livre || livre.disponible !== true || vus.has(d.livreId)) return null;
    if (!Number.isInteger(q) || q < 1 || q > 20) return null;
    const prix = centimes(livre.prix);
    if (prix === null) return null;
    vus.add(d.livreId);
    lignes.push({ livreId: d.livreId, titre: livre.titre, prix: prix / 100, quantite: q });
  }
  const total = lignes.reduce((s, l) => s + Math.round(l.prix * 100) * l.quantite, 0) / 100;
  return { lignes, total };
}

// ----- Pages Stripe Checkout -----

/** Paramètres de la page de paiement d'un don (unique ou mensuel). */
export function checkoutDon({ uid, nom, email, langue, don, site }) {
  const l = l2(langue);
  const metadata = { type: 'don', uid, nom: nom.slice(0, 100), affectation: don.affectation };
  const nomProduit = don.mensuel
    ? `${LIBELLES[l].donMensuel} · ${LIBELLES[l][don.affectation]}`
    : LIBELLES[l][don.affectation];
  const prix = {
    currency: 'eur',
    unit_amount: don.centimes,
    product_data: { name: nomProduit },
    ...(don.mensuel ? { recurring: { interval: 'month' } } : {}),
  };
  return {
    mode: don.mensuel ? 'subscription' : 'payment',
    payment_method_types: don.mensuel ? ['card'] : ['card', 'bancontact'],
    line_items: [{ price_data: prix, quantity: 1 }],
    customer_email: email || undefined,
    locale: l,
    client_reference_id: uid,
    metadata,
    ...(don.mensuel ? { subscription_data: { metadata } } : {}),
    success_url: `${site}/paiement/merci?retour=dons`,
    cancel_url: `${site}/paiement/annule?retour=dons`,
  };
}

/** Paramètres de la page de paiement d'une commande de livres. */
export function checkoutCommande({ commandeId, uid, email, langue, lignes, site }) {
  const l = l2(langue);
  return {
    mode: 'payment',
    payment_method_types: ['card', 'bancontact'],
    line_items: lignes.map((x) => ({
      price_data: {
        currency: 'eur',
        unit_amount: Math.round(x.prix * 100),
        product_data: { name: x.titre },
      },
      quantity: x.quantite,
    })),
    customer_email: email || undefined,
    locale: l,
    client_reference_id: uid,
    metadata: { type: 'commande', commandeId, uid },
    success_url: `${site}/paiement/merci?retour=commande&id=${commandeId}`,
    cancel_url: `${site}/paiement/annule?retour=commande&id=${commandeId}`,
  };
}

// ----- Événements Stripe (webhook) → écritures Firestore -----

/**
 * Traduit un événement Stripe en écritures. Chaque action :
 *   { chemin, donnees, creer?: true, horodater?: [champs], siStatut?: 'en_attente' }
 * - creer : document écrit en entier (identifiant Stripe : rejouer l'événement ne crée pas de doublon) ;
 * - horodater : champs à remplir avec l'heure du serveur ;
 * - siStatut : mise à jour seulement si le document a encore ce statut.
 */
export function actionsWebhook(evenement) {
  const o = evenement?.data?.object ?? {};
  switch (evenement?.type) {
    case 'checkout.session.completed':
    case 'checkout.session.async_payment_succeeded': {
      const m = o.metadata ?? {};
      if (o.payment_status !== 'paid') return [];
      if (m.type === 'commande' && m.commandeId) {
        return [{
          chemin: `commandes/${m.commandeId}`,
          donnees: { statut: 'payee', reference: o.payment_intent ?? o.id },
          horodater: ['payeeLe'],
          siStatut: 'en_attente',
        }];
      }
      if (m.type !== 'don' || !m.uid) return [];
      if (o.mode === 'subscription') {
        // Les versements arrivent ensuite, chaque mois (invoice.paid).
        return [{
          chemin: `donsMensuels/${o.subscription}`,
          creer: true,
          donnees: {
            uid: m.uid, nom: m.nom ?? '', montant: (o.amount_total ?? 0) / 100, devise: 'EUR',
            affectation: m.affectation, actif: true,
          },
          horodater: ['createdAt'],
        }];
      }
      return [{
        chemin: `dons/${o.id}`,
        creer: true,
        donnees: {
          uid: m.uid, nom: m.nom ?? '', montant: (o.amount_total ?? 0) / 100, devise: 'EUR',
          affectation: m.affectation, mode: 'en_ligne', statut: 'recu', reference: o.payment_intent ?? o.id,
        },
        horodater: ['createdAt'],
      }];
    }
    case 'checkout.session.expired':
    case 'checkout.session.async_payment_failed': {
      const m = o.metadata ?? {};
      if (m.type !== 'commande' || !m.commandeId) return [];
      return [{
        chemin: `commandes/${m.commandeId}`,
        donnees: { statut: 'annulee' },
        horodater: ['majLe'],
        siStatut: 'en_attente',
      }];
    }
    case 'invoice.paid': {
      // Versement d'un don mensuel (y compris le premier).
      const abo = o.parent?.subscription_details ?? o.subscription_details ?? {};
      const m = abo.metadata ?? {};
      const subscription = abo.subscription ?? o.subscription;
      if (m.type !== 'don' || !m.uid || !(o.amount_paid > 0)) return [];
      return [{
        chemin: `dons/${o.id}`,
        creer: true,
        donnees: {
          uid: m.uid, nom: m.nom ?? '', montant: o.amount_paid / 100, devise: 'EUR',
          affectation: m.affectation, mode: 'mensuel', statut: 'recu', reference: subscription ?? o.id,
        },
        horodater: ['createdAt'],
      }];
    }
    case 'customer.subscription.deleted': {
      if (o.metadata?.type !== 'don') return [];
      return [{ chemin: `donsMensuels/${o.id}`, donnees: { actif: false }, horodater: ['finLe'] }];
    }
    default:
      return [];
  }
}

// ----- Page affichée après le paiement -----

const PAGE = {
  merci: {
    fr: ['Merci !', 'Votre paiement est bien reçu. Vous pouvez fermer cette page et revenir dans l\'application.'],
    nl: ['Dank je wel!', 'Je betaling is ontvangen. Je kunt deze pagina sluiten en terugkeren naar de app.'],
  },
  annule: {
    fr: ['Paiement annulé', 'Aucun montant n\'a été prélevé. Vous pouvez fermer cette page et revenir dans l\'application.'],
    nl: ['Betaling geannuleerd', 'Er werd niets aangerekend. Je kunt deze pagina sluiten en terugkeren naar de app.'],
  },
};

/** Lien de retour vers le site (version web de l'app). */
export function lienRetour(retour, id) {
  if (retour === 'commande' && /^[A-Za-z0-9_-]{1,40}$/.test(id ?? '')) return `/#/profil/commandes/${id}`;
  return '/#/accueil/dons';
}

/** Page HTML de retour, en français et en néerlandais. */
export function pageRetourHtml(etat, retour, id) {
  const e = etat === 'merci' ? 'merci' : 'annule';
  const [titreFr, texteFr] = PAGE[e].fr;
  const [titreNl, texteNl] = PAGE[e].nl;
  return `<!doctype html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${titreFr} · Montagne des Oliviers</title>
<style>
body{font-family:system-ui,sans-serif;margin:0;background:#f6f4ee;color:#1f2a1f}
main{max-width:520px;margin:48px auto;padding:24px}
h1{color:#3d5a2a}.nl{margin-top:32px;color:#555}
a{display:inline-block;margin-top:24px;padding:12px 20px;border-radius:24px;background:#3d5a2a;color:#fff;text-decoration:none}
</style></head>
<body><main>
<h1>${titreFr}</h1><p>${texteFr}</p>
<div class="nl" lang="nl"><h2>${titreNl}</h2><p>${texteNl}</p></div>
<a href="${lienRetour(retour, id)}">Montagne des Oliviers</a>
</main></body></html>`;
}

// ----- Notifications -----

const T = {
  fr: {
    donRecu: 'Don reçu, merci !',
    nouvelleCommande: 'Nouvelle commande de livres',
    virementAttendu: 'virement attendu',
    payeeEnLigne: 'payée en ligne',
    votreCommande: 'Votre commande de livres',
    statuts: { en_attente: 'en attente du paiement', payee: 'paiement reçu, à retirer à l\'église', remise: 'remise, bonne lecture !', annulee: 'annulée' },
  },
  nl: {
    donRecu: 'Gift ontvangen, dank je wel!',
    nouvelleCommande: 'Nieuwe bestelling van boeken',
    virementAttendu: 'overschrijving verwacht',
    payeeEnLigne: 'online betaald',
    votreCommande: 'Je bestelling van boeken',
    statuts: { en_attente: 'wacht op betaling', payee: 'betaling ontvangen, af te halen in de kerk', remise: 'afgehaald, veel leesplezier!', annulee: 'geannuleerd' },
  },
};

/** « 50,00 € » (fr) ou « € 50,00 » (nl). */
function euros(n, l) {
  const m = Number(n).toFixed(2).replace('.', ',');
  return l === 'nl' ? `€ ${m}` : `${m} €`;
}

/** Au donateur : son virement a été reçu par le trésorier. */
export function notificationDonRecu(id, d, langue) {
  const l = l2(langue);
  return {
    notification: { title: T[l].donRecu, body: `${euros(d.montant, l)} · ${LIBELLES[l][d.affectation] ?? d.affectation}` },
    data: { type: 'don', id },
  };
}

export const donVientDEtreRecu = (avant, apres) =>
  avant?.statut === 'en_attente' && apres?.statut === 'recu';

/**
 * Qui prévenir après l'écriture d'une commande ?
 * - 'gestion' : trésorier et secrétariat (nouvelle commande par virement, ou payée en ligne) ;
 * - 'client' : l'acheteur (nouveau statut) ;
 * - null : personne.
 */
export function suiteCommande(avant, apres) {
  if (!apres) return null;
  if (!avant) return apres.mode === 'virement' ? 'gestion' : null;
  if (avant.statut === apres.statut) return null;
  if (apres.mode === 'en_ligne' && avant.statut === 'en_attente' && apres.statut === 'payee') return 'gestion';
  if (apres.mode === 'en_ligne' && apres.statut === 'annulee' && avant.statut === 'en_attente') return null;
  return 'client';
}

export function notificationCommande(id, c, langue, pour) {
  const l = l2(langue);
  if (pour === 'gestion') {
    const comment = c.mode === 'virement' ? T[l].virementAttendu : T[l].payeeEnLigne;
    return {
      notification: { title: T[l].nouvelleCommande, body: `${c.nom} · ${euros(c.total, l)} · ${comment}` },
      data: { type: 'commande', id, vue: 'gestion' },
    };
  }
  return {
    notification: { title: T[l].votreCommande, body: T[l].statuts[c.statut] ?? c.statut },
    data: { type: 'commande', id },
  };
}
