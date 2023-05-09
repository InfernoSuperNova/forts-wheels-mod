--  age (in seconds) at which the explosion actor deletes itself
--  make sure this exceedes the age of all effects
LifeSpan = 4.0

Effects =
{
	{
	--DUST CLOUDS
		Type = "sparks",
		TimeToTrigger = 0,
		SparkCount = 2,
		LocalPosition = { x = 0, y = 0, z = -100 },	-- how to place the origin relative to effect position and direction (0, 0) 
		Texture = "effects/media/sandcloud.dds",

		Gravity = 0,						-- gravity applied to particle (981 is earth equivalent)
		
		EvenDistribution =					-- distribute sparks evenly between two angles with optional variation
		{
			Min = -25,						-- minimum angle in degrees (e.g. -180, 45, 0)
			Max = 25,						-- maximum angle in degrees (e.g. -180, 45, 0)
			StdDev = 10,						-- standard deviation at each iteration in degrees (zero will make them space perfectly even)
		},

		Keyframes =							
		{
			{
				Angle = 0,
				RadialOffsetMin = 0,
				RadialOffsetMax = 20,
				ScaleMean = 2,
				ScaleStdDev = 0.5,
				SpeedStretch = 0,
				SpeedMean = 100,	
				SpeedStdDev = 5,
				Drag = 1,
				RotationMean = 0,
				RotationStdDev = 45,
				RotationalSpeedMean = 5,
				RotationalSpeedStdDev = 0,
				AgeMean = 1.5,
				AgeStdDev = 0.25,
				AlphaKeys = { 0.4, 0.5 },
				ScaleKeys = { 0.1, 1 },
			},
		},
	},
}
