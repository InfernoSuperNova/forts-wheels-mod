--physlib/bspTres/terrainTree.lua
Log("Loading terrain tree")


SDTYPE_BOTH_THRESHOLD_MAX = 1.1
SDTYPE_BOTH_THRESHOLD_MIN = 1/SDTYPE_BOTH_THRESHOLD_MAX



function PhysLib.BspTrees.TerrainTree:Subdivide()
    MaxDepthThisFrame = 0
    local blocks = PhysLib.Terrain.Blocks
    local terrainSegments = {}
    self:SplitBlocksIntoSegments(blocks, terrainSegments)
    PhysLib.TerrainTree = self:SubdivideTerrainSegmentGroup(terrainSegments, 0)
end
MaxDepthThisFrame = 0
function PhysLib.BspTrees.TerrainTree:SubdivideTerrainSegmentGroup(terrainSegments, depth, parentCount)
    local rect = self:GetTerrainSegmentRectangle(terrainSegments) -- approximate
    local count = rect.count


    if count <= 1 or (rect.width * rect.height == 0) or count == parentCount then
        rect = terrainSegments[1]

        for i = 1, count do
            local node = terrainSegments[i]
            rect.minX = (rect.minX < node.minX) and rect.minX or node.minX
            rect.maxX = (rect.maxX > node.maxX) and rect.maxX or node.maxX
            rect.minY = (rect.minY < node.minY) and rect.minY or node.minY
            rect.maxY = (rect.maxY > node.maxY) and rect.maxY or node.maxY
            
        end
        MaxDepthThisFrame =  (depth > MaxDepthThisFrame and depth or MaxDepthThisFrame)
        return {children = terrainSegments, rect = rect, deepest = true}
    end

    local widthHeightRatio = rect.width / rect.height

    local subTree

    if (widthHeightRatio > SDTYPE_BOTH_THRESHOLD_MAX) then
        --Divide vertically
        subTree = self:DivideV(terrainSegments, rect.x)
    elseif (widthHeightRatio < SDTYPE_BOTH_THRESHOLD_MIN) then
        --Divide horizontally
        subTree = self:DivideH(terrainSegments, rect.y)
    else
        --Divide both
        subTree = self:DivideVH(terrainSegments, rect)
    end
    local children = {}
    for i = 1, #subTree do
        local group = subTree[i]

        if group == 0 or #group == 0 then continue end
        children[#children + 1] = self:SubdivideTerrainSegmentGroup(group, depth + 1, count)
    end

    -- Call back the minimum quad extent
    for i = 1, #children do
        local child = children[i]
        local childRect = child.rect
        rect.minX = (rect.minX < childRect.minX) and rect.minX or childRect.minX
        rect.maxX = (rect.maxX > childRect.maxX) and rect.maxX or childRect.maxX
        rect.minY = (rect.minY < childRect.minY) and rect.minY or childRect.minY
        rect.maxY = (rect.maxY > childRect.maxY) and rect.maxY or childRect.maxY
        -- Spawn lines from each child corner to the parent corner


    end
    children.type = subTree.type
    return {children = children, rect = rect, deepest = false}
end

--#region Rect shape subdivision handlers
function PhysLib.BspTrees.TerrainTree:DivideV(nodes, center)
    local subTree1, subTree2 = {}, {}
    local count1, count2 = 0, 0


    for i = 1, #nodes do
        local v = nodes[i]

        if v.x < center then
            count1 = count1 + 1
            subTree1[count1] = v
        else
            count2 = count2 + 1
            subTree2[count2] = v
        end
    end
    subTree1.type = 1
    subTree2.type = 1
    return { subTree1, subTree2, type = 1 }
end

function PhysLib.BspTrees.TerrainTree:DivideH(nodes, center)
    local subTree1, subTree2 = {}, {}
    local count1, count2 = 0, 0

    for i = 1, #nodes do
        local v = nodes[i]

        if v.y < center then
            count1 = count1 + 1
            subTree1[count1] = v
        else
            count2 = count2 + 1
            subTree2[count2] = v
        end
    end
    subTree1.type = 2
    subTree2.type = 2
    return { subTree1, subTree2, type = 2 }
end

function PhysLib.BspTrees.TerrainTree:DivideVH(nodes, center)
    local subTree1, subTree2, subTree3, subTree4 = {}, {}, {}, {}
    local count1, count2, count3, count4 = 0, 0, 0, 0

    local centerY = center.y

    for i = 1, #nodes do
        local v = nodes[i]
        local y = v.y
        if v.x < center.x then
            if y < centerY then
                count1 = count1 + 1
                subTree1[count1] = v
            else
                count2 = count2 + 1
                subTree2[count2] = v
            end
        else
            if y < centerY then
                count3 = count3 + 1
                subTree3[count3] = v
            else
                count4 = count4 + 1
                subTree4[count4] = v
            end
        end
    end
    subTree1.type = 3
    subTree2.type = 3
    subTree3.type = 3
    subTree4.type = 3
    return { subTree1, subTree2, subTree3, subTree4, type = 3 }
end

local boundCheckInterval = 5
local boundCheckCounter = 4
function PhysLib.BspTrees.TerrainTree:GetTerrainSegmentRectangle(nodes)
    local huge = 10e11
    local count = #nodes
    local minX, minY, maxX, maxY = huge, huge, -huge, -huge
    local averageX, averageY = 0, 0

    
    
    --local boolToNumber = BoolToNumber
    for i = 1, count do
        local v = nodes[i]
        local x, y = v.x, v.y

        -- Update sums for average
        averageX = averageX + x
        averageY = averageY + y

        boundCheckCounter = boundCheckCounter + 1
        if boundCheckCounter == boundCheckInterval then
            boundCheckCounter = 0
            -- Update bounds
            
            minX = (v.minX < minX) and v.minX or minX
            maxX = (v.maxX > maxX) and v.maxX or maxX

            minY = (v.minY < minY) and v.minY or minY
            maxY = (v.maxY > maxY) and v.maxY or maxY
            

        end
    end



    return {
        minX = minX,
        minY = minY,
        maxX = maxX,
        maxY = maxY,
        width = maxX - minX,
        height = maxY - minY,
        x = averageX / count,
        y = averageY / count,
        count = count
    }
end



local testTerrainIndex = 100
function PhysLib.BspTrees.TerrainTree:SplitBlocksIntoSegments(blocks, terrainSegments)
    for i = 0, #blocks do
        local block = blocks[i]
        if not block then continue end
        for j = 0, #block do
            local node = block[j]
            local nextIndex = (j + 1) % (#block + 1)
            local nextNode = block[nextIndex]
            

            local minX = math.min(node.pos.x, nextNode.pos.x)
            local minY = math.min(node.pos.y, nextNode.pos.y)
            local maxX = math.max(node.pos.x, nextNode.pos.x)
            local maxY = math.max(node.pos.y, nextNode.pos.y)

            local averageX = (node.pos.x + nextNode.pos.x) / 2
            local averageY = (node.pos.y + nextNode.pos.y) / 2
            local line = {
                posA = node.pos,
                posB = nextNode.pos,
                line = node.nextLine,
                normal = node.nextLineNormal,
                minX = minX,
                minY = minY,
                maxX = maxX,
                maxY = maxY,
                x = averageX,
                y = averageY

            }
            -- EXPENSIVE, temporary, detects internal terrain segments
            -- Only eliminates terrain sides that are directly facing each other, not overlapping each other
            local overlap = false
            for k = 1, #terrainSegments do
                local otherLine = terrainSegments[k]
                if (line.line.x * otherLine.line.x + line.line.y * otherLine.line.y < -0.999 and line.x == otherLine.x and line.y == otherLine.y) then
                    overlap = true
                    if testTerrainIndex > k then testTerrainIndex = testTerrainIndex - 1 end
                    table.remove(terrainSegments, k)
                    
                    break
                end
            end
            if overlap then continue end
            terrainSegments[#terrainSegments + 1] = line

        end
    end
end

function PhysLib.BspTrees.TerrainTree:CircleCollider(position, radius, debug)
    
    local results = {}
    self:CircleCollisionsOnBranch(position, radius, PhysLib.TerrainTree, results, debug, 0)

    if #results == 0 then return { displacement = 0, normal = {x = 0, y = 0}} end
    local lowestDistance = math.huge
    local lowestResult = nil

    for i = 1, #results do
        local result = results[i]
        local distance = result.distance
        if distance < lowestDistance then
            lowestDistance = distance
            lowestResult = result
        end
    end

    local normal = lowestResult.normal
    local distance = lowestResult.distance
    local displacementNum = radius - distance

    return {displacement = displacementNum, normal = normal}


    -- local type1Results = {}


    -- for i = 1, #results do
    --     local result = results[i]
    --     if result.type == 1 then
    --         type1Results[#type1Results + 1] = result
    --     end
    -- end

    -- if #type1Results >= 1 then
    --     results = type1Results
    -- end
    -- if #results == 0 then return { x = 0, y = 0 } end
    -- local averageDisplacement = { x = 0, y = 0 }


    -- for i = 1, #results do
    --     local result = results[i]
    --     local normal = result.normal
    --     local distance = result.distance
    --     local displacementNum = radius - distance

    --     local displacementX = normal.x * displacementNum
    --     local displacementY = normal.y * displacementNum

    --     averageDisplacement.x = averageDisplacement.x + displacementX
    --     averageDisplacement.y = averageDisplacement.y + displacementY
    -- end

    
    -- averageDisplacement.x = averageDisplacement.x / #results
    -- averageDisplacement.y = averageDisplacement.y / #results

    -- return averageDisplacement
end
function PhysLib.BspTrees.TerrainTree:CircleCollisionsOnBranch(position, radius, branch, results, debug, depth)
    if not branch then return end
    
    if branch.deepest then
        -- Deepest level: Test if within the bounding squares of individual nodes
        local links = branch.children

        for i = 1, #links do
            local link = links[i]
            --SpawnCircle(node, 15, White(), 0.04)

            self:CircleCollisionOnLine(position, radius, link, results, debug)
        end
        if debug then
            local color = {r = 255, g = (0 + depth / MaxDepthThisFrame) * 255, b = 0, a = 255}
            HighlightExtents(branch.rect, 0.06, color)
        end
        
        return
    end
    
    
    local x = position.x
    local y = position.y
    local rect = branch.rect
    local children = branch.children

    if debug then
        local color = {r = 255, g = (0 + depth / MaxDepthThisFrame) * 255, b = 0, a = 255}
        HighlightExtents(rect, 0.06, color)
    end
    for i = 1, #children do
        local child = children[i]
        if not child then continue end
        local childRect = child.rect
        local minX = childRect.minX
        local minY = childRect.minY
        local maxX = childRect.maxX
        local maxY = childRect.maxY

        -- Draw a line from child corners to parent corners
        
        if x > minX - radius and x < maxX + radius and y > minY - radius and y < maxY + radius then
            self:CircleCollisionsOnBranch(position, radius, child, results, debug, depth + 1)

        end
    end


end


function PhysLib.BspTrees.TerrainTree:CircleCollisionOnLine(position, radius, line, results, debug)
    -- --SpawnLine(node, link.node, White(), 0.06)

    local positionX = position.x
    local positionY = position.y

    local posA = line.posA
    local posB = line.posB

    local posAX = posA.x
    local posAY = posA.y
    local posBX = posB.x
    local posBY = posB.y
    -- Now you might be thinking to yourself, "DeltaWing, this is actually fucking disgusting", and you'd be correct. However, metatables are horrifically slow, and because
    -- lua is interpreted it is unfortunately much faster to manually type out everything, no matter how soul crushing that may be. Not to mention unreadable.
    -- But it's fast at least!
    local lineX, lineY = line.line.x, line.line.y

    local unNormalizedLineX, unNormalizedLineY = posBX - posAX, posBY - posAY
    local normalX, normalY = line.normal.x, line.normal.y
    local posToNodeAX, posToNodeAY = posAX - positionX, posAY - positionY
    local posToNodeBX, posToNodeBY = posBX - positionX, posBY - positionY




    --SpawnLine(nodeA, nodeB, Green(), 0.06)
    local linkPerpX, linkPerpY = -lineY, lineX


    local crossDistToNodeA = posToNodeAX * linkPerpY - posToNodeAY * linkPerpX
    local crossDistToNodeB = posToNodeBX * linkPerpY - posToNodeBY * linkPerpX


    if (crossDistToNodeA < 0) then
        if debug then
            posA.z = -100
            SpawnCircle(posA, 15, Blue(), 0.04)
        end
        local posToNodeASquaredX = posToNodeAX * posToNodeAX
        local posToNodeASquaredY = posToNodeAY * posToNodeAY
        if posToNodeASquaredX + posToNodeASquaredY > radius * radius then return end
        local dist = math.sqrt(posToNodeASquaredX + posToNodeASquaredY)
        local linkNormalX = -posToNodeAX / dist
        local linkNormalY = -posToNodeAY / dist
        results[#results + 1] = { 
            nodeA = posA, 
            nodeB = posB, 
            normal = { x = linkNormalX, y = linkNormalY }, 
            pos = { x = posA.x, y = posA.y }, 
            distance = dist, 
            material = line.material, 
            type = 2, 
            t = 0, 
            testPos = position, 
            time = time 
        }
        return
    end
    if (crossDistToNodeB > 0) then
        if debug then
            posB.z = -100
            SpawnCircle(posB, 15, Blue(), 0.04)
        end
        local posToNodeBSquaredX = posToNodeBX * posToNodeBX
        local posToNodeBSquaredY = posToNodeBY * posToNodeBY
        if posToNodeBSquaredX + posToNodeBSquaredY > radius * radius then return end
        local dist = math.sqrt(posToNodeBSquaredX + posToNodeBSquaredY)
        local linkNormalX = -posToNodeBX / dist
        local linkNormalY = -posToNodeBY / dist
        results[#results + 1] = { 
            nodeA = posA, 
            nodeB = posB, 
            normal = { x = linkNormalX, y = linkNormalY }, 
            pos = { x = posB.x, y = posB.y }, 
            distance = dist, 
            material = line.material, 
            type = 2, 
            t = 1, 
            testPos = position, 
            time = time 
        }
        -- SpawnCircle(nodeB, 15, Blue(), 0.04)
        -- HighlightUnitVector( { x = nodeB.x, y = nodeB.y }, { x = linkNormalX, y = linkNormalY }, 20, Blue())
        return
    end


    if debug then
        posA.z = -100
        posB.z = -100
        
        SpawnLine(posA, posB, Green(), 0.06)
    end
   
    local dist = -posToNodeAX * normalX + -posToNodeAY * normalY -- dot product (can't have nice things)
   
    if math.abs(dist) < radius then
        local distToNodeA = posToNodeAX * normalY - posToNodeAY * normalX
        local distToNodeB = posToNodeBX * normalY - posToNodeBY * normalX


        -- Collision case 1: Circle is intersecting with the link

        local totalDist = -distToNodeA + distToNodeB
        local t = -distToNodeA / totalDist
        local posX, posY = posAX + unNormalizedLineX * t, posAY + unNormalizedLineY * t

        results[#results + 1] = { 
            nodeA = posA, 
            nodeB = posB, 
            normal = line.normal, 
            pos = { x = posX, y = posY }, 
            distance = dist, 
            material = line.material, 
            type = 1,
            t = t, 
            testPos = position, 
            time = time }
        -- SpawnCircle(nodeA, 15, White(), 0.04)
        -- SpawnCircle(nodeB, 15, White(), 0.04)
        -- HighlightUnitVector( { x = posX, y = posY }, { x = linkNormalX, y = linkNormalY }, 20, Blue())
        return
    end
end