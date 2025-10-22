


--scripts/utility/physLib/physLib.lua
--#region class table
PhysLib = {
    Render = {},
    Structures = {},
    BspTrees = {
        ObjectTree = {},
        StructureTree = {},
        Helper = {},
        TerrainTree = {}
    },
    NodesRaw = {},
    Nodes = {},

    ExistingLinks = {},
    Links = {},
    LinksTree = {},

    PhysicsObjects = {
        Objects = {},
        FlattenedObjects = {},
        ObjectsTree = {},
        globalId = 0
    },
    API = {},
    Definitions = {
        Links = {}
    },
    Terrain = {
        Blocks = {}
    }
}
--#endregion


dofile(path .. "/PhysLibAPI/terrain.lua")
dofile(path .. "/PhysLibAPI/structures.lua")
dofile(path .. "/PhysLibAPI/bspTrees/terrainTree.lua")
dofile(path .. "/PhysLibAPI/bspTrees/structureTree.lua")


function PhysLib:Load()
    PhysLib.PhysicsObjects.Objects = data.physicsObjects or PhysLib.PhysicsObjects.Objects
    PhysLib.Nodes = {}
    PhysLib.NodesRaw = {}
    PhysLib.ExistingLinks = {}
    PhysLib.Links = {}
    PhysLib.LinksTree = {}

    BetterLog("Calling enumerate structurelinksc")
    EnumerateStructureLinks(0, -1, "c", true)
    EnumerateStructureLinks(1, -1, "c", true)
    EnumerateStructureLinks(2, -1, "c", true)
    self.Structures:UpdateNodePositions()
    EnumerateStructureLinks(0, -1, "d", true)
    EnumerateStructureLinks(1, -1, "d", true)
    EnumerateStructureLinks(2, -1, "d", true)
    self.BspTrees.StructureTree:Subdivide(PhysLib.Links)
    local count = 0
    for k, v in pairs(PhysLib.NodesRaw) do
        count = count + 1
    end
    BetterLog("Node count: " .. count)
    BetterLog("Other node count: " .. NodeCount(0) + NodeCount(1) + NodeCount(2))

    PhysLib.Terrain:Index()
    PhysLib.BspTrees.TerrainTree:Subdivide()
end

function PhysLib:LateLoad()
    local count = 0
    for k, v in pairs(PhysLib.Terrain.SpecialBlocks[PhysLib.Terrain.SpecialTypes.Late]) do
        count = count + 1
    end
    if count > 0 then
        PhysLib.Terrain:IndexLate()
        PhysLib.BspTrees.TerrainTree:Subdivide()
    end
    
end

function UpdatePhysLib(frame)

    PhysLib:Update(frame)
end
data.framesSinceLastPhysLibStructureUpdate = 0
function PhysLib:Update(frame)

    self.Structures:UpdateNodePositions()

    PhysLib.ExistingLinks = {}
    
    data.framesSinceLastPhysLibStructureUpdate = data.framesSinceLastPhysLibStructureUpdate + 1
    if data.framesSinceLastPhysLibStructureUpdate % 25 == 0 or self.NodeTableNeedsUpdating then
        data.framesSinceLastPhysLibStructureUpdate = 0
        PhysLib.Links = {}
        EnumerateStructureLinks(0, -1, "d", true)
        EnumerateStructureLinks(1, -1, "d", true)
        EnumerateStructureLinks(2, -1, "d", true)
        self.NodeTableNeedsUpdating = false
    end
    
    self.BspTrees.StructureTree:Subdivide(PhysLib.Links)
    
end


function PhysLib:OnNodeCreated(nodeId, teamId, pos, foundation, selectable, extrusion)
    -- Just assign pos since we're using the x and y directly from that
    pos.links = {}
    pos.id = nodeId
    pos.GetVelocity = function() if pos.velocity then return pos.velocity else
            pos.velocity = NodeVelocity(nodeId)
            return pos.velocity
        end end
    PhysLib.NodesRaw[nodeId] = pos
    self.NodeTableNeedsUpdating = true
end

function PhysLib:OnNodeDestroyed(nodeId, selectable)
    local node = PhysLib.NodesRaw[nodeId]
    if not node then return end
    local linkedToNodes = node.links
    for otherLinkedNodeId, otherLink in pairs(linkedToNodes) do
        otherLink.node.links[nodeId] = nil
    end
    PhysLib.NodesRaw[nodeId] = nil
    self.NodeTableNeedsUpdating = true
end

function PhysLib:OnNodeBroken(thisNodeId, nodeIdNew)
    -- Step 1, clear the links from the things that the node is linked to
    local existingNode = PhysLib.NodesRaw[thisNodeId]
    local linkedToNodes = existingNode.links
    for otherLinkedNodeId, otherLink in pairs(linkedToNodes) do
        otherLink.node.links[thisNodeId] = nil
    end

    -- Step 2, delete the node
    PhysLib.NodesRaw[thisNodeId] = nil
    -- Step 3, add the two nodes as normal
    local nodeA = NodePosition(thisNodeId)
    nodeA.links = {}
    nodeA.id = thisNodeId
    PhysLib.NodesRaw[thisNodeId] = nodeA
    local nodeB = NodePosition(nodeIdNew)
    nodeB.links = {}
    nodeB.id = nodeIdNew
    PhysLib.NodesRaw[nodeIdNew] = nodeB
    -- Step 4, recursively readd links to the nodes
    self:AddLinksRecursive(thisNodeId)
    self:AddLinksRecursive(nodeIdNew)

    self.NodeTableNeedsUpdating = true
end

function PhysLib:OnLinkCreated(teamId, saveName, nodeIdA, nodeIdB, pos1, pos2, extrusion)
    local nodeA = PhysLib.NodesRaw[nodeIdA]
    local nodeB = PhysLib.NodesRaw[nodeIdB]


    nodeA.links[nodeIdB] = { node = nodeB, material = saveName }
    nodeB.links[nodeIdA] = { node = nodeA, material = saveName }
    self.NodeTableNeedsUpdating = true
end

function PhysLib:OnLinkDestroyed(teamId, saveName, nodeIdA, nodeIdB, breakType)
    local nodeA = PhysLib.NodesRaw[nodeIdA]
    local nodeB = PhysLib.NodesRaw[nodeIdB]

    nodeA.links[nodeIdB] = nil
    nodeB.links[nodeIdA] = nil

    self.NodeTableNeedsUpdating = true
end
--#endregion
--#region Events utility

function PhysLib:AddLinksRecursive(nodeId)
    local node = PhysLib.NodesRaw[nodeId]

    local linkCount = NodeLinkCount(nodeId)

    for index = 0, linkCount - 1 do
        local otherNodeId = NodeLinkedNodeId(nodeId, index)
        local otherNode = PhysLib.NodesRaw[otherNodeId]
        local saveName = GetLinkMaterialSaveName(nodeId, otherNodeId)
        node.links[otherNodeId] = { node = otherNode, material = saveName }
        otherNode.links[nodeId] = { node = node, material = saveName }
    end
end


function PhysLib:UpdateNodeTable()
    PhysLib.Nodes = FlattenTable(PhysLib.NodesRaw)
end

function PhysLib:CircleCollider(pos, radius, debug)
    debug = debug or false
    local result = PhysLib.BspTrees.TerrainTree:CircleCollider(pos, radius, debug)
    local result2 = PhysLib.BspTrees.StructureTree:CircleCollider(pos, radius, debug)

    if result.displacement > result2.displacement then
        return result
    end
    return result2
end