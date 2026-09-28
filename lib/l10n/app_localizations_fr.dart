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
}
