


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
    FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health)
end

function FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health)
    local parse = {deviceId = deviceId, direction = direction, nodeA = nodeA, nodeB = nodeB, t = t, reloadTime = reloadTime, health = health}
    ScheduleCall(0, FlipTurret2, parse)
end
function FlipTurret2(parse)
    EnableWeaponUpgradeAllSides("turretCannon2", "turretCannonFlip1", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, "turretCannonFlip1")
    EnableWeaponUpgradeAllSides("turretCannon2", "turretCannonFlip1", false)
    ScheduleCall(0.08, FlipTurret3, parse)
end
function FlipTurret3(parse)
    EnableWeaponUpgradeAllSides("turretCannonFlip1", "turretCannonFlip2", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, "turretCannonFlip2")
    EnableWeaponUpgradeAllSides("turretCannonFlip1", "turretCannonFlip2", false)
    ScheduleCall(0.08, FlipTurret4, parse)
end

function FlipTurret4(parse)
    EnableWeaponUpgradeAllSides("turretCannonFlip2", "turretCannonFlip3", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, "turretCannonFlip3")
    EnableWeaponUpgradeAllSides("turretCannonFlip2", "turretCannonFlip3", false)
    parse.direction = 3 - parse.direction
    ScheduleCall(0.04, ScheduleDeviceDestruction, parse.deviceId)
    ScheduleCall(0.08, FlipTurret5, parse)
end
function FlipTurret5(parse)
    EnableWeaponAllSides("turretCannonFlip2", true)
    parse.deviceId = CreateDevice(parse.direction, "turretCannonFlip2", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip2", false)
    ScheduleCall(0.08, FlipTurret6, parse)
end
function FlipTurret6(parse)
    EnableWeaponUpgradeAllSides("turretCannonFlip2", "turretCannonFlip1", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, "turretCannonFlip1")
    EnableWeaponUpgradeAllSides("turretCannonFlip2", "turretCannonFlip1", false)
    ScheduleCall(0.08, FlipTurret7, parse)
end
function FlipTurret7(parse)
    EnableWeaponUpgradeAllSides("turretCannonFlip1", "turretCannon3", true)
    parse.deviceId = UpgradeDevice(parse.deviceId, "turretCannon3")
    EnableWeaponUpgradeAllSides("turretCannonFlip1", "turretCannon3", false)
    data.currentTurretDirections[parse.deviceId] = parse.direction
    SetWeaponReloadTime(parse.deviceId, parse.reloadTime)
    --local currentHealth = GetDeviceHitpoints(parse.deviceId)
    local currentHealth = 2900
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

