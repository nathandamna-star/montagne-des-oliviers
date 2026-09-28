import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  doitNotifier, messagesActualite, messagesEvenement, quand, sujet, totalInscrits, traduire,
} from '../../notifications.js';

describe('notifications', () => {
  it('une seule fois, à la publication avec « prévenir »', () => {
    assert.equal(doitNotifier({ publie: true, notifier: true }), true);
    assert.equal(doitNotifier({ publie: false, notifier: true }), false);
    assert.equal(doitNotifier({ publie: true, notifier: false }), false);
    assert.equal(doitNotifier({ publie: true, notifier: true, notifieLe: new Date() }), false);
    assert.equal(doitNotifier(undefined), false);
  });

  it('sujets : public pour tous, membres pour les connectés', () => {
    assert.equal(sujet('public', 'fr'), 'annonces_fr');
    assert.equal(sujet('membres', 'nl'), 'membres_nl');
  });

  it('traduction avec le français en secours', () => {
    assert.equal(traduire({ fr: 'Culte', nl: 'Dienst' }, 'nl'), 'Dienst');
    assert.equal(traduire({ fr: 'Culte' }, 'nl'), 'Culte');
    assert.equal(traduire(undefined, 'fr'), '');
  });

  it('annonce : un message par langue', () => {
    const m = messagesActualite('a1', { titre: { fr: 'Baptêmes', nl: 'Dopen' }, visibilite: 'membres' });
    assert.deepEqual(m.map((x) => x.topic), ['membres_fr', 'membres_nl']);
    assert.equal(m[1].notification.body, 'Dopen');
    assert.deepEqual(m[0].data, { type: 'actualite', id: 'a1' });
  });

  it('événement : date et heure de Bruxelles, lieu', () => {
    // 11 octobre 2026, 8 h UTC = 10 h à Bruxelles (heure d'été).
    const debut = new Date(Date.UTC(2026, 9, 11, 8));
    assert.equal(quand(debut, 'fr'), 'dimanche 11 octobre à 10:00');
    assert.equal(quand(debut, 'nl'), 'zondag 11 oktober om 10:00');
    const m = messagesEvenement('e1', { titre: { fr: 'Culte' }, visibilite: 'public', lieu: 'Tienen' }, debut);
    assert.equal(m[0].topic, 'annonces_fr');
    assert.equal(m[0].notification.title, 'Culte');
    assert.equal(m[0].notification.body, 'dimanche 11 octobre à 10:00 · Tienen');
    assert.equal(m[1].notification.title, 'Culte');
  });

  it('total des inscrits', () => {
    assert.equal(totalInscrits([{ personnes: 2 }, { personnes: 1 }, {}]), 4);
    assert.equal(totalInscrits([{ personnes: 99 }]), 10);
    assert.equal(totalInscrits([]), 0);
  });
});
