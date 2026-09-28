# CLAUDE.md — Projet « La Montagne des Oliviers »

> Ce fichier décrit l'application à construire. Lis-le en entier avant de commencer.
> Le porteur du projet n'est pas développeur : explique chaque étape simplement, en français,
> et dis-lui exactement quoi faire quand une action de sa part est nécessaire
> (créer un compte, copier une clé, installer un outil).

## 1. Le projet

Application du **Centre Évangélique Montagne des Oliviers**, à **Tienen** (Belgique).
Structure juridique : **Centre Évangélique d'Hoegaarden ASBL**, numéro d'entreprise (BCE)
**0557.986.857**, siège : **Vroentestraat 100, 3320 Hoegaarden** : éditeur de l'app, responsable du traitement
des données, titulaire du compte bancaire, du compte Stripe et, si possible, du compte Apple Developer.
Une seule église. Elle répond à deux besoins :

- **Vie de l'église** (tous les membres, sur téléphone) : actualités, calendrier des cultes et
  événements, demandes (baptême, présentation d'enfant, mariage, rendez-vous pastoral), sujets de
  prière, groupes (cellules de maison, jeunes, louange, entraide), prédications et direct, dîmes et offrandes.
- **Administration** (responsables, sur téléphone **et** sur ordinateur via le site web) : fichier des
  membres et des familles, suivi des dons, plannings des services, réservation des salles.

Vocabulaire évangélique : cultes, pasteurs, anciens, diacres, prédicateurs, équipe de louange,
baptême (par immersion), présentation d'enfant, sainte cène, cellules de maison, dîmes et offrandes.

## 2. Choix techniques (imposés)

| Sujet | Choix |
|---|---|
| Application | **Flutter** : iOS, Android **et Web** (même code ; le web sert surtout au back-office) |
| Gestion d'état / navigation | Riverpod / go_router |
| Back-end | **Firebase** : Authentication, Firestore, Storage, Cloud Messaging, Cloud Functions, **Hosting** (site web) |
| Région | `europe-west1` (RGPD) |
| Langues | **Français** (par défaut) et **néerlandais**, fichiers ARB, aucun texte en dur |
| Dons | **Virement** (IBAN, communication structurée, QR code EPC) **et** **Stripe** (carte, Bancontact, dons mensuels) |
| Direct | Lien **YouTube Live** (ou Facebook) intégré : pas d'hébergement vidéo payant |

N'ajoute pas d'autre service payant sans le demander. Aucune clé secrète dans le dépôt.

## 3. Identité visuelle (reprise du logo de l'église)

- Logo fourni par l'église : cercle vert olive, rameau d'olivier, montagnes gris ardoise, texte
  « CENTRE ÉVANGÉLIQUE » / « MONTAGNE DES OLIVIERS » en dégradé bleu profond → turquoise. Fichier original
  (haute définition, fond blanc) à placer dans `assets/logo/` ; icône de l'app tirée du logo (olivier +
  montagnes, sans le texte, lisible en petit).
- Couleurs : principale bleu profond `#1F4E8C`, secondaire vert olive `#7F9A34`, accent turquoise
  `#3AA0B5`, ardoise `#2C3440` (texte), fond `#F7F9FA`, cartes `#FFFFFF`, texte secondaire `#5B6570`.
  Mode sombre prévu.
- Polices incluses dans l'app (titres avec empattements, texte lisible), zones tactiles ≥ 44 px, contraste AA.
- Barre du bas (membres) : Accueil, Agenda, Groupes, Médias, Profil ; + **Responsables** selon le rôle.
- Sur ordinateur (web) : menu latéral, tableaux larges, recherche, export CSV.

## 4. Rôles (custom claims, attribués par Cloud Function, jamais par l'app)

- **Visiteur** (sans compte) : actualités publiques, horaires des cultes, médias publics, dons.
- **Membre** : tout le contenu réservé aux membres, ses groupes, ses demandes, son historique de dons.
- **Responsable de groupe** : gère son groupe (membres, messages, présences).
- **Trésorier** : dons, confirmation des virements, relevés annuels.
- **Secrétariat** : fichier des membres, salles, demandes, plannings.
- **Pasteur / administrateur** : tout, y compris l'attribution des rôles.

Un compte peut avoir plusieurs rôles. Le premier administrateur est désigné comme dans les autres apps
(e-mail donné au déploiement, fonction `revendiquerAdmin`).

## 5. Modules

### Administration (back-office)
1. **Membres et familles** : fiche (nom, coordonnées, date de naissance, famille, date de baptême,
   présentation d'enfant, mariage, date d'arrivée, statut : visiteur / membre / membre actif),
   groupes, services exercés ; recherche, filtres, export CSV ; lien avec le compte de l'app si la
   personne en a un. Données sensibles (appartenance religieuse) : accès limité au secrétariat et aux pasteurs.
2. **Dîmes et offrandes** : dons ponctuels ou mensuels, par virement (QR code) ou par carte / Bancontact
   (Stripe) ; affectation (dîme, offrande, mission, construction, entraide…) ; confirmation des virements
   par le trésorier ; tableau de bord par mois et par affectation ; **relevé annuel des dons** envoyé à
   chaque donateur (voir 8).
3. **Planning des services** : équipes (prédication, louange, sono / vidéo, accueil, école du dimanche,
   intercession, nettoyage…), plannings par culte, disponibilités, demandes de remplacement,
   rappels automatiques la veille.
4. **Réservation des salles** : liste des salles, calendrier, demande de réservation, validation par le
   secrétariat, détection des conflits.

### Vie de l'église (application)
5. **Actualités et annonces** : articles avec photo, épinglage, public ou membres, notification.
6. **Calendrier** : cultes, réunions de prière, jeûnes, cellules, événements, conférences ; inscription
   aux événements ; ajout au calendrier du téléphone.
7. **Demandes** : baptême, présentation d'enfant, mariage, rendez-vous pastoral, visite ; suivi de la demande.
7 bis. **Préparations au mariage et au baptême** (section « Préparations », accessible depuis l'Accueil,
   le Profil et la demande correspondante) : parcours en leçons créés par les pasteurs, chaque leçon avec
   texte, **audio et vidéo chargés depuis l'app** (téléphone ou ordinateur, Firebase Storage), document
   joint, questions ; les candidats inscrits (après leur demande) voient leur parcours, marquent les
   leçons comme faites, posent des questions au pasteur ; le pasteur suit la progression de chacun et
   planifie les rencontres (entretiens, date du baptême / du mariage). Contenus réservés aux candidats
   inscrits ; certains peuvent être rendus publics.
8. **Sujets de prière** : confidentiel (pasteurs seulement) ou partagé avec l'équipe d'intercession ;
   « J'ai prié » ; témoignages de prières exaucées.
9. **Groupes** : cellules de maison, **groupes d'intercession**, jeunes, femmes, hommes, louange,
   entraide… ; messagerie de groupe privée, documents, événements du groupe.
   - Chaque groupe a un ou plusieurs **administrateurs de groupe** (nommés par le pasteur ou le
     secrétariat) qui **ajoutent et retirent les membres** (parmi les comptes de l'église), nomment
     d'autres administrateurs du groupe, modifient le groupe et ses horaires. Groupe privé : seuls ses
     membres le voient et y écrivent.
   - **Appel de groupe dans l'app** (audio, vidéo possible) : bouton « Démarrer l'appel » pour un
     administrateur, « Rejoindre l'appel » pour les membres, notification « L'appel a commencé »,
     programmation d'appels réguliers (ex. intercession chaque mardi à 20 h, rappel).
     **Choix validé : appel intégré dans l'app** via un fournisseur de temps réel (Agora envisagé :
     quota gratuit mensuel puis facturation à la minute, tarifs à vérifier à l'ouverture du compte, au
     nom de l'ASBL). Jetons d'accès générés par une Cloud Function (membres du groupe seulement,
     certificat de l'app en secret Firebase, jamais dans l'app). Audio par défaut, vidéo en option.
     Derrière une interface `AppelsGroupe` pour pouvoir changer de fournisseur.
     **Et en plus (choix validé) : lien d'appel externe** facultatif par groupe (Google Meet, Zoom, appel
     WhatsApp…), saisi par l'administrateur du groupe (adresse https vérifiée) ; bouton « Rejoindre sur
     Meet / Zoom / WhatsApp » qui ouvre le lien. L'administrateur choisit, pour chaque appel programmé,
     « appel dans l'app » ou « lien externe » ; les deux restent possibles (secours si le quota gratuit
     est dépassé ou si des invités n'ont pas l'app).
   - **Groupe de louange : calendrier des répétitions** (lieu, heure, chants à préparer avec liens
     audio / partitions / paroles, qui joue quoi), présence « Je viens / Je ne viens pas / Peut-être »,
     rappel la veille ; lié au planning des services (le culte du dimanche et sa répétition). Le même
     calendrier de groupe sert aux autres groupes (réunions de cellule, intercession programmée).
   - **Groupe de modération** (modérateurs / animateurs qui conduisent le culte) : **calendrier des
     modérations** = qui modère quel culte ou quel événement (tour de rôle), confirmation « Je suis
     disponible / indisponible », demande de remplacement à un autre modérateur, rappel la veille,
     déroulé du culte joint (ordre : accueil, louange, annonces, offrande, prédication…) ; lié au planning
     des services.
10. **Médias** : prédications et exhortations en audio (podcast, lecture en arrière-plan), vidéos,
    **direct YouTube** du culte, **verset du jour**.
    **Partage WhatsApp (choix validé : gratuit, sans API payante)** : après chaque publication d'une
    exhortation audio ou vidéo, bouton « Envoyer sur WhatsApp » qui ouvre WhatsApp avec un message prêt
    (titre, court texte, lien) à envoyer sur la chaîne / la communauté WhatsApp de l'église. Le lien ouvre
    une **page web publique** de l'exhortation (lecteur audio/vidéo, bouton « Télécharger l'app ») servie par
    Firebase Hosting / Cloud Function, avec aperçu Open Graph. Notification push automatique aux membres
    ayant l'app. L'envoi automatique à chaque membre (WhatsApp Business Platform de Meta, payant par
    message, opt-in obligatoire) est **hors périmètre pour l'instant** ; garder l'envoi derrière une
    interface `DiffusionWhatsApp` pour pouvoir le brancher plus tard.

## 6. Données sensibles (RGPD) — priorité absolue

L'appartenance à une église et les sujets de prière révèlent des convictions religieuses (article 9 RGPD) :
consentement explicite à l'inscription, minimisation, accès limité par rôle, export et suppression du
compte depuis l'app, données en Europe, aucune publicité ni traceur. Registre des membres tenu par
l'église (responsable de traitement : Centre Évangélique d'Hoegaarden ASBL, BCE 0557.986.857).

## 7. Paiements

- Virement : IBAN de l'église, communication structurée belge (modulo 97), QR code EPC.
- Stripe : **compte Stripe de l'église** (paiements directs, pas de Connect) ; carte, Bancontact, dons
  mensuels (abonnement Stripe) ; clés en secrets Firebase ; montants recalculés côté serveur ; webhook signé.
- Apple : un don dans une app iPhone n'est accepté que si l'église est reconnue comme organisme à but non
  lucratif par Apple (paiement par Apple Pay) ; sinon le don se fait dans le navigateur. **À vérifier avant
  la publication.** Apple demandera aussi probablement que l'app soit publiée par le compte développeur
  **de l'église** (ASBL, numéro D-U-N-S ; frais annuels offerts aux organismes sans but lucratif).

## 8. Reçus et relevés

En Belgique, les dons à une église ne donnent droit à une réduction d'impôt que si l'institution est
agréée pour délivrer des attestations fiscales (rare pour un culte). Par défaut : **relevé annuel des
dons** (PDF) pour le donateur, sans valeur fiscale. Si l'église (ou une ASBL liée) est agréée, on
ajoutera les attestations fiscales officielles.

## 9. Ordre de travail

À la fin de chaque étape : l'app compile, les tests passent, commit, push, résumé en français et ce que
le porteur du projet doit vérifier sur son téléphone ou son ordinateur.

1. Projet Flutter (iOS, Android, Web), thème, français / néerlandais, navigation à écrans vides.
2. Firebase (guider le porteur), connexion (e-mail, Google, Apple), consentement, rôles.
3. Modèle de données, règles de sécurité et leurs tests.
4. Actualités, calendrier des cultes et événements, notifications.
5. Membres et familles (back-office mobile et web), rôles des responsables.
6. Groupes et messagerie de groupe.
7. Demandes et sujets de prière.
8. Planning des services.
9. Réservation des salles.
10. Médias : prédications audio, direct YouTube, verset du jour.
11. Dîmes et offrandes : virement + Stripe, dons mensuels, tableau de bord du trésorier, relevé annuel.
12. Profil, export et suppression du compte, pages légales ; mise en ligne du site web (Firebase Hosting).
13. Contenus de départ, tests sur appareils, fiches des stores, publication.

Avant toute décision importante non prévue ici, pose la question au lieu de choisir seul.

## Notes techniques (tenues à jour au fil des étapes)
- Identifiant de l'app : `be.montagnedesoliviers.montagne_des_oliviers` (généré par Flutter ; à fixer avant
  l'enregistrement chez Apple/Google), nom affiché « Montagne des Oliviers ». Le nom de l'église n'est pas
  traduit en néerlandais.
- Structure : `lib/core/` (thème, navigation, rôles), `lib/features/<module>/`, `lib/shared/widgets/`.
- Traductions : `lib/l10n/app_fr.arb` (modèle) et `app_nl.arb` ; langue du téléphone, sinon français.
- Polices incluses dans `assets/google_fonts/` : Montserrat (titres, comme le logo) et Nunito Sans (texte),
  licences OFL jointes ; `GoogleFonts.config.allowRuntimeFetching = false`.
- Navigation : `StatefulShellRoute` à 5 onglets (Accueil, Agenda, Groupes, Médias, Profil) + Responsables si
  `estResponsableProvider` (branché sur les custom claims à l'étape 2). Barre du bas sur téléphone,
  `NavigationRail` à partir de 800 px de large (ordinateur, site web).
- Vérifier avant chaque commit : `flutter analyze`, `flutter test` ; la CI construit aussi la version web.
