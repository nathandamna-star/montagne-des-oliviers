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
}
