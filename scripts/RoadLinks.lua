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
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(2, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(101, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(201, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(301, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(401, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(102, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(202, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(302, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(402, -1, "PlaceRoadLinksInTable", true)
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
        local velocityA = NodeVelocity(nodeA)
        local velocityB = NodeVelocity(nodeB)
        local avgVelocity = AverageCoordinates({velocityA, velocityB})
        local surfaceNormal = NormalizeVector(displacement)
        if math.abs(displacement.y) > 0 then
            local DampenedForce = {
                --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
                x = SpringDampenedForce(SpringConst, -displacement.x, Dampening * math.abs(surfaceNormal.x) * 0.2, avgVelocity.x),
                y = SpringDampenedForce(SpringConst, -displacement.y, Dampening * math.abs(surfaceNormal.y), avgVelocity.y)
            }
            dlc2_ApplyForce(nodeA, DampenedForce)
            dlc2_ApplyForce(nodeB, DampenedForce)
        end
        
    end
    

end