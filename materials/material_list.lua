for k, v in pairs(Materials) do

    if v.Stiffness and not v.MaxSegmentLength then
        v.Stiffness = v.Stiffness * 2
    end
    if v.MaxExpansion then v.MaxExpansion = (v.MaxExpansion -1) * 2 end
    if v.MaxCompression then v.MaxCompression = 1 - (1 - v.MaxCompression ) * 2 end
end