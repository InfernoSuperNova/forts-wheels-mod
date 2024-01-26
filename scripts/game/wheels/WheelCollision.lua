--WheelCollision.lua
--- forts script API ---




--Master wheel collision handling function. 
function WheelCollisionHandler()
    Displacement = {}
    data.wheelsTouchingGround = {}
    local structures = GetDeviceStructureGroups()


    --section off into structures

    for structureKey, devices in pairs(structures) do
        local collisions = CheckBoundingCircleCollisions(devices)

        for deviceKey, device in pairs(devices) do
            local displacement = CheckCollisionWheelOnSegment(device, collisions.simplifiedBlocks, collisions.blockSegmentsToDo, collisions.structures, structureKey)
            if math.pow(displacement.x, 2) + math.pow(displacement.y, 2) > 0 then
                StoreFinalDisplacement(device, displacement, structureKey)
            end
            
            if not data.wheelsTouchingGround[structureKey] then data.wheelsTouchingGround[structureKey] = {} end



            if displacement then
                data.wheelsTouchingGround[structureKey][deviceKey] = displacement
            end
        end
    end
    Structures = structures
    CalculateFinalForce()
end
--Gets a table of structures, each structure being a "group" of wheel devices
function GetDeviceStructureGroups()
    local structures = {}
    for _, device in pairs(data.devices) do
        if (CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.small) 
        or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.medium) 
        or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.large)
        or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.extraLarge))
        and IsDeviceFullyBuilt(device.id) then
            local structureId = device.strucId
            if not structures[structureId] then structures[structureId] = {} end
            table.insert(structures[structureId], device)
        end
    end
    return structures
end
--Creates a collider around the wheels

--Gets a bounding circle for a wheel group
function GetWheelBoundingCircle(devices)
    local positions = {}

    --assign the position of each wheel into the respective key in the positions table
    for k, device in pairs(devices) do
        local wheelStats = GetWheelStats(device)
        positions[k] = wheelStats.pos
    end
    --Get the minimum circular boundary, and add necessary padding
    local collider = MinimumCircularBoundary(positions)
    collider.r = collider.r + WHEEL_RADIUSES.extraLarge + TRACK_WIDTH 
    --debug stuff
    if ModDebug.collision == true then
        local colour1 = {r = 100, g = 255, b = 100, a = 255}
        local colour2 = {r = 0, g = 255, b = 200, a = 255}
        local colour3 = {r = 100, g = 200, b = 255, a = 255}
        collider.z = -100
        SpawnCircle(collider, collider.r, colour2, 0.04)
        HighlightPolygon(collider.square, colour1)
        HighlightPolygon(positions, colour3)
    end
    return collider
end

--Checks if the wheel bounding circle collides with any terrain or structure/road bounding circles
function CheckBoundingCircleCollisions(devices)
    local wheelBC = GetWheelBoundingCircle(devices)
    local collidingBlocks = {}
    local simplifiedBlocks = {}
    local blockSegmentsToDo = {}
    local collidingStructures = {}
    --Check collisions with terrain, set the collidingBlocks table key with the terrain id to true if colliding
    for terrainId, terrainBC in pairs(data.terrainCollisionBoxes) do
        if IsWithinDistance(wheelBC, terrainBC, wheelBC.r + terrainBC.r + 50) then
            collidingBlocks[terrainId] = true
        end
    end
    for terrainId = 1, GetHighestIndex(Terrain) do
        local terrain = Terrain[terrainId]

        local doSegments = {}
        local newSpecialBlock = {}
        --Looping through all colliding blocks...
        if collidingBlocks[terrainId] then
            -- for _, corner in pairs(TerrainCorners[terrainId]) do
            --     if not collidingNodes[terrainId] then collidingNodes[terrainId] = {} end
            --     collidingNodes[terrainId][corner] = true
            -- end
            --looping through all segments in the block
            for segmentId = 1   , #terrain do
                local pointA = terrain[segmentId]
                local pointB = terrain[segmentId % #terrain + 1]
                local segmentLength = Distance(pointA, pointB)
                local segmentBC = {
                    x = (pointA.x + pointB.x) / 2,
                    y = (pointA.y + pointB.y) / 2,
                    r = segmentLength / 2
                }
                if IsWithinDistance(wheelBC, segmentBC, wheelBC.r + segmentBC.r) then
                    doSegments[(segmentId - 2) % #terrain + 1] = true
                    doSegments[segmentId] = true
                    doSegments[segmentId % #terrain + 1] = true
                    doSegments[(segmentId + 2 - 1) % #terrain + 1] = true

                    --check if the block contains the prev node
                end
            end
            table.insert(simplifiedBlocks, terrain)
            table.insert(blockSegmentsToDo, doSegments)
        end

        --simplify 
        if ModDebug.collision then 
            for _, block in pairs(simplifiedBlocks) do
                HighlightPolygonWithDisplacement(block, {x = 0, y = -2500}, {r = 255, g = 255, b = 255, a = 255})
                HighlightCoordsTextWithDisplacement(block, {x = 0, y = -2500}, {r = 255, g = 255, b = 255, a = 255})
            end
        end
    end
    
    --Check collisions with structures, set the collidingStructures table key with the structure id to true if colliding
    for structureId, roadBC in pairs(RoadStructureBoundaries) do
        if IsWithinDistance(wheelBC, roadBC, wheelBC.r + roadBC.r + 50) then
            
            collidingStructures[structureId] = true
        end
    end
    return {blocks = collidingBlocks, structures = collidingStructures, simplifiedBlocks = simplifiedBlocks, blockSegmentsToDo = blockSegmentsToDo}
end

--Lowest level collision checks, checks a wheel against a line segment (could be a terrain segment or a road segment)
function CheckCollisionWheelOnSegment(device, collidingBlocks, blockSegmentsToDo, collidingStructures, structureId)
    local returnVal = { x = 0, y = 0 }
    local wheelStats = GetWheelStats(device)
    
    WheelPos[device.id] = wheelStats.pos
    --looping through blocks
    returnVal = CheckCollisionWheelOnTerrain(device, wheelStats, collidingBlocks, blockSegmentsToDo, structureId, returnVal)
    returnVal = CheckCollisionWheelOnRoad(collidingStructures, wheelStats, device, returnVal, structureId)
    
    if returnVal then
        return returnVal
    end
    
end

--Checks a wheel against a terrain block
function CheckCollisionWheelOnTerrain(device, wheelStats, collidingBlocks, blockSegmentsToDo, structureId, prevDisplacement)
    --Assign returnVal to prevDisplacement for the first iteration
    local returnVal = prevDisplacement
    local displacement
    for blockIndex, Nodes in pairs(collidingBlocks) do


        local toDo = blockSegmentsToDo[blockIndex]
        --resolve a list of segments to check collisions on
        local newTerrain = {}
        local yes = {}
        for segment = 1, #Nodes do
            if not toDo[segment] then continue end
            if segment > segment % #Nodes + 1 then continue end
            local pointA = Nodes[segment]
            local pointB = Nodes[segment % #Nodes + 1 ]
            pointA.z = -100
            pointB.z = -100
            local segmentLength = Distance(pointA, pointB)
            local segmentBC = {
                x = (pointA.x + pointB.x) / 2,
                y = (pointA.y + pointB.y) / 2,
                r = segmentLength / 2
            }
            if IsWithinDistance(wheelStats.pos, segmentBC, wheelStats.radius + TRACK_WIDTH * 2 + segmentBC.r) then
                yes[(segment - 2) % #Nodes + 1] = true
                yes[segment] = true
                yes[segment % #Nodes + 1] = true
                yes[(segment + 2 - 1) % #Nodes + 1] = true
            end
        end

        for id, pos in pairs(Nodes) do
            if yes[id] then
                table.insert(newTerrain, pos)
            end
        end
        displacement = CheckCollisionsOnBlock(newTerrain, wheelStats.pos, wheelStats.radius + TRACK_WIDTH)

        
        SendDisplacementToTracks(displacement, device)
        if displacement and displacement.y ~= 0 then
            
            
            if math.abs(returnVal.y) < math.abs(displacement.y) then
                returnVal = { x = displacement.x, y = displacement.y }
            end
        end
    end
    return returnVal
end

function CheckCollisionsOnBlock(terrain, pos, radius)
    --Fix for single node blocks
    if #terrain < 2 then
        return Vec3(0,0)
    end
    local newPos = pos
        local perpendicularVector = CirclePolygonCollision(pos, radius, terrain)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * -radius,
                y = pos.y + perpendicularVector.y * -radius
            }
        end
        return { x = newPos.x - pos.x, y = newPos.y - pos.y }
end

-- Check if a circle is colliding with a polygon.
function CirclePolygonCollision(circleCenter, WHEEL_RADIUS, polygon)

    --Centerpoint in polygon
    local obj = FindClosestEdge(circleCenter, polygon)
    local edge = SubtractVectors(obj.closestEdge.edgeEnd, obj.closestEdge.edgeStart)
    obj.closestEdge.edgeStart.z = -100
    obj.closestEdge.edgeEnd.z = -100
    if ModDebug.collision then
        SpawnCircle(AverageCoordinates({obj.closestEdge.edgeStart, circleCenter}), Distance(circleCenter, obj.closestEdge.edgeStart) / 2, {r = 255, g = 0, b = 0, a = 255}, 0.04)
        SpawnCircle(AverageCoordinates({obj.closestEdge.edgeEnd, circleCenter}), Distance(circleCenter, obj.closestEdge.edgeEnd) / 2, {r = 0, g = 255, b = 0, a = 255}, 0.04)
    end
    
    local edgeToWheelA = SubtractVectors(circleCenter, obj.closestEdge.edgeEnd)
    local edgeToWheelB = SubtractVectors(circleCenter, obj.closestEdge.edgeStart)
    local sideOfEdge = CrossProduct(edge, edgeToWheelA) + CrossProduct(edge, edgeToWheelB)
    local final = CalculateCollisionResponseVector(obj.closestDistance * -math.sign(sideOfEdge), obj.closestEdge.edgeStart,
        obj.closestEdge.edgeEnd,
        WHEEL_RADIUS)
    if final then return final end
    --Centerpoint out of polygon
    -- If there is no collision, return nil.
    return nil
end

--Checks a wheel against a set of roads on a base
function CheckCollisionWheelOnRoad(collidingStructures, wheelStats, device, prevDisplacement, structureId)
    local returnVal = prevDisplacement
    local displacement = prevDisplacement

    for structure, _ in pairs(collidingStructures) do
        local roadCollider = RoadStructureBoundaries[structure]
        if not IsWithinDistance(roadCollider, wheelStats.pos, roadCollider.r + wheelStats.radius) then
            continue
        end

        local links = RoadStructures[structure]
        for index, link in pairs(links) do
            local newLink = {RoadCoords[structure][index * 2 - 1], RoadCoords[structure][index * 2]}
            local uid = device.id .. "_" .. index * 2 - 1 .. "_" .. index * 2
            --First do a check to see if the wheel collider is within the road segment's bounding circle
            local roadLength = Distance(newLink[1], newLink[2])
            local roadBC = {
                x = (newLink[1].x + newLink[2].x) / 2,
                y = (newLink[1].y + newLink[2].y) / 2,
                r = roadLength / 2
            }
            if not IsWithinDistance(roadBC, wheelStats.pos, roadBC.r + wheelStats.radius) then
                continue
            end
            displacement = CheckCollisionsOnBrace(newLink, wheelStats.pos, wheelStats.radius + TRACK_WIDTH, uid)
            SendDisplacementToTracks(displacement, device)
            if displacement == nil then --incase of degenerate blocks
                displacement = Vec3(0,0)
            end

            local averageVel = AverageSpringDampening(device.nodeVelA, device.nodeVelB, NodeVelocity(link.nodeA), NodeVelocity(link.nodeB))
            local roadVel = AverageCoordinates({device.nodeVelA, device.nodeVelB})
            roadVel = Vec3(roadVel.x, roadVel.y)
            -- if wheelStats.inverted then
            --     roadVel.x = -roadVel.x
            -- end
            roadVel.y = -roadVel.y
            AccumulateForceOnRoad(link.nodeA, link.nodeB, displacement, roadVel)
            
            
            if displacement and displacement.y ~= 0 then

                StoreFinalDisplacement(device, displacement, structureId, averageVel)
    
                if math.abs(returnVal.y) < math.abs(displacement.y) then
                    returnVal = { x = displacement.x, y = displacement.y }
                end
            end
        end
    end
    return returnVal
end

function GetRelativeVelocity(velA, velB)
    return {
        x = velA.x - velB.x,
        y = velA.y - velB.y
    }
end
function AverageSpringDampening(nodeA, nodeB, nodeC, nodeD)
    local vel1 = AverageCoordinates({ nodeA, nodeB })
    local vel2 = AverageCoordinates({ nodeC, nodeD })
    return {
        x = (vel1.x - vel2.x) / 4,
        y = (vel1.y - vel2.y) / 4,
    }
    --return AverageCoordinates({ vel1, vel2 })
end

function GetOffsetDevicePos(device, offset)

    local offsetPos = OffsetPerpendicular(device.nodePosA, device.nodePosB, offset)
    local newPos = {
        x = offsetPos.x + device.pos.x,
        y = offsetPos.y + device.pos.y
    }
    return newPos
end


function SendDisplacementToTracks(displacement, device)
    if not Displacement[device.id] then
        Displacement[device.id] = displacement
    else
        --set displacement to largest among all blocks
        if math.abs(Displacement[device.id].y) < math.abs(displacement.y) then
            Displacement[device.id] = DeepCopy(displacement)
        end
    end
end
FinalDisplacement = {}
function StoreFinalDisplacement(device, displacement, structureId, velocity)
    FinalDisplacement[device.id] = {displacement = displacement, device = device, structureId = structureId, velocity = velocity}
end
function CalculateFinalForce()
    for id, wheel in pairs(FinalDisplacement) do
        if ModDebug.forces then
            HighlightDirectionalVector(wheel.device.nodePosA, wheel.displacement, 3, {r = 100, g = 255, b = 100, a = 255})
            HighlightDirectionalVector(wheel.device.nodePosB, wheel.displacement, 3, {r = 100, g = 255, b = 100, a = 255})
        end
        if data.brakes[wheel.structureId] == true then wheel.displacement.x = 0 end
        local surfaceNormal = NormalizeVector(wheel.displacement)
        
        --Calculate torque that the wheel would produce on the strut from it's offset position, so that struts with only a single wheel and no other structure attached fall over
        
        local torque
        if Gravity == 0 then
            torque = CalculateTorqueSpherical(wheel.device, surfaceNormal)
        else
            torque = CalculateTorque(wheel.device)
        end
        
        local DampenedForce = DampenFinalForce(wheel.velocity, wheel.displacement, surfaceNormal, torque, wheel.device)

        FinalSuspensionForces[wheel.device.id] = DampenedForce
    end
    FinalDisplacement = {}
    
end

function CalculateTorque(device)

    local strutVector = NormalizeVector({x = device.nodePosA.x - device.nodePosB.x, y = device.nodePosA.y - device.nodePosB.y})
    local torqueDir = math.sign(strutVector.x * strutVector.y)
    local torqueForce = math.abs(strutVector.y) * torqueDir * TORQUE_MUL
    local torqueForceVector = PerpendicularVector(strutVector)
    local temp = {x = torqueForceVector.x * torqueForce, y = torqueForceVector.y * torqueForce}
    if ModDebug.forces then
        HighlightDirectionalVector(device.nodePosA, temp, 10, {r = 50, g = 100, b = 255, a = 255})
        HighlightDirectionalVector(device.nodePosB, {x = -temp.x, y = -temp.y}, 10, {r = 50, g = 100, b = 255, a = 255})
    end
    return temp
    

end

function CalculateTorqueSpherical(device, surfacePerpVector)
    local surfaceVector = PerpendicularVector(surfacePerpVector)
    local strutVector = NormalizeVector({x = device.nodePosA.x - device.nodePosB.x, y = device.nodePosA.y - device.nodePosB.y})
    local force = CrossProduct(strutVector, surfaceVector) * TORQUE_MUL
    local torqueForceVector = PerpendicularVector(strutVector)
    local temp = {x = torqueForceVector.x * force, y = torqueForceVector.y * force}
    if ModDebug.forces then
        HighlightDirectionalVector(device.nodePosA, temp, 10, {r = 50, g = 100, b = 255, a = 255})
        HighlightDirectionalVector(device.nodePosB, {x = -temp.x, y = -temp.y}, 10, {r = 50, g = 100, b = 255, a = 255})
    end
    return temp
end

function DampenFinalForce(velocity, displacement, surfaceNormal, torque, device)
    if not velocity then velocity = AverageCoordinates({device.nodeVelA, device.nodeVelB}) end
    --likewise with RoadLinks.lua, velocity has to be averaged between the two nodes, due to the nodes being linked together
    displacement = Vec3(displacement.x, displacement.y)
    torque = Vec3(torque.x, torque.y)
    velocity = Vec3(velocity.x, velocity.y)
    surfaceNormal = Vec3(surfaceNormal.x, surfaceNormal.y)

    local springValues = WHEEL_SPRINGS[device.saveName]
    local DampenedForceA = DirectionalDampening(springValues.springConst, displacement, springValues.dampening, velocity, surfaceNormal)
    local DampenedForceB = DirectionalDampening(springValues.springConst, displacement, springValues.dampening, velocity, surfaceNormal)
    
    local DampenedForce = 
    {
        DampenedForceA = DampenedForceA,
        DampenedForceB = DampenedForceB
    }
   return DampenedForce 
end


function DirectionalDampening(springConst, displacement, dampening, velocity, surfacePerpVector)
    local velocityPerpToSurface = Dot(velocity, surfacePerpVector)
    local force = springConst * displacement - dampening * velocityPerpToSurface * surfacePerpVector
    
    return force
end



function CheckCollisionsOnBrace(terrain, pos, radius, uid)
    --Fix for single node blocks
    if #terrain < 2 then
        return nil
    end
    local newPos = pos
        local perpendicularVector = CircleBraceCollision(pos, radius, terrain, uid)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * -radius,
                y = pos.y + perpendicularVector.y * -radius
            }
        end
        if newPos.x then
            return { x = newPos.x - pos.x, y = newPos.y - pos.y }
        else
            return {x = 0, y = 0}
        end
    
end
-- Check if a circle is colliding with a polygon.


--[[
WheelLinksColliding = {
    [wheelid] = {
        [nodeA.."_"..nodeB] = -1,
        [nodeA.."_"..nodeB] = -1,
        [nodeA.."_"..nodeB] = 1,
        [nodeA.."_"..nodeB] = -1,
        [nodeA.."_"..nodeB] = 1,
        [nodeA.."_"..nodeB] = 1,
    }
}

]]


function CircleBraceCollision(circleCenter, wheelRadius, polygon, uid)
    --Centerpoint in polygon
        for i = 1, 2 do
            if polygon[i].x == 0 and polygon[i].y == 0 then return end
        end
        -- Check if any of the polygon's edges intersect with the circle.
        local edgeStart = polygon[1]
        local edgeEnd = polygon[2]
        local normal = data.wheelLinksColliding[uid]
        if not normal then
            normal = CalculateCollisionNormal(edgeStart, edgeEnd, circleCenter)
        end


        local distance = ClosestDistanceOfTwoPoints(circleCenter, edgeStart, edgeEnd)
        local final = CalculateCollisionResponseVector(distance, edgeStart, edgeEnd, wheelRadius, normal)
        --if final is > 0, then set the normal, otherwise clear the normal, to ensure that it collides with the initial side`
        if final then 
            data.wheelLinksColliding[uid] = normal
            return final
        else
            data.wheelLinksColliding[uid] = nil
        end
           

    -- If there is no collision, return nil.
    return nil
end



function CalculateCollisionResponseVector(distance, edgeStart, edgeEnd, WHEEL_RADIUS, normal)
    if not normal then normal = 1 end
    if distance <= WHEEL_RADIUS then
        -- Calculate the perpendicular vector to the edge
        local edgeVector = SubtractVectors(edgeEnd, edgeStart)
        local perpendicularVector = NormalizeVector({ x = -edgeVector.y, y = edgeVector.x })

        -- Scale the perpendicular vector based on the overlap between the circle and the edge
        local distanceFactor = (WHEEL_RADIUS - distance) / WHEEL_RADIUS
        if math.abs(distance) > WHEEL_RADIUS then distanceFactor = 0 end
        local final = ScaleVector(perpendicularVector, distanceFactor)
        return {x = final.x * normal, y = final.y * normal}
    end
end


















--A cool helper function I sotle from landcroozers 2
function IsWithinDistance(vector1, vector2, distance)
    local dx = vector1.x - vector2.x
    local dy = vector1.y - vector2.y
    local distanceSquared = dx * dx + dy * dy
    local givenDistanceSquared = distance * distance

    return distanceSquared <= givenDistanceSquared
end

