--WheelCollision.lua
--- forts script API ---
local springConst = 30000
local dampening = 1500

Terrain = {}




function WheelCollisionHandler()
    data.wheelsTouchingGround = {}
    local structures = GetDeviceStructureGroups()


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

function GetDeviceStructureGroups()
    local structures = {}
    for side = 1, 2 do
        local deviceCount = GetDeviceCountSide(side)


        for index = 0, deviceCount do
            local device = GetDeviceIdSide(side, index)
            if CheckSaveNameTable(GetDeviceType(device), WheelSaveName) and IsDeviceFullyBuilt(device) then
                local structureId = GetDeviceStructureId(device)
                if not structures[structureId] then structures[structureId] = {} end
                table.insert(structures[structureId], device)
            end
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
    local collider = MinimumCircularBoundary(positions)
    
    for terrainId, terrainCollider in pairs(data.terrainCollisionBoxes) do
        SpawnCircle(collider, collider.r + 50, {r = 255, g = 255, b = 255, a = 255}, 0.04)
        if Distance(collider, terrainCollider) < collider.r + terrainCollider.r + 50 then
            local newCollider = {x = collider.x, y = collider.y, r = collider.r + 50}
            collidingBlocks[terrainId] = CirclePolygonColliderCollision(newCollider, Terrain[terrainId])
        end
    end

    for k, v in pairs(collidingBlocks) do
        --in list of blocks collided with?
        for i, j in pairs(v) do
            --in lst of co ords making up block colliding with?
            HighlightPolygon({j[1], j[2]})
        end
        
    end
    if collidingBlocks == nil then
        return { false }
    end
    
    return collidingBlocks
end



function CheckAndCounteractCollisions(device, collidingBlocks)

    --so, we have our blocks defined as:
    --[[


    collidingBlocks = {
        blockId = {
            {
                1 = {x, y}
                2 = {x, y}
            }
        }
    }
    ]]
    local structureId = GetDeviceStructureId(device)
    local returnVal = {x = 0, y = 0}
    local displacement
    local pos
    if GetDeviceType(device) == WheelSaveName[1] then
        pos = GetOffsetDevicePos(device, WheelSuspensionHeight)
    else
        pos = GetOffsetDevicePos(device, -WheelSuspensionHeight)
    end

    WheelPos[device] = pos

    displacement = {x = 0, y = 0}
    --looping through the block nodes that collision checks should be run with
    for blockIndex, blockPairs in pairs(collidingBlocks) do
        for _, segment in pairs(blockPairs) do
            local localDisplacement = CheckCollisionsOnBlock(segment, pos, WheelRadius + 20)
            --
            
            if Displacement[device] then
                displacement = FindClosestNumber(VecMagnitude(localDisplacement), VecMagnitude(displacement), VecMagnitude(Displacement[device]))
            elseif math.abs(VecMagnitude(localDisplacement)) > math.abs(VecMagnitude(displacement)) then 
                displacement = localDisplacement 
            end

            
        end

    end
        

    local nodeA = GetDevicePlatformA(device)
    local nodeB = GetDevicePlatformB(device)
    local velocity = AverageCoordinates({NodeVelocity(nodeA), NodeVelocity(GetDevicePlatformB(device))})



    SendDisplacementToTracks(displacement, device)
    if displacement and displacement.y ~= 0 then
 
        ApplyFinalForce(device, velocity, displacement)
        

        returnVal = displacement
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
    FinalSuspensionForces[device] = DampenedForce
    --dlc2_ApplyForce(GetDevicePlatformA(device), DampenedForce)
    --dlc2_ApplyForce(GetDevicePlatformB(device), DampenedForce)
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
        if ModDebug == true then
            SpawnCircle(data.terrainCollisionBoxes[currentBlock + 1], data.terrainCollisionBoxes[currentBlock + 1].r, {r = 255, g = 255, b = 255, a = 255}, 0.04)
        end
        
    end
end

function CheckCollisionsOnBlock(terrain, pos, radius)
    --Fix for single node blocks
    if #terrain < 2 then
        return nil
    end
    local newPos = pos
    local cross = PointSideOfLine(pos, terrain[1], terrain[2])
    BetterLog(cross)
    if cross > 0 then
        local perpendicularVector = CirclePolygonCollision(pos, radius, terrain, cross)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * radius,
                y = pos.y + perpendicularVector.y * radius
            }
        end
        return { x = pos.x - newPos.x, y = pos.y - newPos.y }
    else
        local perpendicularVector = CirclePolygonCollision(pos, radius, terrain, cross)
        if perpendicularVector then
            newPos = {
                x = pos.x + perpendicularVector.x * -radius,
                y = pos.y + perpendicularVector.y * -radius
            }
        end
        return { x = newPos.x - pos.x, y = newPos.y - pos.y }
    end
end



function CirclePolygonColliderCollision(circle, polygon)
    local collidedEdges = {}
    for i = 1, #polygon do
        local j = (i % #polygon) + 1
        local edge = {polygon[i], polygon[j]}
        local edgeVector = {(edge[2].x - edge[1].x), (edge[2].y - edge[1].y)}

        -- Check distance between circle center and each vertex of the edge
        local dist1 = math.sqrt((edge[1].x - circle.x)^2 + (edge[1].y - circle.y)^2)
        local dist2 = math.sqrt((edge[2].x - circle.x)^2 + (edge[2].y - circle.y)^2)

        if dist1 <= circle.r or dist2 <= circle.r then
            table.insert(collidedEdges, edge)
        else
            local projection = {(circle.x - edge[1].x), (circle.y - edge[1].y)}
            local dotProduct = projection[1] * edgeVector[1] + projection[2] * edgeVector[2]
            local edgeLengthSquared = edgeVector[1] * edgeVector[1] + edgeVector[2] * edgeVector[2]
            local distanceSquared = projection[1] * projection[1] + projection[2] * projection[2]
            local radiusSquared = circle.r * circle.r

            if dotProduct >= 0 and dotProduct <= edgeLengthSquared then
                local perpendicularVector = {
                    -(edgeVector[2]),
                    edgeVector[1]
                }
                local distanceToPerpendicularSquared = (projection[1] * perpendicularVector[1] + projection[2] * perpendicularVector[2]) ^ 2 / (edgeVector[1] ^ 2 + edgeVector[2] ^ 2)
                if distanceToPerpendicularSquared <= radiusSquared then
                    table.insert(collidedEdges, edge)
                end
            elseif distanceSquared <= radiusSquared then
                table.insert(collidedEdges, edge)
            end
        end
    end
    return collidedEdges
end
-- Check if a circle is colliding with a polygon.
function CirclePolygonCollision(circleCenter, wheelRadius, polygon, cross)
    --Centerpoint in polygon
    if cross > 0 then
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
