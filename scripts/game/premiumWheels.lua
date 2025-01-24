
WheelTable = {}



data.teamWheelTypes = {}


WheelIndexToName = {}
WheelNameToIndex = {}
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

    for key, definition in pairs(WheelTable) do
        WheelIndexToName[#WheelIndexToName + 1] = key
        WheelNameToIndex[key] = #WheelIndexToName
    end
end


function LoadPremiumWheels()

    
    -- BetterLog("Loading premium wheels")
    AddStrings(path .. "/config/clearUserStrings.lua")
    
    for steamId, def in pairs(PremiumUsers) do
        steamId = "7656119" .. steamId
        AddStrings("../users/" .. steamId .. "/multiplayer.lua")
        if StringExists("data.ServerName") then
            BetterLog("SteamID is " .. steamId)
            LocalPlayerHasAccessToPremiumWheels = true
            LocalPlayerIsModAuthor = def.ModAuthor
            ScheduleCall(1, HandleCosmeticWheel, def)
            AddStrings(path .. "/config/clearUserStrings.lua")
        end
    end 
end
LocalPlayerHasAccessToPremiumWheels = false
LocalPlayerIsModAuthor = false
function HandleCosmeticWheel(def)
    SetControlFrame(0)
    -- local type = types[1]
    AddTextControl("HUD", "cosmeticWheelContainer", CurrentLanguage.WelcomeText .. def.Name .. CurrentLanguage.ChooseWheelText, ANCHOR_TOP_LEFT, {x = 25, y = 50}, false, "Console")
    
    local y = 50
    AddTextButtonControl("cosmeticWheelContainer", "button_cosmetic_SetDefault", CurrentLanguage.ResetToDefaultText, ANCHOR_TOP_LEFT, {x = 0, y = 25}, false, "Readout")
    if def.ModAuthor then
        for name, wheelDefinition in pairs(WheelTable) do
            local index = WheelNameToIndex[name]
            AddTextButtonControl("cosmeticWheelContainer", "button_cosmetic_" .. name, tostring(name), ANCHOR_TOP_LEFT, {x = 0, y = y}, false, "Readout")
            SetButtonCallback("cosmeticWheelContainer", "button_cosmetic_" .. name, index)
            y = y + 15
        end
    else
        for _, name in pairs(def.Wheels) do
            local index = WheelNameToIndex[name]
            AddTextButtonControl("cosmeticWheelContainer", "button_cosmetic_" .. name, tostring(name), ANCHOR_TOP_LEFT, {x = 0, y = y}, false, "Readout")
            SetButtonCallback("cosmeticWheelContainer", "button_cosmetic_" .. name, index)
            y = y + 15
        end
    end
    
    -- SendScriptEvent("ShareCosmeticWheel",  '"' ..type .. "\"," .. teamId, "", false)
end
function GetCosmeticWheelChoice(index)
    local name = WheelIndexToName[index]
    local teamId = GetLocalTeamId()
    if not index or index == 0 then 
        Notice("Default selected! Press CTRL + LSHIFT + LALT + C to change selection.")
        name = teamId % MAX_SIDES
    else
        Notice(name .. " selected! Press CTRL + LSHIFT + LALT + C  to change selection.")
    end
    SendScriptEvent("ShareCosmeticWheel",  "\"" ..name .. "\"," .. teamId, "", false)
    ShowControl("HUD", "cosmeticWheelContainer", false)
end

function ShareCosmeticWheel(wheelType, teamId)
    if type(tonumber(wheelType)) == "number" then 
        --Notice("Default selected! Press CTRL + ALT + C to change selection.")
        data.teamWheelTypes[teamId] = WheelTable[tonumber(wheelType)]
        
    else
        --Notice(type .. " selected! Press CTRL + ALT + C  to change selection.")
        data.teamWheelTypes[teamId] = WheelTable[wheelType]
    end
    --ShowControl("HUD", "cosmeticWheelContainer", false)
    RefreshWheels(teamId)
end

function ShowWheelSelectionScreen()
    if LocalPlayerHasAccessToPremiumWheels then
        SetControlFrame(0)
        ShowControl("HUD", "cosmeticWheelContainer", true)
    end
end