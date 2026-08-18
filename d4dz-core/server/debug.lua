-- server/debug.lua
d4dzCore = d4dzCore or {}
d4dzCore.Debug = d4dzCore.Debug or {}

local isDebugModeActive = true

function d4dzCore.Debug.Log(text)
    if not isDebugModeActive then return end
    print(string.format("^3[d4dzCore:SERVER_DEBUG] %s^7", tostring(text)))
end

function d4dzCore.Debug.Error(text)
    print(string.format("^1[d4dzCore:SERVER_ERROR] %s^7", tostring(text)))
end
