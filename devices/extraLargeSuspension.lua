dofile(path .. "/devices/suspension.lua")
SelectionWidth = 120
SelectionHeight = 40
SelectionOffset = { 0.0, -50.5 }
Mass = 250.0
HitPoints = 550.0
Sprites =
{
	{
		Name = "extraLargeSuspension-base",
		States =
		{
			Normal = { Frames = { { texture = path .. "/devices/suspension/extraLargeSuspension.png" }, mipmap = true, }, },
		},
	},
}

Root =
{
	Name = "suspension",
	Angle = 0,
	Pivot = { 0, 0.48 },
	PivotOffset = { 0, 0 },
	Sprite = "extraLargeSuspension-base",
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