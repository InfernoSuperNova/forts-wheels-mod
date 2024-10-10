
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
    -- ApplyRoadForces()
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

function IndexLinks()
    EnumerateStructureLinks(0, -1, "DetermineLinks", true)
    EnumerateStructureLinks(3, -1, "DetermineLinks", true)
    for side, teams in pairs(data.teams) do
        for index, team in pairs(teams) do
            EnumerateStructureLinks(team, -1, "DetermineLinks", false)
        end
    end
    

end
function UpdateLinks(frame)
    
    RoadCoords = {}
    
    if frame % 25 == 0 then
        RoadStructures = {}
        CheckOldRoadLinks()
    end
    -- IndexRoadStructures(frame)
end

function DetermineLinks(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if ROAD_SAVE_NAME[saveName] then 
        table.insert(data.roadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end

