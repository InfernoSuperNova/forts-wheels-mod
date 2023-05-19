-- based upon gxaps' idea
--made by thonio, based on my idea xD
--now we've come full circle


function InitializeCommanders()
    data.Commanders = {}
    for side = 1, 2 do 
        data.Commanders[side] = GetWeaponReloadPeriod(side, "observer_dummy")
    end
end


function IsCommanderAndEnemyActive(commanderString, team)
    if team == -1 then return false end
    local commander = Commander[commanderString]
    local localSideId = GetLocalTeamId() % MAX_SIDES
    local enemySideId = 3 - localSideId
    if IsCommanderActive(enemySideId) and data.Commanders[enemySideId] == commander and team % MAX_SIDES == enemySideId then return true else return false end
end