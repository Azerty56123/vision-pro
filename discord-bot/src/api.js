import 'dotenv/config';

const API_BASE = process.env.VISION_API_URL?.trim().replace(/\/+$/, '');
const ADMIN_TOKEN = process.env.VISION_ADMIN_TOKEN?.trim();

export class ApiError extends Error {
  constructor(message, code = 0) {
    super(message);
    this.name = 'ApiError';
    this.code = code;
  }
}

export function checkApiConfig() {
  if (!ADMIN_TOKEN || ADMIN_TOKEN.length < 32) {
    throw new Error('VISION_ADMIN_TOKEN manquant ou trop court dans .env (32 caracteres minimum).');
  }
  if (!API_BASE) throw new Error('VISION_API_URL manquant dans .env.');
  let url;
  try { url = new URL(API_BASE); } catch { throw new Error('VISION_API_URL est invalide.'); }
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && url.hostname === 'localhost')) {
    throw new Error('VISION_API_URL doit utiliser HTTPS.');
  }
  if (url.pathname !== '/' || url.search || url.hash || url.username || url.password) {
    throw new Error('VISION_API_URL doit etre une URL de base sans /admin ou parametres.');
  }
}

export async function api(path, { method = 'GET', data } = {}) {
  const response = await fetch(API_BASE + path, {
    method,
    headers: {
      Authorization: 'Bearer ' + ADMIN_TOKEN,
      ...(data !== undefined ? { 'Content-Type': 'application/json' } : {})
    },
    ...(data !== undefined ? { body: JSON.stringify(data) } : {}),
    cache: 'no-store',
    signal: AbortSignal.timeout(12_000)
  });
  let body;
  try { body = await response.json(); } catch { throw new ApiError('Reponse invalide du serveur VISION PRO.', response.status); }
  if (!response.ok || !body?.ok) {
    const reason = typeof body?.message === 'string' ? body.message.slice(0, 180) : 'Service indisponible.';
    throw new ApiError('API V4 : ' + reason, response.status);
  }
  return body;
}

export function fetchKeys() { return api('/api/admin/keys'); }
export function generateKey(label, days, maxActivations) {
  return api('/api/admin/generate', { method: 'POST', data: { label, days, maxActivations } });
}
export function revokeKey(id) {
  return api('/api/admin/revoke', { method: 'POST', data: { id } });
}
