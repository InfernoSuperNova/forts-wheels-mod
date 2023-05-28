

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
    for side = 1, 2 do
        DeviceCounts[side] = GetDeviceCountSide(side)
    end
end
function IndexDevices()
    Devices = {}
    for side = 1, 2 do
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
            if device.saveName == GearboxSaveName then
                if not Gearboxes[device.strucId] then
                    Gearboxes[device.strucId] = 1
                else
                    Gearboxes[device.strucId] = Gearboxes[device.strucId] + 1
                end
            elseif device.saveName == EngineSaveName then
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
    if saveName == RoadSaveName then 
        table.insert(data.roadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end



function IndexTerrainBlocks()
    data.terrainCollisionBoxes = {}
    local terrainBlockCount = GetBlockCount()
    BlockStatistics.totalBlocks = terrainBlockCount
    --loop through all terrain blocks
    for currentBlock = 0, terrainBlockCount - 1 do
        IndexTerrainBlock(currentBlock)
    end

    FindMovingBlocks(terrainBlockCount)
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
        SpawnCircle(data.terrainCollisionBoxes[terrainBlock + 1], data.terrainCollisionBoxes[terrainBlock + 1].r, {r = 255, g = 255, b = 255, a = 255}, 0.04)
    end
end

function FindMovingBlocks(BlockCount)
    MovingTerrain = {}
    for movingIndex = 1, BlockCount do
        local terrainIndex = GetTerrainBlockIndex("Moving Terrain " .. movingIndex)
        if terrainIndex ~= -1 then
            table.insert(MovingTerrain, terrainIndex)
        end
    end
    
end

function IndexMovingBlocks()
    for key, terrainIndex in pairs(MovingTerrain) do
        IndexTerrainBlock(terrainBlock)
    end
end


function DebugHighlightTerrain(frame)
    if frame % 25 == 1 then
        for _, boundary in pairs(data.terrainCollisionBoxes) do
            if ModDebug.collision == true then
                SpawnCircle(boundary, boundary.r, {r = 255, g = 255, b = 255, a = 255}, 1)
            end
        end
    end
    
end