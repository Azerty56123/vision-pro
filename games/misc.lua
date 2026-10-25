-- Vision Ware V1 / Misc: essential protections only.
-- Local protections and observational warnings, not server authority.
return {
 id="misc",name="Misc",description="Protections essentielles",
 sections={
  {tab="Misc",column="left",title="Protection",
   subtitle="Protection locale de ton personnage",items={
    {type="toggle",id="antiFling",label="Anti-Fling",desc="Réduit les projections et rotations brutales"},
    {type="toggle",id="antiVoid",label="Anti-Void",desc="Tente d'éviter une chute hors de la carte"}
    }}
 }
}
