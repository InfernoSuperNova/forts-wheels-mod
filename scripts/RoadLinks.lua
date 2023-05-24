RoadLinks = {}
--[[
{
    {nodeA = coord, nodeB = coord}
    {nodeA = coord, nodeB = coord}
    {nodeA = coord, nodeB = coord}
}
]]
RoadStructures = {}
--[[
    structure1 ={nodeA = coord, nodeB = coord}
    structure2 = {nodeA = coord, nodeB = coord}
]]
RoadCoords = {}
RoadStructureBoundaries = {}
--[[
    {
        [structure] = {
            x,
            y,
            rad
        }

    }
]]
function IndexRoadLinks()
    RoadLinks = {}
    RoadStructures = {}
    RoadCoords = {}
    RoadStructureBoundaries = {}
    EnumerateStructureLinks(0, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", false)
    IndexRoadStructures()
end


function PlaceRoadLinksInTable(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if saveName == RoadSaveName then 
        table.insert(RoadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end


function IndexRoadStructures()
    for _, links in pairs(RoadLinks) do
        local structure = GetDeviceStructureId(links.nodeA)
        if not RoadStructures[structure] then RoadStructures[structure] = {} end
        table.insert(RoadStructures[structure], links)
    end
    for structure, links in pairs(RoadStructures) do
        if not RoadCoords[structure] then RoadCoords[structure] = {} end
        for _, link in pairs(links) do
            table.insert(RoadCoords[structure], NodePosition(link.nodeA))
            table.insert(RoadCoords[structure], NodePosition(link.nodeB))
        end
        local circle = MinimumCircularBoundary(RoadCoords[structure])
        RoadStructureBoundaries[structure] = circle
        if ModDebug then
            SpawnCircle(circle, circle.r, {r = 255, g = 100, b = 100, a = 255}, 0.04)
        end
        
    end
    
end

function ApplyForceToRoadLinks(nodeA, nodeB, displacement)
    local newDisplacement = {x = -displacement.x * SpringConst, y = -displacement.y * SpringConst}
    dlc2_ApplyForce(nodeA, newDisplacement)
    dlc2_ApplyForce(nodeB, newDisplacement)

end