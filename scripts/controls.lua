local moveLeft_down = false --keybinds
local moveRight_down = false
local keybind_down_last_frame = false
local last_selected_controllerId = -1
local current_UI_deviceStructureId = nil

function UpdateControls()
    EvalMoveKeybinds()
    ThrottleControl()
end

function OnControlActivated(name, code, doubleClick)
    local uid = GetLocalClientIndex()
    if name == "brake" and code then
        if data.brakes[code] then
            SendScriptEvent("UpdateBrakes", 0 .. "," .. code, "", false)
            SetControlSpriteByParent("root", "brake", "hud-brake-icon")
        else
            SendScriptEvent("UpdateBrakes", 1 .. "," .. code, "", false)
            SetControlSpriteByParent("root", "brake", "hud-brake-pressed-icon")
        end
    elseif name == "info" .. uid .. "1" or name == "info" .. uid .. "2" then
        if Metric then
            Metric = false
        else
            Metric = true
        end
    elseif name == "info" .. uid .. "3" then
        PrintKeybinds()
    elseif name == "close" then
        Deselect()
    end
end

function IsValidController(deviceId)
    if  deviceId ~= -1
    and CheckSaveNameTable(GetDeviceType(deviceId), CONTROLLER_SAVE_NAME)
    and IsDeviceFullyBuilt(deviceId)
    and (GetDeviceTeamIdActual(deviceId) == GetLocalTeamId())
    then
        return true
    else
        return false
    end
end

function GetControlledStructureId(controllerId)
    if IsValidController(controllerId) then
        -- Getting structure ID directly from device maybe sometimes give wrong value, this is a workaround
        return NodeStructureId(GetDevicePlatformA(controllerId))
    else
        return nil
    end
end

function ThrottleControl()
    local deviceStructureId = GetControlledStructureId(GetLocalSelectedDeviceId())
    local uid = GetLocalClientIndex()
    
    if deviceStructureId then
        --user has a valid controller selected so we should show the UI and read throttle slider

        if deviceStructureId ~= current_UI_deviceStructureId then DestroyUI(uid) end --recreate UI so button callbacks get updated to new structureid

        if not ControlExists("root", "ThrottleSlider") then
            CreateUI(deviceStructureId, uid)
        else
            local pos = GetControlRelativePos("ThrottleSlider", "SliderBar")
            --send the pos to the throttles table
            if ControlExists("root", "ThrottleSlider") then
                SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(pos.x, 3) .. "," .. pos.y .. "," .. deviceStructureId, "", false)
            end
        end

        UpdateVehicleInfo(deviceStructureId, uid)
    else
        DestroyUI(uid)
    end
end

function CreateUI(deviceStructureId, uid)
    current_UI_deviceStructureId = deviceStructureId

    SetControlFrame(0)
    local position = { x =200, y = 450}
    local size = { x = 662, y = 371.25}
    AddButtonControl("HUD", "throttle backdrop", path .. "/ui/textures/HUD/HUD Box.png", ANCHOR_TOP_LEFT, size, position, "Panel")
    LoadControl(path .. "/ui/controls.lua", "root")

    for i = 1, 3 do
        AddTextButtonControl("throttle backdrop", "info" .. uid .. i, CurrentLanguage.PromptRightClick, ANCHOR_TOP_LEFT, {x = 50, y = 50 + i * 20, z = -10}, false, "Panel")
        SetButtonCallback("root", "info" .. uid .. i, deviceStructureId)
    end
    SetControlText("throttle backdrop", "info" .. uid .. "3", "Show hotkeys")
    SetControlStyle("throttle backdrop", "info" .. uid .. "3", "Fine")

    for i = 4, 6 do
        AddTextButtonControl("throttle backdrop", "info" .. uid .. i, CurrentLanguage.PromptRightClick, ANCHOR_TOP_RIGHT, {x = 612, y = -10 + i * 20, z = -10}, false, "Panel")
    end
    SetControlText("throttle backdrop", "info" .. uid .. "6", CurrentLanguage.PromptRightClick)
    SetControlStyle("throttle backdrop", "info" .. uid .. "6", "Fine")

    AddTextButtonControl("throttle backdrop", "close", "x", ANCHOR_TOP_LEFT, {x = 612, y = 20, z = -10}, false, "Heading")
    SetButtonCallback("root", "close", deviceStructureId)

    CreateBrakeButton(deviceStructureId)

    --initialize throttle
    local pos = {x = 273.5, y = 15}
    --if the structure doesn't already have a throttle, create it
    if not data.throttles[deviceStructureId] then
        if ControlExists("root", "ThrottleSlider") then
            SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(pos.x, 3) .. "," .. pos.y .. "," .. deviceStructureId, "", false)
        end
        SetControlRelativePos("ThrottleSlider", "SliderBar", pos)
    end
    
    --set the device slider to whatever the throttle is in the structure throttles table
    if data.throttles[deviceStructureId] then
        SetControlRelativePos("ThrottleSlider", "SliderBar", data.throttles[deviceStructureId])
    end
end

function CreateBrakeButton(deviceStructureId)
    AddButtonControl("", "brake", "hud-brake-icon", ANCHOR_CENTER_CENTER, {x = 51.56, y = 41.25}, {x = 524, y = 550}, "Normal")
    SetButtonCallback("root", "brake", deviceStructureId)
    --if the structure doesn't already have a brake, then create it

    if data.brakes[deviceStructureId] == nil then
        SendScriptEvent("UpdateBrakes", 0 .. "," .. deviceStructureId, "", false)
    else
        
        if data.brakes[deviceStructureId] then
            SetControlSpriteByParent("root", "brake", "hud-brake-pressed-icon")
        else
            SetControlSpriteByParent("root", "brake", "hud-brake-icon")
        end
    end
end

function DestroyUI(uid)
    current_UI_deviceStructureId = nil

    if ControlExists("root", "ThrottleSlider") then
        DeleteControl("", "close")
        DeleteControl("HUD", "throttle backdrop")
        DeleteControl("root", "ThrottleSlider")
        DeleteControl("root", "brake")
        for i = 1, 6 do
            DeleteControl("root", "info" .. uid .. i)
        end
    end
end

function UpdateVehicleInfo(structure, uid)
    local uid = GetLocalClientIndex()

    --make sure the details exist
    if DrivechainDetails[structure] and DrivechainDetails[structure][1] then
        --define variables
        local velocity = math.abs(DrivechainDetails[structure][1])
        local maxSpeed = DrivechainDetails[structure][2]
        local details = {
            kmhr = string.format("%.0f", velocity / 100 * 3.6),
            mph = string.format("%.0f", velocity / 100 * 2.23694),
            maxkmhr = string.format("%.0f", maxSpeed / 100 * 3.6),
            maxmph = string.format("%.0f", maxSpeed / 100 * 2.23694),
            gear = DrivechainDetails[structure][3],
            power = DrivechainDetails[structure][4],
        }
        --to stop things from flashing around as much.
        if tonumber(details.kmhr) < 10 then details.kmhr = "  " .. details.kmhr end
        if tonumber(details.mph) < 10 then details.mph = "  " .. details.mph end
        --power
        details.power = math.floor(details.power / 1000)
        if details.power < 1000 then details.power = "  " .. details.power end
        if not details.power == 0 then details.power = details.power .. "K" end
        --set text
        if Metric then
            SetControlText("throttle backdrop", "info" .. uid .. "1", CurrentLanguage.SpeedText .. details.kmhr .. CurrentLanguage.SpeedUnitKmph)
            SetControlText("throttle backdrop", "info" .. uid .. "2", CurrentLanguage.TopSpeedText .. details.maxkmhr .. CurrentLanguage.SpeedUnitMph)
        else
            SetControlText("throttle backdrop", "info" .. uid .. "1", CurrentLanguage.SpeedText .. details.mph .. CurrentLanguage.SpeedUnitMph)
            SetControlText("throttle backdrop", "info" .. uid .. "2", CurrentLanguage.TopSpeedText .. details.maxmph .. CurrentLanguage.SpeedUnitMph)
        end

        SetControlText("throttle backdrop", "info" .. uid .. "4", CurrentLanguage.GearText .. details.gear)
        SetControlText("throttle backdrop", "info" .. uid .. "5", CurrentLanguage.PowerText .. details.power)
    end
end

--returns the selected, or as a fallback the last selected controllerId
function GetMostRecentController()
    local controller = GetLocalSelectedDeviceId()

    if IsValidController(controller) then
        last_selected_controllerId = controller

    elseif IsValidController(last_selected_controllerId) then
        controller = last_selected_controllerId

    else
        last_selected_controllerId = -1
        return nil
    end

    return controller
end

function EvalMoveKeybinds()
    local controller = GetMostRecentController()
    if not controller then return end

    local deviceStructureId = GetControlledStructureId(controller)
    if not deviceStructureId or not data.throttles[deviceStructureId] then return end

    local old_throttle = data.throttles[deviceStructureId].x
    local new_throttle = nil

    if moveLeft_down and moveRight_down then
        keybind_down_last_frame = true
        new_throttle = 273.5

    elseif moveLeft_down then
        keybind_down_last_frame = true
        new_throttle = math.min(old_throttle, 273.5) - 50

    elseif moveRight_down then
        keybind_down_last_frame = true
        new_throttle = math.max(old_throttle, 273.5) + 50

    elseif keybind_down_last_frame then --keybind was released so we set neutral throttle once
        keybind_down_last_frame = false
        new_throttle = 273.5
    end

    if new_throttle then
        new_throttle = Clamp(new_throttle, 33, 514)
        
        if ControlExists("ThrottleSlider", "SliderBar") then
            SetControlRelativePos("ThrottleSlider", "SliderBar", {x = new_throttle, y = 15})
        else
            SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(new_throttle, 3) .. "," .. 15 .. "," .. deviceStructureId, "", false)
        end
    end
end

-------Keybind callbacks
function MoveLeft()
    moveLeft_down = true
end

function MoveLeft_Up()
    moveLeft_down = false
end

function MoveRight()
    moveRight_down = true
end

function MoveRight_Up()
    moveRight_down = false
end

function ToggleBrake()
    local controller = GetMostRecentController()
    if not controller then return end

    local deviceStructureId = GetControlledStructureId(controller)
    if deviceStructureId then
        if ControlExists("root", "brake") then
            OnControlActivated("brake", deviceStructureId)
        else
            if data.brakes[deviceStructureId] then
                SendScriptEvent("UpdateBrakes", 0 .. "," .. deviceStructureId, "", false)
            else
                SendScriptEvent("UpdateBrakes", 1 .. "," .. deviceStructureId, "", false)
            end
        end
    end
end