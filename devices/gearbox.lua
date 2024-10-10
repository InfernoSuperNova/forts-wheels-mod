-- fort wars device file

ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/device_explode.lua"
Scale = 1
SelectionWidth = 40
SelectionHeight = 40
SelectionOffset = { 0.0, -40.5 }
Mass = 100.0
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
BlockPenetration = false

--dofile("effects/device_smoke.lua")
--SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "gearbox-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/gearbox/gearbox.png" }, mipmap = true, }, },
		},
	},
    
}

Root =
{
	Name = "gearbox",
	Angle = 0,
	Pivot = { 0, -0.60 },
	PivotOffset = { 0, 0 },
	Sprite = "gearbox-base",
    Scale = 1,
    UserData = 0,

	ChildrenInFront =
	{
	},
}
