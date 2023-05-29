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
end



function ThrottleControl()
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
                LoadControl(path .. "/ui/controls.lua", "root")
                --AddTextControl("", tostring(teamId), "Gear: ", ANCHOR_CENTER_CENTER, {x = 520, y = 460}, false, "normal")
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
            --Get the pos from the slider
            local pos = GetControlRelativePos("PropulsionSlider", "SliderBar")
            --send the pos to the throttles table
            if ControlExists("root", "PropulsionSlider") then
                SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(pos.x, 3) .. "," .. pos.y .. "," .. deviceStructureId, "", false)
            end
            if ControlExists("root", "brake") then
                UpdateBrakeButton(deviceStructureId)
            end
        else
            --once done with throttle widget, delete it
            if ControlExists("root", "PropulsionSlider") then
                DeleteControl("root", "PropulsionSlider")
                DeleteControl("root", tostring(teamId))
                DeleteControl("root", "brake")
            end
        end
end

function CreateBrakeButton(deviceStructureId)
    AddTextButtonControl("", "brake", "Brakes: Off", ANCHOR_CENTER_CENTER, {x = 520, y = 460}, false, "normal")
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