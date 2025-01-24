--WheelCollision.lua
--- forts script API ---


CollisionSubsteps = 2


data.roadNormalOfWheel = {}


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


            local result = PhysLib:CircleCollider(wheelPos, wheelRadius)
            local displacement = result.displacement
            
            local normal = result.normal
            -- if data.brakes[structureKey] then
            --     normal.x = 0
            -- end
            displacement = {x = displacement * normal.x, y = displacement * normal.y}

            if displacement.x == 0 and displacement.y == 0 then
                PreviousWheelPos[device.id] = WheelPos[device.id]
                WheelPos[device.id] = wheelPos
                continue
            end
            
            


            if ModDebug.collision then
                -- SpawnCircle(snapResultPos, 25, Blue(), 0.04)
                -- local secondPos = {x = snapResultPos.x + 75 * normal.x, y = snapResultPos.y + 75 * normal.y, z = 0}
                -- SpawnLine(snapResultPos, secondPos, Blue(), 0.04)
                -- SpawnCircle(secondPos, 75, Red(), 0.04)
            end


            local displacedPos = {x = wheelPosX + displacement.x, y = wheelPosY + displacement.y, z = 0}
            PreviousWheelPos[device.id] = WheelPos[device.id]
            WheelPos[device.id] = displacedPos
            local spring = WHEEL_SPRINGS[device.saveName]
            
            
            
            
            if result.nodeA then
                local firstNormal
                if not data.roadNormalOfWheel[device.id] then
                    data.roadNormalOfWheel[device.id] = {nodeA = result.nodeA, nodeB = result.nodeB, normal = normal}
                    firstNormal = data.roadNormalOfWheel[device.id].normal
                else
                    if data.roadNormalOfWheel[device.id].nodeA == result.nodeA and data.roadNormalOfWheel[device.id].nodeB == result.nodeB then
                        firstNormal = data.roadNormalOfWheel[device.id].normal
                    else
                        firstNormal = normal
                        data.roadNormalOfWheel[device.id] = {nodeA = result.nodeA, nodeB = result.nodeB, normal = firstNormal}
                    end
                end
                
                if normal.x * firstNormal.x + normal.y * firstNormal.y < 0 then
                    normal.x = -normal.x
                    normal.y = -normal.y
                    

                    local resultDisplacement = (wheelRadius - result.displacement + wheelRadius)
                    displacement = {x = resultDisplacement * normal.x, y = resultDisplacement * normal.y}

                    displacedPos.x = wheelPosX + displacement.x
                    displacedPos.y = wheelPosY + displacement.y
                end
                --local force = DirectionalDampening(spring.springConst, displacement, spring.dampening, AverageCoordinates({device.nodeVelA, device.nodeVelB, -NodeVelocity(result.nodeA), -NodeVelocity(result.nodeB)}), normal)
                local averageDeviceVelocity = AverageCoordinates({device.nodeVelA, device.nodeVelB})
                local averageNodeVelocity = AverageCoordinates({NodeVelocity(result.nodeA), NodeVelocity(result.nodeB)})

                local relativeVelocity = {x = averageDeviceVelocity.x / 2 - averageNodeVelocity.x / 2, y = averageDeviceVelocity.y / 2 - averageNodeVelocity.y / 2, z = 0}
                
                local force = DirectionalDampening(spring.springConst, displacement, spring.dampening, relativeVelocity, normal)
                if data.brakes[structureKey] then force.x = 0 end
                local negativeForce = {x = -force.x, y = -force.y, z = 0}
                ApplyForce(result.nodeA, negativeForce)
                ApplyForce(result.nodeB, negativeForce)
                ApplyForce(device.nodeA, force)
                ApplyForce(device.nodeB, force)
                WheelForces[structureKey][deviceKey] = force
            else
                data.roadNormalOfWheel[device.id] = nil
                local force = DirectionalDampening(spring.springConst, displacement, spring.dampening, AverageCoordinates({device.nodeVelA, device.nodeVelB}), normal)
                if data.brakes[structureKey] then force.x = 0 end
                ApplyForce(device.nodeA, force)
                ApplyForce(device.nodeB, force)
                WheelForces[structureKey][deviceKey] = force
            end

            WheelsTouchingGround[structureKey][deviceKey] = displacement
            
        end
    end
    Structures = structures
end

function CalculateNodeNormal(testPos, snapPos, terrainNormal)

    local snapResultPosXToWheelPosX = testPos.x - snapPos.x
    local snapResultPosYToWheelPosY = testPos.y - snapPos.y
    local magnitude = math.sqrt(snapResultPosXToWheelPosX * snapResultPosXToWheelPosX + snapResultPosYToWheelPosY * snapResultPosYToWheelPosY)
    local normal = {x = snapResultPosXToWheelPosX / magnitude, y = snapResultPosYToWheelPosY / magnitude, z = 0}


    if (terrainNormal.x * normal.x + terrainNormal.y * normal.y) < 0 then
        normal.x = -normal.x
        normal.y = -normal.y
    end


    return normal
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

