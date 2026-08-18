local LocaleObj = {}
LocaleObj.__index = LocaleObj

function LocaleObj:new(data)
    local obj = setmetatable({}, LocaleObj)
    obj.translations = data or {}
    return obj
end

function LocaleObj:t(key, substitute)
    local text = self.translations[key] or key
    if substitute then
        for k, v in pairs(substitute) do
            text = string.gsub(text, "%%{" .. k .. "}", tostring(v))
        end
    end
    return text
end

-- This export function hands the engine directly to any script that requests it
function GetLocaleClass()
    return LocaleObj
end

-- Keep global fallbacks just in case
Locale = LocaleObj
_G.Locale = LocaleObj
