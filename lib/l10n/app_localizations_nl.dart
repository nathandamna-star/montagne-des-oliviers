// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Montagne des Oliviers';

  @override
  String get nomEglise => 'Centre Évangélique Montagne des Oliviers';

  @override
  String get navAccueil => 'Home';

  @override
  String get navAgenda => 'Agenda';

  @override
  String get navGroupes => 'Groepen';

  @override
  String get navMedias => 'Media';

  @override
  String get navProfil => 'Profiel';

  @override
  String get navResponsables => 'Leiding';

  @override
  String get bientot => 'Binnenkort beschikbaar';

  @override
  String get accueilBienvenue =>
      'Welkom in de familie van Montagne des Oliviers.';

  @override
  String get accueilAVenir =>
      'Hier: het vers van de dag, de aankondigingen van de kerk, de volgende dienst en de livestream.';

  @override
  String get agendaAVenir =>
      'Hier: de diensten, de gebedssamenkomsten, de huiskringen en alle activiteiten, met inschrijving.';

  @override
  String get groupesAVenir =>
      'Hier: uw huiskringen, de jongeren, de lofprijzing, de onderlinge hulp… met een privégesprek per groep.';

  @override
  String get mediasAVenir =>
      'Hier: de preken en bemoedigingen in audio en video, de livestream van de dienst en het vers van de dag.';

  @override
  String get profilAVenir =>
      'Hier: uw account, uw aanvragen, uw gebedspunten, uw giften en de taal van de app.';

  @override
  String get responsablesAVenir =>
      'Hier: het ledenbestand, de giften, de dienstroosters en de reservatie van de zalen.';

  @override
  String get seConnecter => 'Aanmelden';

  @override
  String get seDeconnecter => 'Afmelden';

  @override
  String get creerCompte => 'Account aanmaken';

  @override
  String get connexionIntro =>
      'Meld je aan om je groepen te vinden, je in te schrijven voor activiteiten en je aanvragen te doen.';

  @override
  String get continuerGoogle => 'Doorgaan met Google';

  @override
  String get continuerApple => 'Doorgaan met Apple';

  @override
  String get continuerEmail => 'Doorgaan met e-mail';

  @override
  String get continuerSansCompte => 'Doorgaan zonder account';

  @override
  String get bienvenueFamille => 'Welkom in de familie!';

  @override
  String get completerProfilIntro =>
      'Nog één stap: vul je naam in en ga akkoord met het gebruik van je gegevens.';

  @override
  String get annuler => 'Annuleren';

  @override
  String get valider => 'Bevestigen';

  @override
  String get enregistrer => 'Opslaan';

  @override
  String get chargement => 'Laden…';

  @override
  String get champNom => 'Voornaam en naam';

  @override
  String get champEmail => 'E-mailadres';

  @override
  String get champMotDePasse => 'Wachtwoord';

  @override
  String get afficherMotDePasse => 'Wachtwoord tonen';

  @override
  String get masquerMotDePasse => 'Wachtwoord verbergen';

  @override
  String get motDePasseOublie => 'Wachtwoord vergeten?';

  @override
  String emailReinitialisationEnvoye(String email) {
    return 'Er is een e-mail naar $email gestuurd om een nieuw wachtwoord te kiezen.';
  }

  @override
  String get validationNomRequis => 'Vul je naam in.';

  @override
  String get validationEmail => 'Vul een geldig e-mailadres in.';

  @override
  String get validationMotDePasse => 'Minstens 8 tekens.';

  @override
  String get consentementTexte =>
      'Ik ga ermee akkoord dat de kerk mijn gegevens bewaart (naam, e-mail, groepen, aanvragen en gebedsintenties, die mijn geloofsovertuiging kunnen onthullen) voor het leven van de gemeenschap. Ik kan mijn account op elk moment verwijderen.';

  @override
  String get consentementRequis => 'Vink het vakje aan om verder te gaan.';

  @override
  String get connexionRequiseTitre => 'Aanmelding nodig';

  @override
  String get connexionRequiseTexte =>
      'Dit deel is voorbehouden aan aangemelde leden.';

  @override
  String get groupesConnexionTexte =>
      'Meld je aan om je groepen en hun gesprekken te vinden.';

  @override
  String get profilConnexionTexte =>
      'Meld je aan om je account, je aanvragen en je giften te zien.';

  @override
  String get accueilConnexionTexte =>
      'Hoor je bij de kerk? Meld je aan om alles terug te vinden.';

  @override
  String bonjourNom(String nom) {
    return 'Hallo $nom';
  }

  @override
  String get activerAdminTitre => 'Beheer activeren?';

  @override
  String get activerAdminTexte =>
      'Alleen het account dat bij de installatie werd aangeduid, kan beheerder worden.';

  @override
  String get adminActive => 'Je bent nu beheerder.';

  @override
  String get adminRefuse => 'Dit account kan geen beheerder worden.';

  @override
  String get roleAdmin => 'Beheerder';

  @override
  String get roleSecretariat => 'Secretariaat';

  @override
  String get roleTresorier => 'Penningmeester';

  @override
  String get roleAdminAide => 'Alles beheren, ook de rollen.';

  @override
  String get roleSecretariatAide => 'Leden, agenda, aankondigingen, aanvragen.';

  @override
  String get roleTresorierAide => 'Giften en jaaroverzichten.';

  @override
  String get rolesTitre => 'Rollen van de verantwoordelijken';

  @override
  String get rolesSousTitre => 'Toegang geven of intrekken';

  @override
  String get rolesAide =>
      'De persoon moet eerst een account hebben aangemaakt. Vink alles uit om de toegang in te trekken.';

  @override
  String rolesEnregistres(String email) {
    return 'Rollen opgeslagen voor $email.';
  }

  @override
  String get rolesCompteIntrouvable =>
      'Geen account met dit adres. De persoon moet zich eerst registreren.';

  @override
  String get rolesRefuse => 'Alleen een beheerder kan de rollen wijzigen.';

  @override
  String get erreurEmailInvalide => 'Dit e-mailadres is ongeldig.';

  @override
  String get erreurMotDePasseFaible =>
      'Dit wachtwoord is te zwak. Gebruik minstens 8 tekens.';

  @override
  String get erreurEmailDejaUtilise =>
      'Er bestaat al een account met dit adres. Meld je aan.';

  @override
  String get erreurIdentifiantsIncorrects =>
      'Onjuist e-mailadres of wachtwoord.';

  @override
  String get erreurTropDeTentatives =>
      'Te veel pogingen. Probeer het over enkele minuten opnieuw.';

  @override
  String get erreurReseau =>
      'Geen internetverbinding. Controleer je netwerk en probeer opnieuw.';

  @override
  String get erreurInconnue => 'Er ging iets mis. Probeer het opnieuw.';

  @override
  String get devise => 'Bekering · Bevrijding · Heiliging';

  @override
  String get annonce => 'Aankondiging';

  @override
  String get annonces => 'Aankondigingen';

  @override
  String get annoncesSousTitre => 'Aankondigingen van de kerk publiceren';

  @override
  String get annonceIndisponible =>
      'Deze aankondiging is niet meer beschikbaar.';

  @override
  String get aucuneAnnonce => 'Nog geen aankondigingen.';

  @override
  String get aucunEvenement => 'Momenteel geen activiteiten gepland.';

  @override
  String get brouillon => 'Concept';

  @override
  String get champTitre => 'Titel';

  @override
  String get champTexte => 'Tekst';

  @override
  String get champDescription => 'Beschrijving';

  @override
  String get champObligatoire => 'Dit veld is verplicht.';

  @override
  String get traductionFacultative =>
      'Optioneel: anders wordt de Franse tekst getoond.';

  @override
  String get ajouterPhoto => 'Foto toevoegen';

  @override
  String get changerPhoto => 'Foto wijzigen';

  @override
  String get retirerPhoto => 'Foto verwijderen';

  @override
  String get erreurPhoto =>
      'De foto kon niet worden verzonden. Probeer opnieuw.';

  @override
  String get erreurChargement => 'Laden mislukt. Controleer je verbinding.';

  @override
  String get complet => 'Volzet';

  @override
  String get debut => 'Begin';

  @override
  String get fin => 'Einde';

  @override
  String get finAvantDebut => 'Het einde moet na het begin liggen.';

  @override
  String get enregistre => 'Opgeslagen.';

  @override
  String get envoyerNotification => 'Melding sturen';

  @override
  String get envoyerNotificationAide =>
      'Er wordt één keer een melding gestuurd, bij de publicatie.';

  @override
  String get epinglee => 'Vastgezet';

  @override
  String get epingler => 'Bovenaan vastzetten';

  @override
  String get epinglerAide => 'Blijft bovenaan de aankondigingen.';

  @override
  String get evenement => 'Activiteit';

  @override
  String get evenementIndisponible =>
      'Deze activiteit is niet meer beschikbaar.';

  @override
  String get gestionAgenda => 'Agenda van de kerk';

  @override
  String get gestionAgendaSousTitre => 'Diensten, samenkomsten en activiteiten';

  @override
  String get inscription => 'Inschrijving';

  @override
  String get inscriptionConnexion => 'Meld je aan om je in te schrijven.';

  @override
  String get inscriptionOuverte => 'Inschrijvingen open';

  @override
  String inscritPersonnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personen',
      one: '1 persoon',
    );
    return 'Inschrijving bevestigd ($_temp0).';
  }

  @override
  String inscritsNombre(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n inschrijvingen',
      one: '1 inschrijving',
      zero: 'Nog geen inschrijvingen',
    );
    return '$_temp0';
  }

  @override
  String inscritsSurPlaces(int n, int max) {
    return '$n ingeschreven op $max plaatsen';
  }

  @override
  String get lieu => 'Plaats';

  @override
  String get modifierAnnonce => 'Aankondiging bewerken';

  @override
  String get modifierEvenement => 'Activiteit bewerken';

  @override
  String get moins => 'Minder';

  @override
  String get plus => 'Meer';

  @override
  String get nombreInvalide => 'Geef een geheel getal in.';

  @override
  String get nombrePersonnes => 'Aantal personen';

  @override
  String get nouvelEvenement => 'Nieuwe activiteit';

  @override
  String get nouvelleAnnonce => 'Nieuwe aankondiging';

  @override
  String get placesMax => 'Aantal plaatsen';

  @override
  String get placesMaxAide => 'Leeg laten als er geen limiet is.';

  @override
  String get prochainement => 'Binnenkort';

  @override
  String publieeLe(String date) {
    return 'Gepubliceerd op $date';
  }

  @override
  String get publier => 'Publiceren';

  @override
  String get publierAide =>
      'Anders blijft het een concept (alleen zichtbaar voor verantwoordelijken).';

  @override
  String get sInscrire => 'Ik schrijf me in';

  @override
  String get seDesinscrire => 'Mijn inschrijving annuleren';

  @override
  String get supprimer => 'Verwijderen';

  @override
  String get supprimerAnnonce => 'Deze aankondiging verwijderen?';

  @override
  String get supprimerEvenement => 'Deze activiteit verwijderen?';

  @override
  String get tous => 'Alle';

  @override
  String get toutLAgenda => 'Volledige agenda';

  @override
  String get voirTout => 'Alles bekijken';

  @override
  String get typeEvenementChamp => 'Soort';

  @override
  String get visibilite => 'Wie kan het zien?';

  @override
  String get visibilitePublic => 'Iedereen';

  @override
  String get visibiliteMembres => 'Leden';

  @override
  String get typeCulte => 'Dienst';

  @override
  String get typePriere => 'Gebed';

  @override
  String get typeJeune => 'Vasten';

  @override
  String get typeCellule => 'Celgroep';

  @override
  String get typeEvenement => 'Activiteit';

  @override
  String get typeConference => 'Conferentie';

  @override
  String get ajouter => 'Toevoegen';

  @override
  String get ajouterALaFamille => 'Persoon toevoegen';

  @override
  String get aucun => 'Geen';

  @override
  String get aucune => 'Geen';

  @override
  String get aucuneFamille => 'Nog geen gezinnen.';

  @override
  String get aucuneFiche => 'Geen fiches.';

  @override
  String get autreService => 'Andere dienst';

  @override
  String get champArrivee => 'Aankomst in de kerk';

  @override
  String get champBapteme => 'Doop';

  @override
  String get champCodePostal => 'Postcode';

  @override
  String get champDateNaissance => 'Geboortedatum';

  @override
  String get champFamille => 'Gezin';

  @override
  String get champMariage => 'Huwelijk';

  @override
  String get champNomFamille => 'Naam';

  @override
  String get champNotes => 'Notities';

  @override
  String get champPrenom => 'Voornaam';

  @override
  String get champPresentation => 'Opdracht van een kind';

  @override
  String get champRue => 'Straat en nummer';

  @override
  String get champServices => 'Diensten';

  @override
  String get champStatut => 'Status';

  @override
  String get champTelephone => 'Telefoon';

  @override
  String get champVille => 'Gemeente';

  @override
  String get compteApp => 'Account in de app';

  @override
  String get compteLie => 'Gekoppeld account';

  @override
  String get compteLieAide =>
      'De persoon kan zijn of haar fiche in de app zien.';

  @override
  String comptesSansFiche(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n accounts zonder fiche',
      one: '1 account zonder fiche',
    );
    return '$_temp0';
  }

  @override
  String get comptesSansFicheAide => 'Hun fiche aanmaken met naam en e-mail';

  @override
  String get coordonnees => 'Contactgegevens';

  @override
  String get creer => 'Aanmaken';

  @override
  String get creerFicheDepuisCompte => 'Fiche aanmaken voor…';

  @override
  String get effacerDate => 'Datum wissen';

  @override
  String get exporterCsv => 'Exporteren (CSV-bestand)';

  @override
  String familleDe(String nom) {
    return 'Gezin $nom';
  }

  @override
  String get familleVide => 'Nog niemand in dit gezin.';

  @override
  String get familles => 'Gezinnen';

  @override
  String get ficheMembre => 'Fiche';

  @override
  String get fichierMembres => 'Ledenbestand';

  @override
  String get fichierMembresSousTitre =>
      'Leden, gezinnen, contactgegevens, diensten';

  @override
  String get nomFamilleChamp => 'Naam van het gezin';

  @override
  String nombreFiches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n fiches',
      one: '1 fiche',
      zero: 'Geen fiches',
    );
    return '$_temp0';
  }

  @override
  String nombrePersonnesFamille(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personen',
      one: '1 persoon',
      zero: 'Niemand',
    );
    return '$_temp0';
  }

  @override
  String get notesAide =>
      'Notities (alleen zichtbaar voor secretariaat en pastoors)';

  @override
  String get nouvelleFamille => 'Nieuw gezin';

  @override
  String get nouvelleFiche => 'Nieuwe fiche';

  @override
  String get rechercherMembre => 'Zoeken (naam, telefoon, gemeente…)';

  @override
  String get renommer => 'Naam wijzigen';

  @override
  String get responsablesActuels => 'Huidige verantwoordelijken';

  @override
  String get retirerDeLaFamille => 'Uit het gezin halen';

  @override
  String get supprimerFamille => 'Dit gezin verwijderen?';

  @override
  String get supprimerFamilleAide =>
      'De fiches van de personen blijven bewaard.';

  @override
  String get supprimerFiche => 'Deze fiche verwijderen?';

  @override
  String get supprimerFicheAide =>
      'Het app-account van de persoon wordt niet verwijderd.';

  @override
  String get vieDEglise => 'Kerkelijk leven';

  @override
  String get statutVisiteur => 'Bezoeker';

  @override
  String get statutMembre => 'Lid';

  @override
  String get statutActif => 'Actief lid';

  @override
  String get adminGroupe => 'Beheerder van de groep';

  @override
  String get adminsGroupe => 'Beheerders van de groep';

  @override
  String get adminsGroupeAide =>
      'Zij voegen leden toe en verwijderen ze. Kies minstens één persoon.';

  @override
  String get ajouterMembres => 'Toevoegen';

  @override
  String ajouterNombre(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personen toevoegen',
      one: '1 persoon toevoegen',
      zero: 'Toevoegen',
    );
    return '$_temp0';
  }

  @override
  String get aucunGroupe => 'Je maakt nog geen deel uit van een groep.';

  @override
  String get aucunGroupeEglise => 'Nog geen groepen.';

  @override
  String get aucunMessageGroupe => 'Nog geen berichten. Schrijf het eerste!';

  @override
  String get autresGroupes => 'Open groepen';

  @override
  String get autresGroupesAide =>
      'Vraag een beheerder van de groep om lid te worden.';

  @override
  String get choisirAdminGroupe => 'Kies minstens één beheerder.';

  @override
  String get compteInconnu => 'Verwijderd account';

  @override
  String get discussion => 'Gesprek';

  @override
  String get ecrireMessage => 'Schrijf een bericht…';

  @override
  String get effacerMessage => 'Dit bericht verwijderen?';

  @override
  String get envoiEchoue => 'Verzenden mislukt. Controleer je verbinding.';

  @override
  String get envoyerMessage => 'Verzenden';

  @override
  String get envoyerPhoto => 'Foto sturen';

  @override
  String get groupeIndisponible => 'Deze groep is niet toegankelijk.';

  @override
  String get groupeOuvert => 'Open groep';

  @override
  String get groupePrive => 'Besloten groep';

  @override
  String get groupePriveAide =>
      'Alleen de leden zien hem. Anders zien alle leden van de kerk hem (zonder het gesprek).';

  @override
  String get lienAppel => 'Link voor oproep (Meet, Zoom, WhatsApp…)';

  @override
  String get lienAppelAide =>
      'Optioneel. Adres dat begint met https://; een knop « Deelnemen aan oproep » opent het.';

  @override
  String get lienInvalide => 'De link moet beginnen met https://';

  @override
  String get mesGroupes => 'Mijn groepen';

  @override
  String get modifierGroupe => 'Groep bewerken';

  @override
  String get nomGroupe => 'Naam van de groep';

  @override
  String nombreMembres(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n leden',
      one: '1 lid',
      zero: 'Geen leden',
    );
    return '$_temp0';
  }

  @override
  String get nommerAdmin => 'Beheerder maken';

  @override
  String get nouveau => 'Nieuw';

  @override
  String get nouveauGroupe => 'Nieuwe groep';

  @override
  String get options => 'Opties';

  @override
  String get personneATrouver => 'Niemand om toe te voegen.';

  @override
  String get photo => 'Foto';

  @override
  String get quitterGroupe => 'Groep verlaten';

  @override
  String get quitterGroupeQuestion => 'Deze groep verlaten?';

  @override
  String get rechercherPersonne => 'Iemand zoeken';

  @override
  String get rejoindreAppel => 'Deelnemen aan oproep';

  @override
  String rejoindreGroupeAide(String admins) {
    return 'Vraag om lid te worden aan: $admins.';
  }

  @override
  String get retirerAdmin => 'Beheerdersrol intrekken';

  @override
  String get retirerDuGroupe => 'Uit de groep verwijderen';

  @override
  String retirerDuGroupeQuestion(String nom) {
    return '$nom uit de groep verwijderen?';
  }

  @override
  String get supprimerGroupe => 'Deze groep verwijderen?';

  @override
  String get supprimerGroupeAide => 'De groep verdwijnt voor alle leden.';

  @override
  String get tousLesGroupes => 'Groepen van de kerk';

  @override
  String get tousLesGroupesSousTitre =>
      'Groepen aanmaken en beheerders aanduiden';

  @override
  String get groupeCellule => 'Huiskring';

  @override
  String get groupeIntercession => 'Voorbede';

  @override
  String get groupeJeunes => 'Jongeren';

  @override
  String get groupeFemmes => 'Vrouwen';

  @override
  String get groupeHommes => 'Mannen';

  @override
  String get groupeLouange => 'Aanbidding';

  @override
  String get groupeModeration => 'Leiding van de dienst';

  @override
  String get groupeMedia => 'Mediateam';

  @override
  String get groupeEntraide => 'Hulpverlening';

  @override
  String get groupeAutre => 'Andere';

  @override
  String get ajouterChant => 'Lied toevoegen';

  @override
  String get ajouterRendezVous => 'Afspraak toevoegen';

  @override
  String get appelAvecLien =>
      'De knop « Deelnemen aan oproep » opent de link van de groep. Bellen in de app komt binnenkort.';

  @override
  String get appelSansLien =>
      'Voeg een oproeplink toe aan de groep (✏️ op de groepspagina) zodat de leden kunnen deelnemen.';

  @override
  String get aucunModerateur => 'Nog geen leider';

  @override
  String get aucunRendezVous => 'Geen afspraken gepland.';

  @override
  String get calendrier => 'Kalender';

  @override
  String calendrierDe(String nom) {
    return 'Kalender · $nom';
  }

  @override
  String chantNumero(int n) {
    return 'Lied $n';
  }

  @override
  String get chantsAPreparer => 'Liederen voor te bereiden';

  @override
  String get demanderRemplacant => 'Ik ben niet beschikbaar: vervanger vragen';

  @override
  String get deroule => 'Verloop van de dienst';

  @override
  String get derouleAide => 'Eén onderdeel per regel.';

  @override
  String get finalementDisponible => 'Ik ben toch beschikbaar';

  @override
  String get instrumentAide =>
      'Instrument of stem (leeg als hij/zij niet speelt)';

  @override
  String get jeRemplace => 'Ik vervang';

  @override
  String get lienChant => 'Link naar audio, partituur of tekst (optioneel)';

  @override
  String get maReponse => 'Mijn antwoord';

  @override
  String get moderateur => 'Leider van de dienst';

  @override
  String moderePar(String nom) {
    return 'Geleid door $nom';
  }

  @override
  String get modifier => 'Bewerken';

  @override
  String get modifierRendezVous => 'Afspraak bewerken';

  @override
  String get ouvrirLien => 'Link openen';

  @override
  String get presences => 'Aanwezigheden';

  @override
  String get quiJoueQuoi => 'Wie speelt wat';

  @override
  String remplacantRecherche(String nom) {
    return '$nom zoekt een vervanger';
  }

  @override
  String get remplacementDemande => 'Er wordt een vervanger gezocht.';

  @override
  String get rendezVousIndisponible =>
      'Deze afspraak is niet meer beschikbaar.';

  @override
  String get retirer => 'Verwijderen';

  @override
  String get supprimerRendezVous => 'Deze afspraak verwijderen?';

  @override
  String get titreCulteDimanche => 'Zondagsdienst';

  @override
  String get rencontreReunion => 'Samenkomst';

  @override
  String get rencontreRepetition => 'Repetitie';

  @override
  String get rencontreModeration => 'Leiding van de dienst';

  @override
  String get rencontreAppel => 'Groepsoproep';

  @override
  String get reponseOui => 'Ik kom';

  @override
  String get reponseNon => 'Ik kom niet';

  @override
  String get reponsePeutEtre => 'Misschien';

  @override
  String get aTraiter => 'Te behandelen';

  @override
  String annonceePar(String nom) {
    return 'Aangekondigd door $nom';
  }

  @override
  String get annoncer => 'Aankondigen';

  @override
  String get annoncerExaucement => 'Mijn gebed is verhoord!';

  @override
  String get annoncerFete => 'Aankondigen';

  @override
  String get anonyme => 'Anoniem';

  @override
  String get aucunSujetPartage => 'Nog geen gedeelde gebedsintenties.';

  @override
  String get aucunSujetPriere => 'Geen gebedsintenties.';

  @override
  String get aucuneDemande =>
      'Geen aanvragen. Tik op « Nieuwe aanvraag » om er een te doen.';

  @override
  String get aucuneDemandeATraiter => 'Geen aanvragen te behandelen.';

  @override
  String get aucuneFete =>
      'Nog niets aangekondigd. Tik op « Aankondigen » voor een verjaardag of een feest.';

  @override
  String get chaineYoutube => 'YouTube-kanaal';

  @override
  String get choisirTypeDemande => 'Kies het soort aanvraag.';

  @override
  String get confierPriere => 'Gebedsintentie';

  @override
  String get confierSujet => 'Deze intentie toevertrouwen';

  @override
  String get cuisineInformee =>
      'Genoteerd, de keuken is op de hoogte. Dank je!';

  @override
  String get cultesEtEvenements => 'Diensten en activiteiten';

  @override
  String get dateEtHeure => 'Datum en uur';

  @override
  String get demande => 'Aanvraag';

  @override
  String get demandeEnvoyee =>
      'Aanvraag verzonden. Je krijgt een melding bij het antwoord.';

  @override
  String get demandeIndisponible => 'Deze aanvraag is niet meer beschikbaar.';

  @override
  String get demandesRecues => 'Aanvragen';

  @override
  String get demandesRecuesSousTitre =>
      'Dopen, huwelijken, afspraken, bezoeken';

  @override
  String get divers => 'Allerlei';

  @override
  String get diversConnexion =>
      'Meld je aan om de verjaardagen en feesten van de kerk te zien.';

  @override
  String get enregistrerEtPrevenir => 'Opslaan en de persoon verwittigen';

  @override
  String get envoyerDemande => 'Aanvraag versturen';

  @override
  String get exaucee => 'Verhoord';

  @override
  String get faireDemande => 'Aanvraag doen';

  @override
  String get feteIndisponible => 'Deze aankondiging is niet meer beschikbaar.';

  @override
  String get gloireADieu => 'God zij geprezen!';

  @override
  String get groupeCuisineAide =>
      'De leden zien wat iedereen meebrengt naar de feesten (rubriek Allerlei) en krijgen een melding. Maak eerst een groep van het type « Keuken ».';

  @override
  String get groupeCuisineChamp => 'Groep van de keukenverantwoordelijken';

  @override
  String get groupeIntercessionAide =>
      'Ontvangt de gebedsintenties die leden willen delen. Maak eerst een groep van het type « Voorbede ».';

  @override
  String get groupeIntercessionChamp => 'Voorbedegroep van de kerk';

  @override
  String get informerCuisine => 'De keuken verwittigen';

  @override
  String get jaiPrie => 'Ik heb gebeden';

  @override
  String get japporte => 'Ik breng mee…';

  @override
  String get japporteAide => 'Om de keukenverantwoordelijken te informeren.';

  @override
  String get mesDemandes => 'Mijn aanvragen';

  @override
  String get mesDemandesSousTitre =>
      'Doop, huwelijk, afspraak met een pastoor…';

  @override
  String get mesSujetsPriere => 'Mijn gebedsintenties';

  @override
  String get messageDemandeAide =>
      'Bijvoorbeeld: je beschikbaarheid, je telefoonnummer, de gewenste datum.';

  @override
  String get messageFacultatif => 'Bericht (optioneel)';

  @override
  String get modifierTemoignage => 'Mijn getuigenis bewerken';

  @override
  String nombrePrieres(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personen hebben gebeden',
      one: '1 persoon heeft gebeden',
      zero: 'Nog niemand heeft gebeden',
    );
    return '$_temp0';
  }

  @override
  String get nouveauSujet => 'Nieuwe gebedsintentie';

  @override
  String get nouvelleDemande => 'Nieuwe aanvraag';

  @override
  String get pageFacebook => 'Facebookpagina';

  @override
  String get parametresEglise => 'Instellingen van de kerk';

  @override
  String get parametresEgliseSousTitre => 'Voorbede, keuken, Facebook, YouTube';

  @override
  String get partageIntercession => 'Ook het voorbedeteam';

  @override
  String get partageIntercessionAide =>
      'De leden van de voorbedegroep bidden met je mee.';

  @override
  String get partagePasteurs => 'Alleen de pastoors';

  @override
  String get partagePasteursAide => 'Vertrouwelijk.';

  @override
  String get pasDeGroupeIntercession =>
      'De kerk heeft nog geen voorbedegroep aangeduid.';

  @override
  String get personneNApporte => 'Nog niemand heeft iets aangegeven.';

  @override
  String get pourLaCuisine => 'Voor de keuken';

  @override
  String get precisionApport =>
      'Detail (optioneel): « een chocoladetaart », « 2 flessen sap »…';

  @override
  String get priereExaucee => 'Gebed verhoord';

  @override
  String get quiPeutLeLire => 'Wie mag het lezen?';

  @override
  String get reponseALaPersonne => 'Antwoord aan de persoon';

  @override
  String get reponseAide =>
      'Zichtbaar voor de persoon in de app; ze krijgt een melding.';

  @override
  String get reponseEglise => 'Antwoord van de kerk';

  @override
  String get resterAnonyme => 'Anoniem blijven';

  @override
  String get resterAnonymeAide =>
      'Het voorbedeteam ziet je naam niet (de pastoors wel).';

  @override
  String get retirerDemande => 'Mijn aanvraag intrekken';

  @override
  String get suivreFacebook => 'Facebook';

  @override
  String get suivreYoutube => 'YouTube';

  @override
  String get sujetConfie =>
      'Je gebedsintentie is toevertrouwd. We bidden met je mee.';

  @override
  String get sujetIndisponible => 'Deze gebedsintentie is niet toegankelijk.';

  @override
  String get sujetPriere => 'Gebedsintentie';

  @override
  String get sujetPriereChamp => 'Waarvoor wil je dat we bidden?';

  @override
  String get sujetsPriere => 'Gebedsintenties';

  @override
  String get sujetsPriereSousTitre => 'Alle toevertrouwde intenties (pastoors)';

  @override
  String get supprimerFete => 'Deze aankondiging verwijderen?';

  @override
  String get supprimerSujet => 'Deze gebedsintentie verwijderen?';

  @override
  String get temoignageFacultatif => 'Je getuigenis (optioneel)';

  @override
  String get titreFeteAide => 'Bv.: Verjaardag van Mama Esther';

  @override
  String get toutes => 'Alle';

  @override
  String get typeDemandeQuestion => 'Wat wil je aanvragen?';

  @override
  String get vousAvezPrie => 'Je hebt gebeden. Dank je!';

  @override
  String get demandeBapteme => 'Doop';

  @override
  String get demandePresentation => 'Opdracht van een kind';

  @override
  String get demandeMariage => 'Huwelijk';

  @override
  String get demandeRendezVous => 'Afspraak met een pastoor';

  @override
  String get demandeVisite => 'Huisbezoek';

  @override
  String get statutNouvelle => 'Verzonden';

  @override
  String get statutEnCours => 'In behandeling';

  @override
  String get statutAcceptee => 'Aanvaard';

  @override
  String get statutRefusee => 'Geweigerd';

  @override
  String get statutTerminee => 'Afgerond';

  @override
  String get feteAnniversaire => 'Verjaardag';

  @override
  String get feteNaissance => 'Geboorte';

  @override
  String get feteMariage => 'Huwelijk';

  @override
  String get feteFete => 'Feest';

  @override
  String get feteAutre => 'Andere';

  @override
  String get apportNourriture => 'Eten';

  @override
  String get apportGateau => 'Taart';

  @override
  String get apportBoisson => 'Drank';

  @override
  String get apportAutre => 'Andere';

  @override
  String get groupeCuisine => 'Keuken';

  @override
  String get erreurLecture =>
      'Dit bestand kan niet worden afgespeeld. Controleer je verbinding.';

  @override
  String get reculer15 => '15 seconden terug';

  @override
  String get avancer15 => '15 seconden vooruit';

  @override
  String get pause => 'Pauze';

  @override
  String get lecture => 'Afspelen';

  @override
  String get vitesse => 'Afspeelsnelheid';

  @override
  String get pleinEcran => 'Volledig scherm';

  @override
  String get ajouterLecon => 'Les toevoegen';

  @override
  String get aucunCandidat => 'Geen kandidaten ingeschreven.';

  @override
  String get aucunFichier => 'Geen bestand';

  @override
  String get aucuneLecon => 'Nog geen lessen.';

  @override
  String get aucunePreparation => 'Nog geen voorbereidingen.';

  @override
  String get aucunePreparationType =>
      'Maak eerst een voorbereiding van dit type (Home → Voorbereidingen).';

  @override
  String get aucuneQuestion => 'Geen vragen.';

  @override
  String get aucuneRencontre => 'Geen ontmoetingen gepland.';

  @override
  String candidatInscrit(String nom) {
    return '$nom is ingeschreven voor de voorbereiding.';
  }

  @override
  String get candidats => 'Kandidaten';

  @override
  String get choisirFichier => 'Bestand kiezen';

  @override
  String get descendre => 'Omlaag';

  @override
  String get desinscrire => 'Uitschrijven';

  @override
  String get enAttenteReponse => 'Wacht op het antwoord van de pastoor.';

  @override
  String get fichierAudio => 'Audio';

  @override
  String get fichierDocument => 'Document (PDF)';

  @override
  String get fichierEnvoye => 'Bestand verzonden';

  @override
  String get fichierVideo => 'Video';

  @override
  String get inscrire => 'Inschrijven';

  @override
  String get inscrireCandidat => 'Kandidaat inschrijven';

  @override
  String get inscrirePreparation => 'Inschrijven voor een voorbereiding';

  @override
  String get lecon => 'Les';

  @override
  String get leconPublique => 'Openbare les';

  @override
  String get leconPubliqueAide =>
      'Zichtbaar voor alle leden. Anders alleen voor ingeschreven kandidaten.';

  @override
  String get leconReservee =>
      'Deze les is voorbehouden aan ingeschreven kandidaten.';

  @override
  String get leconTerminee => 'Les afgerond';

  @override
  String get lecons => 'Lessen';

  @override
  String get marquerTerminee => 'Ik heb deze les afgerond';

  @override
  String get mesQuestions => 'Mijn vragen aan de pastoor';

  @override
  String get mesRencontres => 'Mijn ontmoetingen';

  @override
  String get monter => 'Omhoog';

  @override
  String get nouvellePreparation => 'Nieuwe voorbereiding';

  @override
  String get ouvrirDocument => 'Document openen';

  @override
  String get pasInscritPreparation =>
      'De lessen zijn voorbehouden aan kandidaten. Doe een aanvraag: de pastoor schrijft je in.';

  @override
  String get planifier => 'Plannen';

  @override
  String get poserQuestion => 'Een vraag stellen aan de pastoor';

  @override
  String get preparationIndisponible =>
      'Deze voorbereiding is niet toegankelijk.';

  @override
  String get preparations => 'Voorbereidingen';

  @override
  String get preparationsGestionSousTitre => 'Lessen, kandidaten, gesprekken';

  @override
  String get preparationsIntro =>
      'Voorbereiding op het huwelijk en de doop: lessen in tekst, audio en video.';

  @override
  String get preparationsSousTitre => 'Huwelijk en doop';

  @override
  String progression(int faites, int total) {
    return '$faites van $total les(sen) afgerond';
  }

  @override
  String get publierPreparationAide =>
      'Zichtbaar voor de leden (de lessen blijven voorbehouden aan kandidaten).';

  @override
  String get publique => 'openbaar';

  @override
  String get questionEnvoyee => 'Vraag verzonden naar de pastoor.';

  @override
  String get questions => 'Vragen';

  @override
  String get remplacerFichier => 'Bestand vervangen';

  @override
  String get rencontreAide => 'Bv.: Gesprek, Doop, Repetitie van het huwelijk';

  @override
  String get rencontres => 'Ontmoetingen';

  @override
  String get repondre => 'Antwoorden';

  @override
  String get reponseEnvoyee => 'Antwoord verzonden.';

  @override
  String get supprimerLecon => 'Deze les verwijderen?';

  @override
  String get voirPreparations => 'Voorbereidingen bekijken';

  @override
  String get votreQuestion => 'Je vraag';

  @override
  String get votreReponse => 'Je antwoord';

  @override
  String get vousEtesInscrit => 'Je bent ingeschreven';

  @override
  String get ajouterAdmin => 'Beheerder toevoegen';

  @override
  String get ajouterAuPlanning => 'Aan de planning toevoegen';

  @override
  String get aucunService => 'Geen diensten gepland voor jou.';

  @override
  String get aucuneEquipe => 'Je maakt geen deel uit van een dienstteam.';

  @override
  String get autresEquipes => 'Andere teams';

  @override
  String get choisirCulte => 'Kies een dienst of activiteit uit de agenda';

  @override
  String get choisirPersonne => 'Kies de persoon.';

  @override
  String get cultOuEvenement => 'Dienst of activiteit';

  @override
  String get demanderRemplacantService => 'Vervanger vragen';

  @override
  String get demanderRemplacantServiceAide =>
      'De andere teamleden worden verwittigd.';

  @override
  String get equipeIndisponible => 'Dit team bestaat niet meer.';

  @override
  String get jeConfirme => 'Ik bevestig, ik ben er';

  @override
  String get jeNeSuisPasDisponible => 'Ik ben niet beschikbaar';

  @override
  String get jeNeSuisPasDisponibleAide =>
      'De verantwoordelijke van het team wordt verwittigd.';

  @override
  String get membresEtResponsables => 'Leden en verantwoordelijken';

  @override
  String get membresEtResponsablesAide =>
      'Vink de leden aan; « Verantwoordelijke »: maakt de planning van het team.';

  @override
  String get mesEquipes => 'Mijn teams';

  @override
  String get mesServices => 'Mijn komende diensten';

  @override
  String get nomEquipe => 'Naam van het team';

  @override
  String get nomEquipeAide => 'Bv.: Geluid en video, Onthaal, Zondagsschool';

  @override
  String get nouvelleEquipe => 'Nieuw team';

  @override
  String get planning => 'Dienstenplanning';

  @override
  String get planningServices => 'Dienstenplanning';

  @override
  String get planningServicesSousTitre => 'Teams, wie dient bij welke dienst';

  @override
  String get planningSousTitre => 'Mijn diensten en mijn teams';

  @override
  String get planningVide => 'Momenteel niets gepland.';

  @override
  String get poste => 'Taak (optioneel)';

  @override
  String get posteAide => 'Bv.: Mengtafel, Onthaal aan de deur';

  @override
  String get quiSert => 'Wie dient?';

  @override
  String remplaceNom(String nom) {
    return 'Vervangt $nom';
  }

  @override
  String get repondreService => 'Bevestigen of afzeggen';

  @override
  String get responsable => 'Verantwoordelijke';

  @override
  String get responsableEquipe => 'Verantwoordelijke van het team';

  @override
  String get retirerDeLEquipe => 'Uit het team verwijderen';

  @override
  String get supprimerEquipe => 'Dit team en zijn planning verwijderen?';

  @override
  String get servicePrevu => 'Gepland (te bevestigen)';

  @override
  String get serviceConfirme => 'Bevestigd';

  @override
  String get serviceIndisponible => 'Niet beschikbaar';

  @override
  String get serviceRemplacement => 'Vervanger gezocht';

  @override
  String get exhortations => 'Bemoedigingen';

  @override
  String get exhortation => 'Bemoediging';

  @override
  String get ajouterExhortation => 'Bemoediging toevoegen';

  @override
  String get aucuneExhortation => 'Nog geen bemoedigingen.';

  @override
  String get entretienSalle => 'Onderhoud van de zaal';

  @override
  String get entretienSousTitre => 'Schrijf je in voor de schoonmaak';

  @override
  String get entretienIntro =>
      'Help onze zaal proper te houden: schrijf je in voor een schoonmaakbeurt.';

  @override
  String get nouvelleSeanceNettoyage => 'Nieuwe beurt';

  @override
  String get aucuneSeanceNettoyage => 'Geen schoonmaakbeurten gepland.';

  @override
  String inscritsNettoyage(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n personen ingeschreven',
      one: '1 persoon ingeschreven',
      zero: 'Nog niemand ingeschreven',
    );
    return '$_temp0';
  }

  @override
  String inscritsNettoyageSur(int n, int max) {
    return '$n ingeschreven op $max gewenst';
  }

  @override
  String get jeViensNettoyer => 'Ik kom helpen';

  @override
  String get inscritAnnuler => 'Ingeschreven — annuleren';

  @override
  String get titreNettoyageDefaut => 'Schoonmaak van de zaal';

  @override
  String get personnesSouhaitees => 'Gewenst aantal personen';

  @override
  String get reserverSalle => 'Zaal reserveren';

  @override
  String get reserverSalleSousTitre => 'Vrije momenten bekijken en aanvragen';

  @override
  String get sallesEtReservations => 'Zalen en reservaties';

  @override
  String get sallesEtReservationsSousTitre =>
      'Aanvragen goedkeuren, zalen beheren';

  @override
  String get nouvelleSalle => 'Nieuwe zaal';

  @override
  String get salles => 'Zalen';

  @override
  String get aucuneSalle => 'Geen zalen geregistreerd.';

  @override
  String get nomSalle => 'Naam van de zaal';

  @override
  String get capacite => 'Capaciteit (personen)';

  @override
  String capacitePersonnes(int n) {
    return '$n personen';
  }

  @override
  String get mesReservations => 'Mijn reservaties';

  @override
  String get aucuneReservation => 'Geen komende reservaties.';

  @override
  String get annulerReservation => 'Reservatie annuleren';

  @override
  String get reservationsAValider => 'Goed te keuren reservaties';

  @override
  String get aucuneReservationAValider => 'Geen reservatieaanvragen.';

  @override
  String get reservationDemandee => 'Wacht op goedkeuring';

  @override
  String get reservationValidee => 'Goedgekeurd';

  @override
  String get reservationRefusee => 'Geweigerd';

  @override
  String get reservationAnnulee => 'Geannuleerd';

  @override
  String get salleIndisponible => 'Deze zaal bestaat niet meer.';

  @override
  String get creneauxReserves => 'Al gereserveerd';

  @override
  String get aucunCreneauReserve =>
      'Geen komende reservaties: de zaal is vrij.';

  @override
  String get demanderReservation => 'Reservatie aanvragen';

  @override
  String get motifReservation => 'Waarvoor?';

  @override
  String get motifReservationAide => 'Bv.: Repetitie van het koor';

  @override
  String get motifObligatoire => 'Geef aan waarvoor je reserveert.';

  @override
  String get creneauDejaPris => 'Dit moment is al gereserveerd.';

  @override
  String creneauDejaPrisPar(String motifs) {
    return 'Al gereserveerd: $motifs';
  }

  @override
  String get envoyerDemandeReservation => 'Aanvraag versturen';

  @override
  String get reservationEnvoyee => 'Aanvraag verzonden naar het secretariaat.';

  @override
  String demandeePar(String nom) {
    return 'Aangevraagd door $nom';
  }

  @override
  String conflitAvec(String autres) {
    return 'Conflict met: $autres';
  }

  @override
  String get refuser => 'Weigeren';

  @override
  String get versetDuJour => 'Vers van de dag';

  @override
  String get direct => 'Livestream';

  @override
  String get enDirectMaintenant => 'Nu live';

  @override
  String get regarderDirect => 'Livestream bekijken';

  @override
  String get audios => 'Audio';

  @override
  String get videos => 'Video\'s';

  @override
  String get aucunMedia => 'Nog geen preken.';

  @override
  String get mediaIndisponible => 'Dit medium is niet beschikbaar.';

  @override
  String get regarderSurYoutube => 'Bekijken';

  @override
  String get envoyerSurWhatsApp => 'Via WhatsApp versturen';

  @override
  String get gestionMedias => 'Media';

  @override
  String get gestionMediasSousTitre =>
      'Preken, bemoedigingen, livestreams, verzen';

  @override
  String get predicationsEtDirects => 'Preken en livestreams';

  @override
  String get versetsDuJour => 'Verzen van de dag';

  @override
  String get nouveauMedia => 'Nieuw medium';

  @override
  String get versetsAide =>
      'Eén vers per dag, in deze volgorde, telkens opnieuw.';

  @override
  String get aucunVerset => 'Geen verzen. Voeg er enkele toe.';

  @override
  String get ajouterVerset => 'Vers toevoegen';

  @override
  String get referenceBiblique => 'Referentie';

  @override
  String get audio => 'Audio';

  @override
  String get video => 'Video';

  @override
  String get predicateur => 'Prediker';

  @override
  String get debutDirect => 'Begin van de livestream';

  @override
  String get lienDirect => 'Link van de livestream (YouTube of Facebook)';

  @override
  String get ouLienYoutube => 'Of YouTube- / Facebooklink (optioneel)';

  @override
  String get fichierOuLienRequis => 'Stuur een bestand of geef een link op.';

  @override
  String get dimesEtOffrandes => 'Tienden en giften';

  @override
  String get donner => 'Geven';

  @override
  String get donsVerset =>
      '“Laat ieder geven zoals hij zich in zijn hart heeft voorgenomen, niet met tegenzin of uit dwang, want God heeft de blijmoedige gever lief.” 2 Korintiërs 9:7';

  @override
  String get donsConnexionTexte =>
      'Meld je aan om te geven en je giften op te volgen.';

  @override
  String get donsSurLeSiteTexte =>
      'Op iPhone geef je via de website van de kerk. Meld je aan met hetzelfde account: je giften verschijnen hier.';

  @override
  String get donnerSurLeSite => 'Geven op de website van de kerk';

  @override
  String get montant => 'Bedrag';

  @override
  String get autreMontant => 'Ander bedrag';

  @override
  String get montantEnEuros => 'Bedrag in euro';

  @override
  String get montantInvalide => 'Geef een bedrag tussen 1 en 10.000 €.';

  @override
  String get affectationDon => 'Voor';

  @override
  String get affectationDime => 'Tiende';

  @override
  String get affectationOffrande => 'Offergave';

  @override
  String get affectationMission => 'Zending';

  @override
  String get affectationConstruction => 'Bouwproject';

  @override
  String get affectationEntraide => 'Onderlinge hulp';

  @override
  String get uneFois => 'Eenmalig';

  @override
  String get chaqueMois => 'Elke maand';

  @override
  String get donMensuelAide =>
      'De maandelijkse gift gebeurt met een kaart. Je kunt hem hier op elk moment stopzetten.';

  @override
  String get donnerParVirement => 'Overschrijving (QR-code)';

  @override
  String get donnerEnLigne => 'Bancontact of kaart';

  @override
  String get donnerChaqueMois => 'Elke maand geven met kaart';

  @override
  String get paiementImpossible =>
      'De betaling kon niet starten. Probeer later opnieuw.';

  @override
  String get mesDons => 'Mijn giften';

  @override
  String get aucunDon => 'Nog geen giften.';

  @override
  String get mesDonsMensuels => 'Mijn maandelijkse giften';

  @override
  String get arreter => 'Stoppen';

  @override
  String get arreterDonMensuelTitre => 'Deze maandelijkse gift stoppen?';

  @override
  String get arreterDonMensuelTexte =>
      'Er wordt niets meer afgehouden. Bedankt voor je trouw!';

  @override
  String get donMensuelArrete => 'Maandelijkse gift gestopt.';

  @override
  String get donEnAttente => 'in afwachting';

  @override
  String get donRecu => 'ontvangen';

  @override
  String get donAnnule => 'geannuleerd';

  @override
  String get modeVirement => 'overschrijving';

  @override
  String get modeEnLigne => 'online';

  @override
  String get modeMensuel => 'maandelijks';

  @override
  String get virementTitre => 'Overschrijving';

  @override
  String get virementAide =>
      'Scan deze QR-code met je bankapp, of neem de gegevens hieronder over. De gestructureerde mededeling is noodzakelijk.';

  @override
  String get virementAttenteAide =>
      'De penningmeester bevestigt de ontvangst zodra de overschrijving op de rekening staat.';

  @override
  String get qrVirement => 'QR-code van de overschrijving';

  @override
  String get beneficiaire => 'Begunstigde';

  @override
  String get iban => 'IBAN';

  @override
  String get bic => 'BIC';

  @override
  String get communicationStructuree => 'Gestructureerde mededeling';

  @override
  String get copier => 'Kopiëren';

  @override
  String get copie => 'Gekopieerd.';

  @override
  String get coordonneesIndisponibles =>
      'Overschrijven is nog niet mogelijk: de penningmeester moet eerst de rekening van de kerk invullen.';

  @override
  String get donIntrouvable => 'Deze gift werd niet gevonden.';

  @override
  String get renoncerDon => 'Ik zie af van deze gift';

  @override
  String get merciDon => 'Bedankt voor je vrijgevigheid!';

  @override
  String get releveAnnuel => 'Jaaroverzicht';

  @override
  String get anneePrecedente => 'Vorig jaar';

  @override
  String get anneeSuivante => 'Volgend jaar';

  @override
  String get totalRecu => 'Totaal ontvangen';

  @override
  String get aucunDonCetteAnnee => 'Dit jaar geen giften ontvangen.';

  @override
  String get releveAvertissement =>
      'Dit overzicht vat je giften samen die de kerk ontving. Het is geen fiscaal attest.';

  @override
  String get partager => 'Delen';

  @override
  String get tresorerie => 'Penningmeester';

  @override
  String get tresorerieSousTitre =>
      'Te bevestigen overschrijvingen, giften van het jaar, export';

  @override
  String get aConfirmer => 'Te bevestigen';

  @override
  String get donsDeLAnnee => 'Giften van het jaar';

  @override
  String get coordonneesBancaires => 'Bankrekening van de kerk';

  @override
  String get coordonneesAManquer =>
      'Vul de bankrekening van de kerk in om overschrijvingen mogelijk te maken.';

  @override
  String get completer => 'Aanvullen';

  @override
  String get rechercherCommunication => 'Mededeling of naam';

  @override
  String get aConfirmerAide =>
      'Neem de mededeling van een rekeninguittreksel over om de overschrijving te vinden en markeer ze als ontvangen.';

  @override
  String get rienAConfirmer => 'Geen overschrijvingen te bevestigen.';

  @override
  String get marquerRecu => 'Ontvangen';

  @override
  String get parDonateur => 'Per gever';

  @override
  String get tousLesDons => 'Alle giften';

  @override
  String get entetesCsvDons =>
      'Datum,Naam,Bestemming,Wijze,Bedrag (€),Mededeling';

  @override
  String get coordonneesAide =>
      'Deze gegevens staan op de overschrijvingsinstructies (giften en boeken). Iedereen kan ze zien.';

  @override
  String get titulaireCompte => 'Rekeninghouder';

  @override
  String get ibanInvalide => 'Ongeldig IBAN.';

  @override
  String get bicFacultatif => 'BIC (optioneel)';

  @override
  String get boutique => 'Winkel';

  @override
  String get boutiqueAide =>
      'Boeken af te halen in de kerk. Betalen met Bancontact, kaart of overschrijving.';

  @override
  String get boutiqueVide => 'Nog geen boeken.';

  @override
  String get livreIndisponible => 'Dit boek is niet beschikbaar.';

  @override
  String get livreEpuise => 'Uitverkocht';

  @override
  String get ajouterAuPanier => 'In winkelmandje';

  @override
  String get retraitEglise => 'Af te halen in de kerk na betaling.';

  @override
  String get panier => 'Winkelmandje';

  @override
  String get panierVide => 'Je winkelmandje is leeg.';

  @override
  String get panierInvalide =>
      'Een boek is niet meer beschikbaar. Controleer je winkelmandje.';

  @override
  String get enleverUn => 'Eén minder';

  @override
  String get ajouterUn => 'Eén meer';

  @override
  String get seConnecterPourCommander => 'Aanmelden om te bestellen';

  @override
  String get payerEnLigne => 'Betalen met Bancontact of kaart';

  @override
  String get payerParVirement => 'Betalen via overschrijving (QR-code)';

  @override
  String get mesCommandes => 'Mijn bestellingen';

  @override
  String get aucuneCommande => 'Geen bestellingen.';

  @override
  String get commande => 'Bestelling';

  @override
  String get commandes => 'Bestellingen';

  @override
  String get livres => 'Boeken';

  @override
  String get commandeIntrouvable => 'Deze bestelling werd niet gevonden.';

  @override
  String get commandeEnAttente => 'Wacht op betaling';

  @override
  String get commandePayee => 'Betaald, af te halen';

  @override
  String get commandeRemise => 'Afgehaald';

  @override
  String get commandeAnnulee => 'Geannuleerd';

  @override
  String get annulerCommande => 'Bestelling annuleren';

  @override
  String get paiementEnLigneAttente =>
      'Betaling bezig. Als je de betaalpagina hebt gesloten, bestel dan opnieuw via de winkel.';

  @override
  String get suiviCommande => 'Opvolging van de bestelling';

  @override
  String get gestionBoutiqueSousTitre => 'Bestellingen en boekencatalogus';

  @override
  String get nouveauLivre => 'Nieuw boek';

  @override
  String get supprimerLivre => 'Dit boek verwijderen?';

  @override
  String get couverture => 'Omslag';

  @override
  String get auteur => 'Auteur';

  @override
  String get prix => 'Prijs';

  @override
  String get prixInvalide => 'Geef een prijs tussen 1 en 1.000 €.';

  @override
  String get description => 'Beschrijving';

  @override
  String get livreDisponible => 'Te koop';

  @override
  String voirPanier(int n) {
    return 'Winkelmandje ($n)';
  }

  @override
  String nombreLivres(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n boeken',
      one: '1 boek',
    );
    return '$_temp0';
  }

  @override
  String nombreDons(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n giften',
      one: '1 gift',
      zero: 'Geen giften',
    );
    return '$_temp0';
  }

  @override
  String donsMensuelsActifs(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lopende maandelijkse giften',
      one: '1 lopende maandelijkse gift',
    );
    return '$_temp0';
  }

  @override
  String parMois(String montant) {
    return '$montant per maand';
  }

  @override
  String releveTitre(String annee) {
    return 'Overzicht van mijn giften $annee';
  }

  @override
  String get total => 'Totaal';

  @override
  String get politiqueConfidentialite => 'Privacy';

  @override
  String get conditionsUtilisation => 'Gebruiksvoorwaarden';

  @override
  String get aideEtContact => 'Hulp en contact';

  @override
  String get photoProfil => 'Profielfoto';

  @override
  String get langueApp => 'Taal van de app en de meldingen';

  @override
  String get langueTelephone => 'Telefoon';

  @override
  String get telechargerMesDonnees => 'Mijn gegevens downloaden';

  @override
  String get telechargerMesDonneesAide =>
      'Een bestand met alles wat de app over jou weet.';

  @override
  String get supprimerMonCompte => 'Mijn account verwijderen';

  @override
  String get supprimerCompteTitre => 'Je account verwijderen?';

  @override
  String get supprimerCompteTexte =>
      'Je profiel, berichten, aanvragen, gebedsintenties en inschrijvingen worden definitief gewist. Je giften blijven zonder je naam in de boekhouding van de kerk; een maandelijkse gift wordt gestopt. Je fiche in het ledenregister blijft bij het secretariaat.';

  @override
  String get supprimerDefinitivement => 'Definitief verwijderen';

  @override
  String get compteSupprime => 'Je account is verwijderd.';

  @override
  String get suppressionDernierAdmin =>
      'Je bent de enige beheerder: stel eerst een andere beheerder aan (Leiding → Rollen).';

  @override
  String get suppressionCommandeARetirer =>
      'Een betaald boek moet nog in de kerk afgehaald worden. Haal het eerst af of neem contact op met het secretariaat.';

  @override
  String get emailContact => 'Contact-e-mail van de kerk';

  @override
  String get emailContactAide =>
      'Vermeld in het privacybeleid en de hulppagina.';

  @override
  String get emailInvalide => 'Ongeldig e-mailadres.';

  @override
  String get editeurReleve =>
      'Centre Évangélique d\'Hoegaarden vzw · KBO 0557.986.857 · Vroentestraat 100, 3320 Hoegaarden';

  @override
  String get entetesReleve => 'Datum,Bestemming,Wijze,Bedrag';

  @override
  String releveEmisLe(String date) {
    return 'Overzicht opgemaakt op $date.';
  }
}
