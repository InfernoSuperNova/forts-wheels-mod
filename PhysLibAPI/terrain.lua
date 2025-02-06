--physlib/terrain.lua
Log("Loading terrain")


local terrainTree = PhysLib.BspTrees.TerrainTree
local Terrain = PhysLib.Terrain


Terrain.SpecialTypes = {
    Dynamic = "Dynamic",    -- TO BE IMPLEMENTED
    Late = "Late",          -- TO BE IMPLEMENTED
    Ignored = "Ignored",    -- Done
}

Terrain.SpecialTypeConverter = {
    ["dynamic"] = PhysLib.Terrain.SpecialTypes.Dynamic,
    ["moving"] = PhysLib.Terrain.SpecialTypes.Dynamic,
    ["late"] = PhysLib.Terrain.SpecialTypes.Late,
    ["indexAfterLoad"] = PhysLib.Terrain.SpecialTypes.Late,
    ["ignored"] = PhysLib.Terrain.SpecialTypes.Ignored,
    ["doNotIndex"] = PhysLib.Terrain.SpecialTypes.Ignored
}

Terrain.SpecialBlocks = {
    [Terrain.SpecialTypeConverter["dynamic"]] = {},
    [Terrain.SpecialTypeConverter["late"]] = {},
    [Terrain.SpecialTypeConverter["ignored"]] = {}
}

function Terrain:Index()
    self.Blocks = {}

    local blockCount = GetBlockCount()
    self:IndexSpecialBlocks(blockCount)
    for block = 0, blockCount - 1 do
        
        if Terrain.SpecialBlocks["Late"][block] or Terrain.SpecialBlocks["Ignored"][block] then
            continue
        end
        BlockStatistics.totalBlocks = BlockStatistics.totalBlocks + 1
        self:IndexBlock(block)
    end
end

function PhysLib.Terrain:IndexLate()
    for blockIndex, _ in pairs(self.SpecialBlocks[self.SpecialTypes.Late]) do
        self:IndexBlock(blockIndex)
    end

end

function Terrain:DynamicIndex()
    --TBE
end



function Terrain:IndexSpecialBlocks(blockCount)
    for i = 0, blockCount - 1 do
        for blockName, blockType in pairs(self.SpecialTypeConverter) do
            local index = GetTerrainBlockIndex(blockName .. i)
            if index ~= -1 then
                local tbl = self.SpecialBlocks[blockType]
                tbl[index] = true
            end
        end
    end
end

function Terrain:IndexBlock(blockIndex)

    self.Blocks[#self.Blocks+1] = {}
    local block = self.Blocks[#self.Blocks]
    local vertexCount = GetBlockVertexCount(blockIndex)
    BlockStatistics.totalNodes = BlockStatistics.totalNodes + vertexCount
    if vertexCount > BlockStatistics.largestBlock then
        BlockStatistics.largestBlock = vertexCount
    end
    
    local nodes = {}
    -- Loop 1: Get all node positions
    for currentVertex = 0, vertexCount - 1 do
        local pos = GetBlockVertexPos(blockIndex, currentVertex)
        nodes[currentVertex] = pos
    end

    -- Loop 2: Get all vectors from node to next node and normalize
    local lines = {}
    for currentVertex = 0, vertexCount - 1 do
        local currentIndex = currentVertex
        local nextIndex = (currentVertex + 1) % vertexCount

        local currentNode = nodes[currentIndex]
        local nextNode = nodes[nextIndex]

        local lineX = currentNode.x - nextNode.x
        local lineY = currentNode.y - nextNode.y



        local lineMagnitude = math.sqrt(lineX * lineX + lineY * lineY)

        lines[currentVertex] = {
            x = lineX / lineMagnitude,
            y = lineY / lineMagnitude
        }
    end

    -- Loop 3: Get normal
    for currentVertex = 0, vertexCount - 1 do
        local previousIndex = (currentVertex - 1 + vertexCount) % vertexCount
        local currentIndex = currentVertex

        local previousLine = lines[previousIndex]
        local nextLine = lines[currentIndex]

        local bisectorX = (previousLine.x + nextLine.x) / 2
        local bisectorY = (previousLine.y + nextLine.y) / 2


        local bisectorMagnitude = math.sqrt(bisectorX * bisectorX + bisectorY * bisectorY)

        bisectorX = bisectorX / bisectorMagnitude
        bisectorY = bisectorY / bisectorMagnitude

        local normalX = -bisectorY
        local normalY = bisectorX



        local terrainNode = {
            pos = nodes[currentIndex],
            previousLine = previousLine,
            nextLine = nextLine,
            normal = {
                x = normalX,
                y = normalY
            },
            previousLineNormal = {
                x = -previousLine.y,
                y = previousLine.x
            },
            nextLineNormal = {
                x = -nextLine.y,
                y = nextLine.x
            }
        }

        block[currentVertex] = terrainNode
    end
    -- loop 4: assign next node
    for currentVertex = 0, vertexCount - 1 do
        local nextIndex = (currentVertex + 1) % vertexCount

        local currentNode = block[currentVertex]
        local nextNode = block[nextIndex]

        currentNode.nextNode = nextNode
        nextNode.previousNode = currentNode

    end
end