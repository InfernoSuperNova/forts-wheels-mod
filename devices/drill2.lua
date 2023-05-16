dofile(path .. "/devices/drill.lua")
Sprites = {}
MetalProductionRate = 3
EnergyProductionRate = -6
Sprites =
{
    {
        Name = "drill_extend",

        States =
        {
            Normal =
            {
                Frames =
                {
                    { texture = path .. "/devices/drill/drill_retract7.png" },
                    { texture = path .. "/devices/drill/drill_retract6.png" },
                    { texture = path .. "/devices/drill/drill_retract5.png" },
                    { texture = path .. "/devices/drill/drill_retract4.png" },
                    { texture = path .. "/devices/drill/drill_retract3.png" },
                    { texture = path .. "/devices/drill/drill_retract2.png" },
                    { texture = path .. "/devices/drill/drill_retract1.png" },
                    { texture = path .. "/devices/drill/drill_retract0.png" },
                    { texture = path .. "/devices/drill/drill_retract0.png", duration = 100},
                    duration = 0.08,
                    blendColour = false,
                    blendCoordinates = false,
                    mipmap = true,
                },
                NextState = "Normal",
            },
        },
    },
}
Root.ChildrenBehind =
{
    {
        Name = "Arm",
        Angle = 0,
        Pivot = { 0, 0.35 },
        PivotOffset = { 0, 0.5 },
        Scale = 1.2,
        Sprite = "drill_extend",
        UserData = 100,
    },
}