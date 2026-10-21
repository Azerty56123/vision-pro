import 'dotenv/config';
import {
  ActionRowBuilder, ButtonBuilder, ButtonStyle, Client, EmbedBuilder,
  Events, GatewayIntentBits, MessageFlags, ModalBuilder,
  StringSelectMenuBuilder, TextInputBuilder, TextInputStyle
} from 'discord.js';
import { checkApiConfig, fetchKeys, generateKey, revokeKey, ApiError } from './api.js';

const COLORS = { purple: 0xAE80FF, cyan: 0x71EDF4, green: 0x9EF0CC, red: 0xFFACBD, amber: 0xF7D59E };
const KEY_ID = /^[0-9A-F]{16}$/;
const FILTERS = ['all', 'active', 'soon', 'expired', 'exhausted', 'revoked'];
const BACKTICK = String.fromCharCode(96);
const config = {
  token: process.env.DISCORD_TOKEN?.trim(),
  clientId: process.env.DISCORD_CLIENT_ID?.trim(),
  guildId: process.env.DISCORD_GUILD_ID?.trim(),
  ownerId: process.env.DISCORD_OWNER_ID?.trim(),
  adminRoleId: process.env.DISCORD_ADMIN_ROLE_ID?.trim()
};
for (const [key, value] of [
  ['DISCORD_TOKEN', config.token], ['DISCORD_CLIENT_ID', config.clientId],
  ['DISCORD_GUILD_ID', config.guildId], ['DISCORD_OWNER_ID', config.ownerId]
]) if (!value) throw new Error(key + ' manquant dans .env.');
for (const [key, value] of [
  ['DISCORD_CLIENT_ID', config.clientId], ['DISCORD_GUILD_ID', config.guildId],
  ['DISCORD_OWNER_ID', config.ownerId],
  ...(config.adminRoleId ? [['DISCORD_ADMIN_ROLE_ID', config.adminRoleId]] : [])
]) if (!/^[0-9]{16,22}$/.test(value)) throw new Error(key + ' doit etre un identifiant Discord.');
checkApiConfig();

const client = new Client({ intents: [GatewayIntentBits.Guilds] });
const clean = (value, max = 90) => String(value ?? '').replaceAll('@', '＠')
  .replaceAll('<', '‹').replaceAll('>', '›')
  .replace(/[*_~|]/g, '').replaceAll(BACKTICK, '').slice(0, max);
const date = unix => unix > 0 ? '<t:' + unix + ':d>' : 'Sans limite';
const makeEmbed = (title, text, color = COLORS.purple) => new EmbedBuilder()
  .setTitle(title).setDescription(text).setColor(color)
  .setFooter({ text: 'VISION PRO   /   BETA V4' }).setTimestamp();

function authorized(i) {
  if (!i.inGuild() || i.guildId !== config.guildId) return false;
  if (i.user.id === config.ownerId) return true;
  if (!config.adminRoleId) return false;
  const roles = i.member?.roles;
  return Array.isArray(roles) ? roles.includes(config.adminRoleId) : Boolean(roles?.cache?.has(config.adminRoleId));
}
function action(label, id, style = ButtonStyle.Secondary, disabled = false) {
  return new ButtonBuilder().setLabel(label).setCustomId(id).setStyle(style).setDisabled(disabled);
}
function buttons(...items) { return new ActionRowBuilder().addComponents(...items); }
const hidden = options => ({ ...options, flags: MessageFlags.Ephemeral, allowedMentions: { parse: [] } });

function keyStatus(k) {
  const now = Math.floor(Date.now() / 1000);
  if (k.disabled) return 'revoked';
  if (k.expiresAt > 0 && now >= k.expiresAt) return 'expired';
  if (k.maxActivations > 0 && k.uses >= k.maxActivations) return 'exhausted';
  if (k.expiresAt > 0 && k.expiresAt <= now + 604800) return 'soon';
  return 'active';
}
const states = {
  active: '🟢 Active', soon: '🟡 Bientôt expirée', expired: '🔴 Expirée',
  exhausted: '🟠 Épuisée', revoked: '⛔ Révoquée'
};

function panel(userId) {
  return {
    embeds: [makeEmbed('VISION PRO   |   Administration',
      'Gère les clés de ta bêta V4 directement depuis Discord.\n\n' +
      '🔑 **Clés** — créer, consulter et révoquer\n' +
      '📊 **Statistiques** — voir les activations\n' +
      '🔒 **Sécurité** — réponses privées et accès limité\n\n' +
      'Toutes les fonctions sont accessibles avec les boutons ci-dessous.')],
    components: [
      buttons(
        action('Créer une clé', 'vp:create:' + userId, ButtonStyle.Primary),
        action('Mes clés', 'vp:panel:list:' + userId),
        action('Statistiques', 'vp:panel:stats:' + userId),
        action('Révoquer', 'vp:showrevoke:' + userId, ButtonStyle.Danger)
      ),
      buttons(action('Détails d’une clé', 'vp:showinfo:' + userId))
    ]
  };
}

async function keyList(userId, filter = 'all', page = 0) {
  const { keys } = await fetchKeys();
  const all = Array.isArray(keys) ? keys : [];
  const filtered = all.filter(k => filter === 'all' || keyStatus(k) === filter);
  const maxPage = Math.max(0, Math.ceil(filtered.length / 5) - 1);
  const p = Math.max(0, Math.min(page, maxPage));
  const entries = filtered.slice(p * 5, p * 5 + 5);
  const lines = entries.map(k =>
    '**' + clean(k.label) + '** · ' + states[keyStatus(k)] +
    '\n' + BACKTICK + k.id + BACKTICK +
    ' · ' + k.uses + '/' + (k.maxActivations || '∞') +
    ' activations · ' + date(k.expiresAt)
  );
  const warning = all.length >= 250 ? '\n\n⚠️ 250 dernières clés seulement (limite de l’API).' : '';
  return {
    embeds: [makeEmbed('Mes clés   /   ' + filtered.length + ' résultat(s)',
      (lines.join('\n\n') || 'Aucune clé pour ce filtre.') +
      '\n\nPage ' + (p + 1) + '/' + (maxPage + 1) + warning)],
    components: [
      buttons(
        action('◀', 'vp:list:' + userId + ':' + filter + ':' + (p - 1), ButtonStyle.Secondary, p === 0),
        action('Actualiser', 'vp:list:' + userId + ':' + filter + ':' + p),
        action('▶', 'vp:list:' + userId + ':' + filter + ':' + (p + 1), ButtonStyle.Secondary, p === maxPage),
        action('Créer', 'vp:create:' + userId, ButtonStyle.Primary),
        action('Retour', 'vp:panel:home:' + userId)
      ),
      new ActionRowBuilder().addComponents(
        new StringSelectMenuBuilder()
          .setCustomId('vp:filter:' + userId)
          .setPlaceholder('Filtrer les clés')
          .addOptions([
            { label: 'Toutes', value: 'all', default: filter === 'all' },
            { label: 'Actives', value: 'active', default: filter === 'active' },
            { label: 'Bientôt expirées', value: 'soon', default: filter === 'soon' },
            { label: 'Expirées', value: 'expired', default: filter === 'expired' },
            { label: 'Épuisées', value: 'exhausted', default: filter === 'exhausted' },
            { label: 'Révoquées', value: 'revoked', default: filter === 'revoked' }
          ])
      )
    ]
  };
}

async function stats(userId) {
  const { keys } = await fetchKeys();
  const all = Array.isArray(keys) ? keys : [];
  const count = status => all.filter(k => keyStatus(k) === status).length;
  const active = count('active') + count('soon');
  const used = all.reduce((sum, k) => sum + (Number(k.uses) || 0), 0);
  return {
    embeds: [makeEmbed('Statistiques   /   BETA V4',
      'Données du générateur VISION PRO.' +
      (all.length >= 250 ? '\n\n⚠️ 250 dernières clés uniquement.' : ''), COLORS.cyan)
      .addFields(
        { name: 'Actives', value: String(active), inline: true },
        { name: 'Total', value: String(all.length), inline: true },
        { name: 'Activations', value: used.toLocaleString('fr-FR'), inline: true },
        { name: 'Révoquées', value: String(count('revoked')), inline: true },
        { name: 'Expirent bientôt', value: String(count('soon')), inline: true }
      )],
    components: [buttons(
      action('Actualiser', 'vp:panel:stats:' + userId),
      action('Voir les clés', 'vp:panel:list:' + userId),
      action('Créer', 'vp:create:' + userId, ButtonStyle.Primary),
      action('Retour', 'vp:panel:home:' + userId)
    )]
  };
}

function keyDetails(k) {
  return makeEmbed('Détails   /   ' + clean(k.label),
    'Identifiant : ' + BACKTICK + k.id + BACKTICK +
    '\nLa valeur complète ne peut être retrouvée après création.', COLORS.cyan)
    .addFields(
      { name: 'Statut', value: states[keyStatus(k)], inline: true },
      { name: 'Activations', value: k.uses + '/' + (k.maxActivations || '∞'), inline: true },
      { name: 'Expiration', value: date(k.expiresAt), inline: true },
      { name: 'Création', value: date(k.createdAt), inline: true }
    );
}

function newKeyEmbed(data) {
  return makeEmbed('Clé V4 générée',
    '**Copie cette clé maintenant.** Elle ne pourra pas être affichée à nouveau.\n\n' +
    BACKTICK + BACKTICK + BACKTICK + '\n' + data.key + '\n' + BACKTICK + BACKTICK + BACKTICK, COLORS.green)
    .addFields(
      { name: 'Nom', value: clean(data.label, 64), inline: true },
      { name: 'Expiration', value: date(data.expiresAt), inline: true },
      { name: 'Activations max.', value: data.maxActivations ? String(data.maxActivations) : 'Illimitées', inline: true },
      { name: 'ID', value: BACKTICK + data.id + BACKTICK }
    );
}

function createModal(userId) {
  return new ModalBuilder().setCustomId('vp:modal:' + userId)
    .setTitle('VISION PRO / Nouvelle clé')
    .addComponents(
      buttons(new TextInputBuilder().setCustomId('name').setLabel('Nom de la clé')
        .setStyle(TextInputStyle.Short).setRequired(true).setMaxLength(64).setValue('Beta V4')),
      buttons(new TextInputBuilder().setCustomId('days').setLabel('Durée (jours, 0 = illimitée)')
        .setStyle(TextInputStyle.Short).setRequired(true).setMaxLength(4).setValue('30')),
      buttons(new TextInputBuilder().setCustomId('uses').setLabel('Activations max. (0 = illimité)')
        .setStyle(TextInputStyle.Short).setRequired(true).setMaxLength(6).setValue('0'))
    );
}

function errorMessage(error) {
  if (error instanceof ApiError && error.code === 401)
    return 'Jeton API incorrect. Vérifie VISION_ADMIN_TOKEN dans .env.';
  if (error instanceof ApiError) return error.message;
  if (error?.name === 'TimeoutError' || error?.name === 'AbortError')
    return 'L’API V4 n’a pas répondu à temps.';
  return 'Une erreur est survenue. Vérifie les paramètres et les logs du bot.';
}

function idModal(userId, purpose) {
  const isRevoke = purpose === 'revoke';
  return new ModalBuilder()
    .setCustomId('vp:modal:' + (isRevoke ? 'revoke' : 'info') + ':' + userId)
    .setTitle(isRevoke ? 'Révoquer une clé' : 'Détails d’une clé')
    .addComponents(
      buttons(new TextInputBuilder()
        .setCustomId('id')
        .setLabel('ID de la clé (16 caractères)')
        .setPlaceholder('Ex. A1B2C3D4E5F60708')
        .setStyle(TextInputStyle.Short)
        .setRequired(true)
        .setMinLength(16)
        .setMaxLength(16))
    );
}

async function onCommand(i) {
  if (i.commandName === 'panel') {
    return i.reply(hidden(panel(i.user.id)));
  }
  if (i.commandName === 'status') {
    await i.deferReply({ flags: MessageFlags.Ephemeral });
    const started = Date.now();
    await fetchKeys();
    return i.editReply({ embeds: [makeEmbed('Services VISION PRO',
      '🟢 Bot Discord : opérationnel\n🟢 API V4 : accessible\n🟢 Gestion des clés : disponible\n\n' +
      'Réponse API : **' + (Date.now() - started) + ' ms**', COLORS.green)] });
  }
}

async function onButton(i) {
  const parts = i.customId.split(':');
  if (parts[0] !== 'vp') return;

  // Every button belongs to the admin who opened the private panel.
  const userId = parts[1] === 'list' ? parts[2] :
    parts[1] === 'revoke' ? parts[4] :
    parts[1] === 'panel' ? parts[3] : parts[2];

  if (userId !== i.user.id) {
    return i.reply(hidden({ content: 'Ce panneau appartient à un autre administrateur.' }));
  }
  if (parts[1] === 'create') return i.showModal(createModal(userId));
  if (parts[1] === 'showinfo') return i.showModal(idModal(userId, 'info'));
  if (parts[1] === 'showrevoke') return i.showModal(idModal(userId, 'revoke'));

  if (parts[1] === 'list' && FILTERS.includes(parts[3])) {
    const page = Number(parts[4]);
    if (!Number.isInteger(page) || page < 0 || page > 1000) return;
    await i.deferUpdate();
    return i.editReply(await keyList(userId, parts[3], page));
  }
  if (parts[1] === 'panel') {
    await i.deferUpdate();
    if (parts[2] === 'list') return i.editReply(await keyList(userId));
    if (parts[2] === 'stats') return i.editReply(await stats(userId));
    if (parts[2] === 'home') return i.editReply(panel(userId));
  }
  if (parts[1] === 'revoke') {
    if (parts[2] === 'no') return i.update({
      embeds: [makeEmbed('Annulé', 'Aucune clé n’a été modifiée.', COLORS.cyan)], components: []
    });
    const id = parts[3];
    if (parts[2] !== 'yes' || !KEY_ID.test(id)) return;
    await i.deferUpdate();
    await revokeKey(id);
    return i.editReply({
      embeds: [makeEmbed('Clé révoquée',
        'La clé ' + BACKTICK + id + BACKTICK + ' est désormais désactivée.', COLORS.green)],
      components: []
    });
  }
}

async function onModal(i) {
  if (!i.customId.startsWith('vp:modal:')) return;

  const parts = i.customId.split(':');
  const purpose = parts.length === 4 ? parts[2] : 'create';
  const userId = parts.length === 4 ? parts[3] : parts[2];
  if (i.user.id !== userId) {
    return i.reply(hidden({ content: 'Formulaire non autorisé.' }));
  }

  if (purpose === 'info' || purpose === 'revoke') {
    const id = i.fields.getTextInputValue('id').trim().toUpperCase();
    if (!KEY_ID.test(id)) {
      return i.reply(hidden({ content: 'ID incorrect : 16 caractères hexadécimaux requis.' }));
    }
    if (purpose === 'revoke') {
      return i.reply(hidden({
        embeds: [makeEmbed('Confirmer la révocation',
          'La clé ' + BACKTICK + id + BACKTICK + ' sera définitivement désactivée.', COLORS.amber)],
        components: [buttons(
          action('Confirmer', 'vp:revoke:yes:' + id + ':' + userId, ButtonStyle.Danger),
          action('Annuler', 'vp:revoke:no:' + id + ':' + userId)
        )]
      }));
    }
    await i.deferReply({ flags: MessageFlags.Ephemeral });
    const { keys } = await fetchKeys();
    const found = (keys || []).find(key => key.id === id);
    return i.editReply(found
      ? { embeds: [keyDetails(found)] }
      : { content: 'Clé introuvable parmi les 250 plus récentes. Vérifie son ID sur le site.' });
  }

  if (purpose !== 'create') return;
  const name = i.fields.getTextInputValue('name').trim();
  const days = i.fields.getTextInputValue('days').trim();
  const uses = i.fields.getTextInputValue('uses').trim();
  if (!name || !/^[0-9]{1,4}$/.test(days) || !/^[0-9]{1,6}$/.test(uses) ||
      Number(days) > 3650 || Number(uses) > 100000) {
    return i.reply(hidden({ content: 'Durée ou activations invalides. Mets 0 pour illimité.' }));
  }
  await i.deferReply({ flags: MessageFlags.Ephemeral });
  const key = await generateKey(name, Number(days), Number(uses));
  return i.editReply({ embeds: [newKeyEmbed(key)] });
}

async function onSelectMenu(i) {
  if (!i.customId.startsWith('vp:filter:')) return;
  const owner = i.customId.slice('vp:filter:'.length);
  if (owner !== i.user.id) {
    return i.reply(hidden({ content: 'Ce panneau appartient à un autre administrateur.' }));
  }
  const filter = i.values[0];
  if (!FILTERS.includes(filter)) {
    return i.reply(hidden({ content: 'Filtre inconnu.' }));
  }
  await i.deferUpdate();
  return i.editReply(await keyList(owner, filter, 0));
}

client.on(Events.InteractionCreate, async i => {
  if (!i.isChatInputCommand() && !i.isButton() && !i.isModalSubmit() && !i.isStringSelectMenu()) return;
  if (!authorized(i)) {
    return void await i.reply(hidden({
      embeds: [makeEmbed('Accès refusé',
        'Cette commande est réservée au propriétaire ou au rôle autorisé sur ton serveur.', COLORS.red)]
    })).catch(() => {});
  }
  try {
    if (i.isChatInputCommand()) await onCommand(i);
    else if (i.isButton()) await onButton(i);
    else if (i.isModalSubmit()) await onModal(i);
    else if (i.isStringSelectMenu()) await onSelectMenu(i);
  } catch (error) {
    console.error('[VISION PRO] Erreur :', error instanceof ApiError ? error.message : error);
    const response = { embeds: [makeEmbed('Erreur', errorMessage(error), COLORS.red)], components: [] };
    try {
      if (i.deferred || i.replied) await i.editReply(response);
      else await i.reply(hidden(response));
    } catch (ignored) { console.error('[VISION PRO] Reponse impossible :', ignored?.message); }
  }
});

client.once(Events.ClientReady, ready => {
  console.log('[VISION PRO] Connecte en tant que ' + ready.user.tag);
  console.log('[VISION PRO] Hebergement autonome, serveur ' + config.guildId);
  console.log('[VISION PRO] Commandes : npm run deploy');
});
client.on(Events.Error, error => console.error('[Discord]', error?.message));
process.on('SIGINT', () => { client.destroy(); process.exit(0); });
process.on('SIGTERM', () => { client.destroy(); process.exit(0); });
await client.login(config.token);
