-- VISION WARE V1 | Obby upgrade
-- Client-side tools. Server-side validations can override movements.
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Collection=game:GetService("CollectionService")
local player=Players.LocalPlayer
local settings={
 fly=false,noclip=false,infiniteJump=false,autoReturn=false,
 autoSkip=false,finishESP=false,nextESP=false,lowGravity=false,
 flySpeed=30,skipDelay=5
}
local originalGravity=workspace.Gravity
local autoSkipGeneration=0
local espTime=0
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


-- Dynamic Obby discovery: no hardcoded place IDs, hidden remotes or false win claims.
local discovery={at=-1000,stages={},finish=nil}
local highlights={finish=nil,next=nil}
local function partFor(obj)
 if obj:IsA("BasePart") then return obj end
 if obj:IsA("Model") then
  if obj.PrimaryPart then return obj.PrimaryPart end
  for _,child in ipairs(obj:GetChildren()) do
   if child:IsA("SpawnLocation") then return child end
  end
  for _,child in ipairs(obj:GetChildren()) do
   if child:IsA("BasePart") then return child end
  end
  return obj:FindFirstChildWhichIsA("BasePart",true)
 end
 return nil
end
local function inCheckpointFolder(obj)
 local node=obj.Parent
 for _=1,3 do
  if not node or node==workspace then break end
  local lower=node.Name:lower()
  if lower=="stages" or lower=="checkpoints" or lower=="stage"
   or lower=="levels" or lower=="spawns" or lower=="stageparts" then
   return true
  end
  node=node.Parent
 end
 return false
end
local function stageNumber(obj)
 local num=tonumber(obj:GetAttribute("Stage"))
  or tonumber(obj:GetAttribute("Checkpoint"))
  or tonumber(obj:GetAttribute("Level"))
 if num and num>=0 and num<=100000 and num%1==0 then return num end
 local name=obj.Name:lower()
 local suffix=name:match("^stage[%s_%-%#]*(%d+)$")
  or name:match("^checkpoint[%s_%-%#]*(%d+)$")
  or name:match("^level[%s_%-%#]*(%d+)$")
  or name:match("^cp[%s_%-%#]*(%d+)$")
 if not suffix and inCheckpointFolder(obj) then
  suffix=name:match("^(%d+)$")
 end
 if suffix then return tonumber(suffix)end
 return nil
end
local function isFinish(obj)
 local name=obj.Name:lower():gsub("[%s_%-%d]","")
 return name=="finish" or name=="finishline" or name=="finishpart"
  or name=="win" or name=="winner" or name=="goal"
  or name=="end" or name=="endpart" or name=="victory"
  or name=="touchfinish"
end
local function scanObby(force)
 if not force and os.clock()-discovery.at<5 then return discovery end
 local indexed,finish,finishScore={},nil,-1
 local seen=0
 for _,obj in ipairs(workspace:GetDescendants()) do
  seen=seen+1
  if seen>120000 then break end
  if obj:IsA("BasePart") or obj:IsA("Model") then
   local ch=player.Character
   if not (ch and obj:IsDescendantOf(ch)) then
    local part=partFor(obj)
    if part and part:IsDescendantOf(workspace) then
     local stage=stageNumber(obj)
     if stage then
      local score=(obj:IsA("BasePart") and 3 or 1)
      if obj:IsA("SpawnLocation") then score=score+2 end
      if part.Name:lower():find("checkpoint",1,true) then score=score+1 end
      local prev=indexed[stage]
      if not prev or score>prev.score then
       indexed[stage]={number=stage,part=part,score=score}
      end
     end
     if isFinish(obj) then
      local score=(obj:IsA("BasePart") and 3 or 1)
       +(part.CanTouch and 1 or 0)
      if score>finishScore then finish=part;finishScore=score end
     end
    end
   end
  end
 end
 local stages={}
 for _,entry in pairs(indexed) do table.insert(stages,entry)end
 table.sort(stages,function(a,b)return a.number<b.number end)
 discovery={at=os.clock(),stages=stages,finish=finish}
 return discovery
end
local function progressValue()
 local stats=player:FindFirstChild("leaderstats")
 for _,source in ipairs({stats or player,player}) do
  for _,name in ipairs({"Stage","Stages","Checkpoint","CheckPoint","Level","CurrentStage","CurrentCheckpoint"}) do
   local obj=source:FindFirstChild(name)
   if obj and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
    local val=tonumber(obj.Value)
    if val and val>=0 then return math.floor(val)end
   end
  end
 end
 for _,key in ipairs({"Stage","Checkpoint","Level"}) do
  local val=tonumber(player:GetAttribute(key))
  if val and val>=0 then return math.floor(val)end
 end
 return nil
end
local function nearestStage(stages)
 local _,root=parts()
 if not root then return nil end
 local best,distance=nil,math.huge
 for idx,entry in ipairs(stages) do
  local magnitude=(entry.part.Position-root.Position).Magnitude
  if magnitude<distance then best=idx;distance=magnitude end
 end
 if distance>350 then return nil end
 return best
end
local function stageDestination(step)
 local data=scanObby(false)
 local list=data.stages
 if #list==0 then return nil,"No stage parts found"end
 local progress=progressValue()
 local index
 if progress then
  for i,entry in ipairs(list) do
   if entry.number<=progress then index=i end
  end
  if not index then index=0 end
 else
  index=nearestStage(list)
  if not index then return nil,"Cannot locate your current stage"end
 end
 local target=list[index+step]
 if not target then return nil,step>0 and "Last known stage reached" or "First known stage reached"end
 return target
end
local function telePart(part,landOnTop)
 if not part or not part:IsDescendantOf(workspace) then return false end
 local extra=landOnTop and 3.2 or 1.8
 local height=part.Size.Y*.5+extra
 return teleportTo(CFrame.new(part.Position+Vector3.new(0,height,0))-Vector3.new(0,2,0))
end
local function stepStage(step)
 local entry,why=stageDestination(step)
 if not entry then return why end
 if telePart(entry.part,true) then
  return "Teleport attempted: stage "..entry.number.." (server decides progression)"
 end
 return "Stage teleport unavailable"
end
local function gotoFinish()
 local data=scanObby(false)
 if not data.finish then return "No Finish / Goal part found"end
 return telePart(data.finish,true) and
  "Finish teleport attempted; win is not guaranteed" or "Finish teleport unavailable"
end
local function tryFinish()
 local data=scanObby(true)
 local part=data.finish
 if not part then return "No Finish / Goal part found"end
 task.spawn(function()
  for i=1,3 do
   if disposed or not part.Parent then break end
   -- Approach the finish pad and allow ordinary game touch detection.
   telePart(part,i==1)
   task.wait(.5)
  end
 end)
 return "Finish contact attempt started (server validates wins)"
end
local function clearHighlight(which)
 local h=highlights[which]
 if h then pcall(function()h:Destroy()end)end
 highlights[which]=nil
end
local function ensureHighlight(which,part,color)
 if not part then clearHighlight(which);return end
 local current=highlights[which]
 if current and current.Parent and current.Adornee==part then return end
 clearHighlight(which)
 local h=Instance.new("Highlight")
 h.Name="VisionWareObby_"..which
 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
 h.FillColor=color
 h.OutlineColor=color
 h.FillTransparency=.78
 h.OutlineTransparency=0
 h.Adornee=part
 h.Parent=part
 highlights[which]=h
end
local function refreshESP()
 local data=scanObby(false)
 if settings.finishESP then
  ensureHighlight("finish",data.finish,Color3.fromRGB(74,240,145))
 else
  clearHighlight("finish")
 end
 if settings.nextESP then
  local entry=stageDestination(1)
  ensureHighlight("next",entry and entry.part,Color3.fromRGB(40,206,245))
 else
  clearHighlight("next")
 end
end
listen(Run.Heartbeat,function(dt)
 if disposed or not (settings.nextESP or settings.finishESP) then return end
 espTime=espTime+dt
 if espTime>=3 then
  espTime=0
  refreshESP()
 end
end)
local function startAutoSkip()
 autoSkipGeneration=autoSkipGeneration+1
 local generation=autoSkipGeneration
 task.spawn(function()
  local lastStage,attempts=nil,0
  while not disposed and settings.autoSkip and autoSkipGeneration==generation do
   local progress=progressValue()
   if progress~=lastStage then lastStage=progress;attempts=0 end
   if not progress or attempts<3 then
    local entry=stageDestination(1)
    if entry then
     telePart(entry.part,true)
     attempts=attempts+1
    end
   end
   task.wait(settings.skipDelay)
  end
 end)
end

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
actions.obbyScan=function()
 local data=scanObby(true)
 refreshESP()
 return "Detected "..#data.stages.." stage(s); Finish: "..(data.finish and "yes" or "no")
end
actions.obbySkipStage=function()return stepStage(1)end
actions.obbyPreviousStage=function()return stepStage(-1)end
actions.obbyTeleportFinish=gotoFinish
actions.obbyAutoWin=tryFinish
actions.obbyTeleportStart=function()
 local data=scanObby(false)
 local entry=data.stages[1]
 if not entry then return "No starting stage found"end
 return telePart(entry.part,true) and "Start teleport attempted" or "Start teleport unavailable"
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
 elseif id=="obbyAutoSkip" then
  settings.autoSkip=enabled
  if enabled then startAutoSkip()
  else autoSkipGeneration=autoSkipGeneration+1 end
 elseif id=="obbyFinishESP" then
  settings.finishESP=enabled
  refreshESP()
 elseif id=="obbyNextESP" then
  settings.nextESP=enabled
  refreshESP()
 elseif id=="obbyLowGravity" then
  settings.lowGravity=enabled
  workspace.Gravity=enabled and 65 or originalGravity
 end
end
local function onSlider(id,value)
 if id=="obbyFlySpeed" then
  settings.flySpeed=math.clamp(tonumber(value) or 30,30,160)
 elseif id=="obbySkipDelay" then
  settings.skipDelay=math.clamp(tonumber(value) or 5,3,15)
 end
end
local function shutdown()
 if disposed then return end
 disposed=true
 settings.fly=false
 settings.noclip=false
 settings.autoSkip=false
 autoSkipGeneration=autoSkipGeneration+1
 if settings.lowGravity then workspace.Gravity=originalGravity end
 clearHighlight("next")
 clearHighlight("finish")
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
   {type="toggle",id="obbyNoclip",label="Noclip",desc="Disable local collisions"},
   {type="toggle",id="obbyInfiniteJump",label="Infinite Jump",desc="Jump again while airborne"},
   {type="toggle",id="obbyLowGravity",label="Low Gravity",desc="Lighter client-side gravity"}
  }},
  {tab="Game",column="right",title="Stage Tools",subtitle="Automatic stage discovery",items={
   {type="button",id="obbyScan",label="Scan Stages / Finish"},
   {type="button",id="obbySkipStage",label="Skip Stage (attempt)"},
   {type="button",id="obbyPreviousStage",label="Previous Stage"},
   {type="button",id="obbyTeleportStart",label="Teleport to Start"},
   {type="button",id="obbyTeleportFinish",label="Teleport to Finish"},
   {type="button",id="obbyAutoWin",label="Auto Win (attempt)"}
  }},
  {tab="Game",column="left",title="Automation",subtitle="Progression attempts; server may reject",items={
   {type="toggle",id="obbyAutoSkip",label="Auto Skip",desc="Try next detected checkpoint at a set interval"},
   {type="slider",id="obbySkipDelay",label="Auto Skip Delay (s)",min=3,max=15},
   {type="toggle",id="obbyAutoReturn",label="Auto Return",desc="Try last saved position after respawn"}
  }},
  {tab="Game",column="right",title="Visual Helpers",subtitle="Highlight important Obby parts",items={
   {type="toggle",id="obbyNextESP",label="Next Stage ESP",desc="Highlight next detected checkpoint"},
   {type="toggle",id="obbyFinishESP",label="Finish ESP",desc="Highlight detected Finish / Goal"}
  }},
  {tab="Game",column="left",title="Checkpoints",subtitle="Saved locally, not official",items={
   {type="button",id="savePos1",label="Save Position 1"},
   {type="button",id="gotoPos1",label="Return to Position 1"},
   {type="button",id="savePos2",label="Save Position 2"},
   {type="button",id="gotoPos2",label="Return to Position 2"}
  }},
  {tab="Game",column="right",title="Fly Settings",subtitle="Adjust flying speed",items={
   {type="slider",id="obbyFlySpeed",label="Fly Speed",min=30,max=160},
   {type="info",label="Walk / Jump",value="Player > Movement"},
   {type="info",label="Anti-Void",value="Misc > Anti-Void"},
   {type="info",label="Stage and win checks",value="Controlled by game servers"}
  }},
  {tab="Overview",column="right",title="Obby Quick Actions",subtitle="Shortcuts",items={
   {type="button",id="savePos1",label="Save Checkpoint"},
   {type="button",id="gotoPos1",label="Return to Checkpoint"},
   {type="button",id="obbySkipStage",label="Try Skip Stage"},
   {type="button",id="obbyTeleportFinish",label="Try Finish TP"}
  }}
 }
}
