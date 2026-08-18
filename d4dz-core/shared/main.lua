-- shared/main.lua
d4dzCore = d4dzCore or {}
d4dzCore.Shared = d4dzCore.Shared or {}

d4dzCore.Config = {
    UpdateInterval = 5,    -- Player auto-save interval in minutes
    StatusInterval = 2500, -- Vital sign processing speed in ms
    DefaultSpawn = vector4(-1037.6, -2737.5, 20.1, 329.5) -- LS Airport
}

d4dzCore.Shared.Items = {
    ['water_bottle'] = { name = 'water_bottle', label = 'Water Bottle', weight = 500, unique = false, useable = true },
    ['sandwich']     = { name = 'sandwich', label = 'Sandwich', weight = 400, unique = false, useable = true },
    ['lockpick']     = { name = 'lockpick', label = 'Lockpick', weight = 1000, unique = false, useable = true },
    ['phone']        = { name = 'phone', label = 'Cell Phone', weight = 250, unique = true, useable = true }
}

local function GetCoreObject(filters)
    if not filters then return d4dzCore end
    local results = {}
    for i = 1, #filters do
        local key = filters[i]
        if d4dzCore[key] then results[key] = d4dzCore[key] end
    end
    return results
end
exports('GetCoreObject', GetCoreObject)

function GetShared(namespace, item)
    local ns = d4dzCore.Shared[namespace]
    if not ns then return nil end
    return item and ns[item] or ns
end
exports('GetShared', GetShared)

d4dzCore.Shared.Trim = function(str)
    if not str then return "" end
    return (string.gsub(str, '^%s*(.-)%s*$', '%1'))
end

d4dzCore.Shared.Round = function(value, numDecimalPlaces)
    if not value then return 0.0 end
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(value * mult + 0.5) / mult
end
