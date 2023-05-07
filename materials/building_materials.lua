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