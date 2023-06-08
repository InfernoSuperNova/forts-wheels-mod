

--[[
{
    [structureId] = {
        DeviceTeam = 101,
        DeviceId = 54,
        SaveName = "bob",
        Position = {x, y},

    }
}

]]


function GetDeviceCounts()
    DeviceCounts = {}  
    for side = 0, 2 do
        DeviceCounts[side] = GetDeviceCountSide(side)
    end
end
function IndexDevices()
    Devices = {}
    for side = 0, 2 do
        local count = DeviceCounts[side]
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            local structureId = GetDeviceStructureId(id)
            local team = GetDeviceTeamId(id)
            local SaveName = GetDeviceType(id)
            local pos = GetDevicePosition(id)
            local nodeA = GetDevicePlatformA(id)
            local nodeB = GetDevicePlatformB(id)
            table.insert(Devices, {
                strucId = structureId,
                team = team,
                id = id,
                saveName = SaveName,
                pos = pos,
                nodeA = nodeA,
                nodeB = nodeB,
            })
        end
    end

    EnumerateCarDevices()
end

function EnumerateCarDevices()
    Motors = {}
    Gearboxes ={}
    for _, device in pairs(Devices) do
        if IsDeviceFullyBuilt(device.id) then
            if CheckSaveNameTable(device.saveName, GEARBOX_SAVE_NAME) then
                if not Gearboxes[device.strucId] then
                    Gearboxes[device.strucId] = 1
                else
                    Gearboxes[device.strucId] = Gearboxes[device.strucId] + 1
                end
            elseif CheckSaveNameTable(device.saveName, ENGINE_SAVE_NAME) then
                if not Motors[device.strucId] then
                    Motors[device.strucId] = 1
                else
                    Motors[device.strucId] = Motors[device.strucId] + 1
                end
            end
        end
    end

end

function FindDeviceInMasterIndex(id)
    for _, device in pairs(Devices) do
        if id == device.id then return device end
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
    IndexRoadStructures(frame)
end

function DetermineLinks(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if CheckSaveNameTable(saveName, ROAD_SAVE_NAME) then 
        table.insert(data.roadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end



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

    
function DebugHighlightTerrain(frame)

        for index, boundary in pairs(data.terrainCollisionBoxes) do
            if ModDebug.collision == true then
                local colour1 = {r = 255, g = 255, b = 255, a = 255}
                local colour2 = {r = 150, g = 150, b = 150, a = 255}
                SpawnCircle(boundary, boundary.r, colour1, 0.04)
                HighlightPolygon(boundary.square, colour2)
                HighlightPolygon(Terrain[index], colour2)
            end
        end

    
end






function GetWheelEffectPath(sprocketType, saveName)
    for wheelType, names in pairs(WHEEL_SAVE_NAMES) do
        if CheckSaveNameTable(saveName, names) then
            return TRACK_SPROCKET_EFFECT_PATHS[sprocketType][wheelType]

        end
    end
end


function GetWheelStats(device)
    local wheelStats = {}
    for wheelType, names in pairs(WHEEL_SAVE_NAMES) do
        if device.saveName == names[1] then
            wheelStats.pos = GetOffsetDevicePos(device, WHEEL_SUSPENSION_HEIGHTS[wheelType])
            wheelStats.radius = WHEEL_RADIUSES[wheelType]
        elseif device.saveName == names[2] then
            wheelStats.pos = GetOffsetDevicePos(device, -WHEEL_SUSPENSION_HEIGHTS[wheelType])
            wheelStats.radius = WHEEL_RADIUSES[wheelType]
        end
    end

    return wheelStats
end

