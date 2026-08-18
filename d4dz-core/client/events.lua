-- client/events.lua
d4dzCore = d4dzCore or {}
d4dzCore.PlayerData = d4dzCore.PlayerData or {}
d4dzCore.ServerCallbacks = d4dzCore.ServerCallbacks or {}

----------------------------------------------------------------
-- 1. FRAMEWORK LIFECYCLE HANDSHAKE LISTENERS
----------------------------------------------------------------

-- Caches data parameters sent by the server without triggering any automatic spawns
RegisterNetEvent('d4dzCore:Client:OnPlayerLoaded', function(serverData)
    d4dzCore.PlayerData = serverData
    d4dzCore.IsLoggedIn = true
    
    -- Safety check in case the debug table hasn't fully loaded across early execution files
    if d4dzCore.Debug and d4dzCore.Debug.Log then
        d4dzCore.Debug.Log("Framework state loaded. Awaiting structural multi-character spawn handoff.")
    else
        print("^5[d4dzCore] Framework state loaded. Awaiting structural multi-character spawn handoff.^7")
    end
end)

----------------------------------------------------------------
-- 2. NATIVE CALLBACK DISPATCH RESOLUTION ENGINE
----------------------------------------------------------------

-- Intercepts server validation confirmations to settle pending native callback promises
RegisterNetEvent('d4dzCore:Client:TriggerCallbackResponse', function(requestId, payload)
    if d4dzCore.ServerCallbacks[requestId] then
        -- FIXED: Unlocks the client thread synchronously by resolving the native promise object
        d4dzCore.ServerCallbacks[requestId]:resolve(payload)
        d4dzCore.ServerCallbacks[requestId] = nil
    end
end)

----------------------------------------------------------------
-- 3. ENVIRONMENTAL ITEM INTERACTION HANDLERS
----------------------------------------------------------------

-- Listens for item utilization network signals to play appropriate tasks
RegisterNetEvent('d4dzCore:Client:PlayItemUseAnimation', function(itemType)
    local ped = PlayerPedId()
    local animDict, animName = "mp_player_inteat@burger", "mp_player_int_eat_burger_fp"
    if itemType == 'water_bottle' then animDict, animName = "mp_player_intdrink", "loop_bottle" end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Wait(10) end

    TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, 3000, 49, 0, false, false, false)
    Wait(3000)
    ClearPedTasks(ped)
    RemoveAnimDict(animDict)
end)
