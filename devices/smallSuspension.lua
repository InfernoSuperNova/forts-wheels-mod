dofile(path .. "/devices/suspension.lua")
Mass = 100.0
HitPoints = 100.0
Sprites =
{
	{
		Name = "smallSuspension-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/suspension/smallSuspension.png" }, mipmap = true, }, },
		},
	},
}

Root =
{
	Name = "suspension",
	Angle = 0,
	Pivot = { 0, 0.24 },
	PivotOffset = { 0, 0 },
	Sprite = "smallSuspension-base",
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
