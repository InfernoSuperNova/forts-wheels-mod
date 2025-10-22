dofile("scripts/interpolate.lua")
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
turretCannon.ProjectileDamage = 800 -- Was 1100
turretCannon.ProjectileSplashDamage = 40
turretCannon.ProjectileSplashDamageMaxRadius = 400
turretCannon.ProjectileThickness = 15
turretCannon.SpeedIndicatorFactor = 1
turretCannon.BeamTileRate = 0.05
turretCannon.Impact = 600000

table.insert(Projectiles, turretCannon)


local laser = FindProjectile("laser")
laser.DamageMultiplier[#laser.DamageMultiplier + 1] = { SaveName = "turretCannon", AntiAir = 0, }
local turretLaser = DeepCopy(laser)

turretLaser.SaveName = "turretLaser"
turretLaser.BeamMaxTravel = 15000
turretLaser.Impact = 1200000
turretLaser.EnemyCanTeleport = false

turretLaser.Effects.Age = {["t1"] = "effects/energy_absorb.lua"}
turretLaser.BeamOcclusionDistanceWater = 15000
turretLaser.BeamOcclusionDistance = 15000
turretLaser.DeflectedByShields = false
turretLaser.DamageMultiplier[#turretLaser.DamageMultiplier+1] = { SaveName = "shield", Direct = 0.00}
turretLaser.DamageMultiplier[#turretLaser.DamageMultiplier+1] = { SaveName = "portal", Direct = 0.00}
turretLaser.ProjectileSprite = nil
turretLaser.Effects.Impact = {
    ["default"] = {	Projectile = {	Speed = 0.1, Type = "turretLaserShock", Count = 1, StdDev = 0 }, Terminate = false, Offset = 0, Effect = "effects/beam_hit.lua", },
    ["terrain"] = {	Projectile = {	Speed = 0.1, Type = "turretLaserShock", Count = 1, StdDev = 0 }, Terminate = false, Offset = 0, Effect = "effects/beam_hit_ground.lua", }
}
-- turretLaser.Effects.Impact = {
--     ["default"] = {	Projectile = {	Speed = 0.1, Type = "turretLaserShockSpawner", Count = 1, StdDev = 0 }, Terminate = false, Offset = 0, Effect = "effects/beam_impact.lua", }
-- }


local turretLaserShock = DeepCopy(FindProjectile("cannon"))

turretLaserShock.SaveName = "turretLaserShock"
turretLaserShock.CollidesWithStructure = false
turretLaserShock.CollidesWithProjectiles = false
turretLaserShock.CollidesWithBeams = false
turretLaserShock.ProjectileSplashDamage = 300
turretLaserShock.ProjectileSplashDamageMaxRadius = 150
turretLaserShock.ProjectileSplashMaxForce = 100000
turretLaserShock.TrailEffect = nil

turretLaserShock.DetonatesOnExpiry = true
turretLaserShock.Effects.Age = {
    ["t2950"] = {
        Terminate = true,
        --Effect = path .. "/effects/turretLaser_shock.lua"
    }
}
turretLaserShock.Gravity = 0

table.insert(Projectiles, turretLaserShock)


table.insert(Sprites,
{
	Name = "turretlaser_beam",
	States =
	{
		Normal = { Frames = { { texture = "weapons/media/beam.tga" }, repeatS = true, } },
	},
})
table.insert(Sprites,
{
    Name = "turretlaser_electricity",
    States =
    {
        Normal = { Frames = { { texture = path .. "/weapons/media/electricBeam.png" }, repeatS = true, } },
    },
})

turretLaser.Beam = {
    Sprites = {
        {Sprite = "turretlaser_beam", ThicknessFunction = "BeamThickness", ScrollRate = -2, TileRate = 400 * 1},
        {Sprite = "turretlaser_electricity", ThicknessFunction = "BeamElectricityThickness", ScrollRate = -20, TileRate = 400 * 1},
    }
}
function turretLaser.BeamThickness(t)
	return InterpolateTable(BeamTableTurretLaser, t, 2)
end

function turretLaser.BeamElectricityThickness(t)
    return InterpolateTable(BeamTableTurretLaserShock, t, 2)
end

function turretLaser.BeamDamage(t)
	return InterpolateTable(BeamTableTurretLaser, t, 4)
end

function turretLaser.BeamCollisionThickness(t)
    return 0
end


BeamTableTurretLaser =
{
	{ 0,	0,	0, 0},
	{ 0.5,  3,  3, 0},
	{ 1,	50,  50, 1000},
	{ 2,	50,  50, 1000}, -- 1000
    { 2.95,  2.5,  50, 100},
	{ 3,	0,	150, 0},
}


BeamTableTurretLaserShock = 
{
    {0, 0},
    {0.5, 3},
    {1, 20},
    {1.2, 50},
    {1.4, 20},
    {1.6, 50},
    {1.8, 30},
    {2, 70},
    {2.1, 30},
    {2.2, 70},
    {2.3, 40},
    {2.4, 80},
    {2.5, 40},
    {2.6, 80},
    {2.7, 50},
    {2.8, 100},
    {2.9, 50},
    {2.95, 100},
    {3, 200},

}



table.insert(Projectiles, turretLaser)

MakeFlamingVersion("turretCannon", 1.25, 0.4, flamingTrail, 80, nil, nil)


for k , v in pairs(Projectiles) do
    if(v.SaveName == "missile2") then 
        v.ProjectileMass = v.ProjectileMass * 3
        v.MaxAge = 300
        v.Missile.MaxSteerPerSecond = v.Missile.MaxSteerPerSecond * 2
    end
    if (v.SaveName == "missile") then
        v.ProjectileMass = v.ProjectileMass * 3
        v.MaxAge = 300
        v.Missile.MaxSteerPerSecond = v.Missile.MaxSteerPerSecond * 2
    end
    if v.ProjectileType == "missile" then
        v.Missile.MinTargetUpdateDistance = 0
    end
 end

dofile(path .. "/scripts/helpers/BetterLog.lua")




local buzzsaw = FindProjectile("buzzsaw")
if (buzzsaw) then

    -- Make aluminium like wood, for balance reasons
    if (buzzsaw.DamageMultiplier == nil) then
        buzzsaw.DamageMultiplier = {}
    end

    local foregroundAluminiumMultiplier = {
        SaveName = "StructuralAluminium",
        Direct = 8, -- 7.8 * (200/100)
        Ray = 14, -- 12.5 * (200/100)
        Splash = 1,
    }
    table.insert(buzzsaw.DamageMultiplier, foregroundAluminiumMultiplier)

    local backgroundAluminiumMultiplier = {
        SaveName = "StructuralAluminiumBackground",
        Direct = 8, -- 7.8 * (130/100) = 10.14
        Ray = 14, -- 12.5 * (130/100) = 16.25
        Splash = 1,
    }
    table.insert(buzzsaw.DamageMultiplier, backgroundAluminiumMultiplier)

    local hazardAluminiumMultiplier = {
        SaveName = "StructuralAluminiumHazard",
        Direct = 7.8,
        Ray = 12.5,
        Splash = 1,
    }
    table.insert(buzzsaw.DamageMultiplier, hazardAluminiumMultiplier)

    -- Disable reflection for aluminium
    if (buzzsaw.MomentumThreshold == nil) then
        buzzsaw.MomentumThreshold = {}
    end
    
    buzzsaw.MomentumThreshold["StructuralAluminium"] = { Reflect = 0 }
    buzzsaw.MomentumThreshold["StructuralAluminiumBackground"] = { Reflect = 0 }
    buzzsaw.MomentumThreshold["StructuralAluminiumHazard"] = { Reflect = 0 }

end


local howitzer = FindProjectile("howitzer")
if (howitzer) then

    -- Make aluminium like wood, for balance reasons
    if (howitzer.DamageMultiplier == nil) then
        howitzer.DamageMultiplier = {}
    end

    -- multiplier of background * ratio of material hp and background bracing (100 hp) 

    local foregroundAluminiumMultiplier = {
        SaveName = "StructuralAluminium",
        Direct = 1,
        Splash = 6.4, -- 3.2 * (200/100) = 6.4
    }
    table.insert(howitzer.DamageMultiplier, foregroundAluminiumMultiplier)

    local backgroundAluminiumMultiplier = {
        SaveName = "StructuralAluminiumBackground",
        Direct = 1,
        Splash = 6.4, -- 3.2 * (130/100) = 4.16
    }
    table.insert(howitzer.DamageMultiplier, backgroundAluminiumMultiplier)

    local hazardAluminiumMultiplier = {
        SaveName = "StructuralAluminiumHazard",
        Direct = 1,
        Splash = 1,
    }
    table.insert(howitzer.DamageMultiplier, hazardAluminiumMultiplier)
    
end