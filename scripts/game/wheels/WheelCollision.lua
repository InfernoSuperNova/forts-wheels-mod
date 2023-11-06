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
            local displacement = CheckCollisionWheelOnSegment(device, collisions.simplifiedBlocks, collisions.structures, structureKey)
            if VecMagnitude(displacement) > 0 then
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
    for _, device in pairs(Devices) do
        if (CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.small) 
        or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.medium) 
        or CheckSaveNameTable(device.saveName, WHEEL_SAVE_NAMES.large)) 
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
    collider.r = collider.r + WHEEL_RADIUSES.large + TRACK_WIDTH 
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
    local collidingNodes = {}
    local simplifiedBlocks = {}
    local collidingStructures = {}
    --Check collisions with terrain, set the collidingBlocks table key with the terrain id to true if colliding
    for terrainId, terrainBC in pairs(data.terrainCollisionBoxes) do
        if Distance(wheelBC, terrainBC) < wheelBC.r + terrainBC.r + 50 then
            collidingBlocks[terrainId] = true
        end
    end
    for terrainId = 1, GetHighestIndex(Terrain) do
        local terrain = Terrain[terrainId]


        if collidingBlocks[terrainId] then
            for _, corner in pairs(TerrainCorners[terrainId]) do
                if not collidingNodes[terrainId] then collidingNodes[terrainId] = {} end
                collidingNodes[terrainId][corner] = true
            end
            for segmentId = 1, #terrain do
                local pointA = terrain[segmentId]
                local pointB = terrain[segmentId % #terrain + 1]
                local segmentLength = Distance(pointA, pointB)
                local segmentBC = {
                    x = (pointA.x + pointB.x) / 2,
                    y = (pointA.y + pointB.y) / 2,
                    r = segmentLength / 2
                }
                if Distance(wheelBC, segmentBC) < wheelBC.r + segmentBC.r then
                    if not collidingNodes[terrainId] then collidingNodes[terrainId] = {} end
                    collidingNodes[terrainId][segmentId] = true
                    collidingNodes[terrainId][segmentId % #terrain + 1] = true
                end
            end
            for segment = 1, GetHighestIndex(Terrain[terrainId]) do
                if collidingNodes[terrainId] and collidingNodes[terrainId][segment] then
                    if not simplifiedBlocks[terrainId] then simplifiedBlocks[terrainId] = {} end
                    simplifiedBlocks[terrainId][segment] = Terrain[terrainId][segment]
                end
            end
        end
        if ModDebug.collision then 
            for _, block in pairs(simplifiedBlocks) do
                HighlightPolygonWithDisplacement(block, {x = 0, y = -2500}, {r = 255, g = 255, b = 255, a = 255})
                HighlightCoordsTextWithDisplacement(block, {x = 0, y = -2500}, {r = 255, g = 255, b = 255, a = 255})
            end
        end
    end
    
    --Check collisions with structures, set the collidingStructures table key with the structure id to true if colliding
    for structureId, roadBC in pairs(RoadStructureBoundaries) do
        if Distance(wheelBC, roadBC) < wheelBC.r + roadBC.r + 50 then
            collidingStructures[structureId] = true
        end
    end
    return {blocks = collidingBlocks, structures = collidingStructures, simplifiedBlocks = simplifiedBlocks}
end

--Lowest level collision checks, checks a wheel against a line segment (could be a terrain segment or a road segment)
function CheckCollisionWheelOnSegment(device, collidingBlocks, collidingStructures, structureId)
    local returnVal = { x = 0, y = 0 }
    local wheelStats = GetWheelStats(device)
    
    WheelPos[device.id] = wheelStats.pos
    --looping through blocks
    returnVal = CheckCollisionWheelOnTerrain(device, wheelStats, collidingBlocks, structureId, returnVal)
    returnVal = CheckCollisionWheelOnRoad(collidingStructures, wheelStats, device, returnVal, structureId)
    
    if returnVal then
        return returnVal
    end
    
end

--Checks a wheel against a terrain block
function CheckCollisionWheelOnTerrain(device, wheelStats, collidingBlocks, structureId, prevDisplacement)
    --Assign returnVal to prevDisplacement for the first iteration
    local returnVal = prevDisplacement
    local displacement
    for blockIndex, Nodes in pairs(collidingBlocks) do
        
        --resolve a list of segments to check collisions on
        local flattenedTerrain = {}
        local newTerrain = {}
        local yes = {}
        local cornerIds = {}
        for k, v in pairs(TerrainCorners[blockIndex]) do
            cornerIds[v] = true
        end
        for segment = 1, GetHighestIndex(Nodes) do
            table.insert(flattenedTerrain, Nodes[segment])
            if cornerIds[segment] then 

                
                yes[#flattenedTerrain] = true 
            end
        end
        for segment = 1, #flattenedTerrain do

            local pointA = flattenedTerrain[segment]
            local pointB = flattenedTerrain[segment % #flattenedTerrain + 1 ]
            local segmentLength = Distance(pointA, pointB)
            local segmentBC = {
                x = (pointA.x + pointB.x) / 2,
                y = (pointA.y + pointB.y) / 2,
                r = segmentLength / 2
            }
            if Distance(wheelStats.pos, segmentBC) < wheelStats.radius + TRACK_WIDTH * 2 + segmentBC.r then
                yes[segment] = true
                yes[segment % #flattenedTerrain + 1] = true
            end
        end

        for id, pos in pairs(flattenedTerrain) do
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
    if PointInsidePolygon(circleCenter, polygon) then
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(-obj.closestDistance, obj.closestEdge.edgeStart,
            obj.closestEdge.edgeEnd,
            WHEEL_RADIUS)
        if final then return final end
        --Centerpoint out of polygon
    else
        -- Check if any of the polygon's edges intersect with the circle.
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(obj.closestDistance, obj.closestEdge.edgeStart,
            obj.closestEdge.edgeEnd,
            WHEEL_RADIUS)
        if final then return final end
    end

    -- If there is no collision, return nil.
    return nil
end

--Checks a wheel against a set of roads on a base
function CheckCollisionWheelOnRoad(collidingStructures, wheelStats, device, prevDisplacement, structureId)
    local returnVal = prevDisplacement
    local displacement = prevDisplacement

    for structure, _ in pairs(collidingStructures) do
        if structure == structureId then
            continue
        end
        local roadCollider = RoadStructureBoundaries[structure]
        if Distance(roadCollider, wheelStats.pos) > roadCollider.r + wheelStats.radius then
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
            if Distance(wheelStats.pos, roadBC) > wheelStats.radius + roadBC.r then
                continue
            end
            displacement = CheckCollisionsOnBrace(newLink, wheelStats.pos, wheelStats.radius + TRACK_WIDTH, uid)
            SendDisplacementToTracks(displacement, device)
            if displacement == nil then --incase of degenerate blocks
                displacement = Vec3(0,0)
            end

            local averageVel = AverageSpringDampening(device.nodeVelA, device.nodeVelB, NodeVelocity(link.nodeA), NodeVelocity(link.nodeB))
            local roadVel = {
                x = -averageVel.x,
                y = -averageVel.y
            }
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
    local DampenedForceA = {
        --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
        x = SpringDampenedForce(SPRING_CONST, displacement.x + torque.x, DAMPENING * math.abs(surfaceNormal.x) ^ 4, velocity.x),
        y = SpringDampenedForce(SPRING_CONST, displacement.y + torque.y, DAMPENING * math.abs(surfaceNormal.y) ^ 4, velocity.y)
    }
    local DampenedForceB = {
        --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
        x = SpringDampenedForce(SPRING_CONST, displacement.x - torque.x, DAMPENING * math.abs(surfaceNormal.x) ^ 4, velocity.x),
        y = SpringDampenedForce(SPRING_CONST, displacement.y - torque.y, DAMPENING * math.abs(surfaceNormal.y) ^ 4, velocity.y)
    }

    
    local DampenedForce = 
    {
        DampenedForceA = DampenedForceA,
        DampenedForceB = DampenedForceB
    }
   return DampenedForce 
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
        --grab the normal for that wheel and brace from the table if it exists, else make a new one
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
        local final = ScaleVector(perpendicularVector, distanceFactor)
        return {x = final.x * normal, y = final.y * normal}
    end
end



