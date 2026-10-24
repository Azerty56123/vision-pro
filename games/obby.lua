-- Vision Hub V1 / Obby. Checkpoints are local user bookmarks, not official stages.
return {
 id="obby",name="Obby",description="Profil parcours et checkpoints",
 sections={
  {tab="Game",column="left",title="Checkpoints",subtitle="Positions enregistrées manuellement",items={
   {type="button",id="savePos1",label="Save Position 1"},
   {type="button",id="gotoPos1",label="Return to Position 1"},
   {type="button",id="savePos2",label="Save Position 2"},
   {type="button",id="gotoPos2",label="Return to Position 2"}
  }},
  {tab="Game",column="right",title="Parkour Camera",subtitle="Préférences de parcours",items={
   {type="slider",id="fov",label="Camera FOV",min=50,max=110},
   {type="toggle",id="xyz",label="Show Coordinates",desc="Voir la position"},
   {type="info",label="Checkpoint Mode",value="Local only"}
  }},
  {tab="Overview",column="right",title="Obby Actions",subtitle="Enregistrement manuel",items={
   {type="button",id="savePos1",label="Save Checkpoint"},
   {type="button",id="gotoPos1",label="Return to Checkpoint"}
  }}
 }
}
