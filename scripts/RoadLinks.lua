RoadLinks = {}
function IndexRoadLinks()
    RoadLinks = {}
    EnumerateStructureLinks(1, -1, "PlaceRoadLinksInTable", false)
    --BetterLog(RoadLinks)
    for k, link in pairs(RoadLinks) do
        local posA = NodePosition(link["nodeA"])
        local posB = NodePosition(link["nodeB"])
        HighlightCoords({posA, posB})
    end
end

function PlaceRoadLinksInTable(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if saveName == "armour" then 
        table.insert(RoadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end