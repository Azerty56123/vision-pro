-- Vision Hub V1 / Arsenal (ROLVe): local performance and display tools.
return {
 id="arsenal",name="Arsenal",description="Profil FPS arcade",
 placeIds={286090429},
 sections={
  {tab="Game",column="left",title="FPS Dashboard",subtitle="Performance en match",items={
   {type="info",label="Experience",value="Arsenal"},
   {type="info",label="FPS",value="@fps"},
   {type="info",label="Ping",value="@ping"},
   {type="toggle",id="fps",label="FPS Overlay",desc="Afficher les FPS"}
  }},
  {tab="Game",column="right",title="Display Presets",subtitle="Réglages locaux",items={
   {type="dropdown",id="fovPreset",label="Camera Preset",values={"Default · 70","Wide · 90","Focus · 60"}},
   {type="toggle",id="ping",label="Ping Counter",desc="Voir la latence"},
   {type="toggle",id="bright",label="Fullbright",desc="Éclairage local"}
  }},
  {tab="Overview",column="right",title="Arsenal Quick Panel",subtitle="Raccourcis",items={
   {type="toggle",id="fps",label="Show FPS",desc="Performance"},
   {type="toggle",id="ping",label="Show Ping",desc="Réseau"}
  }}
 }
}
