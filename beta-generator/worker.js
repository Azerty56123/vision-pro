// Vision Pro V4 — independent Cloudflare Worker key generator and verifier.
// Deploy separately from Roblox. Secrets reside in Cloudflare, not in Lua.
// D1 binding: env.DB ; secret: env.ADMIN_TOKEN.
// Copy schema.sql into D1 before use.
const ADMIN_HTML = "<!doctype html>\n<html lang=\"fr\">\n<head>\n<meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">\n<title>Vision Pro — Générateur Bêta</title>\n<style>\n:root{font-family:Inter,system-ui,Arial,sans-serif;color:#eef4ff;background:#090e19}\n*{box-sizing:border-box}body{margin:0;min-height:100vh;background:radial-gradient(ellipse at 10% -20%,#163253 0%,transparent 40%),#090e19}\nmain{max-width:900px;margin:auto;padding:38px 22px 70px}\nh1{font-size:28px;letter-spacing:-.8px;margin:10px 0 6px}p{color:#9eb0c8;line-height:1.5}\n.brand{display:flex;gap:13px;align-items:center}.logo{width:45px;height:45px;background:#61afff;color:#07111f;display:grid;place-items:center;border-radius:14px;font-weight:900}\n.pill{font-size:11px;font-weight:700;color:#84d1ff;border:1px solid #294963;padding:7px 11px;border-radius:99px;display:inline-block}\n.card{margin-top:22px;border:1px solid #27394e;background:#141e2e;border-radius:17px;padding:23px}\n.grid{display:grid;grid-template-columns:1.8fr 1fr 1fr;gap:11px}label{display:block;font-size:11px;letter-spacing:.3px;color:#acc2da;margin:0 0 7px;font-weight:700}input{width:100%;border:1px solid #344960;border-radius:9px;background:#0d1523;color:#fff;padding:12px;font:inherit;outline:0}input:focus{border-color:#66aefa}\nbutton{border:0;border-radius:10px;padding:12px 16px;font:inherit;font-size:13px;font-weight:700;cursor:pointer;background:#65aeff;color:#0a1627}button:hover{filter:brightness(1.1)}button.secondary{background:#233347;color:#dce9ff}button.danger{background:#3e2835;color:#ff9cae}\n.actions{display:flex;gap:10px;margin-top:16px;flex-wrap:wrap;align-items:center}.mono{font-family:ui-monospace,Menlo,Consolas,monospace;overflow-wrap:anywhere;letter-spacing:.4px}\n#result{display:none;margin-top:17px;background:#0b1726;border:1px solid #34618d;border-radius:10px;padding:15px}\n#notice{font-size:13px;color:#92bad8;margin-top:12px}\ntable{width:100%;border-collapse:collapse;font-size:12px}th{text-align:left;color:#91a9c4;font-weight:700}th,td{padding:12px 9px;border-bottom:1px solid #2b3a4c}td{color:#dfe8f5}.table-wrap{overflow:auto}.disabled{color:#ff9eac}.active{color:#8aefbd}\nsmall{color:#8ea4bc}button:disabled{opacity:.45;cursor:not-allowed}\n@media(max-width:650px){.grid{grid-template-columns:1fr}main{padding:22px 14px}.card{padding:17px}}\n</style>\n</head>\n<body><main>\n<div class=\"brand\"><div class=\"logo\">VP</div><div><span class=\"pill\">VISION PRO / V4</span><h1>Générateur de clés bêta</h1></div></div>\n<p>Crée des accès pour tes testeurs, avec expiration et nombre maximal d'activations. Les clés générées ne sont affichées qu'une seule fois.</p>\n<section class=\"card\">\n<label for=\"token\">JETON ADMINISTRATEUR SECRET</label><input id=\"token\" type=\"password\" autocomplete=\"off\" placeholder=\"Colle le jeton ADMIN_TOKEN configuré sur Cloudflare\">\n<p style=\"font-size:12px;margin-bottom:0\">Le jeton reste uniquement dans cette page ouverte. Il n'est pas enregistré dans le navigateur.</p>\n</section>\n<section class=\"card\">\n<div class=\"grid\">\n<div><label for=\"name\">NOM DE LA CLÉ</label><input id=\"name\" maxlength=\"64\" value=\"Beta V4\" placeholder=\"Ex: Groupe testeurs\"></div>\n<div><label for=\"days\">DURÉE (JOURS)</label><input id=\"days\" type=\"number\" min=\"0\" max=\"3650\" value=\"30\"></div>\n<div><label for=\"uses\">ACTIVATIONS MAX</label><input id=\"uses\" type=\"number\" min=\"0\" max=\"100000\" value=\"0\"></div>\n</div>\n<small>0 jour = pas d'expiration. 0 activation max = illimité. Chaque validation acceptée compte comme une activation.</small>\n<div class=\"actions\"><button id=\"generate\">GÉNÉRER UNE CLÉ</button><button id=\"refresh\" class=\"secondary\">ACTUALISER LES CLÉS</button></div>\n<div id=\"result\"><label>NOUVELLE CLÉ — COPIE-LA MAINTENANT</label><div id=\"newkey\" class=\"mono\" style=\"margin:9px 0 12px;font-size:15px\"></div><button id=\"copy\" class=\"secondary\">COPIER</button></div>\n<div id=\"notice\" role=\"status\"></div>\n</section>\n<section class=\"card\"><h2 style=\"margin-top:0;font-size:17px\">Clés générées</h2>\n<div class=\"table-wrap\"><table><thead><tr><th>Nom</th><th>Identifiant</th><th>Expire</th><th>Usages</th><th>État</th><th></th></tr></thead><tbody id=\"list\"><tr><td colspan=\"6\">Connecte ton jeton administrateur pour afficher les clés.</td></tr></tbody></table></div>\n</section></main>\n<script>\nconst $=id=>document.getElementById(id);\nconst notice=(message,bad=false)=>{$(\"notice\").textContent=message;$(\"notice\").style.color=bad?\"#ff9ba9\":\"#92bad8\"};\nasync function api(path,method=\"GET\",body) {\n const key=$(\"token\").value.trim();\n if(!key)throw Error(\"Renseigne ton jeton administrateur.\");\n const res=await fetch(path,{method,headers:{\"Authorization\":\"Bearer \"+key,\"Content-Type\":\"application/json\"},body:body?JSON.stringify(body):undefined,cache:\"no-store\"});\n const data=await res.json();\n if(!res.ok||!data.ok)throw Error(data.message||\"Erreur serveur\");\n return data;\n}\nasync function refresh(){\n try {\n  const data=await api(\"/api/admin/keys\");\n  const tbody=$(\"list\");tbody.replaceChildren();\n  if(!data.keys.length){const tr=document.createElement(\"tr\");const td=document.createElement(\"td\");td.colSpan=6;td.textContent=\"Aucune clé pour le moment.\";tr.append(td);tbody.append(tr);}\n  for(const item of data.keys){\n    const tr=document.createElement(\"tr\");\n    const expiration=item.expiresAt?new Date(item.expiresAt*1000).toLocaleString(\"fr-FR\"):\"Jamais\";\n    const cells=[item.label,item.id,expiration,item.uses+\" / \"+(item.maxActivations||\"∞\"),item.disabled?\"Révoquée\":\"Active\"];\n    for(const [i,value] of cells.entries()){\n      const td=document.createElement(\"td\");td.textContent=value;\n      if(i===1)td.className=\"mono\";if(i===4)td.className=item.disabled?\"disabled\":\"active\";\n      tr.append(td);\n    }\n    const action=document.createElement(\"td\");\n    if(!item.disabled){\n      const btn=document.createElement(\"button\");btn.className=\"danger\";btn.textContent=\"Révoquer\";\n      btn.onclick=async()=>{if(!confirm(\"Révoquer cette clé ?\"))return;try{await api(\"/api/admin/revoke\",\"POST\",{id:item.id});notice(\"Clé révoquée\");await refresh()}catch(e){notice(e.message,true)}};\n      action.append(btn);\n    }\n    tr.append(action);tbody.append(tr);\n  }\n }catch(e){notice(e.message,true)}\n}\n$(\"refresh\").onclick=refresh;\n$(\"generate\").onclick=async()=>{\n try{\n  const days=Number($(\"days\").value),maxActivations=Number($(\"uses\").value),label=$(\"name\").value.trim();\n  if(!Number.isInteger(days)||days<0||days>3650)throw Error(\"Durée invalide\");\n  if(!Number.isInteger(maxActivations)||maxActivations<0||maxActivations>100000)throw Error(\"Nombre d'activations invalide\");\n  const data=await api(\"/api/admin/generate\",\"POST\",{days,maxActivations,label});\n  $(\"newkey\").textContent=data.key;$(\"result\").style.display=\"block\";\n  notice(\"Clé générée. Sauvegarde-la : elle ne pourra pas être réaffichée.\");\n  await refresh();\n }catch(e){notice(e.message,true)}\n};\n$(\"copy\").onclick=async()=>{try{await navigator.clipboard.writeText($(\"newkey\").textContent);notice(\"Clé copiée\")}catch(e){notice(\"Copie manuelle nécessaire\",true)}};\n</script>\n</body></html>";
const JSON_HEADERS = {"content-type":"application/json; charset=utf-8","cache-control":"no-store"};
const encoder=new TextEncoder();
function reply(payload,code=200){
 return new Response(JSON.stringify(payload),{status:code,headers:JSON_HEADERS});
}
function html(){
 return new Response(ADMIN_HTML,{headers:{
  "content-type":"text/html; charset=utf-8",
  "cache-control":"no-store",
  "x-content-type-options":"nosniff",
  "x-frame-options":"DENY",
  "referrer-policy":"no-referrer",
  "content-security-policy":"default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; connect-src 'self'; img-src 'self' data:; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"
 }});
}
function matchSecret(a,b){
 const left=encoder.encode(String(a||"")),right=encoder.encode(String(b||""));
 if(left.length!==right.length)return false;
 let diff=0;for(let i=0;i<left.length;i++)diff|=left[i]^right[i];
 return diff===0;
}
async function sha256(value){
 const bytes=encoder.encode(value);
 const hash=new Uint8Array(await crypto.subtle.digest("SHA-256",bytes));
 return Array.from(hash,x=>x.toString(16).padStart(2,"0")).join("");
}
function randomHex(bytes=24){
 const raw=crypto.getRandomValues(new Uint8Array(bytes));
 return Array.from(raw,x=>x.toString(16).padStart(2,"0")).join("").toUpperCase();
}
async function bodyJSON(request){
 if(Number(request.headers.get("content-length")||0)>2048)throw Error("Payload too large");
 let data;
 try{data=await request.json()}catch{throw Error("Invalid JSON")}
 if(!data||typeof data!=="object"||Array.isArray(data))throw Error("Invalid payload");
 return data;
}
async function limitAttempts(request,env,now){
 // Best-effort IP throttling in D1; optional Cloudflare edge rate-limiting
 // rules provide stronger protection from distributed traffic.
 const ip=request.headers.get("CF-Connecting-IP")||"unknown";
 const ipHash=await sha256(ip+":"+env.ADMIN_TOKEN);
 const begin=now-60;
 await env.DB.prepare("INSERT INTO beta_attempts(ip_hash,attempts,window_start) VALUES(?,1,?) ON CONFLICT(ip_hash) DO UPDATE SET attempts = CASE WHEN window_start < ? THEN 1 ELSE attempts+1 END, window_start = CASE WHEN window_start < ? THEN ? ELSE window_start END")
  .bind(ipHash,now,begin,begin,now).run();
 const row=await env.DB.prepare("SELECT attempts FROM beta_attempts WHERE ip_hash=?").bind(ipHash).first();
 return (row?.attempts||0)>20;
}
async function verify(request,env){
 const data=await bodyJSON(request);
 const key=typeof data.key==="string"?data.key.trim().toUpperCase():"";
 if(!/^VP4-[0-9A-F]{8}(?:-[0-9A-F]{8}){5}$/.test(key)){
  return reply({ok:false,message:"Format de cle invalide"},400);
 }
 const now=Math.floor(Date.now()/1000);
 if(await limitAttempts(request,env,now)){
  return reply({ok:false,message:"Trop de tentatives. Reessaie dans une minute."},429);
 }
 const hash=await sha256(key);
 const row=await env.DB.prepare("SELECT id,expires_at,uses,max_activations,disabled FROM beta_keys WHERE key_hash=?").bind(hash).first();
 if(!row||row.disabled) return reply({ok:false,message:"Cle invalide ou revoquee"},403);
 if(row.expires_at>0&&now>=row.expires_at)return reply({ok:false,message:"Cle expiree"},403);
 const updated=await env.DB.prepare("UPDATE beta_keys SET uses=uses+1 WHERE id=? AND disabled=0 AND (expires_at=0 OR expires_at>?) AND (max_activations=0 OR uses<max_activations)")
  .bind(row.id,now).run();
 if((updated.meta?.changes||0)!==1)return reply({ok:false,message:"Limite d'activations atteinte"},403);
 return reply({ok:true,message:"Acces beta autorise",expiresAt:row.expires_at});
}
function adminAuthorized(request,env){
 if(typeof env.ADMIN_TOKEN!=="string"||env.ADMIN_TOKEN.length<32)return false;
 const authorization=request.headers.get("authorization")||"";
 return matchSecret(authorization,"Bearer "+env.ADMIN_TOKEN);
}
async function listKeys(env){
 const data=await env.DB.prepare("SELECT id,label,created_at,expires_at,max_activations,uses,disabled FROM beta_keys ORDER BY created_at DESC LIMIT 250").all();
 return reply({ok:true,keys:(data.results||[]).map(row=>({
  id:row.id,label:row.label,createdAt:row.created_at,expiresAt:row.expires_at,
  maxActivations:row.max_activations,uses:row.uses,disabled:row.disabled===1
 }))});
}
async function generate(request,env){
 const data=await bodyJSON(request);
 const days=Number(data.days);
 const maxActivations=Number(data.maxActivations);
 const label=String(data.label||"Cle beta").trim().slice(0,64);
 if(!Number.isInteger(days)||days<0||days>3650)return reply({ok:false,message:"Durée invalide"},400);
 if(!Number.isInteger(maxActivations)||maxActivations<0||maxActivations>100000)
  return reply({ok:false,message:"Limite invalide"},400);
 const key="VP4-"+randomHex(24).match(/.{1,8}/g).join("-");
 const hash=await sha256(key);
 const id=randomHex(8);
 const now=Math.floor(Date.now()/1000);
 const expires=days>0?now+days*86400:0;
 await env.DB.prepare("INSERT INTO beta_keys(id,key_hash,label,created_at,expires_at,max_activations,uses,disabled) VALUES(?,?,?,?,?,?,0,0)")
 .bind(id,hash,label,now,expires,maxActivations).run();
 return reply({ok:true,key,id,label,expiresAt:expires,maxActivations});
}
async function revoke(request,env){
 const data=await bodyJSON(request);
 const id=typeof data.id==="string"?data.id:"";
 if(!/^[0-9A-F]{16}$/.test(id))return reply({ok:false,message:"Identifiant invalide"},400);
 const changed=await env.DB.prepare("UPDATE beta_keys SET disabled=1 WHERE id=?").bind(id).run();
 return reply({ok:(changed.meta?.changes||0)>0,message:"Cle revoquee"});
}
export default{
 async fetch(request,env){
  const url=new URL(request.url);
  if(url.pathname==="/admin"&&request.method==="GET")return html();
  if(url.pathname==="/"&&request.method==="GET")return Response.redirect(url.origin+"/admin",302);
  if(!env.DB)return reply({ok:false,message:"D1 non configure"},503);
  if(!env.ADMIN_TOKEN||env.ADMIN_TOKEN.length<32)return reply({ok:false,message:"Secret admin non configure"},503);
  try{
   if(url.pathname==="/api/verify"&&request.method==="POST")return await verify(request,env);
   if(url.pathname.startsWith("/api/admin/")){
    if(!adminAuthorized(request,env))return reply({ok:false,message:"Jeton administrateur incorrect"},401);
    if(url.pathname==="/api/admin/keys"&&request.method==="GET")return await listKeys(env);
    if(url.pathname==="/api/admin/generate"&&request.method==="POST")return await generate(request,env);
    if(url.pathname==="/api/admin/revoke"&&request.method==="POST")return await revoke(request,env);
   }
   return reply({ok:false,message:"Route inconnue"},404);
  }catch(err){
   console.error("V4 API error",err);
   return reply({ok:false,message:"Erreur interne du generateur"},500);
  }
 }
};