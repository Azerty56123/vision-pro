-- VISION PRO V4 - BETA SERVER (Roblox ServerScriptService)
-- Security boundary: NEVER place the actual secret keys in a LocalScript, a
-- public GitHub file or ReplicatedStorage. Keep your configured copy PRIVATE
-- in ServerScriptService. This public template deliberately contains NO KEY.
-- Setup:
-- 1. Paste this script as a normal Script inside ServerScriptService.
-- 2. Add unique 20+ character keys to BETA_KEYS in the PRIVATE Studio copy.
-- 3. Publish the experience. For persistence, enable API Services in Studio.
-- 4. Set USE_DATASTORE=true for production; fail closed if storage fails.
-- Note: this gate secures UI access requests, not arbitrary client-executed code.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local REMOTE_NAME = "VisionProBetaAccess"
local USE_DATASTORE = true
local ALLOW_STUDIO_PREVIEW = false -- set true in your PRIVATE Studio copy for UI previews only
local STORE_NAME = "VisionProBetaAccessV4"
local MAX_ATTEMPTS = 6
local ATTEMPT_WINDOW = 90

-- KEY FORMAT:
-- ["VP4-VERY-LONG-PRIVATE-RANDOM-KEY"] = {
--     Id = "wave-a-001", -- stable ID (NOT the plaintext key)
--     ExpiresAt = 0,    -- 0 = no expiration; otherwise Unix timestamp
--     MaxUsers = 10,    -- max unique user accounts worldwide
--     AllowedUserIds = nil -- optional: {[12345678]=true}
-- }
-- Keep configured keys only in your private ServerScriptService copy.
local BETA_KEYS = {}

local store
if USE_DATASTORE then
    store = DataStoreService:GetDataStore(STORE_NAME)
end
local session = {}
local attempts = {}
local byId = {}
for secret,entry in pairs(BETA_KEYS) do
    if type(secret) == "string" and type(entry) == "table"
        and type(entry.Id) == "string" and #entry.Id > 0 then
        assert(not byId[entry.Id], "Duplicate beta key ID: "..entry.Id)
        byId[entry.Id] = entry
    end
end

local function validEntry(entry,userId)
    if not entry then return false end
    local expiration=tonumber(entry.ExpiresAt) or 0
    if expiration > 0 and os.time() >= expiration then return false end
    if entry.AllowedUserIds and not entry.AllowedUserIds[userId] then
        return false
    end
    return true
end

local function response(ok,message,expires)
    return {
        ok = ok,
        message = message,
        expiresAt = expires or 0,
    }
end

local function activeStatus(player)
    if ALLOW_STUDIO_PREVIEW and RunService:IsStudio() then
        return response(true,"Apercu Studio autorise",0)
    end
    local id = player.UserId
    local cached = session[id]
    if cached and validEntry(byId[cached],id) then
        return response(true,"Acces beta actif",byId[cached].ExpiresAt)
    end
    if not USE_DATASTORE then
        return response(false,"Entrez une cle beta")
    end
    local ok,saved = pcall(function()
        return store:GetAsync("user:"..id)
    end)
    if not ok then return response(false,"Verification serveur indisponible") end
    if type(saved) == "string" and validEntry(byId[saved],id) then
        session[id] = saved
        return response(true,"Acces beta actif",byId[saved].ExpiresAt)
    end
    return response(false,"Entrez une cle beta")
end

local function rateLimit(userId)
    local now = os.clock()
    local bucket = attempts[userId]
    if not bucket or now - bucket.start > ATTEMPT_WINDOW then
        bucket = {start=now,count=0}
        attempts[userId]=bucket
    end
    bucket.count = bucket.count + 1
    return bucket.count > MAX_ATTEMPTS
end

local function activate(player,rawKey)
    if ALLOW_STUDIO_PREVIEW and RunService:IsStudio() then
        return response(true,"Apercu Studio autorise",0)
    end
    if rateLimit(player.UserId) then
        return response(false,"Trop d'essais. Reessayez plus tard.")
    end
    if type(rawKey)~="string" or #rawKey < 8 or #rawKey > 120 then
        return response(false,"Format de cle invalide")
    end
    local key=rawKey:match("^%s*(.-)%s*$")
    local entry=BETA_KEYS[key]
    if not validEntry(entry,player.UserId) then
        return response(false,"Cle invalide ou expiree")
    end
    local id=entry.Id
    if USE_DATASTORE then
        local approved=false
        local ok,err=pcall(function()
            store:UpdateAsync("key:"..id,function(current)
                local data=type(current)=="table" and current or {}
                local users=type(data.users)=="table" and data.users or {}
                local count=0
                for _ in pairs(users) do count=count+1 end
                local userKey=tostring(player.UserId)
                local maxUsers=math.max(1,tonumber(entry.MaxUsers) or 1)
                if not users[userKey] and count>=maxUsers then
                    approved=false
                    return nil
                end
                users[userKey]=true
                approved=true
                return {users=users}
            end)
        end)
        if not ok then return response(false,"Stockage beta indisponible") end
        if not approved then return response(false,"Cle beta complete") end
        local saved=pcall(function()
            store:SetAsync("user:"..player.UserId,id)
        end)
        if not saved then
            return response(false,"Activation non finalisee. Reessayez.")
        end
    end
    session[player.UserId]=id
    return response(true,"Activation reussie",entry.ExpiresAt)
end

local remote=ReplicatedStorage:FindFirstChild(REMOTE_NAME)
if remote and not remote:IsA("RemoteFunction") then
    error(REMOTE_NAME.." is already used by another instance")
end
if not remote then
    remote=Instance.new("RemoteFunction")
    remote.Name=REMOTE_NAME
    remote.Parent=ReplicatedStorage
end
remote.OnServerInvoke=function(player,action,key)
    if action=="status" then
        return activeStatus(player)
    elseif action=="activate" then
        return activate(player,key)
    end
    return response(false,"Action non autorisee")
end
Players.PlayerRemoving:Connect(function(player)
    session[player.UserId]=nil
    attempts[player.UserId]=nil
end)
local keyCount=0
for _ in pairs(BETA_KEYS) do keyCount=keyCount+1 end
print("[VISION PRO V4] Beta server ready, "..keyCount.." configured keys")
