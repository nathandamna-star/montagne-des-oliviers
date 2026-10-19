# Publier l'app sur l'App Store (iPhone et iPad)

Choix du porteur (19/10/2026) : publication avec **le compte Apple Developer de Nathan Damna**
(équipe `3WHNDT7LP4`, déjà actif), sur **iPhone et iPad**. L'app pourra être transférée plus tard au
compte de l'église (ASBL) sans perdre les utilisateurs (App Store Connect › l'app › « Transférer l'app »).

Déjà prêt dans le code :
- identifiant `be.montagnedesoliviers.app`, nom affiché « Montagne des Oliviers », version `1.0.0+1` ;
- équipe de signature `3WHNDT7LP4`, droits « Notifications » et « Connexion avec Apple »
  (`ios/Runner/Runner.entitlements`) ;
- iPhone et iPad (toutes les orientations sur iPad), iOS 15 minimum ;
- textes d'autorisation (photos, appareil photo), chiffrement déclaré « non » (`ITSAppUsesNonExemptEncryption`) ;
- **dons** : sur iPhone / iPad, le bouton ouvre le **site de l'église** dans Safari (règle 3.2.2 d'Apple :
  une organisation non reconnue par Apple ne collecte pas de dons dans l'app) ; la **boutique** vend des
  livres papier (bien physique : paiement Stripe autorisé) ;
- suppression du compte depuis l'app (Profil), pages légales en ligne.

## 1. Clé des notifications (une seule fois)

1. developer.apple.com › Certificates, Identifiers & Profiles › **Keys** › « + ».
2. Nom : `Montagne des Oliviers APNs`, cocher **Apple Push Notifications service (APNs)** › Continue ›
   Register › **Download** (fichier `.p8`, téléchargeable une seule fois). Noter le **Key ID**.
3. Console Firebase › projet `montagne-des-oliviers` › ⚙ Paramètres du projet › **Cloud Messaging** ›
   app Apple `be.montagnedesoliviers.app` › **Clé d'authentification APNs** › Importer : le fichier `.p8`,
   le Key ID et l'ID d'équipe `3WHNDT7LP4`.

Le fichier `.p8` est une clé secrète : ne jamais l'envoyer dans une conversation ni le mettre dans le dépôt.

## 2. Construire et envoyer l'app (Mac)

```
cd ~ && git clone https://github.com/nathandamna-star/montagne-des-oliviers.git   # première fois
cd ~/montagne-des-oliviers && git pull
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

Dans Xcode : cible **Runner** › Signing & Capabilities : « Automatically manage signing », Team
**Nathan Damna** (Xcode enregistre l'identifiant et les droits tout seul). En haut : destination
**Any iOS Device (arm64)** › menu **Product › Archive** › Distribute App › **App Store Connect** › Upload.
À chaque nouvel envoi : augmenter le numéro après le `+` dans `pubspec.yaml` (1.0.0+2, +3…).

## 3. Créer l'app dans App Store Connect

Apps › « + » › Nouvelle app : plateforme **iOS**, nom **Montagne des Oliviers** (si déjà pris :
« Montagne des Oliviers Tienen »), langue principale **Français**, identifiant de lot
`be.montagnedesoliviers.app`, UGS `montagne-des-oliviers`, accès complet.

Fiche (Français ; ajouter la localisation **Néerlandais** avec les mêmes champs traduits) :
- Sous-titre : `Centre Évangélique · Tienen`
- Catégorie : **Style de vie** (secondaire : Références)
- URL d'assistance : https://montagne-des-oliviers.web.app/legal/aide
- URL de confidentialité : https://montagne-des-oliviers.web.app/legal/confidentialite
- Copyright : `2026 Centre Évangélique d'Hoegaarden ASBL`
- Prix : gratuit ; disponibilité : tous les pays.
- Captures (Simulateur, Cmd + S) : **iPhone 6,9 pouces** (iPhone 16 Pro Max, 1320 × 2868) et
  **iPad 13 pouces** (iPad Pro 13", 2064 × 2752) : Accueil, Agenda, Médias, Groupes, Dons.
- Classification par âge : contenu généré par les utilisateurs / messagerie : **oui** ; le reste : non.

Confidentialité de l'app (« étiquettes ») : données **liées à l'utilisateur**, **aucun pistage** :
coordonnées (nom, e-mail, téléphone), contenu utilisateur (messages, photos, sujets de prière),
identifiants (identifiant du compte, de l'appareil pour les notifications), informations sensibles
(convictions religieuses), historique d'achats (dons et commandes de livres). Finalité : fonctionnement
de l'app.

## 4. Informations pour la vérification

Compte de démonstration : créer un compte **dédié** (par exemple `revue.apple.mdo@gmail.com`) avec
le rôle **membre**, jamais un compte personnel ni administrateur. Remarques (en anglais) :

> This is the private app of the Centre Évangélique Montagne des Oliviers, a church in Tienen (Belgium).
> Members read news, the church calendar, sermons, join private groups, send prayer requests and
> requests (baptism, wedding, appointment). The demo account is a regular member.
> Donations: on iPhone and iPad the app does not collect donations; the "Donner sur le site de l'église"
> button opens the church website in Safari (guideline 3.2.2). The bookshop sells printed books picked
> up at the church (physical goods). Account deletion: Profil > Supprimer mon compte.

Puis : version 1.0 › ajouter le build › **Ajouter pour vérification** › Brouillons de soumissions ›
Soumettre.

## Risque connu

Les **groupes** (discussion avec photos) et les sujets de prière sont du contenu publié par les membres.
La règle 1.2 d'Apple demande de pouvoir **signaler** un contenu et **bloquer** une personne. Ce n'est pas
encore dans l'app : Apple peut le demander. À ajouter si Apple refuse (ou avant l'envoi, au choix du
porteur).
