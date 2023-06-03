Scale = 1
SelectionWidth = 95.0
SelectionHeight = 60.0
SelectionOffset = { -18, -60.5 }
RecessionBox =
{
	Size = { 200, 25 },
	Offset = { -300, -70 },
}
CanFlip = false

WeaponMass = 120.0
HitPoints = 550.0
EnergyProductionRate = 0.0
MetalProductionRate = 0.0
EnergyStorageCapacity = 0.0
MetalStorageCapacity = 0.0
MinWindEfficiency = 1
MaxWindHeight = 0
MaxRotationalSpeed = 0
DeviceSplashDamage = 150
DeviceSplashDamageMaxRadius = 400
DeviceSplashDamageDelay = 0.2
IncendiaryRadius = 120
IncendiaryRadiusHeated = 150
StructureSplashDamage = 200
StructureSplashDamageMaxRadius = 150

FireEffect = "effects/fire_cannon.lua"
ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/cannon_explode.lua"
DestroyUnderwaterEffect = "mods/dlc2/effects/device_explode_submerged_large.lua"
ShellEffect = "effects/shell_eject_cannon.lua"
ReloadEffect = "effects/reload_cannon.lua"
ReloadEffectOffset = -1.5
Projectile = "cannon"
BarrelLength = 100.0
MinFireClearance = 500
FireClearanceOffsetInner = 20
FireClearanceOffsetOuter = 40
AttractZoomOutDuration = 5
ReloadTime = 26.0
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
EnergyFireCost = 2000.0 -- Move to Ammo
MetalFireCost = 50.0 -- Move to Ammo

ShowFireAngle = true

BarrelRecoilLimit = -0.25
BarrelRecoilSpeed = -2
BarrelReturnForce = 0.5

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "cannon-base",
		States =
		{
			Normal = { Frames = { { texture = "weapons/cannon/base.dds" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
	{
		Name = "cannon-head",
		States =
		{
			Normal = { Frames = { { texture = "weapons/cannon/head.dds" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
	{
		Name = "cannon-barrel",
		States =
		{
			Normal = { Frames = { { texture = "weapons/cannon/barrel.dds" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
	{
		Name = "cannon-reload",
		States =
		{
			Normal = { Frames = { { texture = "weapons/cannon/Cannon-Reload01.png" }, mipmap = true, }, },
			Idle = Normal,
			Reload =
			{
				Frames =
				{
					{ texture = "weapons/cannon/Cannon-Reload03.png", duration = 120, },
					mipmap = true,
					duration = 0.1,
				},
			},
			ReloadEnd =
			{
				Frames =
				{
					{ texture = "weapons/cannon/Cannon-Reload04.png" },
					{ texture = "weapons/cannon/Cannon-Reload05.png" },
					{ texture = "weapons/cannon/Cannon-Reload06.png" },
					{ texture = "weapons/cannon/Cannon-Reload07.png" },
					{ texture = "weapons/cannon/Cannon-Reload08.png" },
					{ texture = "weapons/cannon/Cannon-Reload09.png" },
					{ texture = "weapons/cannon/Cannon-Reload10.png" },
					{ texture = "weapons/cannon/Cannon-Reload11.png" },
					{ texture = "weapons/cannon/Cannon-Reload12.png" },
					{ texture = "weapons/cannon/Cannon-Reload13.png" },
					{ texture = "weapons/cannon/Cannon-Reload14.png" },
					{ texture = "weapons/cannon/Cannon-Reload15.png" },
					{ texture = "weapons/cannon/Cannon-Reload01.png" },
					mipmap = true,
					duration = 0.1,
				},
				NextState = "Normal",
			},
		},
	},
}

Root =
{
	Name = "Cannon",
	Angle = 0,
	Pivot = { 0, -0.57 },
	PivotOffset = { 0, 0 },
	Sprite = "cannon-base",
	UserData = 0,
	
	ChildrenBehind =
	{
		{
			Name = "Head",
			Angle = 0,
			Pivot = { 0, -0.05 },
			PivotOffset = { 0.1, 0 },
			Sprite = "cannon-head",
			UserData = 50,

			ChildrenBehind =
			{
				{
					Name = "Barrel",
					Angle = 0,
					Pivot = { -0.5, -0.15},
					PivotOffset = { 0.5, 0 },
					Sprite = "cannon-barrel",
					UserData = 100,

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
							Pivot = { 0.18, -0.35 },
							PivotOffset = { 0, 0 },
						},
						{
							Name = "Chamber",
							Angle = 0,
							Pivot = { -0.32, -0.15 },
							PivotOffset = { 0, 0 },
						},
					},
				},
			},
			
			ChildrenInFront =
			{
				{
					Name = "LoaderBottom",
					Angle = 0,
					Pivot = { -0.41, -0.085 },
					PivotOffset = { 0, 0 },
					Sprite = "cannon-reload",
					UserData = 100,
				},
			},
		},
		{
			Name = "Icon",
			Pivot = { 0, 0.5 },
		},
	},
}
