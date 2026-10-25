-- Vision Ware V1 / Misc, loaded for every supported experience.
-- Honest scope: protection of the local player and observational alerts only.
-- Real anti-fly / shot validation runs on an owner's Roblox game server.
return {
 id="misc",name="Misc",description="Protection locale et alertes",
 sections={
  {tab="Misc",column="left",title="Personal Protection",
   subtitle="Défenses locales (aucun bannissement possible)",items={
    {type="toggle",id="antiFling",label="Anti-Fling",desc="Amortit les vitesses et rotations anormales"},
    {type="toggle",id="antiVoid",label="Anti-Void",desc="Tente de revenir au dernier sol stable"},
    {type="info",label="Anti-Fling Triggers",value="@flingBlocks"},
    {type="info",label="Void Recoveries",value="@voidRescues"},
    {type="info",label="Protection Scope",value="@protectionMode"}
  }},
  {tab="Misc",column="right",title="Suspicious Activity",
   subtitle="Indices, pas des preuves d'exploitation",items={
    {type="toggle",id="flightAlerts",label="Anti-Fly Watch",desc="Signale les vols suspects des autres joueurs"},
    {type="toggle",id="speedAlerts",label="Anti-Speed Watch",desc="Signale les vitesses anormalement élevées"},
    {type="info",label="Fly Alerts",value="@flyAlerts"},
    {type="info",label="Speed Alerts",value="@speedAlerts"},
    {type="button",id="copyMiscReport",label="Copy Security Report"},
    {type="button",id="resetMiscAlerts",label="Reset Alerts"}
  }},
  {tab="Misc",column="left",title="Server Anti-Exploit",
   subtitle="À installer dans un jeu Roblox dont tu es le créateur",items={
    {type="info",label="Anti-Fly",value="server/AntiExploit.server.lua"},
    {type="info",label="Anti-Speed / Teleport",value="Contrôle côté serveur"},
    {type="info",label="Aim / Shoot Verification",value="server/CombatGuard.lua"},
    {type="button",id="copyServerGuide",label="Copy Server Setup Link"}
  }},
  {tab="Misc",column="right",title="Security Limitations",
   subtitle="Transparence sur les fonctions disponibles",items={
    {type="info",label="Anti-Aim",value="Validation des tirs côté serveur"},
    {type="info",label="Other Players",value="Aucune sanction depuis ce hub"},
    {type="info",label="Accuracy",value="Faux positifs possibles"},
    {type="info",label="Server Installation",value="Requise pour une vraie protection"}
  }}
 }
}
