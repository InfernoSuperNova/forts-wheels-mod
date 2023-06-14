--WheelCollision.lua
--- forts script API ---





function WheelCollisionHandler()
    Displacement = {}
    data.wheelsTouchingGround = {}
    local structures = GetDeviceStructureGroups()


    --section off into structures


    for structureKey, devices in pairs(structures) do
        local collisions = CheckBoundingBoxCollisions(devices)

        for deviceKey, device in pairs(devices) do
            local displacement = CheckAndCounteractCollisions(device, collisions.blocks, collisions.structures, structureKey)
            if not data.wheelsTouchingGround[structureKey] then data.wheelsTouchingGround[structureKey] = {} end



            if displacement then
                data.wheelsTouchingGround[structureKey][deviceKey] = displacement
            end
        end
    end
    Structures = structures
end

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

function CheckBoundingBoxCollisions(devices)
    local positions = {}

    for k, device in pairs(devices) do

        local wheelStats = GetWheelStats(device)
        positions[k] = wheelStats.pos
    end
    local collidingBlocks = {}
    local collidingStructures = {}
    local collider = MinimumCircularBoundary(positions)
    collider.r = collider.r + WHEEL_RADIUSES.large + TRACK_WIDTH 
    if ModDebug.collision == true then
        local colour1 = {r = 100, g = 255, b = 100, a = 255}
        local colour2 = {r = 0, g = 255, b = 200, a = 255}
        local colour3 = {r = 100, g = 200, b = 255, a = 255}
        SpawnCircle(collider, collider.r, colour2, 0.04)
        HighlightPolygon(collider.square, colour1)
        HighlightPolygon(positions, colour3)
    end
   
    for terrainId, terrainCollider in pairs(data.terrainCollisionBoxes) do
        if Distance(collider, terrainCollider) < collider.r + terrainCollider.r + 50 then
            collidingBlocks[terrainId] = true
        end
    end
    for structureId, structure in pairs(RoadStructureBoundaries) do
        if Distance(collider, structure) < collider.r + structure.r + 50 then
            collidingStructures[structureId] = true
        end
    end
    if collidingBlocks == nil then
        collidingBlocks = false
    end
    return {blocks = collidingBlocks, structures = collidingStructures}
end

function CheckAndCounteractCollisions(device, collidingBlocks, collidingStructures, structureId)
    local returnVal = { x = 0, y = 0 }
    local displacement
    local wheelStats = GetWheelStats(device)
    
    WheelPos[device.id] = wheelStats.pos
    --looping through blocks


    
    for blockIndex, Nodes in pairs(collidingBlocks) do
        displacement = CheckCollisionsOnBlock(Terrain[blockIndex], wheelStats.pos, wheelStats.radius + TRACK_WIDTH)

        if displacement == nil then --incase of degenerate blocks
            displacement = Vec3(0,0)
        end

        local velocity = AverageCoordinates({NodeVelocity(device.nodeA), NodeVelocity(device.nodeB)})
        SendDisplacementToTracks(displacement, device)
        if displacement and displacement.y ~= 0 then
            ApplyFinalForce(device, velocity, displacement, structureId)

            if math.abs(returnVal.y) < math.abs(displacement.y) then
                returnVal = { x = displacement.x, y = displacement.y }
            end
        end
    end
    for structure, _ in pairs(collidingStructures) do
        local links = RoadStructures[structure]
        for index, link in pairs(links) do
            
            local newLink = {RoadCoords[structure][index * 2 - 1], RoadCoords[structure][index * 2]}
            local uid = device.id .. "_" .. index * 2 - 1 .. "_" .. index * 2
            displacement = CheckCollisionsOnBrace(newLink, wheelStats.pos, wheelStats.radius + TRACK_WIDTH, uid)
            SendDisplacementToTracks(displacement, device)
            if displacement == nil then --incase of degenerate blocks
                displacement = Vec3(0,0)
            end
            displacement.x = displacement.x / 2
            displacement.y = displacement.y / 2
            AccumulateForceOnRoad(link.nodeA, link.nodeB, displacement)
            
            
            if displacement and displacement.y ~= 0 then
                ApplyFinalForce(device, velocity, displacement, structureId)
    
                if math.abs(returnVal.y) < math.abs(displacement.y) then
                    returnVal = { x = displacement.x, y = displacement.y }
                end
            end
        end
    end
    if returnVal.y ~= 0 then
        return returnVal
    end
    
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
        if ModDebug.forces then
            HighlightDirectionalVector(wheel.device.nodePosA, wheel.displacement, 3, {r = 100, g = 255, b = 100, a = 255})
            HighlightDirectionalVector(wheel.device.nodePosB, wheel.displacement, 3, {r = 100, g = 255, b = 100, a = 255})
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
        --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
        x = SpringDampenedForce(SPRING_CONST, displacement.x, DAMPENING * math.abs(surfaceNormal.x) * 0.2, velocity.x),
        y = SpringDampenedForce(SPRING_CONST, displacement.y, DAMPENING * math.abs(surfaceNormal.y), velocity.y)
    }
    if FinalSuspensionForces[device.id] and DampenedForce.x then
        FinalSuspensionForces[device.id] = {
            x = FinalSuspensionForces[device.id].x + DampenedForce.x,
            y = FinalSuspensionForces[device.id].y + DampenedForce.y
        }
    else
        FinalSuspensionForces[device.id] = DampenedForce
    end
    
end



function CheckCollisionsOnBlock(terrain, pos, radius)
    --Fix for single node blocks
    if #terrain < 2 then
        return nil
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
        --BetterLog(uid)
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



