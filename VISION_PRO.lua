-- VISION_PRO_VERSION: 1.7.1
--[[ VISION PRO 1.7.1 | SPECTRA / UI NAVIGATION HOTFIX
     LocalScript for authorized testing in your Roblox place.
     Aimbot / simulated Silent Aim work on locally spawned mannequins only.
     Camera assist and impact preview always start disabled.
     Local HP is a training display, not actual server damage.
]]
if not game:IsLoaded() then game.Loaded:Wait() end
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local Run=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Tags=game:GetService("CollectionService")
local WS=game:GetService("Workspace")
local Me=Players.LocalPlayer
if not Me then return end
local PG=Me:WaitForChild("PlayerGui")
local V="1.7.1"
local GNAME="VISION_PRO_147_GUI"
local ONAME="VISION_PRO_147_OVERLAY"
local DNAME="VISION_PRO_147_DUMMIES"
local KEY="VISION_PRO_147_STOP"
local TAB_ACTION="VISION_PRO_147_TAB"
local AIM_ACTION="VISION_PRO_147_CAMERA"
local TAG="VisionProTarget"
local env=_G
if type(getgenv)=="function" then
    local ok,val=pcall(getgenv)
    if ok and type(val)=="table" then env=val end
end
for _,k in ipairs({KEY,"VISION_PRO_146_STOP","VISION_PRO_145_STOP","VISION_PRO_144_STOP","VISION_PRO_143_STOP","VISION_PRO_142_STOP","VISION_PRO_141_STOP","VISION_PRO_140_STOP","VISION_PRO_132_STOP","VISION_PRO_131_STOP","VISION_PRO_130_STOP","VISION_PRO_127_STOP","VISION_PRO_126_STOP","VISION_PRO_125_STOP","VISION_PRO_124_STOP","VISION_PRO_123_STOP","VISION_PRO_122_STOP","VISION_PRO_121_STOP","VISION_PRO_120_STOP","VISION_PRO_110_STOP"}) do
    if type(env[k])=="function" then pcall(env[k]) end
end
for _,name in ipairs({GNAME,ONAME,"VISION_PRO_146_GUI","VISION_PRO_146_OVERLAY","VISION_PRO_145_GUI","VISION_PRO_145_OVERLAY","VISION_PRO_144_GUI","VISION_PRO_144_OVERLAY","VISION_PRO_143_GUI","VISION_PRO_143_OVERLAY","VISION_PRO_142_GUI","VISION_PRO_142_OVERLAY","VISION_PRO_141_GUI","VISION_PRO_141_OVERLAY","VISION_PRO_140_GUI","VISION_PRO_140_OVERLAY","VISION_PRO_132_GUI","VISION_PRO_132_OVERLAY","VISION_PRO_131_GUI","VISION_PRO_131_OVERLAY","VISION_PRO_130_GUI","VISION_PRO_130_OVERLAY","VISION_PRO_127_GUI","VISION_PRO_127_OVERLAY","VISION_PRO_126_GUI","VISION_PRO_126_OVERLAY","VISION_PRO_125_GUI","VISION_PRO_125_OVERLAY","VISION_PRO_124_GUI","VISION_PRO_124_OVERLAY","VISION_PRO_123_GUI","VISION_PRO_123_OVERLAY"}) do
    local old=PG:FindFirstChild(name)
    if old then old:Destroy() end
end
for _,name in ipairs({DNAME,"VISION_PRO_146_DUMMIES","VISION_PRO_145_DUMMIES","VISION_PRO_144_DUMMIES","VISION_PRO_143_DUMMIES","VISION_PRO_142_DUMMIES","VISION_PRO_141_DUMMIES","VISION_PRO_140_DUMMIES","VISION_PRO_132_DUMMIES","VISION_PRO_131_DUMMIES","VISION_PRO_130_DUMMIES","VISION_PRO_127_DUMMIES","VISION_PRO_126_DUMMIES","VISION_PRO_125_DUMMIES","VISION_PRO_124_DUMMIES","VISION_PRO_123_DUMMIES"}) do
    local old=WS:FindFirstChild(name)
    if old then old:Destroy() end
end

-- CONFIGURATION GITHUB (UNE SEULE LIGNE A CHANGER) :
-- Renseigne ici l'adresse RAW publique de ton propre fichier VISION_PRO.lua.
-- Le pseudo / depot ne s'affiche jamais dans l'onglet About.

local D={ESP=true,Box=true,BoxColor="ACCENT",ESPDetail="FULL",ESPExtraRange=650,ThroughWalls=true,
    Skeleton=true,Tracers=false,Names=true,Distance=true,Health=true,
    ShowAllies=true,ShowNPC=true,TeamColors=false,Highlight=false,
    Aim=false,AimFOV=140,AimSmooth=.12,ShowFOV=true,AimPart="HEAD",AimLOS=true,
    Preview=false,PreviewFOV=170,PreviewPart="HEAD",PreviewLOS=true,ShotDamage=25,AutoRespawn=true,HitMarker=true,PreviewCircle=true,
    -- Local defenses against abnormal physics, not self-rotation demos.
    AntiFly=true,FlyLaunchSpeed=75,
    AntiFling=true,FlingSpeed=100,
    AntiAim=false,SpinThreshold=9,
    GuardCorrect=true,MoveHUD=true,SafeRecovery=true,GuardV3=true,GuardMode="STRONG",GuardV4=true,
    GITHUB_OTA_URL="https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VISION_PRO.lua",
    Accent="VIOLET",RGB=false,Animations=true,Notifications=true,MiniButton=false,
    MenuScale=1,UIRoundness=1.1,Shortcut="TAB",PerformanceMode="BALANCED",Range=1200,
    Thickness=.07,RenderRate=45,AdaptiveFPS=true}
local cfg=table.clone(D)
local old=env.VISION_PRO_147_PREFS or env.VISION_PRO_145_PREFS or env.VISION_PRO_144_PREFS or env.VISION_PRO_143_PREFS or env.VISION_PRO_142_PREFS or env.VISION_PRO_141_PREFS or env.VISION_PRO_140_PREFS or env.VISION_PRO_132_PREFS or env.VISION_PRO_131_PREFS or env.VISION_PRO_130_PREFS or env.VISION_PRO_127_PREFS or env.VISION_PRO_126_PREFS or env.VISION_PRO_125_PREFS or env.VISION_PRO_124_PREFS
if type(old)=="table" then
    for k,v in pairs(D) do
        if typeof(old[k])==typeof(v) then cfg[k]=old[k] end
    end
end
local function validOptions(key,values,fallback)
    if not table.find(values,cfg[key]) then cfg[key]=fallback end
end
local function normalize()
    validOptions("BoxColor",{"BLEU","VIOLET","RGB","ACCENT"},"ACCENT")
    validOptions("ESPDetail",{"FULL","COMPACT"},"FULL")
    validOptions("Accent",{"BLEU","VIOLET","CYAN","ROUGE","VERT","ROSE"},"VIOLET")
    validOptions("PerformanceMode",{"LOW","BALANCED","HIGH"},"BALANCED")
    validOptions("Shortcut",{"TAB","RIGHTSHIFT","F4"},"TAB")
    validOptions("GuardMode",{"NORMAL","STRONG"},"STRONG")
    cfg.MenuScale=math.clamp(tonumber(cfg.MenuScale) or 1,.7,1.15)
    cfg.UIRoundness=math.clamp(tonumber(cfg.UIRoundness) or 1.1,.7,1.5)
    validOptions("AimPart",{"HEAD","BODY"},"HEAD")
    validOptions("PreviewPart",{"HEAD","BODY"},"HEAD")
    for k,v in pairs({AimFOV={60,300},PreviewFOV={60,300},AimSmooth={.03,.45},Range={100,2500},ESPExtraRange={200,1500},Thickness={.03,.18},RenderRate={15,60},ShotDamage={10,50},FlyLaunchSpeed={50,200},FlingSpeed={70,250},SpinThreshold={5,25}}) do
        local num=tonumber(cfg[k]) or D[k]
        cfg[k]=math.clamp(num==num and num or D[k],v[1],v[2])
    end
end
normalize()
-- Training camera assists do not persist enabled state.
cfg.Aim=false
cfg.Preview=false
cfg.AntiAim=false
-- New V3 protection starts enabled on the first run, then respects user settings.
if type(old)~="table" or old.GuardV3~=true then
    cfg.AntiFly=true
    cfg.AntiFling=true
    cfg.GuardCorrect=true
    cfg.SafeRecovery=true
end
local function save() env.VISION_PRO_147_PREFS=table.clone(cfg) end
save()

local C={
    -- SPECTRA SLATE: four neutral surfaces, restrained cool-color accents.
    BG=Color3.fromRGB(13,17,27),
    SIDE=Color3.fromRGB(19,25,39),
    CARD=Color3.fromRGB(27,36,53),
    HOVER=Color3.fromRGB(39,52,73),
    STROKE=Color3.fromRGB(58,76,100),
    WHITE=Color3.fromRGB(244,249,255),
    TEXT=Color3.fromRGB(210,223,236),
    MUTED=Color3.fromRGB(151,169,189),
    PURPLE=Color3.fromRGB(146,127,245),
    BLUE=Color3.fromRGB(93,167,250),
    CYAN=Color3.fromRGB(91,213,199),
    GREEN=Color3.fromRGB(100,214,158),
    RED=Color3.fromRGB(251,116,137),
    DARK=Color3.fromRGB(11,16,25),
    GOLD=Color3.fromRGB(246,191,105),
    PINK=Color3.fromRGB(224,137,179),
    ORANGE=Color3.fromRGB(252,175,106)
}
local accentChoices={BLEU=C.BLUE,VIOLET=C.PURPLE,CYAN=C.CYAN,ROUGE=C.RED,VERT=C.GREEN,ROSE=C.PINK}
local S={Alive=true,Open=true,Page="HOME",Connections={},Players={},Targets={},Dummies={},
    Toggles={},Selectors={},Sliders={},Timers={},Errors=0,Frames=0,FPS=60,Rate=45,
    Hue=0,Accent=C.PURPLE,LastTab=0,Hits=0,Shots=0,MarkerUntil=0,Reloading=false,
    Gun=nil,Armed=false,Ammo=12,GunGeneration=0,LastShot=0,MouseDrag=nil,KOs=0,Damage=0,
    Muzzle=nil,FlashToken=0,LastTarget=nil,SliderFills={},
    FlyFlags=0,FlingFlags=0,SpinFlags=0,
    FlySamples=0,FlingSamples=0,SpinSamples=0,
    LastError=nil,EquipError=nil,
    FlyCooldown=0,FlingCooldown=0,SpinCooldown=0,
    GuardCharacter=nil,LastSafeCFrame=nil,LastSafeTime=0,LastRecovery=0,RecoveryUntil=0,
    GuardNoticeCooldown=0,LastGuardHUD=0,GuardCooldown=0,GuardErrorTime=0,BlockedImpulses=0,
    LastMotionVelocity=nil,GuardCorrections=0,RecoveryReason=nil,ToastList={},RoundCorners={},
    FlyState="OFF",FlingState="OFF",SpinState="OFF",
    MovementStatus=nil,MovementHUD=nil,
    OtaRelease=nil,OtaAssetUrl=nil,OtaPageUrl=nil,OtaBusy=false,OtaConfirmOpen=false,
    AccentBars={},AccentToggles={},AccentButtons={},AccentLabels={}}
-- Only errors raised by VISION PRO are recorded here. Roblox CoreGui errors
-- and invalid animations in the experience are outside this client script.
local function logVisionError(scope,problem)
    local message=tostring(problem)
    S.Errors+=1
    S.LastError=tostring(scope)..": "..message
    -- Limit repeated spam while retaining first detail in developer console.
    if S.Errors<=8 then
        warn("[VISION PRO "..V.." / "..tostring(scope).."] "..message)
    end
end
local notify=function()end
local function safeAction(scope,fn)
    local ok,err=pcall(fn)
    if not ok then
        logVisionError(scope,err)
        notify("Action failed: "..tostring(scope),"ERROR")
    else
        notify("Action done: "..tostring(scope),"SUCCESS")
    end
end
local function make(kind,p,parent)
    local x=Instance.new(kind)
    for k,v in pairs(p or {}) do x[k]=v end
    x.Parent=parent
    return x
end
local function on(event,cb)
    local con=event:Connect(cb)
    table.insert(S.Connections,con)
    return con
end
-- SPECTRA V3 ROUNDED: consistent radii without changing button behavior.
local ROUND={Window=32,Sidebar=32,Card=21,Compact=18,Modal=28,Pill=20}
local function corner(x,r)
    local radius=r
    if radius>=8 and radius<100 then
        radius=math.floor(radius*cfg.UIRoundness+.5)
    end
    local rounded=make("UICorner",{CornerRadius=UDim.new(0,radius)},x)
    if r>=8 and r<100 then
        table.insert(S.RoundCorners,{Corner=rounded,Base=r})
    end
    return x
end
local function refreshRoundness()
    for _,item in ipairs(S.RoundCorners) do
        if item.Corner.Parent then
            item.Corner.CornerRadius=UDim.new(0,math.floor(item.Base*cfg.UIRoundness+.5))
        end
    end
end
local function stroke(x,col,w) return make("UIStroke",{Color=col or C.STROKE,Thickness=w or 1},x) end
local function grad(x,a,b,angle)
    return make("UIGradient",{Color=ColorSequence.new(a,b),Rotation=angle or 0},x)
end
local function txt(parent,s,x,y,w,h,size,bold,col)
    return make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        Text=s,TextColor3=col or C.WHITE,TextSize=size or 12,
        Font=bold and Enum.Font.GothamBold or Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},parent)
end
local function animateUI(object,properties,duration)
    if not object or not object.Parent then return end
    if cfg.Animations then
        Tween:Create(object,TweenInfo.new(duration or .15,Enum.EasingStyle.Quad),properties):Play()
    else
        for key,value in pairs(properties) do object[key]=value end
    end
end
local function btn(parent,s,x,y,w,h,background)
    local control=corner(make("TextButton",{
        Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        Text="",BackgroundColor3=background or C.HOVER,
        BorderSizePixel=0,AutoButtonColor=false,Active=true,
    },parent),math.min(ROUND.Pill,math.floor(h/2)))
    local caption=make("TextLabel",{
        Name="ButtonCaption",Position=UDim2.fromScale(0,0),
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Active=false,Text=s,TextColor3=C.WHITE,
        TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextYAlignment=Enum.TextYAlignment.Center,ZIndex=control.ZIndex+2,
    },control)
    return control
end
local function buttonSurface(control,color1,color2)
    local surface=corner(make("Frame",{
        Name="VisualSurface",
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=color1 or C.BLUE,
        BorderSizePixel=0,
        Active=false,
        ZIndex=control.ZIndex+1
    },control),math.min(ROUND.Pill,math.floor(control.Size.Y.Offset/2)))
    -- A shallow gradient gives depth without the template-like neon streaks.
    grad(surface,color1 or C.BLUE,color2 or C.PURPLE,8)
    return surface
end
local function buttonCaption(b)
    return b:FindFirstChild("ButtonCaption")
end
local function description(parent,s,x,y,w,h)
    local t=txt(parent,s,x,y,w,h,11,false,C.MUTED)
    t.Font=Enum.Font.GothamMedium
    t.TextYAlignment=Enum.TextYAlignment.Center
    return t
end
local function bar(parent,x,y,w,h,color,rotation)
    return corner(make("Frame",{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        BorderSizePixel=0,BackgroundColor3=color or C.WHITE,Rotation=rotation or 0},parent),3)
end
-- All navigation icons are Roblox UI primitives, not letters or external asset IDs.
local function icon(parent,kind,x,y)
    local glyph=make("Frame",{Position=UDim2.fromOffset(x,y),
        Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,Active=false},parent)
    local ink=C.TEXT
    local function part(px,py,w,h,color,r)
        return corner(make("Frame",{Position=UDim2.fromOffset(px,py),
            Size=UDim2.fromOffset(w,h),BackgroundColor3=color or ink,
            BorderSizePixel=0,Active=false},glyph),r or 2)
    end
    local function outline(px,py,w,h,r)
        local frame=corner(make("Frame",{Position=UDim2.fromOffset(px,py),
            Size=UDim2.fromOffset(w,h),BackgroundTransparency=1,Active=false},glyph),r or 4)
        stroke(frame,ink,1.6)
        return frame
    end
    if kind=="home" then
        -- Asymmetric dashboard tile composition.
        outline(3,3,9,9,3)
        outline(15,3,6,9,2)
        outline(3,15,6,6,2)
        outline(12,15,9,6,2)
    elseif kind=="eye" then
        outline(2,7,20,11,9)
        part(9,10,6,6,C.CYAN,8)
    elseif kind=="aim" then
        outline(5,5,14,14,13)
        part(11,0,2,7,ink,1);part(11,17,2,7,ink,1)
        part(0,11,7,2,ink,1);part(17,11,7,2,ink,1)
    elseif kind=="silent" then
        outline(5,5,14,14,13)
        part(0,11,7,2,ink,1);part(17,11,7,2,ink,1)
        part(11,0,2,7,ink,1);part(11,17,2,7,ink,1)
        part(10,10,4,4,C.PINK,4)
    elseif kind=="misc" then
        -- Three separate lab sliders, not another four-tile icon.
        part(3,5,18,2,ink,1);part(3,12,18,2,ink,1);part(3,19,18,2,ink,1)
        part(7,2,5,8,C.GOLD,2);part(15,9,5,8,C.GOLD,2);part(6,16,5,8,C.GOLD,2)
    elseif kind=="settings" then
        outline(3,3,18,18,10)
        part(10,6,4,12,ink,2);part(6,10,12,4,ink,2)
        part(9,9,6,6,C.SIDE,5)
    else
        outline(3,3,18,18,12)
        part(10,10,3,8,ink,2);part(10,6,3,3,ink,3)
    end
    return glyph
end
local overlay=make("ScreenGui",{Name=ONAME,DisplayOrder=850,IgnoreGuiInset=true,ResetOnSpawn=false},PG)
local ui=make("ScreenGui",{Name=GNAME,DisplayOrder=900,IgnoreGuiInset=true,ResetOnSpawn=false},PG)
notify=function(message,kind)
    if not S.Alive or not cfg.Notifications or not ui.Parent then return end
    local items=S.ToastList
    local color=kind=="ERROR" and C.RED or kind=="SUCCESS" and C.GREEN or S.Accent
    local toast=corner(make("Frame",{
        Name="VPToastV4",AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-18,0,-72),Size=UDim2.fromOffset(296,58),
        BackgroundColor3=C.SIDE,BorderSizePixel=0,ZIndex=100
    },ui),ROUND.Compact)
    stroke(toast,C.STROKE,1).Transparency=.28
    bar(toast,0,10,3,38,color).ZIndex=101
    local heading=txt(toast,kind=="ERROR" and "ERROR" or kind=="SUCCESS" and "SUCCESS" or "VISION PRO",
        14,5,258,17,10,true,color)
    heading.ZIndex=101
    local info=description(toast,tostring(message):sub(1,90),14,25,261,24)
    info.ZIndex=101;info.TextWrapped=true
    table.insert(items,toast)
    if #items>3 then
        local oldest=table.remove(items,1)
        if oldest.Parent then oldest:Destroy() end
    end
    for index,item in ipairs(items) do
        if item.Parent then
            animateUI(item,{Position=UDim2.new(1,-18,0,18+(index-1)*68)},.18)
        end
    end
    task.delay(kind=="ERROR" and 4 or 2.8,function()
        local where=table.find(items,toast)
        if not where then return end
        table.remove(items,where)
        if toast.Parent then
            animateUI(toast,{Position=UDim2.new(1,-18,0,-72)},.15)
            task.delay(.2,function()if toast.Parent then toast:Destroy() end end)
        end
        for index,item in ipairs(items) do
            if item.Parent then
                animateUI(item,{Position=UDim2.new(1,-18,0,18+(index-1)*68)},.18)
            end
        end
    end)
end
-- SPECTRA: purpose-built desktop control surface, not a dashboard grid.
local window=corner(make("Frame",{
    Size=UDim2.fromOffset(684,464),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),BackgroundColor3=C.BG,
    BorderSizePixel=0,ClipsDescendants=true,Active=true
},ui),ROUND.Window)
stroke(window,C.STROKE,1).Transparency=.25
local topLight=bar(window,157,0,527,3,C.BLUE)
local topGradient=grad(topLight,C.BLUE,C.PURPLE,5)
topLight.ZIndex=3
-- Apply the tint directly to the rounded root. A rectangular child would
-- cover the visual corners even when the root frame has a UICorner.
grad(window,Color3.fromRGB(16,22,36),Color3.fromRGB(11,16,27),78)
local scale=make("UIScale",{Scale=1},window)
local function rescale()
    local camera=WS.CurrentCamera
    if not camera then return end
    local vp=camera.ViewportSize
    local requested=math.clamp(cfg.MenuScale or 1,.7,1.15)
    scale.Scale=math.clamp(math.min(requested,(vp.X-20)/684,(vp.Y-20)/464),.35,1.15)
end
local sidebar=corner(make("Frame",{
    Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(157,464),
    BackgroundColor3=C.SIDE,BorderSizePixel=0,ClipsDescendants=true
},window),ROUND.Sidebar)
-- Fill the rounded sidebar's inner right edge so the content divider stays straight.
make("Frame",{
    Position=UDim2.fromOffset(132,0),Size=UDim2.fromOffset(25,464),
    BackgroundColor3=C.SIDE,BorderSizePixel=0
},sidebar)
bar(sidebar,156,0,1,464,C.STROKE)
-- Simplified studio-brand tile: one mark, not a large animated illustration.
local logo=corner(make("Frame",{
    Position=UDim2.fromOffset(15,17),Size=UDim2.fromOffset(32,32),
    BackgroundColor3=C.BLUE,BorderSizePixel=0
},sidebar),14)
local mark=txt(logo,"VP",0,4,32,22,13,true,C.DARK)
mark.TextXAlignment=Enum.TextXAlignment.Center
local brandName=txt(sidebar,"VISION PRO",53,13,100,24,12,true,C.WHITE)
local brandSub=txt(sidebar,"DESKTOP V4  /  1.7.1",53,34,102,17,9,true,C.MUTED)
local sidebarLine=bar(sidebar,15,64,125,1,C.STROKE)
sidebarLine.BackgroundTransparency=.4
local tabs={"HOME","VISUALS","AIMBOT","SILENT","MISC","SETTINGS","ABOUT"}
local tabTitles={HOME="Accueil",VISUALS="Visuels",AIMBOT="Aimbot",SILENT="Silent Aim",MISC="Divers",SETTINGS="Parametres",ABOUT="About"}
local tabIcons={HOME="home",VISUALS="eye",AIMBOT="aim",SILENT="silent",MISC="misc",SETTINGS="settings",ABOUT="info"}
local tabColors={HOME=C.BLUE,VISUALS=C.BLUE,AIMBOT=C.PURPLE,SILENT=C.PURPLE,
    MISC=C.CYAN,SETTINGS=C.BLUE,ABOUT=C.GREEN}
local nav={}
for i,name in ipairs(tabs) do
    local y=84+(i-1)*42
    local control=btn(sidebar,"",10,y,136,37,C.SIDE)
    control.BackgroundTransparency=1
    local selected=corner(make("Frame",{Name="Selection",Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromScale(1,1),BackgroundColor3=C.BLUE,
        BorderSizePixel=0,Visible=false,Active=false},control),17)
    local line=bar(control,0,8,3,21,tabColors[name])
    line.Visible=false
    local accentDot=corner(make("Frame",{Position=UDim2.fromOffset(11,9),
        Size=UDim2.fromOffset(21,21),BackgroundColor3=C.CARD,
        BorderSizePixel=0,Active=false},control),11)
    local glyph=icon(control,tabIcons[name],10,7)
    glyph.Size=UDim2.fromOffset(24,24)
    local title=txt(control,tabTitles[name],44,7,88,24,12,true,C.MUTED)
    nav[name]={Button=control,Gradient={Enabled=false},Title=title,Line=line,
        Selected=selected,Dot=accentDot,Icon=glyph}
    on(control.MouseEnter,function()
        if S.Alive and S.Page~=name then
            animateUI(control,{BackgroundTransparency=0,BackgroundColor3=C.CARD},.15)
        end
    end)
    on(control.MouseLeave,function()
        if S.Alive and S.Page~=name then
            animateUI(control,{BackgroundTransparency=1,BackgroundColor3=C.SIDE},.15)
        end
    end)
end
bar(sidebar,15,398,125,1,C.STROKE)
local onlineDot=corner(make("Frame",{Position=UDim2.fromOffset(16,413),
    Size=UDim2.fromOffset(7,7),BackgroundColor3=C.GREEN,BorderSizePixel=0},sidebar),5)
local guardStatusSidebar=txt(sidebar,"GUARD / ACTIVE",31,406,120,22,10,true,C.TEXT)
local status=txt(sidebar,"TAB  /  AFFICHER",16,433,132,18,9,false,C.MUTED)
-- Transparent header keeps the drag affordance; no large colored banner.
local header=make("Frame",{Position=UDim2.fromOffset(168,8),
    Size=UDim2.fromOffset(506,67),BackgroundTransparency=1,Active=true},window)
local pageCounter=txt(header,"01 / 07   -   WORKSPACE",12,4,220,16,10,true,C.MUTED)
local v3Badge=corner(make("Frame",{
    Position=UDim2.fromOffset(292,5),Size=UDim2.fromOffset(94,19),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},header),10)
local v3BadgeText=txt(v3Badge,"SPECTRA V4",11,1,77,16,9,true,C.CYAN)
v3BadgeText.TextXAlignment=Enum.TextXAlignment.Center
local pageTitle=txt(header,"Accueil",12,18,340,28,21,true,C.WHITE)
local pageDesc=description(header,"Environnement de test",13,44,340,18)
local headerStripe=bar(header,0,58,4,6,C.BLUE)
local headerPink=bar(header,361,57,15,2,C.BLUE)
headerPink.BackgroundTransparency=.66
local headerCyan=bar(header,379,57,8,2,C.CYAN)
headerCyan.BackgroundTransparency=.66
local runningDot=corner(make("Frame",{
    Position=UDim2.fromOffset(393,24),Size=UDim2.fromOffset(6,6),
    BackgroundColor3=C.GREEN,BorderSizePixel=0},header),4)
local minimize=btn(header,"-",421,18,30,30,C.CARD)
local close=btn(header,"X",457,18,30,30,C.CARD)
buttonCaption(minimize).TextSize=18
buttonCaption(close).TextSize=17
local topDivider=bar(window,170,77,504,1,C.STROKE)
topDivider.BackgroundTransparency=.52
local body=make("Frame",{Position=UDim2.fromOffset(170,88),
    Size=UDim2.fromOffset(505,326),BackgroundTransparency=1},window)
local footer=make("Frame",{Position=UDim2.fromOffset(170,427),
    Size=UDim2.fromOffset(505,28),BackgroundTransparency=1},window)
local footerLine=bar(footer,0,0,504,1,C.STROKE)
footerLine.BackgroundTransparency=.54
local foot=txt(footer,"SPECTRA V4  /  VISION PRO  /  v1.7.1",3,7,340,18,10,true,C.MUTED)
local fpsText=txt(footer,"-- FPS",390,7,105,18,10,true,C.GREEN)
fpsText.TextXAlignment=Enum.TextXAlignment.Right
local pages,orders,layouts={},{},{}
local function updateCanvas(name)
    local sc=pages[name]
    local layout=layouts[name]
    if not sc or not layout then return end
    -- Stable scroll bounds for pages that were built while hidden.
    local contentHeight=math.ceil(layout.AbsoluteContentSize.Y)+34
    sc.CanvasSize=UDim2.fromOffset(0,math.max(sc.AbsoluteSize.Y,contentHeight))
end
for _,name in ipairs(tabs) do
    orders[name]=0
    local sc=make("ScrollingFrame",{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
        AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,0),ScrollBarThickness=3,
        ScrollBarImageColor3=C.PURPLE,ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false,
        ScrollingEnabled=true},body)
    make("UIPadding",{PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,15),PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,10)},sc)
    local layout=make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},sc)
    pages[name]=sc
    layouts[name]=layout
    on(layout:GetPropertyChangedSignal("AbsoluteContentSize"),function()
        if S.Alive then updateCanvas(name) end
    end)
end
local subtitles={HOME="Controle et entrainement",VISUALS="ESP 3D et affichage",AIMBOT="Ciblage des mannequins uniquement",
    SILENT="Simulation des impacts locaux",MISC="Protections physiques locales",SETTINGS="Performances et apparence",ABOUT="Version, mises a jour et nouveautes"}
local function selectPage(name)
    if not S.Alive or not pages[name] then return end
    S.Page=name
    -- Never tween the ScrollingFrame itself: it can leave some tabs empty
    -- or offscreen after rapid switches and layout recalculations.
    for _,page in pairs(pages) do
        page.Visible=false
        page.Position=UDim2.fromOffset(0,0)
    end
    local activePage=pages[name]
    activePage.CanvasPosition=Vector2.zero
    activePage.Visible=true
    updateCanvas(name)
    task.defer(function()
        if S.Alive and S.Page==name then updateCanvas(name) end
    end)
    for n,item in pairs(nav) do
        local active=n==name
        item.Selected.Visible=active
        item.Line.Visible=active
        item.Selected.BackgroundColor3=S.Accent
        item.Selected.BackgroundTransparency=.85
        item.Line.BackgroundColor3=S.Accent
        item.Button.BackgroundColor3=active and C.CARD or C.SIDE
        item.Button.BackgroundTransparency=active and 0 or 1
        item.Title.TextColor3=active and C.WHITE or C.MUTED
        item.Dot.BackgroundColor3=active and S.Accent or C.DARK
        item.Dot.BackgroundTransparency=active and .06 or .24
    end
    pageCounter.Text=string.format("%02d / 07   -   WORKSPACE",table.find(tabs,name) or 1)
    pageCounter.TextColor3=S.Accent
    headerStripe.BackgroundColor3=S.Accent
    pageTitle.Text=tabTitles[name]
    pageDesc.Text=subtitles[name]
    runningDot.BackgroundColor3=S.Errors==0 and C.GREEN or C.GOLD
end
for n,item in pairs(nav) do on(item.Button.Activated,function()selectPage(n)end) end
local function order(page) orders[page]+=1 return orders[page] end
local function section(page,text)
    local row=make("Frame",{
        Size=UDim2.new(1,-2,0,29),
        LayoutOrder=order(page),BackgroundTransparency=1
    },pages[page])
    local accent=tabColors[page]
    table.insert(S.AccentBars,bar(row,11,17,3,10,accent))
    local label=txt(row,text:upper(),23,7,325,22,10,true,C.MUTED)
    label.TextTransparency=.01
    local hairline=bar(row,365,20,119,1,C.STROKE)
    hairline.BackgroundTransparency=.48
end
local function action(page,title,detail,caption,callback)
    local row=corner(make("Frame",{
        Size=UDim2.new(1,-2,0,63),
        LayoutOrder=order(page),BackgroundColor3=C.CARD,
        BorderSizePixel=0
    },pages[page]),ROUND.Card)
    local rim=stroke(row,C.STROKE,1)
    rim.Transparency=.65
    local dot=corner(make("Frame",{
        Position=UDim2.fromOffset(14,15),
        Size=UDim2.fromOffset(7,7),
        BackgroundColor3=tabColors[page],BorderSizePixel=0
    },row),4)
    table.insert(S.AccentBars,dot)
    txt(row,title,28,7,320,23,12,true,C.WHITE)
    description(row,detail,28,32,314,19)
    local destructive=(caption=="RESET" or caption=="REMOVE")
    local control=btn(row,caption,365,14,120,35,C.HOVER)
    local label=buttonCaption(control)
    if destructive then
        stroke(control,C.STROKE,1).Transparency=.35
        label.TextColor3=C.TEXT
    else
        control.BackgroundColor3=S.Accent
        table.insert(S.AccentButtons,control)
        label.TextColor3=C.DARK
    end
    on(row.MouseEnter,function()
        if not S.Alive then return end
        animateUI(row,{BackgroundColor3=C.HOVER},.12)
        rim.Transparency=.27
    end)
    on(row.MouseLeave,function()
        if not S.Alive then return end
        animateUI(row,{BackgroundColor3=C.CARD},.12)
        rim.Transparency=.78
    end)
    on(control.MouseEnter,function()
        if S.Alive then
            animateUI(control,{BackgroundColor3=destructive and C.STROKE or S.Accent:Lerp(C.WHITE,.16)},.12)
        end
    end)
    on(control.MouseLeave,function()
        if S.Alive then
            animateUI(control,{BackgroundColor3=destructive and C.HOVER or S.Accent},.12)
        end
    end)
    on(control.Activated,function()
        if S.Alive then
            safeAction("Bouton "..title,callback)
        end
    end)
    return control
end
local function toggle(page,key,title,detail)
    local row=btn(pages[page],"",0,0,502,60,C.CARD)
    row.Size=UDim2.new(1,-2,0,60)
    -- The button already uses the shared rounded corner helper.
    row.LayoutOrder=order(page)
    row.BackgroundTransparency=.20
    local rim=stroke(row,C.STROKE,1)
    rim.Transparency=.82
    txt(row,title,16,9,327,23,12,true,C.WHITE)
    description(row,detail,16,31,326,19)
    local stateText=txt(row,"OFF",360,18,48,20,9,true,C.MUTED)
    stateText.TextXAlignment=Enum.TextXAlignment.Right
    local track=corner(make("Frame",{
        Position=UDim2.new(1,-62,.5,-12),
        Size=UDim2.fromOffset(48,25),
        BackgroundColor3=C.STROKE,
        BorderSizePixel=0,Active=false
    },row),13)
    local knob=corner(make("Frame",{
        Position=UDim2.fromOffset(3,3),
        Size=UDim2.fromOffset(19,19),
        BackgroundColor3=C.WHITE,
        BorderSizePixel=0,Active=false
    },track),10)
    local function refreshToggle()
        local enabled=cfg[key]==true
        track.BackgroundColor3=enabled and S.Accent or C.STROKE
        knob.Position=UDim2.fromOffset(enabled and 26 or 3,3)
        stateText.Text=enabled and "ON" or "OFF"
        stateText.TextColor3=enabled and S.Accent or C.MUTED
    end
    on(row.Activated,function()
        cfg[key]=not cfg[key]
        save()
        if key~="Animations" then
            notify(title.." / "..(cfg[key] and "ON" or "OFF"),"INFO")
        end
        local enabled=cfg[key]
        stateText.Text=enabled and "ON" or "OFF"
        stateText.TextColor3=enabled and S.Accent or C.MUTED
        animateUI(track,{BackgroundColor3=enabled and S.Accent or C.STROKE},.17)
        animateUI(knob,{Position=UDim2.fromOffset(enabled and 26 or 3,3)},.17)
    end)
    on(row.MouseEnter,function()
        animateUI(row,{BackgroundTransparency=0},.14)
        animateUI(rim,{Transparency=.47},.14)
    end)
    on(row.MouseLeave,function()
        animateUI(row,{BackgroundTransparency=.20},.14)
        animateUI(rim,{Transparency=.82},.14)
    end)
    table.insert(S.AccentToggles,{Key=key,Track=track,Label=stateText})
    table.insert(S.Toggles,refreshToggle)
    refreshToggle()
end
local function choices(page,title,key,options)
    local row=corner(make("Frame",{Size=UDim2.new(1,-2,0,79),
        LayoutOrder=order(page),BackgroundColor3=C.CARD,
        BorderSizePixel=0},pages[page]),ROUND.Card)
    stroke(row,C.STROKE,1).Transparency=.76
    txt(row,title,14,6,460,21,12,true,C.WHITE)
    local holder=corner(make("Frame",{Position=UDim2.fromOffset(12,34),
        Size=UDim2.new(1,-24,0,35),BackgroundColor3=C.DARK,
        BorderSizePixel=0},row),ROUND.Compact)
    local items={}
    for i,opt in ipairs(options) do
        local count=#options
        local gap=4
        local width=math.floor((466-(count-1)*gap)/count)
        local control=btn(holder,opt,4+(i-1)*(width+gap),4,width-4,27,C.DARK)
        local caption=buttonCaption(control)
        caption.TextSize=10
        items[opt]=control
        on(control.Activated,function()
            cfg[key]=opt
            if key=="Accent" then cfg.RGB=false end
            save()
            for _,fn in ipairs(S.Selectors) do fn() end
            for _,fn in ipairs(S.Toggles) do fn() end
        end)
    end
    table.insert(S.Selectors,function()
        for opt,control in pairs(items) do
            local active=cfg[key]==opt
            control.BackgroundColor3=active and S.Accent or C.DARK
            buttonCaption(control).TextColor3=active and C.DARK or C.MUTED
        end
    end)
end
local function slider(page,key,title,low,high,step,unit)
    local row=corner(make("Frame",{Size=UDim2.new(1,-2,0,71),
        LayoutOrder=order(page),BackgroundColor3=C.CARD,
        BorderSizePixel=0},pages[page]),ROUND.Card)
    txt(row,title,14,5,316,23,12,true,C.WHITE)
    local value=txt(row,"",357,6,125,22,11,true,S.Accent)
    table.insert(S.AccentLabels,value)
    value.TextXAlignment=Enum.TextXAlignment.Right
    local zone=make("Frame",{Position=UDim2.fromOffset(16,38),
        Size=UDim2.new(1,-32,0,23),BackgroundTransparency=1,
        Active=true},row)
    local rail=corner(make("Frame",{Position=UDim2.new(0,0,.5,-2),
        Size=UDim2.new(1,0,0,4),BackgroundColor3=C.SIDE,
        BorderSizePixel=0},zone),4)
    local fill=corner(make("Frame",{Size=UDim2.fromScale(0,1),
        BackgroundColor3=S.Accent,BorderSizePixel=0},rail),4)
    table.insert(S.SliderFills,fill)
    local knob=corner(make("Frame",{AnchorPoint=Vector2.new(.5,.5),
        Size=UDim2.fromOffset(12,12),BackgroundColor3=C.WHITE,
        BorderSizePixel=0},rail),7)
    local function refreshSlider()
        local f=math.clamp((cfg[key]-low)/(high-low),0,1)
        fill.Size=UDim2.fromScale(f,1)
        knob.Position=UDim2.fromScale(f,.5)
        value.Text=(step<1 and string.format("%.2f",cfg[key])
            or tostring(math.floor(cfg[key]+.5)))..(unit or "")
    end
    local function set(x)
        if zone.AbsoluteSize.X<2 then return end
        local f=math.clamp((x-zone.AbsolutePosition.X)/zone.AbsoluteSize.X,0,1)
        cfg[key]=math.clamp(math.floor((low+f*(high-low))/step+.5)*step,low,high)
        save()
        refreshSlider()
        if key=="MenuScale" then rescale() end
        if key=="UIRoundness" then refreshRoundness() end
    end
    on(zone.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
            or input.UserInputType==Enum.UserInputType.Touch then
            S.MouseDrag={Touch=input.UserInputType==Enum.UserInputType.Touch,
                Input=input,Set=set}
            set(input.Position.X)
        end
    end)
    table.insert(S.Sliders,refreshSlider)
    refreshSlider()
end
on(UIS.InputChanged,function(input)
    local d=S.MouseDrag
    if d and ((d.Touch and d.Input==input) or (not d.Touch and input.UserInputType==Enum.UserInputType.MouseMovement)) then d.Set(input.Position.X) end
end)
on(UIS.InputEnded,function(input)
    local d=S.MouseDrag
    if d and ((d.Touch and input==d.Input) or (not d.Touch and input.UserInputType==Enum.UserInputType.MouseButton1)) then S.MouseDrag=nil end
end)
local function refresh()
    for _,fn in ipairs(S.Toggles) do fn() end
    for _,fn in ipairs(S.Selectors) do fn() end
    for _,fn in ipairs(S.Sliders) do fn() end
end

-- Training models and ESP visuals.
local folder=make("Folder",{Name=DNAME},WS)
local dummyInfo,weaponInfo,hitInfo
local function dummyCount()
    local n=0
    for _,m in ipairs(S.Dummies) do if m.Parent==folder then n+=1 end end
    return n
end
local function changeInfo()
    if dummyInfo then dummyInfo.Text="Targets: "..dummyCount().." / 3" end
    if weaponInfo then
        local state=S.EquipError and "EQUIP FAILED" or
            (S.Reloading and "RELOADING" or (S.Armed and "READY" or "HOLSTERED"))
        weaponInfo.Text="Ammo: "..S.Ammo.." / 12   /   "..state
    end
    if hitInfo then hitInfo.Text="HITS  "..S.Hits.."   /   SHOTS  "..S.Shots.."   /   KOs  "..S.KOs end
end
local function clearVisual(d)
    for _,k in ipairs({"Folder","Glow","SkeletonUI","Tracer"}) do if d[k] then d[k]:Destroy();d[k]=nil end end
    d.Edges=nil;d.Bones=nil;d.SkeletonRig=nil;d.Root=nil;d.Head=nil;d.Model=nil;d.LastGeometry=0;d.Visible=false
    d.CacheSize=nil;d.CacheOffset=nil;d.CacheAt=nil
    d.Billboard=nil;d.HealthFill=nil;d.LastHP=nil
end
local function addTarget(model)
    if model~=Me and not S.Targets[model] then S.Targets[model]={LastGeometry=0,Visible=false} end
end
local function removeTarget(model)
    local d=S.Targets[model]
    if d then clearVisual(d);S.Targets[model]=nil end
end
local function clearDummies()
    for _,model in ipairs(S.Dummies) do
        removeTarget(model)
        if model.Parent then model:Destroy() end
    end
    table.clear(S.Dummies);changeInfo()
end
local function dummyPart(model,name,size,cf,color,alpha)
    return make("Part",{Name=name,Size=size,CFrame=cf,Color=color,Transparency=alpha or 0,
        Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,CastShadow=false,Material=Enum.Material.SmoothPlastic},model)
end
local DUMMY_MAX_HP=100
local function dummyHP(model)
    if not model or not model.Parent then return 0 end
    return math.clamp(tonumber(model:GetAttribute("VisionProHealth")) or 0,0,DUMMY_MAX_HP)
end
local function colorDummy(model,down)
    for _,p in ipairs(model:GetChildren()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            local original=p:GetAttribute("VP_OriginalColor")
            if down then
                p.Color=C.RED
            elseif typeof(original)=="Color3" then
                p.Color=original
            end
        end
    end
end
local function resetDummyHP(model)
    if not model or model.Parent~=folder then return end
    model:SetAttribute("VisionProHealth",DUMMY_MAX_HP)
    model:SetAttribute("VisionProDown",false)
    colorDummy(model,false)
end
local function resetAllHP()
    for _,model in ipairs(S.Dummies) do
        resetDummyHP(model)
    end
    changeInfo()
end
local function spawnDummies()
    local root=Me.Character and Me.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    clearDummies()
    local camera=WS.CurrentCamera
    local v=camera and camera.CFrame.LookVector or root.CFrame.LookVector
    local forward=Vector3.new(v.X,0,v.Z)
    if forward.Magnitude<.05 then forward=Vector3.new(0,0,-1) end
    forward=forward.Unit
    local right=Vector3.new(-forward.Z,0,forward.X)
    local filter=RaycastParams.new()
    filter.FilterType=Enum.RaycastFilterType.Exclude
    filter.FilterDescendantsInstances={Me.Character,folder}
    filter.RespectCanCollide=true
    -- 10 studs between mannequins, with ground detection for uneven terrain.
    for i=1,3 do
        local pos=root.Position+forward*23+right*(i-2)*10
        local ground=WS:Raycast(pos+Vector3.new(0,12,0),Vector3.new(0,-85,0),filter)
        local height=root.Position.Y
        if ground and math.abs(ground.Position.Y-root.Position.Y)<19 then
            height=ground.Position.Y+3
        end
        local center=Vector3.new(pos.X,height,pos.Z)
        local cf=CFrame.lookAt(center,center-forward)
        local model=make("Model",{Name=string.format("VP_TARGET_%02d",i)},folder)
        model:SetAttribute("VisionProLocalDummy",true)
        model:SetAttribute("VisionProHealth",DUMMY_MAX_HP)
        model:SetAttribute("VisionProDown",false)
        local r=dummyPart(model,"HumanoidRootPart",Vector3.new(2,2,1),cf,C.WHITE,1)
        dummyPart(model,"Torso",Vector3.new(2,2,1),cf,Color3.fromRGB(68,113,177))
        dummyPart(model,"ChestPlate",Vector3.new(1.45,.33,.08),
            cf*CFrame.new(0,.29,-.545),C.CYAN)
        dummyPart(model,"Belt",Vector3.new(1.83,.19,.10),
            cf*CFrame.new(0,-.78,-.52),C.DARK)
        local head=dummyPart(model,"Head",Vector3.new(1.4,1.4,1.4),cf*CFrame.new(0,2,0),C.WHITE)
        head.Shape=Enum.PartType.Ball
        dummyPart(model,"LeftArm",Vector3.new(.8,2,1),cf*CFrame.new(-1.5,0,0),C.CYAN)
        dummyPart(model,"RightArm",Vector3.new(.8,2,1),cf*CFrame.new(1.5,0,0),C.CYAN)
        dummyPart(model,"LeftLeg",Vector3.new(.8,2,1),cf*CFrame.new(-.5,-2,0),C.DARK)
        dummyPart(model,"RightLeg",Vector3.new(.8,2,1),cf*CFrame.new(.5,-2,0),C.DARK)
        model.PrimaryPart=r
        for _,p in ipairs(model:GetChildren()) do
            if p:IsA("BasePart") then p:SetAttribute("VP_OriginalColor",p.Color) end
        end
        table.insert(S.Dummies,model)
        addTarget(model)
    end
    cfg.ShowNPC=true
    save();refresh();changeInfo()
end
local function partOf(model,name)
    local aliases={LeftArm="Left Arm",RightArm="Right Arm",LeftLeg="Left Leg",RightLeg="Right Leg"}
    local p=model:FindFirstChild(name) or model:FindFirstChild(aliases[name] or name)
    return p and p:IsA("BasePart") and p or nil
end
local R6={{"Head","Torso"},{"Torso","LeftArm"},{"Torso","RightArm"},{"Torso","LeftLeg"},{"Torso","RightLeg"}}
local R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"LowerTorso","LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}}
local edges={}
for _,a in ipairs({-1,1}) do for _,b in ipairs({-1,1}) do
    for _,axis in ipairs({"X","Y","Z"}) do table.insert(edges,{axis,a,b}) end
end end
local function teamColor(player)
    if cfg.TeamColors and player and Me.Team and player.Team and not Me.Neutral and not player.Neutral then
        return Me.Team==player.Team and C.GREEN or C.RED
    end
    return C.BLUE
end
local function boxColor()
    if cfg.BoxColor=="RGB" then return Color3.fromHSV((os.clock()*.32)%1,.85,1) end
    if cfg.BoxColor=="ACCENT" then return S.Accent end
    return cfg.BoxColor=="VIOLET" and C.PURPLE or C.BLUE
end
local function newVisual(d,model)
    d.Model=model
    d.Root=partOf(model,"HumanoidRootPart")
    d.Head=partOf(model,"Head")
    if not d.Root or not d.Head then return end
    d.Folder=make("Folder",{Name="VisionVisual"},PG)
    d.Edges={}
    for _,def in ipairs(edges) do
        local e=make("BoxHandleAdornment",{Adornee=d.Root,AlwaysOnTop=true,Visible=false,
            Size=Vector3.one,Color3=C.BLUE,Transparency=0,ZIndex=4},d.Folder)
        table.insert(d.Edges,{Item=e,Def=def})
    end
    d.Glow=make("Highlight",{Adornee=model,Enabled=false,FillTransparency=.96,OutlineTransparency=.06,
        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},model)
    -- Minimal floating unit HUD, updated only when HP changes.
    d.Billboard=make("BillboardGui",{
        Adornee=d.Head,Size=UDim2.fromOffset(192,71),
        StudsOffsetWorldSpace=Vector3.new(0,2.05,0),AlwaysOnTop=true,
        Enabled=false,MaxDistance=cfg.Range,LightInfluence=0
    },d.Folder)
    local panel=corner(make("Frame",{
        Position=UDim2.fromOffset(5,1),Size=UDim2.fromOffset(182,59),
        BackgroundColor3=C.DARK,BackgroundTransparency=.07,BorderSizePixel=0
    },d.Billboard),ROUND.Compact)
    local rim=stroke(panel,C.STROKE,1);rim.Transparency=.25
    local accent=bar(panel,0,10,3,38,C.PURPLE)
    d.Panel=panel;d.PanelRim=rim;d.Accent=accent
    d.Nametxt=txt(panel,"",11,4,107,20,11,true,C.WHITE)
    d.Subtxt=txt(panel,"",11,26,84,17,10,false,C.MUTED)
    d.HPText=txt(panel,"",100,26,70,17,10,true,C.TEXT)
    d.HPText.TextXAlignment=Enum.TextXAlignment.Right
    d.StateText=txt(panel,"",121,4,50,19,9,true,C.CYAN)
    d.StateText.TextXAlignment=Enum.TextXAlignment.Right
    d.HealthRail=corner(make("Frame",{
        Position=UDim2.fromOffset(11,49),Size=UDim2.fromOffset(159,4),
        BackgroundColor3=C.SIDE,BorderSizePixel=0
    },panel),3)
    d.HealthFill=corner(make("Frame",{
        Size=UDim2.fromScale(1,1),BackgroundColor3=C.GREEN,BorderSizePixel=0
    },d.HealthRail),3)
    d.LastHP=nil

end
local function bounds(d,model,now)
    if d.CacheSize and d.CacheOffset and d.CacheAt and now-d.CacheAt<.25 then
        return d.Root.CFrame*d.CacheOffset,d.CacheSize
    end
    local ok,cf,size=pcall(function()return model:GetBoundingBox()end)
    if not ok or not cf then return nil,nil end
    d.CacheOffset=d.Root.CFrame:ToObjectSpace(cf);d.CacheSize=size;d.CacheAt=now
    return cf,size
end
local function updateGeometry(d,model,now)
    local cf,sz=bounds(d,model,now)
    if not cf then return end
    local w,h,z=math.clamp(sz.X,2.4,6),math.clamp(sz.Y,4.3,10),math.clamp(sz.Z,1.5,6)
    local relative=d.Root.CFrame:ToObjectSpace(cf)
    if relative.Position.Magnitude>8 then relative=CFrame.new(0,1,0) end
    for _,v in ipairs(d.Edges) do
        local axis,a,b=v.Def[1],v.Def[2],v.Def[3]
        local pos,size
        if axis=="X" then pos=Vector3.new(0,a*h/2,b*z/2);size=Vector3.new(w,cfg.Thickness,cfg.Thickness)
        elseif axis=="Y" then pos=Vector3.new(a*w/2,0,b*z/2);size=Vector3.new(cfg.Thickness,h,cfg.Thickness)
        else pos=Vector3.new(a*w/2,b*h/2,0);size=Vector3.new(cfg.Thickness,cfg.Thickness,z) end
        v.Item.CFrame=relative*CFrame.new(pos);v.Item.Size=size
    end
end
local ray=RaycastParams.new()
ray.FilterType=Enum.RaycastFilterType.Exclude
ray.IgnoreWater=true
local function see(d,model,cam)
    if cfg.ThroughWalls then return true end
    ray.FilterDescendantsInstances=Me.Character and {Me.Character} or {}
    local origin=cam.CFrame.Position;local direction=d.Root.Position-origin
    local hit=WS:Raycast(origin,direction,ray)
    return not hit or hit.Instance:IsDescendantOf(model)
end
local function segment(frame,a,b,color,thick)
    local delta=b-a
    if delta.Magnitude<1 then frame.Visible=false return end
    frame.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
    frame.Size=UDim2.fromOffset(delta.Magnitude,thick)
    frame.Rotation=math.deg(math.atan2(delta.Y,delta.X))
    frame.BackgroundColor3=color;frame.Visible=true
end
local function hideExtras(d)
    if d.SkeletonUI then d.SkeletonUI.Visible=false end
    if d.Tracer then d.Tracer.Visible=false end
end
local function drawExtras(d,model,cam)
    if not d.Visible or not see(d,model,cam) then hideExtras(d) return end
    local tint=boxColor()
    if cfg.Skeleton then
        local rig=partOf(model,"UpperTorso") and "R15" or "R6"
        local links=rig=="R15" and R15 or R6
        if d.SkeletonRig~=rig then
            if d.SkeletonUI then d.SkeletonUI:Destroy() end
            d.SkeletonUI=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},overlay)
            d.Bones={}
            for i=1,#links do d.Bones[i]=corner(make("Frame",{AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=tint,
                BorderSizePixel=0,Visible=false},d.SkeletonUI),3) end
            d.SkeletonRig=rig
        end
        d.SkeletonUI.Visible=true
        for i,connection in ipairs(links) do
            local p1=partOf(model,connection[1]);local p2=partOf(model,connection[2])
            local line=d.Bones[i]
            if p1 and p2 then
                local a,va=cam:WorldToViewportPoint(p1.Position)
                local b,vb=cam:WorldToViewportPoint(p2.Position)
                if va and vb and a.Z>0 and b.Z>0 then segment(line,Vector2.new(a.X,a.Y),Vector2.new(b.X,b.Y),tint,2)
                else line.Visible=false end
            else line.Visible=false end
        end
    elseif d.SkeletonUI then d.SkeletonUI.Visible=false end
    if cfg.Tracers then
        if not d.Tracer then d.Tracer=corner(make("Frame",{AnchorPoint=Vector2.new(.5,.5),BorderSizePixel=0},overlay),2) end
        local pt,visible=cam:WorldToViewportPoint(d.Root.Position)
        if visible and pt.Z>0 then
            local vp=cam.ViewportSize
            segment(d.Tracer,Vector2.new(vp.X/2,vp.Y-12),Vector2.new(pt.X,pt.Y),boxColor(),2)
        else d.Tracer.Visible=false end
    elseif d.Tracer then d.Tracer.Visible=false end
end
local function updateTargets()
    local ownRoot=Me.Character and Me.Character:FindFirstChild("HumanoidRootPart")
    for target,d in pairs(S.Targets) do
        local player=target:IsA("Player") and target or nil
        local model=player and player.Character or (target:IsA("Model") and target or nil)
        if model~=d.Model then
            clearVisual(d)
            if model and model:IsDescendantOf(WS) then newVisual(d,model) end
        elseif model and not d.Folder and model:IsDescendantOf(WS) then
            -- Retry while R6/R15 parts are still being created.
            newVisual(d,model)
        end
        local root=d.Root
        if root and root.Parent and model and model:IsDescendantOf(WS) and d.Billboard then
            local dist=ownRoot and (ownRoot.Position-root.Position).Magnitude or math.huge
            local ally=player and Me.Team and player.Team and not Me.Neutral and not player.Neutral and player.Team==Me.Team
            local humanoid=model:FindFirstChildOfClass("Humanoid")
            local isDummy=model:GetAttribute("VisionProLocalDummy")==true
            local hp=isDummy and dummyHP(model) or (humanoid and humanoid.Health or nil)
            local maxHP=isDummy and DUMMY_MAX_HP or (humanoid and math.max(1,humanoid.MaxHealth) or nil)
            local alive=(hp==nil or hp>0)
            d.Visible=cfg.ESP and (alive or isDummy) and dist<=cfg.Range
                and (player~=nil or cfg.ShowNPC) and (cfg.ShowAllies or not ally)
            if d.Visible and not cfg.ThroughWalls then
                local camera=WS.CurrentCamera
                if camera and not see(d,model,camera) then d.Visible=false end
            end
            local detailed=cfg.ESPDetail=="FULL"
            d.ShowExtras=d.Visible and dist<=cfg.ESPExtraRange
            d.Billboard.Enabled=d.Visible and (cfg.Names or (detailed and (cfg.Distance or (cfg.Health and hp~=nil))))
            d.Billboard.MaxDistance=cfg.Range
            d.Billboard.AlwaysOnTop=cfg.ThroughWalls
            d.Accent.BackgroundColor3=boxColor()
            local name=player and player.DisplayName or model.Name
            if isDummy then
                name=string.format("TARGET %02d",tonumber(model.Name:match("(%d+)$")) or 0)
            end
            d.Nametxt.Text=cfg.Names and (not alive and isDummy and (name.."  /  DOWN") or name) or ""
            d.Nametxt.Visible=cfg.Names
            d.StateText.Text=(isDummy and (not alive and "DOWN" or "BOT")) or ""
            d.StateText.TextColor3=alive and C.CYAN or C.RED
            d.Subtxt.Text=cfg.Distance and (math.floor(dist+.5).." studs") or ""
            d.Subtxt.Visible=detailed and cfg.Distance
            d.HPText.Visible=detailed and cfg.Health and hp~=nil
            d.HealthRail.Visible=detailed and cfg.Health and hp~=nil
            if hp~=nil and maxHP~=nil then
                local ratio=math.clamp(hp/maxHP,0,1)
                d.HPText.Text=string.format("%d / %d",math.ceil(hp),math.ceil(maxHP))
                if d.LastHP~=hp then
                    d.LastHP=hp
                    Tween:Create(d.HealthFill,TweenInfo.new(.19,Enum.EasingStyle.Quad),{
                        Size=UDim2.fromScale(ratio,1)
                    }):Play()
                end
                local tone=(ratio>.55 and C.GREEN) or (ratio>.25 and C.PURPLE) or C.RED
                d.HPText.TextColor3=tone
                d.HealthFill.BackgroundColor3=tone
            end
            d.Glow.Enabled=d.ShowExtras and cfg.Highlight
            d.Glow.DepthMode=cfg.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            d.Glow.OutlineColor=cfg.TeamColors and teamColor(player) or boxColor()
            d.Glow.FillColor=cfg.TeamColors and teamColor(player) or boxColor()
            for _,edge in ipairs(d.Edges) do
                edge.Item.Visible=d.Visible and cfg.Box
                edge.Item.AlwaysOnTop=cfg.ThroughWalls
            end
            local geometryGap=cfg.PerformanceMode=="LOW" and .38
                or cfg.PerformanceMode=="HIGH" and .16 or .23
            local geometryNow=os.clock()
            if d.Visible and cfg.Box and geometryNow-d.LastGeometry>=geometryGap then
                updateGeometry(d,model,geometryNow)
                d.LastGeometry=geometryNow
            end
        else
            d.Visible=false
            d.ShowExtras=false
            if d.Billboard then d.Billboard.Enabled=false end
            if d.Edges then for _,edge in ipairs(d.Edges) do edge.Item.Visible=false end end
        end
    end
end
local function drawEffects()
    local cam=WS.CurrentCamera
    if not cam then return end
    local color=boxColor()
    for _,d in pairs(S.Targets) do
        if d.Edges then for _,edge in ipairs(d.Edges) do edge.Item.Color3=(d.Model and d.Model:GetAttribute("VisionProDown")) and C.RED or color end end
        if d.Model and d.Visible and d.ShowExtras and d.Root then drawExtras(d,d.Model,cam)
        else hideExtras(d) end
    end
end
local function attachPlayer(player)
    if player==Me or S.Players[player] then return end
    addTarget(player)
    S.Players[player]={
        player.CharacterRemoving:Connect(function()
            local d=S.Targets[player]
            if d then clearVisual(d) end
        end),
        player.CharacterAdded:Connect(function()
            local d=S.Targets[player]
            if d then clearVisual(d) end
        end)
    }
end
local function detachPlayer(player)
    local c=S.Players[player]
    if c then for _,v in ipairs(c) do v:Disconnect() end end
    S.Players[player]=nil;removeTarget(player)
end
for _,p in ipairs(Players:GetPlayers()) do attachPlayer(p) end
on(Players.PlayerAdded,attachPlayer)
on(Players.PlayerRemoving,detachPlayer)
on(Tags:GetInstanceAddedSignal(TAG),function(x)if x:IsA("Model") then addTarget(x) end end)
on(Tags:GetInstanceRemovedSignal(TAG),function(x)if not x:GetAttribute("VisionProLocalDummy") then removeTarget(x) end end)
for _,x in ipairs(Tags:GetTagged(TAG)) do if x:IsA("Model") then addTarget(x) end end

-- Local-only aiming and training gun.
-- Aim and Silent Aim are intentionally restricted to locally created practice mannequins.
local aimRay=RaycastParams.new()
aimRay.FilterType=Enum.RaycastFilterType.Exclude
aimRay.IgnoreWater=true
local function unobstructed(camera,part)
    aimRay.FilterDescendantsInstances=Me.Character and {Me.Character,folder} or {folder}
    local vector=part.Position-camera.CFrame.Position
    if vector.Magnitude<.05 then return true end
    return WS:Raycast(camera.CFrame.Position,vector,aimRay)==nil
end
local function closestDummy(radius,bone,checkWalls)
    local camera=WS.CurrentCamera
    if not camera then return nil,nil end
    local center=camera.ViewportSize/2
    local best=radius
    local result,selectedModel=nil,nil
    local name=bone=="BODY" and "Torso" or "Head"
    for _,model in ipairs(S.Dummies) do
        if model.Parent==folder and not Players:GetPlayerFromCharacter(model) and dummyHP(model)>0 then
            local part=model:FindFirstChild(name)
            if part then
                local point,visible=camera:WorldToViewportPoint(part.Position)
                if visible and point.Z>0 then
                    local distance=(Vector2.new(point.X,point.Y)-center).Magnitude
                    if distance<best and (not checkWalls or unobstructed(camera,part)) then
                        best=distance
                        result=part
                        selectedModel=model
                    end
                end
            end
        end
    end
    return result,selectedModel
end
local cross=txt(ui,"+",0,0,28,28,26,true,C.CYAN)
cross.AnchorPoint=Vector2.new(.5,.5)
cross.Position=UDim2.fromScale(.5,.5)
cross.TextXAlignment=Enum.TextXAlignment.Center
cross.Visible=false
local fov=corner(make("Frame",{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    BackgroundTransparency=1,Visible=false},ui),999)
local fovOutline=stroke(fov,C.PURPLE,1.5)
fovOutline.Transparency=.4
local marker=txt(ui,"+",0,0,30,30,28,true,C.GREEN)
marker.AnchorPoint=Vector2.new(.5,.5)
marker.TextXAlignment=Enum.TextXAlignment.Center
marker.Visible=false
local gunHUD=corner(make("Frame",{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-24,1,-42),
    Size=UDim2.fromOffset(204,67),BackgroundColor3=C.SIDE,BorderSizePixel=0,Visible=false},ui),ROUND.Card)
grad(gunHUD,Color3.fromRGB(34,43,68),Color3.fromRGB(29,50,73),12)
stroke(gunHUD,C.STROKE,1).Transparency=.3
local gunHudAccent=bar(gunHUD,0,11,3,44,C.PURPLE)
local gunHudSecond=bar(gunHUD,196,11,3,44,C.CYAN)
txt(gunHUD,"VP-9 MKII  /  TRAINING",13,5,175,17,9,true,C.CYAN)
local ammoText=txt(gunHUD,"12 / 12",13,20,169,24,19,true)
local hintText=txt(gunHUD,"LMB FIRE   /   R RELOAD",13,47,180,17,9,false,C.TEXT)
local function setMenu(open)
    if not S.Alive then return end
    S.Open=open;window.Visible=open
    gunHUD.Visible=S.Armed and not open
end
local function updateGun()
    changeInfo()
    ammoText.Text=S.Ammo.." / 12"
    gunHUD.Visible=S.Armed and not S.Open
end
local function removeGun()
    S.GunGeneration+=1
    if S.Gun then S.Gun:Destroy() end
    S.Gun=nil;S.Muzzle=nil;S.FlashLight=nil;S.Armed=false;S.Reloading=false;S.Ammo=12
    S.EquipError=nil
    updateGun()
end
local function reload()
    if not S.Alive or S.Reloading or S.Ammo>=12 or not S.Armed then return end
    S.Reloading=true;hintText.Text="RELOADING...";changeInfo()
    local ticket=S.GunGeneration
    task.delay(1.25,function()
        if S.Alive and ticket==S.GunGeneration then
            S.Reloading=false;S.Ammo=12;hintText.Text="LMB FIRE   /   R RELOAD";updateGun()
        end
    end)
end
local function beam(a,b,color)
    local difference=b-a
    if difference.Magnitude<.1 then return end
    local part=make("Part",{Name="VP_TrainingLaser",Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,
        CastShadow=false,Material=Enum.Material.Neon,Color=color,Transparency=.08,
        Size=Vector3.new(.1,.1,difference.Magnitude),CFrame=CFrame.lookAt((a+b)/2,b)},WS)
    Tween:Create(part,TweenInfo.new(.24),{Transparency=1}):Play()
    task.delay(.28,function()if part.Parent then part:Destroy() end end)
end
local function impactDummy(model,damage)
    if not S.Alive or not model or model.Parent~=folder then return 0 end
    local hp=dummyHP(model)
    if hp<=0 then return 0 end
    local after=math.max(0,hp-damage)
    model:SetAttribute("VisionProHealth",after)
    S.Damage+=hp-after
    if after==0 then
        S.KOs+=1
        model:SetAttribute("VisionProDown",true)
        colorDummy(model,true)
        if cfg.AutoRespawn then
            task.delay(3,function()
                if S.Alive and model.Parent==folder and model:GetAttribute("VisionProDown")==true then
                    resetDummyHP(model)
                end
            end)
        end
    end
    return after
end
local function impactPopup(model,amount)
    local head=model and model:FindFirstChild("Head")
    if not head then return end
    local billboard=make("BillboardGui",{
        Adornee=head,Size=UDim2.fromOffset(78,36),
        StudsOffsetWorldSpace=Vector3.new(0,2.5,0),
        AlwaysOnTop=true,LightInfluence=0
    },head)
    local text=txt(billboard,"-"..math.floor(amount),0,0,78,30,19,true,C.GOLD)
    text.TextXAlignment=Enum.TextXAlignment.Center
    Tween:Create(billboard,TweenInfo.new(.45,Enum.EasingStyle.Quad),{
        StudsOffsetWorldSpace=Vector3.new(0,3.5,0)
    }):Play()
    Tween:Create(text,TweenInfo.new(.45),{TextTransparency=1}):Play()
    task.delay(.5,function()if billboard.Parent then billboard:Destroy() end end)
end

local function muzzleFlash()
    if not S.Muzzle or not S.Muzzle.Parent then return end
    local muzzle=S.Muzzle
    local light=S.FlashLight
    S.FlashToken+=1
    local token=S.FlashToken
    if light and light.Parent then light.Enabled=true end
    task.delay(.065,function()
        if S.Alive and token==S.FlashToken and light and light.Parent then
            light.Enabled=false
        end
    end)
    local flash=make("Part",{
        Name="VP_Flash",Shape=Enum.PartType.Ball,
        Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,
        CastShadow=false,Material=Enum.Material.Neon,Color=C.GOLD,
        Size=Vector3.new(.4,.4,.4),
        CFrame=CFrame.new(S.Muzzle.Position),Transparency=.1
    },WS)
    Tween:Create(flash,TweenInfo.new(.13),{
        Size=Vector3.new(.03,.03,.03),Transparency=1
    }):Play()
    task.delay(.16,function()if flash.Parent then flash:Destroy() end end)
end

local function shoot()
    if not S.Alive or S.Open or not S.Armed or S.Reloading then return end
    if os.clock()-S.LastShot<.17 then return end
    if S.Ammo<=0 then reload() return end
    local cam=WS.CurrentCamera
    if not cam then return end
    S.LastShot=os.clock();S.Ammo-=1;S.Shots+=1
    local target,model=closestDummy(cfg.Preview and cfg.PreviewFOV or 26,
        cfg.PreviewPart,cfg.PreviewLOS)
    local from=(S.Muzzle and S.Muzzle.Parent and S.Muzzle.Position)
        or (cam.CFrame.Position+cam.CFrame.LookVector*2)
    muzzleFlash()
    local to=target and target.Position or (from+cam.CFrame.LookVector*140)
    beam(from,to,target and C.CYAN or C.PURPLE)
    cross.TextColor3=C.WHITE
    task.delay(.13,function()if S.Alive then cross.TextColor3=C.CYAN end end)
    if target and model then
        S.Hits+=1
        local oldHP=dummyHP(model)
        local hpAfter=impactDummy(model,cfg.ShotDamage)
        impactPopup(model,oldHP-hpAfter)
        hintText.Text="HIT  -"..(oldHP-hpAfter).."   /   "..hpAfter.." HP"
        local shotID=S.Shots
        task.delay(.65,function()
            if S.Alive and S.Shots==shotID and not S.Reloading then
                hintText.Text="LMB FIRE   /   R RELOAD"
            end
        end)
        if cfg.HitMarker then
            local pt=cam:WorldToViewportPoint(target.Position)
            marker.Position=UDim2.fromOffset(pt.X,pt.Y)
            marker.Visible=true;S.MarkerUntil=os.clock()+.22
        end
    end
    updateGun()
    if S.Ammo==0 then hintText.Text="R   /   RELOAD" end
end
local function equipGun()
    local backpack=Me:FindFirstChildOfClass("Backpack")
    local character=Me.Character
    if not backpack or not character then return end
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if not S.Gun or not S.Gun.Parent then
        S.GunGeneration+=1
        local tool=make("Tool",{
            Name="VP-9 MKII  |  Training",
            RequiresHandle=true,
            CanBeDropped=false,
            ManualActivationOnly=false,
            ToolTip="VISION PRO / MKII - Local practice pistol",
            Grip=CFrame.new(0,-.16,-.16)
        },nil)

        local dark=Color3.fromRGB(27,33,50)
        local metal=Color3.fromRGB(70,84,111)
        local steel=Color3.fromRGB(113,131,164)
        local soft=Color3.fromRGB(48,59,80)
        local gripColor=Color3.fromRGB(37,44,65)

        -- The Handle is the physical Roblox Tool grip.
        local handle=make("Part",{
            Name="Handle",
            Size=Vector3.new(.41,.83,.49),
            Color=gripColor,
            Material=Enum.Material.SmoothPlastic,
            CanCollide=false,CanTouch=false,CanQuery=false,
            Massless=true,CastShadow=false,
            TopSurface=Enum.SurfaceType.Smooth,
            BottomSurface=Enum.SurfaceType.Smooth
        },tool)

        local base=handle.CFrame
        local function piece(name,size,offset,color,material,shape)
            local properties={
                Name=name,Size=size,CFrame=base*offset,
                Color=color,Material=material or Enum.Material.Metal,
                CanCollide=false,CanTouch=false,CanQuery=false,
                Massless=true,CastShadow=false,
                TopSurface=Enum.SurfaceType.Smooth,
                BottomSurface=Enum.SurfaceType.Smooth
            }
            if shape then properties.Shape=shape end
            local p=make("Part",properties,tool)
            make("WeldConstraint",{Part0=handle,Part1=p},p)
            return p
        end

        -- Sculpted body, slide, ejection area and muzzle.
        piece("Receiver",Vector3.new(.56,.38,.97),CFrame.new(0,.36,-.24),metal)
        piece("ReceiverLower",Vector3.new(.49,.17,.72),CFrame.new(0,.14,-.18),soft)
        piece("Slide",Vector3.new(.59,.23,1.10),CFrame.new(0,.61,-.29),dark)
        piece("SlideUpper",Vector3.new(.49,.06,.98),CFrame.new(0,.75,-.28),steel)
        piece("EjectionPort",Vector3.new(.27,.016,.30),CFrame.new(.04,.789,-.15),soft)
        piece("TopAccent",Vector3.new(.11,.022,.69),CFrame.new(0,.791,-.41),C.PURPLE,Enum.Material.Neon)
        piece("Barrel",Vector3.new(.27,.26,.76),CFrame.new(0,.50,-1.01),steel)
        piece("BarrelBushing",Vector3.new(.36,.36,.14),CFrame.new(0,.50,-1.27),dark)
        piece("MuzzleRing",Vector3.new(.28,.28,.045),CFrame.new(0,.50,-1.355),C.BLUE,Enum.Material.Neon)
        piece("SlideRear",Vector3.new(.59,.24,.18),CFrame.new(0,.61,.23),soft)

        -- Sight picture with a cyan front bead and pale rear notches.
        piece("RearSight",Vector3.new(.40,.14,.11),CFrame.new(0,.86,.19),dark)
        piece("RearDotL",Vector3.new(.05,.04,.035),CFrame.new(-.125,.945,.19),C.CYAN,Enum.Material.Neon)
        piece("RearDotR",Vector3.new(.05,.04,.035),CFrame.new(.125,.945,.19),C.CYAN,Enum.Material.Neon)
        piece("FrontSight",Vector3.new(.14,.13,.12),CFrame.new(0,.86,-.92),dark)
        piece("FrontFiber",Vector3.new(.06,.055,.035),CFrame.new(0,.955,-.92),C.CYAN,Enum.Material.Neon)

        -- Grip texture and controls: side plates, thumb release, rail.
        for _,side in ipairs({-1,1}) do
            piece("GripPlate",Vector3.new(.035,.52,.37),CFrame.new(side*.229,-.12,.008),soft,Enum.Material.SmoothPlastic)
            piece("GripStripe",Vector3.new(.042,.055,.34),CFrame.new(side*.253,-.29,.008),C.PURPLE,Enum.Material.Neon)
            piece("SlideVent1",Vector3.new(.025,.125,.035),CFrame.new(side*.307,.61,.055),steel)
            piece("SlideVent2",Vector3.new(.025,.125,.035),CFrame.new(side*.307,.61,.12),steel)
            piece("SlideVent3",Vector3.new(.025,.125,.035),CFrame.new(side*.307,.61,.185),steel)
        end
        piece("MagazineBase",Vector3.new(.38,.12,.40),CFrame.new(0,-.49,.015),metal)
        piece("MagazineRelease",Vector3.new(.055,.085,.085),CFrame.new(.303,.18,.085),C.CYAN,Enum.Material.Neon)
        piece("TriggerGuardFront",Vector3.new(.38,.09,.12),CFrame.new(0,-.07,-.48),dark)
        piece("TriggerGuardLower",Vector3.new(.40,.085,.51),CFrame.new(0,-.19,-.27),dark)
        piece("Trigger",Vector3.new(.10,.24,.08),CFrame.new(0,.025,-.31),steel)
        piece("UnderRail",Vector3.new(.35,.10,.40),CFrame.new(0,.06,-.71),dark)
        piece("RailLight",Vector3.new(.20,.045,.36),CFrame.new(0,.009,-.71),C.CYAN,Enum.Material.Neon)
        piece("SideMark",Vector3.new(.015,.07,.44),CFrame.new(.306,.47,-.35),C.PURPLE,Enum.Material.Neon)

        -- A tiny welded muzzle locator; flash is cosmetic/client-side only.
        S.Muzzle=piece("Muzzle",Vector3.new(.10,.10,.09),
            CFrame.new(0,.50,-1.39),C.CYAN,Enum.Material.Neon)
        S.Muzzle.Transparency=.35
        S.FlashLight=make("PointLight",{
            Enabled=false,Color=C.GOLD,Brightness=2.4,Range=11,Shadows=false
        },S.Muzzle)
        S.Gun=tool
        on(tool.Activated,shoot)
        on(tool.Equipped,function()
            S.EquipError=nil;S.Armed=true;updateGun()
        end)
        on(tool.Unequipped,function()
            S.Armed=false;updateGun()
        end)
        tool.Parent=backpack
    end
    S.EquipError=nil
    if S.Gun and S.Gun.Parent==character then
        S.Armed=true
        setMenu(false)
        updateGun()
        return
    end
    local ok=pcall(function()humanoid:EquipTool(S.Gun)end)
    if not ok then
        S.Armed=false;S.EquipError="equip rejected"
        changeInfo()
        return
    end
    -- EquipTool may complete on the next scheduler step.
    local ticket=S.GunGeneration
    task.delay(.12,function()
        if not S.Alive or ticket~=S.GunGeneration then return end
        local equipped=S.Gun and S.Gun.Parent==Me.Character
        S.Armed=equipped==true
        S.EquipError=equipped and nil or "not equipped"
        if equipped then setMenu(false) end
        updateGun()
    end)
end

on(UIS.InputBegan,function(input,processed)
    if not S.Alive or UIS:GetFocusedTextBox() then return end
    if input.KeyCode==Enum.KeyCode.R and S.Armed and not S.Open then reload() end
    if input.UserInputType==Enum.UserInputType.MouseButton1 and not S.Open and S.Armed then
        -- Fallback for executors/places where Tool.Activated does not fire.
        -- shoot() throttles two callbacks for the same click.
        shoot()
    end
end)
on(Me.CharacterAdded,function()
    removeGun()
    task.delay(.5,function()
        if S.Alive and Me.Character then
            -- A new blaster is prepared; the user can equip it with Home > EQUIP.
            local backpack=Me:FindFirstChildOfClass("Backpack")
            if backpack then changeInfo() end
        end
    end)
end)

-- SPECTRA V4: Home quick access to local guard controls.
section("HOME","PROTECTION ACTIVE")
local protectionCard=corner(make("Frame",{
    LayoutOrder=order("HOME"),Size=UDim2.new(1,-2,0,91),
    BackgroundColor3=C.SIDE,BorderSizePixel=0
},pages.HOME),ROUND.Card)
stroke(protectionCard,C.STROKE,1).Transparency=.36
local protectionAccent=bar(protectionCard,0,12,3,68,C.GREEN)
table.insert(S.AccentBars,protectionAccent)
local protectTitle=txt(protectionCard,"ANTI FLING V4",17,9,265,24,14,true,C.WHITE)
local protectDesc=description(protectionCard,"Local protection / Strong / Recovery",17,33,306,20)
local protectCount=description(protectionCard,"0 BLOCKED",17,60,270,18)
local protectButton=btn(protectionCard,"TURN OFF",350,26,134,37,C.GREEN)
buttonCaption(protectButton).TextColor3=C.DARK
local function refreshProtectButton()
    local enabled=cfg.AntiFling or cfg.AntiFly
    protectButton.BackgroundColor3=enabled and C.GREEN or C.HOVER
    buttonCaption(protectButton).Text=enabled and "TURN OFF" or "TURN ON"
    buttonCaption(protectButton).TextColor3=enabled and C.DARK or C.WHITE
    protectDesc.Text="Local protection / "..cfg.GuardMode.." / Recovery "
        ..(cfg.SafeRecovery and "ON" or "OFF")
end
on(protectButton.Activated,function()
    local nextValue=not (cfg.AntiFling or cfg.AntiFly)
    cfg.AntiFling=nextValue
    cfg.AntiFly=nextValue
    save()
    refresh()
    refreshProtectButton()
    notify("Anti fling / "..(nextValue and "ON" or "OFF"),"INFO")
end)
table.insert(S.Toggles,refreshProtectButton)
refreshProtectButton()

section("HOME","ENTRAINEMENT")
action("HOME","Pistolet de test","Equiper puis tirer avec le clic gauche","EQUIP",equipGun)
action("HOME","Mannequins de test","Creer trois mannequins R6 locaux","SPAWN",spawnDummies)
action("HOME","Supprimer les mannequins","Retirer toutes les cibles locales","REMOVE",clearDummies)
action("HOME","Reinitialiser les PV","Remettre les cibles a 100 PV","RESET",resetAllHP)
section("HOME","STATUT EN DIRECT")
local homeStatus=corner(make("Frame",{
    LayoutOrder=order("HOME"),Size=UDim2.new(1,-2,0,73),
    BackgroundColor3=C.SIDE,BorderSizePixel=0
},pages.HOME),ROUND.Card)
grad(homeStatus,C.CARD,C.SIDE,7)
stroke(homeStatus,C.STROKE,1).Transparency=.5
local metricsLine=bar(homeStatus,13,38,476,1,C.STROKE)
dummyInfo=txt(homeStatus,"Targets: 0 / 3",13,8,220,25,12,true,C.WHITE)
weaponInfo=description(homeStatus,"Ammo: 12 / 12   /   HOLSTERED",13,40,459,22)

section("VISUALS","ESP V4")
toggle("VISUALS","ESP","Activer les visuels","Activer ou desactiver tout l'ESP")
toggle("VISUALS","Box","Boites 3D","Affichage 3D uniquement")
choices("VISUALS","Couleur des boites","BoxColor",{"BLEU","VIOLET","RGB","ACCENT"})
choices("VISUALS","Affichage ESP V4","ESPDetail",{"FULL","COMPACT"})
slider("VISUALS","Distance des effets","ESPExtraRange",200,1500,100," studs")
slider("VISUALS","Thickness","Epaisseur des contours",.03,.18,.01," studs")
toggle("VISUALS","Skeleton","Skeleton","Articulations R6 et R15")
toggle("VISUALS","Tracers","Tracers","Traces vers les cibles")
toggle("VISUALS","Highlight","Contours lumineux","Surlignage leger du personnage")
section("VISUALS","INFORMATIONS")
toggle("VISUALS","Names","Afficher les noms","Nom au-dessus des cibles")
toggle("VISUALS","Distance","Distance","Distance en studs")
toggle("VISUALS","Health","Barre de vie","Afficher les points de vie")
section("VISUALS","FILTRES")
toggle("VISUALS","ThroughWalls","A travers les murs","Mode de test de visibilite")
toggle("VISUALS","ShowAllies","Afficher les allies","Inclure les membres de l'equipe")
toggle("VISUALS","ShowNPC","Afficher les PNJ","Montrer les cibles d'entrainement")
toggle("VISUALS","TeamColors","Couleurs des equipes","Couleurs selon l'equipe")

section("AIMBOT","ENTRAINEMENT CAMERA")
toggle("AIMBOT","Aim","Assistance camera","Clic droit pour suivre un mannequin vivant")
toggle("AIMBOT","ShowFOV","Afficher le rayon","Zone de selection du viseur")
choices("AIMBOT","Zone ciblee","AimPart",{"HEAD","BODY"})
toggle("AIMBOT","AimLOS","Visibilite requise","Ignorer les cibles derriere les murs")
slider("AIMBOT","AimFOV","Rayon de ciblage",60,300,10," px")
slider("AIMBOT","AimSmooth","Fluidite du suivi",.03,.45,.02," s")
action("AIMBOT","Creer les cibles","Trois mannequins espaces","SPAWN",spawnDummies)

section("SILENT","TIRS DE TEST")
toggle("SILENT","Preview","Silent Aim simule","Agrandir la zone d'impact sans bouger la camera")
toggle("SILENT","PreviewLOS","Visibilite requise","Ne pas traverser les murs solides")
choices("SILENT","Zone d'impact","PreviewPart",{"HEAD","BODY"})
slider("SILENT","PreviewFOV","Rayon des impacts",60,300,10," px")
slider("SILENT","ShotDamage","Degats par tir sur mannequin",10,50,5," HP")
toggle("SILENT","HitMarker","Indicateur d'impact","Afficher les impacts confirmes")
toggle("SILENT","PreviewCircle","Afficher le rayon d'impact","Cercle du mode d'entrainement")
toggle("SILENT","AutoRespawn","Reapparition automatique","Restaurer la cible apres 3 secondes")
local hitsCard=corner(make("Frame",{LayoutOrder=order("SILENT"),Size=UDim2.new(1,-2,0,53),
    BackgroundColor3=C.CARD,BorderSizePixel=0},pages.SILENT),ROUND.Compact)
hitInfo=txt(hitsCard,"HITS  0   /   SHOTS  0   /   KOs  0",13,9,460,31,13,true)
action("SILENT","Equiper le pistolet","Clic gauche pour tirer sur les mannequins","EQUIP",equipGun)
action("SILENT","Reinitialiser les PV","Restaurer les trois cibles a 100 PV","RESET",resetAllHP)
action("SILENT","Reinitialiser les stats","Effacer tirs, impacts et KOs","RESET",function()
    S.Hits=0;S.Shots=0;S.KOs=0;S.Damage=0;changeInfo()
end)

-- MISC: optional protections against abnormal incoming physics impulses.
-- These guards NEVER deliberately rotate the character.
section("MISC","ANTI FLING V4")
toggle("MISC","AntiFling","Anti-fling","Bloquer les fortes projections horizontales et verticales")
toggle("MISC","AntiFly","Anti-launch","Limiter les projections vers le haut")
choices("MISC","Protection","GuardMode",{"NORMAL","STRONG"})
toggle("MISC","SafeRecovery","Recuperation d'urgence","Retour local si une projection extreme est detectee")
slider("MISC","FlingSpeed","Vitesse horizontale limite",70,250,10," studs/s")
slider("MISC","FlyLaunchSpeed","Vitesse verticale limite",50,200,10," studs/s")
section("MISC","ANTI-ROTATION")
toggle("MISC","AntiAim","Anti-rotation","Limiter les rotations forcees")
slider("MISC","SpinThreshold","Sensibilite",5,25,1," rad/s")
section("MISC","REACTIONS")
toggle("MISC","GuardCorrect","Corriger les anomalies","Limiter les mouvements anormaux locaux")
toggle("MISC","MoveHUD","Indicateurs de protection","Afficher l'etat des protections")
local miscPanel=corner(make("Frame",{
    LayoutOrder=order("MISC"),Size=UDim2.new(1,-2,0,65),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.MISC),ROUND.Card)
stroke(miscPanel,C.STROKE,1).Transparency=.58
bar(miscPanel,0,9,3,48,C.GOLD)
local miscStatus=txt(miscPanel,"GUARD V4 / MONITORING",13,5,460,24,11,true,C.CYAN)
local miscHint=description(miscPanel,"Active local guard. Server physics can still override correction.",13,32,467,24)
S.MovementStatus=miscStatus
action("MISC","Effacer les alertes","Vider les compteurs sans desactiver les protections","RESET",function()
    cfg.AntiAim=false
    S.FlyFlags=0;S.FlingFlags=0;S.SpinFlags=0
    S.FlySamples=0;S.FlingSamples=0;S.SpinSamples=0
    S.FlyState="MONITORING";S.FlingState="MONITORING";S.SpinState="OFF"
    S.BlockedImpulses=0
    save();refresh()
end)

section("SETTINGS","PERFORMANCES V4")
choices("SETTINGS","Mode performance","PerformanceMode",{"LOW","BALANCED","HIGH"})
toggle("SETTINGS","AdaptiveFPS","Rafraichissement adaptatif","Adapter le rendu aux FPS")
slider("SETTINGS","RenderRate","Frequence d'affichage",15,60,5," Hz")
slider("SETTINGS","Range","Distance ESP",100,2500,100," studs")
section("SETTINGS","APPARENCE V4")
slider("SETTINGS","Arrondi des coins","UIRoundness",.7,1.5,.1," x")
slider("SETTINGS","MenuScale","Taille du menu",.7,1.15,.05," x")
choices("SETTINGS","Raccourci du menu","Shortcut",{"TAB","RIGHTSHIFT","F4"})
choices("SETTINGS","Couleur d'accent","Accent",{"BLEU","VIOLET","CYAN","ROUGE","VERT","ROSE"})
toggle("SETTINGS","RGB","Accent RGB","Animer legerement les accents")
toggle("SETTINGS","Animations","Animations de l'interface","Transitions et survols discrets")
toggle("SETTINGS","Notifications","Notifications V4","Afficher jusqu a 3 alertes sans chevauchement")
toggle("SETTINGS","MiniButton","Bouton flottant","Raccourci quand le menu est ferme")
action("SETTINGS","Restaurer les parametres","Revenir aux parametres par defaut","RESET",function()
    for k,v in pairs(D) do cfg[k]=v end
    normalize();save();refresh();refreshRoundness();rescale()
end)

do -- ABOUT: build status + configured OTA URL, no public input field.
local Http = game:GetService("HttpService")
local aboutBuild=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,57),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
stroke(aboutBuild,C.STROKE,1).Transparency=.55
bar(aboutBuild,0,10,3,37,C.CYAN)
corner(make("Frame",{
    Position=UDim2.fromOffset(14,17),Size=UDim2.fromOffset(8,8),
    BackgroundColor3=C.GREEN,BorderSizePixel=0
},aboutBuild),5)
txt(aboutBuild,"VERSION INSTALLEE",28,8,230,22,12,true,C.WHITE)
description(aboutBuild,"Entrainement local / mises a jour",28,28,320,19)
local versionPill=corner(make("Frame",{
    Position=UDim2.new(1,-106,0,14),Size=UDim2.fromOffset(90,29),
    BackgroundColor3=C.DARK,BorderSizePixel=0
},aboutBuild),14)
stroke(versionPill,C.PURPLE,1).Transparency=.34
local versionPillText=txt(versionPill,"v"..V,0,4,90,21,12,true,C.PURPLE)
versionPillText.TextXAlignment=Enum.TextXAlignment.Center

section("ABOUT","GITHUB OTA")
local otaPanel=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,114),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
stroke(otaPanel,C.STROKE,1).Transparency=.60
bar(otaPanel,0,11,3,92,C.PURPLE)
txt(otaPanel,"Mises a jour GitHub",13,6,312,23,13,true,C.WHITE)
description(otaPanel,"Verifier la derniere version publiee sur GitHub.",13,28,466,19)
local verifyButton=btn(otaPanel,"CHECK UPDATE",347,53,135,36,C.BLUE)
buttonCaption(verifyButton).TextColor3=C.DARK
local otaStatus=description(otaPanel,"Ready / Installed: v"..V,13,54,324,42)
otaStatus.TextWrapped=true
otaStatus.TextYAlignment=Enum.TextYAlignment.Center

-- Modal shown ONLY when a strictly newer version is detected.
local backdrop=make("Frame",{
    Name="VisionProOTAConfirm",Size=UDim2.fromScale(1,1),
    BackgroundColor3=Color3.fromRGB(4,7,19),
    BackgroundTransparency=.32,Active=true,Visible=false,ZIndex=200
},ui)
local modal=corner(make("Frame",{
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(408,229),BackgroundColor3=C.SIDE,
    BorderSizePixel=0,ZIndex=201,Active=true
},backdrop),ROUND.Modal)
stroke(modal,C.STROKE,1).Transparency=.18
local modalLine=bar(modal,16,0,375,3,C.PURPLE);modalLine.ZIndex=202
grad(modalLine,C.BLUE,C.CYAN,8)
local modalTitle=txt(modal,"UPDATE AVAILABLE",20,18,369,27,17,true,C.WHITE)
modalTitle.ZIndex=202
local versionBox=corner(make("Frame",{
    Position=UDim2.fromOffset(18,53),Size=UDim2.fromOffset(372,36),
    BackgroundColor3=C.CARD,BorderSizePixel=0,ZIndex=202
},modal),ROUND.Compact)
versionBox.ZIndex=202
local modalVersion=txt(versionBox,"",12,7,350,23,12,true,C.CYAN)
modalVersion.ZIndex=202
local modalInfo=txt(modal,
    "Une nouvelle version a ete publiee. Voulez-vous installer la mise a jour ?",
    20,97,368,42,12,false,C.TEXT)
modalInfo.TextWrapped=true;modalInfo.ZIndex=202
local modalNote=txt(modal,
    "Aucune installation sans votre confirmation.",
    20,149,369,20,10,false,C.MUTED)
modalNote.ZIndex=202
local cancelButton=btn(modal,"CANCEL",20,182,172,34,C.CARD)
local applyButton=btn(modal,"UPDATE NOW",203,182,186,34,C.BLUE)
for _,button in ipairs({cancelButton,applyButton}) do
    button.ZIndex=203
    local label=buttonCaption(button)
    if label then label.ZIndex=205 end
end
buttonCaption(applyButton).TextColor3=C.DARK
local modalScale=make("UIScale",{Scale=1},modal)
local function scaleModal()
    local cam=WS.CurrentCamera
    if cam then
        local vp=cam.ViewportSize
        modalScale.Scale=math.clamp(math.min(1,(vp.X-28)/408,(vp.Y-28)/229),.45,1)
    end
end

local pendingSource=nil
local pendingVersion=nil
local pendingUrl=nil
local function setStatus(message,color)
    if S.Alive then
        otaStatus.Text=message
        otaStatus.TextColor3=color or C.MUTED
    end
end
local function closeModal()
    backdrop.Visible=false
    S.OtaConfirmOpen=false
end

-- Static URL prevents untrusted players from changing which repository runs.
local function configuredURL()
    local url=tostring(D.GITHUB_OTA_URL or "")
    if url:find("TON-PSEUDO",1,true)
        or not url:match("^https://raw%.githubusercontent%.com/[%w_.%-]+/[%w_.%-]+/[%w_.%-]+/[%w%._/%-]+%.lua$") then
        return nil
    end
    return url
end
local function httpGet(url)
    -- Supported in some authorized executor environments, not ordinary LocalScripts.
    local fn=(type(request)=="function" and request)
        or (type(http_request)=="function" and http_request)
    if not fn and type(syn)=="table" and type(syn.request)=="function" then
        fn=syn.request
    end
    if fn then
        local ok,res=pcall(fn,{Url=url,Method="GET",Headers={Accept="text/plain"}})
        if ok and type(res)=="table" then
            local body=res.Body or res.body
            local status=tonumber(res.StatusCode or res.status_code)
            if type(body)=="string" and (status==200 or status==nil) then
                return body
            end
        end
    end
    local ok,textResult=pcall(function() return game:HttpGet(url,true) end)
    if ok and type(textResult)=="string" then return textResult end
    return nil,"HTTP blocked / unavailable in this client."
end
local function parseVersion(value)
    local a,b,c=tostring(value or ""):match("^[vV]?(%d+)%.(%d+)%.(%d+)$")
    if not a then return nil end
    return {tonumber(a),tonumber(b),tonumber(c)}
end
local function compareVersion(new,old)
    local a,b=parseVersion(new),parseVersion(old)
    if not a or not b then return nil end
    for i=1,3 do
        if a[i]~=b[i] then return a[i]>b[i] and 1 or -1 end
    end
    return 0
end
local function versionInCode(code)
    -- Inspect only the beginning of the known trusted file, not arbitrary comments.
    if type(code)~="string" then return nil end
    return code:sub(1,350):match("^%-%-%s*VISION_PRO_VERSION:%s*(%d+%.%d+%.%d+)")
        or code:match('local%s+V%s*=%s*"(%d+%.%d+%.%d+)"')
        or code:match("local%s+V%s*=%s*'(%d+%.%d+%.%d+)'" )
end
local function copySource(code)
    local copy=(type(setclipboard)=="function" and setclipboard)
        or (type(toclipboard)=="function" and toclipboard)
    if not copy then return false end
    return pcall(copy,code)
end
local function clearPending()
    pendingSource=nil;pendingVersion=nil;pendingUrl=nil
end

on(cancelButton.Activated,function()
    closeModal()
    clearPending()
    setStatus("CANCELLED / v"..V.." remains installed.",C.MUTED)
end)

on(verifyButton.Activated,function()
    if S.OtaBusy or S.OtaConfirmOpen then return end
    local raw=configuredURL()
    if not raw then
        setStatus("Configure GITHUB_OTA_URL inside the Lua script.",C.GOLD)
        return
    end
    S.OtaBusy=true
    clearPending()
    setStatus("VERIFYING / Checking GitHub...",C.CYAN)
    task.spawn(function()
        -- Cache buster so VERIFY sees new GitHub commits after they propagate.
        local okFetch,response,err=pcall(httpGet,raw.."?verify="..tostring(os.time()))
        if not S.Alive then return end
        S.OtaBusy=false
        if not okFetch then
            logVisionError("GitHub OTA",response)
            setStatus("OTA ERROR / HTTP exception. See console.",C.RED)
            return
        end
        if type(response)~="string" then
            setStatus(err or "GitHub request failed.",C.RED)
            return
        end
        local lowered=response:sub(1,128):lower()
        if #response<25 or #response>512000
            or lowered:find("<!doctype",1,true)
            or lowered:find("<html",1,true)
            or lowered:find("404: not found",1,true) then
            setStatus("File missing or invalid: VISION_PRO.lua",C.RED)
            return
        end
        local remote=versionInCode(response)
        local cmp=compareVersion(remote,V)
        if not cmp then
            setStatus("GitHub file has no readable version marker.",C.GOLD)
            return
        end
        if cmp==0 then
            setStatus("UP TO DATE / v"..V.." is the latest.",C.GREEN)
            notify("Latest version already installed","SUCCESS")
        elseif cmp<0 then
            setStatus("NEWER LOCAL BUILD / GitHub has v"..remote,C.GOLD)
        else
            pendingSource=response
            pendingVersion=remote
            pendingUrl=raw
            modalVersion.Text="INSTALLED v"..V.."  ->  AVAILABLE v"..remote
            modalInfo.Text="GitHub update: v"..remote.." ("..math.floor(#response/1024+.5).." KB). Apply only if you trust this release?"
            setStatus("UPDATE AVAILABLE / v"..remote.." / Confirm below.",C.GREEN)
            S.OtaConfirmOpen=true
            scaleModal()
            backdrop.Visible=true
            notify("Update v"..remote.." available","INFO")
        end
    end)
end)

on(applyButton.Activated,function()
    if S.OtaBusy or not S.OtaConfirmOpen then return end
    local source,version,url=pendingSource,pendingVersion,pendingUrl
    closeModal()
    clearPending()
    if type(source)~="string" or not version or not url
        or url~=configuredURL() or versionInCode(source)~=version
        or compareVersion(version,V)~=1 then
        setStatus("UPDATE REJECTED / Verify again.",C.RED)
        return
    end
    -- Do not load anything before explicit UPDATE NOW.
    local loader=(type(loadstring)=="function" and loadstring)
    if not loader then
        local copied=copySource(source)
        setStatus(copied and ("v"..version.." copied. Review and run manually.")
            or "Execution unavailable and clipboard unsupported.",
            copied and C.GOLD or C.RED)
        return
    end
    local compiledOK,compiled=pcall(loader,source)
    if not compiledOK or type(compiled)~="function" then
        setStatus("COMPILE FAILED / Old version retained.",C.RED)
        return
    end
    setStatus("CONFIRMED / Starting v"..version.."...",C.CYAN)
    task.defer(function()
        -- New build should call old build's *_STOP during its own initialization.
        local ok,err=pcall(compiled)
        if not ok then
            warn("VISION PRO OTA:",err)
            setStatus("UPDATE FAILED / Check Roblox console.",C.RED)
        end
    end)
end)

section("ABOUT","NOUVEAUTES")
local releasePanel=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,144),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
local function releaseLine(index,version,heading,detail,color)
    local y=8+(index-1)*45
    corner(make("Frame",{
        Position=UDim2.fromOffset(13,y+7),Size=UDim2.fromOffset(7,7),
        BackgroundColor3=color,BorderSizePixel=0
    },releasePanel),5)
    txt(releasePanel,version,28,y,84,21,11,true,color)
    txt(releasePanel,heading,118,y,346,21,11,true,C.WHITE)
    description(releasePanel,detail,118,y+19,346,17)
    if index<3 then
        local line=bar(releasePanel,28,y+39,438,1,C.STROKE)
        line.BackgroundTransparency=.76
    end
end
releaseLine(1,"1.7.1","UI HOTFIX","Pages visibles / scroll corrige / coins arrondis",C.CYAN)
releaseLine(2,"1.7.0","V4 COMPLETE","UI / ESP / Anti Fling / notifications V4",C.PURPLE)
releaseLine(3,"1.6.1","ROUNDED UI","Boutons et cartes arrondis",C.GOLD)
local aboutEnd=make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,34),
    BackgroundTransparency=1
},pages.ABOUT)
description(aboutEnd,"LOCAL TRAINING ONLY  /  No server-side game damage",12,4,470,24)

end -- About scope

-- Close/minimize, keyboard, camera and render lifecycle.
local mini=btn(ui,"VP",19,90,46,36,C.PURPLE);mini.Visible=false
buttonSurface(mini,C.PURPLE,C.BLUE)
on(mini.Activated,function()setMenu(true)end)
on(minimize.Activated,function()setMenu(false)end)
-- CoreGui hotfix: never change native Roblox PlayerList.
-- TAB is already bound by the menu; leave Roblox-owned UI in its original state.
local function toggleMenu()
    if not S.Alive or S.OtaConfirmOpen or UIS:GetFocusedTextBox() then return end
    if os.clock()-S.LastTab<.18 then return end
    S.LastTab=os.clock();setMenu(not S.Open)
end
CAS:BindActionAtPriority(TAB_ACTION,function(_,state)
    if cfg.Shortcut~="TAB" or UIS:GetFocusedTextBox() then
        return Enum.ContextActionResult.Pass
    end
    if state==Enum.UserInputState.Begin then toggleMenu() end
    return Enum.ContextActionResult.Sink
end,false,10000,Enum.KeyCode.Tab)
on(UIS.InputBegan,function(input,processed)
    if processed or UIS:GetFocusedTextBox() then return end
    if cfg.Shortcut=="RIGHTSHIFT" and input.KeyCode==Enum.KeyCode.RightShift then
        toggleMenu()
    elseif cfg.Shortcut=="F4" and input.KeyCode==Enum.KeyCode.F4 then
        toggleMenu()
    end
end)
local dragging=false;local dragInput,dragStart,dragPos
on(header.InputBegan,function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
    if input.Position.X>header.AbsolutePosition.X+header.AbsoluteSize.X*.76 then return end
    dragging=true;dragInput=input;dragStart=input.Position;dragPos=window.Position
end)
on(UIS.InputChanged,function(input)
    if not dragging then return end
    if input~=dragInput and input.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local delta=(input.Position-dragStart)/scale.Scale
    window.Position=UDim2.new(dragPos.X.Scale,dragPos.X.Offset+delta.X,dragPos.Y.Scale,dragPos.Y.Offset+delta.Y)
end)
on(UIS.InputEnded,function(input)
    if dragging and (input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1) then dragging=false end
end)
-- LOCAL PHYSICS GUARDS: react only to extreme incoming impulses.
-- No CFrame assignment; no AutoRotate changes; no self-spinning.
local movementHud=corner(make("Frame",{
    Position=UDim2.fromOffset(20,140),
    Size=UDim2.fromOffset(238,59),BackgroundColor3=C.SIDE,
    BorderSizePixel=0,Visible=false
},ui),ROUND.Card)
grad(movementHud,C.CARD,C.SIDE,7)
stroke(movementHud,C.STROKE,1).Transparency=.32
local flightText=txt(movementHud,"LAUNCH / OFF",11,3,217,20,10,true,C.CYAN)
local flingText=description(movementHud,"FLING / OFF",11,22,217,18)
local angleText=description(movementHud,"ROTATION / OFF",11,40,217,16)
S.MovementHUD=movementHud
local function resetDefense()
    S.FlyState="OFF";S.FlingState="OFF";S.SpinState="OFF"
    S.FlySamples=0;S.FlingSamples=0;S.SpinSamples=0
    S.LastMotionVelocity=nil
    S.RecoveryUntil=0
end

-- Guard V4: purely local physics mitigation in authorized test places.
-- No client script can override server-authoritative physics in every game.
local function updateMovement(dt)
    if not S.Alive then return end
    local character=Me.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if S.GuardCharacter~=character then
        S.GuardCharacter=character
        S.LastSafeCFrame=nil
        S.LastSafeTime=0
        resetDefense()
    end
    if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health<=0 then
        movementHud.Visible=false
        return
    end
    local state=humanoid:GetState()
    local excluded=humanoid.Sit or root.Anchored
        or state==Enum.HumanoidStateType.Seated
        or state==Enum.HumanoidStateType.Swimming
        or state==Enum.HumanoidStateType.Climbing
        or state==Enum.HumanoidStateType.Dead
        or state==Enum.HumanoidStateType.Physics
    local now=os.clock()
    local v=root.AssemblyLinearVelocity
    local a=root.AssemblyAngularVelocity
    local last=S.LastMotionVelocity
    S.LastMotionVelocity=v
    local h=Vector3.new(v.X,0,v.Z)
    local hSpeed=h.Magnitude
    local ySpeed=v.Y
    local strict=cfg.GuardMode=="STRONG"
    local hLimit=cfg.FlingSpeed*(strict and .82 or 1)
    local yLimit=cfg.FlyLaunchSpeed*(strict and .86 or 1)
    local horizontalShock=last and
        (Vector3.new(v.X-last.X,0,v.Z-last.Z)).Magnitude or 0
    local verticalShock=last and math.max(0,v.Y-last.Y) or 0
    local grounded=humanoid.FloorMaterial~=Enum.Material.Air

    -- Store a recent, slow grounded point. A recovery still requires a raycast.
    if not excluded and grounded and hSpeed<28 and math.abs(ySpeed)<18 then
        if not S.LastSafeCFrame or now-S.LastSafeTime>.12 then
            S.LastSafeCFrame=root.CFrame
            S.LastSafeTime=now
        end
    end

    local detectH=not excluded and cfg.AntiFling
        and hSpeed>hLimit and
        (strict or horizontalShock>hLimit*.3 or hSpeed>hLimit*1.7)
    local detectY=not excluded and (cfg.AntiFly or cfg.AntiFling)
        and ySpeed>yLimit and
        (strict or verticalShock>yLimit*.3 or ySpeed>yLimit*1.7)
    local detectSpin=not excluded and cfg.AntiAim
        and math.abs(a.Y)>cfg.SpinThreshold

    if excluded then
        S.FlingState="EXEMPT";S.FlyState="EXEMPT";S.SpinState="EXEMPT"
        S.FlingSamples=0;S.FlySamples=0;S.SpinSamples=0
        S.RecoveryUntil=0
    else
        S.FlingSamples=detectH and math.min(3,S.FlingSamples+1) or 0
        S.FlySamples=detectY and math.min(3,S.FlySamples+1) or 0
        S.SpinSamples=detectSpin and math.min(3,S.SpinSamples+1) or 0
        local hitH=detectH and (strict or S.FlingSamples>=2)
        local hitY=detectY and (strict or S.FlySamples>=2)
        local hitSpin=detectSpin and (strict or S.SpinSamples>=2)
        local impacted=hitH or hitY
        S.FlingState=cfg.AntiFling and (hitH and "LIMITED" or detectH and "CHECKING" or "MONITORING") or "OFF"
        S.FlyState=(cfg.AntiFly or cfg.AntiFling) and
            (hitY and "LIMITED" or detectY and "CHECKING" or "MONITORING") or "OFF"
        S.SpinState=cfg.AntiAim and (hitSpin and "LIMITED" or detectSpin and "CHECKING" or "MONITORING") or "OFF"
        if impacted then
            if now-S.GuardCooldown>.5 then
                S.BlockedImpulses+=1
                S.GuardCorrections+=1
                S.GuardCooldown=now
                if hitH then S.FlingFlags+=1 end
                if hitY then S.FlyFlags+=1 end
            end
            if cfg.GuardCorrect then
                -- Modify only the dangerous axis; preserve ordinary gravity and movement.
                local horizontalNew=h
                if hitH and hSpeed>.001 then
                    horizontalNew=h.Unit*math.min(hSpeed,hLimit*.52)
                end
                local verticalNew=hitY and math.min(ySpeed,16) or ySpeed
                root.AssemblyLinearVelocity=Vector3.new(
                    horizontalNew.X,verticalNew,horizontalNew.Z)
                if a.Magnitude>math.max(8,cfg.SpinThreshold*1.1) then
                    root.AssemblyAngularVelocity=Vector3.zero
                end
                if cfg.SafeRecovery and
                    (hSpeed>hLimit*2.2 or ySpeed>yLimit*2.2) and
                    S.LastSafeCFrame and now-S.LastSafeTime<2 then
                    S.RecoveryUntil=now+.65
                end
            end
            if now-S.GuardNoticeCooldown>2.5 then
                notify("Guard V4: abnormal impulse limited","INFO")
                S.GuardNoticeCooldown=now
            end
        elseif hitSpin and cfg.GuardCorrect then
            root.AssemblyAngularVelocity=Vector3.new(a.X,
                math.clamp(a.Y,-cfg.SpinThreshold*.5,cfg.SpinThreshold*.5),a.Z)
        end

        if cfg.GuardCorrect and cfg.SafeRecovery and S.RecoveryUntil>now
            and S.LastSafeCFrame and now-S.LastSafeTime<2
            and now-S.LastRecovery>3 and not grounded then
            local safe=S.LastSafeCFrame
            local distance=(root.Position-safe.Position).Magnitude
            if distance>12 and distance<125 then
                -- Confirm the saved place still has supporting ground.
                local query=RaycastParams.new()
                query.FilterType=Enum.RaycastFilterType.Exclude
                query.FilterDescendantsInstances={character}
                query.IgnoreWater=true
                local ground=WS:Raycast(safe.Position+Vector3.new(0,3,0),
                    Vector3.new(0,-9,0),query)
                if ground and ground.Instance and ground.Instance.CanCollide
                    and ground.Normal.Y>.65 then
                    local destination=Vector3.new(safe.Position.X,
                        math.max(safe.Position.Y,ground.Position.Y+3),safe.Position.Z)
                    local orientation=root.CFrame-root.Position
                    character:PivotTo(CFrame.new(destination)*orientation)
                    root.AssemblyLinearVelocity=Vector3.zero
                    root.AssemblyAngularVelocity=Vector3.zero
                    S.LastRecovery=now
                    S.RecoveryUntil=0
                    S.FlingState="RECOVERED"
                    S.FlyState="RECOVERED"
                    notify("Guard V4: position restored","SUCCESS")
                end
            end
        end
    end

    if now-S.LastGuardHUD<.14 then return end
    S.LastGuardHUD=now
    if protectCount.Parent then
        protectCount.Text=tostring(S.BlockedImpulses).." LIMITED IMPULSES"
    end
    local active=cfg.AntiFling or cfg.AntiFly
    guardStatusSidebar.Text=active and "GUARD V4 / ON" or "GUARD V4 / OFF"
    onlineDot.BackgroundColor3=active and C.GREEN or C.RED
    if S.MovementStatus and S.MovementStatus.Parent then
        S.MovementStatus.Text="FLING "..S.FlingState.." / LAUNCH "..S.FlyState
            .." / EVENTS "..S.BlockedImpulses
    end
    movementHud.Visible=not S.Open and cfg.MoveHUD
        and (cfg.AntiFly or cfg.AntiFling or cfg.AntiAim)
    flightText.Text="LAUNCH / "..S.FlyState.." ("..S.FlyFlags..")"
    flingText.Text="FLING / "..S.FlingState.." ("..S.FlingFlags..")"
    angleText.Text="ROTATION / "..S.SpinState.." ("..S.SpinFlags..")"
    flightText.TextColor3=S.FlyState=="LIMITED" and C.GREEN or C.CYAN
    flingText.TextColor3=S.FlingState=="LIMITED" and C.GREEN or C.MUTED
    angleText.TextColor3=S.SpinState=="LIMITED" and C.GREEN or C.MUTED
end

local function theme(dt)
    if cfg.RGB then S.Hue=(S.Hue+dt*.11)%1 end
    local accent=cfg.RGB and Color3.fromHSV(S.Hue,.63,1) or (accentChoices[cfg.Accent] or C.PURPLE)
    if accent~=S.Accent or not S.PaletteReady then
        S.PaletteReady=true
        S.Accent=accent
        logo.BackgroundColor3=accent
        topLight.BackgroundColor3=accent
        topGradient.Color=ColorSequence.new(accent,accent:Lerp(C.PURPLE,.32))
        headerStripe.BackgroundColor3=accent
        headerPink.BackgroundColor3=accent
        pageCounter.TextColor3=accent
        v3BadgeText.TextColor3=accent
        for _,page in pairs(pages) do page.ScrollBarImageColor3=accent end
        for name,item in pairs(nav) do
            item.Line.BackgroundColor3=accent
            item.Selected.BackgroundColor3=accent
            if name==S.Page then item.Dot.BackgroundColor3=accent end
        end
        for _,barPart in ipairs(S.AccentBars) do
            if barPart.Parent then barPart.BackgroundColor3=accent end
        end
        for _,data in ipairs(S.AccentToggles) do
            if data.Track.Parent then
                local enabled=cfg[data.Key]==true
                data.Track.BackgroundColor3=enabled and accent or C.STROKE
                data.Label.TextColor3=enabled and accent or C.MUTED
            end
        end
        for _,button in ipairs(S.AccentButtons) do
            if button.Parent then button.BackgroundColor3=accent end
        end
        for _,label in ipairs(S.AccentLabels) do
            if label.Parent then label.TextColor3=accent end
        end
        for _,fill in ipairs(S.SliderFills) do
            if fill.Parent then fill.BackgroundColor3=accent end
        end
        for _,update in ipairs(S.Selectors) do update() end
        gunHudAccent.BackgroundColor3=accent
        fovOutline.Color=accent
    end
    gunHudSecond.BackgroundColor3=C.CYAN
    mini.Visible=not S.Open and cfg.MiniButton
    cross.Visible=S.Armed and not S.Open
    fov.Visible=not S.Open and ((cfg.Aim and cfg.ShowFOV) or (cfg.Preview and cfg.PreviewCircle and S.Armed))
    local radius=math.max(cfg.Aim and cfg.ShowFOV and cfg.AimFOV or 0,
        cfg.Preview and cfg.PreviewCircle and S.Armed and cfg.PreviewFOV or 0)
    fov.Size=UDim2.fromOffset(radius*2,radius*2)
    if marker.Visible and os.clock()>S.MarkerUntil then marker.Visible=false end
end
Run:BindToRenderStep(AIM_ACTION,Enum.RenderPriority.Camera.Value+1,function(dt)
    if not S.Alive or S.Open or not cfg.Aim or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local ok,err=pcall(function()
        local cam=WS.CurrentCamera
        if not cam then return end
        local part=closestDummy(cfg.AimFOV,cfg.AimPart,cfg.AimLOS)
        if not part then return end
        local current=cam.CFrame
        local alpha=math.clamp(1-math.exp(-dt/math.max(cfg.AimSmooth,.03)),.01,.85)
        cam.CFrame=current:Lerp(CFrame.lookAt(current.Position,part.Position),alpha)
    end)
    if not ok then
        logVisionError("Camera",err)
        cfg.Aim=false -- prevent a frame-by-frame error loop
    end
end)
local function stop()
    if not S.Alive then return end
    S.Alive=false;resetDefense();save()
    pcall(function()CAS:UnbindAction(TAB_ACTION)end)
    pcall(function()Run:UnbindFromRenderStep(AIM_ACTION)end)
    for _,con in ipairs(S.Connections) do
        pcall(function() con:Disconnect() end)
    end
    for player,connections in pairs(S.Players) do
        for _,con in ipairs(connections) do
            pcall(function() con:Disconnect() end)
        end
        S.Players[player]=nil
    end
    local targets={}
    for target in pairs(S.Targets) do table.insert(targets,target) end
    for _,target in ipairs(targets) do removeTarget(target) end
    clearDummies();removeGun()
    if folder.Parent then folder:Destroy() end
    ui:Destroy();overlay:Destroy();env[KEY]=nil
end
on(close.Activated,stop)
env[KEY]=stop
for _,name in ipairs(tabs) do
    updateCanvas(name)
    local childCount=0
    for _,element in ipairs(pages[name]:GetChildren()) do
        if element:IsA("GuiObject") then childCount+=1 end
    end
    if childCount==0 then
        logVisionError("Page "..name,"No UI items were created")
    end
end
selectPage("HOME");rescale();changeInfo();refresh();theme(0)
local dataClock,renderClock,fpsClock,themeClock=0,0,0,0
local frames=0
on(Run.PostSimulation,function(dt)
    if not S.Alive then return end
    local ok,err=pcall(updateMovement,dt)
    if not ok then
        if os.clock()-S.GuardErrorTime>1 then logVisionError("Anti Fling",err);S.GuardErrorTime=os.clock() end
    end
end)
on(Run.Heartbeat,function(dt)
    if not S.Alive then return end
    dataClock+=dt;themeClock+=dt
    local updateInterval=cfg.PerformanceMode=="LOW" and .31
        or cfg.PerformanceMode=="HIGH" and .13 or .19
    if cfg.AdaptiveFPS and S.FPS<35 then
        updateInterval=math.max(updateInterval,.32)
    end
    if dataClock>=updateInterval then
        local ok,err=pcall(updateTargets)
        if not ok then logVisionError("ESP",err) end
        dataClock=0
    end
    if themeClock>.12 then theme(themeClock);themeClock=0 end
end)
on(Run.RenderStepped,function(dt)
    if not S.Alive then return end
    fpsClock+=dt;renderClock+=dt;frames+=1
    local cap=cfg.PerformanceMode=="LOW" and 20
        or cfg.PerformanceMode=="HIGH" and 60 or 40
    local rate=math.min(cfg.RenderRate,cap)
    if cfg.AdaptiveFPS and S.FPS<30 then rate=math.min(rate,15)
    elseif cfg.AdaptiveFPS and S.FPS<48 then rate=math.min(rate,30) end
    if renderClock>=1/rate then
        local ok,err=pcall(drawEffects)
        if not ok then logVisionError("Render",err) end
        S.Rate=rate;S.Frames+=1;renderClock=0
    end
    if fpsClock>=1 then
        S.FPS=math.floor(frames/fpsClock+.5)
        fpsText.Text=tostring(S.FPS).." FPS"
        fpsClock=0;frames=0;rescale()
    end
end)
print("VISION PRO "..V.." - SPECTRA V4 / UI + ESP + GUARD")
