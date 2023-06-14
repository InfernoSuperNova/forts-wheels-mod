
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
        local boundary = MinimumCircularBoundary(RoadCoords[structure])
        RoadStructureBoundaries[structure] = boundary
        if ModDebug.collision then
            local colour1 = { r = 255, g = 100, b = 100, a = 255 }
            local colour2 = { r = 255, g = 150, b = 100, a = 255 }
            local colour3 = { r = 255, g = 0, b = 0, a = 255 }
            SpawnCircle(boundary, boundary.r, colour2, 0.04)
            HighlightPolygon(boundary.square, colour1)
            HighlightPolygon(RoadCoords[structure], colour3)
        end
    end
end

function ApplyForceToRoadLinks(nodeA, nodeB, displacement, wheelVelocity)
    if displacement then
        local velocityA = NodeVelocity(nodeA)
        local velocityB = NodeVelocity(nodeB)
        local avgVelocity = AverageCoordinates({wheelVelocity, velocityA, velocityB})
        local surfaceNormal = NormalizeVector(displacement)
        if math.abs(displacement.y) > 0 then
            local DampenedForce = {
                --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
                x = SpringDampenedForce(SPRING_CONST, -displacement.x, DAMPENING * math.abs(surfaceNormal.x) * 0.2, avgVelocity.x),
                y = SpringDampenedForce(SPRING_CONST, -displacement.y, DAMPENING * math.abs(surfaceNormal.y) * 0.2, avgVelocity.y)
            }
            BetterLog("Road Velocity")
            BetterLog(avgVelocity)
            BetterLog("Wheel Velocity")
            dlc2_ApplyForce(nodeA, DampenedForce)
            dlc2_ApplyForce(nodeB, DampenedForce)
        end 
            if ModDebug.forces then
                local dir = { x = -road.displacement.x, y = -road.displacement.y }
                local posA = NodePosition(road.nodeA)
                local posB = NodePosition(road.nodeB)
                local colour = { r = 255, g = 100, b = 100, a = 255 }
                HighlightDirectionalVector(posA, dir, 3, colour)
                HighlightDirectionalVector(posB, dir, 3, colour)
            end
        end


-- if data.brakes[structureId] == true then displacement.x = 0 end
--     local surfaceNormal = NormalizeVector(displacement)
--     local DampenedForce = {
--         --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
--         x = SpringDampenedForce(SPRING_CONST, displacement.x, DAMPENING * math.abs(surfaceNormal.x) * 0.2, velocity.x),
--         y = SpringDampenedForce(SPRING_CONST, displacement.y, DAMPENING * math.abs(surfaceNormal.y), velocity.y)
--     }
--     BetterLog({"Force applied to wheel:", DampenedForce})
--     if FinalSuspensionForces[device.id] and DampenedForce.x then
--         FinalSuspensionForces[device.id] = {
--             x = FinalSuspensionForces[device.id].x + DampenedForce.x,
--             y = FinalSuspensionForces[device.id].y + DampenedForce.y
--         }
--     else
--         FinalSuspensionForces[device.id] = DampenedForce
--     end