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
 flySpeed=30,skipDelay=0
}
local originalGravity=workspace.Gravity
local autoSkipGeneration=0
local espTime=0
local saved,latest={},nil
local collisions=setmetatable({}, {__mode="k"})
local connections={}
local flight={velocity=nil,gyro=nil,humanoid=nil,oldStand=false,oldRotate=true}
local disposed=false
local checkpointLanding=false

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
-- Checkpoint discovery and confirmation
-- Roblox Touched requires physical movement, not merely CFrame overlap.
local discovery={at=-1000,stages={},finish=nil}
local highlights={finish=nil,next=nil}
local checkpointBusy=false
local checkpointStatus="Scan requis"
local function status(text)
 checkpointStatus=tostring(text)
end
local function tagged(obj,tag)
 local ok,result=pcall(Collection.HasTag,Collection,obj,tag)
 return ok and result
end
local function isCheckpointContainer(obj)
 local node=obj.Parent
 for _=1,5 do
  if not node or node==workspace then break end
  local name=node.Name:lower()
  if name=="checkpoints" or name=="checkpoint" or name=="stages"
   or name=="spawns" or name=="levels" or name=="stageparts"
   or name=="stagepoints" then return true end
  node=node.Parent
 end
 return false
end
local function stageNumber(obj)
 for _,key in ipairs({"Stage","Checkpoint","CheckpointId","StageId","Level"}) do
  local n=tonumber(obj:GetAttribute(key))
  if n and n>=0 and n<=100000 and n%1==0 then return n end
 end
 local name=obj.Name:lower()
 local n=name:match("^stage[%s_%-%#]*(%d+)$")
  or name:match("^checkpoint[%s_%-%#]*(%d+)$")
  or name:match("^check[%s_%-%#]*(%d+)$")
  or name:match("^level[%s_%-%#]*(%d+)$")
  or name:match("^cp[%s_%-%#]*(%d+)$")
 if not n and (isCheckpointContainer(obj) or tagged(obj,"Checkpoint")) then
  n=name:match("^(%d+)$")
 end
 return n and tonumber(n) or nil
end
local function isFinish(obj)
 if tagged(obj,"Finish") or tagged(obj,"Goal") then return true end
 local name=obj.Name:lower():gsub("[%s_%-%d]","")
 return name=="finish" or name=="finishline" or name=="finishpart"
  or name=="win" or name=="winner" or name=="goal"
  or name=="end" or name=="endpart" or name=="victory"
  or name=="touchfinish"
end
local function partFor(obj)
 if obj:IsA("BasePart") then return obj end
 if not obj:IsA("Model") then return nil end
 local preferred,bestScore=nil,-math.huge
 for _,part in ipairs(obj:GetDescendants()) do
  if part:IsA("BasePart") then
   local name=part.Name:lower()
   local score=(part.CanTouch and 5 or -10)
   if part:IsA("SpawnLocation") then score=score+12 end
   if name:find("checkpoint",1,true) or name:find("spawn",1,true)
     or name:find("touch",1,true) or name:find("trigger",1,true)
     or name:find("pad",1,true) then score=score+8 end
   if part==obj.PrimaryPart then score=score+3 end
   if part.Size.X>=2 and part.Size.Z>=2 then score=score+2 end
   if score>bestScore then preferred=part;bestScore=score end
  end
 end
 return preferred
end
local function scanObby(force)
 if not force and os.clock()-discovery.at<5 then return discovery end
 local indexed,finish,finishScore={},nil,-math.huge
 local ch=player.Character
 local seen=0
 for _,obj in ipairs(workspace:GetDescendants()) do
  seen=seen+1
  if seen>120000 then break end
  if (obj:IsA("BasePart") or obj:IsA("Model"))
   and not (ch and obj:IsDescendantOf(ch)) then
   local stage=stageNumber(obj)
   local finishMatch=isFinish(obj)
   if stage or finishMatch then
    local part=partFor(obj)
    if part and part:IsDescendantOf(workspace) then
     if stage then
      local score=(part.CanTouch and 6 or -15)
      if part:IsA("SpawnLocation") then score=score+12 end
      if isCheckpointContainer(obj) then score=score+8 end
      if tagged(obj,"Checkpoint") or tagged(part,"Checkpoint") then score=score+10 end
      if obj.Name:lower():find("checkpoint",1,true) then score=score+5 end
      if obj:IsA("BasePart") then score=score+2 end
      if not indexed[stage] or score>indexed[stage].score then
       indexed[stage]={number=stage,part=part,score=score}
      end
     end
     if finishMatch then
      local score=(part.CanTouch and 8 or 0)+(obj:IsA("BasePart") and 2 or 0)
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
local progressNames={
 stage=true,stages=true,checkpoint=true,checkpoints=true,
 level=true,currentstage=true,currentcheckpoint=true,
 stagenumber=true,checkpointnumber=true
}
local function progressValue()
 local folders={player}
 for _,folderName in ipairs({"leaderstats","Data","Stats","Progress","Values"}) do
  local folder=player:FindFirstChild(folderName)
  if folder then table.insert(folders,folder)end
 end
 -- Check leaderstats first because it commonly holds replicated stage progress.
 local leader=player:FindFirstChild("leaderstats")
 if leader then
  table.remove(folders,table.find(folders,leader))
  table.insert(folders,1,leader)
 end
 for _,folder in ipairs(folders) do
  for _,obj in ipairs(folder:GetChildren()) do
   local key=obj.Name:lower():gsub("[_%s%-]","")
   if progressNames[key] and (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
    local value=tonumber(obj.Value)
    if value and value>=0 then return math.floor(value),obj:GetFullName()end
   end
  end
 end
 for _,key in ipairs({"Stage","Checkpoint","Level","CurrentStage","CurrentCheckpoint"}) do
  local value=tonumber(player:GetAttribute(key))
  if value and value>=0 then return math.floor(value),"Player attribute"end
 end
 return nil,nil
end
local function nearestStage(stages)
 local _,root=parts()
 if not root then return nil end
 local best,distance=nil,math.huge
 for idx,entry in ipairs(stages) do
  local distanceNow=(entry.part.Position-root.Position).Magnitude
  if distanceNow<distance then best=idx;distance=distanceNow end
 end
 return distance<=350 and best or nil
end
local function stageDestination(step)
 local data=scanObby(false)
 local list=data.stages
 if #list==0 then return nil,"Aucun checkpoint reconnu"end
 local progress=progressValue()
 if progress~=nil and step>0 then
  local wanted=progress+1
  for _,entry in ipairs(list) do
   if entry.number==wanted then return entry end
  end
  -- Never silently leap over intermediate checkpoints.
  if list[#list].number<=progress then return nil,"Dernier stage detecte atteint"end
  return nil,"Checkpoint "..wanted.." introuvable (Scan Stages)"
 end
 local index
 if progress~=nil then
  for i,entry in ipairs(list) do
   if entry.number<=progress then index=i end
  end
  if not index then index=1 end
 else
  index=nearestStage(list)
  if not index then return nil,"Stage actuel introuvable"end
 end
 local target=list[index+step]
 if not target then return nil,"Checkpoint hors de la liste"end
 return target
end
local function telePart(part,above)
 if not part or not part:IsDescendantOf(workspace) then return false end
 local extra=above and 3.2 or 1.8
 local height=part.Size.Y*.5+extra
 return teleportTo(CFrame.new(part.Position+Vector3.new(0,height,0))-Vector3.new(0,2,0))
end
local function landOnCheckpoint(entry)
 local part=entry and entry.part
 if not part or not part.Parent then return false,"Checkpoint disparu"end
 if not part.CanTouch then return false,"Checkpoint non touchable"end
 local ch,root,hum=parts()
 if not ch or not root or not hum or hum.Health<=0 then
  return false,"Personnage indisponible"
 end
 local clearance=math.max(2.5,hum.HipHeight+root.Size.Y*.5)
 local y=part.Position.Y+part.Size.Y*.5+clearance+3
 local offset=Vector3.new(0,y,0)
 local target=CFrame.new(part.Position.X,y,part.Position.Z)
 local ok=pcall(function()
  ch:PivotTo(target)
  hum.Sit=false
  hum:ChangeState(Enum.HumanoidStateType.Freefall)
  root.AssemblyAngularVelocity=Vector3.zero
  root.AssemblyLinearVelocity=Vector3.new(0,-17,0)
 end)
 return ok,ok and "Contact en cours" or "Teleport impossible"
end
-- Make an actual physical landing and wait for replicated Stage to change.
local function activateCheckpoint(entry, options)
 options=options or {}
 if checkpointBusy then return false,"Checkpoint deja en cours"end
 if not entry or not entry.part then return false,"Checkpoint introuvable"end
 checkpointBusy=true
 checkpointLanding=true
 stopFly()
 restoreCollisions()
 local initial=progressValue()
 local confirmed=false
 local result="Checkpoint "..entry.number.." non confirme"
 status("Activation checkpoint "..entry.number.."...")
 for attempt=1,(options.attempts or 2) do
  if disposed then result="Module ferme";break end
  if attempt>1 then scanObby(true)end
  local current=progressValue()
  if current and current>=entry.number and initial and current>initial then
   confirmed=true;break
  end
  local ok,reason=landOnCheckpoint(entry)
  if not ok then result=reason;break end
  -- At 0 seconds, still yield for physics and Stage replication.
  local deadline=os.clock()+(options.timeout or 1.4)
  repeat
   task.wait()
   if disposed then break end
   local now=progressValue()
   if initial~=nil and now~=nil and now>initial and now>=entry.number then
    confirmed=true;break
   end
  until os.clock()>=deadline
  if confirmed then break end
  if initial==nil then
   result="Contact tente, mais aucun compteur Stage verifiable"
   break
  end
 end
 if confirmed then
  result="Checkpoint "..entry.number.." VALIDE (Stage confirme)"
 else
  result=result=="Module ferme" and result or
   (initial~=nil and "Checkpoint "..entry.number.." non valide par le jeu" or result)
 end
 checkpointLanding=false
 if not disposed and settings.fly then startFly()end
 checkpointBusy=false
 status(result)
 return confirmed,result
end
local function stepStage(step)
 local entry,why=stageDestination(step)
 if not entry then return why end
 if step<0 then
  return telePart(entry.part,true) and
   "Retour vers stage "..entry.number.." (non officiel)" or "Teleport impossible"
 end
 if checkpointBusy then return "Activation deja en cours"end
 task.spawn(function()activateCheckpoint(entry)end)
 return "Checkpoint "..entry.number.." : tentative, voir Statut"
end
local function gotoFinish()
 local data=scanObby(false)
 if not data.finish then return "Aucune zone Finish detectee"end
 return telePart(data.finish,true) and
  "Arrivee atteinte localement; victoire non garantie" or "Finish inaccessible"
end
local function tryFinish()
 local data=scanObby(true)
 if not data.finish then return "Aucune zone Finish detectee"end
 local part=data.finish
 task.spawn(function()
  if checkpointBusy then status("Activation deja en cours");return end
  for _=1,3 do
   if disposed or not part.Parent then break end
   -- Ordinary physics needs actual movement to fire Touched.
   telePart(part,true)
   task.wait(.8)
  end
  status("Contact Finish tente - victoire a verifier en jeu")
 end)
 return "Tentative Finish en cours (sans garantie)"
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
-- No artificial pause between stages at 0s.
-- Turbo: try the last checkpoint once, then validate each required stage.
local function startAutoSkip(autoWin)
 autoSkipGeneration=autoSkipGeneration+1
 local generation=autoSkipGeneration
 task.spawn(function()
  local initial=progressValue()
  if initial==nil then
   status("Stage introuvable : progression non verifiable")
   return
  end
  local data=scanObby(true)
  if #data.stages==0 then status("Aucun checkpoint detecte");return end

  while checkpointBusy and not disposed and autoSkipGeneration==generation do
   task.wait()
  end
  if disposed or autoSkipGeneration~=generation then return end

  if autoWin then
   local final=data.stages[#data.stages]
   if final and initial<final.number then
    status("Auto Win Turbo : dernier checkpoint "..final.number)
    local confirmed=activateCheckpoint(final,{attempts=1,timeout=1})
    if confirmed then
     status("Dernier checkpoint valide ; direction Finish")
    else
     status("Saut direct refuse ; passage des stages sans delai")
    end
   end
  end

  while not disposed and autoSkipGeneration==generation
   and (settings.autoSkip or autoWin) do
   local entry,why=stageDestination(1)
   if not entry then
    local refreshed=scanObby(true)
    local current=progressValue()
    local last=refreshed.stages[#refreshed.stages]
    if autoWin and last and current and current>=last.number then
     if refreshed.finish then
      status("Dernier stage confirme ; tentative Finish...")
      tryFinish()
     else
      status("Stages confirmes ; Finish introuvable")
     end
    else
     status("Progression arretee : "..(why or "checkpoint introuvable"))
    end
    return
   end
   local confirmed,reason=activateCheckpoint(entry)
   if not confirmed then
    status("Progression arretee : "..(reason or "checkpoint non valide"))
    return
   end
   -- A 0-second task.wait yields one engine frame, not an intentional delay.
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
actions.obbyAutoWin=function()
 if progressValue()==nil then
  return "Auto Win indisponible : compteur Stage introuvable"
 end
 if #scanObby(true).stages==0 then
  return "Auto Win indisponible : aucun checkpoint detecte"
 end
 startAutoSkip(true)
 return "Auto Win Turbo : dernier stage direct, sinon progression rapide verifiee"
end
actions.obbyTeleportStart=function()
 local data=scanObby(false)
 local entry=data.stages[1]
 if not entry then return "No starting stage found"end
 return telePart(entry.part,true) and "Start teleport attempted" or "Start teleport unavailable"
end
local function readValue(key)
 if key=="@obbyStage" then
  local n=progressValue()
  return n~=nil and tostring(n) or "Indisponible"
 elseif key=="@obbyCount" then
  return tostring(#scanObby(false).stages)
 elseif key=="@obbyStatus" then
  return checkpointStatus
 end
 return nil
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
  settings.skipDelay=math.clamp(tonumber(value) or 0,0,15)
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
 readValue=readValue,
 sections={
  {tab="Game",column="left",title="Obby Cheats",subtitle="Movement helpers",items={
   {type="toggle",id="obbyFly",label="Fly",desc="WASD / Space or E up / Q or Ctrl down"},
   {type="toggle",id="obbyNoclip",label="Noclip",desc="Disable local collisions"},
   {type="toggle",id="obbyInfiniteJump",label="Infinite Jump",desc="Jump again while airborne"},
   {type="toggle",id="obbyLowGravity",label="Low Gravity",desc="Lighter client-side gravity"}
  }},
  {tab="Game",column="right",title="Stage Tools",subtitle="Checkpoint activation + verification",items={
   {type="info",label="Stage actuel (jeu)",value="@obbyStage"},
   {type="info",label="Checkpoints detectes",value="@obbyCount"},
   {type="info",label="Statut",value="@obbyStatus"},
   {type="button",id="obbyScan",label="Scan Stages / Finish"},
   {type="button",id="obbySkipStage",label="Skip Stage (attempt)"},
   {type="button",id="obbyPreviousStage",label="Previous Stage"},
   {type="button",id="obbyTeleportStart",label="Teleport to Start"},
   {type="button",id="obbyTeleportFinish",label="Teleport to Finish"},
   {type="button",id="obbyAutoWin",label="Auto Win Turbo (attempt)"}
  }},
  {tab="Game",column="left",title="Automation",subtitle="Progression attempts; server may reject",items={
   {type="toggle",id="obbyAutoSkip",label="Auto Skip (verified)",desc="0s delay possible; validates each checkpoint before continuing"},
   {type="slider",id="obbySkipDelay",label="Auto Skip Delay (s)",min=0,max=15},
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
