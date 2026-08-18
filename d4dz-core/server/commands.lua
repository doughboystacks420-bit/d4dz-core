-- server/commands.lua
d4dzCore = d4dzCore or {}

local function IsPlayerAdmin(source)
    if source == 0 then return true end
    local license = GetPlayerIdentifierByType(source, 'license')
    if license and string.find(license, "localhost") then return true end
    if IsPlayerAceAllowed(source, "command") or IsPlayerAceAllowed(source, "admin") then return true end
    return false
end

RegisterCommand('spawnchar', function(source, args)
    local src = source
    local license = GetPlayerIdentifierByType(src, 'license')
    if not license then return end
    
    local nameArg = args[1] or "John"
    d4dzCore.Functions.LoadCharacterData(src, license, nameArg)
end, false)

RegisterCommand('givemoney', function(source, args, rawCommand)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local targetId, moneyType, amount = tonumber(args[1]), tostring(args[2]):lower(), tonumber(args[3])
    if not targetId or not amount or (moneyType ~= 'cash' and moneyType ~= 'bank') then return end

    local targetPlayer = d4dzCore.Functions.GetPlayer(targetId)
    if targetPlayer and targetPlayer.Functions.AddMoney(moneyType, amount, "Admin Command Grant") then
        TriggerClientEvent('d4dzCore:Client:Notify', src, "Dispatched transaction accurately.", "success")
    end
end, false)

RegisterCommand('setjob', function(source, args, rawCommand)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local targetId, jobName, jobGrade = tonumber(args[1]), tostring(args[2]):lower(), tonumber(args[3])
    if not targetId or not jobName or not jobGrade then return end

    local targetPlayer = d4dzCore.Functions.GetPlayer(targetId)
    if targetPlayer then
        targetPlayer.PlayerData.job = { name = jobName, grade = jobGrade, onDuty = true }
        targetPlayer.Functions.UpdatePlayerData()
        targetPlayer.Functions.Save()
    end
end, false)
