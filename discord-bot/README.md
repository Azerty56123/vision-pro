# VISION PRO V4 — Bot Discord

Un bot Discord **autonome**, avec un design néon violet/cyan, créé en **Node.js + discord.js**. Tu peux l'héberger sur ton ordinateur, sur un VPS ou sur un hébergeur de bots Discord. **Le bot ne s'exécute pas sur Cloudflare.**

Il utilise simplement les trois endpoints administrateur déjà présents sur ton site V4 pour partager les mêmes clés :

- `GET /api/admin/keys` (jusqu'aux 250 clés les plus récentes)
- `POST /api/admin/generate`
- `POST /api/admin/revoke`

Aucune modification du Worker, de D1 ou de `VISION_PRO.lua` n'est nécessaire.

## Fonctionnalités

| Commande | Action |
| --- | --- |
| `/panel` | Panneau privé avec boutons et création par formulaire |
| `/key generate` | Générer une clé personnalisée |
| `/key list` | Parcourir les clés avec pages et filtre d'état |
| `/key info` | Voir l'état, la durée et les activations d'une clé |
| `/key revoke` | Révoquer une clé **après confirmation** |
| `/stats` | Statistiques |
| `/status` | État de l'API V4 |
| `/help` | Guide des commandes |

Toutes les réponses sont **privées (ephemeral)**, même les clés nouvellement créées. La gestion est réservée au compte `DISCORD_OWNER_ID`, avec un rôle optionnel `DISCORD_ADMIN_ROLE_ID`. Le bot n'utilise pas l'intent « Message Content ».

**Important :** une clé avec 1 activation est utilisable pour une seule *validation réussie*, pas pour un seul utilisateur de manière permanente. Utilise **0** pour illimité si tu veux éviter de bloquer le testeur lors d'un deuxième lancement.

## Étape 1 — Préparer Discord

1. Crée une application ici : https://discord.com/developers/applications
2. Dans **General Information**, récupère **Application ID**.
3. Dans **Bot**, crée ou récupère le **Bot Token**. Ne le communique à personne.
4. Dans **Installation**, autorise **Guild Install** avec le scope **bot** et **applications.commands** ; installe le bot sur ton serveur Discord.
5. Active le **mode développeur** dans les paramètres avancés Discord, puis copie **ton identifiant utilisateur** et **l'identifiant du serveur** (clic droit → Copier l'identifiant).

## Étape 2 — Installer le bot (sur ton hébergement)

Le projet requiert **Node.js 24.17.0 ou plus récent** (discord.js 14.27).

1. Télécharge le dossier `discord-bot` (ou clone le dépôt GitHub).
2. Dans ce dossier, crée `.env` en copiant le fichier `.env.example`.
3. Configure ces variables dans `.env` :

```ini
DISCORD_TOKEN=TON_TOKEN_DISCORD_PRIVE
DISCORD_CLIENT_ID=IDENTIFIANT_APPLICATION
DISCORD_GUILD_ID=IDENTIFIANT_SERVEUR
DISCORD_OWNER_ID=TON_IDENTIFIANT_DISCORD
DISCORD_ADMIN_ROLE_ID=
VISION_API_URL=https://vision-pro-beta-v4.clienthom.workers.dev
VISION_ADMIN_TOKEN=TON_ADMIN_TOKEN_CLOUDFLARE_PRIVE
```

Ne mets **jamais** les vrais tokens dans GitHub, un message Discord ou une capture. Le fichier `.env` est ignoré par Git.

**Sécurité** : un ancien jeton `ADMIN_TOKEN` a été visible dans la conversation. Remplace-le dans Cloudflare par un nouveau jeton privé de 32 caractères ou plus, puis utilise cette **nouvelle** valeur dans `.env`.

## Étape 3 — Démarrer

Depuis le dossier `discord-bot` :

```sh
npm install
npm run deploy
npm start
```

- `npm run deploy` enregistre les commandes **dans ton serveur uniquement**.
- `npm start` lance le bot. Garde le processus actif sur ton hébergeur.
- `npm run check` vérifie la syntaxe des fichiers.

Pour le tester, tape `/panel` dans ton serveur. Tu dois voir les boutons **Créer une clé**, **Mes clés** et **Statistiques**.

## Hébergement

Si ton hébergeur offre une commande de démarrage et une zone de variables d'environnement :

- Commande d'installation : `npm install`
- Commande de déploiement initial des commandes : `npm run deploy`
- Commande de démarrage : `npm start`
- Node.js : **24.17+**
- Secrets : définis les variables ci-dessus dans la zone sécurisée de ton hébergeur.

Cloudflare reste uniquement la **source des clés déjà existantes**. Ton bot tourne exclusivement sur l'hébergement de ton choix.

## Notes

- Les stats et les listes couvrent les **250 dernières clés au maximum**, car l'API V4 a cette limite.
- Les clés entières ne peuvent être affichées qu'au moment de leur création.
- Le bot n'a pas besoin de démarrer un serveur HTTP public.
- Évite d'accorder `DISCORD_ADMIN_ROLE_ID` à un rôle public.
- `/key revoke` demande une confirmation ; la révocation est définitive.
- Si le bot répond que le jeton est incorrect, vérifie `VISION_ADMIN_TOKEN` et `VISION_API_URL`, puis redémarre le bot.
