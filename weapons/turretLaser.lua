

Scale = 1
SelectionWidth = 350.0
SelectionHeight = 60.0
SelectionOffset = { -0, -60.5 }
RecessionBox =
{
	Size = { 500, 25 },
	Offset = { -300, -70 },
}
CanFlip = true

WeaponMass = 1200.0
HitPoints = 500.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DeviceSplashDamage = 150
DeviceSplashDamageMaxRadius = 300
DeviceSplashDamageDelay = 0.2
IncendiaryRadius = 250
IncendiaryRadiusHeated = 300
StructureSplashDamage = 250
StructureSplashDamageMaxRadius = 150

FireEffect = path .. "/effects/fire_turretlaser.lua"
ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/cannon_explode.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged_large.lua"
ShellEffect = nil
ReloadEffect = "effects/reload_cannon.lua"
ReloadEffectOffset = -1.5
Projectile = "turretLaser"
BarrelLength = 100.0
MinFireClearance = 500
FireClearanceOffsetInner = 20
FireClearanceOffsetOuter = 40
AttractZoomOutDuration = 5
ReloadTime = 45.0
ReloadTimeIncludesBurst = false
MinFireSpeed = 15000.0 -- Move to Ammo
MaxFireSpeed = 15000.0 -- Move to Ammo
MinFireRadius = 600.0
MaxFireRadius = 1200.0
MinVisibility = 0.7
MaxVisibilityHeight = 1000
MinFireAngle = -20
MaxFireAngle = 30
KickbackMean = 40 -- Move to Ammo
KickbackStdDev = 5 -- Move to Ammo
MouseSensitivityFactor = 0.5
PanDuration = 0
FireStdDev = 0.01 -- Move to Ammo
FireStdDevAuto = 0.012 -- Move to Ammo
Recoil = 1200000
EnergyFireCost = 6000.0 -- Move to Ammo
MetalFireCost = 25.0 -- Move to Ammo

BeamThicknessMultiplier = 1.0
BeamDamageMultiplier = 1.0

ShowFireAngle = true

BarrelRecoilLimit = -0.3
BarrelRecoilSpeed = -2
BarrelReturnForce = 0.03

TriggerProjectileAgeAction = true
MinAgeTrigger = 1
MaxAgeTrigger = 1

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter


BeamDuration = 3

-- first column is time keypoint
-- second coloumn is thickness at that keypoint
-- third column is damage at that keypoint




EagleEyeReloadBank = 
{
	ReloadTime = 5,
}

Sprites =
{
	{
		Name = "turretLaser-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/base.png" }, mipmap = true, }, },
			Idle = Normal,
            
		},
	},
	{
		Name = "turretLaser-head",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/head.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
	{
		Name = "turretLaser-barrel",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/barrel.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretLaser-commander",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/commander.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretLaser-basket",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/basket.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretLaser-flip1",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/turning_straight.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
    {
		Name = "turretLaser-flip2",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/turning_angled.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
    {
		Name = "turretLaser-flip3",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretLaser/turning_middle.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
    {
        Name = "empty",
        States =
        {
            Normal = { Frames = { { texture = path .. "/empty.png" }, mipmap = true, }, },
            Idle = Normal,
        },
    }
}

Root =
{
	Name = "turretLaser",
	Angle = 0,
	Pivot = { 0.0, -0.445 },
	PivotOffset = { 0, 0 },
	Sprite = "turretLaser-base",
	UserData = 0,
	ChildrenBehind =
	{

        {
            Name = "HeadDummy",
            Angle = 0,
            Pivot = { 0.042, 0.332 },
            PivotOffset = { 0.0, 0 },
            UserData = 0,
            Sprite = "empty",

            ChildrenBehind = {
                {
                    Name = "Head",
                    Angle = 0,
                    --negative is left, positive is right, negative is up, positive is down
        
                    Pivot = { 0.0, 0 },
                    PivotOffset = { 0.3, 0 },
                    Sprite = "turretLaser-head",
                    UserData = 20,
        
                    ChildrenBehind =
                    {
                        {
                            Name = "Barrel",
                            Angle = 0,
                            Pivot = { -0.355, -0.02},
                            PivotOffset = { 0.5, 0 },
                            Sprite = "turretLaser-barrel",
                            UserData = 50,
        
                            ChildrenInFront =
                            {
                                {
                                    Name = "Hardpoint0",
                                    Angle = 90,
                                    Pivot = { 0.16, 0.0 },
                                    PivotOffset = { 0, 0 },
                                },
                                {
                                    Name = "LaserSight",
                                    Angle = 90,
                                    Pivot = { 0.16, -0.35 },
                                    PivotOffset = { 0, 0 },
                                },
                                {
                                    Name = "Chamber",
                                    Angle = 0,
                                    Pivot = { -0.5, 0.05 },
                                    PivotOffset = { 0, 0 },
                                },
                            },
                        },
                    },
                },
                
            },
        },
        {
            Name = "Icon",
            Pivot = { 0, 0.5 },
        },
        {
            Name = "Commander",
            Pivot = {-0.054, 0.18},
            Sprite = "turretLaser-commander",
            UserData = 100,
        },
        {
            Name = "Basket",
            Pivot = {0.0, 0.515},
            Sprite = "turretLaser-basket",
            UserData = 80,
        },
    }
}
dofile(path .. "/scripts/BetterLog.lua")
function RemoveUserData(table)
	for k, v in pairs(table) do
		if k == "UserData" then v = 0 end
		if type(v) =="table" then RemoveUserData(v) end
	end
end
