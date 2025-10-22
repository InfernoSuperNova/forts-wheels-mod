FileList = {
    ["config"] = {
        "commanders", --.lua
        "config",
        "wheels",
        "premiumIds",
    },

    ["scripts"] = {
        ["devices"] = {
            "devices",
            "drillScript",
            "weapons",
        },
        ["game"] = {
            ["wheels"] = {
                "Propulsion",
                "Tracks",
                "WheelCollision",
            },
            "coreShield",
            "editor",
            "effects",
            "resources",
            "premiumWheels",
            "WheelTypeDefinitions",
            "MissileManager"
        },
        ["helpers"] = {
            "BetterLog",
            "CommanderDetection",
            "debug",
            "misc",
        },
        ["math"] = {
            "PID",
            "VectorFunctions",
            ["PolyBool"] = {
                "terrainConverter"
            },
            ["polyman"] = {
                "init"
            }
        },
        ["player"] = {
            "controls",
            "input",
            "localization",
        },
        ["wireframe"] = {
            "drawableWheel"
        },
        "EffectManager",
        "forceManager",
    },

    ["strings"] = {
        "strings"
    }
}

local function RGBAtoHex(r, g, b, a, UTF16)
    local hex = string.format("%02X%02X%02X%02X", r, g, b, a)
    if UTF16 == true then
        return L "[HL=" .. towstring(hex) .. L "]"
    else
        return "[HL=" .. hex .. "]"
    end
end
function LoadTableFiles(table, path)
    for folder, item in pairs(table) do
        if type(item) == "table" then
            LoadTableFiles(item, path.."/"..folder)
        else
            Log("Landcruisers: Loading ".. RGBAtoHex(50, 150, 50, 255, false)..path.."/"..item..".lua")
            dofile(path .. "/"..item..".lua")
        end
    end
end
function LoadFiles()
    LoadTableFiles(FileList, path)
end
