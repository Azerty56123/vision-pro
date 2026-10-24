--[[ VISION HUB V1 • SENA-INSPIRED MULTI-GAME LOADER
  Original Vision design; Sena-like layout and Reverb-like access flow.
  Each supported game profile is defined in a separate games/*.lua file.
  Functional: key demo, optional HTTPS key verification, two-column cards,
  navigation, search, toggles, sliders, drop-downs, FPS/ping, local lighting,
  FOV, movement values, copy utilities and user position bookmarks.
  Game modules only declare UI: no undisclosed external execution.
]]
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Http=game:GetService("HttpService")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
if not player then return end
local pg=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",10)
if not pg then return end
local NAME="VisionHubV1_Sena"
local BASE="https://raw.githubusercontent.com/Azerty56123/vision-pro/main/"
local TEST_KEY="VISION-TEST-ILLIMITE-2026"
local KEY_API="https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
for _,name in ipairs({NAME,"VisionHubV1_Design12","VisionHubV11_Design12","VisionHubV10"}) do
 local old=pg:FindFirstChild(name)
 if old then old:Destroy() end
end

local A={
 bg=Color3.fromRGB(11,11,14),side=Color3.fromRGB(13,13,16),
 card=Color3.fromRGB(23,23,27),row=Color3.fromRGB(31,31,36),
 field=Color3.fromRGB(26,26,31),border=Color3.fromRGB(40,39,45),
 white=Color3.fromRGB(238,237,240),muted=Color3.fromRGB(137,137,147),
 cyan=Color3.fromRGB(25,197,239),cyanDark=Color3.fromRGB(8,53,73),
 light=Color3.fromRGB(192,196,203),good=Color3.fromRGB(107,220,157)
}
local current,closed,unlocked="Overview",false,false
local pconns,conns={},{}
local stored={fps=false,ping=false,xyz=false,players=false,bright=false,animations=true}
local nums={fov=70,speed=16,jump=50,zoom=100}
local positions={}
local fps,frames,fpsElapsed,updateElapsed=0,0,0,0
local originalFOV
local firstLight={
 Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,
 OutdoorAmbient=Lighting.OutdoorAmbient,ClockTime=Lighting.ClockTime,FogEnd=Lighting.FogEnd
}
local originalHumanoids=setmetatable({}, {__mode="k"})
local function root()
 local ch=player.Character
 return ch and ch:FindFirstChild("HumanoidRootPart")
end
local function human()
 local ch=player.Character
 return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function clipboard(value)
 local fn=setclipboard or toclipboard
 return type(fn)=="function" and pcall(fn,tostring(value)) or false
end
local function create(klass,parent,attrs)
 local i=Instance.new(klass)
 for k,v in pairs(attrs or {}) do i[k]=v end
 i.Parent=parent
 return i
end
local function corner(i,r)
 create("UICorner",i,{CornerRadius=UDim.new(0,r or 6)})
 return i
end
local function outline(i,color,size)
 create("UIStroke",i,{Color=color or A.border,Thickness=size or 1})
 return i
end
local function label(parent,s,size,color,bold,other)
 local attrs={BackgroundTransparency=1,BorderSizePixel=0,Text=tostring(s),
  Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
  TextSize=size or 11,TextColor3=color or A.white,
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
  TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,20)}
 for k,v in pairs(other or {}) do attrs[k]=v end
 return create("TextLabel",parent,attrs)
end
local function button(parent,name,attrs)
 local a={BackgroundColor3=A.field,BorderSizePixel=0,AutoButtonColor=true,
  Text=tostring(name),Font=Enum.Font.GothamMedium,TextSize=11,TextColor3=A.white,
  Size=UDim2.new(1,0,0,31)}
 for k,v in pairs(attrs or {}) do a[k]=v end
 local o=create("TextButton",parent,a);corner(o,5);return o
end
local function bind(signal,fn,page)
 local c=signal:Connect(fn)
 table.insert(page and pconns or conns,c)
 return c
end
local function clearPageLinks()
 for _,c in ipairs(pconns) do pcall(function()c:Disconnect()end)end
 table.clear(pconns)
end
local function fetchProfile(name)
 local ok,result=pcall(function()
  local source=game:HttpGet(BASE.."games/"..name..".lua")
  local fn=loadstring(source)
  if type(fn)~="function" then error("Profil invalide") end
  return fn()
 end)
 if ok and type(result)=="table" and type(result.sections)=="table" then
  return result
 end
 return nil
end
local function detect()
 local id=game.PlaceId
 if id==142823291 then return "mm2" end
 if id==286090429 then return "arsenal" end
 if id==292439477 then return "phantom_forces" end
 local name=string.lower(game.Name or "")
 if name:find("tycoon",1,true) then return "tycoon" end
 if name:find("obby",1,true) or name:find("parkour",1,true) then return "obby" end
 if name:find("war",1,true) or name:find("army",1,true)
 or name:find("battle",1,true) or name:find("military",1,true) then
  return "war"
 end
 return "universal"
end
local profileId=detect()
local universal=fetchProfile("universal")
local selected=profileId~="universal" and fetchProfile(profileId) or universal
selected=selected or {id="universal",name="Universal",description="Basic dashboard",sections={}}
universal=universal or {id="universal",name="Universal",sections={}}
local allSections={}
for _,group in ipairs(universal.sections) do table.insert(allSections,group)end
if selected~=universal then
 for _,group in ipairs(selected.sections) do table.insert(allSections,group)end
end
local function applyBright(on)
 stored.bright=on
 local nextSet=on and {Brightness=3,ClockTime=14,FogEnd=1000000,
  Ambient=Color3.fromRGB(180,180,190),
  OutdoorAmbient=Color3.fromRGB(180,180,190)} or firstLight
 for key,val in pairs(nextSet) do pcall(function()Lighting[key]=val end)end
end
local function speed(n)
 nums.speed=n
 local h=human()
 if h then
  if not originalHumanoids[h] then
   originalHumanoids[h]={walk=h.WalkSpeed,jump=h.JumpPower,use=h.UseJumpPower}
  end
  pcall(function()h.WalkSpeed=n end)
 end
end
local function jump(n)
 nums.jump=n
 local h=human()
 if h then
  if not originalHumanoids[h] then
   originalHumanoids[h]={walk=h.WalkSpeed,jump=h.JumpPower,use=h.UseJumpPower}
  end
  pcall(function()h.UseJumpPower=true;h.JumpPower=n end)
 end
end
local function fov(n)
 nums.fov=n
 local cam=workspace.CurrentCamera
 if cam then
  if not originalFOV then originalFOV=cam.FieldOfView end
  cam.FieldOfView=n
 end
end
local gui=create("ScreenGui",pg,{Name=NAME,ResetOnSpawn=false,
 ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=920})
local app,appScale,mini,header,tabRail,nav,body,columns,left,right,canvas
local navButtons={}
local footerMessage,footerFps,overlay,overlayText,search
local gameLabel,miniMode=false,false
local render,openApp,fitToScreen
local liveLabels={}
local status=function(_) end
local function kill()
 if closed then return end
 closed=true
 if stored.bright then applyBright(false) end
 if originalFOV and workspace.CurrentCamera then
  pcall(function()workspace.CurrentCamera.FieldOfView=originalFOV end)
 end
 for h,default in pairs(originalHumanoids) do
  if h and h.Parent then pcall(function()
   h.WalkSpeed=default.walk;h.UseJumpPower=default.use;h.JumpPower=default.jump
  end)end
 end
 clearPageLinks()
 for _,c in ipairs(conns) do pcall(function()c:Disconnect()end)end
 if gui.Parent then gui:Destroy()end
end
bind(gui.Destroying,kill)
local function pos()
 local r=root()
 if not r then return "—" end
 local p=r.Position
 return string.format("%.1f, %.1f, %.1f",p.X,p.Y,p.Z)
end
local function readValue(key)
 if key=="@game" then return game.Name end
 if key=="@profile" then return selected.name end
 if key=="@players" then return tostring(#Players:GetPlayers())end
 if key=="@place" then return tostring(game.PlaceId)end
 if key=="@fps" then return tostring(fps)end
 if key=="@ping" then
  local ok,p=pcall(function()return player:GetNetworkPing()end)
  return ok and tostring(math.floor(p*1000+.5)).." ms" or "—"
 end
 if key=="@health" then
  local h=human()
  return h and tostring(math.floor(h.Health)) or "—"
 end
 return tostring(key or "")
end
local function configured()
 return KEY_API:match("^https://") and not KEY_API:find("YOUR-SUBDOMAIN",1,true)
end
local function verifyKeyRemote(value)
 if not configured() then return false,"Cloudflare non configuré" end
 local req=request or http_request or (type(syn)=="table" and syn.request)
   or (type(http)=="table" and http.request)
 if type(req)~="function" then return false,"HTTPS POST non disponible" end
 local ok,result=pcall(req,{Url=KEY_API:gsub("/+$","").."/api/verify",
  Method="POST",Headers={["Content-Type"]="application/json"},
  Body=Http:JSONEncode({key=value})})
 if not ok or type(result)~="table" then return false,"Serveur injoignable" end
 local parsed,data=pcall(function()return Http:JSONDecode(result.Body or result.body or "")end)
 if not parsed or type(data)~="table" then return false,"Réponse invalide" end
 return data.ok==true,tostring(data.message or (data.ok and "Clé valide" or "Clé refusée"))
end

-- DESIGN SENA: topbar, vertical navigation, two compact columns and bottom status.
app=create("Frame",gui,{Name="MainWindow",BackgroundColor3=A.bg,BorderSizePixel=0,
 Size=UDim2.fromOffset(865,548),Position=UDim2.fromScale(.5,.5),
 AnchorPoint=Vector2.new(.5,.5),ClipsDescendants=true,Visible=false})
corner(app,8);outline(app,A.border,.9)
appScale=create("UIScale",app,{Scale=1})
header=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Size=UDim2.new(1,0,0,49),Active=true})
create("Frame",header,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)})
label(header,"VISION",18,A.white,true,{Position=UDim2.fromOffset(17,9),
 Size=UDim2.fromOffset(70,31)})
label(header,"HUB",18,A.cyan,true,{Position=UDim2.fromOffset(89,9),
 Size=UDim2.fromOffset(53,31)})
local titleGame=label(header,"/  "..selected.name,10,A.muted,true,{
 Position=UDim2.fromOffset(148,12),Size=UDim2.fromOffset(210,25)})
search=create("TextBox",header,{BackgroundColor3=A.card,BorderSizePixel=0,
 Position=UDim2.new(1,-275,0,9),Size=UDim2.fromOffset(174,31),
 Text="",ClearTextOnFocus=false,PlaceholderText="⌕  Search",
 Font=Enum.Font.Gotham,TextSize=11,TextColor3=A.white,
 PlaceholderColor3=A.muted,TextXAlignment=Enum.TextXAlignment.Left})
corner(search,6)
create("UIPadding",search,{PaddingLeft=UDim.new(0,9)})
local hide=button(header,"−",{Position=UDim2.new(1,-78,0,10),Size=UDim2.fromOffset(28,29)})
local close=button(header,"×",{Position=UDim2.new(1,-42,0,10),Size=UDim2.fromOffset(28,29)})
tabRail=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,49),Size=UDim2.new(0,184,1,-79)})
create("Frame",tabRail,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0)})
local railTitle=label(tabRail,"WORKSPACE",10,A.muted,true,{
 Position=UDim2.fromOffset(16,15),Size=UDim2.fromOffset(152,17)})
nav=create("ScrollingFrame",tabRail,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(10,48),Size=UDim2.new(1,-20,1,-60),
 ScrollingDirection=Enum.ScrollingDirection.Y,
 CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
 ScrollBarThickness=0})
local navLayout=create("UIListLayout",nav,{
 SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)})
body=create("Frame",app,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(184,49),Size=UDim2.new(1,-184,1,-79)})
local pageTitle=label(body,"Overview",16,A.white,true,{
 Position=UDim2.fromOffset(18,4),Size=UDim2.fromOffset(340,27)})
local pageDescription=label(body,selected.description,10,A.muted,false,{
 Position=UDim2.fromOffset(18,30),Size=UDim2.new(1,-30,0,19)})
canvas=create("ScrollingFrame",body,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(14,58),Size=UDim2.new(1,-26,1,-63),
 CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=3,
 ScrollBarImageColor3=A.cyan,ScrollingDirection=Enum.ScrollingDirection.Y})
columns=create("Frame",canvas,{BackgroundTransparency=1,BorderSizePixel=0,
 Size=UDim2.new(1,-7,0,0),AutomaticSize=Enum.AutomaticSize.Y})
local colLayout=create("UIListLayout",columns,{
 FillDirection=Enum.FillDirection.Horizontal,
 SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,10)})
left=create("Frame",columns,{BackgroundTransparency=1,
 Size=UDim2.new(.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1})
right=create("Frame",columns,{BackgroundTransparency=1,
 Size=UDim2.new(.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
local lLay=create("UIListLayout",left,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,9)})
local rLay=create("UIListLayout",right,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,9)})
local footer=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-30),Size=UDim2.new(1,0,0,30)})
create("Frame",footer,{BackgroundColor3=A.border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)})
footerMessage=label(footer,"●  SYSTEM READY",10,A.good,true,{
 Position=UDim2.fromOffset(13,4),Size=UDim2.fromOffset(320,24)})
local footerExec=label(footer,"Executor: "..(type(identifyexecutor)=="function"
  and tostring((function()local ok,n=pcall(identifyexecutor)return ok and n or "Unknown"end)())
  or "Unknown"),9,A.muted,false,{
 Position=UDim2.new(1,-270,0,4),Size=UDim2.fromOffset(150,23),
 TextXAlignment=Enum.TextXAlignment.Right})
footerFps=label(footer,"-- FPS",10,A.muted,true,{
 Position=UDim2.new(1,-108,0,4),Size=UDim2.fromOffset(51,23),
 TextXAlignment=Enum.TextXAlignment.Right})
label(footer,"v1.0",9,A.muted,true,{
 Position=UDim2.new(1,-54,0,4),Size=UDim2.fromOffset(39,23),
 TextXAlignment=Enum.TextXAlignment.Right})
mini=button(gui,"VISION HUB",{Position=UDim2.new(1,-160,.5,-20),
 Size=UDim2.fromOffset(146,38),BackgroundColor3=A.cyanDark,Visible=false})
outline(mini,A.cyan,.8)
overlay=create("Frame",gui,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(1,-265,0,10),Size=UDim2.fromOffset(250,35),Visible=false})
corner(overlay,6);outline(overlay,A.cyan,.8)
overlayText=label(overlay,"",10,A.white,true,{
 Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center})
status=function(message)
 if footerMessage and footerMessage.Parent then footerMessage.Text="●  "..tostring(message) end
end
openApp=function(on)
 if closed or not unlocked then return end
 app.Visible=on;mini.Visible=not on
end
bind(hide.Activated,function()openApp(false)end)
bind(close.Activated,kill)
bind(mini.Activated,function()openApp(true)end)
bind(UIS.InputBegan,function(i,processed)
 if not processed and not UIS:GetFocusedTextBox() and i.KeyCode==Enum.KeyCode.RightShift then
  openApp(not app.Visible)
 end
end)
-- Window drag (mouse and touch).
local moving=false
local down,initial
bind(header.InputBegan,function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  moving=true;down=i.Position;initial=app.Position
 end
end)
bind(UIS.InputChanged,function(i)
 if moving and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
  local diff=i.Position-down
  app.Position=UDim2.new(initial.X.Scale,initial.X.Offset+diff.X,
   initial.Y.Scale,initial.Y.Offset+diff.Y)
 end
end)
bind(UIS.InputEnded,function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then moving=false end
end)
local small=false
fitToScreen=function()
 if closed or not app.Parent then return end
 local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
 small=v.X<740
 if small then
  app.Size=UDim2.fromOffset(450,650)
  appScale.Scale=math.clamp(math.min(nums.zoom/100,(v.X-12)/450,(v.Y-12)/650),.3,1)
  tabRail.Position=UDim2.fromOffset(0,49);tabRail.Size=UDim2.new(1,0,0,43)
  railTitle.Visible=false
  nav.Position=UDim2.fromOffset(7,4);nav.Size=UDim2.new(1,-14,0,35)
  nav.ScrollingDirection=Enum.ScrollingDirection.X
  nav.AutomaticCanvasSize=Enum.AutomaticSize.X
  navLayout.FillDirection=Enum.FillDirection.Horizontal
  body.Position=UDim2.fromOffset(0,92);body.Size=UDim2.new(1,0,1,-122)
  colLayout.FillDirection=Enum.FillDirection.Vertical
  left.Size=UDim2.new(1,-6,0,0);right.Size=UDim2.new(1,-6,0,0)
  search.Position=UDim2.new(1,-209,0,9);search.Size=UDim2.fromOffset(128,31)
  titleGame.Visible=false
  pageTitle.Position=UDim2.fromOffset(14,4);pageDescription.Position=UDim2.fromOffset(14,30)
  for _,b in pairs(navButtons) do b.Size=UDim2.fromOffset(100,33)end
 else
  app.Size=UDim2.fromOffset(865,548)
  appScale.Scale=math.clamp(math.min(nums.zoom/100,(v.X-14)/865,(v.Y-14)/548),.45,1.15)
  tabRail.Position=UDim2.fromOffset(0,49);tabRail.Size=UDim2.new(0,184,1,-79)
  railTitle.Visible=true
  nav.Position=UDim2.fromOffset(10,48);nav.Size=UDim2.new(1,-20,1,-60)
  nav.ScrollingDirection=Enum.ScrollingDirection.Y
  nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
  navLayout.FillDirection=Enum.FillDirection.Vertical
  body.Position=UDim2.fromOffset(184,49);body.Size=UDim2.new(1,-184,1,-79)
  colLayout.FillDirection=Enum.FillDirection.Horizontal
  left.Size=UDim2.new(.5,-5,0,0);right.Size=UDim2.new(.5,-5,0,0)
  search.Position=UDim2.new(1,-275,0,9);search.Size=UDim2.fromOffset(174,31)
  titleGame.Visible=true
  pageTitle.Position=UDim2.fromOffset(18,4);pageDescription.Position=UDim2.fromOffset(18,30)
  for _,b in pairs(navButtons) do b.Size=UDim2.new(1,0,0,37)end
 end
end
local function canvasHeight()
 task.defer(function()
  if canvas.Parent and not closed then
   canvas.CanvasSize=UDim2.fromOffset(0,(small and (left.AbsoluteSize.Y+right.AbsoluteSize.Y+20)
    or math.max(left.AbsoluteSize.Y,right.AbsoluteSize.Y))+22)
  end
 end)
end
bind(lLay:GetPropertyChangedSignal("AbsoluteContentSize"),canvasHeight)
bind(rLay:GetPropertyChangedSignal("AbsoluteContentSize"),canvasHeight)
bind(left:GetPropertyChangedSignal("AbsoluteSize"),canvasHeight)
bind(right:GetPropertyChangedSignal("AbsoluteSize"),canvasHeight)
