--scripts/utility/physLib/structures.lua


--#region Enumeration callback
---@diagnostic disable-next-line: lowercase-global
function c(idA, idB, linkPos, saveName)
    -- TODO: Optimize this to not get the savename in enumerate links as this is slow and most of the time not useful, instead the savename should be collected and then cached by the next thing
    -- to say it is colliding with the link
    
    local nodesRaw = PhysLib.NodesRaw
    local nodeA = nodesRaw[idA]
    local nodeB = nodesRaw[idB]
    local nodeALinks
    local nodeBLinks

    if not nodeA then
        local p = NodePosition(idA)
        nodeA = p
        nodeALinks = {}
        nodeA.links = nodeALinks
        nodeA.id = idA

        nodesRaw[idA] = nodeA
    else
        nodeALinks = nodeA.links
    end
    if not nodeB then
        local p = NodePosition(idB)
        nodeB = p
        nodeBLinks = {}
        nodeB.links = nodeBLinks
        nodeB.id = idB
        nodesRaw[idB] = nodeB
    else
        nodeBLinks = nodeB.links
    end
    nodeALinks[idB] = {node = nodeB, material = saveName}
    nodeBLinks[idA] = {node = nodeA, material = saveName}

    return true
end
---@diagnostic disable-next-line: lowercase-global
function d(idA, idB, linkPos, material)
    if material ~= "RoadLink" then return true end

    local existingLinks = PhysLib.ExistingLinks

    if not existingLinks[idA] then
        existingLinks[idA] = {}
    else
        if existingLinks[idB] and existingLinks[idB][idA] then
            return true
        end
    end
    existingLinks[idA][idB] = true

    local links = PhysLib.Links
    local nodesRaw = PhysLib.NodesRaw
    local nodeA = nodesRaw[idA]
    local nodeB = nodesRaw[idB]
    if not nodeA or not nodeB then return end
    local nodeAx, nodeAy, nodeBx, nodeBy = nodeA.x, nodeA.y, nodeB.x, nodeB.y


    local minX, minY, maxX, maxY
    if nodeAx < nodeBx then
        minX = nodeAx
        maxX = nodeBx
    else
        minX = nodeBx
        maxX = nodeAx
    end
    if nodeAy < nodeBy then
        minY = nodeAy
        maxY = nodeBy
    else
        minY = nodeBy
        maxY = nodeAy
    end

    nodeA.hasRoadLink = true
    nodeB.hasRoadLink = true
    local link = {nodeA = nodeA, nodeB = nodeB, material = material, minX = minX, minY = minY, maxX = maxX, maxY = maxY, x = linkPos.x, y = linkPos.y, width = maxX - minX, height = maxY - minY}
    links[#links + 1] = link
    return true
end
--#endregion
function PhysLib.Structures:UpdateNodePositions()

    for k, v in pairs(PhysLib.Links) do
        local nodeA = v.nodeA
        local nodeB = v.nodeB
        nodeA.hasUpdatedThisFrame = false
        nodeB.hasUpdatedThisFrame = false
    end
    for k, link in pairs(PhysLib.Links) do
        local nodeA = link.nodeA
        local nodeB = link.nodeB

        if not nodeA.hasUpdatedThisFrame then
            nodeA.hasUpdatedThisFrame = true
            local nodePos = NodePosition(nodeA.id)
            nodeA.x = nodePos.x
            nodeA.y = nodePos.y
            nodeA.velocity = NodeVelocity(nodeA.id)
        end
        if not nodeB.hasUpdatedThisFrame then
            nodeB.hasUpdatedThisFrame = true
            local nodePos = NodePosition(nodeB.id)
            nodeB.x = nodePos.x
            nodeB.y = nodePos.y
            nodeB.velocity = NodeVelocity(nodeB.id)
        end

        local nodeAx, nodeAy, nodeBx, nodeBy = nodeA.x, nodeA.y, nodeB.x, nodeB.y


        local minX, minY, maxX, maxY
        if nodeAx < nodeBx then
            minX = nodeAx
            maxX = nodeBx
        else
            minX = nodeBx
            maxX = nodeAx
        end
        if nodeAy < nodeBy then
            minY = nodeAy
            maxY = nodeBy
        else
            minY = nodeBy
            maxY = nodeAy
        end

        link.minX = minX
        link.minY = minY
        link.maxX = maxX
        link.maxY = maxY
    end
end
