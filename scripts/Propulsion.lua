--- forts script API ---
-- propulsion.lua


-- Get list of devices grouped by structure
-- Get horizontal vector relative to device
-- Apply horizontal force based on sprite control
-- Place sprite control on base?
-- Also need to implement braking

-- Horizontal force applied to each wheel should be base force * engine count / wheel count

--engine power
local PROPULSION_FACTOR = 6000000
--how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
local MAX_POWER_INPUT_RATIO = 1
--velocity per engine, in grid units per sec
local VEL_PER_GEARBOX = 1500


EngineSaveName = "engine_wep"

ControllerSaveName = "engine_wep"

GearboxSaveName = "gearbox"
Motors = {}
Gearboxes = {}

function InitializePropulsion()
    data.throttles = {}
    data.previousThrottleMags = {}
    
end
function UpdatePropulsion()
    Motors = {}
    Gearboxes ={}
    IndexDevices()
    LoopStructures()
    ThrottleControl()
    ClearOldStructures()


end



function ThrottleControl()
    local selectedDevice = GetLocalSelectedDeviceId()
    local deviceStructureId = -1
    if selectedDevice ~= -1 then
         -- Getting structure ID directly from device maybe sometimes give wrong value, this is a workaround
        deviceStructureId = NodeStructureId(GetDevicePlatformA(selectedDevice))
    end
        --If the controller device is selected
        if GetDeviceType(selectedDevice) == ControllerSaveName and IsDeviceFullyBuilt(selectedDevice) and (GetDeviceTeamIdActual(selectedDevice) == GetLocalTeamId()) then
            --if it doesn't exist in it's current instance, create it
            if not ControlExists("root", "PropulsionSlider") then
                SetControlFrame(0)
                LoadControl(path .. "/ui/controls.lua", "root")
                
                --initialize throttle
                local pos = {x = 273.5, y = 15}
                --if the structure doesn't already have a throttle, create it
                if not data.throttles[deviceStructureId] then
                    if ControlExists("root", "PropulsionSlider") then
                        SendScriptEvent("UpdateThrottles", pos.x .. "," .. pos.y .. "," .. deviceStructureId, "", false)
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
                SendScriptEvent("UpdateThrottles", pos.x .. "," .. pos.y .. "," .. deviceStructureId, "", false)
            end
        else
            --once done with throttle widget, delete it
            if ControlExists("root", "PropulsionSlider") then
                DeleteControl("root", "PropulsionSlider")
            end
        end
end

function UpdateThrottles(inx, iny, deviceStructureId)
    local pos = {x = inx, y = iny}
    data.throttles[deviceStructureId] = pos
end
function LoopStructures()
    
    for structureKey, devices in pairs(data.structures) do
        local wheelCount = 0
        local wheelTouchingGroundCount = 0
        for deviceKey, device in pairs(devices) do
            if data.wheelsTouchingGround[structureKey][deviceKey] then
                wheelTouchingGroundCount = wheelTouchingGroundCount + 1
            end
            wheelCount = wheelCount + 1
        end
        local motorCount = Motors[structureKey] or 0
        --Gearboxes[structureKey] + 1 doesn't work if it's nil
        local gearboxCount = Gearboxes[structureKey] or 0
        gearboxCount = gearboxCount + 1
        --max power input per wheels is 1 motor per 2 wheels
        local propulsionFactor = math.min(PROPULSION_FACTOR * motorCount / wheelTouchingGroundCount, PROPULSION_FACTOR * MAX_POWER_INPUT_RATIO)

        propulsionFactor = propulsionFactor / gearboxCount

        
        local maxSpeed = (gearboxCount*VEL_PER_GEARBOX)^0.975/wheelCount/wheelCount^0.01
        local throttle = NormalizeThrottleVal(structureKey)

        ApplyPropulsionForces(devices, structureKey, propulsionFactor, throttle, maxSpeed)
    end
end

function ClearOldStructures()
    for structure, value in pairs(data.throttles) do
        local result = GetStructureTeam(structure) % MAX_SIDES

        if result ~= 1 and result ~= 2 then
            data.throttles[structure] = nil
        end
    end
end


function NormalizeThrottleVal(structure)

    if not data.throttles[structure] then return 0 end
    local min = 33
    local max = 514
    return (data.throttles[structure].x - min) / ((max - min) / 2) - 1
end

function IndexDevices()
    for side = 1, 2 do
        local count = GetDeviceCountSide(side)
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            local structureId = GetDeviceStructureId(id)
            if IsDeviceFullyBuilt(id) then
                if  GetDeviceType(id) == GearboxSaveName then
                    if not Gearboxes[structureId] then 
                        Gearboxes[structureId] = 1 
                    else
                        Gearboxes[structureId] = Gearboxes[structureId] + 1
                    end
                elseif  GetDeviceType(id) == EngineSaveName then
                    if not Motors[structureId] then 
                        Motors[structureId] = 1 
                    else
                        Motors[structureId] = Motors[structureId] + 1
                    end
                end
            end
            
        end
    end
end





function ApplyPropulsionForces(devices, structureKey, enginePower, throttle, maxSpeed)
    for deviceKey, device in pairs(devices) do
        if data.wheelsTouchingGround[structureKey][deviceKey] then
            local nodeA = GetDevicePlatformA(device)
            local nodeB = GetDevicePlatformB(device)
            local velocity = AverageCoordinates({NodeVelocity(nodeA), NodeVelocity(nodeB)})
            local velocityMag = VecMagnitudeDir(velocity)
            local direction = PerpendicularVector(data.wheelsTouchingGround[structureKey][deviceKey])
            local direction = NormalizeVector(direction)
            local desiredVel = maxSpeed * math.sign(throttle)
            enginePower = enginePower * math.abs(throttle)

            local deltaVel = desiredVel - velocityMag
            local mag = 1
            if desiredVel ~= 0 then
                mag = deltaVel / desiredVel
            else
                mag = 0
            end 
            mag = Clamp(mag, -1.1, 1.1)
            --get average between new magnitude and previous one to reduce vibrations
            if data.previousThrottleMags[structureKey] and data.previousThrottleMags[structureKey][deviceKey] then
                mag = (mag + data.previousThrottleMags[structureKey][deviceKey]) / 2
            elseif not data.previousThrottleMags[structureKey] then data.previousThrottleMags[structureKey] = {} end
                
            
            data.previousThrottleMags[structureKey][deviceKey] = mag
            --if our velocity is 50, and our desired is -500
            --delta is -550
            --this produces a magnitude of 1.1
            --if our velocity is 0, and our desired is -500
            --delta is -550
            local force
            --right
            if desiredVel > 0 then
                force = {x = direction.x * mag * enginePower, y = direction.y * mag * enginePower}

            --left
            else
                force = {x = direction.x * -mag * enginePower, y = direction.y * -mag * enginePower}
            end
            FinalPropulsionForces[device] = force
        end
    end
end

