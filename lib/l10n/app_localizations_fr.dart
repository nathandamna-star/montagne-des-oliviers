// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Montagne des Oliviers';

  @override
  String get nomEglise => 'Centre Évangélique Montagne des Oliviers';

  @override
  String get navAccueil => 'Accueil';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navGroupes => 'Groupes';

  @override
  String get navMedias => 'Médias';

  @override
  String get navProfil => 'Profil';

  @override
  String get navResponsables => 'Responsables';

  @override
  String get bientot => 'Bientôt disponible';

  @override
  String get accueilBienvenue =>
      'Bienvenue dans la famille de la Montagne des Oliviers.';

  @override
  String get accueilAVenir =>
      'Ici : le verset du jour, les annonces de l\'église, le prochain culte et le direct.';

  @override
  String get agendaAVenir =>
      'Ici : les cultes, les réunions de prière, les cellules de maison et tous les événements, avec inscription.';

  @override
  String get groupesAVenir =>
      'Ici : vos cellules de maison, les jeunes, la louange, l\'entraide… avec une discussion privée par groupe.';

  @override
  String get mediasAVenir =>
      'Ici : les prédications et exhortations en audio et en vidéo, le direct du culte et le verset du jour.';

  @override
  String get profilAVenir =>
      'Ici : votre compte, vos demandes, vos sujets de prière, vos dons et la langue de l\'application.';

  @override
  String get responsablesAVenir =>
      'Ici : le fichier des membres, les dons, les plannings des services et la réservation des salles.';

  @override
  String get seConnecter => 'Se connecter';

  @override
  String get seDeconnecter => 'Se déconnecter';

  @override
  String get creerCompte => 'Créer un compte';

  @override
  String get connexionIntro =>
      'Connectez-vous pour rejoindre vos groupes, vous inscrire aux activités et faire vos demandes.';

  @override
  String get continuerGoogle => 'Continuer avec Google';

  @override
  String get continuerApple => 'Continuer avec Apple';

  @override
  String get continuerEmail => 'Continuer avec un e-mail';

  @override
  String get continuerSansCompte => 'Continuer sans compte';

  @override
  String get bienvenueFamille => 'Bienvenue dans la famille !';

  @override
  String get completerProfilIntro =>
      'Encore une étape : indiquez votre nom et acceptez l\'utilisation de vos données.';

  @override
  String get annuler => 'Annuler';

  @override
  String get valider => 'Valider';

  @override
  String get enregistrer => 'Enregistrer';

  @override
  String get chargement => 'Chargement…';

  @override
  String get champNom => 'Prénom et nom';

  @override
  String get champEmail => 'Adresse e-mail';

  @override
  String get champMotDePasse => 'Mot de passe';

  @override
  String get afficherMotDePasse => 'Afficher le mot de passe';

  @override
  String get masquerMotDePasse => 'Masquer le mot de passe';

  @override
  String get motDePasseOublie => 'Mot de passe oublié ?';

  @override
  String emailReinitialisationEnvoye(String email) {
    return 'Un e-mail pour choisir un nouveau mot de passe a été envoyé à $email.';
  }

  @override
  String get validationNomRequis => 'Indiquez votre nom.';

  @override
  String get validationEmail => 'Indiquez une adresse e-mail valide.';

  @override
  String get validationMotDePasse => 'Au moins 8 caractères.';

  @override
  String get consentementTexte =>
      'J\'accepte que l\'église enregistre mes données (nom, e-mail, groupes, demandes et sujets de prière, qui peuvent révéler mes convictions religieuses) pour la vie de la communauté. Je peux supprimer mon compte à tout moment.';

  @override
  String get consentementRequis => 'Cochez la case pour continuer.';

  @override
  String get connexionRequiseTitre => 'Connexion nécessaire';

  @override
  String get connexionRequiseTexte =>
      'Cette partie est réservée aux membres connectés.';

  @override
  String get groupesConnexionTexte =>
      'Connectez-vous pour retrouver vos groupes et leurs discussions.';

  @override
  String get profilConnexionTexte =>
      'Connectez-vous pour voir votre compte, vos demandes et vos dons.';

  @override
  String get accueilConnexionTexte =>
      'Vous faites partie de l\'église ? Connectez-vous pour tout retrouver.';

  @override
  String bonjourNom(String nom) {
    return 'Bonjour $nom';
  }

  @override
  String get activerAdminTitre => 'Activer l\'administration ?';

  @override
  String get activerAdminTexte =>
      'Seul le compte désigné lors de l\'installation peut devenir administrateur.';

  @override
  String get adminActive => 'Vous êtes maintenant administrateur.';

  @override
  String get adminRefuse => 'Ce compte ne peut pas devenir administrateur.';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String get roleSecretariat => 'Secrétariat';

  @override
  String get roleTresorier => 'Trésorier';

  @override
  String get roleAdminAide => 'Tout gérer, y compris les rôles.';

  @override
  String get roleSecretariatAide => 'Membres, agenda, annonces, demandes.';

  @override
  String get roleTresorierAide => 'Dons et relevés annuels.';

  @override
  String get rolesTitre => 'Rôles des responsables';

  @override
  String get rolesSousTitre => 'Donner ou retirer un accès';

  @override
  String get rolesAide =>
      'La personne doit d\'abord avoir créé son compte. Décochez tout pour retirer ses accès.';

  @override
  String rolesEnregistres(String email) {
    return 'Rôles enregistrés pour $email.';
  }

  @override
  String get rolesCompteIntrouvable =>
      'Aucun compte avec cette adresse. La personne doit d\'abord s\'inscrire.';

  @override
  String get rolesRefuse => 'Seul un administrateur peut changer les rôles.';

  @override
  String get erreurEmailInvalide => 'Cette adresse e-mail n\'est pas valide.';

  @override
  String get erreurMotDePasseFaible =>
      'Ce mot de passe est trop faible. Utilisez au moins 8 caractères.';

  @override
  String get erreurEmailDejaUtilise =>
      'Un compte existe déjà avec cette adresse. Connectez-vous plutôt.';

  @override
  String get erreurIdentifiantsIncorrects =>
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get erreurTropDeTentatives =>
      'Trop de tentatives. Réessayez dans quelques minutes.';

  @override
  String get erreurReseau =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get erreurInconnue => 'Une erreur est survenue. Réessayez.';

  @override
  String get devise => 'Repentance · Délivrance · Sanctification';

  @override
  String get annonce => 'Annonce';

  @override
  String get annonces => 'Annonces';

  @override
  String get annoncesSousTitre => 'Publier les annonces de l\'église';

  @override
  String get annonceIndisponible => 'Cette annonce n\'est plus disponible.';

  @override
  String get aucuneAnnonce => 'Aucune annonce pour le moment.';

  @override
  String get aucunEvenement => 'Aucun événement prévu pour le moment.';

  @override
  String get brouillon => 'Brouillon';

  @override
  String get champTitre => 'Titre';

  @override
  String get champTexte => 'Texte';

  @override
  String get champDescription => 'Description';

  @override
  String get champObligatoire => 'Ce champ est obligatoire.';

  @override
  String get traductionFacultative =>
      'Facultatif : sinon le texte français est affiché.';

  @override
  String get ajouterPhoto => 'Ajouter une photo';

  @override
  String get changerPhoto => 'Changer la photo';

  @override
  String get retirerPhoto => 'Retirer la photo';

  @override
  String get erreurPhoto => 'La photo n\'a pas pu être envoyée. Réessayez.';

  @override
  String get erreurChargement =>
      'Impossible de charger. Vérifiez votre connexion.';

  @override
  String get complet => 'Complet';

  @override
  String get debut => 'Début';

  @override
  String get fin => 'Fin';

  @override
  String get finAvantDebut => 'La fin doit être après le début.';

  @override
  String get enregistre => 'Enregistré.';

  @override
  String get envoyerNotification => 'Prévenir par notification';

  @override
  String get envoyerNotificationAide =>
      'Une notification est envoyée une seule fois, à la publication.';

  @override
  String get epinglee => 'Épinglée';

  @override
  String get epingler => 'Épingler en haut';

  @override
  String get epinglerAide => 'Reste en tête des annonces.';

  @override
  String get evenement => 'Événement';

  @override
  String get evenementIndisponible => 'Cet événement n\'est plus disponible.';

  @override
  String get gestionAgenda => 'Agenda de l\'église';

  @override
  String get gestionAgendaSousTitre => 'Cultes, réunions et événements';

  @override
  String get inscription => 'Inscription';

  @override
  String get inscriptionConnexion => 'Connectez-vous pour vous inscrire.';

  @override
  String get inscriptionOuverte => 'Inscriptions ouvertes';

  @override
  String inscritPersonnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personnes',
      one: '1 personne',
    );
    return 'Inscription confirmée ($_temp0).';
  }

  @override
  String inscritsNombre(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n inscrits',
      one: '1 inscrit',
      zero: 'Aucun inscrit',
    );
    return '$_temp0';
  }

  @override
  String inscritsSurPlaces(int n, int max) {
    return '$n inscrits sur $max places';
  }

  @override
  String get lieu => 'Lieu';

  @override
  String get modifierAnnonce => 'Modifier l\'annonce';

  @override
  String get modifierEvenement => 'Modifier l\'événement';

  @override
  String get moins => 'Moins';

  @override
  String get plus => 'Plus';

  @override
  String get nombreInvalide => 'Indiquez un nombre entier.';

  @override
  String get nombrePersonnes => 'Nombre de personnes';

  @override
  String get nouvelEvenement => 'Nouvel événement';

  @override
  String get nouvelleAnnonce => 'Nouvelle annonce';

  @override
  String get placesMax => 'Nombre de places';

  @override
  String get placesMaxAide => 'Laisser vide s\'il n\'y a pas de limite.';

  @override
  String get prochainement => 'Prochainement';

  @override
  String publieeLe(String date) {
    return 'Publiée le $date';
  }

  @override
  String get publier => 'Publier';

  @override
  String get publierAide =>
      'Sinon, reste en brouillon (visible seulement par les responsables).';

  @override
  String get sInscrire => 'Je m\'inscris';

  @override
  String get seDesinscrire => 'Annuler mon inscription';

  @override
  String get supprimer => 'Supprimer';

  @override
  String get supprimerAnnonce => 'Supprimer cette annonce ?';

  @override
  String get supprimerEvenement => 'Supprimer cet événement ?';

  @override
  String get tous => 'Tous';

  @override
  String get toutLAgenda => 'Tout l\'agenda';

  @override
  String get voirTout => 'Tout voir';

  @override
  String get typeEvenementChamp => 'Type';

  @override
  String get visibilite => 'Qui peut le voir ?';

  @override
  String get visibilitePublic => 'Tout le monde';

  @override
  String get visibiliteMembres => 'Membres';

  @override
  String get typeCulte => 'Culte';

  @override
  String get typePriere => 'Prière';

  @override
  String get typeJeune => 'Jeûne';

  @override
  String get typeCellule => 'Cellule';

  @override
  String get typeEvenement => 'Événement';

  @override
  String get typeConference => 'Conférence';

  @override
  String get ajouter => 'Ajouter';

  @override
  String get ajouterALaFamille => 'Ajouter une personne';

  @override
  String get aucun => 'Aucun';

  @override
  String get aucune => 'Aucune';

  @override
  String get aucuneFamille => 'Aucune famille pour le moment.';

  @override
  String get aucuneFiche => 'Aucune fiche.';

  @override
  String get autreService => 'Autre service';

  @override
  String get champArrivee => 'Arrivée à l\'église';

  @override
  String get champBapteme => 'Baptême';

  @override
  String get champCodePostal => 'Code postal';

  @override
  String get champDateNaissance => 'Date de naissance';

  @override
  String get champFamille => 'Famille';

  @override
  String get champMariage => 'Mariage';

  @override
  String get champNomFamille => 'Nom';

  @override
  String get champNotes => 'Notes';

  @override
  String get champPrenom => 'Prénom';

  @override
  String get champPresentation => 'Présentation d\'enfant';

  @override
  String get champRue => 'Rue et numéro';

  @override
  String get champServices => 'Services';

  @override
  String get champStatut => 'Statut';

  @override
  String get champTelephone => 'Téléphone';

  @override
  String get champVille => 'Localité';

  @override
  String get compteApp => 'Compte de l\'application';

  @override
  String get compteLie => 'Compte lié';

  @override
  String get compteLieAide => 'La personne pourra voir sa fiche dans l\'app.';

  @override
  String comptesSansFiche(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n comptes de l\'app sans fiche',
      one: '1 compte de l\'app sans fiche',
    );
    return '$_temp0';
  }

  @override
  String get comptesSansFicheAide =>
      'Créer leur fiche en reprenant nom et e-mail';

  @override
  String get coordonnees => 'Coordonnées';

  @override
  String get creer => 'Créer';

  @override
  String get creerFicheDepuisCompte => 'Créer la fiche de…';

  @override
  String get effacerDate => 'Effacer la date';

  @override
  String get exporterCsv => 'Exporter (tableur CSV)';

  @override
  String familleDe(String nom) {
    return 'Famille $nom';
  }

  @override
  String get familleVide => 'Personne dans cette famille pour le moment.';

  @override
  String get familles => 'Familles';

  @override
  String get ficheMembre => 'Fiche';

  @override
  String get fichierMembres => 'Fichier des membres';

  @override
  String get fichierMembresSousTitre =>
      'Membres, familles, coordonnées, services';

  @override
  String get nomFamilleChamp => 'Nom de la famille';

  @override
  String nombreFiches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n fiches',
      one: '1 fiche',
      zero: 'Aucune fiche',
    );
    return '$_temp0';
  }

  @override
  String nombrePersonnesFamille(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personnes',
      one: '1 personne',
      zero: 'Aucune personne',
    );
    return '$_temp0';
  }

  @override
  String get notesAide =>
      'Notes (visibles seulement par le secrétariat et les pasteurs)';

  @override
  String get nouvelleFamille => 'Nouvelle famille';

  @override
  String get nouvelleFiche => 'Nouvelle fiche';

  @override
  String get rechercherMembre => 'Rechercher (nom, téléphone, localité…)';

  @override
  String get renommer => 'Renommer';

  @override
  String get responsablesActuels => 'Responsables actuels';

  @override
  String get retirerDeLaFamille => 'Retirer de la famille';

  @override
  String get supprimerFamille => 'Supprimer cette famille ?';

  @override
  String get supprimerFamilleAide =>
      'Les fiches des personnes sont conservées.';

  @override
  String get supprimerFiche => 'Supprimer cette fiche ?';

  @override
  String get supprimerFicheAide =>
      'Le compte de l\'app de la personne n\'est pas supprimé.';

  @override
  String get vieDEglise => 'Vie d\'église';

  @override
  String get statutVisiteur => 'Visiteur';

  @override
  String get statutMembre => 'Membre';

  @override
  String get statutActif => 'Membre actif';

  @override
  String get adminGroupe => 'Administrateur du groupe';

  @override
  String get adminsGroupe => 'Administrateurs du groupe';

  @override
  String get adminsGroupeAide =>
      'Ils ajoutent et retirent les membres. Choisissez au moins une personne.';

  @override
  String get ajouterMembres => 'Ajouter';

  @override
  String ajouterNombre(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ajouter $n personnes',
      one: 'Ajouter 1 personne',
      zero: 'Ajouter',
    );
    return '$_temp0';
  }

  @override
  String get aucunGroupe => 'Vous ne faites encore partie d\'aucun groupe.';

  @override
  String get aucunGroupeEglise => 'Aucun groupe pour le moment.';

  @override
  String get aucunMessageGroupe => 'Aucun message. Écrivez le premier !';

  @override
  String get autresGroupes => 'Groupes ouverts';

  @override
  String get autresGroupesAide =>
      'Pour en faire partie, demandez à un administrateur du groupe.';

  @override
  String get choisirAdminGroupe => 'Choisissez au moins un administrateur.';

  @override
  String get compteInconnu => 'Compte supprimé';

  @override
  String get discussion => 'Discussion';

  @override
  String get ecrireMessage => 'Écrire un message…';

  @override
  String get effacerMessage => 'Effacer ce message ?';

  @override
  String get envoiEchoue => 'L\'envoi a échoué. Vérifiez votre connexion.';

  @override
  String get envoyerMessage => 'Envoyer';

  @override
  String get envoyerPhoto => 'Envoyer une photo';

  @override
  String get groupeIndisponible => 'Ce groupe n\'est pas accessible.';

  @override
  String get groupeOuvert => 'Groupe ouvert';

  @override
  String get groupePrive => 'Groupe privé';

  @override
  String get groupePriveAide =>
      'Seuls ses membres le voient. Sinon, tous les membres de l\'église le voient (sans la discussion).';

  @override
  String get lienAppel => 'Lien d\'appel (Meet, Zoom, WhatsApp…)';

  @override
  String get lienAppelAide =>
      'Facultatif. Adresse commençant par https:// ; un bouton « Rejoindre l\'appel » l\'ouvrira.';

  @override
  String get lienInvalide => 'Le lien doit commencer par https://';

  @override
  String get mesGroupes => 'Mes groupes';

  @override
  String get modifierGroupe => 'Modifier le groupe';

  @override
  String get nomGroupe => 'Nom du groupe';

  @override
  String nombreMembres(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n membres',
      one: '1 membre',
      zero: 'Aucun membre',
    );
    return '$_temp0';
  }

  @override
  String get nommerAdmin => 'Nommer administrateur';

  @override
  String get nouveau => 'Nouveau';

  @override
  String get nouveauGroupe => 'Nouveau groupe';

  @override
  String get options => 'Options';

  @override
  String get personneATrouver => 'Personne à ajouter.';

  @override
  String get photo => 'Photo';

  @override
  String get quitterGroupe => 'Quitter le groupe';

  @override
  String get quitterGroupeQuestion => 'Quitter ce groupe ?';

  @override
  String get rechercherPersonne => 'Rechercher une personne';

  @override
  String get rejoindreAppel => 'Rejoindre l\'appel';

  @override
  String rejoindreGroupeAide(String admins) {
    return 'Pour rejoindre ce groupe, demandez à : $admins.';
  }

  @override
  String get retirerAdmin => 'Retirer le rôle d\'administrateur';

  @override
  String get retirerDuGroupe => 'Retirer du groupe';

  @override
  String retirerDuGroupeQuestion(String nom) {
    return 'Retirer $nom du groupe ?';
  }

  @override
  String get supprimerGroupe => 'Supprimer ce groupe ?';

  @override
  String get supprimerGroupeAide =>
      'Le groupe disparaît pour tous ses membres.';

  @override
  String get tousLesGroupes => 'Groupes de l\'église';

  @override
  String get tousLesGroupesSousTitre =>
      'Créer les groupes et nommer leurs administrateurs';

  @override
  String get groupeCellule => 'Cellule de maison';

  @override
  String get groupeIntercession => 'Intercession';

  @override
  String get groupeJeunes => 'Jeunes';

  @override
  String get groupeFemmes => 'Femmes';

  @override
  String get groupeHommes => 'Hommes';

  @override
  String get groupeLouange => 'Louange';

  @override
  String get groupeModeration => 'Modération';

  @override
  String get groupeMedia => 'Équipe média';

  @override
  String get groupeEntraide => 'Entraide';

  @override
  String get groupeAutre => 'Autre';

  @override
  String get ajouterChant => 'Ajouter un chant';

  @override
  String get ajouterRendezVous => 'Ajouter un rendez-vous';

  @override
  String get appelAvecLien =>
      'Le bouton « Rejoindre l\'appel » ouvrira le lien du groupe. L\'appel directement dans l\'app arrivera bientôt.';

  @override
  String get appelSansLien =>
      'Ajoutez un lien d\'appel au groupe (✏️ sur la page du groupe) pour que les membres puissent le rejoindre.';

  @override
  String get aucunModerateur => 'Pas encore de modérateur';

  @override
  String get aucunRendezVous => 'Aucun rendez-vous prévu.';

  @override
  String get calendrier => 'Calendrier';

  @override
  String calendrierDe(String nom) {
    return 'Calendrier · $nom';
  }

  @override
  String chantNumero(int n) {
    return 'Chant $n';
  }

  @override
  String get chantsAPreparer => 'Chants à préparer';

  @override
  String get demanderRemplacant =>
      'Je ne suis pas disponible : demander un remplaçant';

  @override
  String get deroule => 'Déroulé du culte';

  @override
  String get derouleAide => 'Une étape par ligne.';

  @override
  String get finalementDisponible => 'Finalement, je suis disponible';

  @override
  String get instrumentAide => 'Instrument ou voix (vide s\'il ne joue pas)';

  @override
  String get jeRemplace => 'Je remplace';

  @override
  String get lienChant => 'Lien audio, partition ou paroles (facultatif)';

  @override
  String get maReponse => 'Ma réponse';

  @override
  String get moderateur => 'Modérateur';

  @override
  String moderePar(String nom) {
    return 'Modéré par $nom';
  }

  @override
  String get modifier => 'Modifier';

  @override
  String get modifierRendezVous => 'Modifier le rendez-vous';

  @override
  String get ouvrirLien => 'Ouvrir le lien';

  @override
  String get presences => 'Présences';

  @override
  String get quiJoueQuoi => 'Qui joue quoi';

  @override
  String remplacantRecherche(String nom) {
    return '$nom cherche un remplaçant';
  }

  @override
  String get remplacementDemande => 'Un remplaçant est recherché.';

  @override
  String get rendezVousIndisponible => 'Ce rendez-vous n\'est plus disponible.';

  @override
  String get retirer => 'Retirer';

  @override
  String get supprimerRendezVous => 'Supprimer ce rendez-vous ?';

  @override
  String get titreCulteDimanche => 'Culte du dimanche';

  @override
  String get rencontreReunion => 'Réunion';

  @override
  String get rencontreRepetition => 'Répétition';

  @override
  String get rencontreModeration => 'Modération';

  @override
  String get rencontreAppel => 'Appel de groupe';

  @override
  String get reponseOui => 'Je viens';

  @override
  String get reponseNon => 'Je ne viens pas';

  @override
  String get reponsePeutEtre => 'Peut-être';

  @override
  String get aTraiter => 'À traiter';

  @override
  String annonceePar(String nom) {
    return 'Annoncé par $nom';
  }

  @override
  String get annoncer => 'Annoncer';

  @override
  String get annoncerExaucement => 'Ma prière est exaucée !';

  @override
  String get annoncerFete => 'Annoncer';

  @override
  String get anonyme => 'Anonyme';

  @override
  String get aucunSujetPartage =>
      'Aucun sujet de prière partagé pour le moment.';

  @override
  String get aucunSujetPriere => 'Aucun sujet de prière.';

  @override
  String get aucuneDemande =>
      'Aucune demande. Touchez « Nouvelle demande » pour en faire une.';

  @override
  String get aucuneDemandeATraiter => 'Aucune demande à traiter.';

  @override
  String get aucuneFete =>
      'Rien d\'annoncé pour le moment. Touchez « Annoncer » pour un anniversaire ou une fête.';

  @override
  String get chaineYoutube => 'Chaîne YouTube';

  @override
  String get choisirTypeDemande => 'Choisissez le type de demande.';

  @override
  String get confierPriere => 'Sujet de prière';

  @override
  String get confierSujet => 'Confier ce sujet';

  @override
  String get cuisineInformee => 'C\'est noté, la cuisine est informée. Merci !';

  @override
  String get cultesEtEvenements => 'Cultes et événements';

  @override
  String get dateEtHeure => 'Date et heure';

  @override
  String get demande => 'Demande';

  @override
  String get demandeEnvoyee =>
      'Demande envoyée. Vous serez prévenu de la réponse.';

  @override
  String get demandeIndisponible => 'Cette demande n\'est plus disponible.';

  @override
  String get demandesRecues => 'Demandes';

  @override
  String get demandesRecuesSousTitre =>
      'Baptêmes, mariages, rendez-vous, visites';

  @override
  String get divers => 'Divers';

  @override
  String get diversConnexion =>
      'Connectez-vous pour voir les anniversaires et les fêtes de l\'église.';

  @override
  String get enregistrerEtPrevenir => 'Enregistrer et prévenir la personne';

  @override
  String get envoyerDemande => 'Envoyer la demande';

  @override
  String get exaucee => 'Exaucée';

  @override
  String get faireDemande => 'Faire une demande';

  @override
  String get feteIndisponible => 'Cette annonce n\'est plus disponible.';

  @override
  String get gloireADieu => 'Gloire à Dieu !';

  @override
  String get groupeCuisineAide =>
      'Ses membres voient ce que chacun apporte aux fêtes (rubrique Divers) et en sont prévenus. Créez d\'abord un groupe de type « Cuisine ».';

  @override
  String get groupeCuisineChamp => 'Groupe des responsables cuisine';

  @override
  String get groupeIntercessionAide =>
      'Il reçoit les sujets de prière que les membres choisissent de partager. Créez d\'abord un groupe de type « Intercession ».';

  @override
  String get groupeIntercessionChamp => 'Groupe d\'intercession de l\'église';

  @override
  String get informerCuisine => 'Informer la cuisine';

  @override
  String get jaiPrie => 'J\'ai prié';

  @override
  String get japporte => 'J\'apporte…';

  @override
  String get japporteAide => 'Pour informer les responsables cuisine.';

  @override
  String get mesDemandes => 'Mes demandes';

  @override
  String get mesDemandesSousTitre =>
      'Baptême, mariage, rendez-vous avec un pasteur…';

  @override
  String get mesSujetsPriere => 'Mes sujets de prière';

  @override
  String get messageDemandeAide =>
      'Par exemple : vos disponibilités, votre numéro de téléphone, la date envisagée.';

  @override
  String get messageFacultatif => 'Message (facultatif)';

  @override
  String get modifierTemoignage => 'Modifier mon témoignage';

  @override
  String nombrePrieres(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personnes ont prié',
      one: '1 personne a prié',
      zero: 'Personne n\'a encore prié',
    );
    return '$_temp0';
  }

  @override
  String get nouveauSujet => 'Nouveau sujet de prière';

  @override
  String get nouvelleDemande => 'Nouvelle demande';

  @override
  String get pageFacebook => 'Page Facebook';

  @override
  String get parametresEglise => 'Paramètres de l\'église';

  @override
  String get parametresEgliseSousTitre =>
      'Intercession, cuisine, Facebook, YouTube';

  @override
  String get partageIntercession => 'Aussi l\'équipe d\'intercession';

  @override
  String get partageIntercessionAide =>
      'Les membres du groupe d\'intercession prient avec vous.';

  @override
  String get partagePasteurs => 'Les pasteurs seulement';

  @override
  String get partagePasteursAide => 'Confidentiel.';

  @override
  String get pasDeGroupeIntercession =>
      'Pas encore de groupe d\'intercession désigné par l\'église.';

  @override
  String get personneNApporte => 'Personne n\'a encore rien indiqué.';

  @override
  String get pourLaCuisine => 'Pour la cuisine';

  @override
  String get precisionApport =>
      'Précision (facultatif) : « un gâteau au chocolat », « 2 bouteilles de jus »…';

  @override
  String get priereExaucee => 'Prière exaucée';

  @override
  String get quiPeutLeLire => 'Qui peut le lire ?';

  @override
  String get reponseALaPersonne => 'Réponse à la personne';

  @override
  String get reponseAide =>
      'Visible par la personne dans l\'app ; elle est prévenue par notification.';

  @override
  String get reponseEglise => 'Réponse de l\'église';

  @override
  String get resterAnonyme => 'Rester anonyme';

  @override
  String get resterAnonymeAide =>
      'L\'équipe d\'intercession ne verra pas votre nom (les pasteurs, oui).';

  @override
  String get retirerDemande => 'Retirer ma demande';

  @override
  String get suivreFacebook => 'Facebook';

  @override
  String get suivreYoutube => 'YouTube';

  @override
  String get sujetConfie =>
      'Votre sujet de prière est confié. Nous prions avec vous.';

  @override
  String get sujetIndisponible => 'Ce sujet de prière n\'est pas accessible.';

  @override
  String get sujetPriere => 'Sujet de prière';

  @override
  String get sujetPriereChamp => 'Pour quoi voulez-vous que l\'on prie ?';

  @override
  String get sujetsPriere => 'Sujets de prière';

  @override
  String get sujetsPriereSousTitre => 'Tous les sujets confiés (pasteurs)';

  @override
  String get supprimerFete => 'Supprimer cette annonce ?';

  @override
  String get supprimerSujet => 'Supprimer ce sujet de prière ?';

  @override
  String get temoignageFacultatif => 'Votre témoignage (facultatif)';

  @override
  String get titreFeteAide => 'Ex. : Anniversaire de Maman Esther';

  @override
  String get toutes => 'Toutes';

  @override
  String get typeDemandeQuestion => 'Que souhaitez-vous demander ?';

  @override
  String get vousAvezPrie => 'Vous avez prié. Merci !';

  @override
  String get demandeBapteme => 'Baptême';

  @override
  String get demandePresentation => 'Présentation d\'enfant';

  @override
  String get demandeMariage => 'Mariage';

  @override
  String get demandeRendezVous => 'Rendez-vous avec un pasteur';

  @override
  String get demandeVisite => 'Visite à domicile';

  @override
  String get statutNouvelle => 'Envoyée';

  @override
  String get statutEnCours => 'En cours';

  @override
  String get statutAcceptee => 'Acceptée';

  @override
  String get statutRefusee => 'Refusée';

  @override
  String get statutTerminee => 'Terminée';

  @override
  String get feteAnniversaire => 'Anniversaire';

  @override
  String get feteNaissance => 'Naissance';

  @override
  String get feteMariage => 'Mariage';

  @override
  String get feteFete => 'Fête';

  @override
  String get feteAutre => 'Autre';

  @override
  String get apportNourriture => 'Nourriture';

  @override
  String get apportGateau => 'Gâteau';

  @override
  String get apportBoisson => 'Boissons';

  @override
  String get apportAutre => 'Autre';

  @override
  String get groupeCuisine => 'Cuisine';

  @override
  String get erreurLecture =>
      'Impossible de lire ce fichier. Vérifiez votre connexion.';

  @override
  String get reculer15 => 'Reculer de 15 secondes';

  @override
  String get avancer15 => 'Avancer de 15 secondes';

  @override
  String get pause => 'Pause';

  @override
  String get lecture => 'Lecture';

  @override
  String get vitesse => 'Vitesse de lecture';

  @override
  String get pleinEcran => 'Plein écran';

  @override
  String get ajouterLecon => 'Ajouter une leçon';

  @override
  String get aucunCandidat => 'Aucun candidat inscrit.';

  @override
  String get aucunFichier => 'Aucun fichier';

  @override
  String get aucuneLecon => 'Pas encore de leçon.';

  @override
  String get aucunePreparation => 'Aucune préparation pour le moment.';

  @override
  String get aucunePreparationType =>
      'Créez d\'abord une préparation de ce type (Accueil → Préparations).';

  @override
  String get aucuneQuestion => 'Aucune question.';

  @override
  String get aucuneRencontre => 'Aucune rencontre planifiée.';

  @override
  String candidatInscrit(String nom) {
    return '$nom est inscrit à la préparation.';
  }

  @override
  String get candidats => 'Candidats';

  @override
  String get choisirFichier => 'Choisir un fichier';

  @override
  String get descendre => 'Descendre';

  @override
  String get desinscrire => 'Désinscrire';

  @override
  String get enAttenteReponse => 'En attente de la réponse du pasteur.';

  @override
  String get fichierAudio => 'Audio';

  @override
  String get fichierDocument => 'Document (PDF)';

  @override
  String get fichierEnvoye => 'Fichier envoyé';

  @override
  String get fichierVideo => 'Vidéo';

  @override
  String get inscrire => 'Inscrire';

  @override
  String get inscrireCandidat => 'Inscrire un candidat';

  @override
  String get inscrirePreparation => 'Inscrire à une préparation';

  @override
  String get lecon => 'Leçon';

  @override
  String get leconPublique => 'Leçon publique';

  @override
  String get leconPubliqueAide =>
      'Visible par tous les membres. Sinon, seulement par les candidats inscrits.';

  @override
  String get leconReservee =>
      'Cette leçon est réservée aux candidats inscrits.';

  @override
  String get leconTerminee => 'Leçon terminée';

  @override
  String get lecons => 'Leçons';

  @override
  String get marquerTerminee => 'J\'ai terminé cette leçon';

  @override
  String get mesQuestions => 'Mes questions au pasteur';

  @override
  String get mesRencontres => 'Mes rencontres';

  @override
  String get monter => 'Monter';

  @override
  String get nouvellePreparation => 'Nouvelle préparation';

  @override
  String get ouvrirDocument => 'Ouvrir le document';

  @override
  String get pasInscritPreparation =>
      'Les leçons sont réservées aux candidats. Faites une demande : le pasteur vous inscrira.';

  @override
  String get planifier => 'Planifier';

  @override
  String get poserQuestion => 'Poser une question au pasteur';

  @override
  String get preparationIndisponible =>
      'Cette préparation n\'est pas accessible.';

  @override
  String get preparations => 'Préparations';

  @override
  String get preparationsGestionSousTitre => 'Leçons, candidats, entretiens';

  @override
  String get preparationsIntro =>
      'Préparations au mariage et au baptême : leçons en texte, audio et vidéo.';

  @override
  String get preparationsSousTitre => 'Mariage et baptême';

  @override
  String progression(int faites, int total) {
    return '$faites leçon(s) terminée(s) sur $total';
  }

  @override
  String get publierPreparationAide =>
      'Visible par les membres (les leçons restent réservées aux candidats).';

  @override
  String get publique => 'publique';

  @override
  String get questionEnvoyee => 'Question envoyée au pasteur.';

  @override
  String get questions => 'Questions';

  @override
  String get remplacerFichier => 'Remplacer le fichier';

  @override
  String get rencontreAide => 'Ex. : Entretien, Baptême, Répétition du mariage';

  @override
  String get rencontres => 'Rencontres';

  @override
  String get repondre => 'Répondre';

  @override
  String get reponseEnvoyee => 'Réponse envoyée.';

  @override
  String get supprimerLecon => 'Supprimer cette leçon ?';

  @override
  String get voirPreparations => 'Voir les préparations';

  @override
  String get votreQuestion => 'Votre question';

  @override
  String get votreReponse => 'Votre réponse';

  @override
  String get vousEtesInscrit => 'Vous êtes inscrit';

  @override
  String get ajouterAdmin => 'Ajouter un administrateur';

  @override
  String get ajouterAuPlanning => 'Ajouter au planning';

  @override
  String get aucunService => 'Aucun service prévu pour vous.';

  @override
  String get aucuneEquipe =>
      'Vous ne faites partie d\'aucune équipe de service.';

  @override
  String get autresEquipes => 'Autres équipes';

  @override
  String get choisirCulte => 'Choisir un culte ou un événement de l\'agenda';

  @override
  String get choisirPersonne => 'Choisissez la personne.';

  @override
  String get cultOuEvenement => 'Culte ou événement';

  @override
  String get demanderRemplacantService => 'Demander un remplaçant';

  @override
  String get demanderRemplacantServiceAide =>
      'Les autres membres de l\'équipe sont prévenus.';

  @override
  String get equipeIndisponible => 'Cette équipe n\'existe plus.';

  @override
  String get jeConfirme => 'Je confirme, je serai là';

  @override
  String get jeNeSuisPasDisponible => 'Je ne suis pas disponible';

  @override
  String get jeNeSuisPasDisponibleAide =>
      'Le responsable de l\'équipe est prévenu.';

  @override
  String get membresEtResponsables => 'Membres et responsables';

  @override
  String get membresEtResponsablesAide =>
      'Cochez les membres ; « Responsable » : fait le planning de l\'équipe.';

  @override
  String get mesEquipes => 'Mes équipes';

  @override
  String get mesServices => 'Mes services à venir';

  @override
  String get nomEquipe => 'Nom de l\'équipe';

  @override
  String get nomEquipeAide => 'Ex. : Sono et vidéo, Accueil, École du dimanche';

  @override
  String get nouvelleEquipe => 'Nouvelle équipe';

  @override
  String get planning => 'Planning des services';

  @override
  String get planningServices => 'Planning des services';

  @override
  String get planningServicesSousTitre => 'Équipes, qui sert à quel culte';

  @override
  String get planningSousTitre => 'Mes services et mes équipes';

  @override
  String get planningVide => 'Rien de prévu pour le moment.';

  @override
  String get poste => 'Poste (facultatif)';

  @override
  String get posteAide => 'Ex. : Table de mixage, Accueil à la porte';

  @override
  String get quiSert => 'Qui sert ?';

  @override
  String remplaceNom(String nom) {
    return 'Remplace $nom';
  }

  @override
  String get repondreService => 'Confirmer ou se désister';

  @override
  String get responsable => 'Responsable';

  @override
  String get responsableEquipe => 'Responsable de l\'équipe';

  @override
  String get retirerDeLEquipe => 'Retirer de l\'équipe';

  @override
  String get supprimerEquipe => 'Supprimer cette équipe et son planning ?';

  @override
  String get servicePrevu => 'Prévu (à confirmer)';

  @override
  String get serviceConfirme => 'Confirmé';

  @override
  String get serviceIndisponible => 'Indisponible';

  @override
  String get serviceRemplacement => 'Remplaçant recherché';

  @override
  String get exhortations => 'Exhortations';

  @override
  String get exhortation => 'Exhortation';

  @override
  String get ajouterExhortation => 'Ajouter une exhortation';

  @override
  String get aucuneExhortation => 'Pas encore d\'exhortation.';

  @override
  String get entretienSalle => 'Entretien de la salle';

  @override
  String get entretienSousTitre => 'Inscrivez-vous pour le nettoyage';

  @override
  String get entretienIntro =>
      'Aidez à garder notre salle propre : inscrivez-vous à une séance de nettoyage.';

  @override
  String get nouvelleSeanceNettoyage => 'Nouvelle séance';

  @override
  String get aucuneSeanceNettoyage => 'Aucune séance de nettoyage prévue.';

  @override
  String inscritsNettoyage(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personnes inscrites',
      one: '1 personne inscrite',
      zero: 'Personne d\'inscrit',
    );
    return '$_temp0';
  }

  @override
  String inscritsNettoyageSur(int n, int max) {
    return '$n inscrit(s) sur $max souhaité(s)';
  }

  @override
  String get jeViensNettoyer => 'Je viens aider';

  @override
  String get inscritAnnuler => 'Inscrit — annuler';

  @override
  String get titreNettoyageDefaut => 'Nettoyage de la salle';

  @override
  String get personnesSouhaitees => 'Nombre de personnes souhaitées';

  @override
  String get reserverSalle => 'Réserver une salle';

  @override
  String get reserverSalleSousTitre => 'Voir les créneaux libres et demander';

  @override
  String get sallesEtReservations => 'Salles et réservations';

  @override
  String get sallesEtReservationsSousTitre =>
      'Valider les demandes, gérer les salles';

  @override
  String get nouvelleSalle => 'Nouvelle salle';

  @override
  String get salles => 'Salles';

  @override
  String get aucuneSalle => 'Aucune salle enregistrée.';

  @override
  String get nomSalle => 'Nom de la salle';

  @override
  String get capacite => 'Capacité (personnes)';

  @override
  String capacitePersonnes(int n) {
    return '$n personnes';
  }

  @override
  String get mesReservations => 'Mes réservations';

  @override
  String get aucuneReservation => 'Aucune réservation à venir.';

  @override
  String get annulerReservation => 'Annuler la réservation';

  @override
  String get reservationsAValider => 'Réservations à valider';

  @override
  String get aucuneReservationAValider => 'Aucune demande de réservation.';

  @override
  String get reservationDemandee => 'En attente de validation';

  @override
  String get reservationValidee => 'Validée';

  @override
  String get reservationRefusee => 'Refusée';

  @override
  String get reservationAnnulee => 'Annulée';

  @override
  String get salleIndisponible => 'Cette salle n\'existe plus.';

  @override
  String get creneauxReserves => 'Déjà réservé';

  @override
  String get aucunCreneauReserve =>
      'Aucune réservation à venir : la salle est libre.';

  @override
  String get demanderReservation => 'Demander une réservation';

  @override
  String get motifReservation => 'Pour quoi ?';

  @override
  String get motifReservationAide => 'Ex. : Répétition de la chorale';

  @override
  String get motifObligatoire => 'Indiquez pour quoi vous réservez.';

  @override
  String get creneauDejaPris => 'Ce créneau est déjà réservé.';

  @override
  String creneauDejaPrisPar(String motifs) {
    return 'Déjà réservé : $motifs';
  }

  @override
  String get envoyerDemandeReservation => 'Envoyer la demande';

  @override
  String get reservationEnvoyee => 'Demande envoyée au secrétariat.';

  @override
  String demandeePar(String nom) {
    return 'Demandée par $nom';
  }

  @override
  String conflitAvec(String autres) {
    return 'Conflit avec : $autres';
  }

  @override
  String get refuser => 'Refuser';

  @override
  String get versetDuJour => 'Verset du jour';

  @override
  String get direct => 'Direct';

  @override
  String get enDirectMaintenant => 'En direct maintenant';

  @override
  String get regarderDirect => 'Regarder le direct';

  @override
  String get audios => 'Audios';

  @override
  String get videos => 'Vidéos';

  @override
  String get aucunMedia => 'Aucune prédication pour le moment.';

  @override
  String get mediaIndisponible => 'Ce média n\'est pas disponible.';

  @override
  String get regarderSurYoutube => 'Regarder';

  @override
  String get envoyerSurWhatsApp => 'Envoyer sur WhatsApp';

  @override
  String get gestionMedias => 'Médias';

  @override
  String get gestionMediasSousTitre =>
      'Prédications, exhortations, directs, versets';

  @override
  String get predicationsEtDirects => 'Prédications et directs';

  @override
  String get versetsDuJour => 'Versets du jour';

  @override
  String get nouveauMedia => 'Nouveau média';

  @override
  String get versetsAide => 'Un verset par jour, dans cet ordre, en boucle.';

  @override
  String get aucunVerset => 'Aucun verset. Ajoutez-en quelques-uns.';

  @override
  String get ajouterVerset => 'Ajouter un verset';

  @override
  String get referenceBiblique => 'Référence';

  @override
  String get audio => 'Audio';

  @override
  String get video => 'Vidéo';

  @override
  String get predicateur => 'Prédicateur';

  @override
  String get debutDirect => 'Début du direct';

  @override
  String get lienDirect => 'Lien du direct (YouTube ou Facebook)';

  @override
  String get ouLienYoutube => 'Ou lien YouTube / Facebook (facultatif)';

  @override
  String get fichierOuLienRequis => 'Envoyez un fichier ou indiquez un lien.';
}
