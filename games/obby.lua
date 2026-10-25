-- VISION WARE V1 | Obby upgrade
-- Client-side tools. Server-side validations can override movements.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local player=Players.LocalPlayer
local settings={fly=false,noclip=false,infiniteJump=false,autoReturn=false,flySpeed=30}
local saved,latest={},nil
local collisions=setmetatable({}, {__mode="k"})
local connections={}
local flight={velocity=nil,gyro=nil,humanoid=nil,oldStand=false,oldRotate=true}
local disposed=false

local function listen(signal,fn)
 local connection=signal:Connect(fn)
 table.insert(connections,connection)
 return connection
end
local function parts()
 local ch=player and player.Character
 if not ch then return nil end
 return ch,ch:FindFirstChild("HumanoidRootPart"),ch:FindFirstChildOfClass("Humanoid")
end
local function restoreCollisions()
 for part,original in pairs(collisions) do
  if part and part.Parent then pcall(function()part.CanCollide=original end)end
  collisions[part]=nil
 end
end
local function stopFly()
 if flight.velocity then flight.velocity:Destroy()end
 if flight.gyro then flight.gyro:Destroy()end
 if flight.humanoid and flight.humanoid.Parent then
  pcall(function()
   flight.humanoid.PlatformStand=flight.oldStand
   flight.humanoid.AutoRotate=flight.oldRotate
  end)
 end
 flight.velocity=nil;flight.gyro=nil;flight.humanoid=nil
end
local function startFly()
 stopFly()
 local ch,root,hum=parts()
 if not root or not hum or hum.Health<=0 then return false end
 flight.humanoid=hum
 flight.oldStand=hum.PlatformStand
 flight.oldRotate=hum.AutoRotate
 hum.PlatformStand=true
 hum.AutoRotate=false
 local velocity=Instance.new("BodyVelocity")
 velocity.Name="VisionWareObbyFlyVelocity"
 velocity.MaxForce=Vector3.new(1e8,1e8,1e8)
 velocity.P=18000
 velocity.Velocity=Vector3.zero
 velocity.Parent=root
 flight.velocity=velocity
 local gyro=Instance.new("BodyGyro")
 gyro.Name="VisionWareObbyFlyGyro"
 gyro.MaxTorque=Vector3.new(1e8,1e8,1e8)
 gyro.P=12000
 gyro.D=650
 gyro.CFrame=root.CFrame
 gyro.Parent=root
 flight.gyro=gyro
 return true
end
local function teleportTo(target)
 local ch,root,hum=parts()
 if not ch or not root or not hum or hum.Health<=0 then return false end
 return pcall(function()
  ch:PivotTo(target+Vector3.new(0,2,0))
  root.AssemblyLinearVelocity=Vector3.zero
  root.AssemblyAngularVelocity=Vector3.zero
 end)
end
local function key(code)
 return UIS:IsKeyDown(code)
end
local function flyDirection(hum,cam)
 local forward=cam and cam.CFrame.LookVector or Vector3.new(0,0,-1)
 forward=Vector3.new(forward.X,0,forward.Z)
 if forward.Magnitude<.01 then forward=Vector3.new(0,0,-1)end
 forward=forward.Unit
 local right=Vector3.new(-forward.Z,0,forward.X)
 local dir=Vector3.zero
 if key(Enum.KeyCode.W) or key(Enum.KeyCode.Up) then dir=dir+forward end
 if key(Enum.KeyCode.S) or key(Enum.KeyCode.Down) then dir=dir-forward end
 if key(Enum.KeyCode.D) or key(Enum.KeyCode.Right) then dir=dir+right end
 if key(Enum.KeyCode.A) or key(Enum.KeyCode.Left) then dir=dir-right end
 if dir.Magnitude<.01 then
  local move=hum.MoveDirection
  dir=Vector3.new(move.X,0,move.Z)
 end
 if key(Enum.KeyCode.Space) or key(Enum.KeyCode.E) then dir=dir+Vector3.yAxis end
 if key(Enum.KeyCode.Q) or key(Enum.KeyCode.LeftControl) or key(Enum.KeyCode.RightControl) then
  dir=dir-Vector3.yAxis
 end
 return dir.Magnitude>1 and dir.Unit or dir
end

listen(UIS.JumpRequest,function()
 if disposed or not settings.infiniteJump then return end
 local _,_,hum=parts()
 if hum and hum.Health>0 then
  hum:ChangeState(Enum.HumanoidStateType.Jumping)
  hum.Jump=true
 end
end)
listen(Run.Stepped,function()
 if disposed or not settings.noclip then return end
 local ch=player.Character
 if not ch then return end
 for _,part in ipairs(ch:GetDescendants()) do
  if part:IsA("BasePart") then
   if collisions[part]==nil then collisions[part]=part.CanCollide end
   part.CanCollide=false
  end
 end
end)
listen(Run.Heartbeat,function()
 if disposed or not settings.fly then return end
 local _,root,hum=parts()
 if not root or not hum or hum.Health<=0 then
  stopFly();return
 end
 if not flight.velocity or flight.velocity.Parent~=root or not flight.gyro then
  if not startFly() then return end
 end
 local cam=workspace.CurrentCamera
 flight.velocity.Velocity=flyDirection(hum,cam)*settings.flySpeed
 if cam then
  local look=cam.CFrame.LookVector
  if look.Magnitude>.01 then
   flight.gyro.CFrame=CFrame.lookAt(root.Position,root.Position+look)
  end
 end
end)
listen(player.CharacterAdded,function(ch)
 stopFly()
 restoreCollisions()
 if not settings.autoReturn or not latest then return end
 local target=saved[latest]
 if not target then return end
 task.spawn(function()
  local root=ch:WaitForChild("HumanoidRootPart",10)
  local hum=ch:WaitForChild("Humanoid",10)
  if not root or not hum then return end
  task.wait(.5)
  if disposed or not settings.autoReturn or player.Character~=ch then return end
  teleportTo(target)
 end)
end)

local actions={}
for i=1,2 do
 actions["savePos"..i]=function()
  local _,root,hum=parts()
  if not root or not hum or hum.Health<=0 then return "Character unavailable"end
  saved[i]=root.CFrame
  latest=i
  return "Local checkpoint "..i.." saved"
 end
 actions["gotoPos"..i]=function()
  if not saved[i] then return "Save checkpoint "..i.." first"end
  return teleportTo(saved[i]) and "Return attempted: checkpoint "..i or "Teleport unavailable"
 end
end
local function onAction(id)
 local handler=actions[id]
 if not handler then return false end
 return true,handler()
end
local function onToggle(id,enabled)
 if id=="obbyFly" then
  settings.fly=enabled
  if enabled then startFly()else stopFly()end
 elseif id=="obbyNoclip" then
  settings.noclip=enabled
  if not enabled then restoreCollisions()end
 elseif id=="obbyInfiniteJump" then
  settings.infiniteJump=enabled
 elseif id=="obbyAutoReturn" then
  settings.autoReturn=enabled
 end
end
local function onSlider(id,value)
 if id=="obbyFlySpeed" then
  settings.flySpeed=math.clamp(tonumber(value) or 30,30,160)
 end
end
local function shutdown()
 if disposed then return end
 disposed=true
 settings.fly=false
 settings.noclip=false
 stopFly()
 restoreCollisions()
 for _,connection in ipairs(connections) do
  pcall(function()connection:Disconnect()end)
 end
 table.clear(connections)
end
return {
 id="obby",name="Obby",
 description="Parkour, movement and local checkpoints",
 onAction=onAction,onToggle=onToggle,onSlider=onSlider,shutdown=shutdown,
 sections={
  {tab="Game",column="left",title="Obby Cheats",subtitle="Movement helpers",items={
   {type="toggle",id="obbyFly",label="Fly",desc="WASD / Space or E up / Q or Ctrl down"},
   {type="toggle",id="obbyNoclip",label="Noclip",desc="Disable some local collisions"},
   {type="toggle",id="obbyInfiniteJump",label="Infinite Jump",desc="Jump again while airborne"}
  }},
  {tab="Game",column="right",title="Fly Settings",subtitle="Adjust flying movement",items={
   {type="slider",id="obbyFlySpeed",label="Fly Speed",min=30,max=160},
   {type="info",label="Walk Speed",value="Player > Movement"},
   {type="info",label="Jump Power",value="Player > Movement"}
  }},
  {tab="Game",column="left",title="Checkpoints",subtitle="Local bookmarks (not official stages)",items={
   {type="button",id="savePos1",label="Save Position 1"},
   {type="button",id="gotoPos1",label="Return to Position 1"},
   {type="button",id="savePos2",label="Save Position 2"},
   {type="button",id="gotoPos2",label="Return to Position 2"}
  }},
  {tab="Game",column="right",title="Recovery",subtitle="Resume after death",items={
   {type="toggle",id="obbyAutoReturn",label="Auto Return",desc="Try to return to latest saved position after respawn"},
   {type="info",label="Anti-Void",value="Misc > Anti-Void"},
   {type="info",label="Server validation",value="Some movements may be blocked"}
  }},
  {tab="Overview",column="right",title="Obby Quick Actions",subtitle="Checkpoint shortcuts",items={
   {type="button",id="savePos1",label="Save Checkpoint"},
   {type="button",id="gotoPos1",label="Return to Checkpoint"}
  }}
 }
}
