function InitializeCoreShield()
    data.coreShields = {}
end

function FillCoreShield()
    if not DrillsEnabled then
        for side = 1, 2 do
            if not data.coreShields[side] then data.coreShields[side] = {} end
            local deviceCount = DeviceCounts[side]
            for device = 0, deviceCount do
                local id = GetDeviceIdSide(side, device)
                if GetDeviceType(id) == "reactor" then
                    data.coreShields[side][id] = GetDevicePosition(id)
                end
            end
        end
    end
end

function RemoveCoreShield(id)
    for side = 1, 2 do
        if #data.coreShields == 0 then return end
        if data.coreShields[side][id] then data.coreShields[side][id] = nil end
    end
end

function UpdateCoreShields()
    for side = 1, 2 do
        if #data.coreShields > 0 then
            for _, coords in pairs(data.coreShields[side]) do
                local deviceSide = 3 - side
                EnumerateDevicesInShieldRadius(coords, deviceSide, side)
            end
        end
    end
end

function EnumerateDevicesInShieldRadius(shieldCoords, deviceSide, shieldSide)
    for _, device in pairs(data.devices) do
        if TURRET_ANIM_NAMES[device.saveName] then continue end
        if device.team % MAX_SIDES == deviceSide then
            if IsWithinDistance(device.pos, shieldCoords, SHIELD_RADIUS) then
                local color = { r = 255, g = 94, b = 94, a = 255 }
                if shieldSide == 1 then color = { r = 77, g = 166, b = 255, a = 255 } end
                shieldCoords.z = -100
                SpawnCircle(shieldCoords, SHIELD_RADIUS, color, 0.04)
                EvaluatePositionInShield(device, shieldCoords)
            end
        end
    end
end

function EvaluatePositionInShield(device, shieldPos)
    local distance = Distance(shieldPos, device.pos)
    local direction = GetAngleVector(shieldPos, device.pos)

    local insideShieldFactor = (1 - distance / SHIELD_RADIUS) ^ 0.5
    DamageDevicesInShield(insideShieldFactor, device.id)
    PushDeviceOutOfShield(insideShieldFactor, direction, device.pos, device)
end

function DamageDevicesInShield(insideShieldFactor, deviceId)
    ApplyDamageToDevice(deviceId, insideShieldFactor * SHIELD_DAMAGE)
end

function PushDeviceOutOfShield(insideShieldFactor, direction, devicePos, device)
    local force = {
        x = direction.x * insideShieldFactor * SHIELD_FORCE,
        y = direction.y * insideShieldFactor * SHIELD_FORCE
    }
    if ModDebug.forces then
        HighlightDirectionalVector(devicePos, force, 0.001, { r = 150, g = 220, b = 255, a = 255 })
    end

    dlc2_ApplyForce(device.nodeA, force)
    dlc2_ApplyForce(device.nodeB, force)
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
--             if Distance(pos, shieldCoords) < radius + SHIELD_RADIUS then
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
--             if Distance(shieldCoords, pos) < SHIELD_RADIUS then
--                 ApplyDamageToDevice(id, SHIELD_DAMAGE)
--             end
--         end
--     end
-- end
