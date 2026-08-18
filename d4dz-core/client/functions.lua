-- client/functions.lua
d4dzCore = d4dzCore or {}
d4dzCore.PlayerData = d4dzCore.PlayerData or {}
d4dzCore.IsLoggedIn = false
d4dzCore.ServerCallbacks = d4dzCore.ServerCallbacks or {}
d4dzCore.Functions = d4dzCore.Functions or {}

----------------------------------------------------------------
-- 1. NATIVE LUA CALLBACK ENGINE (STANDALONE PROMISE OVERRIDE)
----------------------------------------------------------------

-- Asynchronous/Synchronous Native Callback Trigger Wrapper
function d4dzCore.Functions.TriggerCallback(name, cb, ...)
    local chars, requestId = 'abcdefghijklmnopqrstuvwxyz0123456789', ''
    for i = 1, 10 do
        local rand = math.random(1, #chars)
        requestId = requestId .. string.sub(chars, rand, rand)
    end

    -- Create an in-memory framework promise wrapper for this tracking ID
    d4dzCore.ServerCallbacks[requestId] = promise.new()

    -- Trigger the server event passing the unique tracking ID
    TriggerServerEvent('d4dzCore:Server:TriggerCallback', name, requestId, ...)

    -- Force the current execution thread to pause natively until the server answers
    local result = Citizen.Await(d4dzCore.ServerCallbacks[requestId])

    if cb then 
        cb(result) 
    else 
        return result 
    end
end

----------------------------------------------------------------
-- 2. CORE UTILITY BLOCKS & ENTITY PLACEMENT MANAGER
----------------------------------------------------------------

-- Checks item totals inside your d4dz item framework metrics via a callback proxy
function d4dzCore.Functions.HasItem(itemName, amount)
    local targetAmount = amount or 1
    -- Replaced the messy timeout while loop with our optimized synchronous await
    return d4dzCore.Functions.TriggerCallback('d4dzCore:server:hasInventoryItem', nil, itemName, targetAmount)
end

-- Clean, cinematic character spawning method exposed to external scripts
function d4dzCore.Functions.SpawnPlayerPed(coords)
    Citizen.CreateThread(function()
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Wait(10) end

        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, false)
        
        local x, y, z, w = coords.x, coords.y, coords.z, coords.w or 0.0
        RequestCollisionAtCoord(x, y, z)
        SetEntityCoords(ped, x, y, z, false, false, false, true)
        SetEntityHeading(ped, w)
        
        local timeout = GetGameTimer() + 5000
        while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do Wait(10) end

        FreezeEntityPosition(ped, false)
        SetEntityVisible(ped, true, false)
        
        DoScreenFadeIn(1000)
        d4dzCore.Functions.Notify("Character spawned successfully.", "success")
    end)
end

-- High-performance world pool getters matching standard schemas
function d4dzCore.Functions.GetVehicles() return GetGamePool('CVehicle') end
function d4dzCore.Functions.GetObjects() return GetGamePool('CObject') end
function d4dzCore.Functions.GetPlayers() return GetActivePlayers() end

----------------------------------------------------------------
-- 3. GLOBAL MASTER FRAMEWORK EXPORTS
----------------------------------------------------------------
exports('getCoreClientInstance', function() return d4dzCore end)
exports('SpawnPlayerPed', function(coords) d4dzCore.Functions.SpawnPlayerPed(coords) end)
