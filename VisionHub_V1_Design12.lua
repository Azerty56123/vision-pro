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
text(top,"Community",20,C.white,true,{
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
mini=button(gui,"◆ Vision",{Position=UDim2.new(1,-140,.5,-16),
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
  search.Position=UDim2.new(1,-218,0,18)
  search.Size=UDim2.fromOffset(127,27)
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
 text(head,title,13,C.white,true,{Position=UDim2.fromOffset(16,5),
  Size=UDim2.new(1,-58,0,35)})
 local arrow=text(head,expanded==false and "⌄" or "⌃",18,C.muted,true,{
  Position=UDim2.new(1,-35,0,8),Size=UDim2.fromOffset(22,27),
  TextXAlignment=Enum.TextXAlignment.Center})
 local body=obj("Frame",{BackgroundTransparency=1,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
  Visible=expanded~=false},card)
 obj("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
  PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,9)},body)
 obj("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,5)},body)
 local group={frame=card,body=body,collapsed=expanded==false,
  title=string.lower(title.." "..(description or "")),items={}}
 table.insert(sections,group)
 listen(head.Activated,function()
  group.collapsed=not group.collapsed
  body.Visible=not group.collapsed
  arrow.Text=group.collapsed and "⌄" or "⌃"
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
 local b=button(to,"◆    "..name,{BackgroundColor3=accent and C.accent or C.row,
  Size=UDim2.new(1,0,0,35),TextXAlignment=Enum.TextXAlignment.Left})
 obj("UIPadding",{PaddingLeft=UDim.new(0,12)},b)
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
 for _,g in ipairs(sections) do
  local titleMatch=q=="" or g.title:find(q,1,true)~=nil
  local any=false
  for _,v in ipairs(g.items) do
   local display=titleMatch or v.name:find(q,1,true)~=nil
   v.ui.Visible=display;if display then any=true end
  end
  g.frame.Visible=titleMatch or any
  if not g.runtime then
   g.body.Visible=(q~="" and (titleMatch or any)) or
    (q=="" and not g.collapsed)
  end
 end
end
listen(search:GetPropertyChangedSignal("Text"),filter)
local function clear()
 for _,c in ipairs(pages) do pcall(function()c:Disconnect()end)end
 table.clear(pages)
 sections={};live={}
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
 filter()
end
local tabs={{"Accueil","⌂"},{"Automatisation","⚡"},{"Téléportation","◇"},
 {"Joueur","♙"},{"Visuels","◉"},{"Scripts","▤"},{"Paramètres","⚙"},{"Crédits","☆"}}
go=function(name)
 shown=name;heading.Text=name;subheading.Text="Vision Hub · "..name;search.Text=""
 for title,b in pairs(navButtons) do
  b.BackgroundColor3=title==name and C.accent or C.rail
 end
 render()
end
for i,pair in ipairs(tabs) do
 local tab=pair[1]
 local b=button(nav,pair[2].."   "..tab,{BackgroundColor3=C.rail,
  Size=UDim2.new(1,0,0,35),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left})
 obj("UIPadding",{PaddingLeft=UDim.new(0,12)},b)
 navButtons[tab]=b
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

-- KEY SYSTEM FYY COLORS
local blocker=obj("Frame",{BackgroundColor3=Color3.new(0,0,0),
 BackgroundTransparency=.38,BorderSizePixel=0,Size=UDim2.fromScale(1,1)},gui)
local keyBox=obj("Frame",{BackgroundColor3=C.rail,BorderSizePixel=0,
 AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
 Size=UDim2.fromOffset(398,292)},blocker)
round(keyBox,14);stroke(keyBox,C.border,1)
local keyScale=obj("UIScale",{Scale=1},keyBox)
obj("Frame",{BackgroundColor3=C.purple,BorderSizePixel=0,
 Size=UDim2.new(1,0,0,3)},keyBox)
text(keyBox,"◆",25,C.purple,true,{Position=UDim2.fromOffset(20,14),Size=UDim2.fromOffset(31,36)})
text(keyBox,"VISION HUB",19,C.white,true,{Position=UDim2.fromOffset(60,14),
 Size=UDim2.fromOffset(240,29)})
text(keyBox,"KEY SYSTEM  ·  V1",10,C.muted,false,{Position=UDim2.fromOffset(60,43),
 Size=UDim2.fromOffset(240,18)})
local x=button(keyBox,"×",{Position=UDim2.new(1,-38,0,15),Size=UDim2.fromOffset(22,22)})
text(keyBox,"Entrez votre cle",12,C.white,true,{Position=UDim2.fromOffset(22,77),
 Size=UDim2.fromOffset(250,24)})
local keyInput=obj("TextBox",{BackgroundColor3=C.panel,BorderSizePixel=0,
 Position=UDim2.fromOffset(22,105),Size=UDim2.fromOffset(354,39),
 Text="",ClearTextOnFocus=false,PlaceholderText="Coller votre cle...",
 TextColor3=C.white,PlaceholderColor3=C.muted,Font=Enum.Font.Gotham,
 TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},keyBox)
round(keyInput,8);stroke(keyInput,C.border,.8)
obj("UIPadding",{PaddingLeft=UDim.new(0,12)},keyInput)
local getKey=button(keyBox,"GET KEY",{Position=UDim2.fromOffset(22,156),
 Size=UDim2.fromOffset(170,35),BackgroundColor3=C.accent})
local how=button(keyBox,"HOW TO GET KEY",{Position=UDim2.fromOffset(204,156),
 Size=UDim2.fromOffset(172,35)})
local submit=button(keyBox,"SUBMIT KEY",{Position=UDim2.fromOffset(22,201),
 Size=UDim2.fromOffset(354,37),BackgroundColor3=C.accent})
stroke(submit,C.purple,1)
local keyMessage=text(keyBox,"●  Mode test disponible",10,C.muted,false,{
 Position=UDim2.fromOffset(22,249),Size=UDim2.fromOffset(354,27),
 TextXAlignment=Enum.TextXAlignment.Center})
local busy=false
local function verify()
 if busy or dead then return end
 local v=(keyInput.Text or ""):match("^%s*(.-)%s*$"):upper()
 if v=="" then keyMessage.Text="●  Entrez une cle.";return end
 busy=true;submit.Text="VERIFYING..."
 local ok,message
 if v==TEST_KEY then ok,message=true,"Cle de test acceptee"
 else ok,message=verifyServer(v)end
 busy=false;submit.Text="SUBMIT KEY"
 if dead then return end
 if ok then unlocked=true;blocker:Destroy();open(true);status(message)
 else keyMessage.Text="●  "..tostring(message);keyMessage.TextColor3=C.purple end
end
listen(submit.Activated,verify)
listen(keyInput.FocusLost,function(enter)if enter then verify()end end)
listen(getKey.Activated,function()
 if configured() then
  local link=KEY_API:gsub("/+$","").."/key"
  keyMessage.Text=copy(link) and "●  Lien du generateur copie." or "●  Ouvrez votre Worker /key."
 else
  keyInput.Text=TEST_KEY
  keyMessage.Text="●  Mode test : cliquez SUBMIT KEY."
 end
end)
listen(how.Activated,function()
 keyMessage.Text=configured() and "●  GET KEY > navigateur > SUBMIT." or "●  TEST : GET KEY > SUBMIT."
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
   keyScale.Scale=math.clamp(math.min(1,(vp.X-14)/398,(vp.Y-14)/292),.3,1)
  end)
  local vp=camera.ViewportSize
  keyScale.Scale=math.clamp(math.min(1,(vp.X-14)/398,(vp.Y-14)/292),.3,1)
 end
 resize()
end
listen(workspace:GetPropertyChangedSignal("CurrentCamera"),cameraResize)
cameraResize()
