--WheelCollision.lua
--- forts script API ---





function WheelCollisionHandler()
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
        if CheckSaveNameTable(device.saveName, WheelSaveName) and IsDeviceFullyBuilt(device.id) then
            local structureId = device.strucId
            if not structures[structureId] then structures[structureId] = {} end
            table.insert(structures[structureId], device)
        end
    end
    return structures
end

function CheckBoundingBoxCollisions(devices)
    local positions = {}

    for k, deviceKey in pairs(devices) do
        if deviceKey == WheelSaveName[1] then
            positions[k] = GetOffsetDevicePos(deviceKey, -WheelSuspensionHeight)
        else
            positions[k] = GetOffsetDevicePos(deviceKey, WheelSuspensionHeight)
        end
    end
    local collidingBlocks = {}
    local collidingStructures = {}
    local collider = MinimumCircularBoundary(positions)
    if ModDebug.collision == true then
        SpawnCircle(collider, collider.r, {r = 100, g = 255, b = 100, a = 255}, 0.04)
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
    local pos
    if device.saveName == WheelSaveName[1] then
        pos = GetOffsetDevicePos(device, WheelSuspensionHeight)
    else
        pos = GetOffsetDevicePos(device, -WheelSuspensionHeight)
    end
    WheelPos[device.id] = pos
    --looping through blocks

    for structure, _ in pairs(collidingStructures) do
        local links = RoadStructures[structure]
        for index, link in pairs(links) do
            local newLink = {RoadCoords[structure][index * 2 - 1], RoadCoords[structure][index * 2]}
            
            displacement = CheckCollisionsOnBrace(newLink, pos, WheelRadius + TrackWidth)
            
            ApplyForceToRoadLinks(link.nodeA, link.nodeB, displacement)
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
    end
    
    for blockIndex, Nodes in pairs(collidingBlocks) do
        --looping through nodes in block
        -- for nodeIndex = 1, #Nodes do
        --     local node1 = Terrain[blockIndex]
        --     local node2 = Terrain[blockIndex % #Nodes + 1]
        --     BetterLog(CircleLineSegmentCollision(pos, WheelRadius, node1, node2))
        -- end

        --local segmentsToCheck = CircleLineSegmentCollision(pos, WheelRadius)
        displacement = CheckCollisionsOnBlock(Terrain[blockIndex], pos, WheelRadius + TrackWidth)

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
    if returnVal.y ~= 0 then
        return returnVal
    end
end

function GetOffsetDevicePos(device, offset)

    local NodeAPos = NodePosition(device.nodeA)
    local NodeBPos = NodePosition(device.nodeB)


    local offsetPos = OffsetPerpendicular(NodeAPos, NodeBPos, offset)
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
            Displacement[device.id] = displacement
        end
    end
end

function ApplyFinalForce(device, velocity, displacement, structureId)
    if data.brakes[structureId] == true then displacement.x = 0 end
    local surfaceNormal = NormalizeVector(displacement)
    local DampenedForce = {
        --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
        x = SpringDampenedForce(SpringConst, displacement.x, Dampening * math.abs(surfaceNormal.x) * 0.2, velocity.x),
        y = SpringDampenedForce(SpringConst, displacement.y, Dampening * math.abs(surfaceNormal.y), velocity.y)
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
function CirclePolygonCollision(circleCenter, wheelRadius, polygon)
    --Centerpoint in polygon
    if PointInsidePolygon(circleCenter, polygon) then
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(-obj.closestDistance, obj.closestEdge.edgeStart,
            obj.closestEdge.edgeEnd,
            wheelRadius)
        if final then return final end
        --Centerpoint out of polygon
    else
        -- Check if any of the polygon's edges intersect with the circle.
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(obj.closestDistance, obj.closestEdge.edgeStart,
            obj.closestEdge.edgeEnd,
            wheelRadius)
        if final then return final end
    end

    -- If there is no collision, return nil.
    return nil
end


function CheckCollisionsOnBrace(terrain, pos, radius)
    --Fix for single node blocks
    if #terrain < 2 then
        return nil
    end
    local newPos = pos
        local perpendicularVector = CircleBraceCollision(pos, radius, terrain)
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
function CircleBraceCollision(circleCenter, wheelRadius, polygon)
    --Centerpoint in polygon
        
        -- Check if any of the polygon's edges intersect with the circle.
        local edgeStart = polygon[1]
        local edgeEnd = polygon[2]
        if edgeEnd.x < edgeStart.x then
            local temp = DeepCopy(edgeStart)
            edgeStart = DeepCopy(edgeEnd)
            edgeEnd = temp
        end
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(obj.closestDistance, edgeStart,
            edgeEnd,
            wheelRadius)
        if final then return final end

    -- If there is no collision, return nil.
    return nil
end



function CalculateCollisionResponseVector(distance, edgeStart, edgeEnd, wheelRadius)
    if distance <= wheelRadius then
        -- Calculate the perpendicular vector to the edge
        local edgeVector = SubtractVectors(edgeEnd, edgeStart)
        local perpendicularVector = NormalizeVector({ x = -edgeVector.y, y = edgeVector.x })

        -- Scale the perpendicular vector based on the overlap between the circle and the edge
        local distanceFactor = (wheelRadius - distance) / wheelRadius
        return ScaleVector(perpendicularVector, distanceFactor)
    end
end
