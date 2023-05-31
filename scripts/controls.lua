function UpdateControls()
    ThrottleControl()
end

function OnControlActivated(name, code, doubleClick)
    local uid = GetLocalClientIndex()
    if name == "brake" and code then
        if data.brakes[code] then
            SendScriptEvent("UpdateBrakes", 0 .. "," .. code, "", false)
            SetControlText("root", "brake", "Brakes: Off")
        else
            SendScriptEvent("UpdateBrakes", 1 .. "," .. code, "", false)
            SetControlText("root", "brake", "Brakes: On")
        end
    elseif name == "info" .. uid .. "1" or name == "info" .. uid .. "2" then
        if Metric then
            Metric = false
        else
            Metric = true
        end
    elseif name == "close" then
        Deselect()
    end
end



function ThrottleControl()
    local uid = GetLocalClientIndex()
    local selectedDevice = GetLocalSelectedDeviceId()
    local deviceStructureId = -1
    if selectedDevice ~= -1 then
         -- Getting structure ID directly from device maybe sometimes give wrong value, this is a workaround
        deviceStructureId = NodeStructureId(GetDevicePlatformA(selectedDevice))
    end
    local teamId = GetLocalTeamId()
        --If the controller device is selected
        if CheckSaveNameTable(GetDeviceType(selectedDevice), CONTROLLER_SAVE_NAME) and IsDeviceFullyBuilt(selectedDevice) and (GetDeviceTeamIdActual(selectedDevice) == teamId) then
            --if it doesn't exist in it's current instance, create it
            if not ControlExists("root", "PropulsionSlider") then
                SetControlFrame(0)
                local position = { x =200, y = 450}
                local size = { x = 662, y = 371.25}
                AddButtonControl("HUD", "throttle backdrop", path .. "/ui/textures/HUD/HUD Box.png", ANCHOR_TOP_LEFT, size, position, "Panel")
                LoadControl(path .. "/ui/controls.lua", "root")
                for i = 1, 2 do
                    AddTextButtonControl("throttle backdrop", "info" .. uid .. i, "Right click world to close", ANCHOR_TOP_LEFT, {x = 50, y = 70 + i * 20, z = -10}, false, "Panel")
                    SetButtonCallback("root", "info" .. uid .. i, deviceStructureId)
                end
                for i = 3, 5 do
                    AddTextButtonControl("throttle backdrop", "info" .. uid .. i, "Right click world to close", ANCHOR_TOP_RIGHT, {x = 612, y = 10 + i * 20, z = -10}, false, "Panel")
                end
                --AddTextButtonControl("throttle backdrop", "info" .. uid .. "6", "", ANCHOR_TOP_LEFT, {x = 600, y = 540, z = -10}, false, "Panel")
                AddTextButtonControl("throttle backdrop", "close", "x", ANCHOR_TOP_LEFT, {x = 612, y = 20, z = -10}, false, "Heading")
                SetButtonCallback("root", "close", deviceStructureId)
                --brake
                CreateBrakeButton(deviceStructureId)
                --initialize throttle
                local pos = {x = 273.5, y = 15}
                --if the structure doesn't already have a throttle, create it
                if not data.throttles[deviceStructureId] then
                    if ControlExists("root", "PropulsionSlider") then
                        SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(pos.x, 3) .. "," .. pos.y .. "," .. deviceStructureId, "", false)
                    end
                    SetControlRelativePos("PropulsionSlider", "SliderBar", pos)
                end
                
                --set the device slider to whatever the throttle is in the structure throttles table
                if data.throttles[deviceStructureId] then
                    SetControlRelativePos("PropulsionSlider", "SliderBar", data.throttles[deviceStructureId])
                end
            end
            --update starts here
            --Get the pos from the slider
            local pos = GetControlRelativePos("PropulsionSlider", "SliderBar")
            --send the pos to the throttles table
            if ControlExists("root", "PropulsionSlider") then
                SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(pos.x, 3) .. "," .. pos.y .. "," .. deviceStructureId, "", false)
            end
            if ControlExists("root", "brake") then
                UpdateBrakeButton(deviceStructureId)
            end

            UpdateVehicleInfo(deviceStructureId, uid)
        else
            --once done with throttle widget, delete it
            if ControlExists("root", "PropulsionSlider") then
                DeleteControl("", "close")
                DeleteControl("HUD", "throttle backdrop")
                DeleteControl("root", "PropulsionSlider")
                DeleteControl("root", "brake")
                for i = 1, 6 do
                    DeleteControl("root", "info" .. uid .. i)
                end
            end
        end
end


function UpdateVehicleInfo(structure, uid)
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
        details.power = details.power .. "K"
        --set text
        if Metric then
            SetControlText("throttle backdrop", "info" .. uid .. "1", "Speed: " .. details.kmhr .. " km/h")
            SetControlText("throttle backdrop", "info" .. uid .. "2", "Top speed: " .. details.maxkmhr .. " km/h")
        else
            SetControlText("throttle backdrop", "info" .. uid .. "1", "Speed: " .. details.mph .. " mph")
            SetControlText("throttle backdrop", "info" .. uid .. "2", "Top speed: " .. details.maxmph .. " mph")
        end
        SetControlText("throttle backdrop", "info" .. uid .. "3", "Right click world to close")
        SetControlText("throttle backdrop", "info" .. uid .. "4", "Gear: " .. details.gear)
        SetControlText("throttle backdrop", "info" .. uid .. "5", "Power: " .. details.power)
    end
end
function CreateBrakeButton(deviceStructureId)
    AddTextButtonControl("", "brake", "Brakes: Off", ANCHOR_CENTER_CENTER, {x = 520, y = 560}, false, "normal")
    SetButtonCallback("root", "brake", deviceStructureId)
    --if the structure doesn't already have a brake, then create it

    if data.brakes[deviceStructureId] == nil then
        SendScriptEvent("UpdateBrakes", 0 .. "," .. deviceStructureId, "", false)
    else
        
        if data.brakes[deviceStructureId] then
            SetControlText("root", "brake", "Brakes: On")
        else
            SetControlText("root", "brake", "Brakes: Off")
        end
    end

end

function UpdateBrakeButton(deviceStructureId)
    SetButtonCallback("root", "brake", deviceStructureId)
end