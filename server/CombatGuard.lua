-- Vision Ware | Server Combat Guard (ModuleScript)
-- Install in ServerScriptService. Call ValidateShot from your OWN weapon server code.
-- Never let a client decide damage, victims, origin, range or shot cooldown.
-- This validates shots and flags suspicious aim patterns; it does NOT magically
-- detect every aimbot. High-level aim behavior cannot be proven from one shot.
local Guard={}
local state=setmetatable({},{__mode="k"})

local DEFAULTS={
 MaxRange=700, MinShotInterval=.09,
 MaxOriginOffset=14, -- reject weapons firing far outside the shooter
 MaxAimSnapDegrees=90, SnapWindow=.22, SuspiciousSnapCount=4
}
local function numberOk(x)
 return type(x)=="number" and x==x and x>-1e7 and x<1e7
end
local function validVector(v)
 return typeof(v)=="Vector3"
  and numberOk(v.X) and numberOk(v.Y) and numberOk(v.Z)
end
local function muzzlePosition(tool,character)
 local muzzle=tool:FindFirstChild("Muzzle",true)
 if muzzle and muzzle:IsA("Attachment") then return muzzle.WorldPosition end
 if muzzle and muzzle:IsA("BasePart") then return muzzle.Position end
 local handle=tool:FindFirstChild("Handle")
 if handle and handle:IsA("BasePart") then return handle.Position end
 local head=character:FindFirstChild("Head")
 return head and head.Position
end
function Guard.ValidateShot(player,tool,shotDirection,serverSettings)
 local cfg=serverSettings or DEFAULTS -- values MUST come from server code
 if typeof(player)~="Instance" or not player:IsA("Player") then
  return false,"Invalid shooter"
 end
 local character=player.Character
 local hum=character and character:FindFirstChildOfClass("Humanoid")
 local root=character and character:FindFirstChild("HumanoidRootPart")
 if not character or not hum or hum.Health<=0 or not root then
  return false,"No living shooter"
 end
 if typeof(tool)~="Instance" or not tool:IsA("Tool") or tool.Parent~=character then
  return false,"Weapon not equipped"
 end
 if not validVector(shotDirection) then return false,"Invalid aim vector" end
 local magnitude=shotDirection.Magnitude
 if magnitude<.95 or magnitude>1.05 then return false,"Aim vector must be normalized" end
 local direction=shotDirection.Unit
 local origin=muzzlePosition(tool,character)
 if not origin or (origin-root.Position).Magnitude>(cfg.MaxOriginOffset or DEFAULTS.MaxOriginOffset) then
  return false,"Invalid shot origin"
 end
 local now=os.clock()
 local record=state[player]
 if not record then record={lastFire=0,direction=nil,snapCount=0,lastReport=0};state[player]=record end
 local minShot=math.max(.03,cfg.MinShotInterval or DEFAULTS.MinShotInterval)
 if now-record.lastFire<minShot then return false,"Fire-rate limit" end
 -- The server determines hit location with raycasting. Client hit claims
 -- are discarded, so bullets cannot be reported through walls.
 local rayParams=RaycastParams.new()
 rayParams.FilterType=Enum.RaycastFilterType.Exclude
 rayParams.FilterDescendantsInstances={character}
 rayParams.IgnoreWater=true
 local maxRange=math.clamp(cfg.MaxRange or DEFAULTS.MaxRange,1,2000)
 local cast=workspace:Raycast(origin,direction*maxRange,rayParams)
 -- Only observational; legitimate flick-shots should never cause auto-kicks.
 if record.direction and now-record.lastFire<(cfg.SnapWindow or DEFAULTS.SnapWindow) then
  local dot=math.clamp(record.direction:Dot(direction),-1,1)
  local angle=math.deg(math.acos(dot))
  if angle>(cfg.MaxAimSnapDegrees or DEFAULTS.MaxAimSnapDegrees) then
   record.snapCount=record.snapCount+1
  else record.snapCount=math.max(0,record.snapCount-1) end
  if record.snapCount>=(cfg.SuspiciousSnapCount or DEFAULTS.SuspiciousSnapCount)
   and now-record.lastReport>20 then
   warn(("[VisionWare Combat] Suspicious rapid aim changes by %s (%d)")
    :format(player.Name,player.UserId))
   record.snapCount=0;record.lastReport=now
  end
 end
 record.direction=direction
 record.lastFire=now
 return true,nil,cast
end
function Guard.RemovePlayer(player)
 state[player]=nil
end
return Guard
