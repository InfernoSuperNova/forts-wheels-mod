Scale = 1
SelectionWidth = 60
SelectionHeight = 40
SelectionOffset = { 0.0, -40.5 }
RecessionBox =
{
	Size = { 0, 0 },
	Offset = { 0, 0 },
}
CanFlip = false

WeaponMass = 200.0
HitPoints = 350.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DeviceSplashDamage = 100
DeviceSplashDamageMaxRadius = 50
DeviceSplashDamageDelay = 0.2
IgnitePlatformOnDestruct = true
IncendiaryRadius = 100
IncendiaryRadiusHeated = 120
StructureSplashDamage = 50
StructureSplashDamageMaxRadius = 100

FireEffect = path .. "/effects/fire_20mmcannon.lua"

ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/device_explode.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged_large.lua"
ShellEffect = path .. "/effects/shell_eject_20mmcannon.lua"
ReloadEffect = path .. "/effects/reload_20mmcannon.lua"
FireEndEffect = path .. "/effects/cooldown_20mmcannon.lua"
RetriggerFireEffect = true
ReloadEffectOffset = -2
Projectile = nil
BarrelLength = 0.0
MinFireClearance = 0
FireClearanceOffsetInner = 20
FireClearanceOffsetOuter = 40
AttractZoomOutDuration = 5
ReloadTime = 28.8
ReloadTimeIncludesBurst = false
MinFireSpeed = 6000.0
MaxFireSpeed = 6000.1
MinFireRadius = 0.0
MaxFireRadius = 0.0
MinVisibility = 0.7
MaxVisibilityHeight = 0
MinFireAngle = -0
MaxFireAngle = 0
KickbackMean = 40
KickbackStdDev = 5
MouseSensitivityFactor = 0.5
PanDuration = 0
FireStdDev = 0.02
FireStdDevAuto = 0.02
Recoil = 400000
EnergyFireCost = 2000
MetalFireCost = 40
RoundsEachBurst = 9
RoundPeriod = 0.32

ShowFireAngle = true

BarrelRecoilLimit = -0.15
BarrelRecoilSpeed = -1.5
BarrelReturnForce = 1



Scale = 1
SelectionWidth = 80
SelectionHeight = 40
SelectionOffset = { 0.0, -40.5 }
Mass = 125.0
HitPoints = 350.0
DestroyProjectile = nil
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DrawBracket = false
DrawBehindTerrain = true
NoReclaim = false
TeamOwned = true
BlockPenetration = true
ClaimsStructure = true

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter


Root =
{
	Name = "engine",
	Angle = 0,
	Pivot = { 0, -0.55 },
	PivotOffset = { 0, 0 },
	Sprite = "engine-base",
    Scale = 1,
    UserData = 0,

	ChildrenInFront =
	{
	},
}