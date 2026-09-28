import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  demandeAvancee, messagesFete, notificationApport, notificationNouvelleDemande, notificationPriere,
  notificationSuiviDemande,
} from '../../vie.js';

describe('demandes', () => {
  it('nouvelle demande pour le secrétariat', () => {
    const n = notificationNouvelleDemande('d1', { type: 'bapteme', nom: 'Marie' }, 'fr');
    assert.equal(n.notification.body, 'Baptême · Marie');
    assert.deepEqual(n.data, { type: 'demande', id: 'd1', vue: 'gestion' });
  });

  it('suivi pour la personne, dans sa langue', () => {
    const n = notificationSuiviDemande('d1', { type: 'mariage', statut: 'en_cours', reponse: 'Rendez-vous dimanche' }, 'nl');
    assert.equal(n.notification.title, 'Je aanvraag (Huwelijk): in behandeling');
    assert.equal(n.notification.body, 'Rendez-vous dimanche');
  });

  it('seulement si le statut ou la réponse change', () => {
    assert.equal(demandeAvancee({ statut: 'nouvelle' }, { statut: 'en_cours' }), true);
    assert.equal(demandeAvancee({ statut: 'en_cours', reponse: '' }, { statut: 'en_cours', reponse: 'Oui' }), true);
    assert.equal(demandeAvancee({ statut: 'en_cours', reponse: 'Oui' }, { statut: 'en_cours', reponse: 'Oui', updatedAt: 1 }), false);
  });
});

describe('prières et fêtes', () => {
  it('anonyme pour l\'intercession, nommé pour les pasteurs', () => {
    const p = { nom: 'Marie', anonyme: true, texte: 'Pour ma santé' };
    assert.equal(notificationPriere('p1', p, 'fr', { pourPasteur: false }).notification.body, 'Anonyme : Pour ma santé');
    assert.equal(notificationPriere('p1', p, 'fr', { pourPasteur: true }).notification.body, 'Marie : Pour ma santé');
  });

  it('fête annoncée aux membres, apport annoncé à la cuisine', () => {
    const m = messagesFete('f1', { titre: 'Anniversaire d\'Esther', lieu: 'Tienen' }, (l) => (l === 'fr' ? 'samedi à 15:00' : 'zaterdag om 15:00'));
    assert.deepEqual(m.map((x) => x.topic), ['membres_fr', 'membres_nl']);
    assert.equal(m[1].notification.body, 'zaterdag om 15:00 · Tienen');
    const a = notificationApport('f1', { titre: 'Anniversaire d\'Esther' }, { nom: 'Paul', apporte: ['gateau', 'boisson'], precision: 'au chocolat' }, 'fr');
    assert.equal(a.notification.body, 'Paul apporte : gâteau, boissons (au chocolat)');
  });
});
