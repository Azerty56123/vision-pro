# VISION HUB V10 — Interface, clés et tests

## Script V10 (loadstring)
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VisionHub_V10_HoHo_Rayz.lua"))()
```

## Mode TEST (sans Cloudflare)
- Clé de développement : `VISION-TEST-ILLIMITE-2026`
- Dans le menu, `GET KEY` remplit la clé de test puis `SUBMIT KEY` ouvre le hub.
- Attention : cette clé est publique dans le code et **n'est pas un mécanisme de sécurité**. Supprime-la avant diffusion réelle.

## Mode vraies clés de 24 h
Le Worker `beta-generator/worker.js` possède la page publique `/key`, l'API `POST /api/public/generate` et l'API `POST /api/verify`. Le site limite les créations publiques à trois par adresse IP sur 24 h. La validation réussie consomme une activation. Le serveur **n'est pas déployé par ces commits GitHub**.

### Installer le service Cloudflare
Depuis PowerShell (Node.js requis) :
1. Cloner ce dépôt ou ouvrir le dossier `beta-generator`.
2. `npx wrangler login`
3. `npx wrangler d1 create vision-pro-beta`
4. Remplacer `REPLACE_WITH_DATABASE_ID` dans `beta-generator/wrangler.toml` par l'identifiant renvoyé.
5. Dans le dossier `beta-generator`, lancer :
   ```powershell
   npx wrangler d1 execute vision-pro-beta --remote --file=./schema.sql
   ```
6. Générer un jeton secret fort localement :
   ```powershell
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```
7. `npx wrangler secret put ADMIN_TOKEN` et saisir le jeton. Ne jamais le mettre sur GitHub.
8. `npx wrangler deploy`
9. Copier l'URL HTTPS de ton Worker dans `KEY_SERVICE_BASE`, tout en haut de `VisionHub_V10_HoHo_Rayz.lua` (sans `/key`) et enregistrer le changement sur GitHub.

### Parcours utilisateur
1. Exécuter la V10 ; ouvrir la fenêtre d'accès par clé.
2. Cliquer `GET KEY`, qui copie le lien HTTPS vers **ton propre** Worker `/key` (si un presse-papiers est disponible).
3. Ouvrir ce lien dans le navigateur ; cliquer « GÉNÉRER MA CLÉ ».
4. Copier la clé générée, revenir au jeu, la coller dans `ENTER KEY HERE`.
5. Cliquer `SUBMIT KEY`. La V10 contacte `/api/verify` en HTTPS POST.
6. Une réponse `ok:true` ouvre le hub ; sinon une erreur explique l'échec.

## Fonctionnalités V10
- Fenêtre de clé et menu noir/rouge inspirés des **dispositions** HoHo Hub / RayzHub (marque et graphisme Vision Hub).
- Navigation, recherche, cartes, interrupteurs, réglage de taille, déplacement / recentrage, affichage FPS / XYZ, Fullbright local et FOV.
- Infos joueur dynamiques (FPS, ping, nombre de joueurs et santé).
- Onglets horizontaux et cartes empilées sur petit écran.
- Enregistrer une position, tenter de revenir à cette position. Le serveur Roblox peut refuser/corriger le déplacement.
- **Auto Farm et téléportations propres à un jeu : NON implémentés.** Nécessitent le nom exact du jeu, ses mécaniques et son Place ID.

## Vérifications / limites
- Vérification statique de la présence des méthodes dans les fichiers GitHub, **pas d'essai dans JJSploit**.
- Une interface inspirée d'une capture ne prouve pas une identité visuelle à 99 % : la dernière étape est de comparer des captures dans Roblox.
- Les API HTTPS POST et presse-papiers ne sont pas disponibles dans tous les exécuteurs.
- Aucun mot de passe Roblox ou cookie de compte n'est requis par ce projet.
