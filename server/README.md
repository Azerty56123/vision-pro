# Vision Ware — Anti-Exploit serveur Roblox

Les modules de ce dossier sont **pour une expérience Roblox dont tu es propriétaire**.
Ils ne peuvent pas protéger un serveur tiers en exécutant le `loadstring` Vision Ware.

## Installation dans Roblox Studio

1. Créer / ouvrir **ServerScriptService**.
2. Placer **`AntiExploit.server.lua`** en tant que **Script** nommé `AntiExploit`.
3. Placer **`CombatGuard.lua`** en tant que **ModuleScript** nommé `CombatGuard`.
4. Tester plusieurs scénarios dans une copie du jeu : sprint, véhicules, plates-formes mobiles, dash, téléportation, respawn et armes.
5. Adapter les seuils à la physique et aux capacités de ton expérience. **L'enforcement automatique est désactivé par défaut** (`Enforcement=false`).
6. Activer une sanction seulement après vérification des journaux et des faux positifs.

## Anti-Fly, Anti-Speed, Anti-Teleport

`AntiExploit.server.lua` observe, côté serveur :

- **Anti-Fly** : déplacements aériens prolongés au-dessus du sol, avec une vitesse verticale proche de zéro ;
- **Anti-Speed** : déplacements horizontaux soutenus au-delà des seuils attendus ;
- **Anti-Teleport** : déplacements anormalement longs entre deux vérifications ;
- exemptions : respawn, nage, escalade, véhicules (assis), objets ancrés, état physique, et déplacements spéciaux autorisés.

Pour une téléportation légitime **faite côté serveur**, placer juste avant le déplacement :

```lua
player:SetAttribute("VisionGuardExemptUntil", os.clock() + 3)
character:PivotTo(destination)
```

Ne jamais permettre à un client de définir `VisionGuardExemptUntil`. Les mouvements autorisés depuis un client doivent être validés et exécutés sur le serveur.

Les paramètres tels que `SpeedLimit`, `FlyGrace` et `TeleportDistance` sont configurables. Les mesures ne prouvent pas à elles seules qu'un joueur triche.

## Anti-Aim / validation des armes (à intégrer à ton système de tirs)

Un serveur Roblox **ne peut pas lire directement la caméra des autres joueurs** pour savoir si un aimbot est actif. En revanche, il peut rejeter des tirs physiquement impossibles et enregistrer des indices.

`CombatGuard.ValidateShot(player, tool, direction, config)` effectue :

- vérification du joueur vivant et de l'arme réellement équipée ;
- vérification du vecteur de tir et de l'origine côté serveur (Muzzle / Handle / Head) ;
- limitation de la fréquence des tirs ;
- `workspace:Raycast` **côté serveur**, pour que le client ne puisse pas annoncer une cible derrière un mur ;
- enregistrement d'enchaînements de rotations de visée extrêmes **sans sanction automatique**.

Ce module doit être **appelé depuis le gestionnaire serveur de tes armes**. Il ne protège pas automatiquement les armes déjà présentes.

Exemple *à adapter à tes vrais noms d'arme, RemoteEvent et paramètres serveur* :

```lua
-- Script sous ServerScriptService ; exemple d'intégration pour une arme raycast.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatGuard = require(script.Parent.CombatGuard)
local FireWeapon = ReplicatedStorage:WaitForChild("FireWeapon")

local GUN = "MyGun"
local FIRE_CONFIG = {
 MaxRange = 350,
 MinShotInterval = 0.15,
 MaxOriginOffset = 14
}

FireWeapon.OnServerEvent:Connect(function(player, direction)
 local character = player.Character
 local tool = character and character:FindFirstChild(GUN)
 local valid, reason, raycastResult =
  CombatGuard.ValidateShot(player, tool, direction, FIRE_CONFIG)
 if not valid then return end

 if raycastResult then
  local hitModel = raycastResult.Instance:FindFirstAncestorOfClass("Model")
  local victim = hitModel and hitModel:FindFirstChildOfClass("Humanoid")
  if victim and victim.Health > 0 and hitModel ~= character then
   -- Ici appliquer TES règles serveur : équipe, bouclier, invulnérabilité, etc.
   victim:TakeDamage(15)
  end
 end
end)

Players.PlayerRemoving:Connect(CombatGuard.RemovePlayer)
```

La direction demandée vient du client, mais le serveur décide **si le tir est valide, quel obstacle est touché et si des dégâts doivent être appliqués**. Pour protéger complètement ton jeu, il faut aussi sécuriser les autres remotes (inventaire, monnaie, achats, combat, téléportations).

## L'onglet Misc du hub

`games/misc.lua` s'ouvre dans le hub Vision Ware pour chaque jeu :

| Fonction | Portée | Limites |
| --- | --- | --- |
| Anti-Fling | Client local | Amortit certaines impulsions, peut perturber des mécaniques légitimes |
| Anti-Void | Client local | Tentative de restauration vers le dernier sol stable |
| Anti-Fly Watch | Observateur client | Alertes heuristiques, faux positifs possibles |
| Anti-Speed Watch | Observateur client | Alertes heuristiques, faux positifs possibles |
| Anti-Fly / Speed / Teleport serveur | Jeu propriétaire | Installer le Script côté serveur |
| Anti-Aim / tirs | Jeu propriétaire | Intégrer CombatGuard à chaque arme |

Ces systèmes ne contournent pas les contrôles d'autres expériences et ne sont pas des protections infaillibles.
