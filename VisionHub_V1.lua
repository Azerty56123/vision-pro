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
local Marketplace=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
if not player then return end
local pg=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",10)
if not pg then return end
local NAME="VisionHubV1_Sena"
local BASE="https://raw.githubusercontent.com/Azerty56123/vision-pro/main/"
local TEST_KEY="VISION-TEST-ILLIMITE-2026"
local GAME_TITLE=game.Name
local okName,placeInfo=pcall(function()
 return Marketplace:GetProductInfo(game.PlaceId,Enum.InfoType.Asset)
end)
if okName and type(placeInfo)=="table" and type(placeInfo.Name)=="string" and placeInfo.Name~="" then
 GAME_TITLE=placeInfo.Name
end
local KEY_API="https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
for _,name in ipairs({NAME,"VisionHubV1_Design12","VisionHubV11_Design12","VisionHubV10"}) do
 local old=pg:FindFirstChild(name)
 if old then old:Destroy() end
end

local A={
 bg=Color3.fromRGB(10,11,15),side=Color3.fromRGB(15,17,22),
 card=Color3.fromRGB(24,27,34),row=Color3.fromRGB(31,35,43),
 field=Color3.fromRGB(29,33,41),border=Color3.fromRGB(49,54,66),
 white=Color3.fromRGB(247,248,250),muted=Color3.fromRGB(153,162,176),
 cyan=Color3.fromRGB(42,203,239),cyanDark=Color3.fromRGB(16,79,102),
 light=Color3.fromRGB(179,200,217),good=Color3.fromRGB(111,228,166)
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
-- Important: Roblox widgets may already have a UICorner. Update it; do not stack
-- duplicate UICorners (the old code did that on toggles and buttons).
local function corner(i,r)
 local existing=i:FindFirstChildOfClass("UICorner")
 if existing then existing.CornerRadius=UDim.new(0,r or 8)
 else create("UICorner",i,{CornerRadius=UDim.new(0,r or 8)})end
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
 local o=create("TextButton",parent,a);corner(o,9);return o
end
-- Shared Lucide-style Roblox image assets: no homemade glyphs, no invented IDs.
local ICON={
 overview="rbxassetid://7733970318",game="rbxassetid://7733799795",
 player="rbxassetid://7743875962",visuals="rbxassetid://7733774602",
 settings="rbxassetid://7734058803",about="rbxassetid://7733993369",
 module="rbxassetid://7743869612",chevron="rbxassetid://7733717447",
 search="rbxassetid://7734052925",key="rbxassetid://7733965118",
 shield="rbxassetid://7734056411",menu="rbxassetid://7733993211",
 copy="rbxassetid://7733764083"
}
local function artwork(host,name,x,y,w,h,color)
 local uri=ICON[name]
 if not uri then return nil end
 return create("ImageLabel",host,{
  Name="Icon_"..name,BackgroundTransparency=1,BorderSizePixel=0,
  Image=uri,ImageColor3=color or A.light,ScaleType=Enum.ScaleType.Fit,
  Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h)
 })
end
local function monogram(host,x,y,size)
 local outer=create("Frame",host,{BackgroundColor3=Color3.fromRGB(7,40,55),
  BorderSizePixel=0,Position=UDim2.fromOffset(x,y),
  Size=UDim2.fromOffset(size,size)})
 corner(outer,math.ceil(size*.5))
 outline(outer,A.cyan,1.8)
 create("UIGradient",outer,{Rotation=35,Color=ColorSequence.new({
  ColorSequenceKeypoint.new(0,Color3.fromRGB(19,101,128)),
  ColorSequenceKeypoint.new(1,Color3.fromRGB(7,27,41))
 })})
 local inner=create("Frame",outer,{
  BackgroundColor3=Color3.fromRGB(6,20,30),BackgroundTransparency=.16,
  BorderSizePixel=0,Position=UDim2.fromScale(.14,.14),
  Size=UDim2.fromScale(.72,.72)})
 corner(inner,math.ceil(size*.36))
 label(outer,"V",math.floor(size*.52),A.cyan,true,{
  Font=Enum.Font.GothamBlack,Size=UDim2.fromScale(1,1),
  TextXAlignment=Enum.TextXAlignment.Center
 })
 local dot=create("Frame",outer,{BackgroundColor3=Color3.fromRGB(177,252,255),
  BorderSizePixel=0,Position=UDim2.new(1,-8,0,5),
  Size=UDim2.fromOffset(4,4)})
 corner(dot,3)
 return outer
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
 local name=string.lower(GAME_TITLE or game.Name or "")
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
 if key=="@game" then return GAME_TITLE end
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
corner(app,15);outline(app,A.border,.9)
appScale=create("UIScale",app,{Scale=1})
header=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Size=UDim2.new(1,0,0,49),Active=true})
corner(header,15)
-- Keep top corners rounded without rounding the bottom edge.
create("Frame",header,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-16),Size=UDim2.new(1,0,0,16)})
create("Frame",header,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)})
-- Identity shared by both windows.
monogram(header,14,8,32)
label(header,"VISION",16,A.white,true,{
 Position=UDim2.fromOffset(57,10),Size=UDim2.fromOffset(82,28)})
label(header,"HUB",16,A.cyan,true,{
 Position=UDim2.fromOffset(158,10),Size=UDim2.fromOffset(48,28)})
local titleGame=label(header,"/  "..selected.name,10,A.muted,true,{
 Position=UDim2.fromOffset(222,12),Size=UDim2.fromOffset(190,25)})
-- A separate search wrapper prevents Roblox TextBox placeholder text from
-- rendering underneath an ImageLabel (a visible overlap in the screenshots).
local searchHolder=create("Frame",header,{
 BackgroundColor3=A.card,BorderSizePixel=0,
 Position=UDim2.new(1,-275,0,9),Size=UDim2.fromOffset(174,31)})
corner(searchHolder,10)
local searchEdge=outline(searchHolder,A.border,.8)
artwork(searchHolder,"search",12,8,14,14,A.muted)
search=create("TextBox",searchHolder,{
 BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(35,0),Size=UDim2.new(1,-39,1,0),
 Text="",ClearTextOnFocus=false,PlaceholderText="Search modules...",
 Font=Enum.Font.Gotham,TextSize=11,TextColor3=A.white,
 PlaceholderColor3=A.muted,TextXAlignment=Enum.TextXAlignment.Left,
 TextTruncate=Enum.TextTruncate.AtEnd})
bind(search.Focused,function()searchEdge.Color=A.cyan end)
bind(search.FocusLost,function()searchEdge.Color=A.border end)
local hide=button(header,"−",{Position=UDim2.new(1,-78,0,10),Size=UDim2.fromOffset(29,29),BackgroundColor3=A.field})
local close=button(header,"×",{Position=UDim2.new(1,-42,0,10),Size=UDim2.fromOffset(29,29),BackgroundColor3=A.field})
corner(hide,9);corner(close,9)
outline(hide,A.border,.75);outline(close,A.border,.75)
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
 Position=UDim2.fromOffset(18,34),Size=UDim2.new(1,-30,0,19)})
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
corner(footer,15)
-- Straight footer top edge, with rounded bottom corners.
create("Frame",footer,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,15)})
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
corner(mini,11);outline(mini,A.cyan,.8)
overlay=create("Frame",gui,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(1,-265,0,10),Size=UDim2.fromOffset(250,35),Visible=false})
corner(overlay,10);outline(overlay,A.cyan,.8)
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
  searchHolder.Position=UDim2.new(1,-209,0,9)
  searchHolder.Size=UDim2.fromOffset(128,31)
  titleGame.Visible=false
  pageTitle.Position=UDim2.fromOffset(14,4);pageDescription.Position=UDim2.fromOffset(14,30)
  for _,b in pairs(navButtons) do b.Size=UDim2.fromOffset(119,37)end
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
  searchHolder.Position=UDim2.new(1,-275,0,9)
  searchHolder.Size=UDim2.fromOffset(174,31)
  titleGame.Visible=true
  pageTitle.Position=UDim2.fromOffset(18,4);pageDescription.Position=UDim2.fromOffset(18,30)
  for _,b in pairs(navButtons) do b.Size=UDim2.new(1,0,0,39)end
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

-- Components: compact Sena-like cards with controls in two columns.
local filterRecords={}
local tabSections={}
local expandStates={}
local function clearCards()
 clearPageLinks()
 liveLabels={}
 filterRecords={}
 for _,area in ipairs({left,right}) do
  for _,ch in ipairs(area:GetChildren()) do
   if not ch:IsA("UIListLayout") then ch:Destroy()end
  end
 end
 canvas.CanvasPosition=Vector2.new(0,0)
end
local function row(parent,h)
 local f=create("Frame",parent,{BackgroundColor3=A.row,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,h or 54)})
 corner(f,9)
 return f
end
local function register(section,f,title)
 table.insert(section.items,{ui=f,text=string.lower(title)})
end
local function isTrue(id)
 return stored[id]==true
end
local function action(id)
 if id=="copyPlace" then
  status(clipboard(game.PlaceId) and "Place ID copied" or "Place ID: "..game.PlaceId)
 elseif id=="copyCoords" then
  status(clipboard(pos()) and "Coordinates copied" or "XYZ: "..pos())
 elseif id=="savePos1" or id=="savePos2" then
  local i=id=="savePos1" and 1 or 2
  local r=root()
  if r then positions[i]=r.CFrame;status("Position "..i.." saved")
  else status("Character unavailable")end
 elseif id=="gotoPos1" or id=="gotoPos2" then
  local i=id=="gotoPos1" and 1 or 2
  if not positions[i] or not player.Character then
   status("Save position "..i.." first");return
  end
  local ok=pcall(function()player.Character:PivotTo(positions[i])end)
  status(ok and "Local return attempted" or "Return unavailable")
 elseif id=="equipTool" then
  local h=human()
  local pack=player:FindFirstChildOfClass("Backpack")
  local tool=pack and pack:FindFirstChildOfClass("Tool")
  if not h or not tool then return status("No available Tool")end
  local ok=pcall(function()h:EquipTool(tool)end)
  status(ok and "Tool equip requested" or "Cannot equip Tool")
 elseif id=="useTool" then
  local ch=player.Character
  local tool=ch and ch:FindFirstChildOfClass("Tool")
  if not tool then return status("Equip a Tool first")end
  local ok=pcall(function()tool:Activate()end)
  status(ok and "Tool activation requested" or "Cannot activate Tool")
 elseif id=="resetMovement" then
  speed(16);jump(50);status("Movement reset to 16 / 50")
  if render then render()end
 elseif id=="recenter" then
  app.Position=UDim2.fromScale(.5,.5);status("Window centered")
 elseif id=="minimize" then openApp(false)
 elseif id=="close" then kill()
 else status("Unavailable command: "..tostring(id))end
end
local function controlInfo(parent,section,item)
 local f=row(parent,44)
 label(f,item.label,11,A.white,true,{Position=UDim2.fromOffset(13,5),
  Size=UDim2.new(1,-23,0,18)})
 local value=label(f,readValue(item.value),10,A.muted,false,{
  Position=UDim2.fromOffset(12,24),Size=UDim2.new(1,-22,0,15)})
 if type(item.value)=="string" and item.value:sub(1,1)=="@" then
  table.insert(liveLabels,{id=item.value,target=value})
 end
 register(section,f,item.label.." "..tostring(item.value))
end
local function controlToggle(parent,section,item)
 local f=row(parent,59)
 label(f,item.label,11,A.white,true,{Position=UDim2.fromOffset(11,9),
  Size=UDim2.new(1,-77,0,20)})
 label(f,item.desc or "",9,A.muted,false,{Position=UDim2.fromOffset(11,31),
  Size=UDim2.new(1,-77,0,17)})
 local b=button(f,"",{Position=UDim2.new(1,-53,0,17),
  Size=UDim2.fromOffset(41,23),
  BackgroundColor3=isTrue(item.id) and A.cyanDark or A.border})
 corner(b,12)
 local dot=create("Frame",b,{BackgroundColor3=isTrue(item.id) and A.cyan or A.light,
  BorderSizePixel=0,Position=UDim2.fromOffset(isTrue(item.id) and 21 or 4,4),
  Size=UDim2.fromOffset(15,15)})
 corner(dot,8)
 bind(b.Activated,function()
  stored[item.id]=not isTrue(item.id)
  local state=isTrue(item.id)
  b.BackgroundColor3=state and A.cyanDark or A.border
  dot.BackgroundColor3=state and A.cyan or A.light
  local goal=UDim2.fromOffset(state and 21 or 4,4)
  if stored.animations then Tween:Create(dot,TweenInfo.new(.14),{Position=goal}):Play()
  else dot.Position=goal end
  if item.id=="bright" then applyBright(state)end
  status(item.label.." : "..(state and "ON" or "OFF"))
 end,true)
 register(section,f,item.label.." "..(item.desc or ""))
end
local function controlSlider(parent,section,item)
 local lo,hi=item.min or 0,item.max or 100
 if hi<=lo then return end
 local id=item.id
 local f=row(parent,81)
 label(f,item.label,11,A.white,true,{Position=UDim2.fromOffset(12,7),
  Size=UDim2.new(1,-80,0,21)})
 local val=label(f,tostring(nums[id] or lo),10,A.muted,true,{
  Position=UDim2.new(1,-75,0,7),Size=UDim2.fromOffset(60,21),
  TextXAlignment=Enum.TextXAlignment.Right})
 local track=create("Frame",f,{BackgroundColor3=A.border,BorderSizePixel=0,
  Position=UDim2.new(0,13,0,55),Size=UDim2.new(1,-26,0,6)})
 corner(track,4)
 local fill=create("Frame",track,{BackgroundColor3=A.light,BorderSizePixel=0,
  Size=UDim2.fromScale(math.clamp(((nums[id] or lo)-lo)/(hi-lo),0,1),1)})
 corner(fill,4)
 local dot=create("Frame",track,{BackgroundColor3=A.white,BorderSizePixel=0,
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(fill.Size.X.Scale,.5),
  Size=UDim2.fromOffset(11,11)})
 corner(dot,6)
 local zone=button(f,"",{BackgroundTransparency=1,
  Position=UDim2.new(0,12,0,40),Size=UDim2.new(1,-24,0,34)})
 local dragging=false
 local touchInput
 local function set(x)
  local fraction=math.clamp((x-track.AbsolutePosition.X)/
   math.max(1,track.AbsoluteSize.X),0,1)
  local nextVal=math.floor(lo+fraction*(hi-lo)+.5)
  if nums[id]~=nextVal then
   nums[id]=nextVal
   val.Text=tostring(nextVal)
   fill.Size=UDim2.fromScale(fraction,1)
   dot.Position=UDim2.fromScale(fraction,.5)
   if id=="speed" then speed(nextVal)
   elseif id=="jump" then jump(nextVal)
   elseif id=="fov" then fov(nextVal)
   elseif id=="zoom" then fitToScreen()
   end
  end
 end
 bind(zone.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   dragging=true;touchInput=i;set(i.Position.X)
  end
 end,true)
 bind(UIS.InputChanged,function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
    or (i.UserInputType==Enum.UserInputType.Touch and i==touchInput)) then
   set(i.Position.X)
  end
 end,true)
 bind(UIS.InputEnded,function(i)
  if i==touchInput or (touchInput and touchInput.UserInputType==Enum.UserInputType.MouseButton1
   and i.UserInputType==Enum.UserInputType.MouseButton1) then
   dragging=false;touchInput=nil
  end
 end,true)
 register(section,f,item.label)
end
local function controlButton(parent,section,item)
 local b=button(parent,item.label,{Size=UDim2.new(1,0,0,35),
  BackgroundColor3=A.field})
 outline(b,A.border,.6)
 bind(b.Activated,function()
  local ok,err=pcall(action,item.id)
  if not ok then status("Action error: "..tostring(err))end
 end,true)
 register(section,b,item.label)
end
local function controlDrop(parent,section,item)
 local values=item.values or {}
 if #values==0 then return end
 local f=row(parent,59)
 label(f,item.label,11,A.white,true,{Position=UDim2.fromOffset(12,6),
  Size=UDim2.new(.5,-12,0,21)})
 local chosen=1
 local drop=button(f,values[chosen].."  v",{
  Position=UDim2.new(.47,0,0,10),
  Size=UDim2.new(.53,-11,0,30),BackgroundColor3=A.field,TextSize=10
 })
 outline(drop,A.border,.8)
 local optFrame=create("Frame",f,{BackgroundTransparency=1,
  Size=UDim2.new(1,-20,0,0),Position=UDim2.fromOffset(10,54),Visible=false})
 local stack=create("UIListLayout",optFrame,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,3)})
 for i,v in ipairs(values) do
  local option=button(optFrame,v,{Size=UDim2.new(1,0,0,26),LayoutOrder=i,
   BackgroundColor3=A.field,TextSize=10})
  bind(option.Activated,function()
   chosen=i;drop.Text=v.."  v"
   optFrame.Visible=false;f.Size=UDim2.new(1,0,0,59)
   if item.id=="fovPreset" then
    local preset=i==1 and 70 or i==2 and 90 or 60
    fov(preset)
    status("FOV preset: "..preset)
   end
  end,true)
 end
 bind(drop.Activated,function()
  optFrame.Visible=not optFrame.Visible
  f.Size=UDim2.new(1,0,0,optFrame.Visible and (61+#values*29) or 59)
  if optFrame.Visible then optFrame.Size=UDim2.new(1,-20,0,#values*29)end
 end,true)
 register(section,f,item.label)
end
local function card(which,definition)
 local host=which=="right" and right or left
 local c=create("Frame",host,{BackgroundColor3=A.card,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
 corner(c,9);outline(c,A.border,.65)
 local lay=create("UIListLayout",c,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,0)})
 local title=button(c,"",{BackgroundColor3=A.card,Size=UDim2.new(1,0,0,49)})
 corner(title,9)
 -- Compact, uniform card title: proper white outline icon, no big cyan tiles.
 artwork(title,"module",16,15,18,18,A.muted)
 label(title,definition.title,12,A.white,true,{
  Position=UDim2.fromOffset(42,10),Size=UDim2.new(1,-82,0,28)})
 local arrow=artwork(title,"chevron",0,0,16,16,A.muted)
 arrow.Position=UDim2.new(1,-30,0,16)
local inside=create("Frame",c,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
  AutomaticSize=Enum.AutomaticSize.Y,Visible=true})
 create("UIPadding",inside,{PaddingLeft=UDim.new(0,8),
  PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,9),
  PaddingTop=UDim.new(0,2)})
 create("UIListLayout",inside,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,6)})
 local record={card=c,title=string.lower(definition.title.." "..(definition.subtitle or "")),
  items={},body=inside}
 table.insert(filterRecords,record)
 bind(title.Activated,function()
  inside.Visible=not inside.Visible
  arrow.Rotation=inside.Visible and 0 or 180
 end,true)
 for _,item in ipairs(definition.items or {}) do
  if item.type=="info" then controlInfo(inside,record,item)
  elseif item.type=="toggle" then controlToggle(inside,record,item)
  elseif item.type=="slider" then controlSlider(inside,record,item)
  elseif item.type=="dropdown" then controlDrop(inside,record,item)
  elseif item.type=="button" then controlButton(inside,record,item)
  end
 end
 return c
end
local function applySearch()
 if not search or not search.Parent then return end
 local query=string.lower(search.Text or ""):match("^%s*(.-)%s*$")
 for _,g in ipairs(filterRecords) do
  local heading=query=="" or g.title:find(query,1,true)~=nil
  local matching=false
  for _,item in ipairs(g.items) do
   local show=heading or item.text:find(query,1,true)~=nil
   item.ui.Visible=show
   if show then matching=true end
  end
  g.card.Visible=heading or matching
  if query~="" and g.card.Visible then g.body.Visible=true end
 end
 canvasHeight()
end
bind(search:GetPropertyChangedSignal("Text"),applySearch)
render=function()
 if closed then return end
 clearCards()
 local count=0
 for _,def in ipairs(allSections) do
  if def.tab==current then
   count=count+1
   card(def.column,def)
  end
 end
 if current=="About" then
  count=count+1
  card("left",{title="Vision Hub V1",subtitle="Modules et design",items={
   {type="info",label="Version",value="1.0"},
   {type="info",label="UI Theme",value="Sena-inspired"},
   {type="info",label="Key Screen",value="Reverb-inspired"},
   {type="info",label="Game Profile",value="@profile"},
   {type="button",id="copyPlace",label="Copy Game ID"}
  }})
  card("right",{title="Modules",subtitle="Dossiers séparés",items={
   {type="info",label="Detected",value=selected.id},
   {type="info",label="Universal",value="games/universal.lua"},
   {type="info",label="Game-specific",value="games/"..profileId..".lua"},
   {type="info",label="Real Auto Farm",value="Not configured"}
  }})
 end
 if count==0 then
  card("left",{title="No specialized module",subtitle="Game profile in development",items={
   {type="info",label="Game",value="@game"},
   {type="info",label="Detected profile",value="@profile"},
   {type="info",label="Place ID",value="@place"},
   {type="button",id="copyPlace",label="Copy Place ID"}
  }})
 end
 applySearch();canvasHeight()
end
-- True icon artwork from the open LucideBlox Roblox asset map.
local function navIcon(parent,name)
 local target={Overview="overview",Game="game",Player="player",
  Visuals="visuals",Settings="settings",About="about"}
 return artwork(parent,target[name] or "menu",15,10,19,19,A.light)
end

local tabs={"Overview","Game","Player","Visuals","Settings","About"}
local tabLabels={Overview="Overview",Game="Game",Player="Player",
 Visuals="Visuals",Settings="Paramètres",About="About"}
local function goPage(name)
 current=name
 pageTitle.Text=tabLabels[name] or name
 pageDescription.Text=name=="Game" and selected.description or
  (name=="Overview" and "Session overview & quick controls" or
  (name=="About" and "Community / project information" or
  (name=="Settings" and "Interface preferences" or
  (name=="Visuals" and "Visual & display options" or "Player preferences"))))
 search.Text=""
 for n,b in pairs(navButtons)do
  local chosen=n==name
  b.BackgroundColor3=chosen and A.field or A.side
  local textLabel=b:FindFirstChild("NavTitle")
  if textLabel then textLabel.TextColor3=chosen and A.white or A.muted end
  local bar=b:FindFirstChild("Selected")
  if bar then bar.BackgroundTransparency=chosen and 0 or 1 end
 end
 render()
end
for i,name in ipairs(tabs) do
 local tabName=name
 local b=button(nav,"",{BackgroundColor3=A.side,
  Size=UDim2.new(1,0,0,39),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left})
 corner(b,9)
 create("Frame",b,{Name="Selected",BackgroundColor3=A.cyan,BackgroundTransparency=1,
  BorderSizePixel=0,Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(3,23)})
 navIcon(b,name)
 label(b,tabLabels[name] or name,12,A.muted,true,{
  Name="NavTitle",Position=UDim2.fromOffset(47,7),
  Size=UDim2.new(1,-50,0,25)
 })
 navButtons[name]=b
 bind(b.MouseEnter,function()
  if current~=tabName then b.BackgroundColor3=A.field end
 end)
 bind(b.MouseLeave,function()
  if current~=tabName then b.BackgroundColor3=A.side end
 end)
 bind(b.Activated,function()goPage(tabName)end)
end
goPage("Overview")
fitToScreen()
bind(player.CharacterAdded,function(ch)
 task.defer(function()
  if closed then return end
  local h=ch:WaitForChild("Humanoid",7)
  if not h or closed then return end
  if nums.speed~=16 then speed(nums.speed)end
  if nums.jump~=50 then jump(nums.jump)end
 end)
end)
bind(Run.Heartbeat,function(dt)
 if closed then return end
 fpsElapsed=fpsElapsed+dt;frames=frames+1;updateElapsed=updateElapsed+dt
 if fpsElapsed>.7 then fps=math.floor(frames/fpsElapsed+.5);frames=0;fpsElapsed=0 end
 if updateElapsed>.45 then
  updateElapsed=0
  for _,item in ipairs(liveLabels) do
   if item.target.Parent then item.target.Text=readValue(item.id)end
  end
  footerFps.Text=tostring(fps).." FPS"
  local parts={}
  if stored.fps then table.insert(parts,"FPS "..fps)end
  if stored.ping then table.insert(parts,"PING "..readValue("@ping"))end
  if stored.players then table.insert(parts,"PLAYERS "..#Players:GetPlayers())end
  if stored.xyz then table.insert(parts,"XYZ "..pos())end
  overlay.Visible=#parts>0
  overlayText.Text=table.concat(parts,"  •  ")
 end
end)

-- REVERB-INSPIRED KEY PANEL: blue/cyan border, status-log left, key controls right.
local gateShade=create("Frame",gui,{Name="GateShade",BackgroundColor3=Color3.new(0,0,0),
 BackgroundTransparency=.34,BorderSizePixel=0,Size=UDim2.fromScale(1,1)})
local keyPanel=create("Frame",gateShade,{Name="KeySystem",
 BackgroundColor3=Color3.fromRGB(5,12,20),BorderSizePixel=0,
 Size=UDim2.fromOffset(662,438),
 AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5)})
corner(keyPanel,18);outline(keyPanel,Color3.fromRGB(37,159,192),.9)
local gateScale=create("UIScale",keyPanel,{Scale=1})
create("UIGradient",keyPanel,{Rotation=100,Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(7,19,29)),
 ColorSequenceKeypoint.new(.55,Color3.fromRGB(5,10,18)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(5,13,20))})})
-- upper cyan accent and top brand
-- Shared cyan V insignia, with subtle ring, in both hub and access screen.
local keyAccent=create("Frame",keyPanel,{BackgroundColor3=A.cyan,BorderSizePixel=0,
 Position=UDim2.fromOffset(15,17),Size=UDim2.fromOffset(3,39)})
corner(keyAccent,2)
monogram(keyPanel,26,14,42)
label(keyPanel,"VISION",19,A.white,true,{
 Position=UDim2.fromOffset(84,13),Size=UDim2.fromOffset(90,28)})
label(keyPanel,"HUB",19,A.cyan,true,{
 Position=UDim2.fromOffset(190,13),Size=UDim2.fromOffset(56,28)})
label(keyPanel,"SYSTÈME DE CLÉS",10,A.muted,true,{
 Position=UDim2.fromOffset(85,41),Size=UDim2.fromOffset(180,18)})
label(keyPanel,"ACCESS PANEL  ·  V1",10,A.muted,true,{
 Position=UDim2.new(1,-198,0,19),Size=UDim2.fromOffset(151,24),
 TextXAlignment=Enum.TextXAlignment.Right})
local exitGate=button(keyPanel,"×",{
 Position=UDim2.new(1,-44,0,14),Size=UDim2.fromOffset(29,29),
 BackgroundColor3=A.field,TextSize=15})
corner(exitGate,9);outline(exitGate,A.border,.7)
create("Frame",keyPanel,{BackgroundColor3=A.cyan,BorderSizePixel=0,
 Position=UDim2.fromOffset(17,70),Size=UDim2.new(1,-34,0,1)})

-- left: loader log (status rail) like Reverb.
local logPanel=create("Frame",keyPanel,{BackgroundColor3=Color3.fromRGB(7,17,23),
 BorderSizePixel=0,Position=UDim2.fromOffset(17,85),
 Size=UDim2.fromOffset(199,309)})
corner(logPanel,12);outline(logPanel,Color3.fromRGB(33,80,98),.8)
artwork(logPanel,"menu",12,14,16,16,A.cyan)
label(logPanel,"LOADER LOG",11,A.cyan,true,{
 Position=UDim2.fromOffset(35,11),Size=UDim2.fromOffset(148,22)})
create("Frame",logPanel,{BackgroundColor3=Color3.fromRGB(24,65,79),
 BorderSizePixel=0,Position=UDim2.fromOffset(12,42),
 Size=UDim2.new(1,-24,0,1)})
local logs=create("Frame",logPanel,{BackgroundTransparency=1,
 Position=UDim2.fromOffset(12,54),Size=UDim2.new(1,-24,0,216)})
create("UIListLayout",logs,{SortOrder=Enum.SortOrder.LayoutOrder,
 Padding=UDim.new(0,7)})
local logEntries={}
local function log(message)
 if closed or not logs.Parent then return end
 table.insert(logEntries,"> "..tostring(message))
 if #logEntries>9 then table.remove(logEntries,1)end
 for _,x in ipairs(logs:GetChildren())do
  if x:IsA("TextLabel") then x:Destroy()end
 end
 for idx,msg in ipairs(logEntries)do
  label(logs,msg,10,idx==#logEntries and A.cyan or
   Color3.fromRGB(105,158,162),false,{
   Size=UDim2.new(1,0,0,15),TextTruncate=Enum.TextTruncate.AtEnd,
   LayoutOrder=idx
  })
 end
end
label(logPanel,"●  "..(configured() and "SERVICE CONNECTED" or "DEVELOPMENT MODE"),9,A.good,true,{
 Position=UDim2.new(0,13,1,-30),Size=UDim2.new(1,-26,0,19)})
-- right-side credentials and action buttons.
local rightGate=create("Frame",keyPanel,{BackgroundTransparency=1,
 Position=UDim2.fromOffset(232,88),Size=UDim2.fromOffset(415,307)})
label(rightGate,"VISION ACCESS",16,A.white,true,{
 Position=UDim2.fromOffset(5,1),Size=UDim2.fromOffset(385,28)})
label(rightGate,"One key · all game profiles",10,A.muted,false,{
 Position=UDim2.fromOffset(5,34),Size=UDim2.fromOffset(388,19)})
local entry=create("TextBox",rightGate,{BackgroundColor3=Color3.fromRGB(9,20,28),
 BorderSizePixel=0,Text="",ClearTextOnFocus=false,
 PlaceholderText="Enter your access key...",TextColor3=A.white,
 PlaceholderColor3=A.muted,Font=Enum.Font.Gotham,TextSize=12,
 TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(5,68),
 Size=UDim2.fromOffset(399,43)})
corner(entry,10);outline(entry,Color3.fromRGB(44,91,110),.8)
-- TextBox placeholder in Roblox can overlap child icons on some executors.
-- Keep the access field clean; only the left padding is applied.
create("UIPadding",entry,{PaddingLeft=UDim.new(0,16)})
bind(entry.Focused,function()
 local edge=entry:FindFirstChildOfClass("UIStroke")
 if edge then edge.Color=A.cyan end
end)
bind(entry.FocusLost,function()
 local edge=entry:FindFirstChildOfClass("UIStroke")
 if edge then edge.Color=Color3.fromRGB(44,91,110)end
end)
local localStatus=label(rightGate,"Ready to verify",10,A.light,false,{
 Position=UDim2.fromOffset(7,120),Size=UDim2.fromOffset(390,20)})
local enterButton=button(rightGate,"CONTINUE",{
 Position=UDim2.fromOffset(5,153),Size=UDim2.fromOffset(399,44),
 BackgroundColor3=Color3.fromRGB(13,46,65),Font=Enum.Font.GothamBold,TextSize=12})
corner(enterButton,10);outline(enterButton,Color3.fromRGB(43,111,138),.8)
local generateButton=button(rightGate,"GET FREE KEY",{
 Position=UDim2.fromOffset(5,209),Size=UDim2.fromOffset(399,44),
 BackgroundColor3=Color3.fromRGB(15,55,76),Font=Enum.Font.GothamBold,TextSize=12})
corner(generateButton,10);outline(generateButton,Color3.fromRGB(45,119,148),.8)
-- High-contrast blue CTA. Gradients attached to TextButtons also tint the text;
-- solid fill is deliberate so the label remains readable.
local helpButton=button(rightGate,"HELP / SUPPORT",{
 Position=UDim2.fromOffset(5,265),Size=UDim2.fromOffset(399,44),
 BackgroundColor3=Color3.fromRGB(10,158,217),Font=Enum.Font.GothamBold,
 TextColor3=Color3.fromRGB(246,251,255),TextSize=12})
corner(helpButton,10)
outline(helpButton,Color3.fromRGB(32,201,242),.9)
create("Frame",keyPanel,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(0,17,1,-35),Size=UDim2.new(1,-34,0,1)})
label(keyPanel,"●  "..(configured() and "KEY SERVER CONFIGURED" or "LOCAL TEST MODE").."  •  V1",9,A.good,true,{
 Position=UDim2.new(0,20,1,-30),Size=UDim2.fromOffset(360,21)})
label(keyPanel,"PC  /  MOBILE",9,A.muted,true,{
 Position=UDim2.new(1,-146,1,-30),Size=UDim2.fromOffset(124,21),
 TextXAlignment=Enum.TextXAlignment.Right})

local checking=false
local function message(str,errorFlag)
 localStatus.Text=tostring(str)
 localStatus.TextColor3=errorFlag and Color3.fromRGB(244,110,135) or A.light
 log(str)
end
local function validate()
 if checking or closed then return end
 local key=(entry.Text or ""):match("^%s*(.-)%s*$"):upper()
 if key=="" then message("Enter a valid key",true);return end
 checking=true;enterButton.Text="VERIFYING..."
 message("Checking access key...",false)
 local ok,msg
 if key==TEST_KEY then
  ok,msg=true,"Development access granted"
 else
  ok,msg=verifyKeyRemote(key)
 end
 checking=false
 if closed then return end
 enterButton.Text="CONTINUE"
 if ok then
  message(msg,false)
  unlocked=true
  gateShade:Destroy()
  openApp(true)
  status("Profile: "..selected.name.."  •  "..msg)
 else
  message(msg,true)
 end
end
bind(enterButton.Activated,validate)
bind(entry.FocusLost,function(enterPressed)
 if enterPressed then validate()end
end)
bind(generateButton.Activated,function()
 if configured() then
  local url=KEY_API:gsub("/+$","").."/key"
  if clipboard(url) then
   message("Key page copied. Open your browser.",false)
  else
   message("Open your Cloudflare /key page.",true)
  end
 else
  entry.Text=TEST_KEY
  message("Test key ready. Press CONTINUE.",false)
 end
end)
bind(helpButton.Activated,function()
 local url="https://github.com/Azerty56123/vision-pro"
 message(clipboard(url) and "Support GitHub link copied." or
  "Support: Vision Hub GitHub repository.",false)
end)
bind(exitGate.Activated,kill)
log("Vision loader initialized")
log("Profile: "..selected.name)
log("Place: "..tostring(game.PlaceId))
log("Modules: "..tostring(#allSections))
log(configured() and "Cloudflare service configured" or "Development key mode")

-- Handle new screen sizes and camera replacements.
local cameraConnection
local function updateCamera()
 if cameraConnection then cameraConnection:Disconnect()end
 local cam=workspace.CurrentCamera
 if cam then
  cameraConnection=bind(cam:GetPropertyChangedSignal("ViewportSize"),function()
   fitToScreen()
   if gateShade.Parent then
    local v=cam.ViewportSize
    gateScale.Scale=math.clamp(math.min(1,(v.X-16)/662,(v.Y-16)/438),.28,1)
   end
  end)
  local v=cam.ViewportSize
  gateScale.Scale=math.clamp(math.min(1,(v.X-16)/662,(v.Y-16)/438),.28,1)
 end
 fitToScreen()
end
bind(workspace:GetPropertyChangedSignal("CurrentCamera"),updateCamera)
updateCamera()
