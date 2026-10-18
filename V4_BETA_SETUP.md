# VISION PRO V4.0.0 - NOVA / BETA

Cette version contient deux scripts complets :
- **VISION_PRO.lua** : interface V4, modules locaux existants et fenetre de saisie de cle beta.
- **VISION_BETA_SERVER.lua** : controle de cle **sur le serveur de ton jeu Roblox**.

## Installation (Roblox Studio)

1. Ouvre **ton propre jeu** dans Roblox Studio.
2. Dans **ServerScriptService**, ajoute un **Script** appele `VisionProBetaServer`. Colle-y le code complet de `VISION_BETA_SERVER.lua`.
3. Dans **ce script prive de Studio uniquement**, ajoute tes cles dans `BETA_KEYS`. Ne publie JAMAIS ta liste de cles dans GitHub, un LocalScript, ou ReplicatedStorage.
4. Pour une production multi-serveurs, garde `USE_DATASTORE = true`. **Publie le jeu** puis active l'acces aux services API dans les parametres de securite de Roblox Studio si tu testes les DataStores dans Studio. Sans DataStore fonctionnel, le serveur refuse l'activation (fail closed).
5. Dans **StarterPlayer > StarterPlayerScripts**, ajoute un **LocalScript** `VisionProClient` et colle le code complet de `VISION_PRO.lua`.
6. Lance le jeu avec **Play**. Entre une cle configuree. Apres validation, le panneau V4 s'ouvre.
7. Le serveur cree automatiquement `ReplicatedStorage.VisionProBetaAccess` (RemoteFunction). Tu n'as rien a creer manuellement dans ReplicatedStorage.

Exemple de configuration **a garder privee** :

```lua
local BETA_KEYS = {
    ["VP4-REMPLACE-CETTE-CLE-PUBLIQUE-PAR-UNE-CLE-ALEATOIRE-LONGUE"] = {
        Id = "beta-wave-001",
        ExpiresAt = 0,
        MaxUsers = 5,
        AllowedUserIds = nil
    }
}
```

**Remplace la chaine d'exemple** par une cle aleatoire longue et privee. Pour une expiration, utilise un timestamp Unix a la place de 0. Pour restreindre aux testeurs, `AllowedUserIds = {[123456789] = true}` avec leurs vrais UserIds.

## Apercu de l'interface V4 en Studio (sans cle)

Si tu veux d'abord **voir le design V4**, mets `ALLOW_STUDIO_PREVIEW = true` dans **ta copie privee du script serveur**, puis lance **Play dans Roblox Studio**. Le serveur autorise alors uniquement la session Studio, sans cle beta. **Remets `false` avant de publier/tester l'acces beta reel.** Le parametre est deja `false` dans le fichier public, pour eviter un acces par defaut.

## Comment fonctionne la verification

- L'interface affiche un ecran d'activation avant d'initialiser les modules locaux.
- `status` demande au serveur si ce joueur dispose deja d'un acces.
- `activate` transmet la cle au serveur et recoit un resultat (valide, refusee, expiree, pleine, etc.).
- Les cles sont definies exclusivement dans le script serveur prive.
- `MaxUsers` compte les comptes distincts via DataStore; `ExpiresAt` permet l'expiration.
- Le serveur limite les essais consecutifs.

## Limites de securite

La verification serveur controle **le flux d'acces du client officiel**. Un script client distribue publiquement est toujours modifiable. Pour proteger des **actions de jeu sensibles**, celles-ci doivent aussi etre autorisees et executees par des Scripts dans ServerScriptService. Les simulations de cette version (mannequins, impacts, ESP local) demeurent locales. N'utilise pas la validation du menu comme un systeme anti-triche serveur.

Le chargeur `loadstring(game:HttpGet(...))()` n'est pas une methode standard pour les LocalScripts dans Roblox Studio. Pour un jeu Roblox, copie le contenu complet dans le LocalScript indique ci-dessus.

## Depannage

- **Service beta absent** : verifie que le Script serveur est place dans ServerScriptService, actif et sans erreurs; teste dans ton propre jeu.
- **Verification serveur indisponible** : verifie l'acces DataStore et la console **F9**.
- **Cle invalide** : verifie la cle configuree cote serveur; aucun code secret n'est inclus dans la version publique.
- **Le menu ne se charge pas** : consulte la console F9 pour le message `VISION PRO V4 / UNLOCKED STARTUP`.
- **CoreGui** : la V4 utilise `PlayerGui` pour l'interface; elle ne devrait pas necessiter de modifier le CoreGui Roblox.

Il n'y a pas de cle active par defaut : **la V4 reste verrouillee tant que tu n'as pas configure le serveur**, conformement a son fonctionnement beta.
