--[[
    VISION HUB V6 — INTERFACE + ACCÈS PAR CLÉ (PC + MOBILE)

    Copie ce script dans un exécuteur Luau qui prend en charge les
    API client Roblox ordinaires, puis exécute-le dans un jeu.
    Pas besoin de Roblox Studio. La vérification de clé nécessite un service HTTPS configuré et une fonction POST compatible.

    - Interface RayzHub-inspired, sombre et rouge
    - Accès par clé de type HoHo Hub, relié à l’API Cloudflare du projet
    - 7 pages, recherche, toggles, sliders, sélecteurs
    - Barre de navigation compacte sur mobile, navigation latérale sur PC
    - RightShift sur clavier / bouton V pour masquer et réafficher
    - Le bouton X ferme et nettoie le hub ; le bouton — le masque
    - Relancer le script retire l'ancien menu, sans le dupliquer
    - Les options Farm/TP/Joueur sont des DEMOS D'INTERFACE :
      aucun jeu n'est modifié par défaut.

    Aucune compatibilité universelle ne peut être garantie : selon les mises
    à jour de Roblox et les capacités de l'exécuteur, l'UI peut ne pas s'afficher.
    Ce script ne désactive ni ne contourne les mécanismes de sécurité.
]]


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    warn("Vision Hub : lance le script dans un client Roblox ayant rejoint un jeu.")
    return
end

-- PlayerGui est l'emplacement standard d'un ScreenGui côté client.
-- L'UI n'utilise ni gethui, ni getgenv, ni requêtes externes.
local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 12)
if not playerGui then
    warn("Vision Hub : PlayerGui indisponible, impossible d'afficher l'interface.")
    return
end

local UI_NAME = "VisionHub_Universal_V6"
-- À REMPLACER par l’URL de TON Worker Cloudflare, sans chemin final.
local KEY_API_BASE = "https://vision-pro-beta-v4.YOUR-SUBDOMAIN.workers.dev"
for _, name in ipairs({UI_NAME, "VisionHub_Universal_V5", "VisionHub_Universal_V4", "VisionHub_JJSploit_V3", "VisionHubExecutorV2", "VisionHubV1"}) do
    local previous = playerGui:FindFirstChild(name)
    if previous then previous:Destroy() end
end

-- Nom d'exécuteur purement informatif : optionnel et sans dépendance.
local function executorLabel()
    local getter = identifyexecutor or getexecutorname
    if type(getter) == "function" then
        local ok, name = pcall(getter)
        if ok and type(name) == "string" and #name > 0 then
            return name:sub(1, 36)
        end
    end
    return "Environnement standard"
end
local runtimeName = executorLabel()

local liveConnections = {}
local pageConnections = {}
local stopped = false
local gui
local function bind(signal, callback, forPage)
    local c = signal:Connect(callback)
    table.insert(forPage and pageConnections or liveConnections, c)
    return c
end
local function stop()
    if stopped then return end
    stopped = true
    for _, connection in ipairs(pageConnections) do pcall(function() connection:Disconnect() end) end
    for _, connection in ipairs(liveConnections) do pcall(function() connection:Disconnect() end) end
    if gui then pcall(function() gui:Destroy() end) end
end

local C = {
    background = Color3.fromRGB(11, 12, 15),
    surface = Color3.fromRGB(18, 19, 23),
    card = Color3.fromRGB(23, 24, 29),
    input = Color3.fromRGB(29, 30, 36),
    border = Color3.fromRGB(47, 48, 56),
    red = Color3.fromRGB(205, 39, 54),
    redDark = Color3.fromRGB(66, 23, 30),
    white = Color3.fromRGB(241, 242, 245),
    muted = Color3.fromRGB(145, 148, 159),
    green = Color3.fromRGB(70, 204, 122),
}

local state = {}
local currentPage = "Accueil"
local visibleRows = {}
local sections = {}
local cardIndex = {}
local navButtons = {}
local unlocked = false
local showNotifications = true
local animations = true
local uiZoom = 1

-- Ajoute ici des fonctions développées pour TES propres jeux.
-- Exemple : actions["Farm.Auto"] = function(enabled) ... end
-- Sans fonction associée, les éléments du hub sont des contrôles d'interface.
local ACTIONS = {}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function corner(parent, pixels)
    return make("UICorner", {CornerRadius = UDim.new(0, pixels)}, parent)
end

local function stroke(parent, color, thickness)
    return make("UIStroke", {Color = color or C.border, Thickness = thickness or 1}, parent)
end

local function padding(parent, l, r, t, b)
    return make("UIPadding", {
        PaddingLeft = UDim.new(0, l), PaddingRight = UDim.new(0, r),
        PaddingTop = UDim.new(0, t), PaddingBottom = UDim.new(0, b),
    }, parent)
end

local function stack(parent, gap, horizontal)
    return make("UIListLayout", {
        FillDirection = horizontal and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, gap),
    }, parent)
end

local function label(parent, text, size, color, bold, props)
    local p = {
        BackgroundTransparency = 1, Text = text, TextColor3 = color or C.white,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize = size or 13, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Size = UDim2.new(1, 0, 0, 22),
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return make("TextLabel", p, parent)
end

local function button(parent, text, position, size, color)
    local b = make("TextButton", {
        Name = text, AutoButtonColor = false, BackgroundColor3 = color or C.input,
        BorderSizePixel = 0, Text = text, TextColor3 = C.white,
        TextSize = 12, Font = Enum.Font.GothamMedium,
        Position = position or UDim2.new(),
        Size = size or UDim2.new(0, 100, 0, 32),
    }, parent)
    corner(b, 6)
    return b
end

gui = make("ScreenGui", {
    Name = UI_NAME, ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = false,
    DisplayOrder = 100,
}, playerGui)
-- Si le script est relancé, Destroy() sur l'ancienne fenêtre déconnecte
-- également les événements globaux de cette exécution.
bind(gui.Destroying, function() stop() end)

local window = make("Frame", {
    Name = "Window", BackgroundColor3 = C.background, BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(880, 550), ClipsDescendants = true, Visible = false,
}, gui)
corner(window, 9)
stroke(window, C.border)
local scale = make("UIScale", {Scale = 1}, window)

-- Mise en page responsive initialisée après la construction des widgets.

local top = make("Frame", {
    Name = "Topbar", BackgroundColor3 = C.surface, BorderSizePixel = 0,
    Active = true, Size = UDim2.new(1, 0, 0, 53),
}, window)
make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1)}, top)
label(top, "V", 26, C.red, true, {Position = UDim2.fromOffset(19, 8), Size = UDim2.fromOffset(30, 36)})
label(top, "VISION", 15, C.white, true, {Position = UDim2.fromOffset(53, 8), Size = UDim2.fromOffset(72, 22)})
label(top, "HUB", 15, C.red, true, {Position = UDim2.fromOffset(126, 8), Size = UDim2.fromOffset(42, 22)})
label(top, "v6.0  |  Multi-exécuteurs", 10, C.muted, false,
    {Position = UDim2.fromOffset(53, 28), Size = UDim2.fromOffset(180, 15)})

local hideButton = button(top, "—", UDim2.new(1, -86, 0, 11), UDim2.fromOffset(31, 30), C.surface)
local closeButton = button(top, "×", UDim2.new(1, -45, 0, 11), UDim2.fromOffset(31, 30), C.surface)
closeButton.TextSize = 18
local dot = make("Frame", {BackgroundColor3 = C.green, BorderSizePixel = 0,
    Position = UDim2.new(1, -235, 0, 23), Size = UDim2.fromOffset(7, 7)}, top)
corner(dot, 10)
local topStatus = label(top, "Interface prête", 11, C.muted, false,
    {Position = UDim2.new(1, -221, 0, 14), Size = UDim2.fromOffset(120, 25)})

local side = make("Frame", {
    Name = "Sidebar", BackgroundColor3 = C.surface, BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 53), Size = UDim2.new(0, 184, 1, -83),
}, window)
make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0,
    Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0)}, side)
local navHeading = label(side, "NAVIGATION", 10, C.muted, true,
    {Position = UDim2.fromOffset(18, 16), Size = UDim2.fromOffset(145, 17)})

local navScroll = make("ScrollingFrame", {
    Name = "Navigation", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 46), Size = UDim2.new(1, -24, 1, -56),
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 0,
}, side)
local navLayout = stack(navScroll, 5)

local content = make("Frame", {
    Name = "Content", BackgroundTransparency = 1,
    Position = UDim2.fromOffset(184, 53), Size = UDim2.new(1, -184, 1, -83),
}, window)
local title = label(content, "Accueil", 20, C.white, true,
    {Position = UDim2.fromOffset(22, 13), Size = UDim2.new(0.55, 0, 0, 27)})
local subtitle = label(content, "Tableau de bord", 11, C.muted, false,
    {Position = UDim2.fromOffset(22, 42), Size = UDim2.new(0.55, 0, 0, 16)})

local search = make("TextBox", {
    BackgroundColor3 = C.input, BorderSizePixel = 0,
    Position = UDim2.new(1, -216, 0, 18), Size = UDim2.fromOffset(192, 31),
    ClearTextOnFocus = false, PlaceholderText = "Rechercher...",
    Text = "", TextColor3 = C.white, PlaceholderColor3 = C.muted,
    TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
}, content)
corner(search, 6)
stroke(search, C.border)
padding(search, 11, 7, 0, 0)

local scroll = make("ScrollingFrame", {
    Name = "Page", BackgroundTransparency = 1, BorderSizePixel = 0,
    Position = UDim2.fromOffset(20, 74), Size = UDim2.new(1, -32, 1, -83),
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarThickness = 3, ScrollBarImageColor3 = C.red,
}, content)
local horizontal = stack(scroll, 12, true)
local emptyResults = label(content, "Aucun réglage trouvé sur cette page.", 12, C.muted, false, {
    Position = UDim2.fromOffset(24, 110), Size = UDim2.new(1, -48, 0, 24),
    Visible = false,
})

local footer = make("Frame", {
    BackgroundColor3 = C.surface, BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -30), Size = UDim2.new(1, 0, 0, 30),
}, window)
make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1)}, footer)
local statusText = label(footer, "●  Vision Hub prêt • UI universelle", 10, C.green, false,
    {Position = UDim2.fromOffset(14, 4), Size = UDim2.new(0.65, -14, 0, 22)})
local footerHelp = label(footer, "RightShift / bouton V : afficher", 10, C.muted, false,
    {Position = UDim2.new(1, -245, 0, 4), Size = UDim2.fromOffset(233, 22),
    TextXAlignment = Enum.TextXAlignment.Right})

local reopen = button(gui, "V  Ouvrir Vision Hub", UDim2.new(1, -188, 0.5, -18),
    UDim2.fromOffset(178, 36), C.red)
reopen.Visible = false

local function showWindow(value)
    if stopped or not unlocked then return end
    window.Visible = value
    reopen.Visible = not value
end
bind(hideButton.Activated, function() showWindow(false) end)
bind(closeButton.Activated, function() stop() end)
bind(reopen.Activated, function() showWindow(true) end)

bind(UserInputService.InputBegan, function(input, processed)
    if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == Enum.KeyCode.RightShift then
        showWindow(not window.Visible)
    end
end)

-- La fenêtre ne sort pas entièrement de l'écran, même sur mobile.
local function clampWindowToScreen(x, y)
    local cam = workspace.CurrentCamera
    local view = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local halfW = (window.Size.X.Offset * scale.Scale) / 2
    local halfH = (window.Size.Y.Offset * scale.Scale) / 2
    local minX, minY = halfW + 5, halfH + 5
    x = math.clamp(x, math.min(minX, view.X / 2), math.max(view.X - minX, view.X / 2))
    y = math.clamp(y, math.min(minY, view.Y / 2), math.max(view.Y - minY, view.Y / 2))
    window.Position = UDim2.fromOffset(x, y)
end

-- Glisser-déposer souris / tactile, sans accumuler de connexions.
local dragging = false
local dragStart, windowStart, dragInput
bind(top.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        windowStart = window.AbsolutePosition + window.AbsoluteSize / 2
        dragInput = input
    end
end)
bind(UserInputService.InputChanged, function(input)
    if not dragging then return end
    local touching = dragInput and dragInput.UserInputType == Enum.UserInputType.Touch
    if (touching and input == dragInput) or
        (not touching and input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        clampWindowToScreen(windowStart.X + delta.X, windowStart.Y + delta.Y)
    end
end)
bind(UserInputService.InputEnded, function(input)
    if input == dragInput or (dragInput and
        dragInput.UserInputType == Enum.UserInputType.MouseButton1 and
        input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging = false
        dragInput = nil
    end
end)

local function feedback(message)
    if not showNotifications then return end
    statusText.Text = "●  " .. message
end

local function emit(key, value)
    if state[key] == value then return end
    state[key] = value
    if ACTIONS[key] then
        local ok, err = pcall(ACTIONS[key], value)
        if not ok then warn("Vision Hub : " .. tostring(err)) end
    else
        feedback("Réglage modifié : " .. key .. " (interface uniquement)")
    end
end

local function clearPage()
    for _, connection in ipairs(pageConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(pageConnections)
    visibleRows = {}
    sections = {}
    cardIndex = {}
    for _, child in ipairs(scroll:GetChildren()) do
        if child ~= horizontal then child:Destroy() end
    end
    scroll.CanvasPosition = Vector2.new(0, 0)
    emptyResults.Visible = false
end

local isCompact = false
local function addColumn()
    local col = make("Frame", {
        BackgroundTransparency = 1,
        Size = isCompact and UDim2.new(1, -5, 0, 0) or UDim2.new(0.5, -11, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    }, scroll)
    stack(col, 12)
    return col
end

local function section(parent, heading, description)
    local card = make("Frame", {
        BackgroundColor3 = C.card, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    corner(card, 7)
    stroke(card)
    padding(card, 13, 13, 11, 13)
    stack(card, 7)
    local group = {
        ui = card,
        text = string.lower(heading .. " " .. (description or "")),
        rows = {},
    }
    table.insert(sections, group)
    cardIndex[card] = group
    label(card, heading, 13, C.white, true)
    if description then
        label(card, description, 10, C.muted, false, {Size = UDim2.new(1, 0, 0, 15)})
    end
    make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1)}, card)
    return card
end

local function track(row, text)
    local entry = {ui = row, text = string.lower(text)}
    table.insert(visibleRows, entry)
    local node = row.Parent
    while node and node ~= scroll do
        if cardIndex[node] then
            table.insert(cardIndex[node].rows, entry)
            break
        end
        node = node.Parent
    end
end

local function controlRow(parent, name, description)
    local row = make("Frame", {BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, description and 52 or 40)}, parent)
    label(row, name, 12, C.white, false,
        {Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, -64, 0, 22)})
    if description then
        label(row, description, 10, C.muted, false,
            {Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, -58, 0, 17)})
    end
    track(row, name .. " " .. (description or ""))
    return row
end

local function addToggle(parent, name, desc, key, initial)
    local row = controlRow(parent, name, desc)
    local on = state[key]
    if on == nil then on = initial or false; state[key] = on end
    local switch = button(row, "", UDim2.new(1, -42, 0.5, -11), UDim2.fromOffset(42, 22), on and C.red or C.input)
    local switchCorner = switch:FindFirstChildOfClass("UICorner")
    if switchCorner then switchCorner.CornerRadius = UDim.new(0, 12) end
    local knob = make("Frame", {BackgroundColor3 = C.white, BorderSizePixel = 0,
        Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(on and 23 or 3, 3)}, switch)
    corner(knob, 20)
    local function refresh()
        local targetColor = on and C.red or C.input
        local targetPos = UDim2.fromOffset(on and 23 or 3, 3)
        if animations then
            local ok = pcall(function()
                TweenService:Create(switch, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(knob, TweenInfo.new(0.15), {Position = targetPos}):Play()
            end)
            if ok then return end
        end
        switch.BackgroundColor3 = targetColor
        knob.Position = targetPos
    end
    switch.Activated:Connect(function()
        on = not on
        emit(key, on)
        refresh()
    end)
    return row
end

local function addSlider(parent, name, key, minValue, maxValue, defaultValue)
    local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58)}, parent)
    track(row, name)
    local value = state[key] or defaultValue
    state[key] = value
    label(row, name, 12, C.white, false,
        {Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, -45, 0, 22)})
    local val = label(row, tostring(value), 11, C.red, true,
        {Position = UDim2.new(1, -48, 0, 0), Size = UDim2.fromOffset(48, 22),
        TextXAlignment = Enum.TextXAlignment.Right})
    local bar = make("Frame", {BackgroundColor3 = C.input, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 34), Size = UDim2.new(1, 0, 0, 6)}, row)
    corner(bar, 5)
    local fill = make("Frame", {BackgroundColor3 = C.red, BorderSizePixel = 0,
        Size = UDim2.fromScale((value - minValue) / (maxValue - minValue), 1)}, bar)
    corner(fill, 5)
    local hit = button(row, "", UDim2.new(0, 0, 0, 25), UDim2.new(1, 0, 0, 23), C.input)
    hit.BackgroundTransparency = 1
    local isSliding = false
    local sliderInput
    local function update(input)
        local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        value = math.floor(minValue + (maxValue - minValue) * ratio + 0.5)
        val.Text = tostring(value)
        fill.Size = UDim2.fromScale((value - minValue) / (maxValue - minValue), 1)
        emit(key, value)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            sliderInput = input
            update(input)
        end
    end)
    bind(UserInputService.InputChanged, function(input)
        if isSliding and sliderInput and
            ((sliderInput.UserInputType == Enum.UserInputType.Touch and input == sliderInput)
            or (sliderInput.UserInputType == Enum.UserInputType.MouseButton1 and
                input.UserInputType == Enum.UserInputType.MouseMovement)) then
            update(input)
        end
    end, true)
    bind(UserInputService.InputEnded, function(input)
        if input == sliderInput or (sliderInput and
            sliderInput.UserInputType == Enum.UserInputType.MouseButton1 and
            input.UserInputType == Enum.UserInputType.MouseButton1) then
            isSliding = false
            sliderInput = nil
        end
    end, true)
    return row
end

local function addDropdown(parent, name, key, choices)
    local row = controlRow(parent, name, nil)
    local index = table.find(choices, state[key]) or 1
    state[key] = choices[index]
    local b = button(row, choices[index] .. "  ▾", UDim2.new(1, -154, 0, 5), UDim2.fromOffset(154, 30))
    b.TextSize = 11
    local opened = false
    local list = make("Frame", {
        BackgroundColor3 = C.input, BorderSizePixel = 0, Visible = false,
        Position = UDim2.new(1, -154, 0, 39), Size = UDim2.fromOffset(154, #choices * 30 + 6),
    }, row)
    corner(list, 6)
    stroke(list, C.border)
    padding(list, 3, 3, 3, 3)
    stack(list, 0)
    for _, choice in ipairs(choices) do
        local item = button(list, choice, UDim2.new(), UDim2.new(1, 0, 0, 30), C.input)
        item.TextSize = 11
        item.Activated:Connect(function()
            index = table.find(choices, choice) or 1
            b.Text = choices[index] .. "  ▾"
            emit(key, choices[index])
            opened = false
            list.Visible = false
            row.Size = UDim2.new(1, 0, 0, 40)
        end)
    end
    b.Activated:Connect(function()
        opened = not opened
        list.Visible = opened
        row.Size = UDim2.new(1, 0, 0, opened and (47 + #choices * 30) or 40)
    end)
    return row
end

local function addAction(parent, text, callback, red)
    local b = button(parent, text, UDim2.new(), UDim2.new(1, 0, 0, 34), red and C.red or C.input)
    b.Activated:Connect(callback)
    track(b, text)
    return b
end

local pages = {
    {name = "Accueil", icon = "⌂", info = "Vue générale et informations"},
    {name = "Scripts", icon = "▤", info = "Modules par jeu et organisation"},
    {name = "Farm", icon = "▣", info = "Gestion des tâches • Démo"},
    {name = "Téléportation", icon = "◇", info = "Points de déplacement • Démo"},
    {name = "Joueur", icon = "♙", info = "Paramètres du joueur • Démo"},
    {name = "Divers", icon = "☷", info = "Outils et raccourcis"},
    {name = "Paramètres", icon = "⚙", info = "Personnalisation du hub"},
}

local renderPage
local function changePage(name)
    currentPage = name
    search.Text = ""
    title.Text = name
    for _, page in ipairs(pages) do
        if page.name == name then subtitle.Text = page.info end
        local nav = navButtons[page.name]
        if nav then
            local active = page.name == name
            nav.BackgroundColor3 = active and C.redDark or C.surface
            nav.TextColor3 = active and C.white or C.muted
        end
    end
    renderPage()
end

for _, page in ipairs(pages) do
    local nav = button(navScroll, "  " .. page.icon .. "    " .. page.name,
        UDim2.new(), UDim2.new(1, 0, 0, 38), C.surface)
    nav.TextXAlignment = Enum.TextXAlignment.Left
    nav.TextSize = 12
    navButtons[page.name] = nav
    nav.Activated:Connect(function() changePage(page.name) end)
end

-- Adaptation automatique au viewport :
-- PC = navigation latérale, 2 colonnes ; petit écran = barre d'onglets et 1 colonne.
local cameraSizeConnection
local function refreshLayout()
    if stopped or not window.Parent then return end
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local compact = viewport.X < 720
    isCompact = compact

    if compact then
        window.Size = UDim2.fromOffset(390, 640)
        scale.Scale = math.clamp(math.min(uiZoom, (viewport.X - 16) / 390,
            (viewport.Y - 16) / 640), 0.28, 1.1)
        side.Position = UDim2.fromOffset(0, 53)
        side.Size = UDim2.new(1, 0, 0, 49)
        navHeading.Visible = false
        navScroll.Position = UDim2.fromOffset(10, 5)
        navScroll.Size = UDim2.new(1, -20, 1, -10)
        navScroll.ScrollingDirection = Enum.ScrollingDirection.X
        navScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
        navLayout.FillDirection = Enum.FillDirection.Horizontal
        content.Position = UDim2.fromOffset(0, 102)
        content.Size = UDim2.new(1, 0, 1, -132)
        title.Position = UDim2.fromOffset(15, 12)
        title.Size = UDim2.fromOffset(160, 25)
        subtitle.Position = UDim2.fromOffset(15, 41)
        subtitle.Size = UDim2.fromOffset(168, 16)
        search.Position = UDim2.new(1, -169, 0, 19)
        search.Size = UDim2.fromOffset(154, 31)
        scroll.Position = UDim2.fromOffset(14, 75)
        scroll.Size = UDim2.new(1, -28, 1, -82)
        horizontal.FillDirection = Enum.FillDirection.Vertical
        dot.Visible = false
        topStatus.Visible = false
        footerHelp.Visible = false
        statusText.Size = UDim2.new(1, -18, 0, 22)
        for _, nav in pairs(navButtons) do
            nav.Size = UDim2.fromOffset(115, 36)
        end
    else
        window.Size = UDim2.fromOffset(880, 550)
        scale.Scale = math.clamp(math.min(uiZoom, (viewport.X - 30) / 880,
            (viewport.Y - 30) / 550), 0.4, 1.1)
        side.Position = UDim2.fromOffset(0, 53)
        side.Size = UDim2.new(0, 184, 1, -83)
        navHeading.Visible = true
        navScroll.Position = UDim2.fromOffset(12, 46)
        navScroll.Size = UDim2.new(1, -24, 1, -56)
        navScroll.ScrollingDirection = Enum.ScrollingDirection.Y
        navScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        navLayout.FillDirection = Enum.FillDirection.Vertical
        content.Position = UDim2.fromOffset(184, 53)
        content.Size = UDim2.new(1, -184, 1, -83)
        title.Position = UDim2.fromOffset(22, 13)
        title.Size = UDim2.new(0.55, 0, 0, 27)
        subtitle.Position = UDim2.fromOffset(22, 42)
        subtitle.Size = UDim2.new(0.55, 0, 0, 16)
        search.Position = UDim2.new(1, -216, 0, 18)
        search.Size = UDim2.fromOffset(192, 31)
        scroll.Position = UDim2.fromOffset(20, 74)
        scroll.Size = UDim2.new(1, -32, 1, -83)
        horizontal.FillDirection = Enum.FillDirection.Horizontal
        dot.Visible = true
        topStatus.Visible = true
        footerHelp.Visible = true
        statusText.Size = UDim2.new(0.65, -14, 0, 22)
        for _, nav in pairs(navButtons) do
            nav.Size = UDim2.new(1, 0, 0, 38)
        end
    end
    for _, obj in ipairs(scroll:GetChildren()) do
        if obj:IsA("Frame") then
            obj.Size = compact and UDim2.new(1, -5, 0, 0)
                or UDim2.new(0.5, -11, 0, 0)
        end
    end
    if not dragging then
        local x = (window.Position.X.Scale * viewport.X) + window.Position.X.Offset
        local y = (window.Position.Y.Scale * viewport.Y) + window.Position.Y.Offset
        clampWindowToScreen(x, y)
    end
end

local function hookCamera()
    if cameraSizeConnection then
        cameraSizeConnection:Disconnect()
        cameraSizeConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        cameraSizeConnection = bind(camera:GetPropertyChangedSignal("ViewportSize"), refreshLayout)
    end
    refreshLayout()
end
bind(workspace:GetPropertyChangedSignal("CurrentCamera"), hookCamera)
hookCamera()

local function infoLine(parent, heading, value)
    local row = controlRow(parent, heading, nil)
    label(row, value, 10, C.muted, true, {
        Position = UDim2.new(1, -145, 0, 0), Size = UDim2.fromOffset(145, 40),
        TextXAlignment = Enum.TextXAlignment.Right,
    })
end

renderPage = function()
    clearPage()
    local left, right = addColumn(), addColumn()
    if currentPage == "Accueil" then
        local a = section(left, "Bienvenue sur Vision Hub", "Une base pour tes futurs modules Luau")
        infoLine(a, "Compte", player.DisplayName)
        infoLine(a, "Place ID", tostring(game.PlaceId))
        infoLine(a, "Version", "6.0 — UI")
        infoLine(a, "Exécuteur", runtimeName)
        local b = section(right, "Navigation rapide", "Accéder aux différentes pages")
        addAction(b, "Ouvrir Scripts", function() changePage("Scripts") end, true)
        addAction(b, "Ouvrir Farm", function() changePage("Farm") end)
        addAction(b, "Ouvrir Paramètres", function() changePage("Paramètres") end)
        local c = section(left, "Modules", "Les fonctionnalités sont à connecter séparément")
        infoLine(c, "Jeu détecté", "Oui")
        infoLine(c, "Actions jeu", "À connecter")
        addAction(c, "Vérifier l'interface", function() feedback("Navigation et boutons opérationnels") end)
    elseif currentPage == "Scripts" then
        local a = section(left, "Modules du jeu", "Architecture prête pour ajouter tes scripts")
        infoLine(a, "Place ID", tostring(game.PlaceId))
        infoLine(a, "Modules actifs", "0")
        infoLine(a, "Statut", "Aucun module chargé")
        local b = section(right, "Organisation", "Séparer l'interface du code de chaque jeu")
        infoLine(b, "Interface", "Vision Hub V6")
        infoLine(b, "Chargement externe", "Désactivé")
        addAction(b, "Afficher l'identifiant", function()
            feedback("Place ID : " .. tostring(game.PlaceId))
        end, true)
        local c = section(left, "À venir", "Première étape de ton hub multijeux")
        label(c, "Les modules autorisés seront ajoutés séparément.", 11, C.muted,
            false, {Size = UDim2.new(1, 0, 0, 35), TextWrapped = true})
    elseif currentPage == "Farm" then
        local a = section(left, "Farm", "Interface des tâches")
        addToggle(a, "Module Farm (démo)", "Aucune action dans le jeu", "Farm.Auto", false)
        addToggle(a, "Tâches (démo)", "Options visuelles seulement", "Farm.Tasks", false)
        addToggle(a, "Collecte (démo)", "Options visuelles seulement", "Farm.Collect", false)
        local b = section(right, "Réglages", "Configuration du module")
        addDropdown(b, "Méthode", "Farm.Method", {"Normal", "Proche", "Par zone"})
        addSlider(b, "Distance", "Farm.Distance", 0, 100, 50)
        addSlider(b, "Pause", "Farm.Pause", 0, 30, 5)
    elseif currentPage == "Téléportation" then
        local a = section(left, "Destinations", "Points configurables pour tes jeux")
        addDropdown(a, "Zone", "Teleport.Zone", {"Lobby", "Zone 1", "Zone 2", "Zone 3"})
        addAction(a, "Choisir ce point", function()
            feedback("Point sélectionné : " .. state["Teleport.Zone"] .. " • module non connecté")
        end, true)
        local b = section(right, "Positions", "Actions à développer côté serveur")
        addAction(b, "Définir un point", function() feedback("À relier au module de ton jeu") end)
        addAction(b, "Revenir au point", function() feedback("À relier au module de ton jeu") end)
    elseif currentPage == "Joueur" then
        local a = section(left, "Joueur", "Paramètres de démonstration")
        addSlider(a, "Vitesse", "Player.Speed", 0, 100, 16)
        addSlider(a, "Saut", "Player.Jump", 0, 100, 50)
        local b = section(right, "Options", "Contrôles d'interface")
        addToggle(b, "Mode entraînement", "Non relié à un script", "Player.Training", false)
        addToggle(b, "Affichage détaillé", "Non relié à un script", "Player.Detail", true)
    elseif currentPage == "Divers" then
        local a = section(left, "Outils", "Fonctions d'interface")
        addAction(a, "Afficher la page d'accueil", function() changePage("Accueil")
reopen.Visible = false


-- ================================================================
-- ACCÈS PAR CLÉ — V6 (style compact inspiré de HoHo Hub)
-- Le serveur conserve les clés et répond via /api/verify.
-- Ne place jamais de jeton ADMIN_TOKEN dans le client !
-- ================================================================
local HttpService = game:GetService("HttpService")
local function keyServerReady()
    return type(KEY_API_BASE) == "string"
        and KEY_API_BASE:match("^https://") ~= nil
        and not KEY_API_BASE:find("YOUR-SUBDOMAIN", 1, true)
        and not KEY_API_BASE:find("TON-SOUS-DOMAINE", 1, true)
end

local function httpPoster()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
    if type(http) == "table" and type(http.request) == "function" then return http.request end
    return nil
end

local function postKeyAPI(path, payload)
    if not keyServerReady() then
        return false, "URL Cloudflare à configurer dans KEY_API_BASE."
    end
    local post = httpPoster()
    if not post then
        return false, "Requêtes HTTPS POST indisponibles dans cet environnement."
    end
    local ok, result = pcall(post, {
        Url = KEY_API_BASE:gsub("/+$", "") .. path,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json", ["Accept"] = "application/json"},
        Body = HttpService:JSONEncode(payload),
    })
    if not ok or type(result) ~= "table" then
        return false, "Connexion au serveur impossible."
    end
    local body = result.Body or result.body
    if type(body) ~= "string" then
        return false, "Réponse invalide du serveur."
    end
    local parsedOK, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not parsedOK or type(data) ~= "table" then
        return false, "Réponse non JSON du serveur."
    end
    if data.ok ~= true then
        return false, tostring(data.message or "Clé refusée.")
    end
    return true, data
end

local overlay = make("Frame", {
    Name = "KeyOverlay", BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.38, BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1), Active = true
}, gui)
local keyWindow = make("Frame", {
    Name = "KeyWindow", BackgroundColor3 = C.background, BorderSizePixel = 0,
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(466, 270), ClipsDescendants = true,
}, overlay)
corner(keyWindow, 8)
stroke(keyWindow, C.red, 1)
local keyScale = make("UIScale", {Scale = 1}, keyWindow)
local keyHeader = make("Frame", {
    BackgroundColor3 = C.surface, BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 0, 45)
}, keyWindow)
make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1)}, keyHeader)
label(keyHeader, "VISION HUB", 16, C.white, true,
    {Position = UDim2.fromOffset(18, 8), Size = UDim2.fromOffset(170, 27)})
label(keyHeader, "ACCÈS PAR CLÉ", 10, C.red, true,
    {Position = UDim2.new(1, -132, 0, 13), Size = UDim2.fromOffset(112, 18),
     TextXAlignment = Enum.TextXAlignment.Right})

label(keyWindow, "Entrez votre clé pour continuer", 14, C.white, true,
    {Position = UDim2.fromOffset(21, 58), Size = UDim2.new(1, -42, 0, 24)})
label(keyWindow, "Votre clé doit être validée par le serveur.", 11, C.muted, false,
    {Position = UDim2.fromOffset(21, 83), Size = UDim2.new(1, -42, 0, 18)})

local keyField = make("TextBox", {
    Name = "Clé", BackgroundColor3 = C.input, BorderSizePixel = 0,
    Position = UDim2.fromOffset(21, 113), Size = UDim2.new(1, -42, 0, 42),
    ClearTextOnFocus = false, Text = "", PlaceholderText = "Collez votre clé ici...",
    TextColor3 = C.white, PlaceholderColor3 = C.muted, TextSize = 12,
    Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left
}, keyWindow)
corner(keyField, 6)
stroke(keyField, C.border)
padding(keyField, 14, 11, 0, 0)

local getKeyButton = button(keyWindow, "Obtenir une clé", UDim2.fromOffset(21, 167),
    UDim2.fromOffset(151, 36), C.input)
local verifyButton = button(keyWindow, "Valider", UDim2.fromOffset(182, 167),
    UDim2.fromOffset(128, 36), C.red)
local quitButton = button(keyWindow, "Fermer", UDim2.fromOffset(320, 167),
    UDim2.fromOffset(125, 36), C.input)

make("Frame", {BackgroundColor3 = C.border, BorderSizePixel = 0,
    Position = UDim2.fromOffset(21, 218), Size = UDim2.new(1, -42, 0, 1)}, keyWindow)
local keyStatus = label(keyWindow,
    keyServerReady() and "●  En attente de clé." or "●  Configuration Cloudflare requise.",
    11, C.muted, false,
    {Position = UDim2.fromOffset(21, 230), Size = UDim2.new(1, -42, 0, 22)})
local keyBusy = false
local function setKeyStatus(text, isError)
    if not stopped and keyStatus.Parent then
        keyStatus.Text = "●  " .. text
        keyStatus.TextColor3 = isError and C.red or C.muted
    end
end
local function withKeyRequest(kind)
    if keyBusy or stopped then return end
    keyBusy = true
    verifyButton.Text = "Vérification..."
    getKeyButton.Active = false
    verifyButton.Active = false
    setKeyStatus("Connexion au serveur...", false)
    local ok, result
    if kind == "generate" then
        ok, result = postKeyAPI("/api/public/generate", {
            label = "VisionHub-" .. tostring(player.UserId),
            days = 1,
            maxActivations = 50,
        })
        if ok then
            keyField.Text = tostring(result.key or "")
            setKeyStatus("Clé obtenue (24 h). Cliquez sur Valider.", false)
        end
    else
        local entered = (keyField.Text or ""):match("^%s*(.-)%s*$")
        if entered == "" then
            ok, result = false, "Entrez votre clé avant de valider."
        else
            ok, result = postKeyAPI("/api/verify", {key = entered})
            if ok then
                unlocked = true
                overlay:Destroy()
                showWindow(true)
                statusText.Text = "●  Clé validée • Vision Hub prêt"
            end
        end
    end
    if not ok then setKeyStatus(tostring(result), true) end
    keyBusy = false
    if not stopped then
        verifyButton.Text = "Valider"
        getKeyButton.Active = true
        verifyButton.Active = true
    end
end
bind(getKeyButton.Activated, function() withKeyRequest("generate") end)
bind(verifyButton.Activated, function() withKeyRequest("verify") end)
bind(quitButton.Activated, function() stop() end)
bind(keyField.FocusLost, function(enterPressed)
    if enterPressed then withKeyRequest("verify") end
end)

local function resizeKeyGate()
    if stopped or not overlay.Parent then return end
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
    keyScale.Scale = math.clamp(math.min((vp.X - 18) / 466, (vp.Y - 18) / 270), 0.32, 1)
end
resizeKeyGate()
local viewportSignal
local function bindGateViewport()
    if viewportSignal then viewportSignal:Disconnect() end
    local camera = workspace.CurrentCamera
    if camera then viewportSignal = bind(camera:GetPropertyChangedSignal("ViewportSize"), resizeKeyGate) end
    resizeKeyGate()
end
bind(workspace:GetPropertyChangedSignal("CurrentCamera"), bindGateViewport)
bindGateViewport()

-- Gate server-side : l'accès normal requiert une réponse {ok=true}.
-- Les actions des onglets sont encore des maquettes, comme dans V5.
 end, true)
        addAction(a, "Masquer le hub", function() showWindow(false) end)
        local b = section(right, "Informations", "Environnement")
        infoLine(b, "Joueur", player.Name)
        infoLine(b, "Place ID", tostring(game.PlaceId))
        infoLine(b, "Game ID", tostring(game.GameId))
        infoLine(b, "Environnement", runtimeName)
    elseif currentPage == "Paramètres" then
        local a = section(left, "Interface", "Options locales")
        addToggle(a, "Animations", "Transitions des interrupteurs", "UI.Animations", true)
        addToggle(a, "Notifications", "Messages dans la barre d'état", "UI.Notifications", true)
        addDropdown(a, "Taille de l'interface", "UI.Size", {"Normale", "Compacte", "Grande"})
        local b = section(right, "Fenêtre", "Actions disponibles")
        addAction(b, "Recentrer la fenêtre", function()
            window.Position = UDim2.fromScale(0.5, 0.5)
            feedback("Fenêtre recentrée")
        end, true)
        addAction(b, "Masquer l'interface", function() showWindow(false) end)
        addAction(b, "Quitter Vision Hub", function() stop() end)
    end
end

-- Options réellement reliées au fonctionnement de cette UI.
ACTIONS["UI.Animations"] = function(v) animations = v; feedback("Animations " .. (v and "activées" or "désactivées")) end
ACTIONS["UI.Notifications"] = function(v)
    showNotifications = v
    if v then feedback("Notifications activées") end
end
ACTIONS["UI.Size"] = function(v)
    uiZoom = (v == "Compacte" and 0.87) or (v == "Grande" and 1.08) or 1
    refreshLayout()
end

bind(search:GetPropertyChangedSignal("Text"), function()
    local query = string.lower(search.Text):match("^%s*(.-)%s*$")
    local found = false
    for _, group in ipairs(sections) do
        local headingMatch = query == "" or string.find(group.text, query, 1, true) ~= nil
        local count = 0
        for _, item in ipairs(group.rows) do
            if item.ui and item.ui.Parent then
                local matched = headingMatch or string.find(item.text, query, 1, true) ~= nil
                item.ui.Visible = matched
                if matched then count = count + 1 end
            end
        end
        local show = headingMatch or count > 0
        group.ui.Visible = show
        if show then found = true end
    end
    emptyResults.Visible = query ~= "" and not found
end)

changePage("Accueil")

-- Relancer le script enlève l'ancienne fenêtre et déconnecte ses événements.
-- Utilisation : interface seulement, sans actions de jeu ou contournement.