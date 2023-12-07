dofile("scripts/forts.lua")
dofile(path .. "/scripts/BetterLog.lua")
for k, v in pairs(Materials) do
    
    if v.Stiffness and not v.MaxSegmentLength then
        v.Stiffness = v.Stiffness * 2
    end
    if v.MaxExpansion then v.MaxExpansion = (v.MaxExpansion -1) * 2 + 1 end
    if v.MaxCompression then v.MaxCompression = 1 - (1 - v.MaxCompression ) * 2 end
    if v.AngleStressPrimaryThreshold then
        v.AngleStressPrimaryThreshold = v.AngleStressPrimaryThreshold * 2
    end
end

table.insert(Sprites, 
    {
		Name = "road",
		States =
		{
			Normal =
			{
				Frames =
				{
					-- durations must add up to 1 for the damage keying to work properly
					-- anything beyond 1 will never show
					{ texture = path .. "/materials/concrete.png", duration = 0.01 },
					{ texture = path .. "/materials/concrete.png", duration = 0.33 },
					{ texture = path .. "/materials/concrete.png", duration = 0.33 },
					{ texture = path .. "/materials/concrete.png", duration = 0.331 },
					mipmap = true,
					repeatS = true,
				},
			},
		},
	}
)
table.insert(Sprites, 
    {
		Name = "structural",
		States =
		{
			Normal =
			{
				Frames =
				{
					-- durations must add up to 1 for the damage keying to work properly
					-- anything beyond 1 will never show
					{ texture = path .. "/materials/structural.dds", duration = 0.01 },
					{ texture = path .. "/materials/structural.dds", duration = 0.33 },
					{ texture = path .. "/materials/structural.dds", duration = 0.33 },
					{ texture = path .. "/materials/structural.dds", duration = 0.331 },
					mipmap = true,
					repeatS = true,
				},
			},
		},
	}
)
table.insert(Sprites, 
    {
		Name = "structuralBackground",
		States =
		{
			Normal =
			{
				Frames =
				{
					-- durations must add up to 1 for the damage keying to work properly
					-- anything beyond 1 will never show
					{ texture = path .. "/materials/structuralBackground.dds", duration = 0.01 },
					{ texture = path .. "/materials/structuralBackground.dds", duration = 0.33 },
					{ texture = path .. "/materials/structuralBackground.dds", duration = 0.33 },
					{ texture = path .. "/materials/structuralBackground.dds", duration = 0.331 },
					mipmap = true,
					repeatS = true,
				},
			},
		},
	}
)
local road = DeepCopy(FindMaterial("armour"))
if road then
    road.SaveName = "RoadLink"
    road.Sprite = "road"
	road.BuildTime = 60
	road.ScrapTime = 60
	road.HitPoints = 100

    table.insert(Materials, road)
end

local structuralAluminium = DeepCopy(FindMaterial("armour"))
if structuralAluminium then
	structuralAluminium.SaveName = "StructuralAluminium"
	structuralAluminium.Sprite = "structural"
	structuralAluminium.MetalBuildCost = 0.5
	structuralAluminium.EnergyBuildCost = 0.5
	structuralAluminium.SupportsDevices = true
	structuralAluminium.Stiffness = 1000000
	structuralAluminium.MaxCompression = 0.5
	structuralAluminium.MaxExpansion = 1.5
	structuralAluminium.Mass = 0.2
	structuralAluminium.RecessionTargetSaveName = "StructuralAluminiumBackground"
	
	structuralAluminium.WeaponRecession = false
	structuralAluminium.FullExtrusion = true
	structuralAluminium.ArmorRemovalTargetSaveName = "StructuralAluminiumBackground"
	structuralAluminium.HitPoints = 200

	table.insert(Materials, structuralAluminium)
end

local structuralAluminiumBackground = DeepCopy(FindMaterial("armour"))
if structuralAluminiumBackground then
	structuralAluminiumBackground.SaveName = "StructuralAluminiumBackground"
	structuralAluminiumBackground.Sprite = "structuralBackground"
	structuralAluminiumBackground.MetalBuildCost = 0.4
	structuralAluminiumBackground.EnergyBuildCost = 0.4
	structuralAluminiumBackground.SupportsDevices = false
	structuralAluminiumBackground.CollidesWithFriendlyProjectiles = false
	structuralAluminiumBackground.CollidesWithEnemyProjectiles = false
	structuralAluminiumBackground.CollidesWithFriendlyBeams = false
	structuralAluminiumBackground.CollidesWithEnemyBeams = true
	structuralAluminiumBackground.IsBehindDevices = true
	structuralAluminiumBackground.AttachesCladding = true
	structuralAluminiumBackground.BackgroundCladding = true
	structuralAluminiumBackground.CollidesWithWind = false
	structuralAluminiumBackground.FullExtrusion = true
	structuralAluminiumBackground.Stiffness = 800000
	structuralAluminiumBackground.MaxCompression = 0.5
	structuralAluminiumBackground.MaxExpansion = 1.5
	structuralAluminiumBackground.Mass = 0.15

	structuralAluminiumBackground.HitPoints = 100
	structuralAluminiumBackground.ForegroundTargetSaveName = "StructuralAluminium"
	table.insert(Materials, structuralAluminiumBackground)
end