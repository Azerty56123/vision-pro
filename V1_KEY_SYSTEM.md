# Vision Hub V1 — système de clés

## Version utilisateur

Le script du hub est publié à :

\`\`\`lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VisionHub_V1_Design12.lua"))()
\`\`\`

La fenêtre de clé utilise la même identité graphique que l'interface : noir mat, violet, titre **Vision Community**, boutons compacts GET KEY / HOW TO GET KEY / SUBMIT KEY.

## Test immédiat

1. Exécuter le loadstring.
2. Cliquer **GET KEY**. Tant que le Worker n'est pas configuré, une clé de développement est saisie.
3. Cliquer **SUBMIT KEY** pour ouvrir le hub.

La clé de test est \`VISION-TEST-ILLIMITE-2026\`. Elle est **publique dans le code** et ne constitue pas une authentification sécurisée.

## Activer les vraies clés (24 h)

Les sources du service sont dans \`beta-generator/worker.js\`. Elles contiennent :

- Page publique \`GET /key\` noire/violette assortie au hub.
- Génération publique \`POST /api/public/generate\`, limitée à **3 clés par IP / 24 h** et **24 h par clé**.
- Vérification \`POST /api/verify\`, contrôlant le hash de la clé, son expiration et ses activations.

Un commit GitHub **ne déploie pas automatiquement** le Worker. Il faut utiliser votre compte Cloudflare.

1. Dans \`beta-generator/wrangler.toml\`, remplacer \`REPLACE_WITH_DATABASE_ID\` par l'ID d'une base D1 créée dans Cloudflare, après \`npx wrangler d1 create vision-pro-beta\`.
2. Appliquer \`npx wrangler d1 execute vision-pro-beta --remote --file=./schema.sql\` depuis le dossier \`beta-generator\`.
3. Définir le secret \`ADMIN_TOKEN\` d'au moins 32 caractères avec \`npx wrangler secret put ADMIN_TOKEN\`, sans jamais le commiter.
4. Déployer depuis le même dossier avec \`npx wrangler deploy\`.
5. Remplacer dans \`VisionHub_V1_Design12.lua\` :
   \`\`\`lua
   local KEY_API="https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
   \`\`\`
   par l'URL HTTPS **réelle** du Worker déployé, **sans** /key.
6. Republier le fichier V1 sur GitHub. Le même loadstring récupèrera cette modification.

## Usage après déploiement

**GET KEY** copie le lien vers \`/key\`, l'utilisateur y génère et copie sa clé; **SUBMIT KEY** soumet cette clé en HTTPS à \`/api/verify\` puis ouvre le hub seulement si la réponse du serveur est \`ok: true\`.

Pour une vraie distribution avec contrôle d'accès, désactivez la clé de test intégrée au script (elle permet actuellement de passer outre la vérification). Un système exclusivement client n'est jamais une protection inviolable.

## Limites

Le code a été relu statiquement sur GitHub, mais il n'a pas été testé à l'exécution sur Roblox/JJSploit. Les méthodes \`request\`, \`http_request\` et \`setclipboard\` peuvent manquer selon l'environnement.
