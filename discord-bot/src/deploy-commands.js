import 'dotenv/config';
import { REST, Routes } from 'discord.js';
import { commandData } from './commands.js';

const token = process.env.DISCORD_TOKEN?.trim();
const clientId = process.env.DISCORD_CLIENT_ID?.trim();
const guildId = process.env.DISCORD_GUILD_ID?.trim();

if (!token || !clientId || !guildId) {
  throw new Error('Configure DISCORD_TOKEN, DISCORD_CLIENT_ID et DISCORD_GUILD_ID dans .env.');
}
if (!/^[0-9]{16,22}$/.test(clientId) || !/^[0-9]{16,22}$/.test(guildId)) {
  throw new Error('Application ID / Guild ID incorrects.');
}

const rest = new REST({ version: '10' }).setToken(token);
console.log('[VISION PRO] Installation des commandes Discord sur le serveur ' + guildId + '...');
const installed = await rest.put(
  Routes.applicationGuildCommands(clientId, guildId),
  { body: commandData }
);
console.log('[VISION PRO] ' + installed.length + ' commandes installees !');
