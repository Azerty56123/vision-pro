import { SlashCommandBuilder } from 'discord.js';

const key = new SlashCommandBuilder()
  .setName('key')
  .setDescription('Gerer les cles beta VISION PRO V4')
  .addSubcommand(sub => sub.setName('generate').setDescription('Generer une cle beta')
    .addStringOption(opt => opt.setName('nom').setDescription('Nom de la cle').setMaxLength(64))
    .addIntegerOption(opt => opt.setName('jours').setDescription('Duree : 0 = illimitee, 30 par defaut').setMinValue(0).setMaxValue(3650))
    .addIntegerOption(opt => opt.setName('activations').setDescription('0 = illimite').setMinValue(0).setMaxValue(100000)))
  .addSubcommand(sub => sub.setName('list').setDescription('Lister les cles beta')
    .addStringOption(opt => opt.setName('etat').setDescription('Filtrer les cles')
      .addChoices(
        { name: 'Toutes', value: 'all' },
        { name: 'Actives', value: 'active' },
        { name: 'Bientot expirees', value: 'soon' },
        { name: 'Expirees', value: 'expired' },
        { name: 'Epuisees', value: 'exhausted' },
        { name: 'Revoquees', value: 'revoked' }
      )))
  .addSubcommand(sub => sub.setName('info').setDescription('Afficher les informations d’une cle')
    .addStringOption(opt => opt.setName('id').setDescription('ID (16 caracteres)').setRequired(true).setMinLength(16).setMaxLength(16)))
  .addSubcommand(sub => sub.setName('revoke').setDescription('Revoquer une cle apres confirmation')
    .addStringOption(opt => opt.setName('id').setDescription('ID (16 caracteres)').setRequired(true).setMinLength(16).setMaxLength(16)));

export const commands = [
  key,
  new SlashCommandBuilder().setName('panel').setDescription('Ouvrir le panneau de gestion prive'),
  new SlashCommandBuilder().setName('stats').setDescription('Voir les statistiques des cles'),
  new SlashCommandBuilder().setName('status').setDescription('Verifier le bot et l’API V4'),
  new SlashCommandBuilder().setName('help').setDescription('Afficher les commandes de VISION PRO')
];

export const commandData = commands.map(command => command.toJSON());
