function GetWheelEffectPath(sprocketType, saveName)
    for wheelType, names in pairs(WHEEL_SAVE_NAMES) do
        if CheckSaveNameTable(saveName, names) then
            return TRACK_SPROCKET_EFFECT_PATHS[sprocketType][wheelType]

        end
    end
end


function GetWheelStats(device)
    local wheelStats = {}
    local wheelType = WHEEL_SAVENAME_KEY_TYPES[device.saveName]
    local inverted = WHEEL_INVERTED_KEY[device.saveName]
    local height = WHEEL_SUSPENSION_HEIGHTS[wheelType] * (inverted and -1 or 1)

    local platformX = device.nodePosA.x - device.nodePosB.x
    local platformY = device.nodePosA.y - device.nodePosB.y
    local platformMag = math.sqrt(platformX * platformX + platformY * platformY)
    local platformNorm = {x = platformX / platformMag, y = platformY / platformMag}
    local platformPerp = {x = platformNorm.y, y = -platformNorm.x}


    local wheelPosX = platformPerp.x * height + device.pos.x
    local wheelPosY = platformPerp.y * height + device.pos.y

    local pos = {x = wheelPosX, y = wheelPosY}

    local leverArmNodeAX = wheelPosX - device.nodePosA.x
    local leverArmNodeAY = wheelPosY - device.nodePosA.y

    local leverArmNodeA = {x = leverArmNodeAX, y = leverArmNodeAY}

   
    local leverArmNodeBX = wheelPosX - device.nodePosB.x
    local leverArmNodeBY = wheelPosY - device.nodePosB.y

    local leverArmNodeB = {x = leverArmNodeBX, y = leverArmNodeBY}




    wheelStats.pos = pos
    wheelStats.radius = WHEEL_RADIUSES[wheelType]
    wheelStats.inverted = inverted
    wheelStats.platformNormal = platformNorm
    wheelStats.normal = platformPerp
    wheelStats.leverArmA = leverArmNodeA
    wheelStats.leverArmB = leverArmNodeB
    wheelStats.height = height
    return wheelStats
end

function GetWheelRadius(saveName)
    return WHEEL_RADIUSES[WHEEL_SAVENAME_KEY_TYPES[saveName]]
end