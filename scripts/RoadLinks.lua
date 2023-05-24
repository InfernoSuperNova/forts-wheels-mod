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
function IndexRoadLinks(frame)
    
    RoadLinks = {}
    
    if frame % 25 == 0 then
        RoadStructures = {}
    end
    RoadCoords = {}
    RoadStructureBoundaries = {}
    EnumerateStructureLinks(0, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(2, -1, "PlaceRoadLinksInTable", false)

    -- for i = 1, 2 do
    --     for team, _ in pairs(data.teams[i]) do
    --         EnumerateStructureLinks(team, -1, "PlaceRoadLinksInTable", false)
    --     end
    -- end
    EnumerateStructureLinks(101, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(201, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(301, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(401, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(102, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(202, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(302, -1, "PlaceRoadLinksInTable", false)
    EnumerateStructureLinks(402, -1, "PlaceRoadLinksInTable", false)
    IndexRoadStructures(frame)
end


function PlaceRoadLinksInTable(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if saveName == RoadSaveName then 
        table.insert(RoadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end


function IndexRoadStructures(frame)
    if frame % 25 == 0 then
        for _, links in pairs(RoadLinks) do
            local structure = NodeStructureId(links.nodeA)
            if not RoadStructures[structure] then RoadStructures[structure] = {} end
            table.insert(RoadStructures[structure], links)
        end
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
            SpawnCircle(circle, circle.r, { r = 255, g = 100, b = 100, a = 255 }, 0.04)
        end
    end
end

function ApplyForceToRoadLinks(nodeA, nodeB, displacement)
    if displacement then
        local newDisplacement = {x = -displacement.x * SpringConst, y = -displacement.y * SpringConst}
        dlc2_ApplyForce(nodeA, newDisplacement)
        dlc2_ApplyForce(nodeB, newDisplacement)
    end
    

end