-- VISION HUB V1 | FYY COMMUNITY DESIGN 12 - MATTE BLACK/PURPLE
-- Interface noire et violette, modules repliables, PC/mobile.
-- Script UI client avec fonctions locales. Modules par jeu a developper.

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Http=game:GetService("HttpService")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
if not player then return end
local parent=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",12)
if not parent then return end
local NAME="VisionHubV1_Design12"
local TEST_KEY="VISION-TEST-ILLIMITE-2026"
local KEY_API="https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
for _,n in ipairs({NAME,"VisionHubV11_Design12","VisionHubV10","VisionHubV9_Refonte","VisionHubV8_UI"}) do
 local g=parent:FindFirstChild(n)
 if g then g:Destroy() end
end
local C={
bg=Color3.fromRGB(4,4,6),rail=Color3.fromRGB(6,6,8),
panel=Color3.fromRGB(19,19,22),row=Color3.fromRGB(24,23,27),
border=Color3.fromRGB(35,31,42),purple=Color3.fromRGB(145,77,222),
accent=Color3.fromRGB(53,32,77),white=Color3.fromRGB(238,236,244),
muted=Color3.fromRGB(147,146,154),green=Color3.fromRGB(121,188,165)}
local sessions,pages={},{}
local dead,unlocked=false,false
local screenZoom=1
local shown="Accueil"
local effects={fps=false,xyz=false,players=false,ping=false,bright=false,animations=true}
local vals={fov=70,zoom=100,speed=16,jump=50}
local startingLight={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,
FogEnd=Lighting.FogEnd,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient}
local originalFOV
local originalHumanoids=setmetatable({}, {__mode="k"})
local frames,timer,fps=0,0,0
local uiTimer=0
local slots={}
local sections,activeRows={},{}
local emptySearch
local live={}
local frame,scale,rail,nav,navLayout,content,scroll,bodyLayout
local mini,overlay,footer,search,heading,subheading
local navButtons={}
local activeMobile=false
local render,go

local function obj(class,props,to)
 local x=Instance.new(class)
 for k,v in pairs(props or {}) do x[k]=v end
 x.Parent=to
 return x
end
local function round(x,r) obj("UICorner",{CornerRadius=UDim.new(0,r or 4)},x) end
local function stroke(x,col,n) obj("UIStroke",{Color=col or C.border,Thickness=n or 1},x) end
local function text(to,value,size,col,bold,props)
 local p={Text=tostring(value),BackgroundTransparency=1,TextColor3=col or C.white,
 TextSize=size or 12,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
 TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
 TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,22)}
 for k,v in pairs(props or {}) do p[k]=v end
 return obj("TextLabel",p,to)
end
local function button(to,value,props)
 local p={Text=tostring(value),Font=Enum.Font.GothamMedium,
 TextSize=12,TextColor3=C.white,BackgroundColor3=C.row,
 BorderSizePixel=0,AutoButtonColor=true,Size=UDim2.new(1,0,0,35)}
 for k,v in pairs(props or {}) do p[k]=v end
 local x=obj("TextButton",p,to);round(x,4);return x
end

-- Icônes vectorielles créées avec des Frames Roblox, sans assets externes.
-- Les tracés gardent une apparence uniforme semblable aux icônes de Fyy.
local ICON_PATHS={
 Automation={
  {{13,2},{5,13},{11,13},{10,22},{19,10},{13,10},{13,2}}
 },
 Teleport={
  {{12,22},{7,16},{5,11},{6,6},{9,3},{12,2},{16,3},{19,6},{20,11},{17,16},{12,22}},
  {{12,7},{14,8},{15,10},{14,12},{12,13},{10,12},{9,10},{10,8},{12,7}}
 },
 Visual={
  {{2,12},{6,7},{12,5},{18,7},{22,12},{18,17},{12,19},{6,17},{2,12}},
  {{12,9},{14,10},{15,12},{14,14},{12,15},{10,14},{9,12},{10,10},{12,9}}
 },
 Scripts={
  {{12,2},{21,7},{21,17},{12,22},{3,17},{3,7},{12,2}},
  {{3,7},{12,12},{21,7}},
  {{12,12},{12,22}}
 },
 Community={
  {{4,11},{20,11},{20,21},{4,21},{4,11}},
  {{2,7},{22,7},{22,11},{2,11},{2,7}},
  {{12,7},{12,21}},
  {{12,7},{7,6},{6,4},{7,2},{9,2},{12,7}},
  {{12,7},{17,6},{18,4},{17,2},{15,2},{12,7}}
 },
 Overview={{{3,22},{4,17},{7,14},{17,14},{20,17},{21,22}}},
 Player={{{3,22},{4,17},{7,14},{17,14},{20,17},{21,22}}}
}
local function iconStroke(canvas,points)
 for i=2,#points do
  local a,b=points[i-1],points[i]
  local dx,dy=b[1]-a[1],b[2]-a[2]
  local length=math.sqrt(dx*dx+dy*dy)
  if length>0 then
   local edge=obj("Frame",{
    BackgroundColor3=C.white,BorderSizePixel=0,
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromOffset((a[1]+b[1])/2,(a[2]+b[2])/2),
    Size=UDim2.fromOffset(length,2),Rotation=math.deg(math.atan2(dy,dx))
   },canvas)
   round(edge,1)
  end
 end
end
local function drawNavIcon(parent,kind)
 local canvas=obj("Frame",{
  BackgroundTransparency=1,BorderSizePixel=0,
  Position=UDim2.fromOffset(19,10),
  Size=UDim2.fromOffset(24,24)
 },parent)
 if kind=="Overview" or kind=="Player" then
  local head=obj("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
   Position=UDim2.fromOffset(8,2),Size=UDim2.fromOffset(8,9)},canvas)
  round(head,6);stroke(head,C.white,1.8)
 end
 if kind=="Settings" then
  local center=obj("Frame",{
   BackgroundTransparency=1,BorderSizePixel=0,
   Position=UDim2.fromOffset(7,7),Size=UDim2.fromOffset(10,10)
  },canvas)
  round(center,6);stroke(center,C.white,1.8)
  for i=0,7 do
   local angle=(math.pi*2)*i/8
   iconStroke(canvas,{
    {12+math.cos(angle)*7,12+math.sin(angle)*7},
    {12+math.cos(angle)*11,12+math.sin(angle)*11}
   })
  end
 end
 for _,path in ipairs(ICON_PATHS[kind] or {})do
  iconStroke(canvas,path)
 end
 return canvas
end

local function listen(signal,fn,page)
 local con=signal:Connect(fn)
 table.insert(page and pages or sessions,con)
 return con
end
local function getRoot() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end
local function copy(str)
 local fn=setclipboard or toclipboard
 return type(fn)=="function" and pcall(fn,tostring(str)) or false
end
local function configured()
 return KEY_API:match("^https://") and not KEY_API:find("YOUR-SUBDOMAIN",1,true)
end
local function verifyServer(key)
 if not configured() then return false,"Cloudflare non configure" end
 local req=request or http_request or (type(syn)=="table" and syn.request)
   or (type(http)=="table" and http.request)
 if type(req)~="function" then return false,"Requete HTTPS indisponible" end
 local ok,r=pcall(req,{Url=KEY_API:gsub("/+$","").."/api/verify",
 Method="POST",Headers={["Content-Type"]="application/json"},
 Body=Http:JSONEncode({key=key})})
 if not ok or type(r)~="table" then return false,"Serveur inaccessible" end
 local parsed,data=pcall(function()return Http:JSONDecode(r.Body or r.body or "")end)
 if not parsed or type(data)~="table" then return false,"Reponse non valide" end
 return data.ok==true,tostring(data.message or (data.ok and "Cle valide" or "Cle refusee"))
end
local function brightness(on)
 effects.bright=on
 if on then
  Lighting.Brightness=3;Lighting.ClockTime=14;Lighting.FogEnd=1e6
  Lighting.Ambient=Color3.fromRGB(183,178,197)
  Lighting.OutdoorAmbient=Color3.fromRGB(183,178,197)
 else
  for k,v in pairs(startingLight) do pcall(function()Lighting[k]=v end)end
 end
end
local function setSpeed(v)
 vals.speed=v
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then
  if not originalHumanoids[h] then
   originalHumanoids[h]={walk=h.WalkSpeed,jump=h.JumpPower,use=h.UseJumpPower}
  end
  pcall(function()h.WalkSpeed=v end)
 end
end
local function setJump(v)
 vals.jump=v
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then
  if not originalHumanoids[h] then
   originalHumanoids[h]={walk=h.WalkSpeed,jump=h.JumpPower,use=h.UseJumpPower}
  end
  pcall(function()h.UseJumpPower=true;h.JumpPower=v end)
 end
end
local function firstTool()
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 local backpack=player:FindFirstChildOfClass("Backpack")
 local tool=backpack and backpack:FindFirstChildOfClass("Tool")
 if not h or not tool then return false end
 return pcall(function()h:EquipTool(tool)end)
end
local function activateTool()
 local tool=player.Character and player.Character:FindFirstChildOfClass("Tool")
 if not tool then return false end
 return pcall(function()tool:Activate()end)
end
local function setFOV(v)
 vals.fov=v
 local cam=workspace.CurrentCamera
 if cam then
  if not originalFOV then originalFOV=cam.FieldOfView end
  cam.FieldOfView=v
 end
end
local function quit()
 if dead then return end
 dead=true
 if effects.bright then brightness(false)end
 for h,values in pairs(originalHumanoids) do
  if h and h.Parent then pcall(function()
   h.WalkSpeed=values.walk;h.UseJumpPower=values.use;h.JumpPower=values.jump
  end)end
 end
 if originalFOV and workspace.CurrentCamera then pcall(function()
  workspace.CurrentCamera.FieldOfView=originalFOV
 end)end
 for _,con in ipairs(pages)do pcall(function()con:Disconnect()end)end
 for _,con in ipairs(sessions)do pcall(function()con:Disconnect()end)end
 local g=parent:FindFirstChild(NAME)
 if g then g:Destroy()end
end
local gui=obj("ScreenGui",{Name=NAME,ResetOnSpawn=false,DisplayOrder=920,
 ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
listen(gui.Destroying,quit)
local function status(msg)
 if footer and footer.Parent then footer.Text="●  "..tostring(msg) end
end
local function open(show)
 if dead or not unlocked then return end
 frame.Visible=show;mini.Visible=not show
end

-- FENETRE FYY: topbar, navigation et modules accordeon
frame=obj("Frame",{Name="VisionHub",BackgroundColor3=C.bg,BorderSizePixel=0,
 AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
 Size=UDim2.fromOffset(784,527),ClipsDescendants=true,Visible=false},gui)
round(frame,7);stroke(frame,C.border,.8)
scale=obj("UIScale",{Scale=1},frame)
-- Barre de titre basse et mate, soulignement violet fin comme la capture.
local top=obj("Frame",{BackgroundColor3=C.rail,BorderSizePixel=0,
 Size=UDim2.new(1,0,0,65),Active=true},frame)
obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
 Position=UDim2.fromOffset(16,61),Size=UDim2.new(1,-32,0,2)},top)
local logoSymbol=text(top,"Ϝ",33,C.purple,true,{
 Position=UDim2.fromOffset(16,12),Size=UDim2.fromOffset(41,41),
 TextXAlignment=Enum.TextXAlignment.Center})
logoSymbol.Rotation=-10
text(top,"Vision",20,C.purple,true,{
 Position=UDim2.fromOffset(65,14),Size=UDim2.fromOffset(76,34)})
local communityTitle=text(top,"Community",20,C.white,true,{
 Position=UDim2.fromOffset(143,14),Size=UDim2.fromOffset(162,34)})
local minimize=button(top,"−",{Position=UDim2.new(1,-67,0,18),
 Size=UDim2.fromOffset(23,23),BackgroundColor3=C.rail,TextColor3=C.muted})
local exit=button(top,"×",{Position=UDim2.new(1,-37,0,18),
 Size=UDim2.fromOffset(23,23),BackgroundColor3=C.rail,TextColor3=C.muted})
rail=obj("Frame",{BackgroundColor3=C.rail,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,65),Size=UDim2.new(0,208,1,-92)},frame)
nav=obj("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(12,12),Size=UDim2.new(1,-24,1,-25),
 AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),
 ScrollBarThickness=0},rail)
navLayout=obj("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
 Padding=UDim.new(0,5)},nav)
content=obj("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(208,65),Size=UDim2.new(1,-208,1,-92)},frame)
-- La zone principale commence par Runtime, sans grand titre au-dessus.
heading=text(content,"Overview",14,C.white,true,{Visible=false})
subheading=text(content,"",10,C.muted,false,{Visible=false})
search=obj("TextBox",{BackgroundColor3=C.panel,BorderSizePixel=0,
 Position=UDim2.new(1,-259,0,18),Size=UDim2.fromOffset(174,27),
 Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.white,
 PlaceholderColor3=C.muted,PlaceholderText="⌕  Search...",
 ClearTextOnFocus=false,Text="",TextXAlignment=Enum.TextXAlignment.Left},top)
round(search,4);stroke(search,C.border,.5)
obj("UIPadding",{PaddingLeft=UDim.new(0,11)},search)
scroll=obj("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(16,15),Size=UDim2.new(1,-28,1,-17),
 AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),
 ScrollBarThickness=3,ScrollBarImageColor3=C.purple},content)
bodyLayout=obj("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
 Padding=UDim.new(0,7)},scroll)
local footbar=obj("Frame",{BackgroundColor3=C.rail,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-28),Size=UDim2.new(1,0,0,28)},frame)
footer=text(footbar,"●  Hub pret",10,C.green,false,{
 Position=UDim2.fromOffset(15,3),Size=UDim2.new(1,-180,0,22)})
text(footbar,"Vision V1 · Design n°12",9,C.muted,false,{
 Position=UDim2.new(1,-177,0,3),Size=UDim2.fromOffset(164,22),
 TextXAlignment=Enum.TextXAlignment.Right})
mini=button(gui,"Ϝ Vision",{Position=UDim2.new(1,-140,.5,-16),
 Size=UDim2.fromOffset(130,34),BackgroundColor3=C.accent,Visible=false})
stroke(mini,C.purple,1)
listen(minimize.Activated,function()open(false)end)
listen(exit.Activated,quit)
listen(mini.Activated,function()open(true)end)
listen(UIS.InputBegan,function(i,processed)
 if not processed and i.KeyCode==Enum.KeyCode.RightShift
    and not UIS:GetFocusedTextBox() then open(not frame.Visible)end
end)

-- GLISSER PAR LE HAUT UNIQUEMENT
local dragging,start,initial=false,nil,nil
listen(top.InputBegan,function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
  dragging=true;start=i.Position;initial=frame.Position
 end
end)
listen(UIS.InputChanged,function(i)
 if not dragging then return end
 if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
  local d=i.Position-start
  frame.Position=UDim2.new(initial.X.Scale,initial.X.Offset+d.X,initial.Y.Scale,initial.Y.Offset+d.Y)
 end
end)
listen(UIS.InputEnded,function(i)
 if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

local hud=obj("Frame",{BackgroundColor3=C.rail,BackgroundTransparency=.07,BorderSizePixel=0,
 Position=UDim2.new(1,-270,0,10),Size=UDim2.fromOffset(258,37),Visible=false},gui)
round(hud,8);stroke(hud,C.purple,.8)
local hudText=text(hud,"",10,C.white,true,{
 Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center})
local function resize()
 local cam=workspace.CurrentCamera
 local vp=cam and cam.ViewportSize or Vector2.new(1280,720)
 activeMobile=vp.X<665
 if activeMobile then
  frame.Size=UDim2.fromOffset(426,600)
  scale.Scale=math.clamp(math.min(screenZoom,(vp.X-12)/426,(vp.Y-12)/600),.3,1)
  rail.Position=UDim2.fromOffset(0,65);rail.Size=UDim2.new(1,0,0,45)
  nav.Position=UDim2.fromOffset(6,4);nav.Size=UDim2.new(1,-12,0,36)
  nav.ScrollingDirection=Enum.ScrollingDirection.X
  nav.AutomaticCanvasSize=Enum.AutomaticSize.X
  navLayout.FillDirection=Enum.FillDirection.Horizontal
  content.Position=UDim2.fromOffset(0,110)
  content.Size=UDim2.new(1,0,1,-137)
  communityTitle.Visible=false
  search.Position=UDim2.new(1,-219,0,18)
  search.Size=UDim2.fromOffset(131,27)
  scroll.Position=UDim2.fromOffset(10,12)
  scroll.Size=UDim2.new(1,-18,1,-14)
  for _,b in pairs(navButtons)do b.Size=UDim2.fromOffset(110,35)end
 else
  frame.Size=UDim2.fromOffset(784,527)
  scale.Scale=math.clamp(math.min(screenZoom,(vp.X-12)/784,(vp.Y-12)/527),.4,1.15)
  rail.Position=UDim2.fromOffset(0,65);rail.Size=UDim2.new(0,208,1,-92)
  nav.Position=UDim2.fromOffset(12,12);nav.Size=UDim2.new(1,-24,1,-25)
  nav.ScrollingDirection=Enum.ScrollingDirection.Y
  nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
  navLayout.FillDirection=Enum.FillDirection.Vertical
  content.Position=UDim2.fromOffset(208,65)
  content.Size=UDim2.new(1,-208,1,-92)
  communityTitle.Visible=true
  search.Position=UDim2.new(1,-259,0,18)
  search.Size=UDim2.fromOffset(174,27)
  scroll.Position=UDim2.fromOffset(16,15)
  scroll.Size=UDim2.new(1,-28,1,-17)
  for _,b in pairs(navButtons)do b.Size=UDim2.new(1,0,0,44)end
 end
end

-- MODULES REPLIABLES
-- Petits accordéons noirs Fyy : titres seuls, flèche minimaliste.
local function section(title,description,expanded)
 local card=obj("Frame",{BackgroundColor3=C.panel,BorderSizePixel=0,
  Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y},scroll)
 round(card,4)
 obj("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,0)},card)
 local head=button(card,"",{Size=UDim2.new(1,0,0,46),
  BackgroundColor3=C.panel})
 local indicator=obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
  BackgroundTransparency=expanded==false and 1 or 0,
  Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(3,30)},head)
 round(indicator,1)
 text(head,title,13,C.white,true,{Position=UDim2.fromOffset(16,5),
  Size=UDim2.new(1,-58,0,35)})
 local arrow=text(head,"⌄",18,C.muted,true,{
  Position=UDim2.new(1,-35,0,8),Size=UDim2.fromOffset(22,27),
  TextXAlignment=Enum.TextXAlignment.Center,
  Rotation=expanded==false and 0 or 180})
 local body=obj("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
  Visible=expanded~=false},card)
 obj("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
  PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,9)},body)
 obj("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,5)},body)
 local group={frame=card,body=body,collapsed=expanded==false,
  title=string.lower(title.." "..(description or "")),items={},
  arrow=arrow,indicator=indicator}
 table.insert(sections,group)
 listen(head.MouseEnter,function()
  head.BackgroundColor3=C.row
  arrow.TextColor3=C.purple
 end,true)
 listen(head.MouseLeave,function()
  head.BackgroundColor3=C.panel
  arrow.TextColor3=C.muted
 end,true)
 listen(head.Activated,function()
  group.collapsed=not group.collapsed
  body.Visible=not group.collapsed
  local rotation=group.collapsed and 0 or 180
  if effects.animations then
   Tween:Create(arrow,TweenInfo.new(.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
    {Rotation=rotation}):Play()
  else arrow.Rotation=rotation end
  indicator.BackgroundTransparency=group.collapsed and 1 or 0
 end,true)
 return body,group
end
-- Panneau Runtime, colonne violette et mesures compactes : motif central du design 12.
local function runtimePanel(title)
 local card=obj("Frame",{BackgroundColor3=C.panel,BorderSizePixel=0,
  Size=UDim2.new(1,-4,0,186)},scroll)
 round(card,4)
 obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
  Position=UDim2.fromOffset(13,13),Size=UDim2.fromOffset(4,157)},card)
 text(card,title or "Vision Runtime",15,C.white,true,{
  Position=UDim2.fromOffset(29,12),Size=UDim2.new(1,-55,0,25)})
 local records={}
 local function metric(name,val,liveKey,row)
  text(card,name..":",11,C.muted,false,{
   Position=UDim2.fromOffset(29,43+(row-1)*24),Size=UDim2.fromOffset(133,21)})
  local value=text(card,val,11,C.muted,false,{
   Position=UDim2.fromOffset(150,43+(row-1)*24),Size=UDim2.new(1,-178,0,21)})
  if liveKey then live[liveKey]=value end
 end
 metric("Game",game.Name,nil,1)
 metric("Players",tostring(#Players:GetPlayers()),"players",2)
 metric("FPS",tostring(fps),"fps",3)
 metric("Ping","...","ping",4)
 text(card,"● IDLE",10,C.purple,true,{
  Position=UDim2.fromOffset(29,145),Size=UDim2.fromOffset(157,20)})
 -- Recherche : la carte ne cache pas d'éléments actionnables.
 table.insert(sections,{frame=card,body=card,collapsed=false,
  title="vision runtime game players fps ping",items=records,runtime=true})
end

local function remember(g,instance,name)
 table.insert(g.items,{ui=instance,name=string.lower(name)})
end
local function cell(to,h)
 local x=obj("Frame",{BackgroundColor3=C.row,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,h)},to)
 round(x,3);return x
end
local function stat(to,g,key,value,liveName)
 local c=cell(to,34)
 text(c,key,11,C.muted,false,{Position=UDim2.fromOffset(10,5),
  Size=UDim2.new(.51,-10,0,23)})
 local v=text(c,tostring(value),11,C.white,true,{Position=UDim2.new(.52,0,0,5),
  Size=UDim2.new(.48,-10,0,23),TextXAlignment=Enum.TextXAlignment.Right})
 if liveName then live[liveName]=v end
 remember(g,c,key)
end
local function action(to,g,name,fn,accent)
 local b=button(to,"  "..name,{BackgroundColor3=accent and C.accent or C.row,
  Size=UDim2.new(1,0,0,36),TextXAlignment=Enum.TextXAlignment.Left})
 obj("UIPadding",{PaddingLeft=UDim.new(0,12)},b)
 if accent then
  obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
   Size=UDim2.fromOffset(3,20),Position=UDim2.fromOffset(0,8)},b)
 end
 listen(b.MouseEnter,function()
  b.BackgroundColor3=accent and Color3.fromRGB(74,46,109) or Color3.fromRGB(39,35,45)
 end,true)
 listen(b.MouseLeave,function()
  b.BackgroundColor3=accent and C.accent or C.row
 end,true)
 listen(b.Activated,function()
  local ok,err=pcall(fn)
  if not ok then status("Erreur: "..tostring(err))end
 end,true)
 remember(g,b,name)
end
local function toggle(to,g,name,detail,key,callback)
 local c=cell(to,51)
 text(c,name,11,C.white,true,{Position=UDim2.fromOffset(11,5),
  Size=UDim2.new(1,-90,0,20)})
 text(c,detail,10,C.muted,false,{Position=UDim2.fromOffset(11,26),
  Size=UDim2.new(1,-90,0,17)})
 local b=button(c,"",{Position=UDim2.new(1,-53,.5,-11),
  Size=UDim2.fromOffset(40,23),BackgroundColor3=effects[key] and C.accent or C.border})
 round(b,11)
 local dot=obj("Frame",{BackgroundColor3=C.white,BorderSizePixel=0,
  Position=UDim2.fromOffset(effects[key] and 20 or 4,4),
  Size=UDim2.fromOffset(15,15)},b)
 round(dot,8)
 listen(b.Activated,function()
  effects[key]=not effects[key]
  local on=effects[key]
  b.BackgroundColor3=on and C.accent or C.border
  local target=UDim2.fromOffset(on and 20 or 4,4)
  if effects.animations then
   Tween:Create(dot,TweenInfo.new(.16),{Position=target}):Play()
  else dot.Position=target end
  if callback then callback(on)end
  status(name.." : "..(on and "ON" or "OFF"))
 end,true)
 remember(g,c,name.." "..detail)
end
local function slider(to,g,name,key,lo,hi,fn)
 local c=cell(to,65)
 text(c,name,11,C.white,true,{Position=UDim2.fromOffset(10,4),
  Size=UDim2.new(1,-85,0,23)})
 local n=text(c,tostring(vals[key]),11,C.purple,true,{
  Position=UDim2.new(1,-72,0,4),Size=UDim2.fromOffset(60,23),
  TextXAlignment=Enum.TextXAlignment.Right})
 local t=obj("Frame",{BackgroundColor3=C.accent,BorderSizePixel=0,
  Position=UDim2.new(0,12,0,42),Size=UDim2.new(1,-24,0,6)},c)
 round(t,4)
 local f=obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
  Size=UDim2.fromScale((vals[key]-lo)/(hi-lo),1)},t)
 round(f,4)
 local hit=button(c,"",{BackgroundTransparency=1,Position=UDim2.new(0,11,0,34),
  Size=UDim2.new(1,-22,0,22)})
 local holding=false
 local function set(x)
  local a=math.clamp((x-t.AbsolutePosition.X)/math.max(t.AbsoluteSize.X,1),0,1)
  local v=math.floor(lo+(hi-lo)*a+.5)
  if v~=vals[key] then
   vals[key]=v;n.Text=tostring(v);f.Size=UDim2.fromScale((v-lo)/(hi-lo),1)
   fn(v)
  end
 end
 listen(hit.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
   holding=true;set(i.Position.X)
  end
 end,true)
 listen(UIS.InputChanged,function(i)
  if holding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   set(i.Position.X)
  end
 end,true)
 listen(UIS.InputEnded,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then holding=false end
 end,true)
 remember(g,c,name)
end
local function filter()
 local q=string.lower(search.Text or ""):match("^%s*(.-)%s*$")
 local foundAny=false
 for _,g in ipairs(sections) do
  local titleMatch=q=="" or g.title:find(q,1,true)~=nil
  local any=false
  for _,v in ipairs(g.items) do
   local display=titleMatch or v.name:find(q,1,true)~=nil
   v.ui.Visible=display
   if display then any=true end
  end
  g.frame.Visible=titleMatch or any
  if g.frame.Visible then foundAny=true end
  if not g.runtime then
   g.body.Visible=(q~="" and (titleMatch or any)) or
    (q=="" and not g.collapsed)
   if q~="" and g.frame.Visible then
    g.arrow.Rotation=180
    g.indicator.BackgroundTransparency=0
   elseif q=="" then
    g.arrow.Rotation=g.collapsed and 0 or 180
    g.indicator.BackgroundTransparency=g.collapsed and 1 or 0
   end
  end
 end
 if emptySearch and emptySearch.Parent then
  emptySearch.Visible=q~="" and not foundAny
 end
end
listen(search:GetPropertyChangedSignal("Text"),filter)
local function clear()
 for _,c in ipairs(pages) do pcall(function()c:Disconnect()end)end
 table.clear(pages)
 sections={};live={};emptySearch=nil
 for _,c in ipairs(scroll:GetChildren())do
  if not c:IsA("UIListLayout")then c:Destroy()end
 end
 scroll.CanvasPosition=Vector2.new()
end
local function posString()
 local r=getRoot()
 if not r then return "Pas de personnage" end
 local p=r.Position
 return string.format("%.1f, %.1f, %.1f",p.X,p.Y,p.Z)
end
local function copyOrShow(v,name)
 status(copy(v) and name.." copie" or name.." : "..tostring(v))
end
render=function()
 clear()
 local p,g
 if shown=="Accueil" then
  runtimePanel("Vision Runtime")
  p,g=section("Main Features","Réglages principaux",false)
  toggle(p,g,"Afficher FPS","Compteur de performances","fps")
  toggle(p,g,"Fullbright","Luminosité locale","bright",brightness)
  toggle(p,g,"Afficher XYZ","Coordonnées locales","xyz")
  p,g=section("Player Controls","Caméra et mouvements",false)
  slider(p,g,"Camera FOV","fov",50,110,setFOV)
  slider(p,g,"WalkSpeed","speed",8,100,setSpeed)
  slider(p,g,"JumpPower","jump",20,140,setJump)
  p,g=section("Quick Actions","Outils utiles",false)
  action(p,g,"Copier le Place ID",function()copyOrShow(game.PlaceId,"Place ID")end,true)
  action(p,g,"Copier mes coordonnees",function()copyOrShow(posString(),"XYZ")end)
  action(p,g,"Afficher les parametres",function()go("Paramètres")end)
 elseif shown=="Automatisation" then
  p,g=section("Modules","Etat des fonctions",true)
  stat(p,g,"Experience",game.Name)
  stat(p,g,"Auto Farm par jeu","Module manquant")
  stat(p,g,"Place ID",game.PlaceId)
  p,g=section("Outils equipés","Actions manuelles compatibles avec Tools",true)
  action(p,g,"Equiper le premier outil du sac",function()
   status(firstTool() and "Outil equipe" or "Aucun Tool trouve")
  end,true)
  action(p,g,"Activer l'outil equipe une fois",function()
   status(activateTool() and "Activation demandee" or "Aucun outil tenu")
  end)
  p,g=section("Information","Compatibilite",false)
  action(p,g,"Copier ID pour creer un module",function()copyOrShow(game.PlaceId,"Place ID")end,true)
 elseif shown=="Téléportation" then
  p,g=section("Saved Locations","3 emplacements",true)
  for i=1,3 do
   local index=i
   action(p,g,"Sauver position "..index,function()
    local r=getRoot()
    if r then slots[index]=r.CFrame;status("Position enregistree")else status("Pas de personnage")end
   end,true)
   action(p,g,"Revenir position "..index,function()
    if not slots[index] or not player.Character then return status("Position vide")end
    local ok=pcall(function()player.Character:PivotTo(slots[index])end)
    status(ok and "Deplacement local demande" or "Deplacement impossible")
   end)
  end
  p,g=section("Coordonnees","Affichage",false)
  toggle(p,g,"Afficher XYZ","Position a l'ecran","xyz")
  action(p,g,"Copier XYZ",function()copyOrShow(posString(),"XYZ")end)
 elseif shown=="Joueur" then
  p,g=section("Mouvement","Controles locaux du personnage",true)
  slider(p,g,"WalkSpeed","speed",8,100,setSpeed)
  slider(p,g,"JumpPower","jump",20,140,setJump)
  action(p,g,"Remettre vitesse et saut par defaut",function()
   setSpeed(16);setJump(50);render();status("Mouvement restaure")
  end)
  p,g=section("Camera","Reglages du joueur",true)
  slider(p,g,"Champ de vision (FOV)","fov",50,110,setFOV)
  action(p,g,"Revenir au FOV 70",function()setFOV(70);render()end)
  p,g=section("Profil","Statistiques",false)
  stat(p,g,"Pseudo",player.Name)
  stat(p,g,"User ID",player.UserId)
  stat(p,g,"Sante","...","health")
 elseif shown=="Visuels" then
  p,g=section("Eclairage","Options locales",true)
  toggle(p,g,"Fullbright","Eclairage clair","bright",brightness)
  p,g=section("Indicateurs","Affichage en jeu",true)
  toggle(p,g,"Compteur FPS","Images par seconde","fps")
  toggle(p,g,"Coordonnees XYZ","Position du joueur","xyz")
  toggle(p,g,"Nombre de joueurs","Compteur direct","players")
  toggle(p,g,"Afficher ping","Latence reseau","ping")
  p,g=section("Camera","Vue locale",false)
  slider(p,g,"Camera FOV","fov",50,110,setFOV)
 elseif shown=="Scripts" then
  p,g=section("Script Manager","Modules de Vision Hub",true)
  stat(p,g,"Interface","Vision V1")
  stat(p,g,"Place ID",game.PlaceId)
  stat(p,g,"Module du jeu","Non configure")
  action(p,g,"Copier Place ID",function()copyOrShow(game.PlaceId,"Place ID")end)
 elseif shown=="Paramètres" then
  p,g=section("Interface","Preferences de session",true)
  slider(p,g,"Taille du menu (%)","zoom",65,115,function(v)
   screenZoom=v/100;resize()
  end)
  toggle(p,g,"Animations","Transitions douces","animations")
  action(p,g,"Recentrer le menu",function()frame.Position=UDim2.fromScale(.5,.5)end,true)
  action(p,g,"Masquer le menu",function()open(false)end)
  p,g=section("Systeme","Actions",false)
  stat(p,g,"Raccourci","RightShift")
  action(p,g,"Fermer Vision Hub",quit)
 elseif shown=="Crédits" then
  p,g=section("Vision Hub","A propos de la version",true)
  stat(p,g,"Version","1.0")
  stat(p,g,"Design","Fyy Community n°12")
  stat(p,g,"Palette","Noir / Violet")
  action(p,g,"Copier GitHub",function()copyOrShow("https://github.com/Azerty56123/vision-pro","GitHub")end)
 end
 emptySearch=obj("Frame",{BackgroundColor3=C.panel,BorderSizePixel=0,
  Size=UDim2.new(1,-4,0,72),Visible=false},scroll)
 round(emptySearch,4)
 text(emptySearch,"Aucun résultat",13,C.white,true,{
  Position=UDim2.fromOffset(18,10),Size=UDim2.new(1,-36,0,25)})
 text(emptySearch,"Essaie un autre mot-clé.",11,C.muted,false,{
  Position=UDim2.fromOffset(18,36),Size=UDim2.new(1,-36,0,21)})
 filter()
end
-- La barre gauche conserve les fonctions Vision, mais reproduit la présentation
-- Fyy : icônes blanches, noms anglais, sélection sombre et trait violet à gauche.
local tabs={
 {"Accueil","Overview"},
 {"Automatisation","Automation"},
 {"Téléportation","Teleport"},
 {"Joueur","Player"},
 {"Visuels","Visual"},
 {"Scripts","Scripts"},
 {"Paramètres","Settings"},
 {"Crédits","Community"}
}
go=function(name)
 shown=name
 heading.Text=name
 subheading.Text="Vision Hub · "..name
 search.Text=""
 for title,b in pairs(navButtons) do
  local selected=title==name
  b.BackgroundColor3=selected and C.panel or C.rail
  local accentBar=b:FindFirstChild("SelectionBar")
  if accentBar then accentBar.BackgroundTransparency=selected and 0 or 1 end
  local caption=b:FindFirstChild("Caption")
  if caption then caption.TextColor3=selected and C.white or C.muted end
 end
 render()
end
for i,entry in ipairs(tabs) do
 local tab,display=entry[1],entry[2]
 local b=button(nav,"",{BackgroundColor3=C.rail,
  Size=UDim2.new(1,0,0,44),LayoutOrder=i})
 local stripe=obj("Frame",{Name="SelectionBar",BackgroundColor3=C.purple,
  BackgroundTransparency=1,BorderSizePixel=0,
  Position=UDim2.fromOffset(0,5),Size=UDim2.fromOffset(4,34)},b)
 round(stripe,2)
 drawNavIcon(b,display)
 local caption=text(b,display,13,C.muted,true,{
  Name="Caption",Position=UDim2.fromOffset(57,5),
  Size=UDim2.new(1,-61,0,33)
 })
 navButtons[tab]=b
 listen(b.MouseEnter,function()
  if shown~=tab then b.BackgroundColor3=C.panel end
 end)
 listen(b.MouseLeave,function()
  if shown~=tab then b.BackgroundColor3=C.rail end
 end)
 listen(b.Activated,function()go(tab)end)
end
go("Accueil");resize()
listen(player.CharacterAdded,function(char)
 task.defer(function()
  if dead then return end
  local h=char:WaitForChild("Humanoid",8)
  if h and not dead then
   if vals.speed~=16 then setSpeed(vals.speed)end
   if vals.jump~=50 then setJump(vals.jump)end
  end
 end)
end)
listen(Run.Heartbeat,function(dt)
 if dead then return end
 frames=frames+1;timer=timer+dt;uiTimer=uiTimer+dt
 if timer>=.7 then fps=math.floor(frames/timer+.5);frames=0;timer=0 end
 if uiTimer>=.45 then
  uiTimer=0
  if live.players and live.players.Parent then live.players.Text=tostring(#Players:GetPlayers())end
  if live.fps and live.fps.Parent then live.fps.Text=tostring(fps)end
  if live.ping and live.ping.Parent then
   local ok,v=pcall(function()return player:GetNetworkPing()end)
   live.ping.Text=ok and tostring(math.floor(v*1000+.5)).."ms" or "—"
  end
  if live.health and live.health.Parent then
   local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   live.health.Text=h and tostring(math.floor(h.Health)) or "—"
  end
  local out={}
  if effects.fps then table.insert(out,"FPS "..tostring(fps))end
  if effects.xyz then table.insert(out,"XYZ "..posString())end
  if effects.players then table.insert(out,"JOUEURS "..tostring(#Players:GetPlayers()))end
  if effects.ping then
   local ok,v=pcall(function()return player:GetNetworkPing()end)
   table.insert(out,ok and "PING "..tostring(math.floor(v*1000+.5)).."ms" or "PING —")
  end
  hud.Visible=#out>0
  hudText.Text=table.concat(out,"  |  ")
 end
end)

-- KEY SYSTEM V1 : DESIGN 12 / FYY-LIKE / NOIR + VIOLET
-- En test : GET KEY fournit la clé locale. Après déploiement :
-- GET KEY copie le lien Cloudflare /key et SUBMIT vérifie /api/verify.
local blocker=obj("Frame",{
 Name="KeyOverlay",BackgroundColor3=Color3.new(0,0,0),
 BackgroundTransparency=.25,BorderSizePixel=0,Size=UDim2.fromScale(1,1)
},gui)
local keyBox=obj("Frame",{
 Name="VisionAccess",BackgroundColor3=C.rail,BorderSizePixel=0,
 AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
 Size=UDim2.fromOffset(410,346)
},blocker)
round(keyBox,7);stroke(keyBox,C.border,1)
local keyScale=obj("UIScale",{Scale=1},keyBox)

-- En-tête proche de l'interface principale Fyy.
local kTop=obj("Frame",{BackgroundColor3=C.rail,BorderSizePixel=0,
 Size=UDim2.new(1,0,0,70)},keyBox)
text(kTop,"Ϝ",31,C.purple,true,{
 Position=UDim2.fromOffset(20,11),Size=UDim2.fromOffset(40,42),
 TextXAlignment=Enum.TextXAlignment.Center
})
text(kTop,"Vision",19,C.purple,true,{
 Position=UDim2.fromOffset(65,14),Size=UDim2.fromOffset(73,32)
})
text(kTop,"Community",19,C.white,true,{
 Position=UDim2.fromOffset(141,14),Size=UDim2.fromOffset(146,32)
})
text(kTop,"ACCESS",10,C.muted,true,{
 Position=UDim2.new(1,-98,0,23),Size=UDim2.fromOffset(49,16),
 TextXAlignment=Enum.TextXAlignment.Right
})
obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
 Position=UDim2.fromOffset(18,64),Size=UDim2.new(1,-36,0,2)},kTop)
local x=button(kTop,"×",{
 Position=UDim2.new(1,-34,0,18),Size=UDim2.fromOffset(22,23),
 BackgroundColor3=C.rail,TextColor3=C.muted,TextSize=16
})

text(keyBox,"Enter key",14,C.white,true,{
 Position=UDim2.fromOffset(23,82),Size=UDim2.fromOffset(270,25)
})
text(keyBox,"Colle ta clé pour ouvrir Vision Hub.",10,C.muted,false,{
 Position=UDim2.fromOffset(23,106),Size=UDim2.fromOffset(330,20)
})

local keyInput=obj("TextBox",{
 Name="KeyInput",BackgroundColor3=C.panel,BorderSizePixel=0,
 Position=UDim2.fromOffset(23,133),Size=UDim2.fromOffset(364,40),
 ClearTextOnFocus=false,Text="",
 PlaceholderText="ENTER KEY HERE...",
 TextColor3=C.white,PlaceholderColor3=C.muted,
 Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left
},keyBox)
round(keyInput,4);stroke(keyInput,C.border,.8)
obj("UIPadding",{PaddingLeft=UDim.new(0,13)},keyInput)

local getKey=button(keyBox,"GET KEY",{
 Position=UDim2.fromOffset(23,184),Size=UDim2.fromOffset(177,34),
 BackgroundColor3=C.accent,Font=Enum.Font.GothamBold,TextSize=11
})
local how=button(keyBox,"HOW TO GET KEY",{
 Position=UDim2.fromOffset(211,184),Size=UDim2.fromOffset(176,34),
 BackgroundColor3=C.panel,Font=Enum.Font.GothamMedium,TextSize=11
})
stroke(getKey,C.purple,.8);stroke(how,C.border,.7)
local submit=button(keyBox,"SUBMIT KEY",{
 Position=UDim2.fromOffset(23,228),Size=UDim2.fromOffset(364,37),
 BackgroundColor3=C.accent,Font=Enum.Font.GothamBold,TextSize=12
})
stroke(submit,C.purple,1)
obj("UIGradient",{Rotation=90,Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,Color3.fromRGB(81,46,126)),
 ColorSequenceKeypoint.new(1,Color3.fromRGB(50,32,75))
})},submit)

local keyMessage=text(keyBox,"●  "..(configured() and "Service de clés configuré" or "Mode développement actif"),10,C.muted,false,{
 Position=UDim2.fromOffset(23,277),Size=UDim2.fromOffset(364,19),
 TextXAlignment=Enum.TextXAlignment.Center
})
obj("Frame",{BackgroundColor3=C.border,BorderSizePixel=0,
 Position=UDim2.fromOffset(23,304),Size=UDim2.fromOffset(364,1)},keyBox)
text(keyBox,"01 GET KEY     •     02 ENTER KEY     •     03 SUBMIT",10,C.muted,true,{
 Position=UDim2.fromOffset(24,309),Size=UDim2.fromOffset(362,25),
 TextXAlignment=Enum.TextXAlignment.Center
})
local busy=false
local function updateKeyMessage(message,error)
 if dead or not keyMessage.Parent then return end
 keyMessage.Text="●  "..tostring(message)
 keyMessage.TextColor3=error and Color3.fromRGB(238,111,139) or C.muted
end
local function verify()
 if busy or dead then return end
 local value=(keyInput.Text or ""):match("^%s*(.-)%s*$"):upper()
 if value=="" then updateKeyMessage("Entre une clé pour continuer.",true);return end
 busy=true
 submit.Text="VERIFYING..."
 updateKeyMessage("Vérification en cours...",false)
 local ok,message
 if value==TEST_KEY then
  ok,message=true,"Mode test : accès à Vision Hub V1"
 else
  ok,message=verifyServer(value)
 end
 busy=false
 if dead then return end
 submit.Text="SUBMIT KEY"
 if ok then
  unlocked=true
  blocker:Destroy()
  open(true)
  status(message)
 else
  updateKeyMessage(message,true)
 end
end

listen(submit.Activated,verify)
listen(keyInput.FocusLost,function(pressedEnter)
 if pressedEnter then verify() end
end)
listen(getKey.Activated,function()
 if configured() then
  local url=KEY_API:gsub("/+$","").."/key"
  if copy(url) then
   updateKeyMessage("Lien du générateur copié. Ouvre-le dans ton navigateur.",false)
  else
   updateKeyMessage("Copie le lien /key depuis ton navigateur Cloudflare.",true)
  end
 else
  keyInput.Text=TEST_KEY
  updateKeyMessage("Clé TEST insérée : clique sur SUBMIT KEY.",false)
 end
end)
listen(how.Activated,function()
 if configured() then
  updateKeyMessage("GET KEY > navigateur > copie > SUBMIT.",false)
 else
  updateKeyMessage("Version TEST : GET KEY puis SUBMIT KEY.",false)
 end
end)
listen(x.Activated,quit)

local cameraConnection
local function cameraResize()
 if cameraConnection then cameraConnection:Disconnect()end
 local camera=workspace.CurrentCamera
 if camera then
  cameraConnection=listen(camera:GetPropertyChangedSignal("ViewportSize"),function()
   resize()
   local vp=camera.ViewportSize
   keyScale.Scale=math.clamp(math.min(1,(vp.X-14)/410,(vp.Y-14)/346),.3,1)
  end)
  local vp=camera.ViewportSize
  keyScale.Scale=math.clamp(math.min(1,(vp.X-14)/410,(vp.Y-14)/346),.3,1)
 end
 resize()
end
listen(workspace:GetPropertyChangedSignal("CurrentCamera"),cameraResize)
cameraResize()
