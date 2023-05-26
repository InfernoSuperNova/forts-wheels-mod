--- forts script API ---
-- propulsion.lua


-- Get list of devices grouped by structure
-- Get horizontal vector relative to device
-- Apply horizontal force based on sprite control
-- Place sprite control on base?
-- Also need to implement braking

-- Horizontal force applied to each wheel should be base force * engine count / wheel count



function InitializePropulsion()
    data.throttles = {}
    data.brakes = {}
    data.currentRevs = {}
    data.previousThrottleMags = {}
    
end
function UpdatePropulsion()
    LoopStructures()
    ClearOldStructures()

end





function UpdateThrottles(inx, iny, deviceStructureId)
    local pos = {x = inx, y = iny}
    data.throttles[deviceStructureId] = pos
end
function UpdateBrakes(state, structure)
    if state == 1 then
        data.brakes[structure] = true
    else
        data.brakes[structure] = false
    end
    
end
function LoopStructures()
    for structureKey, devices in pairs(Structures) do
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
            table.insert(velocities, NodeVelocity(device.nodeA))
            table.insert(velocities, NodeVelocity(device.nodeB))
        end
    end
    local velocity = AverageCoordinates(velocities)
    local velocityMag = VecMagnitudeDir(velocity)
    --now that we have the average velocity magnitude, we should select which gear should be used

    local currentGear = GetCurrentGearFromVelocity(applicableGears, velocityMag)

    

    ApplyPropulsionForces2(devices, structureKey, throttle, currentGear.propulsionFactor, currentGear.maxSpeed,
    velocity, velocityMag, propulsionFactor * 0.2)
end

function ApplyPropulsionForces2(devices, structureKey, throttle, propulsionFactor, maxSpeed, velocity, velocityMag, brakeFactor)
    if data.brakes[structureKey] == true then 
        for deviceKey, device in pairs(devices) do
            if data.wheelsTouchingGround[structureKey][deviceKey] then

                local signX = math.sign(velocity.x)
                local brakeVelocity = velocity.x * 0.01
                brakeVelocity = Clamp(brakeVelocity, -1, 1)
                FinalPropulsionForces[device] = {x = -brakeVelocity * brakeFactor, y = 0}
            end
        end
        return
    end
    
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
            data.currentRevs[structureKey] = (math.abs(velocityMag / maxSpeed) - 0.45) * 2
            mag = Clamp(mag, -1.0, 1.0)
            
            
            --get average between new magnitude and previous one to reduce vibrations
            if data.previousThrottleMags[structureKey] and data.previousThrottleMags[structureKey][deviceKey] then
                mag = (mag + data.previousThrottleMags[structureKey][deviceKey] * 4) / 5
            elseif not data.previousThrottleMags[structureKey] then data.previousThrottleMags[structureKey] = {} end
                
            data.previousThrottleMags[structureKey][deviceKey] = mag
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
