-- server/exports.lua
d4dzCore = d4dzCore or {}

exports('getCoreServerInstance', function() 
    return d4dzCore 
end)

-- Inject usable attributes directly to your baseline elements catalog
d4dzCore.Functions.CreateUseableItem('sandwich', function(source)
    local player = d4dzCore.Functions.GetPlayer(source)
    if player then
        local newHunger = math.min(100, (player.PlayerData.metadata['hunger'] or 100) + 35)
        player.Functions.SetMetaData('hunger', newHunger)
        TriggerClientEvent('d4dzCore:Client:Notify', source, "You ate a sandwich.", "success")
        TriggerClientEvent('d4dzCore:Client:PlayItemUseAnimation', source, 'sandwich')
    end
end)

d4dzCore.Functions.CreateUseableItem('water_bottle', function(source)
    local player = d4dzCore.Functions.GetPlayer(source)
    if player then
        local newThirst = math.min(100, (player.PlayerData.metadata['thirst'] or 100) + 40)
        player.Functions.SetMetaData('thirst', newThirst)
        TriggerClientEvent('d4dzCore:Client:Notify', source, "You drank water.", "success")
        TriggerClientEvent('d4dzCore:Client:PlayItemUseAnimation', source, 'water_bottle')
    end
end)

d4dzCore.Debug.Log("Master server core framework decentralized runtimes fully mounted.")
