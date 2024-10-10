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
            wheelStats.inverted = false
        elseif device.saveName == names[2] then
            wheelStats.pos = GetOffsetDevicePos(device, -WHEEL_SUSPENSION_HEIGHTS[wheelType])
            wheelStats.radius = WHEEL_RADIUSES[wheelType]
            wheelStats.inverted = true
        end
    end

    return wheelStats
end
