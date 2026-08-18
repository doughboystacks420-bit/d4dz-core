-- client/loops.lua
d4dzCore = d4dzCore or {}
d4dzCore.Functions = d4dzCore.Functions or {}

-- Safe error-managed wrapper for spinning up continuous game loops
function d4dzCore.Functions.CreateTick(tickFunction)
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local result = tickFunction()
            if type(result) == "number" then sleep = result end
            Citizen.Wait(sleep)
        end
    end)
end

----------------------------------------------------------------
-- 1. SAVE SYNCHRONIZATION LOOP
----------------------------------------------------------------
d4dzCore.Functions.CreateTick(function()
    if d4dzCore.IsLoggedIn then
        local updateInterval = (1000 * 60) * (d4dzCore.Config and d4dzCore.Config.UpdateInterval or 5)
        TriggerServerEvent('d4dzCore:server:updatePlayerState', d4dzCore.PlayerData.metadata)
        return updateInterval
    end
    return 1000
end)

----------------------------------------------------------------
-- 2. VITALS HEALTH MONITORING LOOP (STARVATION DAMAGE)
----------------------------------------------------------------
d4dzCore.Functions.CreateTick(function()
    if d4dzCore.IsLoggedIn then
        local metadata = d4dzCore.PlayerData.metadata
        if metadata then
            local isDead = metadata['isdead'] or metadata['inlaststand']
            local hunger = metadata['hunger'] or 100
            local thirst = metadata['thirst'] or 100

            if (hunger <= 0 or thirst <= 0) and not isDead then
                local ped = PlayerPedId()
                local currentHealth = GetEntityHealth(ped)
                local decreaseThreshold = math.random(5, 10)
                SetEntityHealth(ped, currentHealth - decreaseThreshold)
            end
        end
        return (d4dzCore.Config and d4dzCore.Config.StatusInterval or 2500)
    end
    return 1000
end)

----------------------------------------------------------------
-- 3. PERMANENT NUI HUD TELEMETRY TRACKER
----------------------------------------------------------------
d4dzCore.Functions.CreateTick(function()
    if not d4dzCore.IsLoggedIn then 
        d4dzCore.Functions.HideText()
        return 2000 
    end

    local playerMoney = d4dzCore.PlayerData.money
    local playerJob = d4dzCore.PlayerData.job
    
    local cashBalance = playerMoney and playerMoney.cash or 0
    local bankBalance = playerMoney and playerMoney.bank or 0
    local jobLabel = playerJob and playerJob.name or "Civilian"
    local jobGrade = playerJob and playerJob.grade or 0

  local hudDisplayString = string.format([=[
        <div style="color: #4cd964; margin-bottom: 2px;">Cash: $%s</div>
        <div style="color: #0076ff; margin-bottom: 2px;">Bank: $%s</div>
        <div style="color: #ffcc00; font-size: 15px;">Job: %s (Grade %s)</div>
    ]=], 
    tostring(cashBalance), 
    tostring(bankBalance), 
    string.upper(jobLabel), 
    tostring(jobGrade.grade or jobGrade)) -- FIXED: Changes %d to %s and safely checks for sub-grade

    d4dzCore.Functions.DrawText(hudDisplayString)
    return 1500
end)


----------------------------------------------------------------
-- 4. GRADUAL HUNGER & THIRST DEGRADATION TIMELINE
----------------------------------------------------------------
d4dzCore.Functions.CreateTick(function()
    if not d4dzCore.IsLoggedIn then return 5000 end

    local metadata = d4dzCore.PlayerData.metadata
    if metadata then
        local isDead = metadata['isdead'] or metadata['inlaststand']

        if not isDead then
            local currentHunger = metadata['hunger'] or 100
            local currentThirst = metadata['thirst'] or 100

            -- Decreases points incrementally while avoiding negative numbers
            local newHunger = math.max(0, currentHunger - 1) -- Drops 1 point per minute
            local newThirst = math.max(0, currentThirst - 2) -- Drops 2 points per minute (Dehydration is faster)

            d4dzCore.PlayerData.metadata['hunger'] = newHunger
            d4dzCore.PlayerData.metadata['thirst'] = newThirst

            -- Fire synchronization parameters straight back to server memory
            TriggerServerEvent('d4dzCore:server:updatePlayerState', d4dzCore.PlayerData.metadata)

            -- Send an overlay alert warning if vitals reach critical thresholds
            if newHunger < 20 or newThirst < 20 then
                d4dzCore.Functions.Notify("You are feeling severely hungry or dehydrated!", "error", 4000)
            end
        end
    end

    -- Run this resource calculation tick exactly once every 60 seconds (60000ms)
    return 60000
end)
----------------------------------------------------------------
-- 5. SURVIVAL STAMINA EXHAUSTION & SPRINT FATIGUE LOOP
----------------------------------------------------------------
d4dzCore.Functions.CreateTick(function()
    if not d4dzCore.IsLoggedIn then return 5000 end

    local metadata = d4dzCore.PlayerData.metadata
    if metadata then
        local isDead = metadata['isdead'] or metadata['inlaststand']
        
        if not isDead then
            local hunger = metadata['hunger'] or 100
            local thirst = metadata['thirst'] or 100
            local ped = PlayerPedId()

            -- Check if the player is actively putting physical strain on their body
            if (IsPedRunning(ped) or IsPedSprinting(ped) or IsPedSwimming(ped)) then
                -- Target condition: Character is pushing themselves while starved or dehydrated
                if hunger <= 20 or thirst <= 20 then
                    -- Drop their current stamina level incrementally
                    local currentStamina = GetPlayerStamina(PlayerId())
                    SetPlayerStamina(PlayerId(), math.max(0.0, currentStamina - 4.0))
                    
                    -- If they hit absolute exhaustion, apply visual fatigue side-effects
                    if currentStamina <= 1.0 then
                        -- Apply a heavy physical camera shake motion to mimic passing out
                        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
                        SetPedMoveRateOverride(ped, 0.75) -- Slows their structural run speed down to a heavy walk
                        
                        -- Screen flash blur effect
                        StartScreenEffect('ChopVision', 1000, false)
                    end
                    return 200 -- Run fast checks while sprinting to deplete smoothly
                end
            end
        end
    end

    return 1000 -- Slow the loop down to 1 second rest intervals when walking or standing idle
end)
