-- Vision Hub V1 / Tycoon: generic profile, not a game-specific auto-farm.
return {
 id="tycoon",name="Tycoon",description="Profil pour les jeux de gestion et construction",
 sections={
  {tab="Game",column="left",title="Tycoon Overview",subtitle="Compagnon de gestion",items={
   {type="info",label="Experience",value="@game"},
   {type="info",label="Module",value="Generic Tycoon"},
   {type="info",label="Auto Farm",value="Not configured"},
   {type="button",id="copyPlace",label="Copy Place ID"}
  }},
  {tab="Game",column="right",title="Tool Actions",subtitle="Outils Roblox disponibles",items={
   {type="button",id="equipTool",label="Equip First Tool"},
   {type="button",id="useTool",label="Activate Equipped Tool"},
   {type="info",label="Automation",value="Requires game module"}
  }},
  {tab="Overview",column="right",title="Tycoon Toolkit",subtitle="Actions rapides",items={
   {type="button",id="equipTool",label="Equip Tool"},
   {type="button",id="copyCoords",label="Copy Plot Position"}
  }}
 }
}
