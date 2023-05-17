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
                    { texture = path .. "/devices/drill/drill_retract0.png", duration = 999999},
                    duration = 0.04,
                    blendColour = false,
                    blendCoordinates = false,
                    mipmap = true,
                },
                NextState = "Normal",
            },
        },
    },
    {
        Name = "drill_bit",

        States =
        {
            Normal =
            {
                Frames =
                {
                    { texture = path .. "/devices/drill/blank.png", duration = 0.28},
                    { texture = path .. "/devices/drill/drill_bit0.png" },
                    { texture = path .. "/devices/drill/drill_bit1.png" },
                    duration = 0.04,
                    blendColour = false,
                    blendCoordinates = false,
                    mipmap = true,
                },
                NextState = "Normal",
            },
        },
    },
}
for i = 0, 30 do
    table.insert(Sprites[2].States.Normal.Frames, { texture = path .. "/devices/drill/drill_bit0.png" })
    table.insert(Sprites[2].States.Normal.Frames, { texture = path .. "/devices/drill/drill_bit1.png" })
end
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
        ChildrenInFront =
        {
            {
                Name = "Bit",
                Angle = 0,
                Pivot = { 0, 0.43 },
                PivotOffset = { 0, 0.0 },
                Sprite = "drill_bit",
                UserData = 100,
            },
        }
    },
}