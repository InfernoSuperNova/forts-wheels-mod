dofile("devices/battery.lua")
Sprites = {}
SelectionHeight = 50.0
SelectionOffset = {0, 10}
EnergyStorageCapacity = 0
DeviceSplashDamage = 0
DeviceSplashDamageMaxRadius = 0
ConstructEffect = ""
CompleteEffect = path .. "/effects/drill_extend.lua"
Sprites =
{
    {
        Name = "drill_retract",

        States =
        {
            Normal =
            {
                Frames =
                {
                    { texture = path .. "/devices/drill/drill_retract0.png" },
                    { texture = path .. "/devices/drill/drill_retract1.png" },
                    { texture = path .. "/devices/drill/drill_retract2.png" },
                    { texture = path .. "/devices/drill/drill_retract3.png" },
                    { texture = path .. "/devices/drill/drill_retract4.png" },
                    { texture = path .. "/devices/drill/drill_retract5.png" },
                    { texture = path .. "/devices/drill/drill_retract6.png" },
                    { texture = path .. "/devices/drill/drill_retract7.png", duration = 999999 },
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
Root =
{
    Name = "Drill",
    Angle = 0,
    Pivot = { 0, -0.07 },
    PivotOffset = { 0, 0 },
    Sprite = path .. "/devices/drill/base.png",
    
    ChildrenBehind =
    {
        {
            Name = "Arm",
            Angle = 0,
            Pivot = { 0, 0.35 },
            PivotOffset = { 0, 0.5 },
            Scale = 1.2,
            Sprite = "drill_retract",
            UserData = 100,
        },
    },
}