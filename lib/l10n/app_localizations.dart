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
