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




FreeNode =
{
	Priority = 2,
	Foundations =
	{
--		{ angle = 35, material = "core-fndhvyfloor" }, -- you can have heavier foundations for different angle brackets (lower is a more horizontal surface)
		{ angle = 145, material = "lc-fndfree" },
		{ material = "lc-fndfree"},
	},
	Plates =
	{
		{ material = "core-brc1" },
--[[
		{ mass = 75, material = "core-brc1" },
		{ mass = 125, material = "core-brc2" },
		{ mass = 200, material = "core-brc3" },
		{ material = "core-brc4" },
]]
	},
}
FoundationTestNode =
{
    Priority = 2,
    Foundations =
    {
        { angle = 145, material = "lc-fndtest" },
        { material = "lc-fndtest"},
    },
    Plates =
    {
        { material = "core-brc1" },
    },
}

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
					{ texture = path .. "/materials/structural.png", duration = 0.01 },
					{ texture = path .. "/materials/structuralDamage1.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralDamage2.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralDamage3.png", duration = 0.331 },
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
					{ texture = path .. "/materials/structuralBackground.png", duration = 0.01 },
					{ texture = path .. "/materials/structuralBackground.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralBackground.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralBackground.png", duration = 0.331 },
					mipmap = true,
					repeatS = true,
				},
			},
		},
	}
)
table.insert(Sprites, 
    {
		Name = "structuralHazard",
		States =
		{
			Normal =
			{
				Frames =
				{
					-- durations must add up to 1 for the damage keying to work properly
					-- anything beyond 1 will never show
					{ texture = path .. "/materials/structuralHazard2.png", duration = 0.01 },
					{ texture = path .. "/materials/structuralHazard2.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralHazard2.png", duration = 0.33 },
					{ texture = path .. "/materials/structuralHazard2.png", duration = 0.331 },
					mipmap = true,
					repeatS = true,
				},
			},
		},
	}
)
table.insert(Sprites, ButtonSprite("hud-structural-icon", "HUD/HUD-structural", nil, 0.664, nil, nil, path))
table.insert(Sprites, ButtonSprite("hud-structuralbackground-icon", "HUD/HUD-structuralBackground", nil, 0.664, nil, nil, path))
table.insert(Sprites, ButtonSprite("hud-road-icon", "HUD/HUD-road", nil, 0.664, nil, nil, path))
table.insert(Sprites, {
    Name = "magnesium_fire",

    States =
    {
        Normal =
        {
            Frames =
            {
                { texture = path .. "/effects/media/Fire01.png", colour = { 1, 1, 1, 0 }, },
            },
            NextState = "Normal",
        },
        
        Lit =
        {
            Frames =
            {
                { texture = path .. "/effects/media/FireStart01.png" },
                { texture = path .. "/effects/media/FireStart02.png" },
                { texture = path .. "/effects/media/FireStart03.png" },
                { texture = path .. "/effects/media/FireStart04.png" },
                { texture = path .. "/effects/media/FireStart05.png" },
                { texture = path .. "/effects/media/FireStart06.png" },
                { texture = path .. "/effects/media/FireStart07.png" },

                duration = 0.1,
                blendColour = false,
                blendCoordinates = false,
                mipmap = true,
            },
            NextState = "FireLoop",
        },
        
        FireLoop =
        {
            RandomStartFrame = true,
            Frames =
            { 
                { texture = path .. "/effects/media/Fire01.png" },
                { texture = path .. "/effects/media/Fire02.png" },
                { texture = path .. "/effects/media/Fire03.png" },
                { texture = path .. "/effects/media/Fire04.png" },
                { texture = path .. "/effects/media/Fire05.png" },
                { texture = path .. "/effects/media/Fire06.png" },
                { texture = path .. "/effects/media/Fire07.png" },
                { texture = path .. "/effects/media/Fire08.png" },
                { texture = path .. "/effects/media/Fire09.png" },

                duration = 0.1,
                blendColour = false,
                blendCoordinates = false,
                mipmap = true,
            },
            NextState = "FireLoop",
        },
    },
})
local road = DeepCopy(FindMaterial("armour"))
if road then
    road.SaveName = "RoadLink"
    road.Sprite = "road"
    road.Icon = "hud-road-icon"
	road.BuildTime = 60
	road.ScrapTime = 60
	road.HitPoints = 100

    table.insert(Materials, road)
end

local structuralAluminium = DeepCopy(FindMaterial("armour"))
if structuralAluminium then
    structuralAluminium.FireSprite = "magnesium_fire"
	structuralAluminium.SaveName = "StructuralAluminium"
	structuralAluminium.Sprite = "structural"
    structuralAluminium.Icon = "hud-structural-icon"
	structuralAluminium.MetalBuildCost = 0.4
	structuralAluminium.MetalReclaim = 0.25
	structuralAluminium.EnergyBuildCost = 0.4
	structuralAluminium.EnergyReclaim = 0.0
	structuralAluminium.SupportsDevices = true
    structuralAluminium.CatchesFire = true
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
    structuralAluminiumBackground.FireSprite = "magnesium_fire"
	structuralAluminiumBackground.SaveName = "StructuralAluminiumBackground"
	structuralAluminiumBackground.Sprite = "structuralBackground"
    structuralAluminiumBackground.Icon = "hud-structuralbackground-icon"
	structuralAluminiumBackground.MetalBuildCost = 0.3
	structuralAluminiumBackground.MetalReclaim = 0.2
	structuralAluminiumBackground.EnergyBuildCost = 0.3
	structuralAluminiumBackground.EnergyReclaim = 0.0
	structuralAluminiumBackground.SupportsDevices = false
    structuralAluminiumBackground.CatchesFire = true
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
	structuralAluminiumBackground.RecessionTargetSaveName = "StructuralAluminiumBackground"
	structuralAluminiumBackground.HitPoints = 130
	structuralAluminiumBackground.ForegroundTargetSaveName = "StructuralAluminium"
	table.insert(Materials, structuralAluminiumBackground)
end


local hazardAluminium = DeepCopy(FindMaterial("armour"))
if hazardAluminium then
	hazardAluminium.SaveName = "StructuralAluminiumHazard"
	hazardAluminium.Sprite = "structuralHazard"
	hazardAluminium.MetalBuildCost = 0.0
	hazardAluminium.EnergyBuildCost = 0.0
	hazardAluminium.MetalReclaim = 0
	hazardAluminium.EnergyReclaim = 0
	hazardAluminium.SupportsDevices = false
	hazardAluminium.CollidesWithFriendlyProjectiles = false
	hazardAluminium.CollidesWithEnemyProjectiles = false
	hazardAluminium.CollidesWithFriendlyBeams = false
	hazardAluminium.CollidesWithEnemyBeams = true
	hazardAluminium.IsBehindDevices = true
	hazardAluminium.AttachesCladding = true
	hazardAluminium.BackgroundCladding = true
	hazardAluminium.CollidesWithWind = false
	hazardAluminium.FullExtrusion = true
	hazardAluminium.Stiffness = 1000000
	hazardAluminium.MaxCompression = 0.5
	hazardAluminium.MaxExpansion = 1.5
	hazardAluminium.Mass = 0.15
	hazardAluminium.BuildTime = 0
	hazardAluminium.ScrapTime = 0
	hazardAluminium.RequiresFoundationSupport = true
	hazardAluminium.Node = FreeNode
	hazardAluminium.HitPoints = 100
	hazardAluminium.MaxLength = 10e11
    hazardAluminium.MaxLinkLength = 10e11
	hazardAluminium.MinLength = 0
    hazardAluminium.AirDrag = 6400
    hazardAluminium.NodeGravity = 0

	hazardAluminium.Enabled = false
	table.insert(Materials, hazardAluminium)
end

local foundationTestMat = DeepCopy(hazardAluminium)

foundationTestMat.SaveName = "FoundationTest"
foundationTestMat.Node = FoundationTestNode
table.insert(Materials, foundationTestMat)