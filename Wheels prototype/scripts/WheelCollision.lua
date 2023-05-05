--WheelCollision.lua
--- forts script API ---
local springConst = 15000
local dampening = 500

Terrain = {}




function WheelCollisionHandler()
    data.wheelsTouchingGround = {}
    local structures = {}
    for side = 1, 2 do
        local deviceCount = GetDeviceCountSide(side)

        
        for index = 0, deviceCount do
            local device = GetDeviceIdSide(side, index)
            if GetDeviceType(device) == WheelSaveName and IsDeviceFullyBuilt(device) then
                local structureId = GetDeviceStructureId(device)
                if not structures[structureId] then structures[structureId] = {} end
                table.insert(structures[structureId], device)
            end
        end
    end

    --section off into structures


    for structureKey, devices in pairs(structures) do
        local collidingBlocks = CheckBoundingBoxCollisions(devices)

        for deviceKey, device in pairs(devices) do

             local displacement = CheckAndCounteractCollisions(device, collidingBlocks)

            if not data.wheelsTouchingGround[structureKey] then data.wheelsTouchingGround[structureKey] = {} end



            if displacement then
                data.wheelsTouchingGround[structureKey][deviceKey] = displacement
            end

             
        end
    end
    data.structures = structures

end



function CheckBoundingBoxCollisions(devices)

    local positions = {}

    for k, v in pairs(devices) do
        positions[k] = GetOffsetDevicePos(v, WheelSuspensionHeight)
    end

    local collidingBlocks = {}
    local collider = MinimumCircularBoundary(positions)
    for terrainId, terrainCollider in pairs(data.terrainCollisionBoxes) do
        if Distance(collider, terrainCollider) < collider.r + terrainCollider.r + 50 then

            collidingBlocks[terrainId] = true
        end
    end
    
    return collidingBlocks
    

end


function CheckAndCounteractCollisions(device, collidingBlocks)
    local returnVal = {x = 0, y = 0}
    local displacement
    local pos = GetOffsetDevicePos(device, WheelSuspensionHeight)
    WheelPos[device] = pos
    --looping through blocks
    for blockIndex, Nodes in pairs(collidingBlocks) do
        --looping through nodes in block
        -- for nodeIndex = 1, #Nodes do
        --     local node1 = Terrain[blockIndex]
        --     local node2 = Terrain[blockIndex % #Nodes + 1]
        --     BetterLog(CircleLineSegmentCollision(pos, WheelRadius, node1, node2))
        -- end

        --local segmentsToCheck = CircleLineSegmentCollision(pos, WheelRadius)
        displacement = CheckCollisionsOnBlock(Terrain[blockIndex], pos, WheelRadius)
        local velocity = NodeVelocity(GetDevicePlatformA(device))



        SendDisplacementToTracks(displacement, device)
        if displacement.y ~= 0 then
            --BetterLog(displacement)
            ApplyFinalForce(device, velocity, displacement)
            
            if math.abs(returnVal.y) < math.abs(displacement.y) then 

                returnVal = {x = displacement.x, y = displacement.y} 
            end

        end
    end
    if returnVal.y ~= 0 then 
        return returnVal 
    end

    
end

function GetOffsetDevicePos(device, offset)
    local NodeAPos = NodePosition(GetDevicePlatformA(device))
    local NodeBPos = NodePosition(GetDevicePlatformB(device))
    local devicePos = GetDevicePosition(device)


    local offsetPos = OffsetPerpendicular(NodeAPos, NodeBPos, offset)
    local newPos = {
        x = offsetPos.x + devicePos.x,
        y = offsetPos.y + devicePos.y
    }
    return newPos
end
function SendDisplacementToTracks(displacement, device)
    if not Displacement[device] then
        Displacement[device] = displacement
    else
        --set displacement to largest among all blocks
        if math.abs(Displacement[device].y) < math.abs(displacement.y) then
            Displacement[device] = displacement
        end
    end
end

function ApplyFinalForce(device, velocity, displacement)
    local DampenedForce = {
        --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
        x = SpringDampenedForce(springConst, displacement.x, 0, velocity.x),
        y = SpringDampenedForce(springConst, displacement.y, dampening, velocity.y)
    }

    --apply the PID force
    -- local DampenedForce = {
    --     x = data.previousVals[device].output.x,
    --     y = data.previousVals[device].output.y
    -- }
    dlc2_ApplyForce(GetDevicePlatformA(device), DampenedForce)
    dlc2_ApplyForce(GetDevicePlatformB(device), DampenedForce)
end

function IndexTerrainBlocks()
    data.terrainCollisionBoxes = {}
    local terrainBlockCount = GetBlockCount()

    --loop through all terrain blocks
    for currentBlock = 0, terrainBlockCount - 1 do
        --create new array for that block
        Terrain[currentBlock + 1] = {}
        local vertexCount = GetBlockVertexCount(currentBlock)
        --loop through all vertexes in that block
        for currentVertex = 0, vertexCount - 1 do
            --adds to table for maths
            Terrain[currentBlock + 1][currentVertex + 1] = GetBlockVertexPos(currentBlock, currentVertex)
        end
        data.terrainCollisionBoxes[currentBlock + 1] = MinimumCircularBoundary(Terrain[currentBlock + 1])
    end
end

function CheckCollisionsOnBlock(terrain, pos, radius)
    local newPos = pos
    if PointInsidePolygon(pos, terrain) then
        local perpendicularVector = CirclePolygonCollision(pos, radius, terrain)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * radius,
                y = pos.y + perpendicularVector.y * radius
            }
        end
        return { x = pos.x - newPos.x, y = pos.y - newPos.y }
    else
        local perpendicularVector = CirclePolygonCollision(pos, radius, terrain)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * -radius,
                y = pos.y + perpendicularVector.y * -radius
            }
        end
        return { x = newPos.x - pos.x, y = newPos.y - pos.y }
    end
end

-- Check if a circle is colliding with a polygon.
function CirclePolygonCollision(circleCenter, wheelRadius, polygon)
    --Centerpoint in polygon
    if PointInsidePolygon(circleCenter, polygon) then
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(-obj.closestDistance, obj.closestEdge.edgeStart, obj.closestEdge.edgeEnd,
        wheelRadius)
        if final then return final end
        --Centerpoint out of polygon
    else
        -- Check if any of the polygon's edges intersect with the circle.
        local obj = FindClosestEdge(circleCenter, polygon)
        local final = CalculateCollisionResponseVector(obj.closestDistance, obj.closestEdge.edgeStart, obj.closestEdge.edgeEnd,
        wheelRadius)
        if final then return final end
    end

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
