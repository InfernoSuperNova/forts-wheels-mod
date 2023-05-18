dofile(path .. "/devices/drill3.lua")
Sprites = {}
MetalProductionRate = 5
EnergyProductionRate = -10
NodeEffects =
{
	{
		NodeName = "Bit",
		EffectPath = path .. "/effects/idle_drill.lua",
	},
}
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
        {
            Name = "Arm2",
            Angle = 0,
            Pivot = { 0.25, 0.35 },
            PivotOffset = { 0, 0.5 },
            Scale = 1.2,
            Sprite = "drill_extend",
            UserData = 100,
            ChildrenInFront =
            {
                {
                    Name = "Bit2",
                    Angle = 0,
                    Pivot = { 0, 0.43 },
                    PivotOffset = { 0, 0.0 },
                    Sprite = "drill_bit",
                    UserData = 100,
                },
            }
        },
    },
}