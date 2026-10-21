import { SlashCommandBuilder } from 'discord.js';

// Two commands only. The private panel handles all beta-key operations.
export const commands = [
  new SlashCommandBuilder().setName('panel').setDescription('Ouvrir le panneau privé VISION PRO V4'),
  new SlashCommandBuilder().setName('status').setDescription('Vérifier le bot et l’API V4')
];

export const commandData = commands.map(command => command.toJSON());
