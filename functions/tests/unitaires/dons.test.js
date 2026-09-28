import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  actionsWebhook, centimes, checkoutCommande, checkoutDon, communicationValide, donVientDEtreRecu,
  genererCommunication, lienRetour, lignesCommande, notificationCommande, notificationDonRecu,
  pageRetourHtml, suiteCommande, verifierDon,
} from '../../dons.js';

describe('communication structurée', () => {
  it('générée valide, 12 chiffres, contrôle modulo 97', () => {
    for (let i = 0; i < 200; i++) assert.ok(communicationValide(genererCommunication()));
    assert.equal(communicationValide('100000000035'), false);
    assert.equal(communicationValide('010000000001'), false);
    assert.equal(communicationValide('100000000034'), true);
    assert.equal(communicationValide('100000001044'), true);
    // Reste 0 → contrôle 97.
    assert.equal(communicationValide('100000006397'), true);
    assert.equal(communicationValide('100000006300'), false);
  });
});

describe('vérifications', () => {
  it('montants : entre 1 et 10 000 €, au centime', () => {
    assert.equal(centimes(25), 2500);
    assert.equal(centimes('12.5'), 1250);
    assert.equal(centimes(0.5), null);
    assert.equal(centimes(10001), null);
    assert.equal(centimes(1.234), null);
    assert.equal(centimes('abc'), null);
  });

  it('don : affectation connue', () => {
    assert.deepEqual(verifierDon({ montant: 50, affectation: 'dime', mensuel: true }),
      { centimes: 5000, affectation: 'dime', mensuel: true });
    assert.equal(verifierDon({ montant: 50, affectation: 'autre' }), null);
  });

  it('commande : prix du catalogue, livres disponibles, pas de doublon', () => {
    const livres = {
      l1: { titre: 'La prière', prix: 12.5, disponible: true },
      l2: { titre: 'Épuisé', prix: 10, disponible: false },
    };
    assert.deepEqual(lignesCommande([{ livreId: 'l1', quantite: 2, prix: 0.01 }], livres), {
      lignes: [{ livreId: 'l1', titre: 'La prière', prix: 12.5, quantite: 2 }],
      total: 25,
    });
    assert.equal(lignesCommande([{ livreId: 'l2', quantite: 1 }], livres), null);
    assert.equal(lignesCommande([{ livreId: 'x', quantite: 1 }], livres), null);
    assert.equal(lignesCommande([{ livreId: 'l1', quantite: 0 }], livres), null);
    assert.equal(lignesCommande([{ livreId: 'l1', quantite: 1 }, { livreId: 'l1', quantite: 1 }], livres), null);
    assert.equal(lignesCommande([], livres), null);
  });
});

describe('pages de paiement Stripe', () => {
  const site = 'https://mdo.web.app';

  it('don unique : carte et Bancontact', () => {
    const p = checkoutDon({
      uid: 'u1', nom: 'Marie', email: 'm@x.be', langue: 'fr', site,
      don: { centimes: 5000, affectation: 'mission', mensuel: false },
    });
    assert.equal(p.mode, 'payment');
    assert.deepEqual(p.payment_method_types, ['card', 'bancontact']);
    assert.equal(p.line_items[0].price_data.unit_amount, 5000);
    assert.equal(p.line_items[0].price_data.product_data.name, 'Mission');
    assert.deepEqual(p.metadata, { type: 'don', uid: 'u1', nom: 'Marie', affectation: 'mission' });
    assert.equal(p.subscription_data, undefined);
    assert.equal(p.success_url, 'https://mdo.web.app/paiement/merci?retour=dons');
  });

  it('don mensuel : abonnement par carte, en néerlandais', () => {
    const p = checkoutDon({
      uid: 'u1', nom: 'Marie', email: '', langue: 'nl', site,
      don: { centimes: 2000, affectation: 'dime', mensuel: true },
    });
    assert.equal(p.mode, 'subscription');
    assert.deepEqual(p.payment_method_types, ['card']);
    assert.deepEqual(p.line_items[0].price_data.recurring, { interval: 'month' });
    assert.equal(p.line_items[0].price_data.product_data.name, 'Maandelijkse gift · Tiende');
    assert.equal(p.subscription_data.metadata.uid, 'u1');
    assert.equal(p.customer_email, undefined);
    assert.equal(p.locale, 'nl');
  });

  it('commande : une ligne par livre', () => {
    const p = checkoutCommande({
      commandeId: 'c1', uid: 'u1', email: 'm@x.be', langue: 'fr', site,
      lignes: [{ livreId: 'l1', titre: 'La prière', prix: 12.5, quantite: 2 }],
    });
    assert.deepEqual(p.line_items, [{
      price_data: { currency: 'eur', unit_amount: 1250, product_data: { name: 'La prière' } }, quantity: 2,
    }]);
    assert.deepEqual(p.metadata, { type: 'commande', commandeId: 'c1', uid: 'u1' });
    assert.equal(p.success_url, 'https://mdo.web.app/paiement/merci?retour=commande&id=c1');
  });
});

describe('événements Stripe', () => {
  const ev = (type, object) => ({ type, data: { object } });
  const metaDon = { type: 'don', uid: 'u1', nom: 'Marie', affectation: 'offrande' };

  it('don unique payé : enregistré comme reçu', () => {
    const [a] = actionsWebhook(ev('checkout.session.completed', {
      id: 'cs_1', mode: 'payment', payment_status: 'paid', amount_total: 5000, payment_intent: 'pi_1', metadata: metaDon,
    }));
    assert.equal(a.chemin, 'dons/cs_1');
    assert.equal(a.creer, true);
    assert.deepEqual(a.donnees, {
      uid: 'u1', nom: 'Marie', montant: 50, devise: 'EUR', affectation: 'offrande',
      mode: 'en_ligne', statut: 'recu', reference: 'pi_1',
    });
  });

  it('paiement pas encore confirmé : rien', () => {
    assert.deepEqual(actionsWebhook(ev('checkout.session.completed', {
      id: 'cs_1', mode: 'payment', payment_status: 'unpaid', metadata: metaDon,
    })), []);
  });

  it('don mensuel : abonnement, puis un don par mois', () => {
    const [a] = actionsWebhook(ev('checkout.session.completed', {
      id: 'cs_2', mode: 'subscription', payment_status: 'paid', amount_total: 2000, subscription: 'sub_1', metadata: metaDon,
    }));
    assert.equal(a.chemin, 'donsMensuels/sub_1');
    assert.equal(a.donnees.actif, true);
    assert.equal(a.donnees.montant, 20);
    const [b] = actionsWebhook(ev('invoice.paid', {
      id: 'in_1', amount_paid: 2000,
      parent: { subscription_details: { subscription: 'sub_1', metadata: metaDon } },
    }));
    assert.equal(b.chemin, 'dons/in_1');
    assert.equal(b.donnees.mode, 'mensuel');
    assert.equal(b.donnees.reference, 'sub_1');
    const [c] = actionsWebhook(ev('customer.subscription.deleted', { id: 'sub_1', metadata: metaDon }));
    assert.deepEqual(c, { chemin: 'donsMensuels/sub_1', donnees: { actif: false }, horodater: ['finLe'] });
  });

  it('commande payée, ou abandonnée', () => {
    const meta = { type: 'commande', commandeId: 'c1', uid: 'u1' };
    const [a] = actionsWebhook(ev('checkout.session.completed', {
      id: 'cs_3', mode: 'payment', payment_status: 'paid', payment_intent: 'pi_3', metadata: meta,
    }));
    assert.deepEqual(a, {
      chemin: 'commandes/c1', donnees: { statut: 'payee', reference: 'pi_3' },
      horodater: ['payeeLe'], siStatut: 'en_attente',
    });
    const [b] = actionsWebhook(ev('checkout.session.expired', { id: 'cs_3', metadata: meta }));
    assert.equal(b.donnees.statut, 'annulee');
    assert.equal(b.siStatut, 'en_attente');
  });

  it('événements étrangers à l\'app : ignorés', () => {
    assert.deepEqual(actionsWebhook(ev('invoice.paid', { id: 'in_2', amount_paid: 100 })), []);
    assert.deepEqual(actionsWebhook(ev('customer.created', {})), []);
    assert.deepEqual(actionsWebhook(null), []);
  });
});

describe('page de retour et notifications', () => {
  it('lien de retour sûr', () => {
    assert.equal(lienRetour('commande', 'c1'), '/#/profil/commandes/c1');
    assert.equal(lienRetour('commande', '"><script>'), '/#/accueil/dons');
    assert.equal(lienRetour('dons'), '/#/accueil/dons');
    assert.match(pageRetourHtml('merci', 'dons'), /Merci !/);
    assert.match(pageRetourHtml('x', 'dons'), /Paiement annulé/);
  });

  it('don reçu par virement', () => {
    assert.equal(donVientDEtreRecu({ statut: 'en_attente' }, { statut: 'recu' }), true);
    assert.equal(donVientDEtreRecu({ statut: 'recu' }, { statut: 'recu' }), false);
    const n = notificationDonRecu('d1', { montant: 50, affectation: 'dime' }, 'fr');
    assert.equal(n.notification.body, '50,00 € · Dîme');
    assert.equal(notificationDonRecu('d1', { montant: 7.5, affectation: 'dime' }, 'nl').notification.body, '€ 7,50 · Tiende');
  });

  it('commandes : qui prévenir', () => {
    assert.equal(suiteCommande(null, { mode: 'virement', statut: 'en_attente' }), 'gestion');
    assert.equal(suiteCommande(null, { mode: 'en_ligne', statut: 'en_attente' }), null);
    assert.equal(suiteCommande({ mode: 'en_ligne', statut: 'en_attente' }, { mode: 'en_ligne', statut: 'payee' }), 'gestion');
    assert.equal(suiteCommande({ mode: 'en_ligne', statut: 'en_attente' }, { mode: 'en_ligne', statut: 'annulee' }), null);
    assert.equal(suiteCommande({ mode: 'virement', statut: 'en_attente' }, { mode: 'virement', statut: 'payee' }), 'client');
    assert.equal(suiteCommande({ mode: 'virement', statut: 'payee' }, { mode: 'virement', statut: 'payee' }), null);
    const g = notificationCommande('c1', { nom: 'Paul', total: 25, mode: 'virement' }, 'fr', 'gestion');
    assert.equal(g.notification.body, 'Paul · 25,00 € · virement attendu');
    assert.deepEqual(g.data, { type: 'commande', id: 'c1', vue: 'gestion' });
    const c = notificationCommande('c1', { statut: 'payee' }, 'fr', 'client');
    assert.equal(c.notification.body, 'paiement reçu, à retirer à l\'église');
  });
});
