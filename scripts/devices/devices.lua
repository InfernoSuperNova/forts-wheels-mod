function GetDeviceCounts()
    DeviceCounts = {}  
    for side = 0, 2 do
        DeviceCounts[side] = GetDeviceCountSide(side)
    end
end
function IndexDevices()
    data.devices = {}
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
            local platformPos = GetDeviceLinkPosition(id)
            table.insert(data.devices, {
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
                platformPos = platformPos,
            })
        end
    end

    EnumerateCarDevices()
end

function EnumerateCarDevices()
    data.motors = {}
    data.gearboxes ={}
    for _, device in pairs(data.devices) do
        if IsDeviceFullyBuilt(device.id) then
            if CheckSaveNameTable(device.saveName, GEARBOX_SAVE_NAME) then
                if not data.gearboxes[device.strucId] then
                    data.gearboxes[device.strucId] = 1
                else
                    data.gearboxes[device.strucId] = data.gearboxes[device.strucId] + 1
                end
            elseif CheckSaveNameTable(device.saveName, ENGINE_SAVE_NAME) then
                if not data.motors[device.strucId] then
                    data.motors[device.strucId] = 1
                else
                    data.motors[device.strucId] = data.motors[device.strucId] + 1
                end
            end
        end
    end

end

function IndexDevice(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    local nodePosA = NodePosition(nodeA)
    local nodePosB = NodePosition(nodeB)
    local nodeVelA = NodeVelocity(nodeA)
    local nodeVelB = NodeVelocity(nodeB)
    local structureId = GetDeviceStructureId(deviceId)
    table.insert(data.devices, {
        strucId = structureId,
        team = teamId,
        id = deviceId,
        saveName = saveName,
        pos = Vec3Lerp(nodePosA, nodePosB, t),
        nodeA = nodeA,
        nodeB = nodeB,
        nodePosA = nodePosA,
        nodePosB = nodePosB,
        nodeVelA = nodeVelA,
        nodeVelB = nodeVelB,
        platformPos = t,
    })
    if upgradedId ~= 0 then
        local index = FindDeviceIndexInMasterIndex(deviceId)
        if index then
            table.remove(data.devices, index)
        end
        
    end
    EnumerateCreatedCarDevice(saveName, structureId)
end


function EnumerateCreatedCarDevice(saveName, structureId)
    if CheckSaveNameTable(saveName, GEARBOX_SAVE_NAME) then
        if not data.gearboxes[structureId] then
            data.gearboxes[structureId] = 1
        else
            data.gearboxes[structureId] = data.gearboxes[structureId] + 1
        end
    elseif CheckSaveNameTable(saveName, ENGINE_SAVE_NAME) then
        if not data.motors[structureId] then
            data.motors[structureId] = 1
        else
            data.motors[structureId] = data.motors[structureId] + 1
        end
    end
end

function HandleBrokenNode(nodeId, nodeIdNew)
    
    for _, device in pairs (data.devices) do
        if device.nodeA == nodeId then
            device.nodeA = GetDevicePlatformA(device.id)
        end
        if device.nodeB == nodeId then
            device.nodeB = GetDevicePlatformB(device.id)
        end
    end
end

function HandleDestroyedDevice(teamId, deviceId, saveName, nodeA, nodeB, t)
    local device = FindDeviceInMasterIndex(deviceId)
    if not device then return end
    EnumerateDestroyedCarDevice(saveName, device.strucId)
    local index = FindDeviceIndexInMasterIndex(deviceId)
    if WheelSmokeEffects[deviceId] then
        DisableEffect(WheelSmokeEffects[deviceId])
        CancelEffect(WheelSmokeEffects[deviceId])
        WheelSmokeEffects[deviceId] = nil
    end
    table.remove(data.devices, index)
end

function EnumerateDestroyedCarDevice(saveName, structureId)
    if CheckSaveNameTable(saveName, GEARBOX_SAVE_NAME) then
        data.gearboxes[structureId] = data.gearboxes[structureId] - 1
    elseif CheckSaveNameTable(saveName, ENGINE_SAVE_NAME) then
        data.motors[structureId] = data.motors[structureId] - 1
    end
end

function UpdateDeviceTeam(oldTeamId, newTeamId, deviceId, saveName)
    local device = FindDeviceInMasterIndex(deviceId)
    if device then
        device.team = newTeamId
    end
end


function FindDeviceInMasterIndex(id)
    for _, device in pairs(data.devices) do
        if id == device.id then return device end
    end
end

function FindDeviceIndexInMasterIndex(id)
    for index, device in pairs(data.devices) do
        if id == device.id then return index end
    end
    return nil
end

function UpdateDevices(frame)
    SellExtraControllers()
    for _, device in pairs(data.devices) do
        device.nodePosA = NodePosition(device.nodeA)
        device.nodePosB = NodePosition(device.nodeB)
        device.nodeVelA = NodeVelocity(device.nodeA)
        device.nodeVelB = NodeVelocity(device.nodeB)
        device.pos = Vec3Lerp(device.nodePosA, device.nodePosB, device.platformPos)
        local newStructureId = GetDeviceStructureId(device.id)
        if  newStructureId ~= device.strucId then
            EnumerateDestroyedCarDevice(device.saveName, device.strucId)
            device.strucId = newStructureId
            EnumerateCreatedCarDevice(device.saveName, device.strucId)
        end
    end
end

function SellExtraControllers()
    local controllers = {}
    for _, device in pairs(data.devices) do
        if CheckSaveNameTable(device.saveName, CONTROLLER_SAVE_NAME) then
            if not controllers[device.strucId] then controllers[device.strucId] = {} end
            if not controllers[device.strucId][device.team] then controllers[device.strucId][device.team] = 0 end
            controllers[device.strucId][device.team] = controllers[device.strucId][device.team] + 1
            if controllers[device.strucId][device.team] > MAX_CONTROLLERS then
                DestroyDeviceById(device.id)
            end
        end
    end

end