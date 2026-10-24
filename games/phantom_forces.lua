-- Vision Hub V1 / Phantom Forces: display only, no unsupported combat promises.
return {
 id="phantom_forces",name="Phantom Forces",description="Profil FPS tactique",
 placeIds={292439477},
 sections={
  {tab="Game",column="left",title="Performance",subtitle="Résumé de session",items={
   {type="info",label="Experience",value="Phantom Forces"},
   {type="info",label="FPS",value="@fps"},
   {type="info",label="Ping",value="@ping"},
   {type="toggle",id="fps",label="Show FPS",desc="Performance"}
  }},
  {tab="Game",column="right",title="View Setup",subtitle="Confort d'affichage",items={
   {type="slider",id="fov",label="Camera FOV",min=50,max=110},
   {type="toggle",id="ping",label="Show Ping",desc="Latence"},
   {type="toggle",id="bright",label="Fullbright",desc="Éclairage local"}
  }},
  {tab="Overview",column="right",title="Phantom Quick Tools",subtitle="Utilitaires",items={
   {type="button",id="copyPlace",label="Copy Place ID"},
   {type="toggle",id="fps",label="FPS Overlay",desc="Performances"}
  }}
 }
}
