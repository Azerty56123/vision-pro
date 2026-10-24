--[[
 VISION HUB V10 | DESIGN HOHO/RAYZ + ACCESS KEY API
 Visual recreation of common Roblox script-hub layouts using Vision branding.
 Client-only interface. No external libraries, no Roblox Studio dependency.
 Actual features: key test, navigation, search, fps/position overlays, camera FOV,
 UI zoom, recenter, open/close, player information and copy utilities.
 No server/game automation is claimed; Farm/Teleport show honest module status.
 Development key is public and is NOT secure authentication.
]]

local Players = game:GetService('Players')
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local Lighting = game:GetService('Lighting')
local TweenService = game:GetService('TweenService')
local player = Players.LocalPlayer
if not player then return warn('Vision Hub: exécuter côté client uniquement.') end
local playerGui = player:FindFirstChildOfClass('PlayerGui') or player:WaitForChild('PlayerGui', 12)
if not playerGui then return end
local KEY = 'VISION-TEST-ILLIMITE-2026'
local GUI_NAME = 'VisionHubV10'
-- Configure cette URL avec ton domaine Cloudflare apres deploiement.
local KEY_SERVICE_BASE = 'https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev'
for _,n in ipairs({GUI_NAME,'VisionHubV9_Refonte','VisionHubV8_UI','VisionHub_Universal_V8','VisionHub_Universal_V7','VisionHub_Universal_V6','VisionHub_Universal_V5'}) do
    local old=playerGui:FindFirstChild(n)
    if old then old:Destroy() end
end

local color={
    bg=Color3.fromRGB(8,6,8), surface=Color3.fromRGB(12,10,13),
    card=Color3.fromRGB(18,16,20), line=Color3.fromRGB(88,21,32),
    item=Color3.fromRGB(24,19,24), red=Color3.fromRGB(218,13,45),
    redDark=Color3.fromRGB(89,19,33), white=Color3.fromRGB(246,242,244),
    muted=Color3.fromRGB(150,144,150), green=Color3.fromRGB(76,215,124)
}
local conns,pageConns={},{}
local gone=false
local unlocked=false
local activePage='Main'
local zoom=1
local showingFPS,showingXYZ,showingPlayerCount,showFullbright,animateToggles=false,false,false,false,true
local fpsValue,fpsFrames,fpsTimer,drawTimer=0,0,0,0
local originalFOV
local currentFOV=70
local savedPosition
local keyBusy=false
local function serverConfigured()
    return type(KEY_SERVICE_BASE)=='string' and
      KEY_SERVICE_BASE:match('^https://')~=nil and
      KEY_SERVICE_BASE:find('YOUR-SUBDOMAIN',1,true)==nil
end
local function verifyRemoteKey(value)
    if not serverConfigured() then return false,'Cloudflare non configure.' end
    local requester=request or http_request or (type(syn)=='table' and syn.request)
        or (type(http)=='table' and http.request)
    if type(requester)~='function' then
        return false,'Requetes POST non disponibles dans cet executeur.'
    end
    local ok,response=pcall(requester,{
        Url=KEY_SERVICE_BASE:gsub('/+$','')..'/api/verify',
        Method='POST',
        Headers={['Content-Type']='application/json'},
        Body=HttpService:JSONEncode({key=value})
    })
    if not ok or type(response)~='table' then
        return false,'Serveur inaccessible.'
    end
    local read,data=pcall(function()
        return HttpService:JSONDecode(response.Body or response.body or '')
    end)
    if not read or type(data)~='table' then return false,'Reponse invalide.' end
    return data.ok==true,tostring(data.message or (data.ok and 'Cle validee.' or 'Cle refusee.'))
end
local defaultLight={
 Brightness=Lighting.Brightness,
 Ambient=Lighting.Ambient,
 OutdoorAmbient=Lighting.OutdoorAmbient,
 ClockTime=Lighting.ClockTime,
 FogEnd=Lighting.FogEnd
}
local function applyFullbright(value)
 showFullbright=value
 local settings=value and {
  Brightness=3,
  Ambient=Color3.fromRGB(182,182,182),
  OutdoorAmbient=Color3.fromRGB(182,182,182),
  ClockTime=12,
  FogEnd=1000000
 } or defaultLight
 for property,v in pairs(settings) do
  pcall(function() Lighting[property]=v end)
 end
end
local records={}
local liveInfo={}
local search,mainWindow,openMini,navButtons,hud,keyOverlay,footerStatus,sideState
local render
local changePage

local function mk(class,props,parent)
    local obj=Instance.new(class)
    for k,v in pairs(props or {}) do obj[k]=v end
    obj.Parent=parent
    return obj
end
local function round(obj,r)
    return mk('UICorner',{CornerRadius=UDim.new(0,r or 6)},obj)
end
local function border(obj,col,thick)
    return mk('UIStroke',{Color=col or color.line,Thickness=thick or 1},obj)
end
local function txt(parent,str,size,col,bold,props)
    local p={Text=str,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
      TextSize=size or 12,TextColor3=col or color.white,BackgroundTransparency=1,
      TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
      TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,22)}
    for k,v in pairs(props or {}) do p[k]=v end
    return mk('TextLabel',p,parent)
end
local function button(parent,str,pos,size,red)
    local b=mk('TextButton',{Text=str,TextColor3=color.white,
      BackgroundColor3=red and color.red or color.item,BorderSizePixel=0,
      Font=Enum.Font.GothamBold,TextSize=11,AutoButtonColor=true,
      Position=pos or UDim2.new(),Size=size or UDim2.fromOffset(100,30)},parent)
    round(b,5)
    return b
end
local function connect(signal,fn,page)
    local conn=signal:Connect(fn)
    table.insert(page and pageConns or conns,conn)
    return conn
end
local function stop()
    if gone then return end
    gone=true
    if showFullbright then applyFullbright(false) end
    if originalFOV and workspace.CurrentCamera then
        pcall(function()workspace.CurrentCamera.FieldOfView=originalFOV end)
    end
    for _,con in ipairs(pageConns) do pcall(function()con:Disconnect()end)end
    for _,con in ipairs(conns) do pcall(function()con:Disconnect()end)end
    if mainWindow then mainWindow:Destroy() end
    local g=playerGui:FindFirstChild(GUI_NAME)
    if g then g:Destroy() end
end
local gui=mk('ScreenGui',{Name=GUI_NAME,ResetOnSpawn=false,DisplayOrder=90,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=false},playerGui)
connect(gui.Destroying,stop)
local function status(str)
    if footerStatus and footerStatus.Parent then footerStatus.Text='Status: '..str end
    if sideState and sideState.Parent then sideState.Text='Status: '..str end
end
local function openMain(isVisible)
    if gone or not unlocked then return end
    mainWindow.Visible=isVisible
    openMini.Visible=not isVisible
end
local function pasteValue(v)
    local fn=setclipboard or toclipboard
    if type(fn)=='function' then
        local ok=pcall(fn,tostring(v))
        if ok then return true end
    end
    return false
end
local function playerPos()
    local character=player.Character
    local root=character and character:FindFirstChild('HumanoidRootPart')
    return root and root.Position
end

-- MAIN WINDOW - same overall hierarchy as reference: header / left navigation / cards / status
mainWindow=mk('Frame',{Name='MainWindow',BackgroundColor3=color.bg,BorderSizePixel=0,
    Size=UDim2.fromOffset(852,525),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5),Visible=false,ClipsDescendants=true},gui)
round(mainWindow,9)
border(mainWindow,color.red,1.1)
mk('UIGradient',{Rotation=15,Color=ColorSequence.new({
 ColorSequenceKeypoint.new(0,color.bg),
 ColorSequenceKeypoint.new(.67,Color3.fromRGB(18,9,14)),
 ColorSequenceKeypoint.new(1,color.bg)
})},mainWindow)
mk('UIGradient',{
    Rotation=17,
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,color.bg),
        ColorSequenceKeypoint.new(.63,Color3.fromRGB(14,8,13)),
        ColorSequenceKeypoint.new(1,color.bg)
    })
},mainWindow)
local mainScale=mk('UIScale',{Scale=1},mainWindow)
local header=mk('Frame',{BackgroundColor3=color.surface,BorderSizePixel=0,
    Size=UDim2.new(1,0,0,43),Active=true},mainWindow)
mk('Frame',{BackgroundColor3=color.line,BorderSizePixel=0,
    Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1)},header)
txt(header,'Vision',21,color.red,true,{Position=UDim2.fromOffset(18,4),Size=UDim2.fromOffset(76,32)})
txt(header,'!Hub',21,color.white,true,{Position=UDim2.fromOffset(95,4),Size=UDim2.fromOffset(68,32)})
txt(header,'│  UNIVERSAL HUB',11,color.red,true,{Position=UDim2.fromOffset(166,5),Size=UDim2.fromOffset(170,30)})
local headerGame=txt(header,string.upper(tostring(game.Name)),10,color.muted,true,{
    Position=UDim2.new(.57,0,0,5),Size=UDim2.new(.29,0,0,30),
    TextXAlignment=Enum.TextXAlignment.Right
})
local minButton=button(header,'−',UDim2.new(1,-77,0,7),UDim2.fromOffset(28,28))
local exitButton=button(header,'×',UDim2.new(1,-42,0,7),UDim2.fromOffset(28,28))
exitButton.TextSize=17
connect(minButton.Activated,function()openMain(false)end)
connect(exitButton.Activated,stop)

local side=mk('Frame',{BackgroundColor3=color.surface,BorderSizePixel=0,
    Position=UDim2.fromOffset(0,43),Size=UDim2.new(0,178,1,-73)},mainWindow)
mk('Frame',{BackgroundColor3=color.line,BorderSizePixel=0,
    Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0)},side)
local emblem=mk('Frame',{BackgroundColor3=color.bg,BorderSizePixel=0,
    Position=UDim2.fromOffset(49,12),Size=UDim2.fromOffset(80,80)},side)
round(emblem,42);border(emblem,color.red,1.5)
local emblemGlow=mk('Frame',{
    BackgroundColor3=color.red,BackgroundTransparency=.83,BorderSizePixel=0,
    Position=UDim2.fromOffset(12,12),Size=UDim2.fromOffset(56,56)
},emblem)
round(emblemGlow,30)
txt(emblem,'V',52,color.red,true,{
    Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center
})
local emblemBase=mk('Frame',{
    BackgroundColor3=color.red,BackgroundTransparency=.35,BorderSizePixel=0,
    AnchorPoint=Vector2.new(.5,0),Position=UDim2.fromScale(.5,1),
    Size=UDim2.fromOffset(97,2)
},side)
local sideBrand=txt(side,'VISION HUB',12,color.white,true,{Position=UDim2.fromOffset(10,96),
    Size=UDim2.fromOffset(158,24),TextXAlignment=Enum.TextXAlignment.Center})
local nav=mk('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(10,128),Size=UDim2.new(1,-20,1,-192),
    ScrollBarThickness=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,
    CanvasSize=UDim2.new()},side)
mk('UIListLayout',{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3)},nav)
local sideStat=mk('Frame',{BackgroundColor3=color.bg,BorderSizePixel=0,
    Position=UDim2.new(0,12,1,-61),Size=UDim2.new(1,-24,0,51)},side)
round(sideStat,6);border(sideStat,color.line,.8)
sideState=txt(sideStat,'Status: Ready',10,color.green,true,{Position=UDim2.fromOffset(9,5),Size=UDim2.new(1,-17,0,19)})
txt(sideStat,'Game: '..game.Name,9,color.muted,false,{Position=UDim2.fromOffset(9,27),Size=UDim2.new(1,-17,0,18)})

local content=mk('Frame',{BackgroundTransparency=1,Position=UDim2.fromOffset(178,43),
    Size=UDim2.new(1,-178,1,-73)},mainWindow)
local title=txt(content,'Main',19,color.white,true,{Position=UDim2.fromOffset(18,7),Size=UDim2.fromOffset(250,27)})
local subtitle=txt(content,'Welcome to Vision Hub',10,color.muted,false,
    {Position=UDim2.fromOffset(18,34),Size=UDim2.fromOffset(300,20)})
search=mk('TextBox',{BackgroundColor3=color.item,BorderSizePixel=0,
    Position=UDim2.new(1,-195,0,15),Size=UDim2.fromOffset(178,29),
    Text='',PlaceholderText='Search...',ClearTextOnFocus=false,
    TextColor3=color.white,PlaceholderColor3=color.muted,
    Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},content)
round(search,6);border(search,color.line,.8)
mk('UIPadding',{PaddingLeft=UDim.new(0,10)},search)
local scroll=mk('ScrollingFrame',{BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(12,62),Size=UDim2.new(1,-23,1,-72),
    ScrollBarThickness=3,ScrollBarImageColor3=color.red,
    CanvasSize=UDim2.fromOffset(0,0)},content)
local cols=mk('Frame',{BackgroundTransparency=1,Size=UDim2.new(1,-6,0,0),
    AutomaticSize=Enum.AutomaticSize.Y},scroll)
mk('UIListLayout',{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,11)},cols)
local left=mk('Frame',{BackgroundTransparency=1,Size=UDim2.new(.61,-6,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=1},cols)
local leftLayout=mk('UIListLayout',{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,9)},left)
local right=mk('Frame',{BackgroundTransparency=1,Size=UDim2.new(.39,-6,0,0),
    AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2},cols)
local rightLayout=mk('UIListLayout',{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,9)},right)

local footer=mk('Frame',{BackgroundColor3=color.surface,BorderSizePixel=0,
    Position=UDim2.new(0,0,1,-30),Size=UDim2.new(1,0,0,30)},mainWindow)
mk('Frame',{BackgroundColor3=color.line,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},footer)
footerStatus=txt(footer,'Status: Ready',10,color.green,false,
    {Position=UDim2.fromOffset(15,4),Size=UDim2.fromOffset(390,22)})
txt(footer,'VisionHub  |  V10.0',10,color.red,true,{Position=UDim2.new(1,-192,0,4),
    Size=UDim2.fromOffset(176,22),TextXAlignment=Enum.TextXAlignment.Right})
openMini=button(gui,'V   Vision Hub',UDim2.new(1,-160,.5,-18),UDim2.fromOffset(146,36),true)
openMini.Visible=false
connect(openMini.Activated,function()openMain(true)end)

-- Resizing and drag
local moving=false
local dragStart,centerStart,touchID
local function adjust()
    if gone then return end
    local cam=workspace.CurrentCamera
    local size=cam and cam.ViewportSize or Vector2.new(1280,720)
    mainScale.Scale=math.clamp(math.min(zoom,(size.X-16)/852,(size.Y-16)/525),.27,1.15)
end
adjust()
connect(header.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        moving=true;touchID=input;dragStart=input.Position
        centerStart=mainWindow.AbsolutePosition+mainWindow.AbsoluteSize/2
    end
end)
connect(UIS.InputChanged,function(input)
    if not moving then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input==touchID then
        local v=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        local hx=426*mainScale.Scale
        local hy=262.5*mainScale.Scale
        local delta=input.Position-dragStart
        mainWindow.Position=UDim2.fromOffset(
            math.clamp(centerStart.X+delta.X,math.min(hx,v.X/2),math.max(v.X-hx,v.X/2)),
            math.clamp(centerStart.Y+delta.Y,math.min(hy,v.Y/2),math.max(v.Y-hy,v.Y/2)))
    end
end)
connect(UIS.InputEnded,function(input)
    if input==touchID or (touchID and touchID.UserInputType==Enum.UserInputType.MouseButton1
        and input.UserInputType==Enum.UserInputType.MouseButton1) then moving=false;touchID=nil end
end)
connect(UIS.InputBegan,function(input,processed)
    if not processed and not UIS:GetFocusedTextBox() and input.KeyCode==Enum.KeyCode.RightShift then
        openMain(not mainWindow.Visible)
    end
end)
connect(workspace:GetPropertyChangedSignal('CurrentCamera'),adjust)

-- Read-only visual overlay, updated at low frequency
hud=txt(gui,'',11,color.white,true,{BackgroundColor3=color.bg,BackgroundTransparency=.1,
    Position=UDim2.new(1,-279,0,11),Size=UDim2.fromOffset(265,35),
    TextXAlignment=Enum.TextXAlignment.Center,Visible=false})
round(hud,7);border(hud,color.redDark,1)
connect(RunService.Heartbeat,function(dt)
    if gone then return end
    fpsFrames=fpsFrames+1
    fpsTimer=fpsTimer+dt
    drawTimer=drawTimer+dt
    if fpsTimer>=.7 then fpsValue=math.floor(fpsFrames/fpsTimer+.5);fpsFrames=0;fpsTimer=0 end
    if drawTimer>=.35 then
        drawTimer=0
        local bits={}
        if showingFPS then table.insert(bits,'FPS '..tostring(fpsValue)) end
        if showingXYZ then
            local p=playerPos()
            table.insert(bits,p and string.format('XYZ %.0f / %.0f / %.0f',p.X,p.Y,p.Z) or 'XYZ ---')
        end
        if showingPlayerCount then
            table.insert(bits,'JOUEURS '..tostring(#Players:GetPlayers()))
        end
        hud.Text=table.concat(bits,'   |   ')
        hud.Visible=showingFPS or showingXYZ or showingPlayerCount
        if liveInfo['FPS'] then liveInfo['FPS'].Text=tostring(fpsValue) end
        if liveInfo['Joueurs'] then liveInfo['Joueurs'].Text=tostring(#Players:GetPlayers()) end
        if liveInfo['Santé'] then
            local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
            liveInfo['Santé'].Text=h and tostring(math.floor(h.Health)) or '—'
        end
        if liveInfo['Ping'] then
            local success,seconds=pcall(function()return player:GetNetworkPing()end)
            liveInfo['Ping'].Text=success and tostring(math.floor(seconds*1000+.5))..' ms' or '—'
        end
    end
end)

local function cleanPage()
    for _,c in ipairs(pageConns) do pcall(function()c:Disconnect()end)end
    table.clear(pageConns)
    for _,parent in ipairs({left,right}) do
        for _,child in ipairs(parent:GetChildren()) do
            if not child:IsA('UIListLayout') then child:Destroy()end
        end
    end
    records={}
    liveInfo={}
    scroll.CanvasPosition=Vector2.new()
end
local function card(parent,name,desc)
    local c=mk('Frame',{BackgroundColor3=color.card,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},parent)
    round(c,7);border(c,color.line,1)
    if name:find('Welcome',1,true) then
        mk('UIGradient',{
            Rotation=0,
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,color.card),
                ColorSequenceKeypoint.new(.72,Color3.fromRGB(31,11,19)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(61,9,24))
            })
        },c)
    end
    mk('UIPadding',{PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,11),
        PaddingTop=UDim.new(0,9),PaddingBottom=UDim.new(0,11)},c)
    mk('UIListLayout',{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,6)},c)
    txt(c,name,12,color.white,true)
    if desc then txt(c,desc,9,color.muted,false,{Size=UDim2.new(1,0,0,16)})end
    mk('Frame',{BackgroundColor3=color.line,BorderSizePixel=0,Size=UDim2.new(1,0,0,1)},c)
    local record={frame=c,name=string.lower(name..' '..(desc or '')),rows={}}
    table.insert(records,record)
    return c,record
end
local function rowBackground(parent,height)
    local b=mk('Frame',{BackgroundColor3=color.item,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,height)},parent)
    round(b,5);border(b,color.line,.75)
    return b
end
local function addRow(g,row,name)
    table.insert(g.rows,{frame=row,name=string.lower(name)})
end
local function info(parent,group,key,value)
    local b=rowBackground(parent,29)
    txt(b,key,10,color.muted,false,{Position=UDim2.fromOffset(10,3),Size=UDim2.new(.47,-12,0,22)})
    local valueText=txt(b,tostring(value),10,color.white,true,{
        Position=UDim2.new(.47,0,0,3),
        Size=UDim2.new(.53,-9,0,22),TextXAlignment=Enum.TextXAlignment.Right
    })
    if key=='FPS' or key=='Joueurs' or key=='Ping' or key=='Santé' then
        liveInfo[key]=valueText
    end
    addRow(group,b,key..' '..tostring(value))
end
local function action(parent,group,name,fn,highlight)
    local b=button(parent,name,UDim2.new(),UDim2.new(1,0,0,32),highlight)
    border(b,highlight and color.red or color.line,.7)
    connect(b.Activated,function()
        local ok,err=pcall(fn)
        if not ok then status('Erreur : '..tostring(err)) end
    end,true)
    addRow(group,b,name)
end
local function toggle(parent,group,name,description,value,callback)
    local b=rowBackground(parent,47)
    local glyph='◇'
    local low=string.lower(name)
    if low:find('fps',1,true) then glyph='◈'
    elseif low:find('coord',1,true) then glyph='⌖'
    elseif low:find('fullbright',1,true) then glyph='☼'
    elseif low:find('joueur',1,true) then glyph='♙'
    elseif low:find('anim',1,true) then glyph='✦' end
    local symbol=mk('Frame',{
        BackgroundColor3=color.redDark,BorderSizePixel=0,
        Position=UDim2.fromOffset(8,9),Size=UDim2.fromOffset(28,28)
    },b)
    round(symbol,5)
    txt(symbol,glyph,17,color.red,true,{
        Size=UDim2.fromScale(1,1),TextXAlignment=Enum.TextXAlignment.Center
    })
    txt(b,name,11,color.white,true,{Position=UDim2.fromOffset(45,5),Size=UDim2.new(1,-102,0,18)})
    txt(b,description,9,color.muted,false,{Position=UDim2.fromOffset(45,25),Size=UDim2.new(1,-102,0,14)})
    local knob=button(b,'',UDim2.new(1,-45,.5,-11),UDim2.fromOffset(35,22),value)
    round(knob,11)
    local dot=mk('Frame',{BackgroundColor3=color.white,BorderSizePixel=0,
        Size=UDim2.fromOffset(14,14),Position=UDim2.fromOffset(value and 18 or 3,4)},knob)
    round(dot,7)
    connect(knob.Activated,function()
        value=not value
        knob.BackgroundColor3=value and color.red or color.item
        local position=UDim2.fromOffset(value and 18 or 3,4)
        if animateToggles then
            TweenService:Create(dot,TweenInfo.new(0.15),{Position=position}):Play()
        else
            dot.Position=position
        end
        callback(value)
    end,true)
    addRow(group,b,name..' '..description)
end
local function slider(parent,group,name,min,max,value,callback)
    local b=rowBackground(parent,61)
    txt(b,name,11,color.white,true,{Position=UDim2.fromOffset(10,4),Size=UDim2.new(1,-70,0,20)})
    local number=txt(b,tostring(value),11,color.red,true,{Position=UDim2.new(1,-50,0,4),
        Size=UDim2.fromOffset(40,20),TextXAlignment=Enum.TextXAlignment.Right})
    local track=mk('Frame',{BackgroundColor3=color.redDark,BorderSizePixel=0,
        Position=UDim2.fromOffset(11,39),Size=UDim2.new(1,-22,0,6)},b)
    round(track,3)
    local fill=mk('Frame',{BackgroundColor3=color.red,BorderSizePixel=0,
        Size=UDim2.fromScale((value-min)/(max-min),1)},track)
    round(fill,3)
    local hit=button(b,'',UDim2.fromOffset(10,31),UDim2.new(1,-20,0,20))
    hit.BackgroundTransparency=1
    local draggingSlider=false
    local sliderInput
    local function update(input)
        local ratio=math.clamp((input.Position.X-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        local nextValue=math.floor(min+(max-min)*ratio+.5)
        if nextValue~=value then
            value=nextValue
            number.Text=tostring(value)
            fill.Size=UDim2.fromScale((value-min)/(max-min),1)
            callback(value)
        end
    end
    connect(hit.InputBegan,function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            draggingSlider=true;sliderInput=i;update(i)
        end
    end,true)
    connect(UIS.InputChanged,function(i)
        if draggingSlider and sliderInput and
            ((sliderInput.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)
            or (sliderInput.UserInputType==Enum.UserInputType.Touch and sliderInput==i)) then update(i)end
    end,true)
    connect(UIS.InputEnded,function(i)
        if i==sliderInput or (sliderInput and sliderInput.UserInputType==Enum.UserInputType.MouseButton1
            and i.UserInputType==Enum.UserInputType.MouseButton1) then draggingSlider=false;sliderInput=nil end
    end,true)
    addRow(group,b,name)
end
local function filter()
    local query=string.lower(search.Text):match('^%s*(.-)%s*$')
    for _,g in ipairs(records) do
        local cardMatched=query=='' or string.find(g.name,query,1,true)~=nil
        local found=false
        for _,r in ipairs(g.rows) do
            local yes=cardMatched or string.find(r.name,query,1,true)~=nil
            r.frame.Visible=yes
            if yes then found=true end
        end
        g.frame.Visible=cardMatched or found
    end
end
connect(search:GetPropertyChangedSignal('Text'),filter)
local function updateCanvas()
    task.defer(function()
        if not gone and scroll.Parent then
            scroll.CanvasSize=UDim2.fromOffset(0,math.max(left.AbsoluteSize.Y,right.AbsoluteSize.Y)+20)
        end
    end)
end
connect(leftLayout:GetPropertyChangedSignal('AbsoluteContentSize'),updateCanvas)
connect(rightLayout:GetPropertyChangedSignal('AbsoluteContentSize'),updateCanvas)

local function copied(str,titleValue)
    status(pasteValue(str) and titleValue..' copié' or titleValue..' : '..str)
end
local function showXYZ()
    local p=playerPos()
    if not p then status('Personnage indisponible');return end
    copied(string.format('%.1f, %.1f, %.1f',p.X,p.Y,p.Z),'Coordonnées')
end

render=function()
    cleanPage()
    local a,b,g,h
    if activePage=='Main' then
        a,g=card(left,'Welcome to VisionHub','Hub universel - édition Vision')
        txt(a,'Made with ♥ by Vision',10,color.red,true)
        a,g=card(left,'▦  Main Features','Options fonctionnelles en direct')
        toggle(a,g,'Afficher les FPS','Compteur de performances',showingFPS,function(v)showingFPS=v end)
        toggle(a,g,'Afficher les coordonnées','Position du personnage',showingXYZ,function(v)showingXYZ=v end)
        toggle(a,g,'Fullbright','Éclairage clair en local',showFullbright,applyFullbright)
        toggle(a,g,'Nombre de joueurs','Indicateur en direct',showingPlayerCount,function(v)showingPlayerCount=v end)
        toggle(a,g,'Animations UI','Transitions des interrupteurs',animateToggles,function(v)animateToggles=v end)
        b,h=card(right,'♙  Player Info','Session Roblox')
        info(b,h,'Joueur',player.DisplayName)
        info(b,h,'User ID',player.UserId)
        info(b,h,'Place ID',game.PlaceId)
        info(b,h,'Joueurs',#Players:GetPlayers())
        info(b,h,'FPS',fpsValue)
        local pingOk,ping=pcall(function()return player:GetNetworkPing()end)
        info(b,h,'Ping',pingOk and math.floor(ping*1000+.5)..' ms' or '—')
        local playerHumanoid=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
        info(b,h,'Santé',playerHumanoid and math.floor(playerHumanoid.Health) or '—')
        local playerPhoto=mk('ImageLabel',{
            BackgroundTransparency=1,
            Image='rbxthumb://type=AvatarHeadShot&id='..tostring(player.UserId)..'&w=150&h=150',
            Size=UDim2.fromOffset(38,38),
            Position=UDim2.new(1,-45,0,3),
            ScaleType=Enum.ScaleType.Crop
        },b)
        round(playerPhoto,19);border(playerPhoto,color.redDark,.9)
        b,h=card(right,'◇  Quick Actions','Raccourcis')
        action(b,h,'Copier Place ID',function()copied(tostring(game.PlaceId),'Place ID')end,true)
        action(b,h,'Copier mes coordonnées',showXYZ)
        action(b,h,'Recentrer le hub',function()mainWindow.Position=UDim2.fromScale(.5,.5);status('Fenêtre centrée')end)
        action(b,h,'Afficher les paramètres',function()changePage('Settings')end)
    elseif activePage=='Scripts' then
        a,g=card(left,'▦  Scripts','Organisation des modules')
        info(a,g,'Jeu',game.Name)
        info(a,g,'Place ID',game.PlaceId)
        info(a,g,'Module actif','Interface V10')
        action(a,g,'Copier Place ID',function()copied(tostring(game.PlaceId),'Place ID')end,true)
        b,h=card(right,'Modules','État')
        info(b,h,'Interface','Chargée')
        info(b,h,'Externe','Non installé')
    elseif activePage=='Auto Farm' then
        a,g=card(left,'⚡  Auto Farm','Aucun module par jeu installé')
        info(a,g,'Jeu',game.Name)
        info(a,g,'Place ID',game.PlaceId)
        info(a,g,'Automatisation','Non configurée')
        b,h=card(right,'Information','Fonctions du jeu')
        txt(b,'Un module adapté à chaque jeu est nécessaire pour automatiser ses tâches.',10,color.muted,false,
            {Size=UDim2.new(1,0,0,61),TextWrapped=true})
    elseif activePage=='Teleport' then
        a,g=card(left,'◇  Position','Informations locales réelles')
        toggle(a,g,'Coordonnées','Afficher XYZ en continu',showingXYZ,function(v)showingXYZ=v end)
        action(a,g,'Copier mes coordonnées',showXYZ,true)
        action(a,g,'Enregistrer ma position',function()
            local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
            if root then
                savedPosition=root.CFrame
                status('Position enregistree')
            else status('Personnage indisponible') end
        end,true)
        action(a,g,'Revenir a ma position',function()
            if not savedPosition or not player.Character then
                status('Enregistre dabord ta position');return
            end
            local ok=pcall(function()player.Character:PivotTo(savedPosition)end)
            status(ok and 'Deplacement local demande' or 'Deplacement impossible')
        end)
        b,h=card(right,'Positions','Utilitaires locaux')
        info(b,h,'Teleports par jeu','Modules a creer')
        txt(b,'Le serveur Roblox peut annuler un deplacement local.',
            10,color.muted,false,{TextWrapped=true,Size=UDim2.new(1,0,0,43)})
    elseif activePage=='Player' then
        a,g=card(left,'♙  Player','Personnage et caméra')
        info(a,g,'Nom',player.DisplayName)
        info(a,g,'Username',player.Name)
        info(a,g,'User ID',player.UserId)
        slider(a,g,'Camera FOV',50,110,currentFOV,function(v)
            currentFOV=v
            local cam=workspace.CurrentCamera
            if cam then
                if not originalFOV then originalFOV=cam.FieldOfView end
                cam.FieldOfView=v
            end
        end)
        b,h=card(right,'Affichage','Statistiques')
        toggle(b,h,'Afficher FPS','Performances locales',showingFPS,function(v)showingFPS=v end)
        action(b,h,'Copier User ID',function()copied(tostring(player.UserId),'User ID')end)
    elseif activePage=='Misc' then
        a,g=card(left,'☷  Misc & Visuals','Affichage en jeu')
        toggle(a,g,'Compteur FPS','Indicateur de performance',showingFPS,function(v)showingFPS=v end)
        toggle(a,g,'Coordonnées XYZ','Position du joueur',showingXYZ,function(v)showingXYZ=v end)
        toggle(a,g,'Fullbright','Éclairage clair du client',showFullbright,applyFullbright)
        toggle(a,g,'Compteur de joueurs','Affichage live',showingPlayerCount,function(v)showingPlayerCount=v end)
        slider(a,g,'Camera FOV',50,110,currentFOV,function(v)
            currentFOV=v
            local cam=workspace.CurrentCamera
            if cam then
                if not originalFOV then originalFOV=cam.FieldOfView end
                cam.FieldOfView=v
            end
        end)
        b,h=card(right,'Informations','Mesures')
        info(b,h,'FPS actuel',fpsValue)
        action(b,h,'FOV par défaut (70)',function()
            currentFOV=70
            if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView=70 end
            status('FOV restauré : 70')
        end)
    elseif activePage=='Settings' then
        a,g=card(left,'⚙  Settings','Réglages de l’interface')
        toggle(a,g,'Animations','Transitions des interrupteurs',animateToggles,function(v)animateToggles=v end)
        slider(a,g,'UI Scale (%)',65,110,math.floor(zoom*100),function(v)
            zoom=v/100;adjust()
        end)
        action(a,g,'Recentrer la fenêtre',function()
            mainWindow.Position=UDim2.fromScale(.5,.5)
            status('Fenêtre recentrée')
        end,true)
        b,h=card(right,'Window','Commandes')
        info(b,h,'Raccourci','RightShift')
        action(b,h,'Masquer Vision Hub',function()openMain(false)end)
        action(b,h,'Fermer Vision Hub',stop)
    elseif activePage=='Credits' then
        a,g=card(left,'☆  À propos','Vision Hub V10')
        info(a,g,'Interface','Vision Hub')
        info(a,g,'Style du Key System','HoHo-inspired')
        info(a,g,'Style du menu','Rayz-inspired')
        b,h=card(right,'À savoir','Statut des fonctions')
        txt(b,'Navigation, recherche et affichages locaux fonctionnent. Farm/TP dépendent du jeu et ne sont pas inclus.',10,color.muted,false,
            {TextWrapped=true,Size=UDim2.new(1,0,0,72)})
    end
    filter();updateCanvas()
end
local menu={{'Main','⌂'},{'Auto Farm','⚡'},{'Scripts','▦'},{'Teleport','◇'},
    {'Player','♙'},{'Misc','☷'},{'Settings','⚙'},{'Credits','☆'}}
navButtons={}
changePage=function(target)
    activePage=target
    title.Text=target
    subtitle.Text='VISION HUB  |  '..string.upper(game.Name)
    search.Text=''
    for name,b in pairs(navButtons) do
        local on=name==target
        b.BackgroundColor3=on and color.redDark or color.surface
        b.TextColor3=on and color.white or color.muted
        local stripe=b:FindFirstChild('Selected')
        if stripe then stripe.BackgroundColor3=on and color.red or color.surface end
    end
    render()
end
for i,v in ipairs(menu) do
    local name=v[1]
    local b=button(nav,'  '..v[2]..'    '..name,UDim2.new(),UDim2.new(1,0,0,29))
    b.LayoutOrder=i;b.Font=Enum.Font.GothamMedium
    b.TextXAlignment=Enum.TextXAlignment.Left
    b.BackgroundColor3=color.surface;b.TextColor3=color.muted
    local stripe=mk('Frame',{Name='Selected',BackgroundColor3=color.surface,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,4),Size=UDim2.fromOffset(3,24)},b)
    round(stripe,2)
    navButtons[name]=b
    connect(b.Activated,function()changePage(name)end)
end
changePage('Main')

-- KEY WINDOW - aligns with actual HoHo screenshot hierarchy
keyOverlay=mk('Frame',{Name='KeyOverlay',BackgroundColor3=Color3.new(0,0,0),
    BackgroundTransparency=.43,BorderSizePixel=0,Size=UDim2.fromScale(1,1)},gui)
local key=mk('Frame',{Name='KeyWindow',BackgroundColor3=Color3.fromRGB(29,25,29),
    BorderSizePixel=0,Size=UDim2.fromOffset(334,287),AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.fromScale(.5,.5)},keyOverlay)
round(key,14);border(key,color.redDark,1.3)
mk('Frame',{BackgroundColor3=color.red,BorderSizePixel=0,
    Position=UDim2.fromOffset(83,2),Size=UDim2.fromOffset(170,2)},key)
mk('UIGradient',{
    Rotation=90,
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(36,32,36)),
        ColorSequenceKeypoint.new(.58,Color3.fromRGB(28,23,28)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(23,17,23))
    })
},key)
local keyScale=mk('UIScale',{Scale=1},key)
local topAccent=mk('Frame',{
    BackgroundColor3=color.red,BackgroundTransparency=.82,BorderSizePixel=0,
    Position=UDim2.fromOffset(76,17),Size=UDim2.fromOffset(181,29)
},key)
round(topAccent,14)
txt(key,'VISION',26,color.white,true,{
    Position=UDim2.fromOffset(82,11),Size=UDim2.fromOffset(119,40),
    TextXAlignment=Enum.TextXAlignment.Right
})
local hubName=txt(key,'HUB',26,color.red,true,{
    Position=UDim2.fromOffset(203,11),Size=UDim2.fromOffset(76,40)
})
hubName.TextStrokeColor3=Color3.fromRGB(105,14,29)
hubName.TextStrokeTransparency=.55
local inputBar=mk('Frame',{BackgroundColor3=color.bg,BorderSizePixel=0,
    Position=UDim2.fromOffset(23,60),Size=UDim2.fromOffset(288,32)},key)
round(inputBar,5);border(inputBar,color.line,1)
txt(inputBar,'ENTER KEY HERE',10,color.white,true,{Position=UDim2.fromOffset(9,4),
    Size=UDim2.fromOffset(139,24)})
local keyInput=mk('TextBox',{BackgroundColor3=color.item,BorderSizePixel=0,
    Position=UDim2.fromOffset(155,3),Size=UDim2.fromOffset(127,26),
    ClearTextOnFocus=false,Text='',PlaceholderText='••••••',
    TextColor3=color.white,PlaceholderColor3=color.muted,TextSize=11,
    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center},inputBar)
round(keyInput,4);border(keyInput,color.redDark,.8)
local getKey=button(key,'GET KEY',UDim2.fromOffset(23,101),UDim2.fromOffset(142,29),true)
local how=button(key,'How To Get Key',UDim2.fromOffset(171,101),UDim2.fromOffset(140,29),true)
local submit=button(key,'SUBMIT KEY',UDim2.fromOffset(23,137),UDim2.fromOffset(288,29),true)
for _,redButton in ipairs({getKey,how,submit}) do
    mk('UIGradient',{Color=ColorSequence.new(
        Color3.fromRGB(237,26,57),Color3.fromRGB(169,10,34)
    ),Rotation=90},redButton)
end
local keyAvatar=mk('Frame',{BackgroundColor3=color.redDark,BorderSizePixel=0,
    Position=UDim2.fromOffset(23,173),Size=UDim2.fromOffset(70,75)},key)
round(keyAvatar,6)
border(keyAvatar,color.redDark,1)
local userAvatar=mk('ImageLabel',{
    BackgroundTransparency=1,
    Image='rbxthumb://type=AvatarHeadShot&id='..tostring(player.UserId)..'&w=150&h=150',
    Size=UDim2.fromScale(1,1),ScaleType=Enum.ScaleType.Crop
},keyAvatar)
round(userAvatar,6)
txt(key,'VISION HUB  |  COMMUNAUTÉ',10,color.white,true,{Position=UDim2.fromOffset(103,174),
    Size=UDim2.fromOffset(207,17)})
local support=button(key,'SUPPORT US',UDim2.fromOffset(103,194),UDim2.fromOffset(208,24))
local dismiss=button(key,'CLOSE UI',UDim2.fromOffset(103,223),UDim2.fromOffset(208,24))
border(support,color.redDark,1);border(dismiss,color.redDark,1)
local keyStatus=txt(key,'●  En attente de clé...',10,color.muted,false,
    {Position=UDim2.fromOffset(23,256),Size=UDim2.fromOffset(288,20),
    TextXAlignment=Enum.TextXAlignment.Center})
local function keyMessage(message,problem)
    keyStatus.Text='●  '..message
    keyStatus.TextColor3=problem and color.red or color.muted
end
local function verifyKey()
    if gone or keyBusy then return end
    local value=(keyInput.Text or ''):match('^%s*(.-)%s*$'):upper()
    if value=='' then return keyMessage('Entre une cle.',true) end
    local ok,message
    keyBusy=true
    submit.Text='VERIFYING...'
    if value==KEY then
        ok,message=true,'Mode test : Vision Hub V10'
    else
        keyMessage('Verification serveur...',false)
        ok,message=verifyRemoteKey(value)
    end
    keyBusy=false
    if gone then return end
    submit.Text='SUBMIT KEY'
    if ok then
        unlocked=true
        keyOverlay:Destroy()
        openMain(true)
        status(message)
    else
        keyMessage(message,true)
    end
end
connect(submit.Activated,verifyKey)
connect(keyInput.FocusLost,function(enter)if enter then verifyKey()end end)
connect(getKey.Activated,function()
    if serverConfigured() then
        local url=KEY_SERVICE_BASE:gsub('/+$','')..'/key'
        local ok=pasteValue(url)
        keyMessage(ok and 'Lien du generateur copie : ouvre ton navigateur.'
            or 'Ouvre la page /key de ton Worker.',not ok)
    else
        keyInput.Text=KEY
        keyMessage('Mode TEST. Deploie Cloudflare pour des vraies cles.',false)
    end
end)
connect(how.Activated,function()
    keyMessage(serverConfigured() and 'GET KEY > navigateur > copie > SUBMIT.'
        or 'TEST : GET KEY > SUBMIT KEY.',false)
end)
connect(support.Activated,function()
    local url='https://github.com/Azerty56123/vision-pro'
    local result=pasteValue(url)
    keyMessage(result and 'Lien du support copié.' or 'Support : GitHub Vision Pro',false)
end)
connect(dismiss.Activated,stop)
local function resizeKey()
    if not keyOverlay.Parent then return end
    local cam=workspace.CurrentCamera
    local size=cam and cam.ViewportSize or Vector2.new(1280,720)
    keyScale.Scale=math.clamp(math.min(1,(size.X-18)/334,(size.Y-18)/287),.32,1)
end
resizeKey()
local keyCameraConn
local function attachViewport()
    if keyCameraConn then keyCameraConn:Disconnect()end
    local cam=workspace.CurrentCamera
    if cam then keyCameraConn=connect(cam:GetPropertyChangedSignal('ViewportSize'),function()
        resizeKey();adjust()
    end)end
    resizeKey();adjust()
end
connect(workspace:GetPropertyChangedSignal('CurrentCamera'),attachViewport)
attachViewport()