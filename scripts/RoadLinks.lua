
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

function CheckNewRoadLinks(saveName, nodeA, nodeB)
    if CheckSaveNameTable(saveName, ROAD_SAVE_NAME) then
        table.insert(data.roadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
end
function DestroyOldRoadLinks(saveName, nodeA, nodeB)
    if CheckSaveNameTable(saveName, ROAD_SAVE_NAME) then
        for key, link in pairs(data.roadLinks) do
            BetterLog(link)
            if nodeA == link.nodeA and nodeB == link.nodeB then
                table.remove(data.roadLinks, key)
            end
        end
    end
end

function CheckOldRoadLinks()
    for key, link in pairs(data.roadLinks) do
        local saveName = GetLinkMaterialSaveName(link.nodeA, link.nodeB)
        if not (IsNodeLinkedTo(link.nodeA, link.nodeB) and CheckSaveNameTable(saveName, ROAD_SAVE_NAME)) then
            table.remove(data.roadLinks, key)
        end
    end

end

function IndexRoadStructures(frame)
    if frame % 25 == 0 then
        RoadStructureBoundaries = {}
        for _, links in pairs(data.roadLinks) do
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
        if ModDebug.collision then
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
                x = SpringDampenedForce(SPRING_CONST, -displacement.x, DAMPENING * math.abs(surfaceNormal.x) * 0.2, avgVelocity.x),
                y = SpringDampenedForce(SPRING_CONST, -displacement.y, DAMPENING * math.abs(surfaceNormal.y) * 0.2, avgVelocity.y)
            }
            dlc2_ApplyForce(nodeA, DampenedForce)
            dlc2_ApplyForce(nodeB, DampenedForce)
        end
        
    end
    

end