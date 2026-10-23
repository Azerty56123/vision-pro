// VISION PRO V4 - Beta Access Console
// Full Cloudflare Worker: HTML, CSS, JavaScript, API.
// Your existing DB binding and ADMIN_TOKEN remain unchanged.
// Paste this entire file in Edit code and click Deploy.

// ============================================================================
// 1. WEBSITE - HTML, CSS, JAVASCRIPT
// ============================================================================
const ADMIN_HTML = String.raw`<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="theme-color" content="#0b0e13">
<title>VISION PRO / KEY CONTROL</title>
<style>
:root{
 color-scheme:dark;font-family:Inter,"Segoe UI",Arial,sans-serif;
 --bg:#0b0e13;--rail:#10151c;--pane:#151b23;--card:#1b232c;
 --raised:#222d38;--border:#2d3946;--line:#29323c;--text:#edf2f6;
 --muted:#9aa9b7;--dim:#748695;--accent:#90a9ff;--accent-soft:#253052;
 --good:#8fd0af;--red:#f1a0ad;--orange:#e7c08a;
 font-synthesis:none;-webkit-font-smoothing:antialiased;
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{margin:0;min-width:320px;background:var(--bg);color:var(--text);font-size:13px}
button,input,select{font:inherit}button{cursor:pointer}
button:disabled{opacity:.5;cursor:not-allowed}
button:focus-visible,input:focus-visible,select:focus-visible{outline:2px solid var(--accent);outline-offset:3px}
[hidden]{display:none!important}
svg{display:block;width:17px;height:17px;stroke:currentColor;stroke-width:1.8;fill:none;stroke-linecap:round;stroke-linejoin:round}
.app-shell{min-height:100vh;display:grid;grid-template-columns:220px minmax(0,1fr)}
.rail{background:var(--rail);border-right:1px solid var(--border);padding:27px 16px;display:flex;flex-direction:column;gap:34px}
.logo{display:flex;align-items:center;gap:10px;padding:0 8px}
.logo-square{width:35px;height:35px;display:grid;place-items:center;background:var(--accent);border-radius:7px;color:#111929;font-size:13px;font-weight:850;letter-spacing:-.04em}
.logo-text{font-size:12px;font-weight:800;letter-spacing:.12em}
.logo-small{font-size:10px;color:var(--dim);letter-spacing:.13em;margin-top:3px}
.rail-menu{display:grid;gap:6px}
.rail-heading{font-size:10px;font-weight:760;letter-spacing:.13em;color:var(--dim);padding:7px 13px 12px}
.rail-entry{height:43px;display:flex;align-items:center;gap:12px;color:var(--text);border:1px solid var(--border);background:var(--pane);padding:0 13px;border-radius:7px;font-size:12px;font-weight:700}
.rail-entry svg{color:var(--accent)}
.rail-foot{margin-top:auto;border-top:1px solid var(--border);padding:18px 11px 0;font-size:11px;color:var(--dim);line-height:1.7}
.rail-foot strong{color:var(--muted);font-weight:700;letter-spacing:.06em;font-size:10px}
.work{min-width:0}
.top{height:69px;display:flex;align-items:center;justify-content:space-between;gap:12px;border-bottom:1px solid var(--line);padding:0 34px}
.breadcrumb{font-size:12px;color:var(--muted)}.breadcrumb strong{color:var(--text);font-weight:700}
.top-right{display:flex;align-items:center;gap:17px}
.status{display:inline-flex;align-items:center;gap:8px;color:var(--muted);font-size:11px;white-space:nowrap}
.dot{display:block;width:7px;height:7px;border-radius:50%;background:#586877}
.status.connected .dot{background:var(--good)}
.link-button{border:0;background:transparent;color:var(--muted);font-size:11px;font-weight:700;padding:9px 0}
.link-button:hover{color:var(--text)}
.wrap{width:min(100% - 68px,1120px);margin:0 auto}
main{padding:36px 0 50px}
.hero{display:flex;justify-content:space-between;align-items:end;gap:20px;margin-bottom:26px}
.eyebrow{color:var(--accent);font-size:10px;font-weight:780;letter-spacing:.15em;text-transform:uppercase}
h1{font-size:30px;line-height:1.15;letter-spacing:-.04em;margin:10px 0 8px;font-weight:760}
.hero p{color:var(--muted);margin:0;line-height:1.6;font-size:12px}
.primary{display:inline-flex;align-items:center;justify-content:center;gap:8px;border:1px solid transparent;border-radius:7px;background:var(--accent);color:#111a30;min-height:39px;padding:9px 15px;font-size:12px;font-weight:790}
.primary:hover{background:#b1bfff}
.secondary{display:inline-flex;align-items:center;justify-content:center;gap:8px;min-height:37px;padding:8px 13px;background:var(--raised);color:var(--text);border:1px solid var(--border);border-radius:6px;font-size:11px;font-weight:720}
.secondary:hover{background:#303c49;border-color:#4e6278}
.metrics{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin-bottom:22px}
.metric{background:var(--pane);border:1px solid var(--border);padding:21px;border-radius:8px;min-height:112px;position:relative}
.metric::before{content:"";width:21px;height:2px;position:absolute;left:21px;top:0;background:var(--accent)}
.metric-name{color:var(--muted);font-size:11px;font-weight:650}
.metric-number{font-size:29px;font-weight:760;letter-spacing:-.055em;margin-top:12px;font-variant-numeric:tabular-nums}
.panel{background:var(--pane);border:1px solid var(--border);border-radius:8px;overflow:hidden}
.panel-header{display:flex;justify-content:space-between;align-items:center;gap:18px;padding:20px 21px}
.panel-header h2{margin:0;font-size:14px;font-weight:760}
.panel-header p{margin:6px 0 0;font-size:11px;color:var(--dim)}
.tools{display:flex;gap:8px;align-items:center}
.search{position:relative;min-width:0}
.search svg{position:absolute;width:15px;height:15px;left:11px;top:11px;color:var(--dim);pointer-events:none}
.input,.select{border:1px solid #394754;border-radius:6px;background:#10161e;color:var(--text);font-size:12px;padding:9px 12px;min-height:37px;max-width:100%}
.input::placeholder{color:var(--dim)}
.input:focus,.select:focus{border-color:var(--accent);outline:0}
.search .input{padding-left:35px;width:220px}
.select{width:146px;cursor:pointer}
.list{overflow:auto}
table{border-collapse:collapse;width:100%;min-width:630px;text-align:left}
th{background:#171f29;color:var(--dim);font-size:10px;font-weight:740;letter-spacing:.09em;text-transform:uppercase}
th,td{white-space:nowrap;padding:16px 18px}
th:first-child,td:first-child{padding-left:21px}
th:last-child,td:last-child{padding-right:21px;text-align:right}
td{border-top:1px solid var(--line);font-size:11px;color:#bac9d4}
tr:hover td{background:#1e2933}
.key-name{color:var(--text);font-weight:760;display:block;max-width:220px;text-overflow:ellipsis;overflow:hidden;font-size:12px}
.key-id{display:block;font:10px/1.6 Consolas,ui-monospace,monospace;color:var(--dim);margin-top:4px}
.badge{display:inline-block;padding:5px 9px;border-radius:5px;font-size:10px;font-weight:750}
.badge.active{background:#20352d;color:var(--good)}
.badge.expiring,.badge.exhausted{background:#3a3026;color:var(--orange)}
.badge.revoked,.badge.expired{background:#3a242e;color:var(--red)}
.revoke{background:transparent;border:0;color:var(--red);font-size:11px;font-weight:740;padding:8px}
.revoke:hover{text-decoration:underline}
.empty{text-align:center!important;color:var(--muted);padding:48px 20px!important;white-space:normal}
.panel-foot{display:flex;justify-content:space-between;gap:12px;padding:13px 20px;border-top:1px solid var(--line);font-size:10px;color:var(--dim)}
.footer{display:flex;justify-content:space-between;gap:12px;color:var(--dim);font-size:10px;margin-top:22px}
.login-view{display:grid;place-items:center;min-height:calc(100vh - 170px)}
.login-card{width:min(100%,420px);background:var(--pane);border:1px solid var(--border);border-radius:9px;padding:33px}
.login-icon{display:grid;place-items:center;width:42px;height:42px;background:var(--accent-soft);border:1px solid #475a9a;color:var(--accent);border-radius:8px;margin-bottom:24px}
.login-icon svg{width:19px;height:19px}
.login-card h1{font-size:27px}
.login-card p{font-size:12px;line-height:1.65;color:var(--muted);margin:0 0 28px}
.field-label{display:block;font-size:11px;font-weight:720;color:var(--text);margin:0 0 9px}
.login-input{position:relative}
.login-input .input{width:100%;height:46px;padding-right:75px}
.reveal-toggle{position:absolute;right:10px;top:7px;border:0;background:transparent;color:var(--accent);font-size:11px;font-weight:650;padding:8px}
.login-card .primary{width:100%;margin-top:14px;min-height:44px}
.login-error{color:var(--red);min-height:18px;margin-top:12px;font-size:11px}
.login-note{margin-top:18px;padding-top:16px;border-top:1px solid var(--line);color:var(--dim);font-size:10px;line-height:1.6}
.shade{position:fixed;inset:0;background:rgba(3,6,11,.86);z-index:20;display:grid;place-items:center;padding:20px}
.dialog{width:min(100%,470px);max-height:min(92dvh,770px);overflow:auto;border-radius:10px;border:1px solid #435266;background:var(--pane);padding:25px}
.dialog-head{display:flex;justify-content:space-between;gap:20px;align-items:center}
.dialog-head h2{margin:0;font-size:19px;letter-spacing:-.03em}
.x-btn{border:1px solid var(--border);border-radius:6px;background:var(--raised);color:var(--muted);padding:8px}
.dialog-sub{color:var(--muted);font-size:11px;line-height:1.6;margin:8px 0 24px}
.form-field{margin-bottom:20px}
.form-field label{display:block;color:var(--text);font-size:11px;font-weight:740;margin-bottom:9px}
.form-field .input{width:100%;min-height:43px}
.hint{color:var(--dim);font-size:10px;line-height:1.65;margin-top:8px}
.days-presets{display:flex;gap:7px;margin-top:10px}
.preset{background:var(--raised);color:var(--muted);border:1px solid var(--border);border-radius:5px;padding:7px 11px;font-size:10px;font-weight:730}
.preset[aria-pressed=true]{background:var(--accent-soft);color:var(--accent);border-color:#485e9b}
.dialog-actions{border-top:1px solid var(--line);padding-top:18px;display:flex;justify-content:flex-end;gap:9px}
.created{margin-top:18px;background:var(--accent-soft);border:1px solid #496097;border-radius:7px;padding:15px}
.created-title{font-size:11px;font-weight:740;color:var(--accent);margin-bottom:9px}
.created-key{font:11px/1.65 Consolas,ui-monospace,monospace;overflow-wrap:anywhere;color:var(--text);user-select:all}
.created .secondary{margin-top:13px}
.toast{position:fixed;bottom:20px;right:22px;z-index:30;max-width:min(370px,calc(100% - 40px));border-radius:7px;padding:13px 16px;background:#273551;border:1px solid #435a8d;color:var(--text);font-size:12px}
.toast.error{background:#3d2731;border-color:#754656;color:#ffccdc}
@media(max-width:1120px){.panel-header{align-items:stretch;flex-direction:column}.tools{flex-wrap:wrap}}
@media(max-width:810px){
 .app-shell{display:block}.rail{padding:16px 20px;border-right:0;border-bottom:1px solid var(--border);display:flex;flex-direction:row;align-items:center;justify-content:space-between;gap:16px}
 .rail-menu{display:none}.rail-foot{margin-top:0;padding:0;border:0}.rail-foot span{display:none}
 .top{height:54px;padding:0 20px}.wrap{width:calc(100% - 36px)}main{padding-top:26px}
 .metrics{gap:7px}.metric{padding:15px;min-height:92px}.metric-number{font-size:24px}
 .hero{align-items:flex-start;flex-wrap:wrap}.login-view{min-height:calc(100vh - 220px)}
}
@media(max-width:550px){
 .metric-name{font-size:10px}.metric-number{font-size:21px}
 .metrics{grid-template-columns:repeat(3,minmax(0,1fr))}
 .tools{display:grid;grid-template-columns:minmax(0,1fr) 135px auto}.search .input{width:100%}
 .panel-header{padding:17px}.footer,.panel-foot{flex-wrap:wrap}.login-card{padding:25px}
 .dialog{padding:20px}.rail-foot{display:none}.days-presets{flex-wrap:wrap}
}
</style>
</head>
<body>
<div class="app-shell">
 <aside class="rail" aria-label="Vision Pro">
   <div class="logo"><span class="logo-square">VP</span><div><div class="logo-text">VISION PRO</div><div class="logo-small">ACCESS SYSTEM</div></div></div>
   <div class="rail-menu"><div class="rail-heading">ADMINISTRATION</div><div class="rail-entry"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></svg>Clés d'accès</div></div>
   <div class="rail-foot"><strong>VISION / PRIVATE BETA</strong><span>Console privée<br>Contrôle des activations</span></div>
 </aside>
 <div class="work">
 <header class="top">
   <div class="breadcrumb">Espace privé <span aria-hidden="true">/</span> <strong>Gestion des clés</strong></div>
   <div class="top-right"><span id="connection" class="status"><i class="dot" aria-hidden="true"></i>Hors connexion</span><button id="logout" type="button" class="link-button" hidden>Déconnexion</button></div>
 </header>
 <main class="wrap">
   <section id="loginView" class="login-view" aria-label="Connexion administrateur">
     <form id="loginForm" class="login-card">
       <div class="login-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg></div>
       <div class="eyebrow">Authentification / admin</div>
       <h1>Accès à la console</h1>
       <p>Entre ton jeton administrateur pour gérer les accès bêta et les activations.</p>
       <label class="field-label" for="token">Jeton administrateur</label>
       <div class="login-input"><input id="token" class="input" type="password" autocomplete="off" spellcheck="false" placeholder="Jeton privé" required><button id="toggleToken" class="reveal-toggle" type="button">Afficher</button></div>
       <button id="loginButton" type="submit" class="primary">Ouvrir le tableau de bord →</button>
       <div id="loginError" class="login-error" aria-live="polite" role="alert"></div>
       <div class="login-note">Le jeton reste uniquement en mémoire durant cette session. Il n'est pas enregistré localement.</div>
     </form>
   </section>
   <div id="dashboard" hidden>
     <section class="hero"><div><div class="eyebrow">VISION PRO / GESTION</div><h1>Gestion des clés</h1><p>Contrôle les accès bêta depuis une interface unique.</p></div>
       <button type="button" id="openCreate" class="primary"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>Créer une clé</button></section>
     <section class="metrics" aria-label="Statistiques">
       <div class="metric"><div class="metric-name">Clés actives</div><div class="metric-number" id="statActive">—</div></div>
       <div class="metric"><div class="metric-name">Clés enregistrées</div><div class="metric-number" id="statTotal">—</div></div>
       <div class="metric"><div class="metric-name">Activations utilisées</div><div class="metric-number" id="statUses">—</div></div>
     </section>
     <section class="panel" aria-label="Liste des clés">
       <div class="panel-header"><div><h2>Clés enregistrées</h2><p>Expiration, quotas et accès actifs.</p></div>
         <div class="tools">
           <label class="search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6.5"/><path d="m16 16 5 5"/></svg><input id="search" class="input" type="search" placeholder="Chercher une clé" aria-label="Chercher une clé"></label>
           <select id="statusFilter" class="select" aria-label="Filtrer les clés"><option value="all">Tous les états</option><option value="active">Actives</option><option value="expiring">Bientôt expirées</option><option value="exhausted">Épuisées</option><option value="expired">Expirées</option><option value="revoked">Révoquées</option></select>
           <button id="refresh" type="button" class="secondary" aria-label="Actualiser"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 11a8 8 0 1 0-2 6M20 4v7h-7"/></svg></button>
         </div></div>
       <div class="list"><table><thead><tr><th>Nom / identifiant</th><th>État</th><th>Expiration</th><th>Activations</th><th>Action</th></tr></thead><tbody id="rows"><tr><td colspan="5" class="empty">Connecte-toi pour afficher les clés.</td></tr></tbody></table></div>
       <div class="panel-foot"><span id="count">0 clé</span><span>Une clé n'est affichée en clair qu'à sa création.</span></div>
     </section>
     <footer class="footer"><span>VISION PRO / KEY CONTROL</span><span>Clés protégées par empreinte SHA-256</span></footer>
   </div>
 </main>
 </div>
</div>
<div id="createShade" class="shade" hidden>
 <section class="dialog" role="dialog" aria-modal="true" aria-labelledby="dialogTitle">
   <div class="dialog-head"><h2 id="dialogTitle">Créer une clé</h2><button id="closeCreate" type="button" class="x-btn" aria-label="Fermer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 5l14 14M19 5 5 19"/></svg></button></div>
   <p class="dialog-sub">Paramètres de la clé bêta : nom, validité et activations.</p>
   <form id="createForm">
     <div class="form-field"><label for="keyName">Nom de la clé</label><input id="keyName" class="input" maxlength="64" required value="Beta V4" placeholder="Nom de la clé"></div>
     <div class="form-field"><label for="days">Durée de validité (jours)</label><input id="days" class="input" type="number" min="0" max="3650" step="1" required value="30">
       <div class="days-presets"><button type="button" class="preset" data-days="7" aria-pressed="false">7 j</button><button type="button" class="preset" data-days="30" aria-pressed="true">30 j</button><button type="button" class="preset" data-days="90" aria-pressed="false">90 j</button><button type="button" class="preset" data-days="0" aria-pressed="false">Illimité</button></div>
       <div class="hint">0 = aucune expiration.</div>
     </div>
     <div class="form-field"><label for="maxActivations">Activations maximum</label><input id="maxActivations" class="input" type="number" min="0" max="100000" step="1" required value="0"><div class="hint">0 = illimité. Chaque vérification réussie consomme une activation.</div></div>
     <div class="dialog-actions"><button id="cancelCreate" type="button" class="secondary">Annuler</button><button id="generate" type="submit" class="primary">Générer la clé</button></div>
   </form>
   <div id="created" class="created" hidden><div class="created-title">CLÉ CRÉÉE / COPIE IMMÉDIATE</div><div class="created-key" id="generatedKey"></div><button id="copy" type="button" class="secondary">Copier la clé</button><div class="hint">Impossible d'afficher à nouveau cette clé après fermeture.</div></div>
 </section>
</div>
<div id="toast" class="toast" role="status" aria-live="polite" hidden></div>
<script>
(() => {
"use strict";
const $=id=>document.getElementById(id);
const state={token:"",keys:[],busy:false,search:"",filter:"all"};
let toastTimer,lastFocus=null;
const now=()=>Math.floor(Date.now()/1000);
function notify(message,error=false){
 const el=$("toast");el.textContent=message;el.classList.toggle("error",error);el.hidden=false;
 clearTimeout(toastTimer);toastTimer=setTimeout(()=>{el.hidden=true},4000);
}
async function api(path,method="GET",payload,credential=state.token){
 if(!credential)throw Error("Jeton administrateur requis.");
 const response=await fetch(path,{method,headers:{"Authorization":"Bearer "+credential,"Content-Type":"application/json"},body:payload===undefined?undefined:JSON.stringify(payload),cache:"no-store"});
 let data;try{data=await response.json()}catch{throw Error("Réponse du serveur invalide.");}
 if(!response.ok||!data||data.ok!==true)throw Error(data?.message||"Erreur serveur");
 return data;
}
function keyStatus(key){
 if(key.disabled)return "revoked";
 if(key.expiresAt>0&&key.expiresAt<=now())return "expired";
 if(key.maxActivations>0&&key.uses>=key.maxActivations)return "exhausted";
 if(key.expiresAt>0&&key.expiresAt<=now()+604800)return "expiring";
 return "active";
}
const statusLabels={active:"Active",expiring:"Expire bientôt",exhausted:"Épuisée",expired:"Expirée",revoked:"Révoquée"};
const dateLabel=timestamp=>timestamp?new Date(timestamp*1000).toLocaleDateString("fr-FR",{day:"2-digit",month:"short",year:"numeric"}):"Sans limite";
function addCell(row,value,className){
 const cell=document.createElement("td");cell.textContent=value;if(className)cell.className=className;row.append(cell);return cell;
}
function render(){
 const keys=state.keys;
 const active=keys.filter(k=>["active","expiring"].includes(keyStatus(k))).length;
 $("statActive").textContent=active.toLocaleString("fr-FR");
 $("statTotal").textContent=keys.length.toLocaleString("fr-FR");
 $("statUses").textContent=keys.reduce((n,k)=>n+(Number(k.uses)||0),0).toLocaleString("fr-FR");
 const search=state.search.trim().toLocaleLowerCase("fr-FR");
 const selected=keys.filter(k=>{
  const matches=!search||String(k.label||"").toLocaleLowerCase("fr-FR").includes(search)||String(k.id||"").toLocaleLowerCase("fr-FR").includes(search);
  return matches&&(state.filter==="all"||state.filter===keyStatus(k));
 });
 const rows=$("rows");rows.replaceChildren();
 if(selected.length===0){
  const row=document.createElement("tr");addCell(row,keys.length?"Aucun résultat pour cette recherche.":"Aucune clé pour le moment. Clique sur « Nouvelle clé ».","empty").colSpan=5;rows.append(row);
 }else for(const k of selected){
  const row=document.createElement("tr"),first=document.createElement("td");
  const name=document.createElement("span"),id=document.createElement("span");
  name.className="key-name";name.textContent=k.label||"Clé sans nom";name.title=name.textContent;
  id.className="key-id";id.textContent=k.id;
  first.append(name,id);row.append(first);
  const badgeCell=document.createElement("td"),badge=document.createElement("span");
  const status=keyStatus(k);
  badge.className="badge "+status;badge.textContent=statusLabels[status];badgeCell.append(badge);row.append(badgeCell);
  addCell(row,dateLabel(k.expiresAt));
  addCell(row,k.uses+" / "+(k.maxActivations||"∞"));
  const control=document.createElement("td");
  if(status!=="revoked"){
   const btn=document.createElement("button");btn.type="button";btn.className="revoke";btn.textContent="Révoquer";
   btn.addEventListener("click",()=>revoke(k));control.append(btn);
  }else control.textContent="—";
  row.append(control);rows.append(row);
 }
 $("count").textContent=selected.length+" clé"+(selected.length!==1?"s":"")+" affichée"+(selected.length!==1?"s":"");
}
async function refresh(){
 const data=await api("/api/admin/keys");
 state.keys=Array.isArray(data.keys)?data.keys:[];render();
}
async function login(event){
 event.preventDefault();if(state.busy)return;
 const candidate=$("token").value.trim();
 if(candidate.length<32){$("loginError").textContent="Entre ton jeton administrateur complet.";return}
 state.busy=true;$("loginButton").disabled=true;$("loginButton").textContent="Connexion...";
 $("loginError").textContent="";
 try{
  const result=await api("/api/admin/keys","GET",undefined,candidate);
  state.token=candidate;state.keys=Array.isArray(result.keys)?result.keys:[];
  $("token").value="";$("loginView").hidden=true;$("dashboard").hidden=false;$("logout").hidden=false;
  $("connection").classList.add("connected");$("connection").lastChild.textContent="Connecté";render();
 }catch(e){$("loginError").textContent=e.message||"Connexion refusée."}
 finally{state.busy=false;$("loginButton").disabled=false;$("loginButton").textContent="Accéder au tableau de bord →"}
}
function closeDialog(){
 if(state.busy)return;
 $("createShade").hidden=true;$("created").hidden=true;$("generatedKey").textContent="";
 if(lastFocus&&document.contains(lastFocus))lastFocus.focus();
 lastFocus=null;
}
function openDialog(){
 lastFocus=document.activeElement;
 $("generatedKey").textContent="";$("created").hidden=true;
 $("createShade").hidden=false;
 $("keyName").focus();
}
async function revoke(key){
 if(!confirm('Révoquer « '+key.label+' » ? Cette clé sera inutilisable.'))return;
 try{await api("/api/admin/revoke","POST",{id:key.id});await refresh();notify("Clé révoquée.")}
 catch(e){notify(e.message||"Révocation impossible.",true)}
}
function presets(){document.querySelectorAll("[data-days]").forEach(b=>b.setAttribute("aria-pressed",String(Number(b.dataset.days)===Number($("days").value))))}
async function createKey(event){
 event.preventDefault();if(state.busy)return;
 const label=$("keyName").value.trim(),days=Number($("days").value),maxActivations=Number($("maxActivations").value);
 if(!label)return notify("Donne un nom à la clé.",true);
 if(!Number.isInteger(days)||days<0||days>3650)return notify("Durée invalide.",true);
 if(!Number.isInteger(maxActivations)||maxActivations<0||maxActivations>100000)return notify("Limite d'activations invalide.",true);
 state.busy=true;$("generate").disabled=true;$("generate").textContent="Création...";
 try{
  const result=await api("/api/admin/generate","POST",{label,days,maxActivations});
  $("generatedKey").textContent=result.key;$("created").hidden=false;
  try{await refresh()}catch{notify("Clé créée, mais actualisation impossible.",true);return}
  notify("Clé créée. Pense à la copier.");
 }catch(e){notify(e.message||"Erreur lors de la création.",true)}
 finally{state.busy=false;$("generate").disabled=false;$("generate").textContent="Générer la clé"}
}
async function copyKey(){
 const value=$("generatedKey").textContent;if(!value)return;
 try{await navigator.clipboard.writeText(value);notify("Clé copiée.")}
 catch{const range=document.createRange();range.selectNodeContents($("generatedKey"));window.getSelection().removeAllRanges();window.getSelection().addRange(range);notify("Clé sélectionnée. Fais Ctrl + C.")}
}
$("loginForm").addEventListener("submit",login);
$("logout").addEventListener("click",()=>{
 if(state.busy)return;
 state.token="";state.keys=[];$("dashboard").hidden=true;$("loginView").hidden=false;$("logout").hidden=true;
 $("connection").classList.remove("connected");$("connection").lastChild.textContent="Hors connexion";
 $("token").type="password";$("toggleToken").textContent="Afficher";$("loginError").textContent="";
 state.search="";state.filter="all";$("search").value="";$("statusFilter").value="all";
 closeDialog();$("token").focus();
});
$("toggleToken").addEventListener("click",()=>{const input=$("token");input.type=input.type==="password"?"text":"password";$("toggleToken").textContent=input.type==="password"?"Afficher":"Masquer"});
$("openCreate").addEventListener("click",openDialog);
$("closeCreate").addEventListener("click",closeDialog);
$("cancelCreate").addEventListener("click",closeDialog);
$("createShade").addEventListener("click",e=>{if(e.target===$("createShade"))closeDialog()});
document.addEventListener("keydown",e=>{
 if(e.key==="Escape"&&!$("createShade").hidden){e.preventDefault();closeDialog();return}
 if(e.key==="Tab"&&!$("createShade").hidden){
  const controls=[...$("createShade").querySelectorAll("button:not(:disabled),input:not(:disabled)")].filter(x=>x.getClientRects().length>0);
  if(!controls.length)return;
  const first=controls[0],last=controls[controls.length-1];
  if(e.shiftKey&&document.activeElement===first){e.preventDefault();last.focus()}
  else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first.focus()}
 }
});
$("createForm").addEventListener("submit",createKey);
$("refresh").addEventListener("click",async()=>{$("refresh").disabled=true;try{await refresh();notify("Liste actualisée.")}catch(e){notify(e.message,true)}finally{$("refresh").disabled=false}});
$("copy").addEventListener("click",copyKey);
$("search").addEventListener("input",e=>{state.search=e.target.value;render()});
$("statusFilter").addEventListener("change",e=>{state.filter=e.target.value;render()});
$("days").addEventListener("input",presets);
document.querySelectorAll("[data-days]").forEach(b=>b.addEventListener("click",()=>{$("days").value=b.dataset.days;presets()}));
})();
</script>
</body>
</html>`;

// ============================================================================
// 2. HTTP RESPONSES AND PAGE SECURITY
// ============================================================================
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
// ============================================================================
// 3. CRYPTOGRAPHY AND INPUT VALIDATION
// ============================================================================
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
// ============================================================================
// 4. RATE LIMIT AND BETA VERIFICATION
// ============================================================================
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
// ============================================================================
// 5. ADMIN ENDPOINTS AND KEY MANAGEMENT
// ============================================================================
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
// ============================================================================
// VISION BETA 0.9.1 - public key generation with server-side limits.
// No client credentials. Legacy /api/admin/* routes remain protected.
async function visionReserveQuota(request, env, now) {
  const ip = request.headers.get("CF-Connecting-IP");
  if (!ip) return false;
  const ipHash = await sha256("vision-beta-public:v1:" + ip + ":" + env.ADMIN_TOKEN);
  const cutoff = now - 86400;
  const reservation = await env.DB.prepare(
    "INSERT INTO beta_attempts(ip_hash,attempts,window_start) VALUES(?,1,?) " +
    "ON CONFLICT(ip_hash) DO UPDATE SET " +
    "attempts=CASE WHEN beta_attempts.window_start <= ? THEN 1 ELSE beta_attempts.attempts+1 END, " +
    "window_start=CASE WHEN beta_attempts.window_start <= ? THEN excluded.window_start ELSE beta_attempts.window_start END " +
    "WHERE beta_attempts.window_start <= ? OR beta_attempts.attempts < 3 " +
    "RETURNING attempts"
  ).bind(ipHash,now,cutoff,cutoff,cutoff).first();
  return reservation !== null;
}
async function visionGeneratePublic(request, env) {
  const data = await bodyJSON(request);
  const label = typeof data.label === "string" ? data.label.trim() : "";
  if (label.length < 1 || label.length > 64)
    return reply({ok:false,message:"Nom de clé invalide (1 à 64 caractères)."},400);
  if (data.days !== 1)
    return reply({ok:false,message:"Durée limitée à 24 heures."},400);
  if (!Number.isInteger(data.maxActivations) || data.maxActivations < 1 || data.maxActivations > 100)
    return reply({ok:false,message:"Les activations doivent être entre 1 et 100."},400);
  const now = Math.floor(Date.now()/1000);
  if (!(await visionReserveQuota(request,env,now)))
    return reply({ok:false,message:"Quota atteint : 3 clés par IP sur 24 heures."},429);
  const key = "VP4-" + randomHex(24).match(/.{1,8}/g).join("-");
  const id = randomHex(8);
  const expiresAt = now + 86400;
  const keyHash = await sha256(key);
  await env.DB.prepare(
    "INSERT INTO beta_keys(id,key_hash,label,created_at,expires_at,max_activations,uses,disabled) VALUES(?,?,?,?,?,?,0,0)"
  ).bind(id,keyHash,label,now,expiresAt,data.maxActivations).run();
  return reply({ok:true,key,id,label,expiresAt,maxActivations:data.maxActivations});
}

// 6. CLOUDFLARE WORKER ROUTING
// ============================================================================
export default{
 async fetch(request,env){
  const url=new URL(request.url);
  if(url.pathname==="/admin"&&request.method==="GET")return html();
  if(url.pathname==="/"&&request.method==="GET")return Response.redirect(url.origin+"/admin",302);
  if(!env.DB)return reply({ok:false,message:"D1 non configure"},503);
  if(!env.ADMIN_TOKEN||env.ADMIN_TOKEN.length<32)return reply({ok:false,message:"Secret admin non configure"},503);
  try{
   if(url.pathname==="/api/verify"&&request.method==="POST")return await verify(request,env);
   if(url.pathname==="/api/public/status"&&request.method==="GET")return reply({ok:true,service:"VISION",durationHours:24,version:"0.9.2"});
   if(url.pathname==="/api/public/generate"&&request.method==="POST")return await visionGeneratePublic(request,env);
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