function UpdateResources()
    for structure, _ in pairs(data.throttles) do
        if data.brakes[structure] ~= true then
            
            local throttle = math.abs(NormalizeThrottleVal(structure))
            local teamId = GetStructureTeam(structure)
            local cost
            if Motors[structure] == nil then 
                cost = 0 
            else
                cost = Motors[structure] * throttle ^ 2 * MetalCostPerSecMaxThrottle * data.updateDelta
            end
            AddResources(teamId, {metal = -cost}, false, {x = 0, y = 0})
        end
        
    end

end