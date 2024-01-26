--needs fixing
EngineToDeviceDamage = function()
   for index, ProjectileTable in ipairs(Projectiles) do
      if ProjectileTable.WeaponDamageBonus then
        local multiplier
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


local turretCannon = DeepCopy(FindProjectile("cannon"))

turretCannon.SaveName = "turretCannon"
turretCannon.ProjectileDamage = 1100
turretCannon.ProjectileSplashDamage = 70
turretCannon.ProjectileSplashDamageMaxRadius = 400
turretCannon.ProjectileThickness = 15
turretCannon.SpeedIndicatorFactor = 1
turretCannon.BeamTileRate = 0.05

table.insert(Projectiles, turretCannon)

MakeFlamingVersion("turretCannon", 1.25, 0.4, flamingTrail, 80, nil, nil)