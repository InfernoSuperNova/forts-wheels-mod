RoadLinks = {}
function IndexRoadLinks()
    RoadLinks = {}
    EnumerateStructureLinks(0, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", true)
    EnumerateStructureLinks(2, -1, "PlaceRoadLinksInTable", true)
end

function PlaceRoadLinksInTable(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if saveName == RoadSaveName then 
        table.insert(RoadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end



function ApplyForceToRoadLinks(nodeA, nodeB, displacement)
    local newDisplacement = {x = -displacement.x * SpringConst, y = -displacement.y * SpringConst}
    dlc2_ApplyForce(nodeA, newDisplacement)
    dlc2_ApplyForce(nodeB, newDisplacement)

end