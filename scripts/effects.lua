VelocityToSpawnSmoke = 200
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