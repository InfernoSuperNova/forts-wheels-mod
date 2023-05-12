EngineToDeviceDamage = function()
   for index, ProjectileTable in ipairs(Projectiles) do
      if ProjectileTable.WeaponDamageBonus then
         if ProjectileTable.DeviceDamageBonus then
            multiplier = 1 / ((ProjectileTable.WeaponDamageBonus + ProjectileTable.ProjectileDamage + ProjectileTable.DeviceDamageBonus) / ProjectileTable.ProjectileDamage + ProjectileTable.DeviceDamageBonus)
         else
            multiplier = 1 / ((ProjectileTable.WeaponDamageBonus + ProjectileTable.ProjectileDamage) / ProjectileTable.ProjectileDamage)
         end
         if not ProjectileTable.DamageMultiplier then ProjectileTable.DamageMultiplier = {} end
         table.insert(ProjectileTable.DamageMultiplier,{ SaveName = "engine_wep", Direct = multiplier, })
      end
   end
end
RegisterApplyMod(EngineToDeviceDamage)
