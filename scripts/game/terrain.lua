
function IndexTerrainBlocks()
    BlockStatistics.totalNodes = 0
    local terrainBlockCount = GetBlockCount()
    BlockStatistics.totalBlocks = terrainBlockCount

    IndexNamedBlocks(terrainBlockCount)
    --loop through all terrain blocks
    for currentBlock = 0, terrainBlockCount - 1 do
        if SpecialTerrain.ignored[currentBlock] ~= true then
            if SpecialTerrain.late[currentBlock] == true then
            else
                IndexTerrainBlock(currentBlock)
            end
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
    TerrainCorners [terrainBlock + 1] = GetFourOutermostPoints(Terrain[terrainBlock + 1])
end

function IndexNamedBlocks(BlockCount)
    SpecialTerrain = 
    {["moving"] = {}, 
    ["ignored"] = {},
    ["late"] = {},
    }
    for specialIndex = 1, BlockCount do
        local movingTerrainIndex = GetTerrainBlockIndex("moving" .. specialIndex)
        if movingTerrainIndex ~= -1 then
            -- BetterLog("Landcruisers: Found moving block " .. movingTerrainIndex)
            table.insert(SpecialTerrain["moving"], movingTerrainIndex)
        end
        local ignoredTerrainIndex = GetTerrainBlockIndex("ignored" .. specialIndex)
        if ignoredTerrainIndex ~= -1 then
            -- BetterLog("Landcruisers: Found ignored block " .. ignoredTerrainIndex)
            SpecialTerrain["ignored"][ignoredTerrainIndex] = true
        end
        local lateTerrainIndex = GetTerrainBlockIndex("late" .. specialIndex)
        if lateTerrainIndex ~= -1 then
            -- BetterLog("Landcruisers: Found late block " .. lateTerrainIndex)
            SpecialTerrain["late"][lateTerrainIndex] = true
        end
    end
    
end

function IndexMovingBlocks(frame)
    if frame == 5 then
        for terrainIndex, _ in pairs(SpecialTerrain["late"]) do
            IndexTerrainBlock(terrainIndex)
        end
    end
    for key, terrainIndex in pairs(SpecialTerrain["moving"]) do
        IndexTerrainBlock(terrainIndex)
    end
end

    








