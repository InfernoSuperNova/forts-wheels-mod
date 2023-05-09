function UpdateEffects()

    WheelSmoke()
    EngineSoundUpdate()
end
function InitializeEffects()
	EffectsList =
    --keeps track of existing effect ids
	{
		["engine"] = {},
	}
end
function WheelSmoke()
    -- for structure, wheels in pairs(data.structures) do
    --     for deviceId, _ in pairs(wheels) do
            
    --         local nodeA = GetDevicePlatformA(deviceId)
    --         local nodeB = GetDevicePlatformB(deviceId)
    --         local velocity = NodeVelocity(nodeA)
    --         local velocityMag = VecMagnitude(velocity)
    --         if velocityMag > 50 then
    --             local pos = OffsetPerpendicular(NodePosition(nodeA), NodePosition(nodeB), WheelSuspensionHeight + WheelRadius)
    --             SpawnEffect(path .. "/effects/smoke_poof.lua", pos)
                
    --         end
    --     end
    -- end
end

function EngineSoundUpdate()
    --Engine sound script to run on Update()
    --[[
    if JustJoined then
        EngineSoundOnJoin()
    end
    DebugLog(data.throttles)
    for structureIndex, engine in pairs(data.throttles) do
        local rpm = math.abs((engine.x - 274) * 25)
        DebugLog(EffectsList)
        for engine, effect in pairs(EffectsList.engine) do
            DebugLog(GetDeviceStructureId(tonumber(engine)))
            DebugLog(GetStructureId(structureIndex - 1))
            if GetDeviceStructureId(tonumber(engine)) == GetStructureId(structureIndex - 1) then
                SetAudioParameter(effect, "rpm", rpm)
                SetEffectPosition(effect, GetDevicePosition(tonumber(engine)))
            end
        end
    end]]
end
function EngineSoundAdd(saveName, deviceId)
    --[[
    --attaches an effect to a new engine device
    if saveName == ControllerSaveName then
        local id = SpawnEffect(path .. "/effects/engine_loop.lua", GetDevicePosition(deviceId))
        EffectsList.engine[tostring(deviceId)] = id
    end]]
end
function EngineSoundRemove(saveName, deviceId)
    --[[
    --removes an effect when an engine device is removed
    if saveName == ControllerSaveName then
        CancelEffect(EffectsList.engine[tostring(deviceId)])
        EffectsList.engine[tostring(deviceId)] = nil
    end]]
end
function EngineSoundOnJoin()
    --[[
    --attaches effects to engines upon joining
    for side = 1, 2 do
        local count = GetDeviceCountSide(side)
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            if GetDeviceType(id) == ControllerSaveName then
                EngineSoundAdd(ControllerSaveName, id)
            end
        end
    end]]
end