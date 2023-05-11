VelocityToSpawnSmoke = 200
function PreUpdateEffects()
    StoreUnusedEffects()
end
function UpdateEffects(frame)

    WheelSmoke(frame)
    EngineSoundUpdate()
end
function InitializeEffects()
	EffectsList =
    --keeps track of existing effect ids
	{
		["engine"] = {},
	}
end
function WheelSmoke(frame)
    for structure, wheels in pairs(TracksId) do
        for deviceId, pos in pairs(wheels) do
            local wheelIsTouchingGround = data.wheelsTouchingGround[structure][GetDeviceKeyFromId(structure, deviceId)]

            local nodeA = GetDevicePlatformA(deviceId)
            local nodeB = GetDevicePlatformB(deviceId)
            local velocity = AverageCoordinates({NodeVelocity(nodeA), NodeVelocity(nodeB)})
            local offset = OffsetPerpendicular(NodePosition(nodeA), NodePosition(nodeB), 75)
            local finalOffset = {x = pos.x + offset.x, y = pos.y + offset.y}
            if wheelIsTouchingGround then
                local velocityMag = VecMagnitude(velocity)
                if velocityMag and velocityMag > VelocityToSpawnSmoke and frame % 5 == 0 then
                    SpawnEffect(path .. "/effects/smoke_poof.lua", finalOffset)
                end
            end
        end
    end
end

function EngineSoundUpdate()
    --Engine sound script to run on Update()
    if JustJoined then
        EngineSoundOnJoin()
    end
    DebugLog(data.throttles)
    for structureIndex, engine in pairs(data.throttles) do
        local rpm = math.abs((engine.x - 274) * 19)
        DebugLog(EffectsList)
        local needEngine = true
        for engine, effect in pairs(EffectsList.engine) do
            DebugLog(GetDeviceStructureId(tonumber(engine)))
            DebugLog(structureIndex)
            if GetDeviceStructureId(tonumber(engine)) == structureIndex then
                if needEngine then
                    SetAudioParameter(effect, "rpm", rpm)
                    needEngine = false
                else
                    SetAudioParameter(effect, "rpm", -100)
                end
                SetEffectPosition(effect, GetDevicePosition(tonumber(engine)))
            end
        end
    end
end
function EngineSoundAdd(saveName, deviceId)
    --attaches an effect to a new engine device
    if saveName == ControllerSaveName then
        local id = SpawnEffect(path .. "/effects/engine_loop.lua", GetDevicePosition(deviceId))
        EffectsList.engine[tostring(deviceId)] = id
    end
end
function EngineSoundRemove(saveName, deviceId)
    
    --removes an effect when an engine device is removed
    if saveName == ControllerSaveName then
        if EffectsList.engine[tostring(deviceId)] then
            CancelEffect(EffectsList.engine[tostring(deviceId)])
        end
        EffectsList.engine[tostring(deviceId)] = nil
    end
end
function EngineSoundOnJoin()
    
    --attaches effects to engines upon joining
    for side = 1, 2 do
        local count = GetDeviceCountSide(side)
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            if GetDeviceType(id) == ControllerSaveName then
                EngineSoundAdd(ControllerSaveName, id)
            end
        end
    end
end

MasterEffects = {}


--[[

MasterEffects = {
    data/mods/fortswheelmod/effects/track.lua = {
        1 = {
            uid = 55
            effectId = 99

        }
    }
}
]]

function StoreUnusedEffects()
    for _, effectTypes in pairs(MasterEffects) do
        for _, effect in pairs(effectTypes) do
            if effect.assigned == true then
                effect.assigned = false
                continue
            else
                effect.uid = nil
                SetEffectPosition(effect.effectId, {x = -36000, y = -1000})
            end
        end
    end
end
--everything generates a UID
--Everything loops through and updates the effect with that UID
--a loop goes through and sets assigned to false, and if it remains false after the next loop, it's UID is removed which tells new effects that they can have it
function CreateEffectSprite(effectPath, pos, angle, uid)
    Effect = nil
    AssignedEffect = false
    if not MasterEffects[effectPath] then MasterEffects[effectPath] = {} end
    for k, v in pairs(MasterEffects[effectPath]) do
        if v.uid == uid then
            AssignedEffect = true
            Effect = v.effectId
            v.assigned = true
            break
        end
    end
    if AssignedEffect == true then
        SetEffectPosition(Effect, pos)
        SetEffectDirection(Effect, angle)
        return
    end
    --if no assigned effect found, find one that's unassigned
    for k, v in pairs(MasterEffects[effectPath]) do
        if v.uid == nil then
            AssignedEffect = true
            v.uid = uid
            Effect = v.effectId
            v.assigned = true
        end
    end
    if AssignedEffect == true then
        SetEffectPosition(Effect, pos)
        SetEffectDirection(Effect, angle)
        return
    end
    --if no unassigned effects could be found, then create a new one at the end of the list

    local newEffect = {
        uid = uid,
        effectId = SpawnEffectEx(effectPath, pos, angle),
        assigned = true,
    }
    table.insert(MasterEffects[effectPath], newEffect)

end