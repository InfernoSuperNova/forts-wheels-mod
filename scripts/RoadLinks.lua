RoadLinks = {}
function IndexRoadLinks()
    RoadLinks = {}
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", false)
    --BetterLog(RoadLinks)
    for k, link in pairs(RoadLinks) do
        local posA = NodePosition(link["nodeA"])
        local posB = NodePosition(link["nodeB"])
    end
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