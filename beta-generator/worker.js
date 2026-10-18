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
<meta name="theme-color" content="#0d1015">
<title>VISION PRO — Beta</title>
<style>
:root {
  color-scheme:dark;
  font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;
  --bg:#0d1015;
  --panel:#161b23;
  --panel-raised:#1b222d;
  --line:#29313d;
  --line-active:#52617a;
  --ink:#f0f3fa;
  --muted:#99a6b9;
  --dim:#758398;
  --blue:#91afff;
  --blue-dark:#131f35;
  --green:#9ddab6;
  --red:#efafb8;
  --amber:#f3d39a;
  font-synthesis:none;
  -webkit-font-smoothing:antialiased;
}
* {
  box-sizing:border-box;
}
html {
  scroll-behavior:smooth;
}
body {
  margin:0;
  min-width:320px;
  background:var(--bg);
  color:var(--ink);
  font-size:13px;
}
button,input,select {
  font:inherit;
}
button {
  cursor:pointer;
}
button:disabled {
  opacity:.55;
  cursor:not-allowed;
}
button:focus-visible,input:focus-visible,select:focus-visible {
  outline:2px solid var(--blue);
  outline-offset:2px;
}
[hidden] {
  display:none!important;
}
svg {
  display:block;
  width:17px;
  height:17px;
  stroke:currentColor;
  stroke-width:1.8;
  fill:none;
  stroke-linecap:round;
  stroke-linejoin:round;
}
.wrap {
  width:min(100% - 44px,1050px);
  margin:auto;
}
.top {
  height:72px;
  border-bottom:1px solid var(--line);
  display:flex;
  align-items:center;
}
.top-inner {
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:16px;
}
.logo {
  display:flex;
  align-items:center;
  gap:11px;
}
.logo-square {
  display:grid;
  place-items:center;
  width:33px;
  height:33px;
  border-radius:8px;
  background:#b5c9ff;
  color:#142139;
  font-size:16px;
  letter-spacing:-.08em;
  font-weight:850;
}
.logo-text {
  font-size:13px;
  font-weight:800;
  letter-spacing:.10em;
}
.logo-small {
  margin-top:3px;
  color:var(--dim);
  font-size:10px;
  font-weight:600;
  letter-spacing:.08em;
}
.top-right {
  display:flex;
  align-items:center;
  gap:12px;
}
.status {
  display:flex;
  align-items:center;
  gap:8px;
  color:var(--muted);
  font-size:11px;
  white-space:nowrap;
}
.dot {
  width:7px;
  height:7px;
  border-radius:50%;
  background:#677389;
}
.status.connected .dot {
  background:var(--green);
}
.link-button {
  padding:7px 0;
  border:0;
  background:none;
  color:var(--muted);
  font-size:11px;
  font-weight:650;
}
.link-button:hover {
  color:var(--ink);
}
main {
  padding:43px 0 48px;
}
.hero {
  display:flex;
  justify-content:space-between;
  align-items:end;
  gap:15px;
  margin-bottom:29px;
}
.eyebrow {
  font-size:10px;
  font-weight:750;
  text-transform:uppercase;
  letter-spacing:.14em;
  color:var(--blue);
}
h1 {
  font-size:clamp(25px,4vw,33px);
  letter-spacing:-.048em;
  font-weight:720;
  line-height:1.2;
  margin:10px 0 8px;
}
.hero p {
  font-size:12px;
  color:var(--muted);
  margin:0;
  line-height:1.55;
}
.primary {
  border:1px solid transparent;
  background:var(--blue);
  color:#142037;
  border-radius:8px;
  padding:11px 15px;
  display:inline-flex;
  gap:9px;
  align-items:center;
  justify-content:center;
  white-space:nowrap;
  font-size:12px;
  font-weight:750;
  min-height:40px;
}
.primary:hover {
  background:#bed0ff;
}
.secondary {
  display:inline-flex;
  align-items:center;
  justify-content:center;
  gap:7px;
  padding:9px 11px;
  background:var(--panel-raised);
  border:1px solid var(--line);
  border-radius:7px;
  color:var(--ink);
  font-size:11px;
  font-weight:630;
}
.secondary:hover {
  border-color:var(--line-active);
  background:#243041;
}
.metrics {
  display:grid;
  grid-template-columns:repeat(3,minmax(0,1fr));
  gap:13px;
  margin-bottom:23px;
}
.metric {
  background:var(--panel);
  border:1px solid var(--line);
  border-radius:10px;
  padding:19px 20px;
}
.metric-name {
  color:var(--muted);
  font-size:11px;
}
.metric-number {
  margin-top:14px;
  font-size:28px;
  line-height:1;
  font-weight:700;
  letter-spacing:-.045em;
  font-variant-numeric:tabular-nums;
}
.panel {
  background:var(--panel);
  border:1px solid var(--line);
  border-radius:11px;
  overflow:hidden;
}
.panel-header {
  display:flex;
  justify-content:space-between;
  align-items:center;
  gap:16px;
  padding:19px 20px;
}
.panel-header h2 {
  margin:0;
  font-size:14px;
  font-weight:740;
}
.panel-header p {
  margin:5px 0 0;
  color:var(--dim);
  font-size:11px;
}
.tools {
  display:flex;
  gap:9px;
  align-items:center;
}
.search {
  position:relative;
  min-width:0;
}
.search svg {
  position:absolute;
  left:10px;
  top:10px;
  color:var(--dim);
  width:15px;
  height:15px;
  pointer-events:none;
}
.input,.select {
  color:var(--ink);
  background:#111720;
  border:1px solid #384454;
  border-radius:7px;
  padding:9px 12px;
  min-height:37px;
  outline:none;
  font-size:12px;
  max-width:100%;
}
.input::placeholder {
  color:var(--dim);
}
.input:focus,.select:focus {
  border-color:#708ebc;
}
.search .input {
  padding-left:33px;
  width:228px;
}
.select {
  width:124px;
  cursor:pointer;
}
.list {
  overflow-x:auto;
}
table {
  border-collapse:collapse;
  width:100%;
  min-width:650px;
  text-align:left;
}
th {
  background:#1a202a;
  color:#8694a9;
  letter-spacing:.065em;
  text-transform:uppercase;
  font-size:10px;
  font-weight:720;
}
td,th {
  padding:15px 18px;
  white-space:nowrap;
}
td:first-child,th:first-child {
  padding-left:22px;
}
td:last-child,th:last-child {
  padding-right:21px;
  text-align:right;
}
td {
  border-top:1px solid var(--line);
  font-size:11px;
  color:#c3cfde;
}
tr:hover td {
  background:#1b242e;
}
.key-name {
  font-size:12px;
  font-weight:700;
  color:var(--ink);
  display:block;
  max-width:220px;
  overflow:hidden;
  text-overflow:ellipsis;
}
.key-id {
  display:block;
  margin-top:5px;
  color:var(--dim);
  font-family:ui-monospace,Menlo,Consolas,monospace;
  font-size:10px;
}
.badge {
  border-radius:6px;
  padding:5px 9px;
  display:inline-block;
  font-size:10px;
  font-weight:700;
}
.badge.active {
  background:#20372d;
  color:var(--green);
}
.badge.expiring,.badge.exhausted {
  background:#372d21;
  color:var(--amber);
}
.badge.revoked,.badge.expired {
  background:#38242b;
  color:var(--red);
}
.revoke {
  border:0;
  background:none;
  color:#e7acb6;
  font-size:11px;
  font-weight:700;
  padding:7px 0;
}
.revoke:hover {
  color:#ffced4;
}
.empty {
  text-align:center!important;
  color:var(--muted);
  padding:44px 20px!important;
  white-space:normal;
}
.panel-foot {
  border-top:1px solid var(--line);
  padding:13px 20px;
  display:flex;
  justify-content:space-between;
  gap:10px;
  color:var(--dim);
  font-size:11px;
}
.footer {
  margin-top:25px;
  color:var(--dim);
  display:flex;
  justify-content:space-between;
  gap:16px;
  font-size:10px;
}
.login-view {
  min-height:calc(100vh - 135px);
  display:grid;
  place-items:center;
}
.login-card {
  width:min(100%,390px);
  background:var(--panel);
  border:1px solid var(--line);
  border-radius:12px;
  padding:30px;
}
.login-icon {
  display:grid;
  place-items:center;
  width:40px;
  height:40px;
  border-radius:9px;
  border:1px solid #496182;
  background:var(--blue-dark);
  color:var(--blue);
  margin-bottom:24px;
}
.login-icon svg {
  width:19px;
  height:19px;
}
.login-card h1 {
  font-size:25px;
  margin-bottom:9px;
}
.login-card p {
  color:var(--muted);
  line-height:1.65;
  margin:0 0 26px;
  font-size:12px;
}
.field-label {
  display:block;
  margin-bottom:8px;
  font-size:11px;
  color:#cbd5e3;
  font-weight:680;
}
.login-input {
  position:relative;
}
.login-input input {
  width:100%;
  padding-right:70px;
  height:42px;
}
.reveal-toggle {
  position:absolute;
  top:7px;
  right:10px;
  font-size:11px;
  color:var(--blue);
  background:none;
  border:0;
  padding:7px 3px;
}
.login-card .primary {
  width:100%;
  margin-top:15px;
}
.login-error {
  min-height:17px;
  font-size:11px;
  color:var(--red);
  margin-top:12px;
  line-height:1.5;
}
.login-note {
  border-top:1px solid var(--line);
  margin-top:17px;
  padding-top:15px;
  font-size:10px;
  line-height:1.55;
  color:var(--dim);
}
.shade {
  position:fixed;
  inset:0;
  z-index:10;
  background:#05080cbb;
  display:grid;
  place-items:center;
  padding:20px;
}
.dialog {
  width:min(100%,448px);
  max-height:min(94dvh,750px);
  overflow-y:auto;
  border:1px solid #344356;
  background:var(--panel);
  border-radius:13px;
  padding:25px;
  box-shadow:0 24px 70px #0009;
}
.dialog-head {
  display:flex;
  justify-content:space-between;
  align-items:center;
  margin-bottom:7px;
}
.dialog-head h2 {
  margin:0;
  font-size:19px;
  font-weight:730;
  letter-spacing:-.035em;
}
.x-btn {
  border:0;
  background:#252f3c;
  color:var(--muted);
  padding:7px;
  border-radius:7px;
}
.x-btn:hover {
  color:var(--ink);
}
.dialog-sub {
  font-size:11px;
  color:var(--muted);
  line-height:1.6;
  margin:0 0 22px;
}
.form-field {
  margin-bottom:20px;
}
.form-field label {
  display:block;
  font-weight:680;
  font-size:11px;
  margin-bottom:8px;
  color:#cdd6e4;
}
.form-field .input {
  width:100%;
  min-height:41px;
}
.hint {
  margin-top:7px;
  color:var(--dim);
  font-size:10px;
  line-height:1.6;
}
.days-presets {
  display:flex;
  gap:7px;
  margin-top:10px;
}
.preset {
  background:#111822;
  border:1px solid var(--line);
  color:var(--muted);
  border-radius:6px;
  padding:7px 12px;
  font-size:10px;
  font-weight:700;
}
.preset[aria-pressed=true] {
  background:#233653;
  color:var(--blue);
  border-color:#49678e;
}
.dialog-actions {
  display:flex;
  justify-content:flex-end;
  gap:9px;
  padding-top:18px;
  border-top:1px solid var(--line);
}
.created {
  border:1px solid #415d81;
  background:#162538;
  padding:15px;
  border-radius:8px;
  margin-top:17px;
}
.created-title {
  color:var(--blue);
  font-weight:720;
  font-size:11px;
  margin-bottom:9px;
}
.created-key {
  font:11px/1.7 ui-monospace,Menlo,Consolas,monospace;
  color:var(--ink);
  overflow-wrap:anywhere;
  user-select:all;
}
.created .secondary {
  margin-top:13px;
}
.toast {
  position:fixed;
  bottom:20px;
  right:20px;
  z-index:20;
  max-width:min(360px,calc(100% - 40px));
  padding:13px 16px;
  background:#213149;
  border:1px solid #456188;
  color:var(--ink);
  border-radius:8px;
  box-shadow:0 12px 35px #0007;
  font-size:12px;
  line-height:1.5;
}
.toast.error {
  background:#38242a;
  border-color:#754650;
  color:#ffc8cf;
}
@media(max-width:800px) {
  .panel-header {
    align-items:stretch;
    flex-direction:column;
  }
  .tools {
    width:100%;
  }
  .search {
    flex:1;
  }
  .search .input {
    width:100%;
  }
  .main {
    padding-top:31px;
  }
}
@media(max-width:570px) {
  .wrap {
    width:min(100% - 30px,1050px);
  }
  .hero {
    align-items:flex-start;
    flex-direction:column;
  }
  .metrics {
    gap:7px;
  }
  .metric {
    padding:14px 11px;
  }
  .metric-number {
    font-size:24px;
  }
  .metric-name {
    font-size:10px;
  }
  .tools {
    flex-wrap:wrap;
  }
  .search {
    flex:1 1 100%;
  }
  .select {
    width:100%;
    flex:1 1 100%;
  }
  .panel-foot,.footer {
    flex-direction:column;
  }
  .top-right {
    gap:8px;
  }
  .status {
    font-size:10px;
  }
}
@media(prefers-reduced-motion:reduce) {
  html {
    scroll-behavior:auto;
  }
}

/* ==============================================================
   VISION PRO / NEON EDITION
   Premium dark palette. Purple + cyan accent. Responsive.
   ============================================================== */
:root {
  --bg:#080911;
  --panel:#131625;
  --panel-raised:#1b2033;
  --line:#34374c;
  --ink:#f3f2ff;
  --muted:#abb0c7;
  --dim:#8992af;
  --blue:#ae80ff;
  --blue-dark:#24203e;
  --green:#9ef0cc;
  --red:#ffacbd;
  --amber:#ffdda3;
  --violet:#ae80ff;
  --cyan:#71edf4;
  --hotpink:#ff7cbd;
}
html { scroll-behavior:smooth; }
body {
  min-height:100vh;
  background:
    radial-gradient(ellipse 720px 510px at 3% -8%, #813cef36, transparent 72%),
    radial-gradient(ellipse 570px 440px at 97% 18%, #14bfd524, transparent 76%),
    #080911;
  color:var(--ink);
  isolation:isolate;
}
body::before {
  content:"";
  position:fixed;
  z-index:-1;
  inset:0;
  pointer-events:none;
  background-image:
    linear-gradient(#9b7bda0a 1px,transparent 1px),
    linear-gradient(90deg,#9b7bda0a 1px,transparent 1px);
  background-size:48px 48px;
  mask-image:linear-gradient(to bottom,#000b,transparent 85%);
}
button { transition:background .15s ease,border-color .15s ease,box-shadow .15s ease,transform .15s ease,color .15s ease; }
button:focus-visible,input:focus-visible,select:focus-visible {
  outline:2px solid var(--cyan);
  outline-offset:3px;
}
.wrap { width:min(100% - 46px,1100px); }
.top {
  position:relative;
  min-height:79px;
  background:#0c0e19c9;
  border-bottom:1px solid #3b3653;
  backdrop-filter:blur(20px);
  -webkit-backdrop-filter:blur(20px);
}
.top::after {
  content:"";
  position:absolute;
  left:0;right:0;bottom:-1px;
  height:1px;
  background:linear-gradient(90deg,transparent,#b07bff9a 31%,#71edf487 71%,transparent);
}
.top-inner { min-height:79px; }
.logo { gap:13px; }
.logo-square {
  width:41px;height:41px;
  border-radius:11px;
  background:linear-gradient(140deg,#b979ff,#7046d0 70%,#47328e);
  border:1px solid #c99fff88;
  box-shadow:0 0 25px #9252ee66,inset 0 1px 0 #ffffff44;
  color:#fff;
  font-size:20px;
}
.logo-text { font-size:14px;font-weight:850;letter-spacing:.13em; }
.logo-small { color:var(--cyan);font-size:10px;letter-spacing:.21em; }
.top-right { gap:18px; }
.status { color:var(--muted);font-weight:550; }
.dot { width:8px;height:8px;box-shadow:0 0 0 4px #717e9a18; }
.status.connected .dot {
  background:var(--green);
  box-shadow:0 0 0 4px #96edc51a,0 0 13px #8bf2c499;
}
.link-button { color:var(--muted);font-weight:690; }
.link-button:hover { color:var(--cyan); }
main { padding-top:52px; }
.eyebrow {
  display:inline-flex;align-items:center;gap:9px;
  color:var(--cyan);font-weight:800;letter-spacing:.17em;
}
.eyebrow::before {
  content:"";width:15px;height:2px;border-radius:3px;
  background:var(--cyan);box-shadow:0 0 9px var(--cyan);
}
h1 {
  font-weight:790;
  letter-spacing:-.065em;
}
.hero { gap:20px;margin-bottom:31px; }
.hero h1 {
  font-size:clamp(31px,4.4vw,44px);
  line-height:1.12;
  background:linear-gradient(105deg,#fff,#dacbff 62%,#83f1f5 110%);
  -webkit-background-clip:text;
  background-clip:text;
  color:transparent;
}
.hero p { color:var(--muted);font-size:12px;line-height:1.7; }
.primary {
  min-height:44px;
  border:1px solid #c6a1ff99;
  border-radius:10px;
  background:linear-gradient(115deg,#9d5af4,#7045dc);
  color:#fff;
  font-weight:800;
  padding:11px 18px;
  box-shadow:0 4px 22px #823fec64,inset 0 1px 1px #ffffff4c;
}
.primary:hover {
  background:linear-gradient(115deg,#b072ff,#875ae9);
  box-shadow:0 6px 32px #8a4fff8c,inset 0 1px 1px #ffffff70;
  transform:translateY(-1px);
}
.primary:active { transform:translateY(0); }
.secondary {
  border:1px solid #474260;
  border-radius:9px;
  background:#22253a;
  color:#e1dff7;
}
.secondary:hover { border-color:#9070c7;background:#2a2a47; }
.metrics { gap:16px;margin-bottom:25px; }
.metric {
  position:relative;
  min-height:136px;
  padding:24px 24px 21px;
  border:1px solid #3c3856;
  border-radius:14px;
  background:
    radial-gradient(circle at 100% 0%,#9955e826,transparent 58%),
    linear-gradient(155deg,#1a1b2d,#141725);
  box-shadow:0 10px 40px #0003,inset 0 1px 0 #ffffff10;
}
.metric::before {
  content:"";
  position:absolute;top:0;left:24px;width:105px;height:2px;
  background:linear-gradient(90deg,#b481ff,transparent);
  box-shadow:0 0 16px #a872ff;
}
.metric:hover { border-color:#8063ab;transform:translateY(-2px); }
.metric:nth-child(2) {
  background:radial-gradient(circle at 100% 0%,#18cbdd24,transparent 58%),linear-gradient(155deg,#1a1b2d,#141725);
}
.metric:nth-child(2)::before { background:linear-gradient(90deg,var(--cyan),transparent);box-shadow:0 0 16px #70edf4; }
.metric:nth-child(3) {
  background:radial-gradient(circle at 100% 0%,#ec4f9e1b,transparent 58%),linear-gradient(155deg,#1a1b2d,#141725);
}
.metric:nth-child(3)::before { background:linear-gradient(90deg,var(--hotpink),transparent);box-shadow:0 0 16px #fa73bc; }
.metric-name { color:var(--muted);font-weight:580;font-size:12px; }
.metric-number {
  margin-top:20px;
  font-size:37px;
  font-weight:800;
  letter-spacing:-.065em;
  font-variant-numeric:tabular-nums;
}
.metric:nth-child(1) .metric-number { color:#d1b2ff; }
.metric:nth-child(2) .metric-number { color:#8ef2fa; }
.metric:nth-child(3) .metric-number { color:#ffb6db; }
.panel {
  position:relative;
  border:1px solid #3b3852;
  border-radius:15px;
  background:linear-gradient(150deg,#191a2a,#141724 85%);
  box-shadow:0 16px 55px #0004,inset 0 1px 0 #ffffff0b;
}
.panel::before {
  content:"";
  position:absolute;top:0;left:0;right:0;height:1px;
  background:linear-gradient(90deg,#b77effcc,#73e7f4a0,transparent 85%);
}
.panel-header { padding:24px 24px 22px; }
.panel-header h2 { font-size:16px;font-weight:770;letter-spacing:-.02em; }
.panel-header p { font-size:11px;color:var(--dim);margin-top:7px; }
.input,.select {
  min-height:41px;
  border:1px solid #45415e;
  border-radius:9px;
  background:#101323;
  color:var(--ink);
  transition:border-color .16s ease,box-shadow .16s ease;
}
.input::placeholder { color:#8793ae; }
.input:focus,.select:focus { border-color:#a979ff;box-shadow:0 0 0 3px #ac80ff24; }
.search .input { width:241px; }
.search svg { color:#8f92b0; }
.select { width:139px; }
th { background:#1b1d30;color:#a4a0be; }
td { border-top:1px solid #323148;color:#d1d0e4; }
tbody tr:hover td { background:#27243eac; }
.key-name { color:#f8f5ff;font-weight:760; }
.key-id { color:#9996b7; }
.badge { border:1px solid transparent;border-radius:7px;padding:6px 9px; }
.badge.active { color:#aaf4ce;background:#1e3a30;border-color:#315c4e; }
.badge.expiring,.badge.exhausted { color:#f9d8a3;background:#403123;border-color:#795b39; }
.badge.revoked,.badge.expired { color:#ffb3c3;background:#422635;border-color:#805165; }
.revoke { color:#ffb2c8;font-weight:750; }
.revoke:hover { color:#ffdae4;text-shadow:0 0 12px #ff75a9; }
.panel-foot { border-top:1px solid #36344d;color:var(--dim); }
.footer { color:#9397b5; }
.login-view { min-height:calc(100vh - 168px); }
.login-card {
  position:relative;
  overflow:hidden;
  width:min(100%,432px);
  padding:36px;
  border:1px solid #554671;
  border-radius:18px;
  background:radial-gradient(circle at 95% 0%,#843fc426,transparent 60%),linear-gradient(150deg,#1b1b30,#111522);
  box-shadow:0 26px 85px #0008,0 0 67px #9850ef29;
}
.login-card::before {
  content:"";
  position:absolute;top:0;left:0;right:0;height:2px;
  background:linear-gradient(90deg,#ac78ff,#71d5ff,#71edf4);
  box-shadow:0 0 21px #b38bff;
}
.login-icon {
  width:48px;height:48px;border-radius:13px;
  border:1px solid #9467c28c;
  background:#35234e;
  color:#cfb4ff;
  box-shadow:0 0 26px #a16afa5b;
}
.login-icon svg { width:20px;height:20px; }
.login-card h1 { font-size:30px; }
.login-card p { color:var(--muted);line-height:1.7; }
.field-label { color:#e1def1; }
.login-input input { min-height:48px; }
.reveal-toggle { color:var(--cyan); }
.login-card .primary { min-height:48px; }
.login-error { color:#ffb3c3; }
.login-note { border-top-color:#3c3654;color:var(--dim); }
.shade {
  background:#060611de;
  backdrop-filter:blur(13px);
  -webkit-backdrop-filter:blur(13px);
  animation:fade-neon .2s ease both;
}
.dialog {
  position:relative;
  border:1px solid #5d507c;
  border-radius:18px;
  background:linear-gradient(150deg,#1e1e34,#121523 85%);
  box-shadow:0 26px 85px #000c,0 0 48px #9456f52c;
  animation:slide-neon .22s ease both;
}
.dialog::before {
  content:"";
  position:absolute;top:0;left:0;right:0;height:2px;
  background:linear-gradient(90deg,#b47cff,var(--cyan));
  box-shadow:0 0 20px #b88bff;
}
.dialog-head h2 { font-size:21px;font-weight:780; }
.x-btn { border:1px solid #48425d;border-radius:9px;background:#27273e;color:#c3c1d7; }
.x-btn:hover { border-color:#9979d1;color:#fff; }
.dialog-sub { color:var(--muted); }
.form-field label { color:#e1ddec; }
.preset { border-color:#4a455f;border-radius:8px;background:#191b2d;color:#b8b9d1; }
.preset:hover { border-color:#aa8aee;color:#fff; }
.preset[aria-pressed=true] {
  border-color:#9d78eb;
  background:#362851;
  color:#eadcff;
  box-shadow:0 0 14px #9562e635;
}
.dialog-actions { border-top-color:#3a354f; }
.created { background:#262441;border-color:#7562ba;border-radius:10px; }
.created-title { color:#d6bfff; }
.toast {
  border:1px solid #8067bf;
  border-radius:11px;
  background:#26233f;
  color:#f2ebff;
  box-shadow:0 15px 42px #0008,0 0 25px #a46dff35;
  animation:slide-neon .2s ease both;
}
.toast.error { border-color:#93526e;background:#432539;color:#ffd2e1; }
@keyframes fade-neon { from { opacity:0; } to { opacity:1; } }
@keyframes slide-neon {
  from { opacity:0;transform:translateY(12px) scale(.985); }
  to { opacity:1;transform:translateY(0) scale(1); }
}
@media(max-width:800px) {
  .panel-header { flex-direction:column;align-items:stretch; }
  .tools { width:100%; }
  .search { flex:1; }
  .search .input { width:100%; }
}
@media(max-width:570px) {
  .wrap { width:min(100% - 30px,1100px); }
  .top,.top-inner { min-height:68px; }
  main { padding-top:33px; }
  .hero { align-items:start; }
  .hero h1 { font-size:35px; }
  .metric { min-height:106px;padding:16px 12px; }
  .metric-name { font-size:10px;line-height:1.4; }
  .metric-number { font-size:28px;margin-top:16px; }
  .metrics { gap:8px; }
  .panel-header { padding:19px; }
  .panel-foot,.footer { flex-direction:column;gap:8px; }
  .tools { flex-wrap:wrap; }
  .search { flex:1 1 100%; }
  .select { flex:1 1 auto;width:100%; }
  .login-card { padding:27px; }
  .dialog { padding:22px; }
  .top-right { gap:8px; }
}
@media(max-width:390px) {
  .metrics { grid-template-columns:1fr; }
  .metric { min-height:95px; }
  .metric-number { margin-top:10px; }
  .logo-text { font-size:12px; }
  .logo-small { font-size:9px; }
}
@media(prefers-reduced-motion:reduce) {
  *,*::before,*::after { animation-duration:.01ms!important;transition-duration:.01ms!important;scroll-behavior:auto!important; }
}
</style>
</head>
<body>
<header class="top"><div class="wrap top-inner">
  <div class="logo"><span class="logo-square" aria-hidden="true">V</span><div><div class="logo-text">VISION PRO</div><div class="logo-small">BETA ACCESS</div></div></div>
  <div class="top-right"><span id="connection" class="status"><i class="dot" aria-hidden="true"></i>Hors connexion</span><button id="logout" type="button" class="link-button" hidden>Déconnexion</button></div>
</div></header>
<main class="wrap">
  <section id="loginView" class="login-view" aria-label="Connexion administrateur">
    <form id="loginForm" class="login-card">
      <div class="login-icon"><svg viewBox="0 0 24 24" aria-hidden="true"><rect x="5" y="10" width="14" height="11" rx="2"/><path d="M8 10V7a4 4 0 0 1 8 0v3"/></svg></div>
      <div class="eyebrow">Espace privé</div><h1>Connexion</h1><p>Accède à la gestion des clés bêta avec ton jeton administrateur.</p>
      <label class="field-label" for="token">Jeton administrateur</label>
      <div class="login-input"><input id="token" class="input" type="password" autocomplete="off" spellcheck="false" placeholder="Colle ton jeton" required><button id="toggleToken" class="reveal-toggle" type="button">Afficher</button></div>
      <button id="loginButton" type="submit" class="primary">Accéder au tableau de bord <span aria-hidden="true">→</span></button>
      <div id="loginError" class="login-error" aria-live="polite" role="alert"></div>
      <div class="login-note">Le jeton reste dans la mémoire de cette page. Il n'est pas enregistré dans le navigateur.</div>
    </form>
  </section>
  <div id="dashboard" hidden>
    <section class="hero">
      <div><div class="eyebrow">Gestion bêta / V4</div><h1>Clés d'accès</h1><p>Crée et gère les clés de tes testeurs, au même endroit.</p></div>
      <button type="button" id="openCreate" class="primary"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>Nouvelle clé</button>
    </section>
    <section class="metrics" aria-label="Statistiques">
      <div class="metric"><div class="metric-name">Clés actives</div><div class="metric-number" id="statActive">—</div></div>
      <div class="metric"><div class="metric-name">Nombre de clés</div><div class="metric-number" id="statTotal">—</div></div>
      <div class="metric"><div class="metric-name">Activations utilisées</div><div class="metric-number" id="statUses">—</div></div>
    </section>
    <section class="panel" aria-label="Liste des clés">
      <div class="panel-header">
        <div><h2>Toutes les clés</h2><p>Statuts, dates et activations en temps réel.</p></div>
        <div class="tools">
          <label class="search"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6.5"/><path d="m16 16 5 5"/></svg><input id="search" class="input" type="search" placeholder="Rechercher une clé" aria-label="Rechercher une clé"></label>
          <select id="statusFilter" class="select" aria-label="État de la clé">
            <option value="all">Tous les états</option><option value="active">Actives</option><option value="expiring">Bientôt expirées</option><option value="exhausted">Épuisées</option><option value="expired">Expirées</option><option value="revoked">Révoquées</option>
          </select>
          <button id="refresh" type="button" class="secondary" aria-label="Actualiser les clés"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M20 11a8 8 0 1 0-2 6M20 4v7h-7"/></svg></button>
        </div>
      </div>
      <div class="list"><table><thead><tr><th>Nom / ID</th><th>État</th><th>Expiration</th><th>Activations</th><th>Action</th></tr></thead><tbody id="rows"><tr><td colspan="5" class="empty">Connecte-toi pour afficher les clés.</td></tr></tbody></table></div>
      <div class="panel-foot"><span id="count">0 clé</span><span>Seule la clé nouvellement créée peut être copiée.</span></div>
    </section>
    <footer class="footer"><span>VISION PRO / Access Console</span><span>Les clés sont conservées sous forme d'empreintes SHA-256.</span></footer>
  </div>
</main>
<div id="createShade" class="shade" hidden>
  <section class="dialog" role="dialog" aria-modal="true" aria-labelledby="dialogTitle">
    <div class="dialog-head"><h2 id="dialogTitle">Nouvelle clé bêta</h2><button id="closeCreate" type="button" class="x-btn" aria-label="Fermer"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 5l14 14M19 5 5 19"/></svg></button></div>
    <p class="dialog-sub">Choisis un nom, une durée et le nombre d'activations autorisées.</p>
    <form id="createForm">
      <div class="form-field"><label for="keyName">Nom de la clé</label><input id="keyName" class="input" maxlength="64" required value="Beta V4" placeholder="Ex. Testeurs privés"></div>
      <div class="form-field"><label for="days">Durée (jours)</label><input id="days" class="input" type="number" min="0" max="3650" step="1" required value="30">
        <div class="days-presets"><button type="button" class="preset" data-days="7" aria-pressed="false">7 j</button><button type="button" class="preset" data-days="30" aria-pressed="true">30 j</button><button type="button" class="preset" data-days="90" aria-pressed="false">90 j</button><button type="button" class="preset" data-days="0" aria-pressed="false">Illimité</button></div>
        <div class="hint">0 = sans date d'expiration.</div>
      </div>
      <div class="form-field"><label for="maxActivations">Activations maximum</label><input id="maxActivations" class="input" type="number" min="0" max="100000" step="1" required value="0"><div class="hint">0 = illimité. Chaque validation réussie consomme une activation.</div></div>
      <div class="dialog-actions"><button id="cancelCreate" type="button" class="secondary">Annuler</button><button id="generate" type="submit" class="primary">Générer la clé</button></div>
    </form>
    <div id="created" class="created" hidden><div class="created-title">Clé générée — copie-la maintenant</div><div class="created-key" id="generatedKey"></div><button id="copy" type="button" class="secondary">Copier la clé</button><div class="hint">Cette clé ne pourra pas être réaffichée après fermeture.</div></div>
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