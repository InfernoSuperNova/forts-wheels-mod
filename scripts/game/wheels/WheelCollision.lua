--WheelCollision.lua
--- forts script API ---




--Master wheel collision handling function. 
function WheelCollisionHandler()
    Displacement = {}
    WheelsTouchingGround = {}
    WheelForces = {}
    local structures = GetDeviceStructureGroups()

    --section off into structures
    for structureKey, devices in pairs(structures) do
        for deviceKey, device in pairs(devices) do
            if not WheelsTouchingGround[structureKey] then WheelsTouchingGround[structureKey] = {} WheelForces[structureKey] = {} end
            local wheelStats = GetWheelStats(device)
            local wheelRadius = wheelStats.radius + TRACK_WIDTH
            local wheelPos = wheelStats.pos
            local wheelPosX = wheelPos.x
            local wheelPosY = wheelPos.y
            local snapResult = SnapToWorld(wheelPos, wheelRadius, SNAP_GROUND, -1, -1, "")

            

            local snapResultPos = snapResult.Position
            local snapResultPosX = snapResultPos.x
            local snapResultPosY = snapResultPos.y
            if SpecialTerrain.ignored[snapResult.BlockIndex] or snapResult.BlockVertexIndex == -1 then
                --unfortunately, this means that only background terrain can be ignored
                snapResult = SnapToWorld(wheelPos, wheelRadius, SNAP_GROUND_FORE, -1, -1, "")
                snapResultPos = snapResult.Position
                snapResultPosX = snapResultPos.x
                snapResultPosY = snapResultPos.y
            end


            if snapResult.Position.x == wheelPosX and snapResult.Position.y == wheelPosY then
                PreviousWheelPos[device.id] = WheelPos[device.id]
                WheelPos[device.id] = wheelPos
                continue
            end
            
            local snapResultPosXToWheelPosX = snapResultPosX - wheelPosX
            local snapResultPosYToWheelPosY = snapResultPosY - wheelPosY
            local magnitude = math.sqrt(snapResultPosXToWheelPosX * snapResultPosXToWheelPosX + snapResultPosYToWheelPosY * snapResultPosYToWheelPosY)
            local normal = {x = snapResultPosXToWheelPosX / magnitude, y = snapResultPosYToWheelPosY / magnitude, z = 0}
            local snapResultNormal = snapResult.Normal
            local snapResultNormalX = snapResultNormal.x
            local snapResultNormalY = snapResultNormal.y
            normal.x = math.abs(normal.x) * math.sign(snapResultNormalX)
            normal.y = math.abs(normal.y) * math.sign(snapResultNormalY)
            if data.brakes[structureKey] then
                normal.x = 0
                normal.y = -1
                snapResultPosX = wheelPosX
            end

            if ModDebug.collision then
                SpawnCircle(snapResultPos, 25, Blue(), 0.04)
                local secondPos = {x = snapResultPos.x + 75 * normal.x, y = snapResultPos.y + 75 * normal.y, z = 0}
                SpawnLine(snapResultPos, secondPos, Blue(), 0.04)
                SpawnCircle(secondPos, 75, Red(), 0.04)
            end


            local displacedPos = {x = snapResultPosX + wheelRadius * normal.x, y = snapResultPosY + wheelRadius * normal.y, z = 0}
            PreviousWheelPos[device.id] = WheelPos[device.id]
            WheelPos[device.id] = displacedPos
            local displacementX = displacedPos.x - wheelPosX
            local displacementY = displacedPos.y - wheelPosY
            local displacement = {x = displacementX, y = displacementY, z = 0}
            local spring = WHEEL_SPRINGS[device.saveName]
            
            local force = DirectionalDampening(spring.springConst, displacement, spring.dampening, AverageCoordinates({device.nodeVelA, device.nodeVelB}), normal)
            ApplyForce(device.nodeA, force)
            ApplyForce(device.nodeB, force)
            WheelsTouchingGround[structureKey][deviceKey] = displacement
            WheelForces[structureKey][deviceKey] = force
        end
    end
    Structures = structures
end
--Gets a table of structures, each structure being a "group" of wheel devices
function GetDeviceStructureGroups()
    local structures = {}
    for _, device in pairs(data.devices) do
        if WHEEL_SAVE_NAMES_RAW[device.saveName] and IsDeviceFullyBuilt(device.id) then
            local structureId = device.strucId
            if not structures[structureId] then structures[structureId] = {} end
            table.insert(structures[structureId], device)
        end
    end
    return structures
end

function GetOffsetDevicePos(device, offset)

    local offsetPos = OffsetPerpendicular(device.nodePosA, device.nodePosB, offset)
    local newPos = offsetPos + device.pos
    return newPos
end

function DirectionalDampening(springConst, displacement, dampening, velocity, surfacePerpVector)
    local velocityX = velocity.x
    local velocityY = velocity.y
    local surfacePerpVectorX = surfacePerpVector.x
    local surfacePerpVectorY = surfacePerpVector.y
    local displacementX = displacement.x
    local displacementY = displacement.y
    local velocityPerpToSurface = velocityX * surfacePerpVectorX + velocityY * surfacePerpVectorY
    local forceX = springConst * displacementX - dampening * velocityPerpToSurface * surfacePerpVectorX
    local forceY = springConst * displacementY - dampening * velocityPerpToSurface * surfacePerpVectorY
    
    return {x = forceX, y = forceY, z = 0}
end

--A cool helper function I sotle from landcroozers 2
function IsWithinDistance(vector1, vector2, distance)
    local dx = vector1.x - vector2.x
    local dy = vector1.y - vector2.y
    local distanceSquared = dx * dx + dy * dy
    local givenDistanceSquared = distance * distance

    return distanceSquared <= givenDistanceSquared
end

