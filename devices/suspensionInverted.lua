-- fort wars device file

ConstructEffect = "effects/device_construct.lua"
CompleteEffect = "effects/device_complete.lua"
DestroyEffect = "effects/device_explode.lua"
Scale = 1
SelectionWidth = 25
SelectionHeight = 25
SelectionOffset = { 0.0, 0.5 }
Mass = 375.0
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

--dofile("effects/device_smoke.lua")
--SmokeEmitter = StandardDeviceSmokeEmitter



Root =
{
	Name = "suspension",
	Angle = 180,
	Pivot = { 0, -0.4 },
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
