-- server/functions.lua
d4dzCore = d4dzCore or {}
d4dzCore.Functions = d4dzCore.Functions or {}
d4dzCore.ServerCallbacks = d4dzCore.ServerCallbacks or {}
d4dzCore.UseableItems = d4dzCore.UseableItems or {}

-- Core Framework Session Getters
function d4dzCore.Functions.GetPlayer(source) return d4dzCore.Players[source] end

function d4dzCore.Functions.GetPlayerByCitizenId(citizenid)
    for _, p in pairs(d4dzCore.Players) do
        if p.PlayerData.citizenid == citizenid then return p end
    end
    return nil
end

-- Asynchronous Callback Registration Engine
function d4dzCore.Functions.CreateCallback(name, cb)
    d4dzCore.ServerCallbacks[name] = cb
end

-- Usable Items System Framework Engine
function d4dzCore.Functions.CreateUseableItem(item, cb) d4dzCore.UseableItems[item] = cb end
function d4dzCore.Functions.CanUseItem(source, item)
    if d4dzCore.UseableItems[item] then d4dzCore.UseableItems[item](source) return true end
    return false
end

----------------------------------------------------------------
-- DATABASE MANAGEMENT & LOAD METRICS LAYER
----------------------------------------------------------------

-- Asynchronous Query Handlers connecting directly to oxmysql via multi-character selections
function d4dzCore.Functions.LoadCharacterData(source, license, chosenCitizenId)
    local src = source
    
    -- Query looking up the specific selected character data row
    exports.oxmysql:single('SELECT * FROM players WHERE license = ? AND citizenid = ?', { license, chosenCitizenId }, function(row)
        if row then
            -- Safely parse database LONGTEXT columns back into operational Lua tables
            row.job = type(row.job) == "string" and json.decode(row.job) or row.job
            row.gang = type(row.gang) == "string" and json.decode(row.gang) or row.gang
            row.metadata = type(row.metadata) == "string" and json.decode(row.metadata) or row.metadata
            
            -- Initialize player session object model mapping
            local playerInstance = d4dzCore.CreatePlayerObject(src, row)
            d4dzCore.Players[src] = playerInstance
            
            -- Force instant state synchronization packet down to client cache matrices
            playerInstance.Functions.UpdatePlayerData()
            d4dzCore.Debug.Log(string.format("Successful handshake validation. Synced active profile: %s for source ID: %s", chosenCitizenId, src))
        else
            -- Error boundary handler executes if multi-character attempts to feed a broken payload key
            d4dzCore.Debug.Error(string.format("Authentication mismatch: Character selection row %s not found in database columns for source %s.", chosenCitizenId, src))
        end
    end)
end

----------------------------------------------------------------
-- FRAMEWORK INTERVAL PAYCHECKS SYSTEM THREAD
----------------------------------------------------------------

-- Automated Salary Paycheck Loop Worker Thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- Execute payroll evaluations every 10 minutes (600000ms)
        d4dzCore.Debug.Log("Executing global framework payroll cycle distribution matrix...")
        
        for src, player in pairs(d4dzCore.Players) do
            if player and player.PlayerData then
                local job = player.PlayerData.job
                local paycheck = 0

                -- Basic salary check loops matching framework preferences
                if job.name == 'unemployed' then paycheck = 50
                elseif job.name == 'police' then
                    if job.grade == 0 then paycheck = 500
                    elseif job.grade == 1 then paycheck = 750
                    elseif job.grade == 2 then paycheck = 1500
                    end
                end

                -- Dispatch allocations to bank sheets safely if value checks clear
                if paycheck > 0 then
                    player.Functions.AddMoney('bank', paycheck, "Salary Paycheck")
                    TriggerClientEvent('d4dzCore:Client:Notify', src, "Paycheck Received: +$"..paycheck, "success")
                end
            end
        end
    end
end)
-- Global Character Initialization Engine for Brand New Accounts
function d4dzCore.Functions.CreateNewCharacterInstance(source, firstname, lastname, slot)
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    if not license then return false end

    -- Generate a unique alphanumeric Citizen ID (Example: D4DZ-10025)
    local generatedId = "D4DZ-" .. math.random(10000, 99999)
    
    -- Setup standard framework baseline starting configurations
    local defaultMoney = json.encode({ cash = 5000, bank = 15000 })
    local defaultCharInfo = json.encode({ firstname = firstname, lastname = lastname })
    local defaultJob = json.encode({ name = 'unemployed', grade = 0 })
    local defaultGang = json.encode({ name = 'none', grade = 0 })
    local defaultMetadata = json.encode({ inside = false, inventory = {} })
    local defaultPosition = json.encode({ x = 309.1, y = -589.2, z = 43.3, w = 0.0 }) -- Default Spawn Point

    -- Force database row insertion via oxmysql query handler
    exports.oxmysql:insert('INSERT INTO players (license, citizenid, slot, money, charinfo, job, gang, metadata, position) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        license, generatedId, slot, defaultMoney, defaultCharInfo, defaultJob, defaultGang, defaultMetadata, defaultPosition
    }, function(insertId)
        if insertId then
            -- Immediately pull the newly generated record to instantiate the player's active session
            d4dzCore.Functions.LoadCharacterData(src, license, generatedId)
        else
            d4dzCore.Debug.Error("Database structural execution failed during character slot initialization.")
        end
    end)

    return true
end
