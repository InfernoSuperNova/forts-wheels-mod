dofile(path .. "/devices/drill.lua")
Sprites = {}
Root =
{
    Name = "Drill",
    Angle = 0,
    Pivot = { 0, -0.07 },
    PivotOffset = { 0, 0 },
    Sprite = path .. "/devices/drill/base2.png",
    
    ChildrenBehind =
    {
        {
            Name = "Arm",
            Angle = 0,
            Pivot = { -0.2, 0.35 },
            PivotOffset = { 0, 0.5 },
            Scale = 1.2,
            Sprite = "drill_retract",
            UserData = 100,
        },
        {
            Name = "Arm2",
            Angle = 0,
            Pivot = { 0.25, 0.35 },
            PivotOffset = { 0, 0.5 },
            Scale = 1.2,
            Sprite = "drill_retract",
            UserData = 100,
        },
    },
}