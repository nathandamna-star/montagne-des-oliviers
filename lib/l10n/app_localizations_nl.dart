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
}
