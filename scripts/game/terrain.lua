
function IndexTerrainBlocks()
    BlockStatistics.totalNodes = 0
    data.terrainCollisionBoxes = {}
    local terrainBlockCount = GetBlockCount()
    BlockStatistics.totalBlocks = terrainBlockCount

    IndexNamedBlocks(terrainBlockCount)
    --loop through all terrain blocks
    for currentBlock = 0, terrainBlockCount - 1 do
        if SpecialTerrain.ignored[currentBlock] ~= true then
            IndexTerrainBlock(currentBlock)
        else
            Terrain[currentBlock + 1] = {}
        end
    end
end

function IndexTerrainBlock(terrainBlock)
    --create new array for that block
    Terrain[terrainBlock + 1] = {}
    local vertexCount = GetBlockVertexCount(terrainBlock)
    BlockStatistics.totalNodes = BlockStatistics.totalNodes + vertexCount
    if BlockStatistics.largestBlock < vertexCount then BlockStatistics.largestBlock = vertexCount end
    --loop through all vertexes in that block
    for currentVertex = 0, vertexCount - 1 do
        --adds to table for maths
        Terrain[terrainBlock + 1][currentVertex + 1] = GetBlockVertexPos(terrainBlock, currentVertex)
    end
    data.terrainCollisionBoxes[terrainBlock + 1] = MinimumCircularBoundary(Terrain[terrainBlock + 1])
    if ModDebug.collision == true then
        --SpawnCircle(data.terrainCollisionBoxes[terrainBlock + 1], data.terrainCollisionBoxes[terrainBlock + 1].r, {r = 255, g = 255, b = 255, a = 255}, 0.04)
    end
end

function IndexNamedBlocks(BlockCount)
    SpecialTerrain = 
    {["moving"] = {}, 
    ["ignored"] = {}}
    for specialIndex = 1, BlockCount do
        local movingTerrainIndex = GetTerrainBlockIndex("moving" .. specialIndex)
        if movingTerrainIndex ~= -1 then
            table.insert(SpecialTerrain["moving"], movingTerrainIndex)
        end
        local ignoredTerrainIndex = GetTerrainBlockIndex("ignored" .. specialIndex)
        if ignoredTerrainIndex ~= -1 then
            SpecialTerrain["ignored"][ignoredTerrainIndex] = true
        end
    end
    
end

function IndexMovingBlocks()
    for key, terrainIndex in pairs(SpecialTerrain["moving"]) do
        IndexTerrainBlock(terrainIndex)
    end
end

    








