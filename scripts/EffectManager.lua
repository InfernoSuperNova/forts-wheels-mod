EffectManager = {
    Standby = {},
    Active = {},
    All = {},
    StandyPosition = {x = 0, y = 0},
    MaxTimeStandby = 20 * 25, -- 20 seconds until cull
    MaxEffectId = 0
}

-- Assign our offscreen position to store effects not in use
function EffectManager:Load()
    BetterLog("Loading effect manager")
    -- cancel all effects
    for _, effectType in pairs(self.All) do
        for _, effect in pairs(effectType) do
            CancelEffect(effect.Id)
        end
    end
    self.Standby = {}
    self.Active = {}
    self.All = {}
    local screen = GetWorldExtents()
    self.StandbyPosition = {x = screen.MaxX + 5000, y = screen.MaxY + 5000}
end


function EffectManager:Update()
    -- Store the effect for potential reuse
    for id, effect in pairs(self.Active) do
        if effect.OneShot then
            self:DestroyEffect(id)
        end
    end

    -- Cull effects that have been in standby for too long
    for effectType, effectList in pairs(self.Standby) do
        for i = #effectList, 1, -1 do
            local effect = effectList[i]
            effect.StandbyTime = effect.StandbyTime + 1
            if effect.StandbyTime > self.MaxTimeStandby then
                CancelEffect(effect.Id)
                self.All[effect.Path][effect.Id] = nil
                table.remove(effectList, i)
            end
        end
    end
end




function EffectManager:CreateEffect(path, pos, direction)
    pos = pos or {x = 0, y = 0}
    direction = direction or {x = 0, y = 1}
    -- If the standby table doesn't exist, create it
    if not self.Standby[path] then
        self.Standby[path] = {}
        self.All[path] = {}
    end

    -- If there are effects in standby, use one of those
    if #self.Standby[path] > 0 then
        local standbyTable = self.Standby[path]
        local effect = standbyTable[#standbyTable]
        standbyTable[#standbyTable] = nil
        self.Active[effect.Id] = effect
        SetEffectPosition(effect.Id, pos)
        SetEffectDirection(effect.Id, direction)
        effect.StandbyTime = 0
        effect.OneShot = false
        effect.Active = true
        return effect.Id
    end

    -- Otherwise, spawn a new effect
    local effectId = SpawnEffectEx(path, pos, direction)
    local effect = { Path = path, Id = effectId, StandbyTime = 0, OneShot = false, Active = true }
    self.Active[effectId] = effect
    self.All[path][effectId] = effect
    self.MaxEffectId = effectId
    return effectId
end

function EffectManager:CreateEffectOneShot(path, pos, direction)
    local effectId = self:CreateEffect(path, pos, direction)
    self.Active[effectId].OneShot = true
    return effectId
end

-- "Destroy" an effect by moving it offscreen and storing it in the standby table to be potentially reused, or otherwise expire
function EffectManager:DestroyEffect(id)

    local effect = self.Active[id]
    if not effect then return end

    local path = effect.Path
    if not self.Standby[path] then
        self.Standby[path] = {} -- store in a table for that effect type
    end

    local standbyTable = self.Standby[path]
    standbyTable[#standbyTable + 1] = effect
    effect.Active = false
    SetEffectPosition(id, self.StandbyPosition)
    self.Active[id] = nil
end

-- Profiling and stuff
function EffectManager:DebugUpdate()
    local allTotal = 0
    local allActive = 0
    local allStandby = 0
    for path, effectList in pairs(self.All) do
        
        local effectTypeTotal = 0
        local effectTypeActive = 0
        local effectTypeStandby = 0
        for id, effect in pairs(effectList) do
            effectTypeTotal = effectTypeTotal + 1
            if effect.Active then
                effectTypeActive = effectTypeActive + 1
            else
                effectTypeStandby = effectTypeStandby + 1
            end
        end
        allTotal = allTotal + effectTypeTotal
        allActive = allActive + effectTypeActive
        allStandby = allStandby + effectTypeStandby

        if effectTypeTotal > 0 then DebugLog(path .. " in use: " .. effectTypeActive .. " / " .. effectTypeTotal) end
    end
    
    if allTotal > 0 then DebugLog("Total effects in use: " .. allActive .. " / " .. allTotal) end
end
