

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
        BetterLog(Gearboxes[device.strucId])
    end
end

function IndexLinks(frame)
    
    RoadLinks = {}
    
    if frame % 25 == 0 then
        RoadStructures = {}
    end
    RoadCoords = {}
    RoadStructureBoundaries = {}
    EnumerateStructureLinks(0, -1, "DetermineLinks", true)
    for side, teams in pairs(data.teams) do
        for index, team in pairs(teams) do
            EnumerateStructureLinks(team, -1, "DetermineLinks", false)
        end
    end
    IndexRoadStructures(frame)
end

function DetermineLinks(nodeA, nodeB, linkPos, saveName, deviceId)
    --BetterLog(saveName)
    if saveName == RoadSaveName then 
        table.insert(RoadLinks, {nodeA = nodeA, nodeB = nodeB})
    end
    return true
end



function IndexTerrainBlocks()
    data.terrainCollisionBoxes = {}
    local terrainBlockCount = GetBlockCount()

    --loop through all terrain blocks
    for currentBlock = 0, terrainBlockCount - 1 do
        --create new array for that block
        Terrain[currentBlock + 1] = {}
        local vertexCount = GetBlockVertexCount(currentBlock)
        --loop through all vertexes in that block
        for currentVertex = 0, vertexCount - 1 do
            --adds to table for maths
            Terrain[currentBlock + 1][currentVertex + 1] = GetBlockVertexPos(currentBlock, currentVertex)
        end
        data.terrainCollisionBoxes[currentBlock + 1] = MinimumCircularBoundary(Terrain[currentBlock + 1])
        if ModDebug == true then
            SpawnCircle(data.terrainCollisionBoxes[currentBlock + 1], data.terrainCollisionBoxes[currentBlock + 1].r, {r = 255, g = 255, b = 255, a = 255}, 0.04)
        end
        
    end
end