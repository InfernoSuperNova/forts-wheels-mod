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
         table.insert(ProjectileTable.DamageMultiplier,{ SaveName = "vehicleControllerNoStructure", Direct = multiplier, })
         table.insert(ProjectileTable.DamageMultiplier,{ SaveName = "vehicleControllerStructure", Direct = multiplier, })
      end
   end
end
RegisterApplyMod(EngineToDeviceDamage)


local turretCannon = DeepCopy(FindProjectile("cannon"))

turretCannon.SaveName = "turretCannon"
turretCannon.ProjectileDamage = 1100
turretCannon.ProjectileSplashDamage = 50
turretCannon.ProjectileSplashDamageMaxRadius = 400
turretCannon.ProjectileThickness = 15
turretCannon.SpeedIndicatorFactor = 1
turretCannon.BeamTileRate = 0.05
turretCannon.Impact = 600000

table.insert(Projectiles, turretCannon)


local laser = FindProjectile("laser")
laser.DamageMultiplier[#laser.DamageMultiplier + 1] = { SaveName = "turretCannon", Direct = 0, }
local turretLaser = DeepCopy(laser)

turretLaser.SaveName = "turretLaser"
turretLaser.BeamMaxTravel = 15000
turretLaser.Impact = 1200000

turretLaser.Effects.Age = {["t1"] = "effects/energy_absorb.lua"}
turretLaser.BeamOcclusionDistanceWater = 15000
turretLaser.BeamOcclusionDistance = 15000
turretLaser.DeflectedByShields = false
turretLaser.DamageMultiplier[#turretLaser.DamageMultiplier+1] = { SaveName = "shield", Direct = 0.05}
table.insert(Projectiles, turretLaser)

MakeFlamingVersion("turretCannon", 1.25, 0.4, flamingTrail, 80, nil, nil)


dofile(path .. "/scripts/helpers/BetterLog.lua")
