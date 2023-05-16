dofile("devices/battery.lua")
Sprites = {}
SelectionOffset = {}
EnergyStorageCapacity = 0
ConstructEffect = nil
CompleteEffect = nil
Root =
{
	Name = "Drill",
	Angle = 0,
	Pivot = { 0, 0.0 },
	PivotOffset = { 0, 0 },
	Sprite = "battery-base",
	
	ChildrenInFront =
	{
	},
}