--frame time, not compatible with mods that change hz rate unfortunately
LifeSpan = 10e11

Sprites =
{
	{
		Name = "track_link_[placeholder]",

		States =
		{
			Normal =
			{
				Frames =
				{
					{ texture = path .. "/effects/wheels/[placeholder]/tracklink.png" },
					

					duration = 0.054,
					blendColour = false,
					blendCoordinates = false,
				},
				--RandomPlayLength = 2,
				NextState = "Normal",
			},
		},
	},
}

Effects =
{

	{
		Type = "sprite",
		TimeToTrigger = 0,
		LocalPosition = { x = 5, y = 0, z = -0.2 },
		LocalVelocity = { x = 0, y = 0, z = 0 },
		Acceleration = { x = 0, y = 0, z = 0 },
		Drag = 0.0,
		Sprite = "track_link_[placeholder]",
		Additive = false,
		TimeToLive = 10e11,
		Angle = 0,
		InitialSize = 1.0,
		ExpansionRate = 0,
		AngularVelocity = 0,
		RandomAngularVelocityMagnitude = 0,
		Colour1 = { 255, 255, 255, 255 },
		Colour2 = { 255, 255, 255, 255 },
		KillParticleOnEffectCancel = true,
	},

}
