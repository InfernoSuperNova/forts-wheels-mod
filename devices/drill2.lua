dofile(path .. "/devices/drill.lua")
Sprites = {}
MetalProductionRate = 3
EnergyProductionRate = -6
table.insert(Root.ChildrenInFront,
{
    Name = "Head",
    Angle = 0,
    Pivot = { 0, 0 },
    PivotOffset = { 0, 0 },
    Sprite = "battery_detail",
    UserData = 50,
})