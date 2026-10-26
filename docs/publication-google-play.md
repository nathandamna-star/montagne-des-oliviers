# Publier l'app sur Google Play (Android)

Choix du porteur (26/10/2026) : **compte Google Play de Nathan Damna** (personnel) ; **dons masqués** dans
l'app Android comme sur iPhone (`donsVisiblesProvider` = site seulement). La boutique de livres papier reste.

Déjà prêt dans le code : identifiant `be.montagnedesoliviers.app`, nom « Montagne des Oliviers », app Android
déclarée dans Firebase, signature de publication lue dans `android/key.properties` (jamais dans le dépôt,
`.gitignore`). Numéro de version : `version:` du pubspec (le nombre après `+` = versionCode, à augmenter).

## 1. Compte Google Play (une fois)
play.google.com/console › compte **personnel**, 25 $ une fois, vérification d'identité (pièce d'identité).
Compte personnel récent : **test fermé obligatoire avec au moins 12 testeurs pendant 14 jours** avant la
production (Tests › Test fermé, liste d'e-mails Gmail de membres de l'église, qui installent l'app par le lien).

## 2. Clé de signature (Mac, une fois — à garder précieusement)
```
keytool -genkey -v -keystore ~/montagne-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Puis créer `~/montagne-des-oliviers/android/key.properties` :
```
storePassword=<mot de passe choisi>
keyPassword=<mot de passe choisi>
keyAlias=upload
storeFile=/Users/<nom>/montagne-upload.jks
```
Ne jamais envoyer ce fichier ni les mots de passe (ni dans une conversation, ni dans le dépôt). Copie de
sauvegarde du `.jks` sur une clé USB.

## 3. Construire
```
cd ~/montagne-des-oliviers && git pull && flutter build appbundle --release
```
Fichier : `build/app/outputs/bundle/release/app-release.aab`.

## 4. Fiche Play Store
Créer l'app (gratuite, app, français). Fiche : même description que l'App Store (sans les dons), icône 512,
bannière 1024 × 500, captures téléphone 1080 × 1920 (`outils/captures_stores_test.dart.txt`, taille `android`).
Contenu de l'app : confidentialité https://montagne-des-oliviers.web.app/legal/confidentialite ; accès à l'app
= compte de démonstration revue.apple.mdo@gmail.com ; publicités : non ; classification (questionnaire :
contenu généré par les utilisateurs, oui) ; public cible : 18 ans et plus ; sécurité des données (nom, e-mail,
téléphone, photos, messages, convictions religieuses, identifiants, achats ; chiffrées en transit ;
suppression possible dans l'app) ; suppression du compte : URL de l'aide.

## 5. Connexion Google sur Android
Après le premier envoi : Play Console › Intégrité de l'app › **Signature d'application** : copier les
empreintes **SHA-1** et **SHA-256** (clé de signature d'application ET clé d'importation) dans Firebase ›
Paramètres du projet › app Android › Ajouter une empreinte. Sans cela, « Se connecter avec Google » échoue.
