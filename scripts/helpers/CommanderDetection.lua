-- based upon gxaps' idea
--made by thonio, based on my idea xD
--now we've come full circle


function InitializeCommanders()
    data.Commanders = {}
    for side = 1, 2 do 
        data.Commanders[side] = GetWeaponReloadPeriod(side, "observer_dummy")
    end
    if Commander["phantom"] == data.Commanders[1] then data.team1IsPhantom = true end
    if Commander["phantom"] == data.Commanders[2] then data.team2IsPhantom = true end
end

-- generalization
function IsCommanderAndEnemyActive(commanderString, team, localSide)
    if team == -1 then return false end
    local commander = Commander[commanderString]
    local localSideId = localSide
    local enemySideId = 3 - localSideId
    if IsCommanderActive(enemySideId) and data.Commanders[enemySideId] == commander and team % MAX_SIDES == enemySideId then return true else return false end
end

-- specialization
-- Technically this is a bad smell, but it's a relatively expensive operation, so I'm going to keep it separate
function IsEnemyPhantomAndActive(team, localSide)
    if team == -1 then return false end
    local localSideId = localSide
    local enemySideId = 3 - localSideId
    if (data.team1IsPhantom and enemySideId == 1 and team % MAX_SIDES == 1 and data.team1ActiveThisFrame) or (data.team2IsPhantom and enemySideId == 2 and team % MAX_SIDES == 2 and data.team2ActiveThisFrame) then return true else return false end
end
