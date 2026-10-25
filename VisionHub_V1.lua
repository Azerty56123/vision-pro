--[[ VISION WARE V1 • SENA-INSPIRED MULTI-GAME LOADER
  Original Vision Ware design with Sena-style navigation and direct launch.
  Each supported game profile is defined in a separate games/*.lua file.
  Functional: immediate access, two-column cards,
  navigation, search, toggles, sliders, drop-downs, FPS/ping, local lighting,
  FOV, movement values, copy utilities and user position bookmarks.
  Game modules only declare UI: no undisclosed external execution.
]]
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local Run=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Tween=game:GetService("TweenService")
local TextService=game:GetService("TextService")
local Marketplace=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
if not player then return end
local pg=player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui",10)
if not pg then return end
local NAME="VisionHubV1_Sena"
local BASE="https://raw.githubusercontent.com/Azerty56123/vision-pro/main/"
local GAME_TITLE=game.Name
local okName,placeInfo=pcall(function()
 return Marketplace:GetProductInfo(game.PlaceId,Enum.InfoType.Asset)
end)
if okName and type(placeInfo)=="table" and type(placeInfo.Name)=="string" and placeInfo.Name~="" then
 GAME_TITLE=placeInfo.Name
end
for _,name in ipairs({NAME,"VisionHubV1_Design12","VisionHubV11_Design12","VisionHubV10"}) do
 local old=pg:FindFirstChild(name)
 if old then old:Destroy() end
end

-- Sena reference proportions (screen-measured approximation).
local DESIGN={width=865,height=548,rail=195,header=64,footer=38}
-- Unified professional UI palette with one restrained cyan accent.
local A={
 bg=Color3.fromRGB(11,13,18),side=Color3.fromRGB(15,17,23),
 card=Color3.fromRGB(22,25,32),row=Color3.fromRGB(28,32,40),
 field=Color3.fromRGB(31,36,45),border=Color3.fromRGB(42,47,57),
 white=Color3.fromRGB(242,245,250),muted=Color3.fromRGB(146,153,164),
 cyan=Color3.fromRGB(36,203,240),cyanDark=Color3.fromRGB(14,67,83),
 light=Color3.fromRGB(176,189,204),good=Color3.fromRGB(86,220,163),
 hover=Color3.fromRGB(35,41,51),selected=Color3.fromRGB(28,47,58)
}
local current,closed="Overview",false
local pconns,conns={},{}
local stored={fps=false,ping=false,xyz=false,players=false,bright=false,animations=true,
 antiFling=false,antiVoid=false}
local nums={fov=70,speed=16,jump=50,zoom=100}
local positions={}
local miscCounts={fling=0,void=0}
-- Local protection state. Reset on every new character (never reuse a stale checkpoint).
local protect={
 character=nil,bornAt=0,lastVelocity=nil,lastPosition=nil,
 elapsed=0,stableFor=0,airborneFor=0,safeCFrame=nil,
 safePlatform=nil,safeAt=0,lastSafeGroundY=nil,
 lastFlingAt=0,lastFlingNoticeAt=0,lastRescueAt=0
}
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
-- Consistent subtle easing; disabling Animations in settings is respected.
local function uiTween(object,props,duration)
 if not object or not object.Parent then return end
 if stored.animations then
  local ok=pcall(function()
   Tween:Create(object,TweenInfo.new(duration or .16,
    Enum.EasingStyle.Quad,Enum.EasingDirection.Out),props):Play()
  end)
  if ok then return end
 end
 for key,value in pairs(props) do pcall(function()object[key]=value end)end
end
-- Shared Lucide-style Roblox image assets: no homemade glyphs, no invented IDs.
local ICON={
 overview="rbxassetid://7733970318",game="rbxassetid://7733799795",
 player="rbxassetid://7743875962",visuals="rbxassetid://7733774602",
 settings="rbxassetid://7734058803",about="rbxassetid://7733993369",
 module="rbxassetid://7743869612",chevron="rbxassetid://7733717447",
 search="rbxassetid://7734052925",
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
-- Compact hub-style neon monogram: designed for a 35px sidebar icon.
-- All elements are native Roblox UI; no uploaded image asset is required.
-- VISION WARE: compact, native Roblox UI monogram.
-- Built specifically for the sidebar at 36px, not a scaled-down banner image.
-- Real Vision Ware image (published in this repository).
-- Roblox cannot load a raw HTTP URL directly as ImageLabel.Image.
-- Local asset bridge is used when available, with a clean native fallback.
-- Hand-designed flat brand icon. PNG in assets/visionware_logo.png;
-- the matching editable vector source is assets/visionware_logo.svg.
-- New cache filename is intentional: it prevents using the previous neon icon.
-- Exact VISION WARE logo selected by the user.
-- GitHub stores the optimized PNG; compatible local-asset APIs display it.
-- A new cache filename prevents the earlier flat/neon logos from persisting.
local function loadVisionLogo()
 local getAsset=getcustomasset or getsynasset
 if type(getAsset)~="function" or type(writefile)~="function" then
  return nil
 end
 local file="visionware_exact_logo_v3.png"
 local available=false
 if type(isfile)=="function" then
  local ok,exists=pcall(isfile,file)
  available=ok and exists
 end
 if not available then
  local ok,bytes=pcall(function()
   return game:HttpGet(BASE.."assets/visionware_logo_exact.png")
  end)
  if ok and type(bytes)=="string" and bytes:sub(1,4)=="\137PNG" then
   available=pcall(writefile,file,bytes)
  end
 end
 if available then
  local ok,asset=pcall(getAsset,file)
  if ok and type(asset)=="string" and asset~="" then return asset end
 end
 return nil
end

local visionLogoAsset=loadVisionLogo()
local function monogram(host,x,y,size)
 local holder=create("Frame",host,{
  Name="VisionWareLogo",BackgroundTransparency=1,BorderSizePixel=0,
  Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(size,size)
 })
 if visionLogoAsset then
  -- The PNG already has its own cyan glow and rounded border.
  -- No extra strokes are added, preserving its exact visual proportions.
  create("ImageLabel",holder,{
   Name="BrandLogo",BackgroundTransparency=1,BorderSizePixel=0,
   Image=visionLogoAsset,ScaleType=Enum.ScaleType.Fit,
   Size=UDim2.fromScale(1,1),ZIndex=3
  })
 else
  -- Fallback for Roblox contexts without local image-asset support.
  local fallback=create("Frame",holder,{
   Name="LogoFallback",BackgroundColor3=Color3.fromRGB(10,20,31),
   BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=3
  })
  corner(fallback,9)
  create("UIStroke",fallback,{
   Color=Color3.fromRGB(0,216,240),Thickness=1.2,
   Transparency=.13,ApplyStrokeMode=Enum.ApplyStrokeMode.Border
  })
  label(fallback,"VW",14,Color3.fromRGB(238,250,255),true,{
   Font=Enum.Font.GothamBold,Size=UDim2.fromScale(1,1),
   TextXAlignment=Enum.TextXAlignment.Center,ZIndex=4
  })
 end
 return holder
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
local function interactiveHover(b,normalColor,hoverColor,page)
 bind(b.MouseEnter,function()
  if b.Parent then uiTween(b,{BackgroundColor3=hoverColor},.12)end
 end,page)
 bind(b.MouseLeave,function()
  if b.Parent then uiTween(b,{BackgroundColor3=normalColor},.15)end
 end,page)
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
local miscProfile=fetchProfile("misc")
local selected=profileId~="universal" and fetchProfile(profileId) or universal
selected=selected or {id="universal",name="Universal",description="Basic dashboard",sections={}}
universal=universal or {id="universal",name="Universal",sections={}}
local allSections={}
for _,group in ipairs(universal.sections) do table.insert(allSections,group)end
if miscProfile and type(miscProfile.sections)=="table" then
 for _,group in ipairs(miscProfile.sections) do table.insert(allSections,group)end
end
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
 ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=920,
 AutoLocalize=false})
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
 if key=="@flingBlocks" then return tostring(miscCounts.fling) end
 if key=="@voidRescues" then return tostring(miscCounts.void) end
 if key=="@health" then
  local h=human()
  return h and tostring(math.floor(h.Health)) or "—"
 end
 return tostring(key or "")
end
-- DESIGN SENA: topbar, vertical navigation, two compact columns and bottom status.
app=create("Frame",gui,{Name="MainWindow",BackgroundColor3=A.bg,BorderSizePixel=0,
 Size=UDim2.fromOffset(DESIGN.width,DESIGN.height),Position=UDim2.fromScale(.5,.5),
 AnchorPoint=Vector2.new(.5,.5),ClipsDescendants=true,Visible=true})
corner(app,15);outline(app,A.border,.9)
appScale=create("UIScale",app,{Scale=1})
-- VISION WARE / SENA desktop structure: the logo lives in the sidebar;
-- the main toolbar contains the current category, description and search.
header=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.fromOffset(DESIGN.rail,0),Size=UDim2.new(1,-DESIGN.rail,0,DESIGN.header),Active=true})
create("Frame",header,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)})
create("Frame",header,{BackgroundColor3=A.cyan,BorderSizePixel=0,
 BackgroundTransparency=.55,Position=UDim2.fromOffset(22,0),
 Size=UDim2.fromOffset(34,2)})
local searchHolder=create("Frame",header,{BackgroundColor3=A.card,BorderSizePixel=0,
 Position=UDim2.new(1,-300,0,15),Size=UDim2.fromOffset(210,37)})
corner(searchHolder,8)
local searchEdge=outline(searchHolder,A.border,.8)
artwork(searchHolder,"search",12,10,17,17,A.muted)
search=create("TextBox",searchHolder,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(39,0),Size=UDim2.new(1,-45,1,0),
 Text="",ClearTextOnFocus=false,PlaceholderText="Search controls...",
 Font=Enum.Font.Gotham,TextSize=11,TextColor3=A.white,
 PlaceholderColor3=A.muted,TextXAlignment=Enum.TextXAlignment.Left})
local clearSearch=button(searchHolder,"×",{
 Name="ClearSearch",BackgroundTransparency=1,AutoButtonColor=false,
 Position=UDim2.new(1,-26,0,5),Size=UDim2.fromOffset(22,27),
 TextSize=16,TextColor3=A.muted,Visible=false})
bind(clearSearch.Activated,function()
 search.Text=""
 search:ReleaseFocus()
end)
bind(search.Focused,function()
 uiTween(searchEdge,{Color=A.cyan,Thickness=1.2},.13)
end)
bind(search.FocusLost,function()
 uiTween(searchEdge,{Color=A.border,Thickness=.8},.17)
end)
local hide=button(header,"−",{
 Position=UDim2.new(1,-77,0,17),Size=UDim2.fromOffset(26,27),
 BackgroundColor3=A.side})
local close=button(header,"×",{
 Position=UDim2.new(1,-41,0,17),Size=UDim2.fromOffset(26,27),
 BackgroundColor3=A.side})
corner(hide,7);corner(close,7)
interactiveHover(hide,A.side,A.hover)
interactiveHover(close,A.side,Color3.fromRGB(86,38,45))
tabRail=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,0),Size=UDim2.new(0,DESIGN.rail,1,-DESIGN.footer)})
create("Frame",tabRail,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0)})
local sideBadge=monogram(tabRail,14,15,38)
-- One rich-text label keeps the two-tone wordmark consistently spaced.
local brandName=label(tabRail,'VISION <font color="#20C9ED">WARE</font>',13,A.white,true,{
 Name="VisionWareWordmark",RichText=true,
 Position=UDim2.fromOffset(60,16),Size=UDim2.fromOffset(130,24)})
local titleGame=label(tabRail,selected.name,10,A.muted,false,{
 Position=UDim2.fromOffset(60,38),Size=UDim2.fromOffset(130,17)})
local railTitle=label(tabRail,"WORKSPACE",9,A.muted,true,{
 Position=UDim2.fromOffset(17,82),Size=UDim2.fromOffset(155,14),
 Text="NAVIGATION",Visible=true})
create("Frame",tabRail,{BackgroundColor3=A.border,BorderSizePixel=0,
 Position=UDim2.fromOffset(16,72),Size=UDim2.fromOffset(163,1)})
local sidebarHint=label(tabRail,"RIGHT SHIFT  •  TOGGLE",9,A.muted,false,{
 Position=UDim2.new(0,17,1,-39),Size=UDim2.fromOffset(166,20)})
nav=create("ScrollingFrame",tabRail,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(10,105),Size=UDim2.new(1,-21,1,-165),
 ScrollingDirection=Enum.ScrollingDirection.Y,
 CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,
 ScrollBarThickness=0})
local navLayout=create("UIListLayout",nav,{
 SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,4)})
body=create("Frame",app,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(DESIGN.rail,DESIGN.header),Size=UDim2.new(1,-DESIGN.rail,1,-(DESIGN.header+DESIGN.footer))})
local pageTitle=label(header,"Overview",15,A.white,true,{
 Position=UDim2.fromOffset(22,9),Size=UDim2.fromOffset(340,25)})
local pageDescription=label(header,selected.description,11,A.muted,false,{
 Position=UDim2.fromOffset(22,32),Size=UDim2.fromOffset(340,22)})
canvas=create("ScrollingFrame",body,{BackgroundTransparency=1,BorderSizePixel=0,
 Position=UDim2.fromOffset(15,14),Size=UDim2.new(1,-30,1,-26),
 CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=2,
 ScrollBarImageColor3=A.cyan,ScrollingDirection=Enum.ScrollingDirection.Y})
local noResults=label(canvas,"Nothing found\nTry another search term",11,A.muted,false,{
 Name="EmptySearch",Position=UDim2.new(0,15,0,44),
 Size=UDim2.new(1,-30,0,70),Visible=false,TextWrapped=true,
 TextXAlignment=Enum.TextXAlignment.Center})
columns=create("Frame",canvas,{BackgroundTransparency=1,BorderSizePixel=0,
 Size=UDim2.new(1,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y})
local colLayout=create("UIListLayout",columns,{
 FillDirection=Enum.FillDirection.Horizontal,
 SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,12)})
left=create("Frame",columns,{BackgroundTransparency=1,
 Size=UDim2.new(.5,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1})
right=create("Frame",columns,{BackgroundTransparency=1,
 Size=UDim2.new(.5,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2})
local lLay=create("UIListLayout",left,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,11)})
local rLay=create("UIListLayout",right,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,11)})
local footer=create("Frame",app,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(0,0,1,-DESIGN.footer),Size=UDim2.new(1,0,0,DESIGN.footer)})
corner(footer,15)
-- Straight footer top edge, with rounded bottom corners.
create("Frame",footer,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,15)})
create("Frame",footer,{BackgroundColor3=A.border,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)})
-- Sena-like compact status pills on the footer (behind live labels).
local function footerTag(pos,size)
 local pill=create("Frame",footer,{BackgroundColor3=A.field,BorderSizePixel=0,
  Position=pos,Size=size})
 corner(pill,6)
 create("UIStroke",pill,{Color=A.border,Thickness=.65,Transparency=.5})
 return pill
end
-- Like the real Sena footer: three short pills grouped tightly against
-- the lower-right edge, not oversized fixed-width capsules.
local executorName="Unknown"
if type(identifyexecutor)=="function" then
 local ok,name=pcall(identifyexecutor)
 if ok and type(name)=="string" and name~="" then executorName=name end
end
local executorText="Executor: "..executorName
local okText,textSize=pcall(function()
 return TextService:GetTextSize(executorText,10,Enum.Font.Gotham,Vector2.new(280,26))
end)
local execWidth=math.clamp(math.ceil(okText and textSize.X or #executorText*5.7)+20,98,165)
local badgeGap,badgeEdge=5,10
local versionWidth,fpsWidth=44,74
local fpsRight=badgeEdge+versionWidth+badgeGap
local execRight=fpsRight+fpsWidth+badgeGap
local statusTag=footerTag(UDim2.fromOffset(14,4),UDim2.fromOffset(206,30))
local execTag=footerTag(UDim2.new(1,-(execRight+execWidth),0,4),
 UDim2.fromOffset(execWidth,30))
local fpsTag=footerTag(UDim2.new(1,-(fpsRight+fpsWidth),0,4),
 UDim2.fromOffset(fpsWidth,30))
local versionTag=footerTag(UDim2.new(1,-(badgeEdge+versionWidth),0,4),
 UDim2.fromOffset(versionWidth,30))
footerMessage=label(statusTag,"●  SYSTEM READY",10,A.good,true,{
 Position=UDim2.fromOffset(11,3),Size=UDim2.new(1,-20,1,-6)})
local footerExec=label(execTag,executorText,10,A.muted,false,{
 Position=UDim2.fromOffset(9,3),Size=UDim2.new(1,-18,1,-6),
 TextXAlignment=Enum.TextXAlignment.Center})
footerFps=label(fpsTag,"-- FPS",10,A.muted,true,{
 Position=UDim2.fromOffset(4,3),Size=UDim2.new(1,-8,1,-6),
 TextXAlignment=Enum.TextXAlignment.Center})
label(versionTag,"v1.0",10,A.muted,true,{
 Position=UDim2.fromOffset(3,3),Size=UDim2.new(1,-6,1,-6),
 TextXAlignment=Enum.TextXAlignment.Center})
mini=button(gui,"VISION WARE",{Position=UDim2.new(1,-160,.5,-20),
 Size=UDim2.fromOffset(146,38),BackgroundColor3=A.cyanDark,Visible=false})
corner(mini,11);outline(mini,A.cyan,.8)
overlay=create("Frame",gui,{BackgroundColor3=A.side,BorderSizePixel=0,
 Position=UDim2.new(1,-265,0,10),Size=UDim2.fromOffset(250,35),Visible=false})
corner(overlay,10);outline(overlay,A.cyan,.8)
overlayText=label(overlay,"",10,A.white,true,{
 Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center})
-- Long action feedback is also shown in a discreet temporary toast:
-- the compact 206px footer stays identical to the reference.
local toast=create("Frame",app,{
 Name="StatusToast",BackgroundColor3=A.card,BorderSizePixel=0,
 Position=UDim2.new(1,-330,1,-86),Size=UDim2.fromOffset(316,42),
 Visible=false,ZIndex=9
})
corner(toast,8);outline(toast,A.border,.9)
create("Frame",toast,{BackgroundColor3=A.cyan,BorderSizePixel=0,
 Position=UDim2.fromOffset(0,7),Size=UDim2.fromOffset(2,28),ZIndex=10})
local toastText=label(toast,"",10,A.white,false,{
 Position=UDim2.fromOffset(13,4),Size=UDim2.new(1,-24,1,-8),
 TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=10
})
local toastSequence=0
status=function(message)
 local msg=tostring(message)
 if footerMessage and footerMessage.Parent then footerMessage.Text="●  "..msg end
 toastSequence=toastSequence+1
 if #msg>26 and toast.Parent then
  local seq=toastSequence
  toastText.Text=msg
  toast.Visible=true
  toast.Position=UDim2.new(1,-330,1,-76)
  uiTween(toast,{Position=UDim2.new(1,-330,1,-86)},.19)
  task.delay(3,function()
   if seq==toastSequence and toast.Parent and not closed then toast.Visible=false end
  end)
 else
  toast.Visible=false
 end
end
openApp=function(on)
 if closed then return end
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
 small=v.X<780
 if small then
  app.Size=UDim2.fromOffset(450,650)
  appScale.Scale=math.clamp(math.min(nums.zoom/100,(v.X-12)/450,(v.Y-12)/650),.3,1)
  header.Position=UDim2.fromOffset(0,0);header.Size=UDim2.new(1,0,0,64)
  tabRail.Position=UDim2.fromOffset(0,64);tabRail.Size=UDim2.new(1,0,0,42)
  sideBadge.Visible=false;brandName.Visible=false
  titleGame.Visible=false;railTitle.Visible=false;sidebarHint.Visible=false
  footerExec.Visible=false;execTag.Visible=false
  fpsTag.Visible=true;versionTag.Visible=true
  statusTag.Size=UDim2.fromOffset(185,30)
  footerMessage.Size=UDim2.new(1,-20,1,-6)
  nav.Position=UDim2.fromOffset(7,4);nav.Size=UDim2.new(1,-14,0,36)
  nav.ScrollingDirection=Enum.ScrollingDirection.X
  nav.AutomaticCanvasSize=Enum.AutomaticSize.X
  navLayout.FillDirection=Enum.FillDirection.Horizontal
  body.Position=UDim2.fromOffset(0,106);body.Size=UDim2.new(1,0,1,-(106+DESIGN.footer))
  colLayout.FillDirection=Enum.FillDirection.Vertical
  left.Size=UDim2.new(1,-6,0,0);right.Size=UDim2.new(1,-6,0,0)
  searchHolder.Position=UDim2.new(1,-204,0,16)
  searchHolder.Size=UDim2.fromOffset(126,31)
  pageTitle.Position=UDim2.fromOffset(14,5);pageDescription.Position=UDim2.fromOffset(14,29)
  pageTitle.Size=UDim2.fromOffset(210,24);pageDescription.Size=UDim2.fromOffset(208,22)
  canvas.Position=UDim2.fromOffset(10,11);canvas.Size=UDim2.new(1,-19,1,-16)
  for _,b in pairs(navButtons) do b.Size=UDim2.fromOffset(118,36)end
 else
  app.Size=UDim2.fromOffset(DESIGN.width,DESIGN.height)
  appScale.Scale=math.clamp(math.min(nums.zoom/100,(v.X-14)/DESIGN.width,(v.Y-14)/DESIGN.height),.45,1.15)
  header.Position=UDim2.fromOffset(DESIGN.rail,0);header.Size=UDim2.new(1,-DESIGN.rail,0,DESIGN.header)
  tabRail.Position=UDim2.fromOffset(0,0);tabRail.Size=UDim2.new(0,DESIGN.rail,1,-DESIGN.footer)
  sideBadge.Visible=true;brandName.Visible=true
  titleGame.Visible=true;railTitle.Visible=true;sidebarHint.Visible=true
  footerExec.Visible=true;execTag.Visible=true
  fpsTag.Visible=true;versionTag.Visible=true
  statusTag.Size=UDim2.fromOffset(206,30)
  footerMessage.Size=UDim2.new(1,-20,1,-6)
  nav.Position=UDim2.fromOffset(10,105);nav.Size=UDim2.new(1,-21,1,-165)
  nav.ScrollingDirection=Enum.ScrollingDirection.Y
  nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
  navLayout.FillDirection=Enum.FillDirection.Vertical
  body.Position=UDim2.fromOffset(DESIGN.rail,DESIGN.header);body.Size=UDim2.new(1,-DESIGN.rail,1,-(DESIGN.header+DESIGN.footer))
  colLayout.FillDirection=Enum.FillDirection.Horizontal
  left.Size=UDim2.new(.5,-6,0,0);right.Size=UDim2.new(.5,-6,0,0)
  searchHolder.Position=UDim2.new(1,-300,0,15)
  searchHolder.Size=UDim2.fromOffset(210,37)
  pageTitle.Position=UDim2.fromOffset(22,9);pageDescription.Position=UDim2.fromOffset(22,32)
  pageTitle.Size=UDim2.fromOffset(340,25);pageDescription.Size=UDim2.fromOffset(340,22)
  canvas.Position=UDim2.fromOffset(15,14);canvas.Size=UDim2.new(1,-30,1,-26)
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
 corner(f,7)
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
 local f=row(parent,76)
 label(f,item.label,12,A.white,true,{Position=UDim2.fromOffset(13,13),
  Size=UDim2.new(1,-79,0,21)})
 label(f,item.desc or "",10,A.muted,false,{Position=UDim2.fromOffset(13,37),
  Size=UDim2.new(1,-79,0,26),TextWrapped=true,
  TextYAlignment=Enum.TextYAlignment.Top})
 local b=button(f,"",{Position=UDim2.new(1,-53,0,25),
  Size=UDim2.fromOffset(41,23),AutoButtonColor=false,
  BackgroundColor3=isTrue(item.id) and A.cyanDark or A.border})
 corner(b,12)
 local toggleStroke=outline(b,isTrue(item.id) and A.cyan or A.border,.8)
 bind(b.MouseEnter,function()uiTween(toggleStroke,{Color=A.cyan},.14)end,true)
 bind(b.MouseLeave,function()
  uiTween(toggleStroke,{Color=isTrue(item.id) and A.cyan or A.border},.14)
 end,true)
 local dot=create("Frame",b,{BackgroundColor3=isTrue(item.id) and A.cyan or A.light,
  BorderSizePixel=0,Position=UDim2.fromOffset(isTrue(item.id) and 21 or 4,4),
  Size=UDim2.fromOffset(15,15)})
 corner(dot,8)
 bind(b.Activated,function()
  stored[item.id]=not isTrue(item.id)
  local state=isTrue(item.id)
  uiTween(b,{BackgroundColor3=state and A.cyanDark or A.border},.15)
  uiTween(toggleStroke,{Color=state and A.cyan or A.border},.15)
  uiTween(dot,{BackgroundColor3=state and A.cyan or A.light,
   Position=UDim2.fromOffset(state and 21 or 4,4)},.15)
  if item.id=="bright" then applyBright(state)end
  status(item.label.." : "..(state and "ON" or "OFF"))
 end,true)
 register(section,f,item.label.." "..(item.desc or ""))
end
local function controlSlider(parent,section,item)
 local lo,hi=item.min or 0,item.max or 100
 if hi<=lo then return end
 local id=item.id
 local f=row(parent,88)
 label(f,item.label,12,A.white,true,{Position=UDim2.fromOffset(13,9),
  Size=UDim2.new(1,-80,0,21)})
 local sliderHints={
  speed="Vitesse de déplacement",jump="Puissance du saut",
  fov="Champ de vision",zoom="Taille de l'interface"
 }
 label(f,item.desc or sliderHints[id] or "",9,A.muted,false,{
  Position=UDim2.fromOffset(13,33),Size=UDim2.new(1,-24,0,15)})
 local val=label(f,tostring(nums[id] or lo),11,A.cyan,true,{
  Position=UDim2.new(1,-75,0,11),Size=UDim2.fromOffset(60,21),
  TextXAlignment=Enum.TextXAlignment.Right})
 local track=create("Frame",f,{BackgroundColor3=A.border,BorderSizePixel=0,
  Position=UDim2.new(0,13,0,61),Size=UDim2.new(1,-26,0,6)})
 corner(track,4)
 local fill=create("Frame",track,{BackgroundColor3=A.cyan,BorderSizePixel=0,
  Size=UDim2.fromScale(math.clamp(((nums[id] or lo)-lo)/(hi-lo),0,1),1)})
 corner(fill,4)
 local dot=create("Frame",track,{BackgroundColor3=A.white,BorderSizePixel=0,
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(fill.Size.X.Scale,.5),
  Size=UDim2.fromOffset(12,12)})
 corner(dot,6)
 outline(dot,A.cyan,1)
 local zone=button(f,"",{BackgroundTransparency=1,
  Position=UDim2.new(0,12,0,46),Size=UDim2.new(1,-24,0,34)})
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
 local b=button(parent,"",{Size=UDim2.new(1,0,0,36),
  BackgroundColor3=A.field,AutoButtonColor=false})
 corner(b,7)
 outline(b,A.border,.65)
 label(b,item.label,11,A.white,true,{
  Position=UDim2.fromOffset(12,3),Size=UDim2.new(1,-42,1,-6)})
 local actionIcon=artwork(b,item.id and item.id:sub(1,4)=="copy" and "copy" or "chevron",
  0,0,14,14,A.muted)
 if actionIcon then actionIcon.Position=UDim2.new(1,-26,.5,-7)end
 interactiveHover(b,A.field,A.hover,true)
 bind(b.Activated,function()
  local ok,err=pcall(action,item.id)
  if not ok then status("Action error: "..tostring(err))end
 end,true)
 register(section,b,item.label)
end
local function controlDrop(parent,section,item)
 local values=item.values or {}
 if #values==0 then return end
 local f=row(parent,78)
 label(f,item.label,11,A.white,true,{Position=UDim2.fromOffset(13,10),
  Size=UDim2.new(.49,-12,0,21)})
 label(f,item.desc or "",10,A.muted,false,{
  Position=UDim2.fromOffset(13,34),Size=UDim2.new(.5,-22,0,31),
  TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
 local chosen=1
 local drop=button(f,values[chosen].."  ▾",{
  Position=UDim2.new(.54,0,0,12),
  Size=UDim2.new(.46,-13,0,32),BackgroundColor3=A.field,
  TextSize=10,AutoButtonColor=false
 })
 corner(drop,7)
 outline(drop,A.border,.8)
 interactiveHover(drop,A.field,A.hover,true)
 local optFrame=create("Frame",f,{BackgroundTransparency=1,
  Size=UDim2.new(1,-20,0,0),Position=UDim2.fromOffset(10,80),Visible=false})
 local stack=create("UIListLayout",optFrame,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,3)})
 for i,v in ipairs(values) do
  local option=button(optFrame,v,{Size=UDim2.new(1,0,0,26),LayoutOrder=i,
   BackgroundColor3=A.field,TextSize=10,AutoButtonColor=false})
  interactiveHover(option,A.field,A.hover,true)
  bind(option.Activated,function()
   chosen=i;drop.Text=v.."  ▾"
   optFrame.Visible=false;f.Size=UDim2.new(1,0,0,78)
   if item.id=="fovPreset" then
    local preset=i==1 and 70 or i==2 and 90 or 60
    fov(preset)
    status("FOV preset: "..preset)
   end
  end,true)
 end
 bind(drop.Activated,function()
  optFrame.Visible=not optFrame.Visible
  f.Size=UDim2.new(1,0,0,optFrame.Visible and (84+#values*29) or 78)
  if optFrame.Visible then optFrame.Size=UDim2.new(1,-20,0,#values*29)end
 end,true)
 register(section,f,item.label)
end
local function card(which,definition)
 local host=which=="right" and right or left
 local c=create("Frame",host,{BackgroundColor3=A.card,BorderSizePixel=0,
  Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y})
 corner(c,10);outline(c,A.border,.9)
 local lay=create("UIListLayout",c,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,0)})
 local title=button(c,"",{BackgroundColor3=A.card,Size=UDim2.new(1,0,0,44),
  AutoButtonColor=false})
 corner(title,10)
 interactiveHover(title,A.card,A.hover,true)
 create("Frame",title,{BackgroundColor3=A.border,BorderSizePixel=0,
  BackgroundTransparency=.25,Position=UDim2.new(0,12,1,-1),
  Size=UDim2.new(1,-24,0,1)})
 -- Compact, uniform card title: proper white outline icon, no big cyan tiles.
 local headingKey=string.lower(definition.title or "")
 local headerGlyph=(headingKey:find("runtime",1,true) or
   headingKey:find("overview",1,true)) and "overview"
  or (headingKey:find("visual",1,true) and "visuals")
  or (headingKey:find("movement",1,true) and "player")
  or (headingKey:find("control",1,true) and "settings")
  or (headingKey:find("protection",1,true) and "shield")
  or (headingKey:find("security",1,true) and "shield")
  or "module"
 artwork(title,headerGlyph,16,13,18,18,A.light)
 label(title,definition.title,12,A.white,true,{
  Position=UDim2.fromOffset(44,7),Size=UDim2.new(1,-84,0,29)})
 local arrow=artwork(title,"chevron",0,0,16,16,A.muted)
 arrow.Position=UDim2.new(1,-30,0,14)
local inside=create("Frame",c,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
  AutomaticSize=Enum.AutomaticSize.Y,Visible=true})
 create("UIPadding",inside,{PaddingLeft=UDim.new(0,8),
  PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,10),
  PaddingTop=UDim.new(0,5)})
 create("UIListLayout",inside,{SortOrder=Enum.SortOrder.LayoutOrder,
  Padding=UDim.new(0,6)})
 local record={card=c,title=string.lower(definition.title.." "..(definition.subtitle or "")),
  items={},body=inside,arrow=arrow}
 table.insert(filterRecords,record)
 bind(title.Activated,function()
  inside.Visible=not inside.Visible
  uiTween(arrow,{Rotation=inside.Visible and 0 or 180},.15)
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
 local anyVisible=false
 clearSearch.Visible=query~=""
 search.Size=UDim2.new(1,query=="" and -45 or -69,1,0)
 for _,g in ipairs(filterRecords) do
  local heading=query=="" or g.title:find(query,1,true)~=nil
  local matching=false
  for _,item in ipairs(g.items) do
   local show=heading or item.text:find(query,1,true)~=nil
   item.ui.Visible=show
   if show then matching=true end
  end
  g.card.Visible=heading or matching
  if g.card.Visible then anyVisible=true end
  if query~="" and g.card.Visible then
   g.body.Visible=true
   if g.arrow then g.arrow.Rotation=0 end
  end
 end
 noResults.Visible=query~="" and not anyVisible
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
  card("left",{title="VISION WARE V1",subtitle="Modules et design",items={
   {type="info",label="Version",value="1.0"},
   {type="info",label="UI Theme",value="Sena-inspired"},
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
  Visuals="visuals",Misc="shield",Settings="settings",About="about"}
 local icon=artwork(parent,target[name] or "menu",15,10,19,19,A.muted)
 if icon then icon.Name="NavIcon" end
 return icon
end

local tabs={"Overview","Game","Player","Visuals","Misc","Settings","About"}
local tabLabels={Overview="Overview",Game="Game",Player="Player",
 Visuals="Visuals",Misc="Misc",Settings="Paramètres",About="About"}
local function goPage(name)
 current=name
 pageTitle.Text=tabLabels[name] or name
 pageDescription.Text=name=="Game" and selected.description or
  (name=="Overview" and "Session overview & quick controls" or
  (name=="About" and "Community / project information" or
  (name=="Settings" and "Interface preferences" or
  (name=="Misc" and "Protections locales essentielles" or
  (name=="Visuals" and "Visual & display options" or "Player preferences")))))
 search.Text=""
 for n,b in pairs(navButtons)do
  local chosen=n==name
  uiTween(b,{BackgroundColor3=chosen and A.selected or A.side},.15)
  local textLabel=b:FindFirstChild("NavTitle")
  if textLabel then
   uiTween(textLabel,{TextColor3=chosen and A.white or A.muted},.15)
  end
  local icon=b:FindFirstChild("NavIcon")
  if icon then uiTween(icon,{ImageColor3=chosen and A.cyan or A.muted},.15)end
  local bar=b:FindFirstChild("Selected")
  if bar then uiTween(bar,{BackgroundTransparency=chosen and 0 or 1},.15)end
 end
 render()
end
for i,name in ipairs(tabs) do
 local tabName=name
 local b=button(nav,"",{BackgroundColor3=A.side,AutoButtonColor=false,
  Size=UDim2.new(1,0,0,39),LayoutOrder=i,TextXAlignment=Enum.TextXAlignment.Left})
 corner(b,7)
 create("Frame",b,{Name="Selected",BackgroundColor3=A.cyan,BackgroundTransparency=1,
  BorderSizePixel=0,Position=UDim2.fromOffset(1,9),Size=UDim2.fromOffset(3,21)})
 navIcon(b,name)
 label(b,tabLabels[name] or name,12,A.muted,true,{
  Name="NavTitle",Position=UDim2.fromOffset(53,7),
  Size=UDim2.new(1,-57,0,25)
 })
 navButtons[name]=b
 bind(b.MouseEnter,function()
  if current~=tabName then uiTween(b,{BackgroundColor3=A.hover},.13)end
 end)
 bind(b.MouseLeave,function()
  if current~=tabName then uiTween(b,{BackgroundColor3=A.side},.16)end
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

-- MISC / advanced client-side protection.
-- These defensive features are local heuristics. Servers can override local physics,
-- and no client-only script can guarantee immunity across every Roblox game.
local function resetProtection(ch)
 protect.character=ch
 protect.bornAt=os.clock()
 protect.lastVelocity=nil
 protect.lastPosition=nil
 protect.elapsed=0
 protect.stableFor=0
 protect.airborneFor=0
 protect.safeCFrame=nil
 protect.safePlatform=nil
 protect.safeAt=0
 protect.lastSafeGroundY=nil
 protect.lastFlingAt=0
 protect.lastFlingNoticeAt=0
 protect.lastRescueAt=0
end

local groundParams=RaycastParams.new()
groundParams.FilterType=Enum.RaycastFilterType.Exclude
groundParams.IgnoreWater=true
local function groundHit(ch,origin,depth)
 groundParams.FilterDescendantsInstances={ch}
 return workspace:Raycast(origin,Vector3.new(0,-depth,0),groundParams)
end
local function validGround(hit)
 if not hit or hit.Normal.Y<.65 then return false end
 local part=hit.Instance
 if not part or not part.Parent then return false end
 if part==workspace.Terrain then return true end
 return part:IsA("BasePart") and part.CanCollide
end
local function stillSafe(ch)
 if not protect.safeCFrame or not protect.safePlatform then return false end
 local part=protect.safePlatform
 if not part.Parent or (part~=workspace.Terrain and not part.CanCollide) then return false end
 local depth=math.max(12,protect.safeCFrame.Position.Y-protect.lastSafeGroundY+7)
 local hit=groundHit(ch,protect.safeCFrame.Position+Vector3.new(0,3,0),depth)
 return validGround(hit) and hit.Instance==part
  and math.abs(hit.Position.Y-protect.lastSafeGroundY)<4
end

local function saveStableGround(dt,ch,hum,hrp,velocity,angular,now)
 local hit=groundHit(ch,hrp.Position,math.max(7,hum.HipHeight+hrp.Size.Y+5))
 local grounded=hum.FloorMaterial~=Enum.Material.Air
  and validGround(hit)
  and hit.Position.Y>workspace.FallenPartsDestroyHeight+35
  and math.abs(velocity.Y)<14
  and Vector3.new(velocity.X,0,velocity.Z).Magnitude<math.max(50,hum.WalkSpeed*2.4)
  and angular.Magnitude<22
 local groundPart=hit and hit.Instance
 -- Moving platforms cannot safely be restored from an old static coordinate.
 local fixed=grounded and
  (groundPart==workspace.Terrain or
   (groundPart:IsA("BasePart") and
    (groundPart.Anchored or groundPart.AssemblyLinearVelocity.Magnitude<3)))
 if fixed then
  protect.stableFor=math.min(2,protect.stableFor+dt)
  protect.airborneFor=0
  if protect.stableFor>.32 and (now-protect.safeAt>.28) then
   local lift=math.max(3.2,hum.HipHeight+hrp.Size.Y*.5+1.1)
   local target=Vector3.new(hrp.Position.X,hit.Position.Y+lift,hrp.Position.Z)
   local yaw=hrp.CFrame.Rotation
   protect.safeCFrame=CFrame.new(target)*yaw
   protect.safePlatform=groundPart
   protect.lastSafeGroundY=hit.Position.Y
   protect.safeAt=now
  end
 else
  protect.stableFor=0
  if not grounded then protect.airborneFor=protect.airborneFor+dt
  else protect.airborneFor=0 end
 end
end

local function stopFling(ch,hum,hrp,vel,spin,dt,now)
 if not stored.antiFling or now-protect.bornAt<1
  or now-protect.lastFlingAt<.18 then return false end
 local planar=Vector3.new(vel.X,0,vel.Z)
 local horizontalSpeed=planar.Magnitude
 local prev=protect.lastVelocity
 local acceleration=prev and
  Vector3.new(vel.X-prev.X,0,vel.Z-prev.Z).Magnitude or 0
 local maxNormal=math.max(100,hum.WalkSpeed*3.4)
 local spike=prev~=nil and dt<.18 and acceleration>85
  and horizontalSpeed>math.max(65,hum.WalkSpeed*2.2)
 -- A violent downward impulse is different from ordinary gravity:
 -- only flag a sudden vertical change, not sustained legitimate freefall.
 local downwardSpike=prev~=nil and dt<.18
  and prev.Y-vel.Y>100 and vel.Y< -105
 local rapidSpin=spin.Magnitude>58
 local extremeVelocity=horizontalSpeed>maxNormal or vel.Y>115
 if not (spike or downwardSpike or rapidSpin or extremeVelocity) then return false end
 protect.lastFlingAt=now
 local maxTravel=math.clamp(hum.WalkSpeed*1.6,24,55)
 local damp=horizontalSpeed>maxTravel
  and planar.Unit*maxTravel or planar
 local correctedY=math.min(vel.Y,46)
 if downwardSpike or rapidSpin or (extremeVelocity and vel.Y< -90) then
  correctedY=math.max(correctedY,-65)
 end
 local corrected=Vector3.new(damp.X,correctedY,damp.Z)
 local ok=pcall(function()
  hrp.AssemblyLinearVelocity=corrected
  hrp.AssemblyAngularVelocity=Vector3.zero
  if rapidSpin then
   local facing=hrp.CFrame.LookVector
   local upright=Vector3.new(facing.X,0,facing.Z)
   if upright.Magnitude>.12 then
    hrp.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+upright.Unit)
   end
  end
 end)
 if ok then
  miscCounts.fling=miscCounts.fling+1
  if now-protect.lastFlingNoticeAt>4 then
   protect.lastFlingNoticeAt=now
   status("Anti-Fling : impulsion anormale amortie")
  end
 end
 return ok
end

local function rescueVoid(ch,hum,hrp,vel,now)
 if not stored.antiVoid or not protect.safeCFrame
  or now-protect.lastRescueAt<2.5 then return end
 local heightLost=protect.safeCFrame.Position.Y-hrp.Position.Y
 local fallLimit=workspace.FallenPartsDestroyHeight
 local critical=hrp.Position.Y<fallLimit+32 and vel.Y<0
 local fallingFar=heightLost>80 and vel.Y< -34
  and protect.airborneFor>.85
 if not critical and not fallingFar then return end
 -- Only verify the remembered platform when rescue is actually necessary,
 -- rather than firing this extra raycast every frame.
 if not stillSafe(ch) then
  protect.safeCFrame=nil
  protect.safePlatform=nil
  return
 end
 if not critical then
  -- Falling a long distance can be legitimate; only rescue if no surface
  -- is detectable within the next ~100 studs beneath the character.
  if validGround(groundHit(ch,hrp.Position,105)) then return end
 end
 protect.lastRescueAt=now
 local target=protect.safeCFrame
 local ok=pcall(function()
  ch:PivotTo(target)
  hrp.AssemblyLinearVelocity=Vector3.zero
  hrp.AssemblyAngularVelocity=Vector3.zero
 end)
 if ok then
  miscCounts.void=miscCounts.void+1
  protect.airborneFor=0
  protect.stableFor=0
  protect.lastVelocity=Vector3.zero
  status("Anti-Void : retour sur une surface stable")
 end
end

local function miscOwnProtection(dt)
 if not stored.antiFling and not stored.antiVoid then
  protect.elapsed=0
  protect.lastVelocity=nil
  return
 end
 local ch=player.Character
 if ch~=protect.character then resetProtection(ch) end
 local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
 local hum=ch and ch:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum or hum.Health<=0 or hum.SeatPart then
  protect.lastVelocity=nil
  return
 end
 local state=hum:GetState()
 if state==Enum.HumanoidStateType.Dead
  or state==Enum.HumanoidStateType.Swimming
  or state==Enum.HumanoidStateType.Climbing then
  protect.lastVelocity=nil
  return
 end
 local now=os.clock()
 local velocity=hrp.AssemblyLinearVelocity
 local spin=hrp.AssemblyAngularVelocity
 local suppressed=stopFling(ch,hum,hrp,velocity,spin,dt,now)
 if suppressed then velocity=hrp.AssemblyLinearVelocity end
 -- Throttle ground-raycasts to 10Hz; critical void detection still runs
 -- on every Heartbeat to catch fast falls before the destroy height.
 protect.elapsed=protect.elapsed+math.min(dt,.1)
 if protect.elapsed>=.1 then
  local sample=protect.elapsed
  protect.elapsed=0
  if stored.antiVoid then
   saveStableGround(sample,ch,hum,hrp,velocity,spin,now)
  else
   protect.safeCFrame=nil
   protect.safePlatform=nil
  end
 end
 if stored.antiVoid then rescueVoid(ch,hum,hrp,velocity,now) end
 protect.lastVelocity=hrp.AssemblyLinearVelocity
 protect.lastPosition=hrp.Position
end
bind(Run.Heartbeat,function(dt)
 if closed then return end
 miscOwnProtection(dt)
end)
bind(player.CharacterAdded,function(ch)
 resetProtection(ch)
end)

-- Screen-size handling for the main window only (no key overlay).
local cameraConnection
local function updateCamera()
 if cameraConnection then cameraConnection:Disconnect() end
 local cam=workspace.CurrentCamera
 if cam then
  cameraConnection=bind(cam:GetPropertyChangedSignal("ViewportSize"),fitToScreen)
 end
 fitToScreen()
end
bind(workspace:GetPropertyChangedSignal("CurrentCamera"),updateCamera)
updateCamera()
