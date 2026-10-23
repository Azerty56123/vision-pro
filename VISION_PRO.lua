-- VISION_PRO_VERSION: 4.2.0
--[[ VISION PRO 4.2.0 | CLASSIC / VISUAL REBUILD WITH SERVER BETA ACCESS
     LocalScript for authorized testing in your Roblox place.
     Aimbot / simulated Silent Aim work on locally spawned mannequins only.
     Camera assist and impact preview always start disabled.
     Local HP is a training display, not actual server damage.
]]
local function runVisionProUnlocked()
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
-- CoreGui is Roblox-owned. All custom UI belongs in PlayerGui.
local V="4.2.0"
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

local D={ESP=true,Box=true,BoxColor="ACCENT",ESPDetail="FULL",ESPExtraRange=650,ESPTextScale=1,ThroughWalls=true,
    Skeleton=true,Tracers=false,Names=true,Distance=true,Health=true,
    ShowAllies=true,ShowNPC=true,TeamColors=false,Highlight=false,
    Aim=false,AimFOV=140,AimSmooth=.12,ShowFOV=true,AimPart="HEAD",AimLOS=true,
    Preview=false,PreviewFOV=170,PreviewPart="HEAD",PreviewLOS=true,ShotDamage=25,AutoRespawn=true,HitMarker=true,PreviewCircle=true,
    -- Local defenses against abnormal physics, not self-rotation demos.
    AntiFly=true,FlyLaunchSpeed=55,
    AntiFling=true,FlingSpeed=100,
    AntiAim=false,SpinThreshold=9,
    GuardCorrect=true,MoveHUD=true,SafeRecovery=true,GuardV3=true,GuardMode="STRONG",GuardV4=true,GuardV5=true,GuardV6=true,FlyGrace=.55,
    GITHUB_OTA_URL="https://raw.githubusercontent.com/Azerty56123/vision-pro/main/VISION_PRO.lua",
    Accent="BLEU",RGB=false,Animations=true,Notifications=true,MiniButton=false,CompactUI=false,
    MenuScale=.95,UIRoundness=1.05,Shortcut="TAB",PerformanceMode="BALANCED",Range=1200,
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
    cfg.MenuScale=math.clamp(tonumber(cfg.MenuScale) or .95,.7,1.15)
    cfg.UIRoundness=math.clamp(tonumber(cfg.UIRoundness) or 1.05,.7,1.5)
    validOptions("AimPart",{"HEAD","BODY"},"HEAD")
    validOptions("PreviewPart",{"HEAD","BODY"},"HEAD")
    for k,v in pairs({AimFOV={60,300},PreviewFOV={60,300},AimSmooth={.03,.45},Range={100,2500},ESPExtraRange={200,1500},ESPTextScale={.8,1.4},FlyGrace={.4,1.3},Thickness={.03,.18},RenderRate={15,60},ShotDamage={10,50},FlyLaunchSpeed={35,150},FlingSpeed={70,250},SpinThreshold={5,25}}) do
        local num=tonumber(cfg[k]) or D[k]
        cfg[k]=math.clamp(num==num and num or D[k],v[1],v[2])
    end
end
normalize()
-- Training camera assists do not persist enabled state.
cfg.Aim=false
cfg.Preview=false
cfg.AntiAim=false
cfg.RGB=false -- The new interface starts with stable colors.
-- First V5 run enables correction and recovery; later runs keep preferences.
if type(old)~="table" or old.GuardV5~=true then
    cfg.AntiFly=true
    cfg.AntiFling=true
    cfg.GuardCorrect=true
    cfg.SafeRecovery=true
    cfg.GuardMode="STRONG"
end
local function save() env.VISION_PRO_147_PREFS=table.clone(cfg) end
save()

local C={
    -- CONTROL: neutral graphite, crisp typography, and restrained accents.
    -- No shadows or gradients; color communicates state, not decoration.
    BG=Color3.fromRGB(17,17,17),
    SIDE=Color3.fromRGB(23,23,23),
    CARD=Color3.fromRGB(29,29,29),
    HOVER=Color3.fromRGB(40,40,40),
    STROKE=Color3.fromRGB(67,67,67),
    WHITE=Color3.fromRGB(226,226,226),
    TEXT=Color3.fromRGB(197,197,197),
    MUTED=Color3.fromRGB(147,147,147),
    PURPLE=Color3.fromRGB(92,206,196),
    BLUE=Color3.fromRGB(58,216,174),
    CYAN=Color3.fromRGB(58,216,174),
    GREEN=Color3.fromRGB(69,227,131),
    RED=Color3.fromRGB(232,95,105),
    DARK=Color3.fromRGB(12,12,12),
    GOLD=Color3.fromRGB(222,188,95),
    PINK=Color3.fromRGB(58,216,174),
    ORANGE=Color3.fromRGB(215,161,91)
}
local accentChoices={BLEU=C.BLUE,VIOLET=C.PURPLE,CYAN=C.CYAN,ROUGE=C.RED,VERT=C.GREEN,ROSE=C.PINK}
local S={Alive=true,Open=true,Page="HOME",Connections={},Players={},Targets={},Dummies={},
    Toggles={},Selectors={},Sliders={},Timers={},Errors=0,Frames=0,FPS=60,Rate=45,
    Hue=0,Accent=C.BLUE,LastTab=0,Hits=0,Shots=0,MarkerUntil=0,Reloading=false,
    Gun=nil,Armed=false,Ammo=12,GunGeneration=0,LastShot=0,MouseDrag=nil,KOs=0,Damage=0,
    Muzzle=nil,FlashToken=0,LastTarget=nil,SliderFills={},
    FlyFlags=0,FlingFlags=0,SpinFlags=0,
    FlySamples=0,FlingSamples=0,SpinSamples=0,
    LastError=nil,EquipError=nil,ErrorHistory={},LastGuardEvent="NONE",LastGuardSpeed=0,
    FlyCooldown=0,FlingCooldown=0,SpinCooldown=0,
    GuardCharacter=nil,LastSafeCFrame=nil,LastSafeTime=0,LastRecovery=0,RecoveryUntil=0,
    GuardNoticeCooldown=0,LastGuardHUD=0,GuardCooldown=0,GuardErrorTime=0,BlockedImpulses=0,
    LastMotionVelocity=nil,GuardCorrections=0,RecoveryReason=nil,ToastList={},RoundCorners={},
    AirborneSince=nil,LastMotionPosition=nil,AscentDuration=0,HoverDuration=0,ToastLast={},
    GuardTriggeredAt=0,GuardTriggeredReason=nil,GuardTriggeredSevere=false,
    GuardSavedAltitude=nil,GuardSafeSample=0,LastGuardCharReady=0,
    FlyState="OFF",FlingState="OFF",SpinState="OFF",
    MovementStatus=nil,MovementHUD=nil,
    OtaRelease=nil,OtaAssetUrl=nil,OtaPageUrl=nil,OtaBusy=false,OtaConfirmOpen=false,
    AccentBars={},AccentToggles={},AccentButtons={},AccentLabels={},AccentStrokes={}}
-- Only errors raised by VISION PRO are recorded here. Roblox CoreGui errors
-- and invalid animations in the experience are outside this client script.
local function logVisionError(scope,problem)
    local message=tostring(problem)
    S.Errors+=1
    S.LastError=tostring(scope)..": "..message
    table.insert(S.ErrorHistory,S.LastError:sub(1,160))
    if #S.ErrorHistory>8 then table.remove(S.ErrorHistory,1) end
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
-- CONTROL V4: radius tokens shared by all custom controls.
local ROUND={Window=2,Sidebar=2,Card=1,Compact=1,Modal=2,Pill=1}
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
local function stroke(x,col,w)
    return make("UIStroke",{Color=col or C.STROKE,Thickness=w or 1},x)
end
local function grad(x,a,b,angle)
    return make("UIGradient",{Color=ColorSequence.new(a,b),Rotation=angle or 0},x)
end
local function txt(parent,s,x,y,w,h,size,bold,col)
    return make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
        Text=s,TextColor3=col or C.WHITE,TextSize=size or 12,
        Font=Enum.Font.Code,
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
        BackgroundColor3=background or C.CARD,
        BorderSizePixel=0,AutoButtonColor=false,Active=true,Text=""
    },parent),math.min(ROUND.Pill,math.floor(h/2)))
    make("TextLabel",{
        Name="ButtonCaption",Position=UDim2.fromScale(0,0),
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text=s,TextColor3=C.WHITE,TextSize=11,
        Font=Enum.Font.GothamMedium,Active=false,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextYAlignment=Enum.TextYAlignment.Center,
        ZIndex=control.ZIndex+2
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
    -- Solid surface keeps small controls readable, without artificial shine.
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
-- V4 navigation pictograms, exact 24x24 visual bounds.
-- Only the left navigation uses icons. No third-party asset dependencies.
local function icon(parent,kind,x,y,tint)
    local ink=tint or C.WHITE
    local root=make("Frame",{
        Name="VP4_"..kind,Position=UDim2.fromOffset(x,y),
        Size=UDim2.fromOffset(24,24),BackgroundTransparency=1,
        BorderSizePixel=0,Active=false
    },parent)
    local function rect(px,py,w,h,color,r)
        return corner(make("Frame",{
            Position=UDim2.fromOffset(px,py),Size=UDim2.fromOffset(w,h),
            BackgroundColor3=color or ink,BorderSizePixel=0,Active=false
        },root),r or 2)
    end
    local function ring(px,py,w,h,r,width)
        local shape=corner(make("Frame",{
            Position=UDim2.fromOffset(px,py),Size=UDim2.fromOffset(w,h),
            BackgroundTransparency=1,BorderSizePixel=0,Active=false
        },root),r or 3)
        stroke(shape,ink,width or 2)
        return shape
    end
    local function line(x1,y1,x2,y2,w)
        local dx,dy=x2-x1,y2-y1
        local distance=math.sqrt(dx*dx+dy*dy)
        if distance<.5 then return end
        local width=w or 2
        local strokePart=rect((x1+x2-distance)/2,
            (y1+y2-width)/2,distance,width,ink,width/2)
        strokePart.Rotation=math.deg(math.atan2(dy,dx))
    end
    if kind=="home" then
        ring(3,3,8,8,2);ring(14,3,7,8,2)
        ring(3,14,7,7,2);ring(13,14,8,7,2)
    elseif kind=="eye" then
        ring(2,7,20,10,10)
        ring(9,9,6,6,8,1.7)
        rect(11,11,2,2,ink,2)
    elseif kind=="aim" then
        ring(6,6,12,12,12,2)
        rect(11,1,2,7);rect(11,16,2,7)
        rect(1,11,7,2);rect(16,11,7,2)
        rect(10,10,4,4,ink,4)
    elseif kind=="silent" then
        ring(3,3,18,18,11,2)
        ring(8,8,8,8,8,1.6)
        rect(10,10,4,4,ink,4)
        rect(19,2,3,3,ink,3)
    elseif kind=="misc" then
        line(12,2,20,5);line(20,5,19,15)
        line(19,15,12,22);line(12,22,5,15)
        line(5,15,4,5);line(4,5,12,2)
        line(8,12,11,15);line(11,15,17,9)
    elseif kind=="settings" then
        rect(3,5,18,2);rect(3,12,18,2);rect(3,19,18,2)
        ring(7,2,5,8,3,1.7)
        ring(14,9,5,8,3,1.7)
        ring(6,16,5,8,3,1.7)
    elseif kind=="info" then
        ring(3,3,18,18,12,2)
        rect(11,11,2,7);rect(11,6,2,2,ink,2)
    end
    return root
end
local overlay=make("ScreenGui",{
    Name=ONAME,DisplayOrder=850,IgnoreGuiInset=true,
    ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
},PG)
local ui=make("ScreenGui",{
    Name=GNAME,DisplayOrder=900,IgnoreGuiInset=true,
    ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling
},PG)
notify=function(message,kind)
    if not S.Alive or not cfg.Notifications or not ui.Parent then return end
    local messageKey=tostring(kind).." / "..tostring(message)
    local now=os.clock()
    if now-(S.ToastLast[messageKey] or -100)<1.8 then
        return
    end
    S.ToastLast[messageKey]=now
    local items=S.ToastList
    local color=kind=="ERROR" and C.RED or kind=="SUCCESS" and C.GREEN or S.Accent
    local toast=corner(make("Frame",{
        Name="AtelierToast3",AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-18,0,-72),Size=UDim2.fromOffset(270,52),
        BackgroundColor3=C.SIDE,BorderSizePixel=0,ZIndex=100
    },ui),ROUND.Compact)
    stroke(toast,C.STROKE,1).Transparency=.80
    local heading=txt(toast,kind=="ERROR" and "ERROR" or kind=="SUCCESS" and "SUCCESS" or "VISION PRO",
        12,4,241,16,10,true,color)
    heading.ZIndex=101
    local info=description(toast,tostring(message):sub(1,90),12,22,243,22)
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
-- CLASSIC V4.2: faithful compact script-hub layout inspired by LinoriaLib.
-- Monochrome flat surfaces, thin borders, tabs, and tight groupboxes.
local W,H=778,557
local window=corner(make("Frame",{
    Name="VisionClassic",Size=UDim2.fromOffset(W,H),
    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    BackgroundColor3=C.BG,BorderSizePixel=0,Active=true,ClipsDescendants=true
},ui),ROUND.Window)
stroke(window,C.STROKE,1).Transparency=0
local scale=make("UIScale",{Scale=1},window)
local function rescale()
    local camera=WS.CurrentCamera
    if not camera then return end
    local viewport=camera.ViewportSize
    local desired=math.clamp(tonumber(cfg.MenuScale) or .95,.65,1.1)
    scale.Scale=math.clamp(math.min(desired,(viewport.X-24)/W,
        (viewport.Y-24)/H),.32,1.1)
end

-- Small ordinary title bar: no logo tile, hero title, or marketing copy.
local header=make("Frame",{
    Name="ClassicTitlebar",Position=UDim2.fromOffset(8,5),
    Size=UDim2.fromOffset(762,27),BackgroundTransparency=1,Active=true
},window)
local logo=corner(make("Frame",{
    Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(6,12),
    BackgroundColor3=C.BLUE,BorderSizePixel=0
},header),1)
local pageTitle=txt(header,"VISION PRO  |  Private beta",13,4,398,21,13,true,C.WHITE)
local pageCounter=txt(header,"4.2.0",514,6,87,18,10,false,C.MUTED)
local minimize=btn(header,"-",687,1,30,24,C.SIDE)
local close=btn(header,"X",727,1,30,24,C.SIDE)
buttonCaption(minimize).TextSize=15
buttonCaption(close).TextSize=11
buttonCaption(close).TextColor3=C.RED
make("Frame",{
    Position=UDim2.fromOffset(6,33),Size=UDim2.fromOffset(766,1),
    BackgroundColor3=C.STROKE,BorderSizePixel=0
},window)

local tabs={"HOME","VISUALS","AIMBOT","SILENT","MISC","SETTINGS","ABOUT"}
local tabTitles={
    HOME="Main",VISUALS="Visuals",AIMBOT="Aimbot",
    SILENT="Silent Aim",MISC="Misc",SETTINGS="Settings",ABOUT="About"
}
local tabColors={
    HOME=C.BLUE,VISUALS=C.BLUE,AIMBOT=C.BLUE,
    SILENT=C.BLUE,MISC=C.BLUE,SETTINGS=C.BLUE,ABOUT=C.BLUE
}
local nav={}
local tabsBar=make("Frame",{
    Name="ClassicTabs",Position=UDim2.fromOffset(11,39),
    Size=UDim2.fromOffset(755,29),BackgroundTransparency=1
},window)
local tabWidths={67,82,83,102,63,97,68}
local tabStart=0
for i,name in ipairs(tabs) do
    local width=tabWidths[i]
    local control=btn(tabsBar,tabTitles[name],tabStart,0,width,26,C.BG)
    control.ClipsDescendants=true
    local caption=buttonCaption(control)
    caption.Font=Enum.Font.Code
    caption.TextColor3=C.MUTED
    caption.TextSize=12
    local line=make("Frame",{
        Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),
        BackgroundColor3=C.BLUE,Visible=false,BorderSizePixel=0
    },control)
    local edge=stroke(control,C.STROKE,1);edge.Transparency=.25
    nav[name]={Button=control,Title=caption,Indicator=line,Color=C.BLUE}
    on(control.MouseEnter,function()
        if S.Alive and S.Page~=name then
            control.BackgroundColor3=C.HOVER
        end
    end)
    on(control.MouseLeave,function()
        if S.Alive and S.Page~=name then control.BackgroundColor3=C.BG end
    end)
    tabStart+=width+3
end
make("Frame",{
    Position=UDim2.fromOffset(11,70),Size=UDim2.fromOffset(755,1),
    BackgroundColor3=C.STROKE,BorderSizePixel=0
},window)

-- The user sees controls right away: no oversized page heading.
local body=make("Frame",{
    Position=UDim2.fromOffset(12,79),Size=UDim2.fromOffset(753,446),
    BackgroundTransparency=1,BorderSizePixel=0
},window)
local dualPages={HOME=false,VISUALS=true,AIMBOT=true,
    SILENT=false,MISC=false,SETTINGS=true,ABOUT=false}
local groupState={}
local pages,orders,pageLayouts={},{},{}
for _,name in ipairs(tabs) do
    orders[name]=0
    local sc=make("ScrollingFrame",{
        Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,
        CanvasSize=UDim2.new(),ScrollBarThickness=3,
        ScrollBarImageColor3=C.STROKE,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ScrollingEnabled=true,Visible=false
    },body)
    make("UIPadding",{
        PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,14),
        PaddingLeft=UDim.new(0,2),PaddingRight=UDim.new(0,8)
    },sc)
    pages[name]=sc
    if dualPages[name] then
        local holder=make("Frame",{
            Name="SectionColumns",Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1
        },sc)
        local columns={}
        for index=1,2 do
            local column=make("Frame",{
                Name=index==1 and "Left" or "Right",
                Position=UDim2.new((index-1)*.5,index==2 and 5 or 0,0,0),
                Size=UDim2.new(.5,-7,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1
            },holder)
            local layout=make("UIListLayout",{
                SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,9)
            },column)
            table.insert(pageLayouts,layout)
            columns[index]=column
        end
        groupState[name]={Columns=columns,Current=nil,Count=0}
    else
        pageLayouts[name]=make("UIListLayout",{
            SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,7)
        },sc)
    end
end
local footer=make("Frame",{
    Position=UDim2.fromOffset(12,531),Size=UDim2.fromOffset(753,20),
    BackgroundTransparency=1
},window)
make("Frame",{
    Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,0,1),
    BackgroundColor3=C.STROKE,BorderSizePixel=0
},footer)
local onlineDot=corner(make("Frame",{
    Position=UDim2.fromOffset(5,8),Size=UDim2.fromOffset(6,6),
    BackgroundColor3=C.GREEN,BorderSizePixel=0
},footer),1)
local runningDot=onlineDot
local guardStatusSidebar=txt(footer,"Protection: ON",18,2,124,17,10,false,C.GREEN)
local pageDesc=txt(footer,"Ready",148,2,472,17,10,false,C.MUTED)
local v3BadgeText=txt(footer,"V4.2.0",649,2,51,17,10,true,C.MUTED)
local fpsText=txt(footer,"-- FPS",705,2,46,17,10,false,C.MUTED)
fpsText.TextXAlignment=Enum.TextXAlignment.Right
local subtitles={
    HOME="Local training dashboard",
    VISUALS="Visual settings",
    AIMBOT="Training targets only",
    SILENT="Local impact preview",
    MISC="Local physics protection",
    SETTINGS="Interface settings",
    ABOUT="Diagnostic and updates"
}
local function selectPage(name)
    if not S.Alive or not pages[name] then return end
    S.Page=name
    for key,page in pairs(pages) do
        page.Visible=key==name
        if key==name then page.CanvasPosition=Vector2.zero end
    end
    for key,item in pairs(nav) do
        local active=key==name
        item.Button.BackgroundColor3=active and C.CARD or C.BG
        item.Title.TextColor3=active and C.WHITE or C.MUTED
        item.Indicator.Visible=active
    end
    pageCounter.Text="4.2.0  /  "..tabTitles[name]
    pageDesc.Text=subtitles[name]
    runningDot.BackgroundColor3=S.Errors==0 and C.GREEN or C.GOLD
end
for n,item in pairs(nav) do
    local lastClick=0
    on(item.Button.Activated,function()
        if os.clock()-lastClick<.10 then return end
        lastClick=os.clock();selectPage(n)
    end)
end

local function order(page) orders[page]+=1 return orders[page] end
-- ECLIPSE: compact control renderers shared across all seven pages.
local function widgetParent(page)
    local group=groupState[page]
    return group and group.Current or pages[page]
end
local function section(page,text)
    local group=groupState[page]
    if group then
        group.Count+=1
        local target=group.Columns[(group.Count-1)%2+1]
        local panel=corner(make("Frame",{
            Name="Groupbox_"..tostring(group.Count),
            LayoutOrder=group.Count,Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=C.SIDE,
            BorderSizePixel=0
        },target),ROUND.Card)
        stroke(panel,C.STROKE,1).Transparency=.42
        make("UIPadding",{
            PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,12),
            PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11)
        },panel)
        make("UIListLayout",{
            SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)
        },panel)
        group.Current=panel
    end
    local row=make("Frame",{
        Name="SectionHeading",Size=UDim2.new(1,-2,0,31),
        LayoutOrder=order(page),BackgroundTransparency=1
    },widgetParent(page))
    local bar=make("Frame",{
        Position=UDim2.fromOffset(2,12),Size=UDim2.fromOffset(3,10),
        BackgroundColor3=tabColors[page],BorderSizePixel=0
    },row)
    local title=txt(row,text:upper(),13,6,610,21,10,true,C.MUTED)
    title.Size=UDim2.new(1,-21,0,21)
    return row
end
local function action(page,title,detail,caption,callback)
    local compact=groupState[page]~=nil
    local danger=caption=="RESET" or caption=="REMOVE" or caption=="CLEAR"
    local row=corner(make("Frame",{
        LayoutOrder=order(page),Size=UDim2.new(1,-2,0,35),
        BackgroundColor3=C.CARD,BorderSizePixel=0
    },widgetParent(page)),ROUND.Compact)
    local outline=stroke(row,C.STROKE,1);outline.Transparency=.70
    local titleLabel=txt(row,title,13,9,compact and 240 or 545,23,12,true,C.WHITE)
    titleLabel.Size=UDim2.new(1,compact and -127 or -199,0,23)
    local descLabel=description(row,detail,13,31,compact and 240 or 545,20)
    descLabel.Visible=false
    descLabel.Size=UDim2.new(1,compact and -127 or -199,0,20)
    local control=btn(row,caption,0,0,compact and 98 or 137,30,
        danger and C.DARK or C.CARD)
    control.Position=UDim2.new(1,compact and -110 or -151,.5,-16)
    local label=buttonCaption(control)
    label.TextColor3=danger and C.RED or C.TEXT
    label.TextSize=10
    if danger then stroke(control,C.RED,1).Transparency=.50
    else stroke(control,C.STROKE,1).Transparency=.50 end
    on(row.MouseEnter,function()
        if S.Alive then animateUI(outline,{Transparency=.34},.12) end
    end)
    on(row.MouseLeave,function()
        if S.Alive then animateUI(outline,{Transparency=.70},.12) end
    end)
    on(control.Activated,function()
        if S.Alive then safeAction("Bouton "..title,callback) end
    end)
    return control
end
local function toggle(page,key,title,detail)
    local row=make("TextButton",{
        LayoutOrder=order(page),Size=UDim2.new(1,-2,0,27),
        BackgroundTransparency=1,BorderSizePixel=0,
        Text="",AutoButtonColor=false,Active=true
    },widgetParent(page))
    local square=make("Frame",{
        Position=UDim2.fromOffset(6,7),Size=UDim2.fromOffset(13,13),
        BackgroundColor3=C.DARK,BorderSizePixel=0,Active=false
    },row)
    local squareBorder=stroke(square,C.STROKE,1)
    local checked=txt(square,"",0,-1,13,14,11,true,C.DARK)
    checked.TextXAlignment=Enum.TextXAlignment.Center
    local caption=txt(row,title,27,5,270,19,12,false,C.TEXT)
    caption.Size=UDim2.new(1,-32,0,19)
    caption.Font=Enum.Font.Code
    local protective=key=="AntiFly" or key=="AntiFling"
        or key=="SafeRecovery" or key=="GuardCorrect" or key=="AntiAim"
    local function update()
        local enabled=cfg[key]==true
        local color=protective and C.GREEN or S.Accent
        square.BackgroundColor3=enabled and color or C.DARK
        squareBorder.Color=enabled and color or C.STROKE
        checked.Text=enabled and "x" or ""
        caption.TextColor3=enabled and C.WHITE or C.TEXT
    end
    on(row.MouseEnter,function()
        if S.Alive then row.BackgroundColor3=C.HOVER;row.BackgroundTransparency=.3 end
    end)
    on(row.MouseLeave,function()
        row.BackgroundTransparency=1
    end)
    on(row.Activated,function()
        if not S.Alive then return end
        cfg[key]=not cfg[key]
        save();update()
        if key~="Animations" then
            notify(title.." / "..(cfg[key] and "ON" or "OFF"),"INFO")
        end
    end)
    table.insert(S.Toggles,update)
    update()
end
local function choices(page,title,key,options)
    local row=corner(make("Frame",{
        LayoutOrder=order(page),Size=UDim2.new(1,-2,0,54),
        BackgroundColor3=C.CARD,BorderSizePixel=0
    },widgetParent(page)),ROUND.Compact)
    stroke(row,C.STROKE,1).Transparency=.74
    local heading=txt(row,title,6,2,580,21,12,false,C.TEXT)
    heading.Size=UDim2.new(1,-24,0,21)
    local holder=corner(make("Frame",{
        Position=UDim2.fromOffset(6,25),
        Size=UDim2.new(1,-12,0,26),BackgroundColor3=C.DARK,
        BorderSizePixel=0
    },row),ROUND.Pill)
    local count=#options
    local controls={}
    for i,option in ipairs(options) do
        local button=btn(holder,option,0,3,22,26,C.DARK)
        button.Position=UDim2.new((i-1)/count,3,0,3)
        button.Size=UDim2.new(1/count,-6,0,21)
        buttonCaption(button).TextSize=count>4 and 9 or 10
        controls[option]=button
        on(button.Activated,function()
            cfg[key]=option
            if key=="Accent" then cfg.RGB=false end
            save()
            for _,fn in ipairs(S.Selectors) do fn() end
            for _,fn in ipairs(S.Toggles) do fn() end
        end)
    end
    table.insert(S.Selectors,function()
        for option,button in pairs(controls) do
            local active=cfg[key]==option
            button.BackgroundColor3=active and S.Accent or C.DARK
            buttonCaption(button).TextColor3=active and C.DARK or C.MUTED
        end
    end)
end
local function slider(page,key,title,low,high,step,unit)
    if type(D[key])~="number" then error("Unknown numeric slider: "..tostring(key)) end
    if type(low)~="number" or type(high)~="number" or type(step)~="number"
        or low>=high or step<=0 then error("Invalid slider bounds: "..tostring(key)) end
    cfg[key]=math.clamp(tonumber(cfg[key]) or D[key],low,high)
    local row=corner(make("Frame",{
        LayoutOrder=order(page),Size=UDim2.new(1,-2,0,56),
        BackgroundColor3=C.CARD,BorderSizePixel=0
    },widgetParent(page)),ROUND.Compact)
    stroke(row,C.STROKE,1).Transparency=.74
    local heading=txt(row,title,13,7,250,22,12,true,C.WHITE)
    heading.Size=UDim2.new(1,-154,0,22)
    local value=txt(row,"",0,8,114,21,11,true,C.CYAN)
    value.Position=UDim2.new(1,-130,0,8)
    value.TextXAlignment=Enum.TextXAlignment.Right
    table.insert(S.AccentLabels,value)
    local zone=make("Frame",{
        Position=UDim2.fromOffset(9,29),Size=UDim2.new(1,-18,0,22),
        BackgroundTransparency=1,Active=true
    },row)
    local rail=corner(make("Frame",{
        Position=UDim2.new(0,0,.5,-7),
        Size=UDim2.new(1,0,0,14),
        BackgroundColor3=C.DARK,BorderSizePixel=0
    },zone),2)
    local fill=corner(make("Frame",{
        Size=UDim2.fromScale(0,1),BackgroundColor3=S.Accent,BorderSizePixel=0
    },rail),2)
    table.insert(S.SliderFills,fill)
    local thumb=corner(make("Frame",{
        AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(12,12),
        BackgroundColor3=C.WHITE,BorderSizePixel=0
    },rail),6)
    thumb.Visible=false
    local function refreshSlider()
        local current=tonumber(cfg[key]) or D[key]
        current=math.clamp(current==current and current or D[key],low,high)
        cfg[key]=current
        local fraction=math.clamp((current-low)/(high-low),0,1)
        fill.Size=UDim2.fromScale(fraction,1)
        thumb.Position=UDim2.fromScale(fraction,.5)
        value.Text=(step<1 and string.format("%.2f",current)
            or tostring(math.floor(current+.5)))..(unit or "")
    end
    local function set(x)
        if zone.AbsoluteSize.X<2 then return end
        local fraction=math.clamp((x-zone.AbsolutePosition.X)/zone.AbsoluteSize.X,0,1)
        cfg[key]=math.clamp(math.floor((low+fraction*(high-low))/step+.5)*step,low,high)
        save();refreshSlider()
        if key=="MenuScale" then rescale() end
        if key=="UIRoundness" then refreshRoundness() end
    end
    on(zone.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or
            input.UserInputType==Enum.UserInputType.Touch then
            S.MouseDrag={Touch=input.UserInputType==Enum.UserInputType.Touch,
                Input=input,Set=set}
            set(input.Position.X)
        end
    end)
    refreshSlider()
    table.insert(S.Sliders,refreshSlider)
end
-- Prevent one broken UI element from stopping all later tabs.
local function safeBuildWidget(kind,constructor)
    return function(page,...)
        local ok,result=pcall(constructor,page,...)
        if ok then return result end
        logVisionError("UI "..tostring(page).." / "..kind,result)
        local parent=pages[page]
        if parent then
            local fallback=corner(make("Frame",{
                Size=UDim2.new(1,-2,0,56),LayoutOrder=order(page),
                BackgroundColor3=C.CARD,BorderSizePixel=0
            },parent),ROUND.Card)
            stroke(fallback,C.RED,1).Transparency=.36
            txt(fallback,"UI ERROR / "..kind,13,6,460,19,11,true,C.RED)
            description(fallback,tostring(result):sub(1,90),13,28,465,21)
        end
        return nil
    end
end
section=safeBuildWidget("SECTION",section)
action=safeBuildWidget("ACTION",action)
toggle=safeBuildWidget("TOGGLE",toggle)
choices=safeBuildWidget("CHOICES",choices)
slider=safeBuildWidget("SLIDER",slider)

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
            if d.LabelScale~=cfg.ESPTextScale then
                d.LabelScale=cfg.ESPTextScale
                d.Nametxt.TextSize=math.floor(11*cfg.ESPTextScale+.5)
                d.Subtxt.TextSize=math.floor(10*cfg.ESPTextScale+.5)
                d.HPText.TextSize=math.floor(10*cfg.ESPTextScale+.5)
            end
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
            if cfg.AdaptiveFPS and S.FPS<35 then
                geometryGap=geometryGap*1.65
            end
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
stroke(gunHUD,C.STROKE,1).Transparency=.3
local gunHudAccent=bar(gunHUD,10,9,2,49,C.BLUE)
local gunHudSecond=bar(gunHUD,196,11,1,44,C.STROKE)
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

-- CONTROL V4: quick access to local guard controls.
section("HOME","PILOTAGE")
local protectionCard=corner(make("Frame",{
    LayoutOrder=order("HOME"),Size=UDim2.new(1,-2,0,122),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.HOME),15)
local protectionLine=corner(make("Frame",{
    Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(5,122),
    BackgroundColor3=C.GREEN,BorderSizePixel=0
},protectionCard),3)
stroke(protectionCard,C.STROKE,1).Transparency=.72
local protectTitle=txt(protectionCard,"Protections actives",20,13,328,28,17,true,C.WHITE)
local protectDesc=description(protectionCard,
    "ANTI-FLIGHT   /   ANTI-FLING",20,44,330,21)
local protectCount=txt(protectionCard,
    "0 CORRECTIONS DETECTEES",20,89,315,18,10,true,C.CYAN)
local protectButton=btn(protectionCard,"DESACTIVER",0,39,136,39,C.GREEN)
protectButton.Position=UDim2.new(1,-155,0,39)
local protectButtonOutline=stroke(protectButton,C.GREEN,1)
protectButtonOutline.Transparency=.84
buttonCaption(protectButton).TextColor3=C.DARK
local function refreshProtectButton()
    local enabled=cfg.AntiFling or cfg.AntiFly
    protectionLine.BackgroundColor3=enabled and C.GREEN or C.RED
    protectTitle.Text=enabled and "Protections actives" or "Protections inactives"
    protectButton.BackgroundColor3=enabled and C.GREEN or S.Accent
    protectButtonOutline.Color=enabled and C.GREEN or S.Accent
    buttonCaption(protectButton).Text=enabled and "DESACTIVER" or "ACTIVER"
    buttonCaption(protectButton).TextColor3=C.DARK
    protectDesc.Text="MODE "..cfg.GuardMode..
        "  /  RECOVERY "..(cfg.SafeRecovery and "ON" or "OFF")
end
on(protectButton.Activated,function()
    local enabled=not (cfg.AntiFly or cfg.AntiFling)
    cfg.AntiFly=enabled
    cfg.AntiFling=enabled
    save();refresh();refreshProtectButton()
    notify("Protection / "..(enabled and "ON" or "OFF"),"INFO")
end)
table.insert(S.Toggles,refreshProtectButton)
refreshProtectButton()

section("HOME","ATELIER D ENTRAINEMENT")
local quickActions=make("Frame",{
    Name="NovaQuickGrid",LayoutOrder=order("HOME"),
    Size=UDim2.new(1,-2,0,171),
    BackgroundTransparency=1
},pages.HOME)
local quickItems={
    {"01","Arme d'entrainement","Equiper le pistolet","EQUIPER",equipGun,false},
    {"02","Mannequins","Placer 3 cibles locales","CREER",spawnDummies,false},
    {"03","Nettoyer","Retirer les mannequins","RETIRER",clearDummies,true},
    {"04","Restaurer","Reinitialiser les PV","RESTAURER",resetAllHP,true}
}
for i,item in ipairs(quickItems) do
    local x=((i-1)%2)*.5
    local y=math.floor((i-1)/2)*86
    local tile=corner(make("Frame",{
        Position=UDim2.new(x,((i-1)%2)*6,0,y),
        Size=UDim2.new(.5,-7,0,79),
        BackgroundColor3=C.CARD,BorderSizePixel=0
    },quickActions),ROUND.Card)
    stroke(tile,C.STROKE,1).Transparency=.80
    local number=txt(tile,item[1],14,9,31,22,11,true,C.CYAN)
    local tileTitle=txt(tile,item[2],46,8,160,25,12,true,C.WHITE)
    tileTitle.Size=UDim2.new(1,-61,0,25)
    local tileDetail=description(tile,item[3],46,34,160,18)
    tileDetail.Size=UDim2.new(1,-61,0,18)
    local runButton=btn(tile,item[4],0,52,95,24,
        item[6] and C.DARK or C.BLUE)
    runButton.Position=UDim2.new(1,-110,0,52)
    buttonCaption(runButton).TextSize=10
    buttonCaption(runButton).TextColor3=item[6] and C.RED or C.DARK
    if item[6] then
        stroke(runButton,C.RED,1).Transparency=.50
    else
        table.insert(S.AccentButtons,runButton)
    end
    on(runButton.Activated,function()
        if S.Alive then safeAction("Quick "..item[2],item[5]) end
    end)
end

section("HOME","STATISTIQUES")
local homeStatus=make("Frame",{
    LayoutOrder=order("HOME"),Size=UDim2.new(1,-2,0,82),
    BackgroundTransparency=1
},pages.HOME)
local targetsCard=corner(make("Frame",{
    Position=UDim2.fromOffset(0,0),Size=UDim2.new(.5,-7,0,75),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},homeStatus),ROUND.Card)
local ammoCard=corner(make("Frame",{
    Position=UDim2.new(.5,6,0,0),Size=UDim2.new(.5,-7,0,75),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},homeStatus),11)
stroke(targetsCard,C.STROKE,1).Transparency=.72
stroke(ammoCard,C.STROKE,1).Transparency=.72
txt(targetsCard,"CIBLES DISPONIBLES",15,9,260,20,10,true,C.MUTED)
dummyInfo=txt(targetsCard,"Targets: 0 / 3",15,34,223,29,16,true,C.CYAN)
txt(ammoCard,"MUNITIONS",15,9,260,20,10,true,C.MUTED)
weaponInfo=txt(ammoCard,"Ammo: 12 / 12",15,34,223,29,14,true,C.WHITE)

section("VISUALS","AFFICHAGE 3D")
toggle("VISUALS","ESP","Activer les visuels","Activer ou desactiver tout l'ESP")
toggle("VISUALS","Box","Boites 3D","Affichage 3D uniquement")
choices("VISUALS","Couleur des boites","BoxColor",{"BLEU","VIOLET","RGB","ACCENT"})
choices("VISUALS","Affichage ESP V4","ESPDetail",{"FULL","COMPACT"})
slider("VISUALS","ESPExtraRange","Distance des effets",200,1500,100," studs")
slider("VISUALS","ESPTextScale","Taille du texte ESP",.8,1.4,.1," x")
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

section("AIMBOT","CAMERA D ENTRAINEMENT")
toggle("AIMBOT","Aim","Assistance camera","Clic droit pour suivre un mannequin vivant")
toggle("AIMBOT","ShowFOV","Afficher le rayon","Zone de selection du viseur")
choices("AIMBOT","Zone ciblee","AimPart",{"HEAD","BODY"})
toggle("AIMBOT","AimLOS","Visibilite requise","Ignorer les cibles derriere les murs")
slider("AIMBOT","AimFOV","Rayon de ciblage",60,300,10," px")
slider("AIMBOT","AimSmooth","Fluidite du suivi",.03,.45,.02," s")
section("AIMBOT","CIBLES DE TEST")
action("AIMBOT","Creer les cibles","Trois mannequins espaces","SPAWN",spawnDummies)

section("SILENT","SIMULATION D IMPACTS")
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
section("MISC","PROTECTION")
toggle("MISC","AntiFling","Anti-fling V4","Limiter les projections et les collisions anormales")
toggle("MISC","AntiFly","Anti-flight V4","Limiter les montes anormales et le vol prolonge")
choices("MISC","Protection","GuardMode",{"NORMAL","STRONG"})
toggle("MISC","SafeRecovery","Recuperation d'urgence","Retour apres une projection ou un vol anormal confirme")
slider("MISC","FlingSpeed","Vitesse horizontale limite",70,250,10," studs/s")
slider("MISC","FlyLaunchSpeed","Vitesse verticale limite",35,150,5," studs/s")
slider("MISC","FlyGrace","Tolerance des sauts",.4,1.3,.1," s")
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
local miscStatus=txt(miscPanel,"GUARD V4 / MONITORING",13,5,460,24,11,true,C.CYAN)
local miscHint=description(miscPanel,"Client-side only / Server physics may override corrections.",13,32,467,24)
S.MovementStatus=miscStatus
action("MISC","Effacer les alertes","Vider les compteurs sans desactiver les protections","RESET",function()
    cfg.AntiAim=false
    S.FlyFlags=0;S.FlingFlags=0;S.SpinFlags=0
    S.FlySamples=0;S.FlingSamples=0;S.SpinSamples=0
    S.FlyState="MONITORING";S.FlingState="MONITORING";S.SpinState="OFF"
    S.BlockedImpulses=0
    S.GuardCorrections=0
    S.RecoveryUntil=0
    S.GuardTriggeredSevere=false
    save();refresh()
end)

section("SETTINGS","PERFORMANCE")
choices("SETTINGS","Mode performance","PerformanceMode",{"LOW","BALANCED","HIGH"})
toggle("SETTINGS","AdaptiveFPS","Rafraichissement adaptatif","Adapter le rendu aux FPS")
slider("SETTINGS","RenderRate","Frequence d'affichage",15,60,5," Hz")
slider("SETTINGS","Range","Distance ESP",100,2500,100," studs")
section("SETTINGS","APPARENCE")
slider("SETTINGS","UIRoundness","Arrondi des coins",.7,1.5,.1," x")
slider("SETTINGS","MenuScale","Taille du menu",.7,1.15,.05," x")
choices("SETTINGS","Raccourci du menu","Shortcut",{"TAB","RIGHTSHIFT","F4"})
choices("SETTINGS","Couleur d'accent","Accent",{"BLEU","VIOLET","CYAN","ROUGE","VERT","ROSE"})
toggle("SETTINGS","Animations","Animations de l'interface","Transitions et survols discrets")
toggle("SETTINGS","Notifications","Notifications V4","Alertes regroupees et anti-spam")
toggle("SETTINGS","MiniButton","Bouton flottant","Raccourci quand le menu est ferme")
toggle("SETTINGS","CompactUI","Interface compacte V4","Reduire les espaces entre les cartes")
action("SETTINGS","Restaurer les parametres","Revenir aux parametres par defaut","RESET",function()
    for k,v in pairs(D) do cfg[k]=v end
    normalize();save();refresh();refreshRoundness();rescale()
end)

local diagOverview,diagGuard,diagLastError
do -- ABOUT: build status + configured OTA URL, no public input field.
local Http = game:GetService("HttpService")
local aboutBuild=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,57),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
stroke(aboutBuild,C.STROKE,1).Transparency=.55
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
stroke(versionPill,C.STROKE,1).Transparency=.67
local versionPillText=txt(versionPill,"v"..V,0,4,90,21,12,true,C.BLUE)
versionPillText.TextXAlignment=Enum.TextXAlignment.Center

section("ABOUT","DIAGNOSTIC")
local diagCard=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,117),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
stroke(diagCard,C.STROKE,1).Transparency=.50
diagOverview=txt(diagCard,"FPS --  /  ERRORS 0",14,8,465,22,12,true,C.WHITE)
diagGuard=description(diagCard,"FLIGHT OFF / FLING OFF",14,38,465,22)
diagLastError=description(diagCard,"LAST ERROR / NONE",14,67,465,40)
diagLastError.TextWrapped=true
action("ABOUT","Afficher les erreurs","Details dans la console Roblox","LOG",function()
    print("[VISION PRO DIAGNOSTIC "..V.."] FPS "..S.FPS.." / ERRORS "..S.Errors)
    print("FLIGHT "..S.FlyState.." / FLING "..S.FlingState.." / EVENT "..S.LastGuardEvent.." / SPEED "..S.LastGuardSpeed)
    for index,message in ipairs(S.ErrorHistory) do
        print("ERROR "..index..": "..message)
    end
end)

section("ABOUT","GITHUB OTA")
local otaPanel=corner(make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,114),
    BackgroundColor3=C.CARD,BorderSizePixel=0
},pages.ABOUT),ROUND.Card)
stroke(otaPanel,C.STROKE,1).Transparency=.60
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

section("ABOUT","JOURNAL DES VERSIONS")
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
releaseLine(1,"4.2.0","CLASSIC UI","Navigation et controles classiques compacts",C.CYAN)
releaseLine(2,"3.4.0","MODERN SWITCH","Derniere interface de la serie V3",C.PURPLE)
releaseLine(3,"3.3.0","WORKBENCH","Ancienne disposition de l accueil",C.GOLD)
local aboutEnd=make("Frame",{
    LayoutOrder=order("ABOUT"),Size=UDim2.new(1,-2,0,34),
    BackgroundTransparency=1
},pages.ABOUT)
description(aboutEnd,"LOCAL TRAINING ONLY  /  No server-side game damage",12,4,470,24)

end -- About scope

local function refreshDiagnostics()
    if not diagOverview or not diagOverview.Parent then return end
    diagOverview.Text="FPS "..tostring(S.FPS)..
        "  /  ERRORS "..tostring(S.Errors).."  /  RATE "..tostring(S.Rate)
    diagGuard.Text="FLIGHT "..S.FlyState.."  /  FLING "..S.FlingState..
        "  /  "..S.LastGuardEvent.." "..tostring(S.LastGuardSpeed)
    diagLastError.Text="LAST ERROR / "..(S.LastError or "NONE"):sub(1,110)
    diagOverview.TextColor3=S.Errors>0 and C.GOLD or C.WHITE
end

-- Close/minimize, keyboard, camera and render lifecycle.
local mini=btn(ui,"VP",19,90,45,35,C.BLUE);mini.Visible=false
buttonCaption(mini).TextColor3=C.DARK
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
    if input.Position.X>header.AbsolutePosition.X+header.AbsoluteSize.X*.69 then return end
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
-- Flat status overlay; no decorative gradient.
stroke(movementHud,C.STROKE,1).Transparency=.32
local flightText=txt(movementHud,"LAUNCH / OFF",11,3,217,20,10,true,C.CYAN)
local flingText=description(movementHud,"FLING / OFF",11,22,217,18)
local angleText=description(movementHud,"ROTATION / OFF",11,40,217,16)
S.MovementHUD=movementHud
local function resetDefense()
    S.FlyState="OFF"
    S.FlingState="OFF"
    S.SpinState="OFF"
    S.FlySamples=0
    S.FlingSamples=0
    S.SpinSamples=0
    S.LastMotionVelocity=nil
    S.LastMotionPosition=nil
    S.AirborneSince=nil
    S.AscentDuration=0
    S.HoverDuration=0
    S.RecoveryUntil=0
    S.GuardTriggeredAt=0
    S.GuardTriggeredReason=nil
    S.GuardTriggeredSevere=false
end

-- Anti Flight V4: work on a client's locally simulated character only.
-- Network ownership and server-authoritative motion cannot be overridden here.
local function updateMovement(dt)
    if not S.Alive then return end
    local character=Me.Character
    local root=character and character:FindFirstChild("HumanoidRootPart")
    local humanoid=character and character:FindFirstChildOfClass("Humanoid")
    if S.GuardCharacter~=character then
        S.GuardCharacter=character
        S.LastSafeCFrame=nil
        S.LastSafeTime=0
        S.LastRecovery=0
        resetDefense()
    end
    if not root or not root:IsA("BasePart")
        or not humanoid or humanoid.Health<=0 then
        movementHud.Visible=false
        return
    end

    local now=os.clock()
    local state=humanoid:GetState()
    -- Physics and PlatformStand are deliberately NOT exempt:
    -- fling/launch impulses can put Humanoid in those states.
    local excluded=humanoid.Sit or root.Anchored
        or state==Enum.HumanoidStateType.Seated
        or state==Enum.HumanoidStateType.Swimming
        or state==Enum.HumanoidStateType.Climbing
        or state==Enum.HumanoidStateType.Dead
    local v=root.AssemblyLinearVelocity
    local angular=root.AssemblyAngularVelocity
    local prev=S.LastMotionVelocity
    local prevPosition=S.LastMotionPosition
    S.LastMotionVelocity=v
    S.LastMotionPosition=root.Position

    local horizontal=Vector3.new(v.X,0,v.Z)
    local hSpeed=horizontal.Magnitude
    local speedY=v.Y
    local strict=cfg.GuardMode=="STRONG"
    local hLimit=cfg.FlingSpeed*(strict and .82 or 1)
    local yLimit=cfg.FlyLaunchSpeed*(strict and .78 or 1)
    local hShock=prev and Vector3.new(
        v.X-prev.X,0,v.Z-prev.Z).Magnitude or 0
    local yShock=prev and math.max(0,v.Y-prev.Y) or 0
    local onGround=humanoid.FloorMaterial~=Enum.Material.Air
    local displacementY=prevPosition and root.Position.Y-prevPosition.Y or 0

    if excluded then
        S.AirborneSince=nil
        S.AscentDuration=0
        S.HoverDuration=0
        S.RecoveryUntil=0
        S.GuardTriggeredAt=0
        S.GuardTriggeredReason=nil
        S.FlingState="EXEMPT"
        S.FlyState="EXEMPT"
        S.SpinState="EXEMPT"
        S.FlingSamples=0
        S.FlySamples=0
        S.SpinSamples=0
    else
        if onGround then
            S.AirborneSince=nil
            S.AscentDuration=0
            S.HoverDuration=0
            S.GuardTriggeredAt=0
            S.GuardTriggeredReason=nil
            S.GuardTriggeredSevere=false
            S.RecoveryUntil=0
            -- Store only stable standing points; never store a fling destination.
            if hSpeed<28 and math.abs(speedY)<16 then
                if now-S.GuardSafeSample>.12 then
                    S.LastSafeCFrame=root.CFrame
                    S.LastSafeTime=now
                    S.GuardSafeSample=now
                end
            end
        elseif not S.AirborneSince then
            S.AirborneSince=now
            S.AscentDuration=0
            S.HoverDuration=0
        end

        local airTime=S.AirborneSince and (now-S.AirborneSince) or 0
        local safe=S.LastSafeCFrame
        local heightAbove=safe and root.Position.Y-safe.Position.Y or 0
        -- A normal jump lasts a short time and rises only a few studs.
        local jumpGrace=airTime<cfg.FlyGrace and heightAbove<13
        local suddenY=speedY>yLimit
        local extremeY=speedY>math.max(95,yLimit*1.85)
        local verticalImpulse=(not jumpGrace and suddenY)
            or (extremeY and yShock>math.max(27,yLimit*.65))

        -- Catch slower continuous flight/hover that the velocity-only V4 missed.
        if not onGround and heightAbove>13 and airTime>.75
            and (speedY>3.5 or displacementY>.16) then
            S.AscentDuration=math.min(3,S.AscentDuration+math.min(dt,.1))
        else
            S.AscentDuration=math.max(0,S.AscentDuration-math.min(dt,.1)*.6)
        end
        if not onGround and heightAbove>18 and airTime>2.1
            and math.abs(speedY)<8 then
            S.HoverDuration=math.min(3,S.HoverDuration+math.min(dt,.1))
        else
            S.HoverDuration=math.max(0,S.HoverDuration-math.min(dt,.1)*.6)
        end
        local slowFlight=not onGround and cfg.AntiFly and safe~=nil
            and ((heightAbove>18 and S.AscentDuration>.48)
                or (heightAbove>20 and S.HoverDuration>.65))
        local hitY=cfg.AntiFly and (
            (verticalImpulse and (airTime>.15 or extremeY))
            or slowFlight)
        local hitH=cfg.AntiFling and
            ((hSpeed>hLimit and
                (strict or hShock>hLimit*.28 or hSpeed>hLimit*1.65))
                or (hShock>hLimit*1.25 and hSpeed>hLimit*.65))
        local hitSpin=cfg.AntiAim and
            math.abs(angular.Y)>cfg.SpinThreshold

        S.FlyState=cfg.AntiFly
            and (hitY and (slowFlight and "FLIGHT" or "LAUNCH")
                or "MONITORING") or "OFF"
        S.FlingState=cfg.AntiFling
            and (hitH and "FLING" or "MONITORING") or "OFF"
        S.SpinState=cfg.AntiAim
            and (hitSpin and "SPIN" or "MONITORING") or "OFF"

        if (hitY or hitH) and cfg.GuardCorrect then
            S.LastGuardEvent=hitY and (slowFlight and "FLIGHT" or "LAUNCH") or "FLING"
            S.LastGuardSpeed=math.floor(math.max(math.abs(speedY),hSpeed)+.5)
            -- Clear the dangerous axis while leaving ordinary movement alone.
            local nextH=horizontal
            if hitH and hSpeed>.01 then
                nextH=horizontal.Unit*math.min(hSpeed,hLimit*.37)
            end
            local nextY=speedY
            if hitY then nextY=math.min(speedY,slowFlight and -7 or 8) end
            root.AssemblyLinearVelocity=Vector3.new(nextH.X,nextY,nextH.Z)
            if angular.Magnitude>math.max(8,cfg.SpinThreshold*1.1) then
                root.AssemblyAngularVelocity=Vector3.zero
            end
            if now-S.GuardCooldown>.55 then
                S.BlockedImpulses+=1
                S.GuardCorrections+=1
                S.GuardCooldown=now
                if hitY then S.FlyFlags+=1 end
                if hitH then S.FlingFlags+=1 end
            end
            -- A short correction isn't enough when a server/network impulse repeats.
            -- Schedule a single grounded recovery, not a permanent teleport loop.
            local severe=extremeY or hSpeed>hLimit*2
                or heightAbove>24 or slowFlight
            if cfg.SafeRecovery and severe and safe and
                now-S.LastSafeTime<10 and airTime>.35 then
                S.GuardTriggeredAt=now
                S.GuardTriggeredReason=slowFlight and "FLIGHT"
                    or (hitY and "LAUNCH" or "FLING")
                S.GuardTriggeredSevere=true
                S.RecoveryUntil=now+1.7
            end
            if now-S.GuardNoticeCooldown>2.3 then
                notify("Guard V4 / correction active","INFO")
                S.GuardNoticeCooldown=now
            end
        elseif hitSpin and cfg.GuardCorrect then
            root.AssemblyAngularVelocity=Vector3.new(angular.X,
                math.clamp(angular.Y,-cfg.SpinThreshold*.5,
                    cfg.SpinThreshold*.5),angular.Z)
        end

        if cfg.SafeRecovery and cfg.GuardCorrect
            and S.GuardTriggeredSevere and S.RecoveryUntil>now
            and S.LastSafeCFrame and now-S.LastSafeTime<10
            and now-S.LastRecovery>2.5 and not onGround then
            local safeFrame=S.LastSafeCFrame
            local delta=root.Position-safeFrame.Position
            local distance=delta.Magnitude
            -- Only return after a clearly abnormal displacement or air time.
            if distance>13 and distance<220
                and (delta.Y>16 or horizontal.Magnitude>hLimit
                    or airTime>1.4) then
                local query=RaycastParams.new()
                query.FilterType=Enum.RaycastFilterType.Exclude
                query.FilterDescendantsInstances={character}
                query.IgnoreWater=true
                local ground=WS:Raycast(
                    safeFrame.Position+Vector3.new(0,4,0),
                    Vector3.new(0,-12,0),query)
                if ground and ground.Instance and ground.Instance.CanCollide
                    and ground.Normal.Y>.67 then
                    local returnPos=Vector3.new(safeFrame.Position.X,
                        math.max(safeFrame.Position.Y,
                            ground.Position.Y+3),safeFrame.Position.Z)
                    local rotation=root.CFrame-root.Position
                    character:PivotTo(CFrame.new(returnPos)*rotation)
                    root.AssemblyLinearVelocity=Vector3.zero
                    root.AssemblyAngularVelocity=Vector3.zero
                    S.LastRecovery=now
                    S.RecoveryUntil=0
                    S.GuardTriggeredSevere=false
                    S.GuardTriggeredReason=nil
                    S.AscentDuration=0
                    S.HoverDuration=0
                    S.FlyState="RECOVERED"
                    S.FlingState="RECOVERED"
                    notify("Guard V4 / retour au sol","SUCCESS")
                end
            end
        end
    end

    if now-S.LastGuardHUD<.14 then return end
    S.LastGuardHUD=now
    local active=cfg.AntiFly or cfg.AntiFling
    guardStatusSidebar.Text=active and "GUARD V4 / ON" or "GUARD V4 / OFF"
    onlineDot.BackgroundColor3=active and C.GREEN or C.RED
    if protectCount.Parent then
        protectCount.Text=tostring(S.BlockedImpulses).." CORRECTIONS"
    end
    if S.MovementStatus and S.MovementStatus.Parent then
        S.MovementStatus.Text="FLIGHT "..S.FlyState..
            " / FLING "..S.FlingState.." / CORR "..S.BlockedImpulses
    end
    movementHud.Visible=not S.Open and cfg.MoveHUD
        and (cfg.AntiFly or cfg.AntiFling or cfg.AntiAim)
    flightText.Text="FLIGHT / "..S.FlyState.." ("..S.FlyFlags..")"
    flingText.Text="FLING / "..S.FlingState.." ("..S.FlingFlags..")"
    angleText.Text="ROTATION / "..S.SpinState.." ("..S.SpinFlags..")"
    flightText.TextColor3=(S.FlyState=="LAUNCH"
        or S.FlyState=="FLIGHT") and C.RED or C.CYAN
    flingText.TextColor3=S.FlingState=="FLING" and C.RED or C.MUTED
    angleText.TextColor3=S.SpinState=="SPIN" and C.RED or C.MUTED
end

local function theme(dt)
    local accent=accentChoices[cfg.Accent] or C.BLUE
    if accent~=S.Accent or not S.PaletteReady then
        S.PaletteReady=true
        S.Accent=accent
        logo.BackgroundColor3=accent
        if protectButton and protectButton.Parent then
            refreshProtectButton()
        end
        pageCounter.TextColor3=accent
        v3BadgeText.TextColor3=C.TEXT
        for _,page in pairs(pages) do page.ScrollBarImageColor3=C.STROKE end
        for _,item in pairs(nav) do
            item.Indicator.BackgroundColor3=item.Color
        end
        for _,control in ipairs(S.AccentButtons) do
            if control.Parent then control.BackgroundColor3=accent end
        end
        for _,line in ipairs(S.SliderFills) do
            if line.Parent then line.BackgroundColor3=accent end
        end
        for _,update in ipairs(S.Selectors) do update() end
        for _,update in ipairs(S.Toggles) do update() end
        for _,update in ipairs(S.Sliders) do update() end
        gunHudAccent.BackgroundColor3=accent
        fovOutline.Color=accent
    end
    gunHudSecond.BackgroundColor3=C.STROKE
    local gap=cfg.CompactUI and 4 or 9
    for _,layout in pairs(pageLayouts) do
        if layout.Padding.Offset~=gap then
            layout.Padding=UDim.new(0,gap)
        end
    end
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
    local page=pages[name]
    local childCount=0
    for _,element in ipairs(page:GetChildren()) do
        if element:IsA("GuiObject") then childCount+=1 end
    end
    if childCount==0 then
        logVisionError("Page "..name,"No UI elements were created")
        local row=corner(make("Frame",{
            Size=UDim2.new(1,-2,0,60),LayoutOrder=1,
            BackgroundColor3=C.CARD,BorderSizePixel=0
        },page),ROUND.Card)
        txt(row,"UI ERROR / PAGE EMPTY",14,10,460,22,12,true,C.RED)
        description(row,"Check developer console for error details.",14,34,460,20)
    end
end
selectPage("HOME");rescale();changeInfo();refresh();theme(0);refreshDiagnostics()
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
        updateInterval=math.max(updateInterval,S.FPS<24 and .42 or .32)
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
        fpsClock=0;frames=0;rescale();refreshDiagnostics()
    end
end)
print("VISION PRO "..V.." - CLASSIC / PRIVATE BETA RELEASE")

end -- runVisionProUnlocked

-- V4 BETA GATE: external key generator / verification, NO Roblox Studio needed.
-- Deploy beta-generator/worker.js separately to Cloudflare Workers with D1.
-- Set this to your own deployed HTTPS endpoint (without trailing slash).
-- Never put the Cloudflare ADMIN_TOKEN or a private key list in this client.
local BETA_API_URL="https://vision-pro-beta-v4.clienthom.workers.dev"
local function bootVisionPro()
    if not game:IsLoaded() then game.Loaded:Wait() end
    local Players=game:GetService("Players")
    local HttpService=game:GetService("HttpService")
    local player=Players.LocalPlayer
    if not player then return end
    local playerGui=player:WaitForChild("PlayerGui")

    local old=playerGui:FindFirstChild("VISION_PRO_V4_BETA_GATE")
    if old then old:Destroy() end
    local gate=Instance.new("ScreenGui")
    gate.Name="VISION_PRO_V4_BETA_GATE"
    gate.ResetOnSpawn=false
    gate.IgnoreGuiInset=true
    gate.DisplayOrder=1500
    gate.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gate.Parent=playerGui

    local function elem(class,props,parent)
        local object=Instance.new(class)
        for key,value in pairs(props or {}) do object[key]=value end
        object.Parent=parent
        return object
    end
    local function radius(frame,number)
        elem("UICorner",{CornerRadius=UDim.new(0,number)},frame)
        return frame
    end
    -- ECLIPSE activation: a new compact centered modal with no external UI.
    local bg=elem("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundColor3=Color3.fromRGB(5,7,12),
        BackgroundTransparency=.09,BorderSizePixel=0
    },gate)
    local card=radius(elem("Frame",{
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(526,362),
        BackgroundColor3=Color3.fromRGB(19,23,32),
        BorderSizePixel=0,ClipsDescendants=true
    },bg),10)
    elem("UIStroke",{
        Color=Color3.fromRGB(70,77,108),Thickness=1,Transparency=.17
    },card)
    local resize=elem("UIScale",{Scale=1},card)
    local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
    if viewport then
        resize.Scale=math.clamp(math.min(
            (viewport.X-28)/526,(viewport.Y-28)/362,1),.35,1)
    end
    elem("Frame",{
        Size=UDim2.fromOffset(526,4),
        BackgroundColor3=Color3.fromRGB(58,216,174),
        BorderSizePixel=0
    },card)
    local vpTile=radius(elem("Frame",{
        Position=UDim2.fromOffset(24,25),Size=UDim2.fromOffset(38,38),
        BackgroundColor3=Color3.fromRGB(58,216,174),BorderSizePixel=0
    },card),7)
    elem("TextLabel",{
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text="V",TextSize=24,Font=Enum.Font.GothamBold,
        TextColor3=Color3.fromRGB(15,19,33)
    },vpTile)
    elem("TextLabel",{
        Position=UDim2.fromOffset(74,21),Size=UDim2.fromOffset(311,22),
        BackgroundTransparency=1,Text="VISION PRO",
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=15,
        Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(245,247,252)
    },card)
    elem("TextLabel",{
        Position=UDim2.fromOffset(75,45),Size=UDim2.fromOffset(318,18),
        BackgroundTransparency=1,Text="ECLIPSE  /  KEY AUTHENTICATION",
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=10,
        Font=Enum.Font.GothamMedium,
        TextColor3=Color3.fromRGB(149,163,188)
    },card)
    local badge=radius(elem("Frame",{
        Position=UDim2.fromOffset(419,29),Size=UDim2.fromOffset(81,25),
        BackgroundColor3=Color3.fromRGB(32,39,64),BorderSizePixel=0
    },card),6)
    elem("TextLabel",{
        Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
        Text="BETA V4.2",TextSize=10,Font=Enum.Font.GothamBold,
        TextColor3=Color3.fromRGB(171,188,255)
    },badge)
    elem("Frame",{
        Position=UDim2.fromOffset(24,81),Size=UDim2.fromOffset(476,1),
        BackgroundColor3=Color3.fromRGB(51,57,77),BorderSizePixel=0
    },card)
    elem("TextLabel",{
        Position=UDim2.fromOffset(24,98),Size=UDim2.fromOffset(465,30),
        BackgroundTransparency=1,Text="Activation de la beta",
        TextSize=21,TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(247,248,251)
    },card)
    elem("TextLabel",{
        Position=UDim2.fromOffset(25,133),Size=UDim2.fromOffset(469,38),
        BackgroundTransparency=1,Text="Saisis une cle valide pour acceder aux outils de test.",
        TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.Gotham,TextColor3=Color3.fromRGB(153,167,192)
    },card)
    elem("TextLabel",{
        Position=UDim2.fromOffset(24,179),Size=UDim2.fromOffset(250,18),
        BackgroundTransparency=1,Text="CLE D'ACCES",
        TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamBold,
        TextColor3=Color3.fromRGB(188,200,224)
    },card)
    local field=radius(elem("TextBox",{
        Position=UDim2.fromOffset(24,205),Size=UDim2.fromOffset(476,43),
        BackgroundColor3=Color3.fromRGB(12,15,23),
        BorderSizePixel=0,ClearTextOnFocus=false,Text="",
        PlaceholderText="VP4-XXXXXXXX-XXXXXXXX-...",
        PlaceholderColor3=Color3.fromRGB(116,130,157),
        TextColor3=Color3.fromRGB(242,246,254),
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=13,
        Font=Enum.Font.GothamMedium
    },card),6)
    elem("UIPadding",{
        PaddingLeft=UDim.new(0,13),PaddingRight=UDim.new(0,13)
    },field)
    local fieldStroke=elem("UIStroke",{
        Color=Color3.fromRGB(71,83,109),Thickness=1,Transparency=.25
    },field)
    local activate=radius(elem("TextButton",{
        Position=UDim2.fromOffset(24,265),
        Size=UDim2.fromOffset(476,41),
        BackgroundColor3=Color3.fromRGB(58,216,174),
        BorderSizePixel=0,AutoButtonColor=false,
        Font=Enum.Font.GothamBold,TextSize=12,
        TextColor3=Color3.fromRGB(17,21,34),
        Text="VERIFIER LA CLE"
    },card),6)
    local status=elem("TextLabel",{
        Position=UDim2.fromOffset(24,317),Size=UDim2.fromOffset(472,29),
        Text="Verification en ligne avec Cloudflare.",
        TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,Font=Enum.Font.GothamMedium,
        TextSize=11,TextColor3=Color3.fromRGB(148,163,188)
    },card)
    local busy=false
    local unlocked=false
    local function message(text,color)
        if gate.Parent then
            status.Text=text
            status.TextColor3=color or Color3.fromRGB(156,175,198)
        end
    end
    local function openUnlocked()
        if unlocked then return end
        unlocked=true
        if gate.Parent then gate:Destroy() end
        task.defer(function()
            local good,problem=xpcall(runVisionProUnlocked,function(err)
                if type(debug)=="table" and type(debug.traceback)=="function" then
                    return debug.traceback(tostring(err),2)
                end
                return tostring(err)
            end)
            if not good then
                warn("[VISION PRO V4 / UNLOCKED STARTUP] "..tostring(problem))
            end
        end)
    end
    -- External POST client, supports common HTTP request capabilities.
    -- The key is sent as JSON in the HTTPS request body, never in a URL.
    local function getHttpRequest()
        local environments={_G}
        if type(getgenv)=="function" then
            local good,e=pcall(getgenv)
            if good and type(e)=="table" then
                table.insert(environments,1,e)
            end
        end
        for _,environment in ipairs(environments) do
            local candidate=environment.request or environment.http_request
                or (type(environment.syn)=="table" and environment.syn.request)
                or (type(environment.http)=="table" and environment.http.request)
            if type(candidate)=="function" then return candidate end
        end
        return nil
    end
    local function submitKey(key)
        if busy or unlocked then return end
        if type(BETA_API_URL)~="string"
            or BETA_API_URL:find("YOUR-SUBDOMAIN",1,true)
            or not BETA_API_URL:match("^https://[%w%._%-]+") then
            message("Configure BETA_API_URL avec le lien de ton Worker Cloudflare.",
                Color3.fromRGB(255,176,120))
            return
        end
        local sendRequest=getHttpRequest()
        if not sendRequest then
            message("Cet environnement ne dispose pas de requetes HTTPS POST.",
                Color3.fromRGB(255,176,120))
            return
        end
        busy=true
        activate.Text="VERIFICATION..."
        activate.BackgroundColor3=Color3.fromRGB(95,121,153)
        message("Verification de la cle sur le generateur...")
        task.spawn(function()
            local ok,response=pcall(function()
                return sendRequest({
                    Url=BETA_API_URL.."/api/verify",
                    Method="POST",
                    Headers={["Content-Type"]="application/json"},
                    Body=HttpService:JSONEncode({key=key})
                })
            end)
            if not gate.Parent or unlocked then return end
            local accepted=false
            local statusText="Connexion au generateur impossible"
            if ok and type(response)=="table" then
                local body=response.Body or response.body
                if type(body)=="string" then
                    local decodedOk,decoded=pcall(HttpService.JSONDecode,HttpService,body)
                    if decodedOk and type(decoded)=="table" then
                        accepted=decoded.ok==true
                        if type(decoded.message)=="string" then
                            statusText=decoded.message
                        end
                    else
                        statusText="Reponse du serveur invalide"
                    end
                end
            end
            if accepted then
                message("Cle valide. Ouverture de VISION PRO...")
                openUnlocked()
                return
            end
            message(statusText,Color3.fromRGB(255,139,158))
            busy=false
            activate.Text="VERIFIER LA CLE"
            activate.BackgroundColor3=Color3.fromRGB(58,216,174)
        end)
    end
    activate.Activated:Connect(function()
        local key=field.Text:match("^%s*(.-)%s*$")
        if #key<12 then
            message("Saisis ta cle beta generee avant de continuer.",
                Color3.fromRGB(255,139,158))
            return
        end
        submitKey(key)
    end)
    field.FocusLost:Connect(function(enter)
        if enter and not busy then
            local key=field.Text:match("^%s*(.-)%s*$")
            if #key>=12 then
                submitKey(key)
            else
                message("Cle trop courte.",Color3.fromRGB(255,139,158))
            end
        end
    end)
end -- bootVisionPro
local ok,err=xpcall(bootVisionPro,function(problem)
    local message=tostring(problem)
    if type(debug)=="table" and type(debug.traceback)=="function" then
        message=debug.traceback(message,2)
    end
    return message
end)
if not ok then
    warn("[VISION PRO 4.2.0 / STARTUP] "..tostring(err))
end
