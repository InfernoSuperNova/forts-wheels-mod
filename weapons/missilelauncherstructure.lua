dofile("weapons/missilelauncher.lua")

SelectionWidth = 42.0
SelectionHeight = 70.0
SelectionOffset = { -0, 20.5 }


EnergyFireCost = 8000.0
MetalFireCost = 200.0


HitPoints = 300.0
WeaponMass = WeaponMass * 3.5
Root.Pivot = { 0, 0.11 }
IncendiaryRadius = 20
IncendiaryRadiusHeated = 50
StructureSplashDamage = 200
StructureSplashDamageMaxRadius = 150
DeviceSplashDamage = 150
DeviceSplashDamageMaxRadius = 400
DeviceSplashDamageDelay = 0.2
Recoil = 600000
FireDelay = 1


Sprites = {
    {
        Name = "lc-missilelauncherstructure-base",
        States =
        {
            Normal = { Frames = { { texture = path .. "/weapons/missilelauncherstructure/base.png" }, mipmap = true, }, },
            Idle = Normal,
        },
    },
    {
		Name = "lc-missilelauncherstructure-cover",
		States =
		{
			Normal = { Frames = { { texture = path .. "/weapons/missilelauncherstructure/cover.png" }, mipmap = true, }, },
			Idle = Normal,
		},
	},
}

-- Silo base
Root.Sprite = "lc-missilelauncherstructure-base"
Root.Pivot[2] = 0.05

-- Silo cover
Root.ChildrenInFront[2].Sprite = "lc-missilelauncherstructure-cover"
Root.ChildrenInFront[2].Pivot = {0, 0}

-- Silo inside
Root.ChildrenInFront[1].Pivot = {0.069, 0.215}

-- Silo door
Root.ChildrenInFront[3].Pivot[2] = -0.12