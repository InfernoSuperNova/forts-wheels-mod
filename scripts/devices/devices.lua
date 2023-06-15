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
            local nodePosA = NodePosition(nodeA)
            local nodePosB = NodePosition(nodeB)
            local nodeVelA = NodeVelocity(nodeA)
            local nodeVelB = NodeVelocity(nodeB)
            table.insert(Devices, {
                strucId = structureId,
                team = team,
                id = id,
                saveName = SaveName,
                pos = pos,
                nodeA = nodeA,
                nodeB = nodeB,
                nodePosA = nodePosA,
                nodePosB = nodePosB,
                nodeVelA = nodeVelA,
                nodeVelB = nodeVelB,
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

function UpdateDevices(frame)
    SellExtraControllers()

end

function SellExtraControllers()
    local controllers = {}
    for _, device in pairs(Devices) do
        if CheckSaveNameTable(device.saveName, CONTROLLER_SAVE_NAME) then
            if not controllers[device.strucId] then controllers[device.strucId] = 0 end
            controllers[device.strucId] = controllers[device.strucId] + 1
            if controllers[device.strucId] > MAX_CONTROLLERS then
                DestroyDeviceById(device.id)
            end
        end
    end

end