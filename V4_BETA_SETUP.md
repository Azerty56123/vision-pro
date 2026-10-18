# VISION PRO V4 — GENERATEUR EXTERNE, SANS ROBLOX STUDIO

Le systeme beta V4 ne depend PLUS de ServerScriptService ou d'un serveur Roblox.

Fichiers:
- **VISION_PRO.lua** : V4 avec ecran d'activation, UI et fonctions existantes.
- **beta-generator/worker.js** : API HTTPS et page de generation des cles.
- **beta-generator/schema.sql** : base de donnees Cloudflare D1.
- **beta-generator/wrangler.toml** : configuration du deploiement.

**Le site n'est pas encore heberge.** Il faut le deployer une fois sur un compte Cloudflare; aucune cle active n'est livree par defaut.

## 1. Creer le generateur (une seule fois)

Il faut un compte Cloudflare et Node.js sur ton PC. Ouvre PowerShell sur Windows :

~~~powershell
git clone https://github.com/Azerty56123/vision-pro.git
cd vision-pro\beta-generator
npx wrangler login
npx wrangler d1 create vision-pro-beta
~~~

Wrangler affiche un identifiant de base de donnees.

Dans le fichier **beta-generator/wrangler.toml**, remplace **REPLACE_WITH_DATABASE_ID** par cet identifiant.

Initialise la base :

~~~powershell
npx wrangler d1 execute vision-pro-beta --remote --file=./schema.sql
~~~

Genere un jeton d'administration secret, fort et aleatoire :

~~~powershell
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
~~~

Garde ce resultat en prive, puis installe-le sur Cloudflare :

~~~powershell
npx wrangler secret put ADMIN_TOKEN
~~~

Colle ton secret quand Wrangler te le demande. Deploie ensuite le site :

~~~powershell
npx wrangler deploy
~~~

Cloudflare affichera une adresse HTTPS semblable a :

~~~text
https://vision-pro-beta-v4.TON-SOUS-DOMAINE.workers.dev
~~~

Documentation Cloudflare :
- https://developers.cloudflare.com/d1/wrangler-commands/
- https://developers.cloudflare.com/workers/configuration/secrets/

## 2. Generer tes cles sur le site

Va a l'adresse de ton Worker, en ajoutant **/admin** a la fin. Depuis cette page :

1. Entre ton **ADMIN_TOKEN secret** (ne le donne jamais a un testeur).
2. Choisis un nom de cle, sa duree en jours et sa limite d'activations.
3. Clique sur **GENERER UNE CLE**.
4. Copie la cle creee, commencant par **VP4-**, et donne-la au testeur.
5. Clique sur **Revoquer** si tu veux la desactiver.

**0 jour = illimite dans le temps ; 0 activation max = nombre illimite.**

Chaque validation acceptee consomme **UNE activation**. Ce n'est pas un compteur d'utilisateurs uniques.

Le serveur stocke uniquement l'empreinte SHA-256 de la cle, pas son texte en clair. La vraie cle s'affiche uniquement au moment de sa creation.

## 3. Relier le site au client V4

Dans le fichier **VISION_PRO.lua**, recherche la ligne suivante, pres du bas du fichier :

~~~lua
local BETA_API_URL="https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
~~~

Remplace l'adresse d'exemple par TON URL Cloudflare (sans /admin ni /api/verify), puis sauvegarde le script sur GitHub si tu utilises le lien RAW.

La V4 enverra une verification **POST HTTPS** vers **/api/verify** en envoyant la cle dans un corps JSON.

## 4. Lancer sans Roblox Studio

Si ton environnement de lancement prend en charge loadstring, game:HttpGet ET les requetes HTTPS POST, tu peux utiliser ton chargeur :

~~~lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VISION_PRO.lua?v=4.0.0"))()
~~~

**Ce n'est pas une methode standard de Roblox LocalScript.** Le client depend de la fonction HTTP du programme qui execute le script : request, http_request, ou syn.request. Si aucune n'est disponible, il annonce l'erreur au lieu d'ignorer la validation.

La V4 affiche l'ecran Beta Access, valide la cle avec ton site, puis ouvre NOVA seulement si le serveur externe confirme l'acces.

## Securite et limites

- Le generateur et le secret ADMIN_TOKEN doivent rester sous ton controle.
- Le client public ne contient ni secret administrateur, ni liste de cles.
- Les cles aleatoires sont generees cote serveur par crypto.getRandomValues.
- Le site utilise HTTPS, stocke les empreintes de cles, et propose une limitation de tentatives par IP (best effort). Protege aussi ton site via Cloudflare si tu attends du trafic important.
- Un script client public reste modifiable. Le systeme bloque le lancement officiel mais ne constitue PAS un dispositif inviolable ni un controle d'acces aux fonctions serveur Roblox.
- Sans acces reseau au Worker, une cle ne peut pas etre verifiee.

## Depannage

**Configure BETA_API_URL** : ton URL Cloudflare n'a pas ete renseignee.

**Requetes HTTPS POST non disponibles** : ton environnement d'execution ne propose pas de requete POST compatible.

**Connexion impossible** : verifie le deploiement de Cloudflare et l'adresse exacte.

**Jeton administrateur incorrect** : verifie le secret ADMIN_TOKEN renseigne dans Cloudflare.

**Cle refusee** : verifie l'expiration, le nombre d'activations et l'etat de la cle.

**L'ancien fichier VISION_BETA_SERVER.lua n'est pas utilise par cette methode sans Studio.**
