# Modèle de données Firestore — Montagne des Oliviers

Règles : `firebase/firestore.rules` et `firebase/storage.rules` (tests : `cd firebase && npm test`).
Textes traduits = `{ fr, nl? }` (le français est obligatoire et sert de secours).
**Membre de l'église** (pour les règles) = compte connecté ayant donné son consentement (`users/{uid}` existe).
Rôles (custom claims) : `admin` (pasteurs), `secretariat`, `tresorier` ; l'administrateur a tous les droits
du secrétariat et du trésorier. Les administrateurs de groupe sont enregistrés dans le groupe.

| Collection | Contenu | Lecture | Écriture |
|---|---|---|---|
| `users/{uid}` | nom, email, langue fr/nl, consentementLe, photoUrl, jetonsNotif, roles (serveur) | soi, secrétariat | soi (champs limités) |
| `membres/{id}` | fiche : nom, prénom, coordonnées, dateNaissance, familleId, baptemeLe, presentationLe, mariageLe, arriveeLe, statut visiteur/membre/actif, uid (compte lié), groupes, services, notes | secrétariat, la personne liée | secrétariat |
| `familles/{id}` | nom, membres | secrétariat | secrétariat |
| `parametres/eglise` | IBAN, BIC, titulaire, adresse, horaires, chaîne YouTube, groupe d'intercession par défaut | tous | trésorier, admin |
| `actualites/{id}` | titre, texte, photoUrl, epingle, visibilite public/membres, publie, publieLe | selon visibilité | secrétariat |
| `evenements/{id}` | titre, description, type culte/priere/jeune/cellule/evenement/conference, debut, fin, lieu, visibilite, publie, inscription, placesMax, inscrits (serveur) | selon visibilité | secrétariat |
| `evenements/{id}/inscriptions/{uid}` | nom, personnes (1–10) | soi, secrétariat | soi |
| `demandes/{id}` | uid, nom, type bapteme/presentation/mariage/rendezvous/visite, message, statut nouvelle→en_cours→acceptee/refusee→terminee, reponse | auteur, secrétariat | auteur (création, retrait si nouvelle), secrétariat |
| `groupes/{gid}` | nom, description, type cellule/intercession/jeunes/femmes/hommes/louange/moderation/**media**/entraide/autre, prive, membres [uid], admins [uid], lienAppel https, horaires | membres ; groupe ouvert : membres de l'église | secrétariat ; admins du groupe (membres, admins, textes, lien) ; un membre peut partir |
| `groupes/{gid}/messages/{mid}` | auteur, nom, texte, fichierUrl | membres du groupe | membres (à leur nom) ; effacement : auteur ou admin du groupe |
| `groupes/{gid}/rencontres/{rid}` | type reunion/repetition/moderation/appel, titre, debut, fin, lieu, chants [{titre, lien}], qui joue quoi, moderateur, remplacement aucun/demande, deroule, modeAppel aucun/app/externe | membres | admins du groupe ; modérateur (demande de remplacement) ; un membre reprend une modération à remplacer |
| `…/rencontres/{rid}/presences/{uid}` | reponse oui/non/peutetre | membres | soi |
| `groupes/{gid}/appels/{aid}` | mode app/externe, enCours, demarrePar | membres | admins du groupe |
| `prieres/{pid}` | uid, nom, anonyme, texte, partage pasteurs/intercession, groupeId (groupe d'intercession), statut ouverte/exaucee, temoignage, nbPrieres (serveur) | auteur, pasteurs ; + groupe d'intercession si partagé | auteur ; pasteurs (suppression) |
| `prieres/{pid}/priants/{uid}` | « J'ai prié » | comme la prière | soi |
| `preparations/{prid}` | type mariage/bapteme, titre, description, publie | pasteurs, inscrits, tous si publié | pasteurs |
| `preparations/{prid}/lecons/{lid}` | titre, texte, audioUrl, videoUrl, documentUrl, questions, ordre, publique | pasteurs, inscrits, tous si publique | pasteurs |
| `preparations/{prid}/inscrits/{uid}` | nom, demandeId, faites [leçons], rencontres (entretiens, date du baptême / mariage) | pasteurs, soi | pasteurs ; soi (leçons faites) |
| `…/inscrits/{uid}/questions/{qid}` | texte, leconId, reponse | pasteurs, soi | soi (question), pasteurs (réponse) |
| `equipes/{eid}` | nom, membres, responsables (sono, accueil, école du dimanche…) | membres de l'église | secrétariat |
| `equipes/{eid}/affectations/{aid}` | uid, date / evenementId, role, statut prevu/confirme/indisponible/remplacement | équipe, secrétariat | responsables, secrétariat ; la personne (statut) |
| `salles/{sid}` | nom, capacité, description | membres de l'église | secrétariat |
| `reservations/{id}` | uid, nom, salleId, debut, fin, motif, statut demandee/validee/refusee/annulee | auteur, secrétariat ; validées : membres | auteur (demande, annulation), secrétariat |
| `medias/{id}` | type audio/video/direct, titre, description, predicateur, date, url, youtubeId, dureeSec, visibilite, publie | selon visibilité | secrétariat |
| `versets/{id}` | reference, texte, ordre | tous | secrétariat |
| `dons/{communication}` | uid, nom, montant, devise EUR, affectation dime/offrande/mission/construction/entraide, mode virement (carte/Bancontact : serveur), frequence, statut en_attente/recu/annule | donateur, trésorier | donateur (annonce, renoncement) ; trésorier (confirmation) |
| `systeme/*`, `stripe/*` | réservé aux Cloud Functions | — | — |

## Fichiers (Storage)

| Dossier | Lecture | Envoi |
|---|---|---|
| `users/{uid}/` | connectés | soi (image < 5 Mo) |
| `actualites/{id}/`, `evenements/{id}/` | tous | secrétariat (image < 10 Mo) |
| `medias/{id}/` | tous (page web partagée sur WhatsApp) | secrétariat (audio < 200 Mo, vidéo < 1 Go) |
| `preparations/{prid}/{lid}/` | pasteurs, inscrits ; tous si leçon publique | pasteurs (audio, vidéo, image, PDF < 20 Mo) |
| `groupes/{gid}/` | membres du groupe | membres (image, PDF, audio) ; suppression : admins du groupe |
