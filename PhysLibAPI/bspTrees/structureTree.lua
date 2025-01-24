--scripts/utility/physLib/bspTrees/structureTree.lua
local Helper = PhysLib.BspTrees.Helper
--#region Generation
function PhysLib.BspTrees.StructureTree:Subdivide(links)
    --for i = 1, 50 do
   PhysLib.LinksTree = self:SubdivideLinkGroup(links, 0)
    --end
end


function PhysLib.BspTrees.StructureTree:SubdivideLinkGroup(nodes, depth)
    
    local rect = self:GetLinkRectangle(nodes) -- approximate
    -- if depth > 1000 then 
    --     BetterLog(nodes.type)
    --     BetterLog(rect)
    --     HighlightExtents(rect, 20, Red())
    --     return
    -- end
    local count = rect.count
    --Degenerate case: two nodes positioned mathematically perfectly on top of each other (this occurs when nodes rotate too far and split)
    if count <= 1 or (rect.width * rect.height == 0) then
        rect = nodes[1]

        for i = 1, count do
            local node = nodes[i]
            rect.minX = (rect.minX < node.minX) and rect.minX or node.minX
            rect.maxX = (rect.maxX > node.maxX) and rect.maxX or node.maxX
            rect.minY = (rect.minY < node.minY) and rect.minY or node.minY
            rect.maxY = (rect.maxY > node.maxY) and rect.maxY or node.maxY
        end
        return {children = nodes, rect = rect, deepest = true}
    end

    local widthHeightRatio = rect.width / rect.height

    local subTree

    if (widthHeightRatio > SDTYPE_BOTH_THRESHOLD_MAX) then
        --Divide vertically
        subTree = self:DivideV(nodes, rect.x)
    elseif (widthHeightRatio < SDTYPE_BOTH_THRESHOLD_MIN) then
        --Divide horizontally
        subTree = self:DivideH(nodes, rect.y)
    else
        --Divide both
        subTree = self:DivideVH(nodes, rect)
    end
    local children = {}
    for i = 1, #subTree do
        local group = subTree[i]

        if group == 0 or #group == 0 then continue end
        children[#children + 1] = self:SubdivideLinkGroup(group, depth + 1)
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
function PhysLib.BspTrees.StructureTree:DivideV(nodes, center)
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

function PhysLib.BspTrees.StructureTree:DivideH(nodes, center)
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

function PhysLib.BspTrees.StructureTree:DivideVH(nodes, center)
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
--#endregion
--#endregion
--#region CircleCast
function PhysLib.BspTrees.StructureTree:CircleCast(posA, posB, radius)
    local results = {}
    self:GetLinksCollidingWithCapsuleBranch(posA, posB, radius, PhysLib.LinksTree, results)

    local backgroundLessResults = {}
    local portalResults = {}
    for i = 1, #results do
        if results[i].link.material == "backbracing" then continue end
        if results[i].link.material == "portal" then
            portalResults[#portalResults + 1] = results[i]
            continue
        end
        backgroundLessResults[#backgroundLessResults + 1] = results[i]
        
    end
    if #backgroundLessResults == 0 then return backgroundLessResults, portalResults end
    results = backgroundLessResults
    local filteredResults = {}

    for i = 1, #results do
        local result = results[i]
        if result.type == 1 then 
            filteredResults[#filteredResults + 1] = result

         end
    end
    if #filteredResults > 0 then results = filteredResults end
    --if #filteredResults == 0 then return {} end -- TEMPORARY
    local lowestResultT = 1.1
    for i = 1, #results do
        local result = results[i]
        if result.t < lowestResultT then
            lowestResultT = result.t
        end
    end
    local finalResults = {}
    for i = 1, #results do
        local result = results[i]
        if result.t == lowestResultT then
            finalResults[#finalResults + 1] = result
        end
    end

    
    local newResults = {}
    for i = 1, #finalResults do 
        local result = finalResults[i]
        local testPos = Vec2Lerp(posA, posB, result.t)
        self:CircleCollisionOnLink(testPos, radius, result.nodeA, result.nodeB, result.link, newResults, result.t, posA)
    end
    newResults.t = lowestResultT
    return newResults, portalResults
end

function PhysLib.BspTrees.StructureTree:GetLinksCollidingWithCapsuleBranch(posA, posB, radius, branch, results)
    if not branch then return end
    if branch.deepest then
        -- Deepest level: Test if within the bounding squares of individual nodes
        local links = branch.children

        for i = 1, #links do
            local link = links[i]
            self:GetLinksCollidingWithCapsule(posA, posB, radius, link, results)
            -- SpawnLine(link.nodeA, link.nodeB, Green(), 0.06)
            -- HighlightExtents(link, 0.06, Blue())
            -- if link.minX < branch.rect.minX then BetterLog("What the fuck") end
        end
        return
    end


    --HighlightExtents(rect, 0.06, Red())
    local children = branch.children
    for i = 1, #children do
        local child = children[i]
        if not child then continue end
        local childRect = child.rect
        if Helper:LineCollidesWithRect(posA, posB, radius, childRect) then
            self:GetLinksCollidingWithCapsuleBranch(posA, posB, radius, child, results)
        end
    end
end

function PhysLib.BspTrees.StructureTree:GetLinksCollidingWithCapsule(posA, posB, radius, link, results)
    local nodeA = link.nodeA
    local nodeB = link.nodeB

    local closestPointCapsuleTime, linkT,
    closestDistance = Helper:ClosestPointsBetweenLines(posA, posB, nodeA, nodeB)
    if closestDistance > radius * radius then return end

    results[#results + 1] = {
        nodeA = nodeA,
        nodeB = nodeB,
        link = link,
        t = closestPointCapsuleTime,
        linkT = linkT,
        distanceSquared = closestDistance,
        type = (linkT == 0 or linkT == 1) and 0 or 1
    }
end
--#endregion
--#region utility
function PhysLib.BspTrees.StructureTree:GetLinkRectangle(nodes)
    local huge = 10e11
    local count = #nodes
    local minX, minY, maxX, maxY = huge, huge, -huge, -huge
    local averageX, averageY = 0, 0

    local boundCheckInterval = 20
    local boundCheckCounter = 19
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
            
            minX = (x < minX) and x or minX
            maxX = (x > maxX) and x or maxX

            minY = (y < minY) and y or minY
            maxY = (y > maxY) and y or maxY
            
            -- BetterLog(minX)
            -- BetterLog(x)
            -- BetterLog(minX < x)
            -- BetterLog(minX * (minX < x and 1 or 0) + x * (x < minX and 1 or 0))
            -- local thing = 5 * (4 < 3)

            -- minX = minX * (minX <= x and 1 or 0) + x * (x < minX and 1 or 0)
            -- maxX = maxX * (maxX >= x and 1 or 0) + x * (x > maxX and 1 or 0)
            
            -- minY = minY * (minY <= y and 1 or 0) + y * (y < minY and 1 or 0)
            -- maxY = maxY * (maxY >= y and 1 or 0) + y * (y > maxY and 1 or 0)

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
--#endregion
--#region Circle collision
function PhysLib.BspTrees.StructureTree:CircleCollider(pos, radius, debug)
    local results = {}
    self:CircleCollisionsOnBranch(pos, radius, PhysLib.LinksTree, results, debug)

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

    return {displacement = displacementNum, normal = normal, nodeA = lowestResult.nodeA.id, nodeB = lowestResult.nodeB.id}
end

function PhysLib.BspTrees.StructureTree:CircleCollisionsOnBranch(position, radius, branch, results, debug)
    if not branch then return end
    
    if branch.deepest then
        -- Deepest level: Test if within the bounding squares of individual nodes
        local links = branch.children

        for i = 1, #links do
            local link = links[i]
            --SpawnCircle(node, 15, White(), 0.04)

            self:CircleCollisionOnLink(position, radius, link.nodeA, link.nodeB, link, results, _, _, debug)
        end
        if debug and branch.rect ~= nil then
            HighlightExtents(branch.rect, 0.06, Red())
        end
        --HighlightExtents(branch.rect, 0.06, Red())
        return
    end
    
    
    local x = position.x
    local y = position.y
    local rect = branch.rect
    local children = branch.children


    if debug and rect ~= nil then
        HighlightExtents(rect, 0.06, Red())
    end
    --HighlightExtents(rect, 0.06, Red())
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
            self:CircleCollisionsOnBranch(position, radius, child, results, debug)

        end
    end


end






--TODO - this function is being called twice, please fix, also cache normals
-- It may not be feasible to check if a link is already tested, as the cost of checking may be greater than the cost of testing
-- Perhaps we could fix it further up the pipeline?
function PhysLib.BspTrees.StructureTree:CircleCollisionOnLinks(position, radius, node, results, normalCalcPos)
    for _, link in pairs(node.links) do
        self:CircleCollisionOnLink(position, radius, node, link.node, link, results, normalCalcPos)
    end
end



function HighlightUnitVector(pos, direction, mag, col)
    pos.z = -100
    col = col or {r = 255, g = 255, b= 255, a = 255}
    local pos2 = Vec3( pos.x + direction.x * mag, pos.y + direction.y * mag, -100)
    SpawnLine(pos, pos2, col, data.updateDelta * 1.2)
    SpawnCircle(pos, Vec3Dist(pos, pos2) / 5, col, data.updateDelta * 1.2)
end

function PhysLib.BspTrees.StructureTree:CircleCollisionOnLink(position, radius, nodeA, nodeB, link, results, time, normalCalcPos, debug)
    -- --SpawnLine(node, link.node, White(), 0.06)



    local positionX = position.x
    local positionY = position.y
    local nodeAX = nodeA.x
    local nodeAY = nodeA.y
    local nodeBX = nodeB.x
    local nodeBY = nodeB.y

    if (nodeAX == 0 and nodeAY == 0) or (nodeBX == 0 and nodeBY == 0) then return end
    -- Now you might be thinking to yourself, "DeltaWing, this is actually fucking disgusting", and you'd be correct. However, metatables are horrifically slow, and because
    -- lua is interpreted it is unfortunately much faster to manually type out everything, no matter how soul crushing that may be. Not to mention unreadable.
    -- But it's fast at least!
    local linkX, linkY = nodeBX - nodeAX, nodeBY - nodeAY
    local posToNodeAX, posToNodeAY = nodeAX - positionX, nodeAY - positionY
    local posToNodeBX, posToNodeBY = nodeBX - positionX, nodeBY - positionY







    --SpawnLine(nodeA, nodeB, Green(), 0.06)
    local linkPerpX, linkPerpY = -linkY, linkX


    local crossDistToNodeA = posToNodeAX * linkPerpY - posToNodeAY * linkPerpX
    local crossDistToNodeB = posToNodeBX * linkPerpY - posToNodeBY * linkPerpX

    if (crossDistToNodeA > 0) then
        if debug then
            nodeA.z = -100
            SpawnCircle(nodeA, 15, Blue(), 0.04)
        end
        local posToNodeASquaredX = posToNodeAX * posToNodeAX
        local posToNodeASquaredY = posToNodeAY * posToNodeAY
        if posToNodeASquaredX + posToNodeASquaredY > radius * radius then return end
        local dist = math.sqrt(posToNodeASquaredX + posToNodeASquaredY)
        local linkNormalX = -posToNodeAX / dist
        local linkNormalY = -posToNodeAY / dist
        results[#results + 1] = { 
            nodeA = nodeA, 
            nodeB = nodeB, 
            normal = { x = linkNormalX, y = linkNormalY }, 
            pos = { x = nodeA.x, y = nodeA.y }, 
            distance = dist, 
            material = link.material, 
            type = 2, 
            t = 0, 
            testPos = position, 
            time = time 
        }
        -- SpawnCircle(nodeA, 15, Blue(), 0.04)
        -- HighlightUnitVector( { x = nodeA.x, y = nodeA.y }, { x = linkNormalX, y = linkNormalY }, 20, Blue())
        return
    end
    if (crossDistToNodeB < 0) then
        if debug then
            nodeB.z = -100
            SpawnCircle(nodeB, 15, Blue(), 0.04)
        end
        local posToNodeBSquaredX = posToNodeBX * posToNodeBX
        local posToNodeBSquaredY = posToNodeBY * posToNodeBY
        if posToNodeBSquaredX + posToNodeBSquaredY > radius * radius then return end
        local dist = math.sqrt(posToNodeBSquaredX + posToNodeBSquaredY)
        local linkNormalX = -posToNodeBX / dist
        local linkNormalY = -posToNodeBY / dist
        results[#results + 1] = { 
            nodeA = nodeA, 
            nodeB = nodeB, 
            normal = { x = linkNormalX, y = linkNormalY }, 
            pos = { x = nodeB.x, y = nodeB.y }, 
            distance = dist, 
            material = link.material, 
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
        nodeA.z = -100
        nodeB.z = -100
        SpawnLine(nodeA, nodeB, Green(), 0.06)
    end
    local mag = math.sqrt(linkX * linkX + linkY * linkY)
    local linkNormalX, linkNormalY = linkY / mag, -linkX / mag



    local dist = -posToNodeAX * linkNormalX + -posToNodeAY * linkNormalY -- dot product (can't have nice things)
    if dist < 0 then
        dist = -dist
        linkNormalX = -linkNormalX
        linkNormalY = -linkNormalY
    end
    if normalCalcPos then -- use the normal calc position to calculate the normal
        local nodeAToNormalCalcX = normalCalcPos.x - nodeAX
        local nodeAToNormalCalcY = normalCalcPos.y - nodeAY

        local dot = nodeAToNormalCalcX * linkNormalX + nodeAToNormalCalcY * linkNormalY
        if dot < 0 then
            linkNormalX = -linkNormalX
            linkNormalY = -linkNormalY
        end
    end

    if dist < radius then
        local distToNodeA = posToNodeAX * linkNormalY - posToNodeAY * linkNormalX
        local distToNodeB = posToNodeBX * linkNormalY - posToNodeBY * linkNormalX


        -- Collision case 1: Circle is intersecting with the link

        local totalDist = -distToNodeA + distToNodeB
        local t = -distToNodeA / totalDist
        local posX, posY = nodeAX + linkX * t, nodeAY + linkY * t

        results[#results + 1] = { 
            nodeA = nodeA, 
            nodeB = nodeB, 
            normal = { x = linkNormalX, y = linkNormalY }, 
            pos = { x = posX, y = posY }, 
            distance = dist, 
            material = link.material, 
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
--#endregion