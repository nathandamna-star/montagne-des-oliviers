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
  static const preparations = '/accueil/preparations';
  static const planning = '/accueil/planning';
  static const entretien = '/accueil/entretien';
  static const gestionMedias = '/responsables/medias';
  static String media(String id) => '/medias/$id';
  static String editerMedia(String id) => '/responsables/medias/$id';
  static const salles = '/accueil/salles';
  static const dons = '/accueil/dons';
  static const releveDons = '/accueil/dons/releve';
  static String virementDon(String id) => '/accueil/dons/virement/$id';
  static const boutique = '/accueil/boutique';
  static const panier = '/accueil/boutique/panier';
  static String livre(String id) => '/accueil/boutique/$id';
  static const mesCommandes = '/profil/commandes';
  static String commande(String id) => '/profil/commandes/$id';
  static const tresorerie = '/responsables/tresorerie';
  static const coordonneesBancaires = '/responsables/tresorerie/coordonnees';
  static const gestionBoutique = '/responsables/boutique';
  static String editerLivre(String id) => '/responsables/boutique/$id';
  static const reservationsAValider = '/accueil/salles/a-valider';
  static String salle(String id) => '/accueil/salles/$id';
  static String equipe(String id) => '/accueil/planning/equipes/$id';
  static String editerEquipe(String id) =>
      '/accueil/planning/equipes/$id/modifier';
  static String editerAffectation(String id, String aid) =>
      '/accueil/planning/equipes/$id/services/$aid';
  static String preparation(String id) => '/accueil/preparations/$id';
  static String editerPreparation(String id) =>
      '/accueil/preparations/$id/modifier';
  static String lecon(String id, String lid) =>
      '/accueil/preparations/$id/lecons/$lid';
  static String editerLecon(String id, String lid) =>
      '/accueil/preparations/$id/lecons/$lid/modifier';
  static String candidat(String id, String uid) =>
      '/accueil/preparations/$id/candidats/$uid';
  static const gestionActualites = '/responsables/actualites';
  static const gestionAgenda = '/responsables/agenda';
  static const membres = '/responsables/membres';
  static const familles = '/responsables/familles';
  static const gestionGroupes = '/responsables/groupes';
  static const nouveauGroupe = '/responsables/groupes/nouveau';

  static String groupe(String id) => '/groupes/$id';
  static String discussion(String id) => '/groupes/$id/discussion';
  static String modifierGroupe(String id) => '/groupes/$id/modifier';
  static String calendrier(String id) => '/groupes/$id/calendrier';
  static String prieresGroupe(String id) => '/groupes/$id/prieres';
  static String priereGroupe(String id, String pid) =>
      '/groupes/$id/prieres/$pid';
  static const mesDemandes = '/profil/demandes';
  static const nouvelleDemande = '/profil/demandes/nouvelle';
  static String maDemande(String id) => '/profil/demandes/$id';
  static const mesPrieres = '/profil/prieres';
  static const nouvellePriere = '/profil/prieres/nouvelle';
  static String maPriere(String id) => '/profil/prieres/$id';
  static const gestionDemandes = '/responsables/demandes';
  static String gererDemande(String id) => '/responsables/demandes/$id';
  static const gestionPrieres = '/responsables/prieres';
  static String gererPriere(String id) => '/responsables/prieres/$id';
  static const parametres = '/responsables/parametres';
  static String rencontre(String id, String rid) =>
      '/groupes/$id/calendrier/$rid';
  static String editerRencontre(String id, String rid) =>
      '/groupes/$id/calendrier/$rid/modifier';

  static String ficheMembre(String id) => '/responsables/membres/$id';
  static String famille(String id) => '/responsables/familles/$id';

  static String actualite(String id) => '/accueil/actualites/$id';
  static String evenement(String id) => '/agenda/$id';
  static String fete(String id) => '/agenda/divers/$id';
  static String editerFete(String id) => '/agenda/divers/$id/modifier';
  static String editerActualite(String id) => '/responsables/actualites/$id';
  static String editerEvenement(String id) => '/responsables/agenda/$id';
}
