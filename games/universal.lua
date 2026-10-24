-- Vision Hub V1: shared universal UI profile.
return {
 id="universal",name="Universal",description="Outils communs à toutes les expériences",
 sections={
  {tab="Overview",column="left",title="Runtime",subtitle="Informations de la session",items={
   {type="info",label="Experience",value="@game"},
   {type="info",label="Profile",value="@profile"},
   {type="info",label="Players",value="@players"},
   {type="info",label="Place ID",value="@place"},
   {type="info",label="FPS",value="@fps"},
   {type="info",label="Ping",value="@ping"}
  }},
  {tab="Overview",column="right",title="Quick Controls",subtitle="Fonctions utiles et vérifiables",items={
   {type="toggle",id="fps",label="FPS Counter",desc="Afficher les FPS"},
   {type="toggle",id="players",label="Player Count",desc="Afficher les joueurs"},
   {type="toggle",id="xyz",label="Coordinates",desc="Afficher XYZ"},
   {type="button",id="copyPlace",label="Copy Place ID"}
  }},
  {tab="Player",column="left",title="Movement",subtitle="Réglages locaux",items={
   {type="slider",id="speed",label="Walk Speed",min=8,max=100},
   {type="slider",id="jump",label="Jump Power",min=20,max=140},
   {type="button",id="resetMovement",label="Reset movement"}
  }},
  {tab="Player",column="right",title="Camera",subtitle="Champ de vision",items={
   {type="slider",id="fov",label="Camera FOV",min=50,max=110},
   {type="dropdown",id="fovPreset",label="FOV Preset",values={"Default · 70","Wide · 90","Focus · 60"}},
   {type="info",label="Health",value="@health"}
  }},
  {tab="Visuals",column="left",title="Visual Settings",subtitle="Effets locaux",items={
   {type="toggle",id="bright",label="Fullbright",desc="Éclairage plus clair"},
   {type="toggle",id="fps",label="FPS Overlay",desc="Performance"},
   {type="toggle",id="ping",label="Ping Overlay",desc="Latence"}
  }},
  {tab="Visuals",column="right",title="HUD",subtitle="Informations à l'écran",items={
   {type="toggle",id="players",label="Player Counter",desc="Joueurs du serveur"},
   {type="toggle",id="xyz",label="XYZ Overlay",desc="Position"},
   {type="button",id="copyCoords",label="Copy Coordinates"}
  }},
  {tab="Settings",column="left",title="Interface",subtitle="Préférences",items={
   {type="slider",id="zoom",label="UI Scale (%)",min=65,max=115},
   {type="toggle",id="animations",label="Smooth Animations",desc="Transitions"},
   {type="button",id="recenter",label="Center Window"}
  }},
  {tab="Settings",column="right",title="Window",subtitle="Aide et commandes",items={
   {type="info",label="Hide / Show",value="RightShift"},
   {type="button",id="minimize",label="Minimize Hub"},
   {type="button",id="close",label="Close Vision Hub"}
  }}
 }
}
