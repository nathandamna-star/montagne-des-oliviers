import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Montagne des Oliviers'**
  String get appTitle;

  /// No description provided for @nomEglise.
  ///
  /// In fr, this message translates to:
  /// **'Centre Évangélique Montagne des Oliviers'**
  String get nomEglise;

  /// No description provided for @navAccueil.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navAccueil;

  /// No description provided for @navAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda'**
  String get navAgenda;

  /// No description provided for @navGroupes.
  ///
  /// In fr, this message translates to:
  /// **'Groupes'**
  String get navGroupes;

  /// No description provided for @navMedias.
  ///
  /// In fr, this message translates to:
  /// **'Médias'**
  String get navMedias;

  /// No description provided for @navProfil.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfil;

  /// No description provided for @navResponsables.
  ///
  /// In fr, this message translates to:
  /// **'Responsables'**
  String get navResponsables;

  /// No description provided for @bientot.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get bientot;

  /// No description provided for @accueilBienvenue.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans la famille de la Montagne des Oliviers.'**
  String get accueilBienvenue;

  /// No description provided for @accueilAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : le verset du jour, les annonces de l\'église, le prochain culte et le direct.'**
  String get accueilAVenir;

  /// No description provided for @agendaAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : les cultes, les réunions de prière, les cellules de maison et tous les événements, avec inscription.'**
  String get agendaAVenir;

  /// No description provided for @groupesAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : vos cellules de maison, les jeunes, la louange, l\'entraide… avec une discussion privée par groupe.'**
  String get groupesAVenir;

  /// No description provided for @mediasAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : les prédications et exhortations en audio et en vidéo, le direct du culte et le verset du jour.'**
  String get mediasAVenir;

  /// No description provided for @profilAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : votre compte, vos demandes, vos sujets de prière, vos dons et la langue de l\'application.'**
  String get profilAVenir;

  /// No description provided for @responsablesAVenir.
  ///
  /// In fr, this message translates to:
  /// **'Ici : le fichier des membres, les dons, les plannings des services et la réservation des salles.'**
  String get responsablesAVenir;

  /// No description provided for @seConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get seConnecter;

  /// No description provided for @seDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get seDeconnecter;

  /// No description provided for @creerCompte.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get creerCompte;

  /// No description provided for @connexionIntro.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour rejoindre vos groupes, vous inscrire aux activités et faire vos demandes.'**
  String get connexionIntro;

  /// No description provided for @continuerGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continuerGoogle;

  /// No description provided for @continuerApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continuerApple;

  /// No description provided for @continuerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec un e-mail'**
  String get continuerEmail;

  /// No description provided for @continuerSansCompte.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans compte'**
  String get continuerSansCompte;

  /// No description provided for @bienvenueFamille.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans la famille !'**
  String get bienvenueFamille;

  /// No description provided for @completerProfilIntro.
  ///
  /// In fr, this message translates to:
  /// **'Encore une étape : indiquez votre nom et acceptez l\'utilisation de vos données.'**
  String get completerProfilIntro;

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @valider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get valider;

  /// No description provided for @enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enregistrer;

  /// No description provided for @chargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get chargement;

  /// No description provided for @champNom.
  ///
  /// In fr, this message translates to:
  /// **'Prénom et nom'**
  String get champNom;

  /// No description provided for @champEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get champEmail;

  /// No description provided for @champMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get champMotDePasse;

  /// No description provided for @afficherMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get afficherMotDePasse;

  /// No description provided for @masquerMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get masquerMotDePasse;

  /// No description provided for @motDePasseOublie.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get motDePasseOublie;

  /// No description provided for @emailReinitialisationEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail pour choisir un nouveau mot de passe a été envoyé à {email}.'**
  String emailReinitialisationEnvoye(String email);

  /// No description provided for @validationNomRequis.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom.'**
  String get validationNomRequis;

  /// No description provided for @validationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez une adresse e-mail valide.'**
  String get validationEmail;

  /// No description provided for @validationMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères.'**
  String get validationMotDePasse;

  /// No description provided for @consentementTexte.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte que l\'église enregistre mes données (nom, e-mail, groupes, demandes et sujets de prière, qui peuvent révéler mes convictions religieuses) pour la vie de la communauté. Je peux supprimer mon compte à tout moment.'**
  String get consentementTexte;

  /// No description provided for @consentementRequis.
  ///
  /// In fr, this message translates to:
  /// **'Cochez la case pour continuer.'**
  String get consentementRequis;

  /// No description provided for @connexionRequiseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connexion nécessaire'**
  String get connexionRequiseTitre;

  /// No description provided for @connexionRequiseTexte.
  ///
  /// In fr, this message translates to:
  /// **'Cette partie est réservée aux membres connectés.'**
  String get connexionRequiseTexte;

  /// No description provided for @groupesConnexionTexte.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour retrouver vos groupes et leurs discussions.'**
  String get groupesConnexionTexte;

  /// No description provided for @profilConnexionTexte.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour voir votre compte, vos demandes et vos dons.'**
  String get profilConnexionTexte;

  /// No description provided for @accueilConnexionTexte.
  ///
  /// In fr, this message translates to:
  /// **'Vous faites partie de l\'église ? Connectez-vous pour tout retrouver.'**
  String get accueilConnexionTexte;

  /// No description provided for @bonjourNom.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}'**
  String bonjourNom(String nom);

  /// No description provided for @activerAdminTitre.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'administration ?'**
  String get activerAdminTitre;

  /// No description provided for @activerAdminTexte.
  ///
  /// In fr, this message translates to:
  /// **'Seul le compte désigné lors de l\'installation peut devenir administrateur.'**
  String get activerAdminTexte;

  /// No description provided for @adminActive.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes maintenant administrateur.'**
  String get adminActive;

  /// No description provided for @adminRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte ne peut pas devenir administrateur.'**
  String get adminRefuse;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleSecretariat.
  ///
  /// In fr, this message translates to:
  /// **'Secrétariat'**
  String get roleSecretariat;

  /// No description provided for @roleTresorier.
  ///
  /// In fr, this message translates to:
  /// **'Trésorier'**
  String get roleTresorier;

  /// No description provided for @roleAdminAide.
  ///
  /// In fr, this message translates to:
  /// **'Tout gérer, y compris les rôles.'**
  String get roleAdminAide;

  /// No description provided for @roleSecretariatAide.
  ///
  /// In fr, this message translates to:
  /// **'Membres, agenda, annonces, demandes.'**
  String get roleSecretariatAide;

  /// No description provided for @roleTresorierAide.
  ///
  /// In fr, this message translates to:
  /// **'Dons et relevés annuels.'**
  String get roleTresorierAide;

  /// No description provided for @rolesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Rôles des responsables'**
  String get rolesTitre;

  /// No description provided for @rolesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Donner ou retirer un accès'**
  String get rolesSousTitre;

  /// No description provided for @rolesAide.
  ///
  /// In fr, this message translates to:
  /// **'La personne doit d\'abord avoir créé son compte. Décochez tout pour retirer ses accès.'**
  String get rolesAide;

  /// No description provided for @rolesEnregistres.
  ///
  /// In fr, this message translates to:
  /// **'Rôles enregistrés pour {email}.'**
  String rolesEnregistres(String email);

  /// No description provided for @rolesCompteIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte avec cette adresse. La personne doit d\'abord s\'inscrire.'**
  String get rolesCompteIntrouvable;

  /// No description provided for @rolesRefuse.
  ///
  /// In fr, this message translates to:
  /// **'Seul un administrateur peut changer les rôles.'**
  String get rolesRefuse;

  /// No description provided for @erreurEmailInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail n\'est pas valide.'**
  String get erreurEmailInvalide;

  /// No description provided for @erreurMotDePasseFaible.
  ///
  /// In fr, this message translates to:
  /// **'Ce mot de passe est trop faible. Utilisez au moins 8 caractères.'**
  String get erreurMotDePasseFaible;

  /// No description provided for @erreurEmailDejaUtilise.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse. Connectez-vous plutôt.'**
  String get erreurEmailDejaUtilise;

  /// No description provided for @erreurIdentifiantsIncorrects.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail ou mot de passe incorrect.'**
  String get erreurIdentifiantsIncorrects;

  /// No description provided for @erreurTropDeTentatives.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques minutes.'**
  String get erreurTropDeTentatives;

  /// No description provided for @erreurReseau.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Vérifiez votre réseau et réessayez.'**
  String get erreurReseau;

  /// No description provided for @erreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get erreurInconnue;

  /// No description provided for @devise.
  ///
  /// In fr, this message translates to:
  /// **'Repentance · Délivrance · Sanctification'**
  String get devise;

  /// No description provided for @annonce.
  ///
  /// In fr, this message translates to:
  /// **'Annonce'**
  String get annonce;

  /// No description provided for @annonces.
  ///
  /// In fr, this message translates to:
  /// **'Annonces'**
  String get annonces;

  /// No description provided for @annoncesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Publier les annonces de l\'église'**
  String get annoncesSousTitre;

  /// No description provided for @annonceIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Cette annonce n\'est plus disponible.'**
  String get annonceIndisponible;

  /// No description provided for @aucuneAnnonce.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annonce pour le moment.'**
  String get aucuneAnnonce;

  /// No description provided for @aucunEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun événement prévu pour le moment.'**
  String get aucunEvenement;

  /// No description provided for @brouillon.
  ///
  /// In fr, this message translates to:
  /// **'Brouillon'**
  String get brouillon;

  /// No description provided for @champTitre.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get champTitre;

  /// No description provided for @champTexte.
  ///
  /// In fr, this message translates to:
  /// **'Texte'**
  String get champTexte;

  /// No description provided for @champDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get champDescription;

  /// No description provided for @champObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get champObligatoire;

  /// No description provided for @traductionFacultative.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif : sinon le texte français est affiché.'**
  String get traductionFacultative;

  /// No description provided for @ajouterPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get ajouterPhoto;

  /// No description provided for @changerPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get changerPhoto;

  /// No description provided for @retirerPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get retirerPhoto;

  /// No description provided for @erreurPhoto.
  ///
  /// In fr, this message translates to:
  /// **'La photo n\'a pas pu être envoyée. Réessayez.'**
  String get erreurPhoto;

  /// No description provided for @erreurChargement.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger. Vérifiez votre connexion.'**
  String get erreurChargement;

  /// No description provided for @complet.
  ///
  /// In fr, this message translates to:
  /// **'Complet'**
  String get complet;

  /// No description provided for @debut.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get debut;

  /// No description provided for @fin.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get fin;

  /// No description provided for @finAvantDebut.
  ///
  /// In fr, this message translates to:
  /// **'La fin doit être après le début.'**
  String get finAvantDebut;

  /// No description provided for @enregistre.
  ///
  /// In fr, this message translates to:
  /// **'Enregistré.'**
  String get enregistre;

  /// No description provided for @envoyerNotification.
  ///
  /// In fr, this message translates to:
  /// **'Prévenir par notification'**
  String get envoyerNotification;

  /// No description provided for @envoyerNotificationAide.
  ///
  /// In fr, this message translates to:
  /// **'Une notification est envoyée une seule fois, à la publication.'**
  String get envoyerNotificationAide;

  /// No description provided for @epinglee.
  ///
  /// In fr, this message translates to:
  /// **'Épinglée'**
  String get epinglee;

  /// No description provided for @epingler.
  ///
  /// In fr, this message translates to:
  /// **'Épingler en haut'**
  String get epingler;

  /// No description provided for @epinglerAide.
  ///
  /// In fr, this message translates to:
  /// **'Reste en tête des annonces.'**
  String get epinglerAide;

  /// No description provided for @evenement.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get evenement;

  /// No description provided for @evenementIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Cet événement n\'est plus disponible.'**
  String get evenementIndisponible;

  /// No description provided for @gestionAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Agenda de l\'église'**
  String get gestionAgenda;

  /// No description provided for @gestionAgendaSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Cultes, réunions et événements'**
  String get gestionAgendaSousTitre;

  /// No description provided for @inscription.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get inscription;

  /// No description provided for @inscriptionConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour vous inscrire.'**
  String get inscriptionConnexion;

  /// No description provided for @inscriptionOuverte.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions ouvertes'**
  String get inscriptionOuverte;

  /// No description provided for @inscritPersonnes.
  ///
  /// In fr, this message translates to:
  /// **'Inscription confirmée ({n, plural, =1{1 personne} other{{n} personnes}}).'**
  String inscritPersonnes(int n);

  /// No description provided for @inscritsNombre.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Aucun inscrit} =1{1 inscrit} other{{n} inscrits}}'**
  String inscritsNombre(int n);

  /// No description provided for @inscritsSurPlaces.
  ///
  /// In fr, this message translates to:
  /// **'{n} inscrits sur {max} places'**
  String inscritsSurPlaces(int n, int max);

  /// No description provided for @lieu.
  ///
  /// In fr, this message translates to:
  /// **'Lieu'**
  String get lieu;

  /// No description provided for @modifierAnnonce.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'annonce'**
  String get modifierAnnonce;

  /// No description provided for @modifierEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'événement'**
  String get modifierEvenement;

  /// No description provided for @moins.
  ///
  /// In fr, this message translates to:
  /// **'Moins'**
  String get moins;

  /// No description provided for @plus.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get plus;

  /// No description provided for @nombreInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un nombre entier.'**
  String get nombreInvalide;

  /// No description provided for @nombrePersonnes.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de personnes'**
  String get nombrePersonnes;

  /// No description provided for @nouvelEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel événement'**
  String get nouvelEvenement;

  /// No description provided for @nouvelleAnnonce.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle annonce'**
  String get nouvelleAnnonce;

  /// No description provided for @placesMax.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de places'**
  String get placesMax;

  /// No description provided for @placesMaxAide.
  ///
  /// In fr, this message translates to:
  /// **'Laisser vide s\'il n\'y a pas de limite.'**
  String get placesMaxAide;

  /// No description provided for @prochainement.
  ///
  /// In fr, this message translates to:
  /// **'Prochainement'**
  String get prochainement;

  /// No description provided for @publieeLe.
  ///
  /// In fr, this message translates to:
  /// **'Publiée le {date}'**
  String publieeLe(String date);

  /// No description provided for @publier.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publier;

  /// No description provided for @publierAide.
  ///
  /// In fr, this message translates to:
  /// **'Sinon, reste en brouillon (visible seulement par les responsables).'**
  String get publierAide;

  /// No description provided for @sInscrire.
  ///
  /// In fr, this message translates to:
  /// **'Je m\'inscris'**
  String get sInscrire;

  /// No description provided for @seDesinscrire.
  ///
  /// In fr, this message translates to:
  /// **'Annuler mon inscription'**
  String get seDesinscrire;

  /// No description provided for @supprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get supprimer;

  /// No description provided for @supprimerAnnonce.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette annonce ?'**
  String get supprimerAnnonce;

  /// No description provided for @supprimerEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet événement ?'**
  String get supprimerEvenement;

  /// No description provided for @tous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tous;

  /// No description provided for @toutLAgenda.
  ///
  /// In fr, this message translates to:
  /// **'Tout l\'agenda'**
  String get toutLAgenda;

  /// No description provided for @voirTout.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get voirTout;

  /// No description provided for @typeEvenementChamp.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get typeEvenementChamp;

  /// No description provided for @visibilite.
  ///
  /// In fr, this message translates to:
  /// **'Qui peut le voir ?'**
  String get visibilite;

  /// No description provided for @visibilitePublic.
  ///
  /// In fr, this message translates to:
  /// **'Tout le monde'**
  String get visibilitePublic;

  /// No description provided for @visibiliteMembres.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get visibiliteMembres;

  /// No description provided for @typeCulte.
  ///
  /// In fr, this message translates to:
  /// **'Culte'**
  String get typeCulte;

  /// No description provided for @typePriere.
  ///
  /// In fr, this message translates to:
  /// **'Prière'**
  String get typePriere;

  /// No description provided for @typeJeune.
  ///
  /// In fr, this message translates to:
  /// **'Jeûne'**
  String get typeJeune;

  /// No description provided for @typeCellule.
  ///
  /// In fr, this message translates to:
  /// **'Cellule'**
  String get typeCellule;

  /// No description provided for @typeEvenement.
  ///
  /// In fr, this message translates to:
  /// **'Événement'**
  String get typeEvenement;

  /// No description provided for @typeConference.
  ///
  /// In fr, this message translates to:
  /// **'Conférence'**
  String get typeConference;

  /// No description provided for @ajouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get ajouter;

  /// No description provided for @ajouterALaFamille.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une personne'**
  String get ajouterALaFamille;

  /// No description provided for @aucun.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get aucun;

  /// No description provided for @aucune.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get aucune;

  /// No description provided for @aucuneFamille.
  ///
  /// In fr, this message translates to:
  /// **'Aucune famille pour le moment.'**
  String get aucuneFamille;

  /// No description provided for @aucuneFiche.
  ///
  /// In fr, this message translates to:
  /// **'Aucune fiche.'**
  String get aucuneFiche;

  /// No description provided for @autreService.
  ///
  /// In fr, this message translates to:
  /// **'Autre service'**
  String get autreService;

  /// No description provided for @champArrivee.
  ///
  /// In fr, this message translates to:
  /// **'Arrivée à l\'église'**
  String get champArrivee;

  /// No description provided for @champBapteme.
  ///
  /// In fr, this message translates to:
  /// **'Baptême'**
  String get champBapteme;

  /// No description provided for @champCodePostal.
  ///
  /// In fr, this message translates to:
  /// **'Code postal'**
  String get champCodePostal;

  /// No description provided for @champDateNaissance.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get champDateNaissance;

  /// No description provided for @champFamille.
  ///
  /// In fr, this message translates to:
  /// **'Famille'**
  String get champFamille;

  /// No description provided for @champMariage.
  ///
  /// In fr, this message translates to:
  /// **'Mariage'**
  String get champMariage;

  /// No description provided for @champNomFamille.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get champNomFamille;

  /// No description provided for @champNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get champNotes;

  /// No description provided for @champPrenom.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get champPrenom;

  /// No description provided for @champPresentation.
  ///
  /// In fr, this message translates to:
  /// **'Présentation d\'enfant'**
  String get champPresentation;

  /// No description provided for @champRue.
  ///
  /// In fr, this message translates to:
  /// **'Rue et numéro'**
  String get champRue;

  /// No description provided for @champServices.
  ///
  /// In fr, this message translates to:
  /// **'Services'**
  String get champServices;

  /// No description provided for @champStatut.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get champStatut;

  /// No description provided for @champTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get champTelephone;

  /// No description provided for @champVille.
  ///
  /// In fr, this message translates to:
  /// **'Localité'**
  String get champVille;

  /// No description provided for @compteApp.
  ///
  /// In fr, this message translates to:
  /// **'Compte de l\'application'**
  String get compteApp;

  /// No description provided for @compteLie.
  ///
  /// In fr, this message translates to:
  /// **'Compte lié'**
  String get compteLie;

  /// No description provided for @compteLieAide.
  ///
  /// In fr, this message translates to:
  /// **'La personne pourra voir sa fiche dans l\'app.'**
  String get compteLieAide;

  /// No description provided for @comptesSansFiche.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 compte de l\'app sans fiche} other{{n} comptes de l\'app sans fiche}}'**
  String comptesSansFiche(int n);

  /// No description provided for @comptesSansFicheAide.
  ///
  /// In fr, this message translates to:
  /// **'Créer leur fiche en reprenant nom et e-mail'**
  String get comptesSansFicheAide;

  /// No description provided for @coordonnees.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées'**
  String get coordonnees;

  /// No description provided for @creer.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get creer;

  /// No description provided for @creerFicheDepuisCompte.
  ///
  /// In fr, this message translates to:
  /// **'Créer la fiche de…'**
  String get creerFicheDepuisCompte;

  /// No description provided for @effacerDate.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la date'**
  String get effacerDate;

  /// No description provided for @exporterCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter (tableur CSV)'**
  String get exporterCsv;

  /// No description provided for @familleDe.
  ///
  /// In fr, this message translates to:
  /// **'Famille {nom}'**
  String familleDe(String nom);

  /// No description provided for @familleVide.
  ///
  /// In fr, this message translates to:
  /// **'Personne dans cette famille pour le moment.'**
  String get familleVide;

  /// No description provided for @familles.
  ///
  /// In fr, this message translates to:
  /// **'Familles'**
  String get familles;

  /// No description provided for @ficheMembre.
  ///
  /// In fr, this message translates to:
  /// **'Fiche'**
  String get ficheMembre;

  /// No description provided for @fichierMembres.
  ///
  /// In fr, this message translates to:
  /// **'Fichier des membres'**
  String get fichierMembres;

  /// No description provided for @fichierMembresSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Membres, familles, coordonnées, services'**
  String get fichierMembresSousTitre;

  /// No description provided for @nomFamilleChamp.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la famille'**
  String get nomFamilleChamp;

  /// No description provided for @nombreFiches.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Aucune fiche} =1{1 fiche} other{{n} fiches}}'**
  String nombreFiches(int n);

  /// No description provided for @nombrePersonnesFamille.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Aucune personne} =1{1 personne} other{{n} personnes}}'**
  String nombrePersonnesFamille(int n);

  /// No description provided for @notesAide.
  ///
  /// In fr, this message translates to:
  /// **'Notes (visibles seulement par le secrétariat et les pasteurs)'**
  String get notesAide;

  /// No description provided for @nouvelleFamille.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle famille'**
  String get nouvelleFamille;

  /// No description provided for @nouvelleFiche.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle fiche'**
  String get nouvelleFiche;

  /// No description provided for @rechercherMembre.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (nom, téléphone, localité…)'**
  String get rechercherMembre;

  /// No description provided for @renommer.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get renommer;

  /// No description provided for @responsablesActuels.
  ///
  /// In fr, this message translates to:
  /// **'Responsables actuels'**
  String get responsablesActuels;

  /// No description provided for @retirerDeLaFamille.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de la famille'**
  String get retirerDeLaFamille;

  /// No description provided for @supprimerFamille.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette famille ?'**
  String get supprimerFamille;

  /// No description provided for @supprimerFamilleAide.
  ///
  /// In fr, this message translates to:
  /// **'Les fiches des personnes sont conservées.'**
  String get supprimerFamilleAide;

  /// No description provided for @supprimerFiche.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette fiche ?'**
  String get supprimerFiche;

  /// No description provided for @supprimerFicheAide.
  ///
  /// In fr, this message translates to:
  /// **'Le compte de l\'app de la personne n\'est pas supprimé.'**
  String get supprimerFicheAide;

  /// No description provided for @vieDEglise.
  ///
  /// In fr, this message translates to:
  /// **'Vie d\'église'**
  String get vieDEglise;

  /// No description provided for @statutVisiteur.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur'**
  String get statutVisiteur;

  /// No description provided for @statutMembre.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get statutMembre;

  /// No description provided for @statutActif.
  ///
  /// In fr, this message translates to:
  /// **'Membre actif'**
  String get statutActif;

  /// No description provided for @adminGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur du groupe'**
  String get adminGroupe;

  /// No description provided for @adminsGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs du groupe'**
  String get adminsGroupe;

  /// No description provided for @adminsGroupeAide.
  ///
  /// In fr, this message translates to:
  /// **'Ils ajoutent et retirent les membres. Choisissez au moins une personne.'**
  String get adminsGroupeAide;

  /// No description provided for @ajouterMembres.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get ajouterMembres;

  /// No description provided for @ajouterNombre.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Ajouter} =1{Ajouter 1 personne} other{Ajouter {n} personnes}}'**
  String ajouterNombre(int n);

  /// No description provided for @aucunGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne faites encore partie d\'aucun groupe.'**
  String get aucunGroupe;

  /// No description provided for @aucunGroupeEglise.
  ///
  /// In fr, this message translates to:
  /// **'Aucun groupe pour le moment.'**
  String get aucunGroupeEglise;

  /// No description provided for @aucunMessageGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message. Écrivez le premier !'**
  String get aucunMessageGroupe;

  /// No description provided for @autresGroupes.
  ///
  /// In fr, this message translates to:
  /// **'Groupes ouverts'**
  String get autresGroupes;

  /// No description provided for @autresGroupesAide.
  ///
  /// In fr, this message translates to:
  /// **'Pour en faire partie, demandez à un administrateur du groupe.'**
  String get autresGroupesAide;

  /// No description provided for @choisirAdminGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez au moins un administrateur.'**
  String get choisirAdminGroupe;

  /// No description provided for @compteInconnu.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get compteInconnu;

  /// No description provided for @discussion.
  ///
  /// In fr, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @ecrireMessage.
  ///
  /// In fr, this message translates to:
  /// **'Écrire un message…'**
  String get ecrireMessage;

  /// No description provided for @effacerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Effacer ce message ?'**
  String get effacerMessage;

  /// No description provided for @envoiEchoue.
  ///
  /// In fr, this message translates to:
  /// **'L\'envoi a échoué. Vérifiez votre connexion.'**
  String get envoiEchoue;

  /// No description provided for @envoyerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get envoyerMessage;

  /// No description provided for @envoyerPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer une photo'**
  String get envoyerPhoto;

  /// No description provided for @groupeIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Ce groupe n\'est pas accessible.'**
  String get groupeIndisponible;

  /// No description provided for @groupeOuvert.
  ///
  /// In fr, this message translates to:
  /// **'Groupe ouvert'**
  String get groupeOuvert;

  /// No description provided for @groupePrive.
  ///
  /// In fr, this message translates to:
  /// **'Groupe privé'**
  String get groupePrive;

  /// No description provided for @groupePriveAide.
  ///
  /// In fr, this message translates to:
  /// **'Seuls ses membres le voient. Sinon, tous les membres de l\'église le voient (sans la discussion).'**
  String get groupePriveAide;

  /// No description provided for @lienAppel.
  ///
  /// In fr, this message translates to:
  /// **'Lien d\'appel (Meet, Zoom, WhatsApp…)'**
  String get lienAppel;

  /// No description provided for @lienAppelAide.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif. Adresse commençant par https:// ; un bouton « Rejoindre l\'appel » l\'ouvrira.'**
  String get lienAppelAide;

  /// No description provided for @lienInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Le lien doit commencer par https://'**
  String get lienInvalide;

  /// No description provided for @mesGroupes.
  ///
  /// In fr, this message translates to:
  /// **'Mes groupes'**
  String get mesGroupes;

  /// No description provided for @modifierGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le groupe'**
  String get modifierGroupe;

  /// No description provided for @nomGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get nomGroupe;

  /// No description provided for @nombreMembres.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Aucun membre} =1{1 membre} other{{n} membres}}'**
  String nombreMembres(int n);

  /// No description provided for @nommerAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Nommer administrateur'**
  String get nommerAdmin;

  /// No description provided for @nouveau.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get nouveau;

  /// No description provided for @nouveauGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get nouveauGroupe;

  /// No description provided for @options.
  ///
  /// In fr, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @personneATrouver.
  ///
  /// In fr, this message translates to:
  /// **'Personne à ajouter.'**
  String get personneATrouver;

  /// No description provided for @photo.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @quitterGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get quitterGroupe;

  /// No description provided for @quitterGroupeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Quitter ce groupe ?'**
  String get quitterGroupeQuestion;

  /// No description provided for @rechercherPersonne.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une personne'**
  String get rechercherPersonne;

  /// No description provided for @rejoindreAppel.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre l\'appel'**
  String get rejoindreAppel;

  /// No description provided for @rejoindreGroupeAide.
  ///
  /// In fr, this message translates to:
  /// **'Pour rejoindre ce groupe, demandez à : {admins}.'**
  String rejoindreGroupeAide(String admins);

  /// No description provided for @retirerAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le rôle d\'administrateur'**
  String get retirerAdmin;

  /// No description provided for @retirerDuGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du groupe'**
  String get retirerDuGroupe;

  /// No description provided for @retirerDuGroupeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Retirer {nom} du groupe ?'**
  String retirerDuGroupeQuestion(String nom);

  /// No description provided for @supprimerGroupe.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce groupe ?'**
  String get supprimerGroupe;

  /// No description provided for @supprimerGroupeAide.
  ///
  /// In fr, this message translates to:
  /// **'Le groupe disparaît pour tous ses membres.'**
  String get supprimerGroupeAide;

  /// No description provided for @tousLesGroupes.
  ///
  /// In fr, this message translates to:
  /// **'Groupes de l\'église'**
  String get tousLesGroupes;

  /// No description provided for @tousLesGroupesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Créer les groupes et nommer leurs administrateurs'**
  String get tousLesGroupesSousTitre;

  /// No description provided for @groupeCellule.
  ///
  /// In fr, this message translates to:
  /// **'Cellule de maison'**
  String get groupeCellule;

  /// No description provided for @groupeIntercession.
  ///
  /// In fr, this message translates to:
  /// **'Intercession'**
  String get groupeIntercession;

  /// No description provided for @groupeJeunes.
  ///
  /// In fr, this message translates to:
  /// **'Jeunes'**
  String get groupeJeunes;

  /// No description provided for @groupeFemmes.
  ///
  /// In fr, this message translates to:
  /// **'Femmes'**
  String get groupeFemmes;

  /// No description provided for @groupeHommes.
  ///
  /// In fr, this message translates to:
  /// **'Hommes'**
  String get groupeHommes;

  /// No description provided for @groupeLouange.
  ///
  /// In fr, this message translates to:
  /// **'Louange'**
  String get groupeLouange;

  /// No description provided for @groupeModeration.
  ///
  /// In fr, this message translates to:
  /// **'Modération'**
  String get groupeModeration;

  /// No description provided for @groupeMedia.
  ///
  /// In fr, this message translates to:
  /// **'Équipe média'**
  String get groupeMedia;

  /// No description provided for @groupeEntraide.
  ///
  /// In fr, this message translates to:
  /// **'Entraide'**
  String get groupeEntraide;

  /// No description provided for @groupeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get groupeAutre;

  /// No description provided for @ajouterChant.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un chant'**
  String get ajouterChant;

  /// No description provided for @ajouterRendezVous.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un rendez-vous'**
  String get ajouterRendezVous;

  /// No description provided for @appelAvecLien.
  ///
  /// In fr, this message translates to:
  /// **'Le bouton « Rejoindre l\'appel » ouvrira le lien du groupe. L\'appel directement dans l\'app arrivera bientôt.'**
  String get appelAvecLien;

  /// No description provided for @appelSansLien.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un lien d\'appel au groupe (✏️ sur la page du groupe) pour que les membres puissent le rejoindre.'**
  String get appelSansLien;

  /// No description provided for @aucunModerateur.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de modérateur'**
  String get aucunModerateur;

  /// No description provided for @aucunRendezVous.
  ///
  /// In fr, this message translates to:
  /// **'Aucun rendez-vous prévu.'**
  String get aucunRendezVous;

  /// No description provided for @calendrier.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendrier;

  /// No description provided for @calendrierDe.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier · {nom}'**
  String calendrierDe(String nom);

  /// No description provided for @chantNumero.
  ///
  /// In fr, this message translates to:
  /// **'Chant {n}'**
  String chantNumero(int n);

  /// No description provided for @chantsAPreparer.
  ///
  /// In fr, this message translates to:
  /// **'Chants à préparer'**
  String get chantsAPreparer;

  /// No description provided for @demanderRemplacant.
  ///
  /// In fr, this message translates to:
  /// **'Je ne suis pas disponible : demander un remplaçant'**
  String get demanderRemplacant;

  /// No description provided for @deroule.
  ///
  /// In fr, this message translates to:
  /// **'Déroulé du culte'**
  String get deroule;

  /// No description provided for @derouleAide.
  ///
  /// In fr, this message translates to:
  /// **'Une étape par ligne.'**
  String get derouleAide;

  /// No description provided for @finalementDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Finalement, je suis disponible'**
  String get finalementDisponible;

  /// No description provided for @instrumentAide.
  ///
  /// In fr, this message translates to:
  /// **'Instrument ou voix (vide s\'il ne joue pas)'**
  String get instrumentAide;

  /// No description provided for @jeRemplace.
  ///
  /// In fr, this message translates to:
  /// **'Je remplace'**
  String get jeRemplace;

  /// No description provided for @lienChant.
  ///
  /// In fr, this message translates to:
  /// **'Lien audio, partition ou paroles (facultatif)'**
  String get lienChant;

  /// No description provided for @maReponse.
  ///
  /// In fr, this message translates to:
  /// **'Ma réponse'**
  String get maReponse;

  /// No description provided for @moderateur.
  ///
  /// In fr, this message translates to:
  /// **'Modérateur'**
  String get moderateur;

  /// No description provided for @moderePar.
  ///
  /// In fr, this message translates to:
  /// **'Modéré par {nom}'**
  String moderePar(String nom);

  /// No description provided for @modifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modifier;

  /// No description provided for @modifierRendezVous.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le rendez-vous'**
  String get modifierRendezVous;

  /// No description provided for @ouvrirLien.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir le lien'**
  String get ouvrirLien;

  /// No description provided for @presences.
  ///
  /// In fr, this message translates to:
  /// **'Présences'**
  String get presences;

  /// No description provided for @quiJoueQuoi.
  ///
  /// In fr, this message translates to:
  /// **'Qui joue quoi'**
  String get quiJoueQuoi;

  /// No description provided for @remplacantRecherche.
  ///
  /// In fr, this message translates to:
  /// **'{nom} cherche un remplaçant'**
  String remplacantRecherche(String nom);

  /// No description provided for @remplacementDemande.
  ///
  /// In fr, this message translates to:
  /// **'Un remplaçant est recherché.'**
  String get remplacementDemande;

  /// No description provided for @rendezVousIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Ce rendez-vous n\'est plus disponible.'**
  String get rendezVousIndisponible;

  /// No description provided for @retirer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get retirer;

  /// No description provided for @supprimerRendezVous.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce rendez-vous ?'**
  String get supprimerRendezVous;

  /// No description provided for @titreCulteDimanche.
  ///
  /// In fr, this message translates to:
  /// **'Culte du dimanche'**
  String get titreCulteDimanche;

  /// No description provided for @rencontreReunion.
  ///
  /// In fr, this message translates to:
  /// **'Réunion'**
  String get rencontreReunion;

  /// No description provided for @rencontreRepetition.
  ///
  /// In fr, this message translates to:
  /// **'Répétition'**
  String get rencontreRepetition;

  /// No description provided for @rencontreModeration.
  ///
  /// In fr, this message translates to:
  /// **'Modération'**
  String get rencontreModeration;

  /// No description provided for @rencontreAppel.
  ///
  /// In fr, this message translates to:
  /// **'Appel de groupe'**
  String get rencontreAppel;

  /// No description provided for @reponseOui.
  ///
  /// In fr, this message translates to:
  /// **'Je viens'**
  String get reponseOui;

  /// No description provided for @reponseNon.
  ///
  /// In fr, this message translates to:
  /// **'Je ne viens pas'**
  String get reponseNon;

  /// No description provided for @reponsePeutEtre.
  ///
  /// In fr, this message translates to:
  /// **'Peut-être'**
  String get reponsePeutEtre;

  /// No description provided for @aTraiter.
  ///
  /// In fr, this message translates to:
  /// **'À traiter'**
  String get aTraiter;

  /// No description provided for @annonceePar.
  ///
  /// In fr, this message translates to:
  /// **'Annoncé par {nom}'**
  String annonceePar(String nom);

  /// No description provided for @annoncer.
  ///
  /// In fr, this message translates to:
  /// **'Annoncer'**
  String get annoncer;

  /// No description provided for @annoncerExaucement.
  ///
  /// In fr, this message translates to:
  /// **'Ma prière est exaucée !'**
  String get annoncerExaucement;

  /// No description provided for @annoncerFete.
  ///
  /// In fr, this message translates to:
  /// **'Annoncer'**
  String get annoncerFete;

  /// No description provided for @anonyme.
  ///
  /// In fr, this message translates to:
  /// **'Anonyme'**
  String get anonyme;

  /// No description provided for @aucunSujetPartage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sujet de prière partagé pour le moment.'**
  String get aucunSujetPartage;

  /// No description provided for @aucunSujetPriere.
  ///
  /// In fr, this message translates to:
  /// **'Aucun sujet de prière.'**
  String get aucunSujetPriere;

  /// No description provided for @aucuneDemande.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande. Touchez « Nouvelle demande » pour en faire une.'**
  String get aucuneDemande;

  /// No description provided for @aucuneDemandeATraiter.
  ///
  /// In fr, this message translates to:
  /// **'Aucune demande à traiter.'**
  String get aucuneDemandeATraiter;

  /// No description provided for @aucuneFete.
  ///
  /// In fr, this message translates to:
  /// **'Rien d\'annoncé pour le moment. Touchez « Annoncer » pour un anniversaire ou une fête.'**
  String get aucuneFete;

  /// No description provided for @chaineYoutube.
  ///
  /// In fr, this message translates to:
  /// **'Chaîne YouTube'**
  String get chaineYoutube;

  /// No description provided for @choisirTypeDemande.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez le type de demande.'**
  String get choisirTypeDemande;

  /// No description provided for @confierPriere.
  ///
  /// In fr, this message translates to:
  /// **'Sujet de prière'**
  String get confierPriere;

  /// No description provided for @confierSujet.
  ///
  /// In fr, this message translates to:
  /// **'Confier ce sujet'**
  String get confierSujet;

  /// No description provided for @cuisineInformee.
  ///
  /// In fr, this message translates to:
  /// **'C\'est noté, la cuisine est informée. Merci !'**
  String get cuisineInformee;

  /// No description provided for @cultesEtEvenements.
  ///
  /// In fr, this message translates to:
  /// **'Cultes et événements'**
  String get cultesEtEvenements;

  /// No description provided for @dateEtHeure.
  ///
  /// In fr, this message translates to:
  /// **'Date et heure'**
  String get dateEtHeure;

  /// No description provided for @demande.
  ///
  /// In fr, this message translates to:
  /// **'Demande'**
  String get demande;

  /// No description provided for @demandeEnvoyee.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée. Vous serez prévenu de la réponse.'**
  String get demandeEnvoyee;

  /// No description provided for @demandeIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Cette demande n\'est plus disponible.'**
  String get demandeIndisponible;

  /// No description provided for @demandesRecues.
  ///
  /// In fr, this message translates to:
  /// **'Demandes'**
  String get demandesRecues;

  /// No description provided for @demandesRecuesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Baptêmes, mariages, rendez-vous, visites'**
  String get demandesRecuesSousTitre;

  /// No description provided for @divers.
  ///
  /// In fr, this message translates to:
  /// **'Divers'**
  String get divers;

  /// No description provided for @diversConnexion.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour voir les anniversaires et les fêtes de l\'église.'**
  String get diversConnexion;

  /// No description provided for @enregistrerEtPrevenir.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer et prévenir la personne'**
  String get enregistrerEtPrevenir;

  /// No description provided for @envoyerDemande.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer la demande'**
  String get envoyerDemande;

  /// No description provided for @exaucee.
  ///
  /// In fr, this message translates to:
  /// **'Exaucée'**
  String get exaucee;

  /// No description provided for @faireDemande.
  ///
  /// In fr, this message translates to:
  /// **'Faire une demande'**
  String get faireDemande;

  /// No description provided for @feteIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Cette annonce n\'est plus disponible.'**
  String get feteIndisponible;

  /// No description provided for @gloireADieu.
  ///
  /// In fr, this message translates to:
  /// **'Gloire à Dieu !'**
  String get gloireADieu;

  /// No description provided for @groupeCuisineAide.
  ///
  /// In fr, this message translates to:
  /// **'Ses membres voient ce que chacun apporte aux fêtes (rubrique Divers) et en sont prévenus. Créez d\'abord un groupe de type « Cuisine ».'**
  String get groupeCuisineAide;

  /// No description provided for @groupeCuisineChamp.
  ///
  /// In fr, this message translates to:
  /// **'Groupe des responsables cuisine'**
  String get groupeCuisineChamp;

  /// No description provided for @groupeIntercessionAide.
  ///
  /// In fr, this message translates to:
  /// **'Il reçoit les sujets de prière que les membres choisissent de partager. Créez d\'abord un groupe de type « Intercession ».'**
  String get groupeIntercessionAide;

  /// No description provided for @groupeIntercessionChamp.
  ///
  /// In fr, this message translates to:
  /// **'Groupe d\'intercession de l\'église'**
  String get groupeIntercessionChamp;

  /// No description provided for @informerCuisine.
  ///
  /// In fr, this message translates to:
  /// **'Informer la cuisine'**
  String get informerCuisine;

  /// No description provided for @jaiPrie.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai prié'**
  String get jaiPrie;

  /// No description provided for @japporte.
  ///
  /// In fr, this message translates to:
  /// **'J\'apporte…'**
  String get japporte;

  /// No description provided for @japporteAide.
  ///
  /// In fr, this message translates to:
  /// **'Pour informer les responsables cuisine.'**
  String get japporteAide;

  /// No description provided for @mesDemandes.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get mesDemandes;

  /// No description provided for @mesDemandesSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Baptême, mariage, rendez-vous avec un pasteur…'**
  String get mesDemandesSousTitre;

  /// No description provided for @mesSujetsPriere.
  ///
  /// In fr, this message translates to:
  /// **'Mes sujets de prière'**
  String get mesSujetsPriere;

  /// No description provided for @messageDemandeAide.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple : vos disponibilités, votre numéro de téléphone, la date envisagée.'**
  String get messageDemandeAide;

  /// No description provided for @messageFacultatif.
  ///
  /// In fr, this message translates to:
  /// **'Message (facultatif)'**
  String get messageFacultatif;

  /// No description provided for @modifierTemoignage.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon témoignage'**
  String get modifierTemoignage;

  /// No description provided for @nombrePrieres.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =0{Personne n\'a encore prié} =1{1 personne a prié} other{{n} personnes ont prié}}'**
  String nombrePrieres(int n);

  /// No description provided for @nouveauSujet.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau sujet de prière'**
  String get nouveauSujet;

  /// No description provided for @nouvelleDemande.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle demande'**
  String get nouvelleDemande;

  /// No description provided for @pageFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Page Facebook'**
  String get pageFacebook;

  /// No description provided for @parametresEglise.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de l\'église'**
  String get parametresEglise;

  /// No description provided for @parametresEgliseSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Intercession, cuisine, Facebook, YouTube'**
  String get parametresEgliseSousTitre;

  /// No description provided for @partageIntercession.
  ///
  /// In fr, this message translates to:
  /// **'Aussi l\'équipe d\'intercession'**
  String get partageIntercession;

  /// No description provided for @partageIntercessionAide.
  ///
  /// In fr, this message translates to:
  /// **'Les membres du groupe d\'intercession prient avec vous.'**
  String get partageIntercessionAide;

  /// No description provided for @partagePasteurs.
  ///
  /// In fr, this message translates to:
  /// **'Les pasteurs seulement'**
  String get partagePasteurs;

  /// No description provided for @partagePasteursAide.
  ///
  /// In fr, this message translates to:
  /// **'Confidentiel.'**
  String get partagePasteursAide;

  /// No description provided for @pasDeGroupeIntercession.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de groupe d\'intercession désigné par l\'église.'**
  String get pasDeGroupeIntercession;

  /// No description provided for @personneNApporte.
  ///
  /// In fr, this message translates to:
  /// **'Personne n\'a encore rien indiqué.'**
  String get personneNApporte;

  /// No description provided for @pourLaCuisine.
  ///
  /// In fr, this message translates to:
  /// **'Pour la cuisine'**
  String get pourLaCuisine;

  /// No description provided for @precisionApport.
  ///
  /// In fr, this message translates to:
  /// **'Précision (facultatif) : « un gâteau au chocolat », « 2 bouteilles de jus »…'**
  String get precisionApport;

  /// No description provided for @priereExaucee.
  ///
  /// In fr, this message translates to:
  /// **'Prière exaucée'**
  String get priereExaucee;

  /// No description provided for @quiPeutLeLire.
  ///
  /// In fr, this message translates to:
  /// **'Qui peut le lire ?'**
  String get quiPeutLeLire;

  /// No description provided for @reponseALaPersonne.
  ///
  /// In fr, this message translates to:
  /// **'Réponse à la personne'**
  String get reponseALaPersonne;

  /// No description provided for @reponseAide.
  ///
  /// In fr, this message translates to:
  /// **'Visible par la personne dans l\'app ; elle est prévenue par notification.'**
  String get reponseAide;

  /// No description provided for @reponseEglise.
  ///
  /// In fr, this message translates to:
  /// **'Réponse de l\'église'**
  String get reponseEglise;

  /// No description provided for @resterAnonyme.
  ///
  /// In fr, this message translates to:
  /// **'Rester anonyme'**
  String get resterAnonyme;

  /// No description provided for @resterAnonymeAide.
  ///
  /// In fr, this message translates to:
  /// **'L\'équipe d\'intercession ne verra pas votre nom (les pasteurs, oui).'**
  String get resterAnonymeAide;

  /// No description provided for @retirerDemande.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ma demande'**
  String get retirerDemande;

  /// No description provided for @suivreFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Facebook'**
  String get suivreFacebook;

  /// No description provided for @suivreYoutube.
  ///
  /// In fr, this message translates to:
  /// **'YouTube'**
  String get suivreYoutube;

  /// No description provided for @sujetConfie.
  ///
  /// In fr, this message translates to:
  /// **'Votre sujet de prière est confié. Nous prions avec vous.'**
  String get sujetConfie;

  /// No description provided for @sujetIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Ce sujet de prière n\'est pas accessible.'**
  String get sujetIndisponible;

  /// No description provided for @sujetPriere.
  ///
  /// In fr, this message translates to:
  /// **'Sujet de prière'**
  String get sujetPriere;

  /// No description provided for @sujetPriereChamp.
  ///
  /// In fr, this message translates to:
  /// **'Pour quoi voulez-vous que l\'on prie ?'**
  String get sujetPriereChamp;

  /// No description provided for @sujetsPriere.
  ///
  /// In fr, this message translates to:
  /// **'Sujets de prière'**
  String get sujetsPriere;

  /// No description provided for @sujetsPriereSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Tous les sujets confiés (pasteurs)'**
  String get sujetsPriereSousTitre;

  /// No description provided for @supprimerFete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette annonce ?'**
  String get supprimerFete;

  /// No description provided for @supprimerSujet.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce sujet de prière ?'**
  String get supprimerSujet;

  /// No description provided for @temoignageFacultatif.
  ///
  /// In fr, this message translates to:
  /// **'Votre témoignage (facultatif)'**
  String get temoignageFacultatif;

  /// No description provided for @titreFeteAide.
  ///
  /// In fr, this message translates to:
  /// **'Ex. : Anniversaire de Maman Esther'**
  String get titreFeteAide;

  /// No description provided for @toutes.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get toutes;

  /// No description provided for @typeDemandeQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Que souhaitez-vous demander ?'**
  String get typeDemandeQuestion;

  /// No description provided for @vousAvezPrie.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez prié. Merci !'**
  String get vousAvezPrie;

  /// No description provided for @demandeBapteme.
  ///
  /// In fr, this message translates to:
  /// **'Baptême'**
  String get demandeBapteme;

  /// No description provided for @demandePresentation.
  ///
  /// In fr, this message translates to:
  /// **'Présentation d\'enfant'**
  String get demandePresentation;

  /// No description provided for @demandeMariage.
  ///
  /// In fr, this message translates to:
  /// **'Mariage'**
  String get demandeMariage;

  /// No description provided for @demandeRendezVous.
  ///
  /// In fr, this message translates to:
  /// **'Rendez-vous avec un pasteur'**
  String get demandeRendezVous;

  /// No description provided for @demandeVisite.
  ///
  /// In fr, this message translates to:
  /// **'Visite à domicile'**
  String get demandeVisite;

  /// No description provided for @statutNouvelle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyée'**
  String get statutNouvelle;

  /// No description provided for @statutEnCours.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statutEnCours;

  /// No description provided for @statutAcceptee.
  ///
  /// In fr, this message translates to:
  /// **'Acceptée'**
  String get statutAcceptee;

  /// No description provided for @statutRefusee.
  ///
  /// In fr, this message translates to:
  /// **'Refusée'**
  String get statutRefusee;

  /// No description provided for @statutTerminee.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statutTerminee;

  /// No description provided for @feteAnniversaire.
  ///
  /// In fr, this message translates to:
  /// **'Anniversaire'**
  String get feteAnniversaire;

  /// No description provided for @feteNaissance.
  ///
  /// In fr, this message translates to:
  /// **'Naissance'**
  String get feteNaissance;

  /// No description provided for @feteMariage.
  ///
  /// In fr, this message translates to:
  /// **'Mariage'**
  String get feteMariage;

  /// No description provided for @feteFete.
  ///
  /// In fr, this message translates to:
  /// **'Fête'**
  String get feteFete;

  /// No description provided for @feteAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get feteAutre;

  /// No description provided for @apportNourriture.
  ///
  /// In fr, this message translates to:
  /// **'Nourriture'**
  String get apportNourriture;

  /// No description provided for @apportGateau.
  ///
  /// In fr, this message translates to:
  /// **'Gâteau'**
  String get apportGateau;

  /// No description provided for @apportBoisson.
  ///
  /// In fr, this message translates to:
  /// **'Boissons'**
  String get apportBoisson;

  /// No description provided for @apportAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get apportAutre;

  /// No description provided for @groupeCuisine.
  ///
  /// In fr, this message translates to:
  /// **'Cuisine'**
  String get groupeCuisine;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['fr', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
