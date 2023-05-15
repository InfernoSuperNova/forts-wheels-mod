--- forts script API ---
-- propulsion.lua


-- Get list of devices grouped by structure
-- Get horizontal vector relative to device
-- Apply horizontal force based on sprite control
-- Place sprite control on base?
-- Also need to implement braking

-- Horizontal force applied to each wheel should be base force * engine count / wheel count

--engine power
local PROPULSION_FACTOR = 2500000
--how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
local MAX_POWER_INPUT_RATIO = 1
--velocity per engine, in grid units per sec
local VEL_PER_GEARBOX = 800

local GEAR_CHANGE_RATIO = 0.95

local THROTTLE_DEADZONE = 0.1
EngineSaveName = "engine_wep"

ControllerSaveName = "engine_wep"

GearboxSaveName = "gearbox"
Motors = {}
Gearboxes = {}

function InitializePropulsion()
    data.throttles = {}
    data.currentRevs = {}
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
    local teamId = GetLocalTeamId()
        --If the controller device is selected
        if GetDeviceType(selectedDevice) == ControllerSaveName and IsDeviceFullyBuilt(selectedDevice) and (GetDeviceTeamIdActual(selectedDevice) == teamId) then
            --if it doesn't exist in it's current instance, create it
            if not ControlExists("root", "PropulsionSlider") then
                SetControlFrame(0)
                LoadControl(path .. "/ui/controls.lua", "root")
                AddTextControl("", tostring(teamId), "Gear: ", ANCHOR_CENTER_CENTER, {x = 520, y = 460}, false, "normal")
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
                DeleteControl("root", tostring(teamId))
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
        

        
        
        local throttle = NormalizeThrottleVal(structureKey)
        if math.abs(throttle) < THROTTLE_DEADZONE then throttle = 0 end
        ApplyPropulsionForces(devices, structureKey, throttle, gearboxCount, wheelCount, wheelTouchingGroundCount, motorCount)
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





function ApplyPropulsionForces(devices, structureKey, throttle, gearCount, wheelCount, wheelGroundCount, motorCount)
    
    
    local propulsionFactor = math.min(PROPULSION_FACTOR * motorCount / wheelGroundCount, PROPULSION_FACTOR * MAX_POWER_INPUT_RATIO)
    local applicableGears = {}
    --sets up applicable gears for the structure
    for gear = 1, gearCount do
        local gearFactor = 2 ^ (gear - 1)
        applicableGears[gear] = {
            
            propulsionFactor = propulsionFactor / gearFactor,
            maxSpeed = (gearFactor * VEL_PER_GEARBOX)^0.975/wheelCount/wheelCount^0.01,

            
        }

    end
    
    
    --get average velocity of every wheel
    local velocities = {}
    for deviceKey, device in pairs(devices) do
        if data.wheelsTouchingGround[structureKey][deviceKey] then
            local nodeA = GetDevicePlatformA(device)
            local nodeB = GetDevicePlatformB(device)
            table.insert(velocities, NodeVelocity(nodeA))
            table.insert(velocities, NodeVelocity(nodeB))
        end
    end
    local velocity = AverageCoordinates(velocities)
    local velocityMag = VecMagnitudeDir(velocity)
    --now that we have the average velocity magnitude, we should select which gear should be used


    local currentGear = GetCurrentGearFromVelocity(applicableGears, velocityMag)

    

    ApplyPropulsionForces2(devices, structureKey, throttle, currentGear.propulsionFactor, currentGear.maxSpeed,
    velocityMag)
end

function ApplyPropulsionForces2(devices, structureKey, throttle, propulsionFactor, maxSpeed, velocityMag)
    for deviceKey, device in pairs(devices) do
        if data.wheelsTouchingGround[structureKey][deviceKey] then
            local direction = PerpendicularVector(data.wheelsTouchingGround[structureKey][deviceKey])
            local direction = NormalizeVector(direction)
            local desiredVel = maxSpeed * math.sign(throttle)
            local enginePower = propulsionFactor * math.abs(throttle)
            local deltaVel = desiredVel - velocityMag
            --somewhere here, plug in a cutoff so that it only starts falling off after 0.95
            local mag = 1
            if desiredVel ~= 0 then
                --*20 effectively eliminates falloff until it reaches 0.95
                mag = deltaVel * 20 / desiredVel
            else
                mag = 0
            end 
            data.currentRevs[structureKey] = math.abs(velocityMag / maxSpeed)
            mag = Clamp(mag, -1.0, 1.0)
            
            
            --get average between new magnitude and previous one to reduce vibrations
            if data.previousThrottleMags[structureKey] and data.previousThrottleMags[structureKey][deviceKey] then
                mag = (mag + data.previousThrottleMags[structureKey][deviceKey] * 4) / 5
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

function GetCurrentGearFromVelocity(applicableGears, velocityMag)

    local currentGear
    for gear = 1, #applicableGears do
        if math.abs(velocityMag) < applicableGears[gear].maxSpeed * GEAR_CHANGE_RATIO then
            currentGear = applicableGears[gear]
            SetControlText("root", tostring(GetLocalTeamId()), "Gear: " .. gear)
            break
        end
    end
    if currentGear == nil then 
        currentGear = applicableGears[#applicableGears] 
        SetControlText("root", tostring(GetLocalTeamId()), "Gear: " .. #applicableGears)
    end
    return currentGear
end
