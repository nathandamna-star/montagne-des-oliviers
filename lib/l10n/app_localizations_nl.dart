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
  String get slogan => 'Een familie in het geloof, in Tienen';

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
}
