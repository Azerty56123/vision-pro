-- Vision Ware V1 / Misc: essential protections only.
-- Opt-in local protections, not authoritative server-side guarantees.
return {
 id="misc",name="Misc",description="Protections essentielles",
 sections={
  {tab="Misc",column="left",title="Protection",
   subtitle="Protection locale de ton personnage",items={
    {type="toggle",id="antiFling",label="Anti-Fling",desc="Détecte les impulsions et rotations excessives"},
    {type="toggle",id="antiVoid",label="Anti-Void",desc="Revient au dernier sol stable vérifié"}
    }}
 }
}
