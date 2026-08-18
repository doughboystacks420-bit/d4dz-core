-- server/player.lua
d4dzCore = d4dzCore or {}
d4dzCore.Players = d4dzCore.Players or {}

local Player = {}
Player.__index = Player

-- Instantiates a Player mimicking standard structural framework states natively
function d4dzCore.CreatePlayerObject(source, rawData)
    local self = setmetatable({}, Player)
    self.Functions = {}
    
    self.PlayerData = {
        source = source,
        citizenid = rawData.citizenid,
        license = rawData.license,
        charinfo = { firstname = rawData.firstname, lastname = rawData.lastname },
        money = { cash = rawData.cash or 5000, bank = rawData.bank or 15000 },
        job = rawData.job or { name = 'unemployed', grade = 0, onDuty = true },
        gang = rawData.gang or { name = 'none', grade = 0 },
        metadata = rawData.metadata or { hunger = 100, thirst = 100, isdead = false, inlaststand = false }
    }
    
    self.Functions.GetMoney = function(moneyType) 
        return self.PlayerData.money[moneyType] or 0 
    end
    
    self.Functions.AddMoney = function(moneyType, amount, reason)
        if not self.PlayerData.money[moneyType] then return false end
        self.PlayerData.money[moneyType] = self.PlayerData.money[moneyType] + amount
        self.Functions.UpdatePlayerData()
        return true
    end

    self.Functions.RemoveMoney = function(moneyType, amount, reason)
        if not self.PlayerData.money[moneyType] or self.PlayerData.money[moneyType] < amount then return false end
        self.PlayerData.money[moneyType] = self.PlayerData.money[moneyType] - amount
        self.Functions.UpdatePlayerData()
        return true
    end

    self.Functions.SetMetaData = function(meta, val)
        self.PlayerData.metadata[meta] = val
        self.Functions.UpdatePlayerData()
    end

    self.Functions.UpdatePlayerData = function()
        TriggerClientEvent('d4dzCore:Client:OnPlayerLoaded', self.PlayerData.source, self.PlayerData)
    end
    
    self.Functions.Save = function()
        local query = [[
            UPDATE players 
            SET cash = ?, bank = ?, job = ?, gang = ?, metadata = ? 
            WHERE citizenid = ?
        ]]
        exports.oxmysql:update(query, {
            self.PlayerData.money.cash,
            self.PlayerData.money.bank,
            json.encode(self.PlayerData.job),
            json.encode(self.PlayerData.gang),
            json.encode(self.PlayerData.metadata),
            self.PlayerData.citizenid
        }, function(affectedRows)
            if affectedRows > 0 then
                d4dzCore.Debug.Log(string.format("Saved persistent data changes for citizenid: %s", self.PlayerData.citizenid))
            end
        end)
    end

    return self
end
-- ============================================================================
-- D4DZ-MULTICHARACTER EXTENSION COMPATIBILITY LAYER
-- ============================================================================

-- Hook tracking when a connection drops past the loading screen phase
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function() -- Or your custom join trigger name
    local src = source
    -- Wake up your custom multicharacter script to start pulling slots
    TriggerEvent('d4dz-core:server:PlayerJoined', src)
end)

-- 1. EXTENSION: Fetches all registered characters belonging to a RockStar License
exports('GetPlayerCharacters', function(source)
    local license = GetPlayerIdentifierByType(source, 'license')
    if not license then return {} end

    -- Raw block query pulling matching archive tables asynchronously-awaited
    local result = exports.oxmysql:query_idx('SELECT * FROM players WHERE license = ?', { license })
    local parsedCharacters = {}

    if result and #result > 0 then
        for i = 1, #result do
            local row = result[i]
            
            -- Re-mapping your table variables to match what Vue.js expects to read
            table.insert(parsedCharacters, {
                citizenid = row.citizenid,
                cid = row.cid or i, -- Maps numerical slot identifier
                charinfo = json.decode(row.charinfo) or { firstname = row.firstname, lastname = row.lastname },
                money = { cash = row.cash or 5000, bank = row.bank or 15000 },
                job = json.decode(row.job) or { name = 'unemployed' }
            })
        end
    end

    return parsedCharacters
end)

-- 2. EXTENSION: Handles instantiation log loops when selecting an identity
exports('PlayerLogin', function(source, citizenid)
    local license = GetPlayerIdentifierByType(source, 'license')
    
    -- Gather specific record fields from the SQL tables
    local result = exports.oxmysql:query_idx('SELECT * FROM players WHERE citizenid = ? AND license = ?', { citizenid, license })
    if not result or #result == 0 then return false end
    
    local row = result[1]
    local charinfo = json.decode(row.charinfo) or {}

    local playerRawData = {
        citizenid = row.citizenid,
        license = row.license,
        firstname = charinfo.firstname or "John",
        lastname = charinfo.lastname or "Doe",
        cash = row.cash,
        bank = row.bank,
        job = json.decode(row.job),
        gang = json.decode(row.gang),
        metadata = json.decode(row.metadata)
    }

    -- TRIGGERS THE CORE BLUEPRINT METHOD PROVIDED ABOVE:
    local PlayerInstance = d4dzCore.CreatePlayerObject(source, playerRawData)
    
    -- Save instance globally into your d4dzCore runtime session table array
    d4dzCore.Players[source] = PlayerInstance
    
    -- Fires off initialization updates down to the player client HUD systems
    PlayerInstance.Functions.UpdatePlayerData()
    return true
end)

-- 3. EXTENSION: Creates a fresh identity registry row inside the tables
exports('CreateNewCharacter', function(source, data)
    local license = GetPlayerIdentifierByType(source, 'license')
    if not license then return false end

    local uniqueCitizenId = tostring("D4DZ" .. math.random(11111, 99999))
    local charinfo = json.encode({
        firstname = data.firstname,
        lastname = data.lastname,
        birthdate = data.dob,
        gender = data.gender
    })
    
    local defaultJob = json.encode({ name = 'unemployed', grade = 0, onDuty = true })
    local defaultGang = json.encode({ name = 'none', grade = 0 })
    local defaultMeta = json.encode({ hunger = 100, thirst = 100, isdead = false, inlaststand = false })

    -- Synchronously insert record block payload into your target server structures
    local inserted = exports.oxmysql:insert_idx([[
        INSERT INTO players (citizenid, cid, license, charinfo, cash, bank, job, gang, metadata) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], { uniqueCitizenId, data.slot, license, charinfo, 5000, 15000, defaultJob, defaultGang, defaultMeta })

    if inserted then
        -- Automatically log them straight in right after creation completes successfully
        return exports['d4dz-core']:PlayerLogin(source, uniqueCitizenId)
    end
    return false
end)

-- 4. EXTENSION: Wipes a character configuration profile completely out of the system
exports('DeleteCharacter', function(source, citizenid)
    local license = GetPlayerIdentifierByType(source, 'license')
    
    -- Ensure authenticity protection signatures validate before dropping records
    local isOwner = exports.oxmysql:scalar_idx('SELECT 1 FROM players WHERE citizenid = ? AND license = ?', { citizenid, license })
    if not isOwner then return false end

    local affectedRows = exports.oxmysql:update_idx('DELETE FROM players WHERE citizenid = ?', { citizenid })
    return affectedRows > 0
end)

-- 5. EXTENSION: Destroys running cache states on logouts/relogs
exports('LogoutPlayer', function(source)
    if d4dzCore.Players[source] then
        -- Force a sync save of current parameters before flushing session logs
        d4dzCore.Players[source].Functions.Save()
        d4dzCore.Players[source] = nil
        TriggerClientEvent('d4dzCore:Client:OnPlayerUnloaded', source)
    end
end)
