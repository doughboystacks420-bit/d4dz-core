-- client/drawtext.lua
d4dzCore = d4dzCore or {}
d4dzCore.Functions = d4dzCore.Functions or {}

-- Routes colored slide-in notifications directly to html/js/app.js
function d4dzCore.Functions.Notify(text, texttype, length)
    SendNUIMessage({
        action = 'notify',
        text = text,
        type = texttype or 'primary',
        length = length or 5000
    })
end

RegisterNetEvent('d4dzCore:Client:Notify', function(text, texttype, length)
    d4dzCore.Functions.Notify(text, texttype, length)
end)

-- Sends permanent text structures or HUD content directly to html/js/drawtext.js
function d4dzCore.Functions.DrawText(text)
    SendNUIMessage({
        action = 'drawtext',
        text = text
    })
end

-- Clear text shortcut helper
function d4dzCore.Functions.HideText()
    SendNUIMessage({
        action = 'drawtext',
        text = false
    })
end

exports('DrawText', function(text) d4dzCore.Functions.DrawText(text) end)
exports('HideText', function() d4dzCore.Functions.HideText() end)
