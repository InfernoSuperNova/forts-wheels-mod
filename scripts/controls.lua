function UpdateControls()
    ThrottleControl()
end

function OnControlActivated(name, code, doubleClick)
    if name == "brake" and code then
        if data.brakes[code] then
            SendScriptEvent("UpdateBrakes", 0 .. "," .. code, "", false)
            SetControlText("root", "brake", "Brakes: Off")
        else
            SendScriptEvent("UpdateBrakes", 1 .. "," .. code, "", false)
            SetControlText("root", "brake", "Brakes: On")
        end


    end
    if name == "close" then
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
                AddSpriteControl("", "throttle backdrop", path .. "/ui/textures/HUD/HUD Box.png", ANCHOR_TOP_LEFT, size, position, false)
                LoadControl(path .. "/ui/controls.lua", "root")
                for i = 1, 3 do
                    AddTextButtonControl("throttle backdrop", "info" .. uid .. i, "Info", ANCHOR_TOP_LEFT, {x = 50, y = 50 + i * 20, z = -10}, false, "Panel")
                end
                for i = 4, 6 do
                    AddTextButtonControl("throttle backdrop", "info" .. uid .. i, "Info", ANCHOR_TOP_RIGHT, {x = 612, y = -10 + i * 20, z = -10}, false, "Panel")
                end
                --AddTextButtonControl("throttle backdrop", "info" .. uid .. "6", "", ANCHOR_TOP_LEFT, {x = 600, y = 540, z = -10}, false, "Panel")
                AddTextButtonControl("throttle backdrop", "close", "x", ANCHOR_TOP_LEFT, {x = 612, y = 20, z = -10}, false, "Heading")
                
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
                DeleteControl("root", "throttle backdrop")
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
        
            SetControlText("throttle backdrop", "info" .. uid .. "1",
                "Max speed: " .. details.maxkmhr .. "km/hr   " .. details.maxmph .. " mph")
            SetControlText("throttle backdrop", "info" .. uid .. "2", details.kmhr .. " km/hr")
            SetControlText("throttle backdrop", "info" .. uid .. "3", details.mph .. " mph")
            SetControlText("throttle backdrop", "info" .. uid .. "4", "")
            SetControlText("throttle backdrop", "info" .. uid .. "5", "Gear: " .. details.gear)
            SetControlText("throttle backdrop", "info" .. uid .. "6", "Power: " .. details.power)
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