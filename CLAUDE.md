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
   **équipe média** (échanger les infos : tournages, matériel, directs, publications), entraide… ; messagerie de groupe privée, documents, événements du groupe.
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
- Identifiant de l'app : `be.montagnedesoliviers.app` (iOS et Android), nom affiché « Montagne des Oliviers ».
  Projet Firebase : `montagne-des-oliviers` (Firestore europe-west1, forfait Blaze ; connexion e-mail, Google, Apple). Le nom de l'église n'est pas
  traduit en néerlandais.
- Structure : `lib/core/` (thème, navigation, rôles), `lib/features/<module>/`, `lib/shared/widgets/`.
- Traductions : `lib/l10n/app_fr.arb` (modèle) et `app_nl.arb` ; langue du téléphone, sinon français.
- Polices incluses dans `assets/google_fonts/` : Montserrat (titres, comme le logo) et Nunito Sans (texte),
  licences OFL jointes ; `GoogleFonts.config.allowRuntimeFetching = false`.
- Navigation : `StatefulShellRoute` à 5 onglets (Accueil, Agenda, Groupes, Médias, Profil) + Responsables si
  `estResponsableProvider` (branché sur les custom claims à l'étape 2). Barre du bas sur téléphone,
  `NavigationRail` à partir de 800 px de large (ordinateur, site web).
- Vérifier avant chaque commit : `flutter analyze`, `flutter test` ; la CI construit aussi la version web.
- Auth (étape 2, `lib/features/auth/`) : e-mail + mot de passe, Google (web : fenêtre Firebase ; mobile :
  google_sign_in avec les identifiants clients de `firebase_options.dart`), Apple (iPhone seulement). Sans compte :
  Accueil, Agenda, Médias ; Groupes et Profil affichent `ConnexionRequise`. Profil `users/{uid}` (nom, email,
  langue fr|nl, `consentementLe` = heure serveur vérifiée par les règles) ; compte Google/Apple sans profil →
  écran de consentement `/connexion/profil` (redirection du routeur). Google et Apple isolés derrière
  `ConnexionFournisseurs`, fonctions derrière `FonctionsRoles` (remplacés dans les tests, voir `test/helpers.dart`).
- Rôles : custom claims `admin`, `secretariat`, `tresorier` (`rolesProvider`, `estResponsableProvider`,
  `estAdminProvider`), recopiés dans `users.roles` par le serveur. Fonctions `revendiquerAdmin` (compte dont
  l'e-mail est le paramètre `EMAIL_ADMIN`, une seule fois, trace dans `systeme/admin` ; dans l'app : appui long
  sur la carte « Bonjour … » du Profil) et `definirRoles` (administrateur ; par e-mail ; impossible de retirer
  son propre rôle d'admin) — écran Responsables → Rôles des responsables.
- Règles : `firebase/firestore.rules` (fichier des membres lisible par secrétariat et admin), tests
  `cd firebase && npm install && npm test` ; fonctions : `functions/` (Node 22, europe-west1), logique pure dans
  `roles.js`, tests `cd functions && npm install && npm test` (Java 21 requis pour l'émulateur).
- Identité : fichiers d'origine dans `docs/identite/` (logo 1024 px sur fond noir, bannière « Rester connecté avec
  nous » 1920×1080, vidéo pub 16 s). Dans l'app : `assets/images/logo.png` (logo sur fond blanc, demande du porteur ; original `docs/identite/logo-fond-blanc.png` ; widget `LogoEglise`, disque blanc) et
  `assets/images/banniere.jpg` (Accueil des visiteurs) ; membres : carte dégradé + logo + devise
  « Repentance · Délivrance · Sanctification » (clé `devise`, traduite en néerlandais). Icônes iOS, Android et web
  générées depuis le logo sur fond blanc (maskable : logo à 80 %). La vidéo servira dans Médias / partage (étapes suivantes).
- Modèle de données (étape 3) : `docs/modele-donnees.md` (toutes les collections, qui lit, qui écrit).
  Membre de l'église = compte avec profil (consentement). Règles Firestore + Storage testées dans
  `firebase/tests/` (Storage lit Firestore : `firestore.get`). Dans cet environnement cloud, lancer les tests
  des règles sans les variables de proxy (`env -u GLOBAL_AGENT_HTTPS_PROXY -u HTTPS_PROXY -u https_proxy npm test`).
- Annonces (étape 4, `lib/features/actualites/`) : `actualites/{id}` (titre/texte `{fr, nl?}` via `Traduction`,
  photoUrl dans Storage `actualites/{id}/…` envoyée par `EnvoiPhotos` (image_picker), epingle, visibilite
  public|membres, publie, notifier, publieLe fixée à la 1re publication, modifieLe). Accueil : 3 dernières (épinglées
  d'abord) + « Tout voir » (`/accueil/actualites`, fiche `/accueil/actualites/:id`). Responsables → Annonces
  (secrétariat/admin, `estSecretariatProvider`) : liste avec brouillons, éditeur FR/NL.
- Agenda (`lib/features/agenda/`) : `evenements/{id}` (titre, description, type culte|priere|jeune|cellule|evenement|
  conference, debut, fin, lieu, visibilite, publie, notifier, inscription, placesMax, inscrits tenu par la fonction
  `compterInscrits`). Onglet Agenda : à venir (fin ≥ aujourd'hui, `horlogeProvider`), un titre par jour, filtres par
  type ; fiche `/agenda/:id` avec inscription (1 à 10 personnes, « Complet »). Responsables → Agenda de l'église :
  éditeur (par défaut dimanche suivant 10 h–12 h) et liste des inscrits. Requêtes : index composites dans
  `firebase/firestore.indexes.json`.
- Notifications (`lib/features/notifications/`) : sujets FCM `annonces_fr|nl` (tous, même sans compte) et
  `membres_fr|nl` (connectés) selon la langue du téléphone ; jeton dans `users.jetonsNotif` (pour les notifications
  personnelles à venir). Fonctions `notifierActualite` / `notifierEvenement` : une seule fois (`notifieLe`) quand
  publié avec `notifier` ; textes FR/NL et heure de Bruxelles (`functions/notifications.js`). Toucher la notification
  ouvre l'annonce ou l'événement. iPhone : `Runner.entitlements` (aps-environment) + clé APNs dans Firebase.
- Membres et familles (étape 5, `lib/features/membres/`) : `membres/{id}` (voir `Membre` : nom, prénom, coordonnées,
  dates de naissance / arrivée / baptême / présentation / mariage, statut visiteur|membre|actif, familleId, uid du compte
  lié, services, notes) et `familles/{id}` (nom). Responsables → Fichier des membres (secrétariat/admin) : recherche
  sans accents (`sansAccents`), filtre par statut, tableau sur grand écran (≥ 900 px), export CSV (`exporterCsv` :
  point-virgule + BOM pour Excel, liste filtrée) partagé par `Partage` (share_plus, téléchargement sur le web),
  « comptes de l'app sans fiche » → fiche pré-remplie (`?uid=`). Familles : liste, ajout/retrait de personnes.
  Rôles : liste des responsables actuels (`users.roles`, écrit par `definirRoles`).
- Site web (back-office sur ordinateur) : Firebase Hosting (`build/web`, réécriture vers index.html) :
  `flutter build web && npx firebase-tools deploy --only hosting` → https://montagne-des-oliviers.web.app
- Groupes (étape 6, `lib/features/groupes/`) : `groupes/{id}` (nom, type dont `media`, description, prive, membres,
  admins, lienAppel https, dernierMessage écrit par `nouveauMessageGroupe`). Onglet Groupes : « Mes groupes »
  (array-contains) + « Groupes ouverts » (qui contacter pour entrer). Page du groupe : Discussion (texte + photo
  Storage `groupes/{id}/…`, appui long pour effacer : auteur ou admin du groupe), « Rejoindre l'appel » (lien externe
  via `Lanceur`), membres (admins du groupe ou secrétariat : ajouter depuis l'annuaire, nommer / retirer admin,
  retirer ; il reste toujours un admin), quitter (membre simple). Éditeur : le secrétariat choisit type, privé et
  les premiers admins ; l'admin du groupe modifie nom, description, lien. Responsables → Groupes de l'église.
  Non-lus : dernière lecture par groupe sur le téléphone (`LecturesGroupes`, shared_preferences).
- Annuaire : `annuaire/{uid}` = { nom } seulement, recopié du profil par `synchroniserAnnuaire` (se crée à la
  prochaine écriture du profil pour les comptes existants), lisible par les membres de l'église.
- Notifications de groupe : `nouveauMessageGroupe` envoie aux jetons des membres (sauf l'auteur) dans leur langue,
  retire les jetons expirés ; toucher → discussion. Appel intégré (Agora), calendriers de répétition et de modération :
  étape suivante des groupes.
- Éditeurs : lecture ponctuelle (`lire(id)`, `get()`) plutôt que `.first` d'un flux.
- Calendriers des groupes (étape 6 bis) : `groupes/{gid}/rencontres/{rid}` (`Rencontre` : type reunion|repetition|
  moderation|appel, titre, debut, fin, lieu, notes, chants [{titre, lien https}], roles uid → instrument, moderateur,
  remplacement aucun|demande, deroule [étapes], modeAppel externe, rappelEnvoye par le serveur, remis à false si la
  date change). Page du groupe → 3 prochains + « Tout voir » (`/groupes/:id/calendrier`), fiche
  (`…/calendrier/:rid`), éditeur admin (`…/:rid/modifier`, « nouvelle » : type proposé selon le groupe — louange →
  répétition demain 19 h, modération → culte du dimanche 10 h avec `derouleCulte`). Présences
  `…/presences/{uid}` (Je viens / Je ne viens pas / Peut-être). Modération : le modérateur demande un remplaçant,
  un autre membre « Je remplace ».
- Fonctions : `nouvelleRencontre` (prévient les membres), `demandeRemplacement` (prévient les autres membres),
  `rappelsRencontres` (toutes les heures : rappel dans les 24 h, au modérateur seulement pour une modération ;
  index de groupe de collections sur `rencontres.debut`). Envoi commun : `envoyerAuxComptes`. Toucher →
  `{type: 'rencontre', id, rid}`.
- À FAIRE PLUS TARD (demandé par le porteur) : liens **Facebook** et **YouTube** de l'église (comptes pas encore
  créés) : champs `facebookUrl`, `youtubeUrl` dans `parametres/eglise`, saisis par l'admin, boutons sur l'Accueil
  et dans Médias (étape 10) ; le direct YouTube utilisera la même chaîne.
- Demandes (étape 7, `lib/features/demandes/`) : `demandes/{id}` (type bapteme|presentation|mariage|rendezvous|visite,
  message, statut nouvelle|en_cours|acceptee|refusee|terminee — `StatutDemande.enCours.code` = « en_cours » —,
  reponse, traiteePar). Membre : Accueil « Faire une demande », Profil → Mes demandes (retrait tant que « nouvelle »).
  Responsables → Demandes (secrétariat/pasteurs : à traiter / toutes, statut + réponse). Fonctions `nouvelleDemande`
  (prévient `users.roles` admin/secretariat) et `suiviDemande` (prévient la personne).
- Sujets de prière (`lib/features/prieres/`) : `prieres/{id}` (partage pasteurs | intercession avec
  `parametres/eglise.groupeIntercessionId`, anonyme pour l'équipe, statut ouverte|exaucee, temoignage, nbPrieres par
  `compterPriants`). Accueil « Sujet de prière », Profil → Mes sujets, groupe d'intercession → Sujets de prière,
  Responsables → Sujets de prière (pasteurs). « J'ai prié » (`priants/{uid}`). Fonction `nouvellePriere`.
- Paramètres de l'église (pasteurs) : groupe d'intercession, groupe cuisine, liens Facebook / YouTube (boutons sur
  l'Accueil quand ils sont renseignés).
- Divers (demande du porteur) : onglet « Divers » dans l'Agenda. `fetes/{id}` (anniversaire|naissance|mariage|fete|autre,
  titre, date, lieu, annoncée par un membre, modifiable par lui ou le secrétariat). Pas de « je viens » : chacun indique
  ce qu'il apporte (`fetes/{id}/apports/{uid}` : nourriture|gateau|boisson|autre + précision) pour informer les
  **responsables cuisine** = groupe de type `cuisine` désigné dans les paramètres (`groupeCuisineId`), qui voient la
  liste et les totaux et sont notifiés (`nouvelApport`). Nouvelle fête → sujets `membres_fr|nl` (`nouvelleFete`).

- Préparations (étape 7 bis, `lib/features/preparations/`) : `preparations/{id}` (type mariage|bapteme, titre/description
  FR/NL, publie), `…/lecons/{lid}` (titre, texte, ordre, publique, audioUrl, videoUrl, documentUrl — fichiers envoyés
  par `EnvoiFichiers` (file_picker, putFile sur téléphone / putData sur le web, vidéos recompressées) dans Storage
  `preparations/{id}/{lid}/…`), `…/inscrits/{uid}` (nom, demandeId, faites, rencontres [{titre, date}]) et
  `…/questions/{qid}`. Accès : Accueil / Profil / Responsables → Préparations (`/accueil/preparations`), et depuis une
  demande de baptême ou de mariage (membre : « Voir les préparations » ; pasteur : « Inscrire à une préparation »).
  Non inscrit : leçons publiques + « Faire une demande » (type pré-choisi `?type=`). Candidat : progression,
  rencontres, « J'ai terminé cette leçon », questions. Pasteur : éditeurs, ordre (monter/descendre), candidats
  (inscrire depuis l'annuaire, rencontres, réponses). Lecteurs audio/vidéo repris de NDAD (`lib/shared/lecteurs/`,
  `FauxLecteurs` en test), `sharedPreferencesProvider` chargé dans main(). Fonctions `inscriptionPreparation`,
  `questionPreparation`, `reponsePreparation`.
- Groupes (demande du porteur) : bouton « Ajouter un administrateur » sur la page du groupe (la personne devient
  membre et administrateur, `ajouterAdmins`) ; à la création, recherche par nom et administrateurs choisis affichés en
  haut. Fonction `reconstruireAnnuaire` (secrétariat/admin) appelée à l'ouverture de ces écrans : tous les comptes
  apparaissent dans la liste, même anciens.
- Planning des services (étape 8, `lib/features/planning/`) : `equipes/{id}` (nom, description, membres, responsables ⊂
  membres ; créées par le secrétariat, les responsables gèrent les membres) et `equipes/{id}/affectations/{aid}` (uid,
  nom, date, titre du culte, role, statut prevu|confirme|indisponible|remplacement, remplace, rappelEnvoye). « Mon
  planning » (`/accueil/planning`, Accueil / Profil / Responsables) : mes services (requête de groupe de collections
  `affectations` sur uid, règle `/{chemin=**}/affectations`) → confirmer / indisponible / demander un remplaçant ;
  mes équipes. Page d'équipe : planning par date, « Je remplace » (un autre membre reprend, `remplace` = ancien nom),
  responsables : ajouter au planning (culte choisi dans l'agenda ou date libre), membres. Fonctions
  `nouvelleAffectation`, `changementAffectation`, `rappelsServices` (veille, toutes les heures). `ChoixPersonnes`
  (feuille de choix dans l'annuaire) partagé avec les groupes.
- Préparations : rubrique **Exhortations** (demande du porteur) : même document que les leçons avec `genre:
  'exhortation'` (audio / vidéo / texte), liste séparée, pas comptée dans la progression ni « terminée ».
- Entretien de la salle (demande du porteur, `lib/features/entretien/`) : `nettoyages/{id}` (titre, date, description,
  places, nbInscrits par `compterNettoyage`, rappelEnvoye) créées par le secrétariat ; chacun s'inscrit
  (`…/inscrits/{uid}` : nom) ou se désinscrit ; « Complet » quand le nombre souhaité est atteint. Accès : Accueil et
  Mon planning (`/accueil/entretien`). Fonctions `nouveauNettoyage` (sujets membres) et `rappelsNettoyage` (veille).
- À FAIRE (demande du porteur) : **Boutique** (livres) payable par virement (QR EPC, communication structurée) ou
  Bancontact / carte (Stripe) — à faire avec l'étape 11 (même compte Stripe que les dons). Livre papier = bien
  physique : paiement hors Apple autorisé.
- Réservation des salles (étape 9, `lib/features/salles/`) : `salles/{id}` (nom, capacite, description ; secrétariat) et
  `reservations/{id}` (uid, nom, salleId, salleNom, debut, fin, motif, statut demandee|validee|refusee|annulee,
  reponse). `/accueil/salles` (Accueil « Réserver une salle », Responsables « Salles et réservations ») : salles, mes
  réservations (annuler) ; fiche salle : créneaux validés à venir + demande (demain 14 h–16 h par défaut), bloquée si
  `conflits()` (bords qui se touchent autorisés). Secrétariat : `/accueil/salles/a-valider` (conflits signalés,
  « Valider » désactivé en cas de conflit, refuser avec message). Fonctions `nouvelleReservation` (secrétariat) et
  `decisionReservation` (prévient la personne ; filet : une validation en conflit repasse « demandee »).
- Médias (étape 10, `lib/features/medias/`) : `medias/{id}` (type audio|video|direct, titre/description FR/NL,
  predicateur, date, url = fichier Storage `medias/{id}/…` (EnvoiFichiers) ou lien YouTube/Facebook (`lienExterne` :
  ouvert dehors), visibilite, publie, notifier) et `versets/{id}` (reference, texte FR/NL, ordre ; `versetDuJour` :
  un par jour en boucle, sur l'Accueil et dans Médias). Onglet Médias : verset, carte Direct (prochain direct ou
  chaîne YouTube des paramètres), filtres Audios / Vidéos ; fiche `/medias/:id` (lecteurs, « Envoyer sur WhatsApp »
  pour les médias publics via `DiffusionWhatsApp` → wa.me avec message prêt + lien `https://montagne-des-oliviers.web.app/m/{id}`).
  Page web publique : fonction `pageMedia` (Hosting réécrit `/m/**`, aperçu Open Graph, lecteur, 404 si réservé aux
  membres ou non publié). Responsables → Médias (secrétariat) : éditeur, versets du jour. Fonction `notifierMedia`.
- Présentation (demande du porteur) : Accueil en **grille de raccourcis** (2 à 6 tuiles par ligne selon la largeur :
  Dîmes et offrandes, Boutique, Notre pasteur ; + pour les membres : demande, prière, planning, salles, entretien,
  préparations), annonces et agenda côte à côte sur grand écran, contenu limité à 1200 px. Navigation : barre du bas
  < 600 px (téléphone), menu latéral compact 600–1100 px (tablette), menu latéral déplié ≥ 1100 px (ordinateur).
- **Notre pasteur** (`/accueil/pasteur`) : `parametres/eglise.pasteurNom`, `pasteurPhotoUrl` (Storage `parametres/…`,
  admin), `pasteurPresentation` {fr, nl} ; édition par l'administrateur (`/accueil/pasteur/modifier`, aussi dans
  Responsables).
- **Réseaux sociaux** : `youtubeUrl`, `facebookUrl`, `tiktokUrl`, `instagramUrl` (Paramètres de l'église) ; widget
  `ReseauxSociaux` (logos font_awesome_flutter) sur l'Accueil et dans Médias, seulement les comptes renseignés.
