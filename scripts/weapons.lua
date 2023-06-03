


function FillAwaitingOLTable(node, device)
    -- local structure
    -- if node then
    --     structure = NodeStructureId(node)
    -- elseif device then
    --     structure = GetDeviceStructureId(device)
    -- else
    --     table.insert(AwaitingOrbitalLasers, nil)
    --     return
    -- end
    -- table.insert(AwaitingOrbitalLasers, {structure = structure})
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
    

    
    -- for weapon, _ in pairs(OrbitalLasers) do
    --     local currentPos = GetDevicePosition(weapon)
    --     local mouse = ProcessedMousePos()
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


function CheckTurrets(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    if upgradedId == 0 then return end
    if not CheckSaveNameTable(saveName, TURRET_SAVE_NAME) then return end
    local direction = teamId %MAX_SIDES
    local reloadTime = GetWeaponReloadTime(upgradedId)
    local health = GetDeviceHealth(deviceId)
    if CurrentTurretDirections[upgradedId] then
        direction = CurrentTurretDirections[upgradedId]
        CurrentTurretDirections[upgradedId] = nil
    end
    FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health)
end

function FlipTurret(deviceId, direction, nodeA, nodeB, t, reloadTime, health)
    local parse = {deviceId = deviceId, direction = direction, nodeA = nodeA, nodeB = nodeB, t = t, reloadTime = reloadTime, health = health}
    ScheduleCall(0.16, ScheduleDeviceDestruction, deviceId)
    ScheduleCall(0.2, FlipTurret2, parse)
end
function FlipTurret2(parse)
    EnableWeaponAllSides("turretCannonFlip1", true)
    local newDevice = CreateDevice(parse.direction, "turretCannonFlip1", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip1", false)
    ScheduleCall(0.16, ScheduleDeviceDestruction, newDevice)
    ScheduleCall(0.2, FlipTurret3, parse)
end
function FlipTurret3(parse)
    EnableWeaponAllSides("turretCannonFlip2", true)
    local newDevice = CreateDevice(parse.direction, "turretCannonFlip2", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip2", false)
    ScheduleCall(0.16, ScheduleDeviceDestruction, newDevice)
    ScheduleCall(0.2, FlipTurret4, parse)
end

function FlipTurret4(parse)
    EnableWeaponAllSides("turretCannonFlip3", true)
    local newDevice = CreateDevice(parse.direction, "turretCannonFlip3", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip3", false)
    parse.direction = 3 - parse.direction
    ScheduleCall(0.16, ScheduleDeviceDestruction, newDevice)
    ScheduleCall(0.2, FlipTurret5, parse)
end
function FlipTurret5(parse)
    EnableWeaponAllSides("turretCannonFlip2", true)
    local newDevice = CreateDevice(parse.direction, "turretCannonFlip2", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip2", false)
    ScheduleCall(0.16, ScheduleDeviceDestruction, newDevice)
    ScheduleCall(0.2, FlipTurret6, parse)
end
function FlipTurret6(parse)
    EnableWeaponAllSides("turretCannonFlip1", true)
    local newDevice = CreateDevice(parse.direction, "turretCannonFlip1", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannonFlip1", false)
    ScheduleCall(0.16, ScheduleDeviceDestruction, newDevice)
    ScheduleCall(0.2, FlipTurret7, parse)
end
function FlipTurret7(parse)
    EnableWeaponAllSides("turretCannon3", true)
    local newDevice = CreateDevice(parse.direction, "turretCannon3", parse.nodeA, parse.nodeB, parse.t)
    EnableWeaponAllSides("turretCannon3", false)
    CurrentTurretDirections[newDevice] = parse.direction
    SetWeaponReloadTime(newDevice, parse.reloadTime)
    --local currentHealth = GetDeviceHitpoints(parse.deviceId)
    local currentHealth = 2900
    ApplyDamageToDevice(newDevice, (1 - parse.health) * currentHealth)
end

function RemoveTurretDirection(id)
    CurrentTurretDirections[id] = nil
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