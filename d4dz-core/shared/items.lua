-- shared/items.lua
d4dzCore = d4dzCore or {}
d4dzCore.Shared = d4dzCore.Shared or {}

d4dzCore.Shared.Items = {
    ['water_bottle'] = { name = 'water_bottle', label = 'Water Bottle', weight = 500, unique = false, useable = true },
    ['sandwich']     = { name = 'sandwich', label = 'Sandwich', weight = 400, unique = false, useable = true },
    ['lockpick']     = { name = 'lockpick', label = 'Lockpick', weight = 1000, unique = false, useable = true },
    ['phone']        = { name = 'phone', label = 'Cell Phone', weight = 250, unique = true, useable = true }
}
