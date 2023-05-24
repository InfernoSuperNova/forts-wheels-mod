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
					{ texture = path .. "/materials/concrete.dds", duration = 0.01 },
					{ texture = path .. "/materials/concrete.dds", duration = 0.33 },
					{ texture = path .. "/materials/concrete.dds", duration = 0.33 },
					{ texture = path .. "/materials/concrete.dds", duration = 0.331 },
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
    road.MaxAngle = 20


    table.insert(Materials, road)
end