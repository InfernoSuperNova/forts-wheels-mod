


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