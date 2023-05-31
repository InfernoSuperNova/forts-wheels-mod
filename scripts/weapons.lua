
local prevPos

function UpdateWeapons(frame)
    

    
    for weapon, _ in pairs(OrbitalLasers) do
        local currentPos = GetDevicePosition(weapon)
        local mouse = ProcessedMousePos()
        local pos = {x = mouse.x, y = currentPos.y}
        local speed = mouse.x - currentPos.x
        dlc2_SetDevicePosition(weapon, pos)
        if math.abs(speed) == 0 then
            SetWeaponEffectTag(weapon, "Right", true)
            SetWeaponEffectTag(weapon, "Left", true)
        else
            SetWeaponEffectTag(weapon, "Right", speed > 0)
            SetWeaponEffectTag(weapon, "Left", speed < 0)
        end
        
    end

end