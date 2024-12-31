


function FillAwaitingOLTable(node, device)
    -- BetterLog("e")
    -- local structure
    -- if node then
    --     structure = NodeStructureId(node)
    -- elseif device then
    --     structure = GetDeviceStructureId(device)
    -- else
    --     table.insert(AwaitingOrbitalLasers, nil)
    --     return
    -- end
    -- table.insert(AwaitingOrbitalLasers, {id = structure})
    -- BetterLog(AwaitingOrbitalLasers)
end

function FillOLTable(saveName, weaponId)
    -- if saveName == "orbital_laser_source" then
    --     OrbitalLasers[weaponId] = table.remove(AwaitingOrbitalLasers, 1)
    --     ScheduleCall(20, RemoveOldOrbital, weaponId)
    -- end
end
function RemoveOldOrbital(weaponId)

    -- OrbitalLasers[weaponId] = nil
end
function UpdateWeapons(frame)
    

    
    -- for weapon, structure in pairs(OrbitalLasers) do

    --     local currentPos = GetDevicePosition(weapon)
    --     local structurePos = GetStructurePos(structure.id)
    --     local structureRadius = GetStructureRadius(structure.id)
    --     SpawnCircle(structurePos, structureRadius, {r = 255, g = 255, b = 255, a = 255}, 0.04)
    --     local pos = {x = mouse.x, y = currentPos.y}
    --     local speed = mouse.x - currentPos.x
    --     dlc2_SetDevicePosition(weapon, pos)
    --     if math.abs(speed) == 0 then
    --         SetWeaponEffectTag(weapon, "Right", true)
    --         SetWeaponEffectTag(weapon, "Left", true)
    --     else
    --         SetWeaponEffectTag(weapon, "Right", speed > 0)
    --         SetWeaponEffectTag(weapon, "Left", speed < 0)
    --     end
        
    -- end

end

function LoadWeapons()
    data.currentTurretDirections = {}

end
function CheckTurrets(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    if upgradedId == 0 then return end
    if not CheckSaveNameTable(saveName, TURRET_SAVE_NAME) then return end
    local direction = teamId %MAX_SIDES
    local reloadTime = GetWeaponReloadTime(deviceId)
    local health = GetDeviceHealth(deviceId)
    if data.currentTurretDirections[upgradedId] then
        direction = data.currentTurretDirections[upgradedId]
        data.currentTurretDirections[upgradedId] = nil
    end
    -- get savename with 1 less character at end
    local turretName = string.sub(saveName, 1, -2)
    FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health, turretName)
end



-- This is ass
function FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health, turretName)
    local parse = {deviceId = deviceId, direction = direction, nodeA = nodeA, nodeB = nodeB, t = t, reloadTime = reloadTime, health = health, name = turretName}
    ScheduleCall(0, FlipTurret2, parse)
end
function FlipTurret2(parse)
    EnableWeaponUpgradeAllSides(parse.name.. "2", parse.name.. "Flip1", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, parse.name.. "Flip1")
    EnableWeaponUpgradeAllSides(parse.name.. "2", parse.name.. "Flip1", false)
    ScheduleCall(0.08, FlipTurret3, parse)
end
function FlipTurret3(parse)
    EnableWeaponUpgradeAllSides(parse.name.. "Flip1", parse.name.. "Flip2", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, parse.name.. "Flip2")
    EnableWeaponUpgradeAllSides(parse.name.. "Flip1", parse.name.. "Flip2", false)
    ScheduleCall(0.08, FlipTurret4, parse)
end

function FlipTurret4(parse)
    EnableWeaponUpgradeAllSides(parse.name.. "Flip2", parse.name.. "Flip3", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, parse.name.. "Flip3")
    EnableWeaponUpgradeAllSides(parse.name.. "Flip2", parse.name.. "Flip3", false)
    parse.direction = 3 - parse.direction
    ScheduleCall(0.04, ScheduleDeviceDestruction, parse.deviceId)
    ScheduleCall(0.08, FlipTurret5, parse)
end
function FlipTurret5(parse)
    EnableWeaponAllSides(parse.name.. "Flip2", true)
    parse.deviceId = CreateDevice(parse.direction, parse.name.. "Flip2", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides(parse.name.. "Flip2", false)
    ScheduleCall(0.08, FlipTurret6, parse)
end
function FlipTurret6(parse)
    EnableWeaponUpgradeAllSides(parse.name.. "Flip2", parse.name.. "Flip1", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, parse.name.. "Flip1")
    EnableWeaponUpgradeAllSides(parse.name.. "Flip2", parse.name.. "Flip1", false)
    ScheduleCall(0.08, FlipTurret7, parse)
end
function FlipTurret7(parse)
    EnableWeaponUpgradeAllSides(parse.name.. "Flip1", parse.name.. "3", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, parse.name.. "3")
    EnableWeaponUpgradeAllSides(parse.name.. "Flip1", parse.name.. "3", false)
    data.currentTurretDirections[parse.deviceId] = parse.direction
    SetWeaponReloadTime(parse.deviceId, parse.reloadTime)
    local currentHealth = GetDeviceHitpoints(parse.deviceId)
    ApplyDamageToDevice(parse.deviceId, (1 - parse.health) * currentHealth)
end

function RemoveTurretDirection(id)
    data.currentTurretDirections[id] = nil
end
function ScheduleDeviceDestruction(id)
    ApplyDamageToDevice(id, 9999999)
end

function EnableDeviceAllSides(saveName, enable)
    for side = 1, 2 do
        EnableDevice(saveName, enable, side)
    end
end

function EnableWeaponAllSides(saveName, enable)
    for side = 1, 2 do
        EnableWeapon(saveName, enable, side)
    end
end


function EnableWeaponUpgradeAllSides(device, upgrade, enable)
    for side = 1, 2 do
        EnableWeaponUpgrade(device, upgrade, side, enable)
    end
end

