-- server/events.lua
d4dzCore = d4dzCore or {}

RegisterNetEvent('d4dzCore:Server:TriggerCallback', function(name, requestId, ...)
    local src = source
    if d4dzCore.ServerCallbacks[name] then
        d4dzCore.ServerCallbacks[name](src, function(...)
            TriggerClientEvent('d4dzCore:Client:TriggerCallbackResponse', src, requestId, ...)
        end, ...)
    else
        TriggerClientEvent('d4dzCore:Client:TriggerCallbackResponse', src, requestId, false)
    end
end)

RegisterNetEvent('d4dzCore:server:updatePlayerState', function(clientMetadata)
    local src = source
    local player = d4dzCore.Functions.GetPlayer(src)
    if player and clientMetadata then
        player.PlayerData.metadata = clientMetadata
        player.Functions.Save()
    end
end)

RegisterNetEvent('d4dzCore:Server:UseItem', function(itemName)
    local src = source
    if d4dzCore.Functions.GetPlayer(src) then 
        d4dzCore.Functions.CanUseItem(src, itemName) 
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if d4dzCore.Players[src] then
        d4dzCore.Players[src].Functions.Save()
        d4dzCore.Players[src] = nil
        d4dzCore.Debug.Log(string.format("Flushed references for source: %s", src))
    end
end)

d4dzCore.Functions.CreateCallback('d4dzCore:server:hasInventoryItem', function(source, cb, itemName, amount)
    cb(true) -- Drop-in inventory compatibility proxy stub
end)
