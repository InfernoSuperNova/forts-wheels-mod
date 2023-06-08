-- fort wars device file
ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/device_explode.lua"
Scale = 1
SelectionWidth = 25
SelectionHeight = 25
SelectionOffset = { 0.0, -25.5 }
Mass = 150.0
HitPoints = 150.0
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

dofile("effects/device_smoke.lua")
SmokeEmitter = StandardDeviceSmokeEmitter

Sprites =
{
	{
		Name = "suspension-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/suspension/suspension.png" }, mipmap = true, }, },
		},
	},
}

Root =
{
	Name = "suspension",
	Angle = 0,
	Pivot = { 0, 0.36 },
	PivotOffset = { 0, 0 },
	Sprite = "suspension-base",
    Scale = 1.3,
    UserData = 0,

	ChildrenInFront =
	{
        -- {
		-- 	Name = "Wheel",
		-- 	Pivot = { 0.0, 0.5 },
		-- 	Sprite = "wheel",
		-- 	UserData = 100,
		-- 	Visible = false,
		-- },
	},
}
