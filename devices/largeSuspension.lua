dofile(path .. "/devices/suspension.lua")
SelectionWidth = 75
Mass = 250.0
HitPoints = 250.0
Sprites =
{
	{
		Name = "largeSuspension-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/suspension/largeSuspension.png" }, mipmap = true, }, },
		},
	},
}

Root =
{
	Name = "suspension",
	Angle = 0,
	Pivot = { 0, 0.44 },
	PivotOffset = { 0, 0 },
	Sprite = "largeSuspension-base",
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