function UpdateResources()
    for structure, _ in pairs(data.throttles) do
        if data.brakes[structure] ~= true then
            
            local throttle = math.abs(NormalizeThrottleVal(structure))
            local teamId = GetStructureTeam(structure)
            local cost
            if data.motors[structure] == nil then 
                cost = 0 
            else
                cost = data.motors[structure] * throttle ^ 2 * ENGINE_RUN_COST * data.updateDelta
            end
            AddResources(teamId, {metal = -cost}, false, {x = 0, y = 0})
        end
        
    end

end
