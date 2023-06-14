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
HitPoints = 1400.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DeviceSplashDamage = 200
DeviceSplashDamageMaxRadius = 400
DeviceSplashDamageDelay = 0.2
IncendiaryRadius = 250
IncendiaryRadiusHeated = 300
StructureSplashDamage = 300
StructureSplashDamageMaxRadius = 250

FireEffect = "effects/fire_cannon.lua"
ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/cannon_explode.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged_large.lua"
ShellEffect = nil
ReloadEffect = "effects/reload_cannon.lua"
ReloadEffectOffset = -1.5
Projectile = "turretCannon"
BarrelLength = 100.0
MinFireClearance = 500
FireClearanceOffsetInner = 20
FireClearanceOffsetOuter = 40
AttractZoomOutDuration = 5
ReloadTime = 45.0
ReloadTimeIncludesBurst = false
MinFireSpeed = 6000.0 -- Move to Ammo
MaxFireSpeed = 6000.1 -- Move to Ammo
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
Recoil = 600000
EnergyFireCost = 4000.0 -- Move to Ammo
MetalFireCost = 150.0 -- Move to Ammo

ShowFireAngle = true

BarrelRecoilLimit = -0.1
BarrelRecoilSpeed = -2
BarrelReturnForce = 3

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

EagleEyeReloadBank = 
{
	ReloadTime = 5,
}

Sprites =
{
	{
		Name = "turretCannon-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/base.png" }, mipmap = true, }, },
			Idle = Normal,
            
		},
	},
	{
		Name = "turretCannon-head",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/head.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
	{
		Name = "turretCannon-barrel",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/barrel.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretCannon-commander",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/commander.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretCannon-basket",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/basket.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
    {
		Name = "turretCannon-flip1",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/turning_straight.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
    {
		Name = "turretCannon-flip2",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/turning_angled.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
    {
		Name = "turretCannon-flip3",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/turretCannon/turning_middle.png" }, mipmap = true, }, },
			Idle = Normal,
            
		}
	},
}

Root =
{
	Name = "TurretCannon",
	Angle = 0,
	Pivot = { 0.0, -0.445 },
	PivotOffset = { 0, 0 },
	Sprite = "turretCannon-base",
	UserData = 0,
	ChildrenBehind =
	{
		{
			Name = "Head",
			Angle = 0,
            --negative is left, positive is right, negative is up, positive is down

			Pivot = { 0.042, 0.332 },
			PivotOffset = { 0.3, 0 },
			Sprite = "turretCannon-head",
			UserData = 20,

			ChildrenBehind =
			{
				{
					Name = "Barrel",
					Angle = 0,
					Pivot = { -0.355, -0.02},
					PivotOffset = { 0.5, 0 },
					Sprite = "turretCannon-barrel",
					UserData = 50,

					ChildrenInFront =
					{
						{
							Name = "Hardpoint0",
							Angle = 90,
							Pivot = { 0, 0.05 },
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
		{
			Name = "Icon",
			Pivot = { 0, 0.5 },
		},
        {
            Name = "Commander",
            Pivot = {-0.054, 0.18},
            Sprite = "turretCannon-commander",
            UserData = 100,
        },
        {
            Name = "Basket",
            Pivot = {0.0, 0.515},
            Sprite = "turretCannon-basket",
            UserData = 80,
        },
	},
}
