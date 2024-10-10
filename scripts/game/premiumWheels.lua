
WheelTable = {}



data.teamWheelTypes = {}

function LoadWheelTypeDefinitions()
    WheelTable = {

        [1] = {
            sprocket = {
                small = "/effects/track_sprocket_blue.lua",
                medium = "/effects/track_sprocket_blue.lua",
                large = "/effects/track_sprocket_blue_large.lua",
                extraLarge = "/effects/track_sprocket_blue_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_blue.lua",
                medium = "/effects/wheel_blue.lua",
                large = "/effects/wheel_blue_large.lua",
                extraLarge = "/effects/wheel_blue_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
        
        [2] = {
            sprocket = {
                small = "/effects/track_sprocket_red.lua",
                medium = "/effects/track_sprocket_red.lua",
                large = "/effects/track_sprocket_red_large.lua",
                extraLarge = "/effects/track_sprocket_red_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_red.lua",
                medium = "/effects/wheel_red.lua",
                large = "/effects/wheel_red_large.lua",
                extraLarge = "/effects/wheel_red_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
    
        Default = {
            sprocket = {
                small = "/effects/track_sprocket.lua",
                medium = "/effects/track_sprocket.lua",
                large = "/effects/track_sprocket_large.lua",
                extraLarge = "/effects/track_sprocket_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel.lua",
                medium = "/effects/wheel.lua",
                large = "/effects/wheel_large.lua",
                extraLarge = "/effects/wheel_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
    
        DeltawingWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Deltawing.lua",
                medium = "/effects/track_sprocket_Deltawing.lua",
                large = "/effects/track_sprocket_Deltawing_large.lua",
                extraLarge = "/effects/track_sprocket_Deltawing_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Deltawing.lua",
                medium = "/effects/wheel_Deltawing.lua",
                large = "/effects/wheel_Deltawing_large.lua",
                extraLarge = "/effects/wheel_Deltawing_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
    
        LinnWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Linn.lua",
                medium = "/effects/track_sprocket_Linn.lua",
                large = "/effects/track_sprocket_Linn_large.lua",
                extraLarge = "/effects/track_sprocket_Linn_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Linn.lua",
                medium = "/effects/wheel_Linn.lua",
                large = "/effects/wheel_Linn_large.lua",
                extraLarge = "/effects/wheel_Linn_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
    
        IncursusWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Incursus.lua",
                medium = "/effects/track_sprocket_Incursus.lua",
                large = "/effects/track_sprocket_Incursus_large.lua",
                extraLarge = "/effects/track_sprocket_Incursus_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Incursus.lua",
                medium = "/effects/wheel_Incursus.lua",
                large = "/effects/wheel_Incursus_large.lua",
                extraLarge = "/effects/wheel_Incursus_extraLarge.lua",
            },
            track = "/effects/track_Incursus.lua",
            trackLink = "/effects/track_link_Incursus.lua",
        },
        
        SpiderWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Spider.lua",
                medium = "/effects/track_sprocket_Spider.lua",
                large = "/effects/track_sprocket_Spider_large.lua",
                extraLarge = "/effects/track_sprocket_Spider_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Spider.lua",
                medium = "/effects/wheel_Spider.lua",
                large = "/effects/wheel_Spider_large.lua",
                extraLarge = "/effects/wheel_Spider_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
    
        FrazzzWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Frazzz.lua",
                medium = "/effects/track_sprocket_Frazzz.lua",
                large = "/effects/track_sprocket_Frazzz_large.lua",
                extraLarge = "/effects/track_sprocket_Frazzz_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Frazzz.lua",
                medium = "/effects/wheel_Frazzz.lua",
                large = "/effects/wheel_Frazzz_large.lua",
                extraLarge = "/effects/wheel_Frazzz_extraLarge.lua",
            },
            track = "/effects/track_Frazzz.lua",
            trackLink = "/effects/track_link_Frazzz.lua",
        },
        NozeWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Noze.lua",
                medium = "/effects/track_sprocket_Noze.lua",
                large = "/effects/track_sprocket_Noze_large.lua",
                extraLarge = "/effects/track_sprocket_Noze_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Noze.lua",
                medium = "/effects/wheel_Noze.lua",
                large = "/effects/wheel_Noze_large.lua",
                extraLarge = "/effects/wheel_Noze_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
        DevWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Dev.lua",
                medium = "/effects/track_sprocket_Dev.lua",
                large = "/effects/track_sprocket_Dev_large.lua",
                extraLarge = "/effects/track_sprocket_Dev_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Dev.lua",
                medium = "/effects/wheel_Dev.lua",
                large = "/effects/wheel_Dev_large.lua",
                extraLarge = "/effects/wheel_Dev_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
        FishyWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Fishy.lua",
                medium = "/effects/track_sprocket_Fishy.lua",
                large = "/effects/track_sprocket_Fishy_large.lua",
                extraLarge = "/effects/track_sprocket_Fishy_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Fishy.lua",
                medium = "/effects/wheel_Fishy.lua",
                large = "/effects/wheel_Fishy_large.lua",
                extraLarge = "/effects/wheel_Fishy_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        },
        DiscordWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Discord.lua",
                medium = "/effects/track_sprocket_Discord.lua",
                large = "/effects/track_sprocket_Discord_large.lua",
                extraLarge = "/effects/track_sprocket_Discord_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Discord.lua",
                medium = "/effects/wheel_Discord.lua",
                large = "/effects/wheel_Discord_large.lua",
                extraLarge = "/effects/wheel_Discord_extraLarge.lua",
            },
            track = "/effects/track_Discord.lua",
            trackLink = "/effects/track_link_Discord.lua",
        },
        CodeUltimateWheel = {
            sprocket = {
                small = "/effects/track_sprocket_CodeUltimate.lua",
                medium = "/effects/track_sprocket_CodeUltimate.lua",
                large = "/effects/track_sprocket_CodeUltimate_large.lua",
                extraLarge = "/effects/track_sprocket_CodeUltimate_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_CodeUltimate.lua",
                medium = "/effects/wheel_CodeUltimate.lua",
                large = "/effects/wheel_CodeUltimate_large.lua",
                extraLarge = "/effects/wheel_CodeUltimate_extraLarge.lua",
            },
            track = "/effects/track_CodeUltimate.lua",
            trackLink = "/effects/track_link_CodeUltimate.lua",
        },
        PaulWheel = {
            sprocket = {
                small = "/effects/track_sprocket_Paul.lua",
                medium = "/effects/track_sprocket_Paul.lua",
                large = "/effects/track_sprocket_Paul_large.lua",
                extraLarge = "/effects/track_sprocket_Paul_extraLarge.lua",
            },
            wheel = {
                small = "/effects/wheel_Paul.lua",
                medium = "/effects/wheel_Paul.lua",
                large = "/effects/wheel_Paul_large.lua",
                extraLarge = "/effects/wheel_Paul_extraLarge.lua",
            },
            track = "/effects/track.lua",
            trackLink = "/effects/track_link.lua",
        }
    }
end

function LoadWheelTypes()
    LoadWheelTypeDefinitions()
    data.teamWheelTypes[0] = WheelTable.Default
    for side = 1, 2 do
        data.teamWheelTypes[side] = WheelTable[side]
        for team = 1, 8 do
            local teamActual = team * 100 + side
            data.teamWheelTypes[teamActual] = WheelTable[side]
        end
    end
end


function LoadPremiumWheels()

    
    -- BetterLog("Loading premium wheels")
    AddStrings(path .. "/config/clearUserStrings.lua")
    
    for steamId, types in pairs(PremiumWheels) do
        AddStrings("../users/" .. steamId .. "/multiplayer.lua")
        if StringExists("data.ServerName") then
            BetterLog("SteamID is " .. steamId)
            --local string = "\"Mod author present, initializing " .. RGBAtoHex(200, 50, 50, 255, false) .. "the funny\""
            --SendScriptEvent("BetterLog", string, "", false)
            ScheduleCall(1, HandleCosmeticWheel, types, PremiumNames[steamId])
            LocallyAvailableTypes = types
            AddStrings(path .. "/config/clearUserStrings.lua")
            LocalPlayerHasAccessToPremiumWheels = true
        end
    end
end
LocalPlayerHasAccessToPremiumWheels = false
LocallyAvailableTypes = {}
function HandleCosmeticWheel(types, username)
    -- local type = types[1]
    AddTextControl("HUD", "cosmeticWheelContainer", "Welcome " .. username .. ". Choose your wheel type.", ANCHOR_TOP_LEFT, {x = 25, y = 50}, false, "Console")
    local y = 50

    AddTextButtonControl("cosmeticWheelContainer", "button_cosmetic_Default", "Default", ANCHOR_TOP_LEFT, {x = 0, y = 25}, false, "Readout")
    for index, type in pairs(types) do
        AddTextButtonControl("cosmeticWheelContainer", "button_cosmetic_" .. type, type, ANCHOR_TOP_LEFT, {x = 0, y = y}, false, "Readout")
        SetButtonCallback("cosmeticWheelContainer", "button_cosmetic_" .. type, index)
        y = y + 25
    end
    -- SendScriptEvent("ShareCosmeticWheel",  '"' ..type .. "\"," .. teamId, "", false)
end
function GetCosmeticWheelChoice(type)
    local teamId = GetLocalTeamId()
    if not type then 
        Notice("Default selected! Press CTRL + ALT + C to change selection.")
        type = teamId % MAX_SIDES
    else
        Notice(type .. " selected! Press CTRL + ALT + C  to change selection.")
    end
    SendScriptEvent("ShareCosmeticWheel",  "\"" ..type .. "\"," .. teamId, "", false)
    ShowControl("HUD", "cosmeticWheelContainer", false)
end

function ShareCosmeticWheel(wheelType, teamId)
    if type(tonumber(wheelType)) == "number" then 
        --Notice("Default selected! Press CTRL + ALT + C to change selection.")
        data.teamWheelTypes[teamId] = WheelTable[teamId % MAX_SIDES]
        
    else
        --Notice(type .. " selected! Press CTRL + ALT + C  to change selection.")
        data.teamWheelTypes[teamId] = WheelTable[wheelType]
    end
    --ShowControl("HUD", "cosmeticWheelContainer", false)
    RefreshWheels(teamId)
end

function ShowWheelSelectionScreen()
    if LocalPlayerHasAccessToPremiumWheels then
        ShowControl("HUD", "cosmeticWheelContainer", true)
    end
end