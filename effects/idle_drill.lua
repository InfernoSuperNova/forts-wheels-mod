--  age (in seconds) at which the explosion deletes itself
--  make sure this exceedes the age of all effects
LifeSpan = 10.1
SoundEvent = "mods/forts-wheels/effects/drilling_loop"
Sprites = 
{
	{
        Name = "sparks0",

        States =
        {
            Normal =
            {
                Frames =
                {
                    { texture = "effects/media/sparks_70.dds" },
                    { texture = "effects/media/sparks_71.dds" },
                    { texture = "effects/media/sparks_72.dds" },
                    { texture = "effects/media/sparks_73.dds" },
                    { texture = "effects/media/sparks_74.dds" },
                    { texture = "effects/media/sparks_75.dds" },
                    { texture = "effects/media/sparks_76.dds" },
                    { texture = "effects/media/sparks_77.dds" },
                    { texture = "effects/media/sparks_78.dds" },
                    { texture = "effects/media/sparks_79.dds" },
                    { texture = "effects/media/sparks_80.dds" },
                    { texture = "effects/media/sparks_81.dds" },
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
Effects =
{
	--[[{
		Type = "sparks",
		TimeToTrigger = 0.28,
		SparkCount = 2,
		BurstPeriod = 0.4,
		SparksPerBurst = 1,
		LocalPosition = { x = 0, y = 10, z = -50 },
		Sprite = "sparks0",

		Gravity = 400,

		NormalDistribution =					-- distribute sparks evenly between two angles with optional variation
		{
			Mean = 0,
			StdDev = 45,						-- standard deviation at each iteration in degrees (zero will make them space perfectly even)
		},
		
		Keyframes =							
		{
			{
				Angle = 0,
				RadialOffsetMin = 0,
				RadialOffsetMax = 20,
				ScaleMean = 0.6,
				ScaleStdDev = 0.3,
				SpeedStretch = 0,
				SpeedMean = 700,
				SpeedStdDev = 300,
				Drag = 0,
				RotationMean = 0,
				RotationStdDev = 360,
				RotationalSpeedMean = 0,
				RotationalSpeedStdDev = 200,
				AgeMean = 0.2,
				AgeStdDev = 0.1,
				AlphaKeys = { 0.1, 1 },
				ScaleKeys = { 0.1, 0.2 },
				colour = { 255, 255, 255, 255 },
			},
		},
	},]]
	{
		Type = "sparks",
		TimeToTrigger = 0.28,
		SparkCount = 4,
		BurstPeriod = 0.3,
		SparksPerBurst = 1,
		LocalPosition = { x = 0, y = 0, z = -50 },
		Sprite = "effects/media/debris.png",

		Gravity = 981,

		NormalDistribution =					-- distribute sparks evenly between two angles with optional variation
		{
			Mean = 0,
			StdDev = 70,						-- standard deviation at each iteration in degrees (zero will make them space perfectly even)
		},
		
		Keyframes =							
		{
			{
				Angle = 0,
				RadialOffsetMin = 0,
				RadialOffsetMax = 20,
				ScaleMean = 0.3,
				ScaleStdDev = 0.2,
				SpeedStretch = 0,
				SpeedMean = 400,
				SpeedStdDev = 200,
				Drag = 0,
				RotationMean = 0,
				RotationStdDev = 360,
				RotationalSpeedMean = 0,
				RotationalSpeedStdDev = 200,
				AgeMean = 1,
				AgeStdDev = 0.5,
				AlphaKeys = { 0.1, 1 },
				ScaleKeys = { 0.1, 0.2 },
				colour = { 255, 255, 255, 255 },
			},
		},
	},
}
