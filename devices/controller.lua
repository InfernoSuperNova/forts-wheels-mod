-- fort wars device file

ConstructEffect = ""
CompleteEffect = ""
DestroyEffect = ""
Scale = 1
SelectionWidth = 65
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
ClaimsStructures = true

--dofile("effects/device_smoke.lua")
--SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "vehicleController-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/controller/controller.png" }, mipmap = true, }, },
		},
	},
    
}

Root =
{
	Name = "controller",
	Angle = 0,
	Pivot = { 0, -0.60 },
	PivotOffset = { 0, 0 },
	Sprite = "vehicleController-base",
    Scale = 1,
    UserData = 0,

	ChildrenInFront =
	{
	},
}
