import 'dotenv/config';
import {
  ActionRowBuilder, ButtonBuilder, ButtonStyle, Client, EmbedBuilder,
  Events, GatewayIntentBits, MessageFlags, ModalBuilder,
  TextInputBuilder, TextInputStyle
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
      'Gère les accès de ta bêta V4 directement sur Discord.\n\n' +
      '🔑 **Clés** — créer, consulter et révoquer\n' +
      '📊 **Statistiques** — consulter les activations\n' +
      '🔒 **Sécurité** — commandes privées, permissions limitées\n\n' +
      'Connecté à la même API que ton générateur web.')],
    components: [buttons(
      action('Créer une clé', 'vp:create:' + userId, ButtonStyle.Primary),
      action('Mes clés', 'vp:panel:list:' + userId),
      action('Statistiques', 'vp:panel:stats:' + userId)
    )]
  };
}

async function keyList(userId, filter = 'all', page = 0) {
  const { keys } = await fetchKeys();
  const all = Array.isArray(keys) ? keys : [];
  const filtered = all.filter(k => filter === 'all' || keyStatus(k) === filter);
  const maxPage = Math.max(0, Math.ceil(filtered.length / 5) - 1);
  const p = Math.max(0, Math.min(page, maxPage));
  const data = filtered.slice(p * 5, p * 5 + 5);
  const lines = data.map(k => '**' + clean(k.label) + '**  ·  ' + states[keyStatus(k)] +
    '\n' + BACKTICK + k.id + BACKTICK +
    '  ·  ' + k.uses + '/' + (k.maxActivations || '∞') +
    ' activations  ·  ' + date(k.expiresAt));
  const warning = all.length >= 250 ? '\n\n⚠️ Limite API : 250 clés les plus récentes.' : '';
  return {
    embeds: [makeEmbed('Mes clés   /   ' + filtered.length + ' résultat(s)',
      (lines.join('\n\n') || 'Aucune clé pour ce filtre.') +
      '\n\nPage ' + (p + 1) + ' / ' + (maxPage + 1) + warning)],
    components: [buttons(
      action('◀', 'vp:list:' + userId + ':' + filter + ':' + (p - 1), ButtonStyle.Secondary, p === 0),
      action('Actualiser', 'vp:list:' + userId + ':' + filter + ':' + p),
      action('▶', 'vp:list:' + userId + ':' + filter + ':' + (p + 1), ButtonStyle.Secondary, p >= maxPage),
      action('Créer', 'vp:create:' + userId, ButtonStyle.Primary)
    )]
  };
}

async function stats(userId) {
  const { keys } = await fetchKeys();
  const all = Array.isArray(keys) ? keys : [];
  const count = state => all.filter(k => keyStatus(k) === state).length;
  const active = count('active') + count('soon');
  const used = all.reduce((sum, k) => sum + (Number(k.uses) || 0), 0);
  return {
    embeds: [makeEmbed('Statistiques   /   BETA V4',
      'Données de la base du générateur VISION PRO.' +
      (all.length >= 250 ? '\n\n⚠️ Uniquement les 250 clés les plus récentes.' : ''), COLORS.cyan)
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
      action('Créer', 'vp:create:' + userId, ButtonStyle.Primary)
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

async function onCommand(i) {
  const uid = i.user.id;
  if (i.commandName === 'panel') return i.reply(hidden(panel(uid)));
  if (i.commandName === 'help') {
    return i.reply(hidden({ embeds: [makeEmbed('Aide  /  VISION PRO',
      '**/panel** — panneau interactif\n' +
      '**/key generate** — créer une clé\n' +
      '**/key list** — liste, filtres et pages\n' +
      '**/key info** — détails d’une clé\n' +
      '**/key revoke** — révocation avec confirmation\n' +
      '**/stats** — statistiques\n' +
      '**/status** — état du service\n\n' +
      'Toutes les réponses sont privées.', COLORS.cyan)] }));
  }
  if (i.commandName === 'key') {
    const sub = i.options.getSubcommand();
    if (sub === 'revoke') {
      const id = i.options.getString('id', true).toUpperCase();
      if (!KEY_ID.test(id)) return i.reply(hidden({ content: 'ID invalide (16 caractères hexadécimaux).' }));
      return i.reply(hidden({
        embeds: [makeEmbed('Confirmer la révocation',
          'La clé ' + BACKTICK + id + BACKTICK + ' sera définitivement désactivée.', COLORS.amber)],
        components: [buttons(
          action('Confirmer', 'vp:revoke:yes:' + id + ':' + uid, ButtonStyle.Danger),
          action('Annuler', 'vp:revoke:no:' + id + ':' + uid)
        )]
      }));
    }
    await i.deferReply({ flags: MessageFlags.Ephemeral });
    if (sub === 'generate') {
      const key = await generateKey(
        i.options.getString('nom') || 'Beta V4',
        i.options.getInteger('jours') ?? 30,
        i.options.getInteger('activations') ?? 0
      );
      return i.editReply({ embeds: [newKeyEmbed(key)] });
    }
    if (sub === 'list') return i.editReply(await keyList(uid, i.options.getString('etat') || 'all'));
    if (sub === 'info') {
      const id = i.options.getString('id', true).toUpperCase();
      if (!KEY_ID.test(id)) return i.editReply('Identifiant incorrect.');
      const data = await fetchKeys();
      const found = data.keys.find(key => key.id === id);
      return i.editReply(found ? { embeds: [keyDetails(found)] } :
        { content: 'ID introuvable parmi les 250 clés les plus récentes.' });
    }
  }
  if (i.commandName === 'stats') {
    await i.deferReply({ flags: MessageFlags.Ephemeral });
    return i.editReply(await stats(uid));
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
  const uid = parts[1] === 'list' ? parts[2] :
    parts[1] === 'revoke' ? parts[4] :
    parts[1] === 'panel' ? parts[3] : parts[2];
  if (uid !== i.user.id) return i.reply(hidden({ content: 'Ce panneau appartient à un autre administrateur.' }));
  if (parts[1] === 'create') return i.showModal(createModal(uid));
  if (parts[1] === 'list' && FILTERS.includes(parts[3])) {
    const page = Number(parts[4]);
    if (!Number.isInteger(page) || page < 0 || page > 1000) return;
    await i.deferUpdate();
    return i.editReply(await keyList(uid, parts[3], page));
  }
  if (parts[1] === 'panel') {
    await i.deferUpdate();
    if (parts[2] === 'list') return i.editReply(await keyList(uid));
    if (parts[2] === 'stats') return i.editReply(await stats(uid));
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
  const userId = i.customId.slice('vp:modal:'.length);
  if (i.user.id !== userId) return i.reply(hidden({ content: 'Formulaire non autorisé.' }));
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

client.on(Events.InteractionCreate, async i => {
  if (!i.isChatInputCommand() && !i.isButton() && !i.isModalSubmit()) return;
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
