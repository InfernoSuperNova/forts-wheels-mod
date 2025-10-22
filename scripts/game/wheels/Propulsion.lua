--- forts script API ---
-- propulsion.lua



function InitializePropulsion()
    data.throttles = {}
    data.brakeSliders = {}
    data.brakes = {}
    data.currentRevs = {}
    data.previousThrottleMags = {}
    
end
function UpdatePropulsion()
    LoopStructures()
    ClearOldStructures()

end

function InitializeThrottleBrakeData(structureId)
    if not structureId then return end
    if not data.brakes[structureId] then data.brakes[structureId] = false end
    if not data.throttles[structureId] then data.throttles[structureId] = {x = 273.5, y = 15} end

end



--takes a value between -1 and 1
function UpdateThrottlesFromMapScript(structureId, val) 
    local normalizedVal = (val + 1) / 2
    local min = 33
    local max = 514
    local xVal = normalizedVal * (max - min) + min

    SendScriptEvent("UpdateThrottles", IgnoreDecimalPlaces(xVal, 3) .. "," .. 15 .. "," .. structureId, "", false)
end

function UpdateThrottles(inx, iny, deviceStructureId)
    local pos = {x = inx, y = iny}
    data.throttles[deviceStructureId] = pos
end

function UpdateBrakeSliders(inx, iny, deviceStructureId)
    local pos = {x = inx, y = iny}
    data.brakeSliders[deviceStructureId] = pos
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
            if WheelsTouchingGround[structureKey][deviceKey] then
                wheelTouchingGroundCount = wheelTouchingGroundCount + 1
            end
            wheelCount = wheelCount + 1
        end
        local motorCount = data.motors[structureKey] or 0
        --Gearboxes[structureKey] + 1 doesn't work if it's nil
        local gearboxCount = data.gearboxes[structureKey] or 0
        gearboxCount = gearboxCount + 3 -- Min 3 gears
        --max power input per wheels is 1 motor per 2 wheels
        

        
        
        local throttle = NormalizeThrottleVal(structureKey)
        if math.abs(throttle) < THROTTLE_DEADZONE then throttle = 0 end
        ApplyPropulsionForces(devices, structureKey, throttle, gearboxCount, wheelCount, wheelTouchingGroundCount, motorCount)
    end
    
    for key, structure in pairs(data.previousThrottleMags) do
        if not Structures[key] then
            data.previousThrottleMags[key] = nil
            data.currentRevs[key] = nil
            data.brakeSliders[key] = nil
        end
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
    local throttle = (data.throttles[structure].x - min) / ((max - min) / 2) - 1
    return math.max(math.min(throttle, 1), -1)
end

function NormalizeBrakeVal(structure)
    if not data.brakeSliders[structure] then return 0 end
    local min = 19
    local max = 226
    return (data.brakeSliders[structure].x - min) / ((max - min) / 2) / 2
end






function ApplyPropulsionForces(devices, structureKey, throttle, gearCount, wheelCount, wheelGroundCount, motorCount)
    
    
    --local propulsionFactor = math.min(PROPULSION_FACTOR * motorCount / wheelGroundCount, PROPULSION_FACTOR * maxPowerInputRatio)
    local propulsionFactor = PROPULSION_FACTOR * motorCount / wheelGroundCount
    local applicableGears = {}
    --sets up applicable gears for the structure

    local baseRatio = 1.35
    local wheelModifier = wheelCount
    for gear = 1, gearCount do
        local ratio = baseRatio ^ (gear - 1)
        applicableGears[gear] = {
            
            propulsionFactor = propulsionFactor / ratio * wheelModifier,
            maxSpeed = (ratio * VEL_PER_GEARBOX) / wheelModifier,
            netPropulsionFactor = PROPULSION_FACTOR * motorCount / ratio * wheelModifier,
            gear = gear,    
            ratio = ratio / wheelModifier,
        }

    end
    
    
    --get average velocity of every wheel
    local velocities = {}
    local velocitiesKeyed = {}
    local wheelsTouchingGroundCount = 0
    for deviceKey, device in pairs(devices) do
        if WheelsTouchingGround[structureKey][deviceKey] then
            wheelsTouchingGroundCount = wheelsTouchingGroundCount + 1
            local velNodeA = NodeVelocity(device.nodeA)
            local velNodeB = NodeVelocity(device.nodeB)
            table.insert(velocities, velNodeA) -- Todo, make unified device thing
            table.insert(velocities, velNodeB)
            velocitiesKeyed[deviceKey] = {velNodeA, velNodeB}
            
        end
    end
    local velocity = AverageCoordinates(velocities)
    local velocityMag = VecMagnitudeDir(velocity)

    
    
    -- --now that we have the average velocity magnitude, we should select which gear should be used

    local currentGear = GetCurrentGearFromVelocity(applicableGears, velocityMag)


    --BetterLog(currentGear.ratio)
    if not DrivechainDetails[structureKey] then DrivechainDetails[structureKey] = {} end
    if math.abs(velocityMag) > 0 then
        DrivechainDetails[structureKey][1] = velocityMag
    end
    DrivechainDetails[structureKey][2] = applicableGears[#applicableGears].maxSpeed or 0
    DrivechainDetails[structureKey][3] = currentGear.gear
    DrivechainDetails[structureKey][4] = currentGear.netPropulsionFactor
    DrivechainDetails[structureKey][5] = currentGear.ratio
    DrivechainDetails[structureKey][6] = PROPULSION_FACTOR * motorCount
    DrivechainDetails[structureKey][7] = throttle
    DrivechainDetails[structureKey][8] = gearCount
    ApplyPropulsionForces2(devices, structureKey, throttle, currentGear.propulsionFactor, currentGear.maxSpeed, velocityMag, velocitiesKeyed)
    for nodeId, force in pairs(FinalPropulsionForces) do
        ForceManager:ApplyForce(nodeId, force)
    end
    FinalPropulsionForces = {}
end

function ApplyPropulsionForces2(devices, structureKey, throttle, propulsionFactor, maxSpeed, velocityMag, velocitiesKeyed)
    if data.brakes[structureKey] == true then
        local brakeMul = 0.5 + NormalizeBrakeVal(structureKey) * 3 -- 0.5 to 3.5
    
        for deviceKey, device in pairs(devices) do
            if WheelsTouchingGround[structureKey][deviceKey] then
                local velocityThis = velocitiesKeyed[deviceKey]
                local vx = (velocityThis[1].x + velocityThis[2].x) / 2
                local absVx = math.abs(vx)
                local brakeFactor = WHEEL_BRAKE_FACTORS[device.saveName]
    
                local brakeVelocity = 0
    
                -- Parameters you can tweak
                local dynamicThreshold = 200   -- above this, use full braking
                local staticThreshold  = 0.001  -- below this, fully hold
    
                if absVx > dynamicThreshold then
                    local scaled = math.pow(math.tanh(absVx / 1000), 1.1)
                    brakeVelocity = vx * scaled
                    brakeVelocity = Clamp(brakeVelocity, -brakeMul, brakeMul)
                elseif absVx > staticThreshold then
                    local blend = (absVx - staticThreshold) / (dynamicThreshold - staticThreshold)
                    brakeVelocity = vx * blend * brakeMul / 10
                    brakeVelocity = Clamp(brakeVelocity, -brakeMul / 10, brakeMul / 10)
                else
                    brakeVelocity = 0
                end
    
                FinalPropulsionForces[device.nodeA] = Vec3(-brakeVelocity * brakeFactor, 0)
                FinalPropulsionForces[device.nodeB] = Vec3(-brakeVelocity * brakeFactor, 0)
            end
        end
        return
    end
    
    
    for deviceKey, device in pairs(devices) do
        if WheelsTouchingGround[structureKey][deviceKey] then
            local direction = PerpendicularVector(WheelsTouchingGround[structureKey][deviceKey])
            local direction = NormalizeVector(direction)
            local desiredVel = maxSpeed * math.sign(throttle)
            local maxPowerInputRatio = WHEEL_POWER_INPUT_RATIOS[device.saveName]
            local enginePower = math.min(propulsionFactor * math.abs(throttle), PROPULSION_FACTOR * maxPowerInputRatio)
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
                force = mag * enginePower * direction

            --left
            else
                force = -mag * enginePower * direction
            end
            FinalPropulsionForces[device.nodeA] = force
            FinalPropulsionForces[device.nodeB] = force
        end
    end
    local deviceCount = #devices
    if data.previousThrottleMags[structureKey] then
        for k, v in pairs(data.previousThrottleMags[structureKey]) do
            if k > deviceCount then
                data.previousThrottleMags[structureKey][k] = nil
            end
        end
    end
    --ShallowLogTable(data.previousThrottleMags)
end

function GetCurrentGearFromVelocity(applicableGears, velocityMag)

    local currentGear
    for gear = 1, #applicableGears do
        if math.abs(velocityMag) < applicableGears[gear].maxSpeed * GEAR_CHANGE_RATIO then
            currentGear = applicableGears[gear]
            break
        end
    end
    if currentGear == nil then 
        currentGear = applicableGears[#applicableGears] 
    end
    return currentGear
end
