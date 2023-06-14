
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
function UpdateRoads(frame)
    ApplyRoadForces()
end
function CheckNewRoadLinks(saveName, nodeA, nodeB)
    if CheckSaveNameTable(saveName, ROAD_SAVE_NAME) then
        table.insert(data.roadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
end
function DestroyOldRoadLinks(saveName, nodeA, nodeB)
    if CheckSaveNameTable(saveName, ROAD_SAVE_NAME) then
        for key, link in pairs(data.roadLinks) do

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
AccumulatedRoadForces = {}
function AccumulateForceOnRoad(nodeA, nodeB, displacement)
    local id = nodeA .. "_" .. nodeB
    if not displacement then return end
    if not AccumulatedRoadForces[id] then 
        AccumulatedRoadForces[id] = {
            nodeA = nodeA,
            nodeB = nodeB,
            displacement = displacement
        }
    else
        AccumulatedRoadForces[id].displacement = {
            x = AccumulatedRoadForces[id].displacement.x + displacement.x,
            y = AccumulatedRoadForces[id].displacement.y + displacement.y
        }
    end
    
end

function ApplyRoadForces()
    for _, road in pairs(AccumulatedRoadForces) do
        if road.displacement then
            --Get velocity of nodes
            local velocityA = NodeVelocity(road.nodeA)
            local velocityB = NodeVelocity(road.nodeB)
            --oddly enough, the velocity of the two links have to be averaged to avoid cataclysmic explosions - Perhaps this is because the nodes are linked to each other?
            local velocity = AverageCoordinates({velocityA, velocityB})
            local surfaceNormal = NormalizeVector(road.displacement)
            if math.abs(road.displacement.y) > 0 then
                -- local DampenedForce = {
                --     nodeA = {
                --         x = SpringDampenedForce(SPRING_CONST, -road.displacement.x, DAMPENING * math.abs(surfaceNormal.x) ^ 4, velocityA.x),
                --         y = SpringDampenedForce(SPRING_CONST, -road.displacement.y, DAMPENING * math.abs(surfaceNormal.y) ^ 4, velocityA.y)
                --     },
                --     nodeB = {
                --         x = SpringDampenedForce(SPRING_CONST, -road.displacement.x, DAMPENING * math.abs(surfaceNormal.x) ^ 4, velocityB.x),
                --         y = SpringDampenedForce(SPRING_CONST, -road.displacement.y, DAMPENING * math.abs(surfaceNormal.y) ^ 4, velocityB.y)
                --     },
                --     --x = SpringDampenedForce(springConst, displacement.x, dampening, velocity.x),
                    
                -- }
                local DampenedForce = {
                    x = SpringDampenedForce(SPRING_CONST, -road.displacement.x, DAMPENING * math.abs(surfaceNormal.x) ^ 4, velocity.x),
                    y = SpringDampenedForce(SPRING_CONST, -road.displacement.y, DAMPENING * math.abs(surfaceNormal.y) ^ 4, velocity.y)
                }
                dlc2_ApplyForce(road.nodeA, DampenedForce)
                dlc2_ApplyForce(road.nodeB, DampenedForce)
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

    end
    AccumulatedRoadForces = {}

end