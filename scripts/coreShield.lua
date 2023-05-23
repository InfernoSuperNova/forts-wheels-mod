function InitializeCoreShield()
    data.coreShields = {}
end
function FillCoreShield()
    for side = 1, 2 do
        if not data.coreShields[side] then data.coreShields[side] = {} end
        local deviceCount = GetDeviceCountSide(side)
        for device = 0, deviceCount do

            local id = GetDeviceIdSide(side, device)
            if GetDeviceType(id) == "reactor" then
                data.coreShields[side][id] = GetDevicePosition(id)
            end
        end
        
    end
end

function RemoveCoreShield(id)
    for side = 1, 2 do
        if data.coreShields[side][id] then data.coreShields[side][id] = nil end
    end


end

function UpdateCoreShields()
    for side = 1, 2 do
        for _, coords in pairs(data.coreShields[side]) do
            local otherSide = 3 - side
            EnumerateDevicesInShieldRadius(coords, otherSide, side)
        end
    end 
end

function EnumerateDevicesInShieldRadius(shieldCoords, deviceSide, shieldSide)
    local deviceCount = GetDeviceCountSide(deviceSide)
    for deviceIndex = 0, deviceCount do
        local id = GetDeviceIdSide(deviceSide, deviceIndex)

        local pos = GetDevicePosition(id)
        if Distance(shieldCoords, pos) < ShieldRadius then
            local color = {r = 255, g = 94, b = 94, a= 255}
            if shieldSide == 1 then color = {r = 77, g = 166, b = 255, a = 255} end
            SpawnCircle(shieldCoords, ShieldRadius, color, 0.04)
            EvaluatePositionInShield(id, shieldCoords, pos)
        end
    end
end

function EvaluatePositionInShield(deviceId, shieldPos, devicePos)

    local distance = Distance(shieldPos, devicePos)
    local direction = GetAngleVector(shieldPos, devicePos)
    
    local insideShieldFactor = (1 - distance / ShieldRadius) ^ 0.5
    DamageDevicesInShield(insideShieldFactor, deviceId)
    PushDeviceOutOfShield(insideShieldFactor, direction, devicePos, deviceId)
    
end


function DamageDevicesInShield(insideShieldFactor, deviceId)
    ApplyDamageToDevice(deviceId, insideShieldFactor * ShieldDamage)
end

function PushDeviceOutOfShield(insideShieldFactor, direction, devicePos, deviceId)
    local nodeA = GetDevicePlatformA(deviceId)
    local nodeB = GetDevicePlatformB(deviceId)
    local force = {x = direction.x * insideShieldFactor * ShieldForce, y = direction.y * insideShieldFactor * ShieldForce}
    --HighlightDirectionalVector(devicePos, direction)
    dlc2_ApplyForce(nodeA, force)
    dlc2_ApplyForce(nodeB, force)
end





--in limbo until beeman fixes GetStructurePos

-- function GetStructuresInShieldRadius(shieldCoords, side)
--     local structureCount = GetStructureCount()
--     for structure = 0, structureCount do
--         local id = GetStructureId(structure)
--         local lside = GetStructureTeam(id) % MAX_SIDES

--         if side == lside then
--             local radius = GetStructureRadius(id)
--             local pos = GetStructurePos(id)
--             SpawnCircle(pos, radius, {r = 255, g = 255, b = 255, a= 255}, 0.1)
--             if Distance(pos, shieldCoords) < radius + ShieldRadius then
--                 DamageDevicesInShieldRadius(shieldCoords, side, id)
--             end
--         end
--     end
-- end


-- function DamageDevicesInShieldRadius(shieldCoords, side, structureId)
--     local deviceCount = GetDeviceCountSide(side)
--     for deviceIndex = 0, deviceCount do
--         local id = GetDeviceIdSide(side, deviceIndex)
--         if GetDeviceStructureId(id) == structureId then
--             local pos = GetDevicePosition(id)
--             if Distance(shieldCoords, pos) < ShieldRadius then
--                 ApplyDamageToDevice(id, ShieldDamage)
--             end
--         end
--     end
-- end