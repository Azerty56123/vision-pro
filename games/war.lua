-- Vision Hub V1 / generic war games profile. Exact mechanics need a game-specific plugin.
return {
 id="war",name="Guerre",description="Profil générique pour jeux de guerre",
 sections={
  {tab="Game",column="left",title="Battle Session",subtitle="Tableau de bord",items={
   {type="info",label="Experience",value="@game"},
   {type="info",label="Players",value="@players"},
   {type="info",label="FPS",value="@fps"},
   {type="info",label="Ping",value="@ping"}
  }},
  {tab="Game",column="right",title="Combat Display",subtitle="Outils locaux",items={
   {type="dropdown",id="fovPreset",label="Camera Preset",values={"Default · 70","Wide · 90","Focus · 60"}},
   {type="toggle",id="bright",label="Fullbright",desc="Éclairage"},
   {type="toggle",id="fps",label="FPS Overlay",desc="Performance"}
  }},
  {tab="Overview",column="right",title="Battle Tools",subtitle="Session",items={
   {type="button",id="copyCoords",label="Copy Coordinates"},
   {type="button",id="copyPlace",label="Copy Place ID"}
  }}
 }
}
