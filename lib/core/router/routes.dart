abstract final class Routes {
  static const accueil = '/accueil';
  static const agenda = '/agenda';
  static const groupes = '/groupes';
  static const medias = '/medias';
  static const profil = '/profil';
  static const responsables = '/responsables';
  static const connexion = '/connexion';
  static const connexionEmail = '/connexion/email';
  static const consentement = '/connexion/profil';
  static const roles = '/responsables/roles';
  static const actualites = '/accueil/actualites';
  static const gestionActualites = '/responsables/actualites';
  static const gestionAgenda = '/responsables/agenda';
  static const membres = '/responsables/membres';
  static const familles = '/responsables/familles';

  static String ficheMembre(String id) => '/responsables/membres/$id';
  static String famille(String id) => '/responsables/familles/$id';

  static String actualite(String id) => '/accueil/actualites/$id';
  static String evenement(String id) => '/agenda/$id';
  static String editerActualite(String id) => '/responsables/actualites/$id';
  static String editerEvenement(String id) => '/responsables/agenda/$id';
}
