VelocityToSpawnSmoke = 200
function UpdateEffects(frame)
    WheelSmoke(frame)
    SoundUpdate()
end
function InitializeEffects()
	EffectsList =
    --keeps track of existing effect ids
	{
		["engine"] = {},
        ["wheel"] = {},
	}
end

function WheelSmoke(frame)
    --spawns smoke particles where tires touch ground
    for structure, wheels in pairs(TracksId) do
        for deviceId, pos in pairs(wheels) do
            local wheelIsTouchingGround = data.wheelsTouchingGround[structure][GetDeviceKeyFromId(structure, deviceId)]

            local nodeA = GetDevicePlatformA(deviceId)
            local nodeB = GetDevicePlatformB(deviceId)
            local velocity = AverageCoordinates({NodeVelocity(nodeA), NodeVelocity(nodeB)})
            local offset = OffsetPerpendicular(NodePosition(nodeA), NodePosition(nodeB), 75)
            local finalOffset

            if GetDeviceType(deviceId) == WheelSaveName[1] then
                finalOffset = {x = pos.x + offset.x, y = pos.y + offset.y}
            else
                finalOffset = {x = pos.x + -offset.x, y = pos.y + -offset.y}
            end
            if wheelIsTouchingGround then
                local velocityMag = VecMagnitude(velocity)
                if velocityMag and velocityMag > VelocityToSpawnSmoke and frame % 5 == 0 then
                    SpawnEffect(path .. "/effects/smoke_poof.lua", finalOffset)
                end
            end
        end
    end
end

function SoundUpdate()
    --sound script to run on Update()
    if JustJoined then
        SoundOnJoin()
    end
    --BetterLog(EffectsList)
    --engines
    for structureIndex, engine in pairs(data.currentRevs) do
        --pow engine 2 for better revs
        local rpm = math.max(engine * 10000, 172)
        local throttle = math.abs(NormalizeThrottleVal(structureIndex))
        local needEngine = true
        for engine, effect in pairs(EffectsList.engine) do
            --BetterLog(GetDeviceStructureId(tonumber(engine)))
            --BetterLog(structureIndex)
            if GetDeviceStructureId(tonumber(engine)) == structureIndex then
                if needEngine then
                    SetAudioParameter(effect, "rpm", rpm)
                    SetAudioParameter(effect, "Throttle", throttle)
                    needEngine = false
                else
                    SetAudioParameter(effect, "rpm", -100)
                end
                SetEffectPosition(effect, GetDevicePosition(tonumber(engine)))
            end
        end
    end
    --wheels
    --[[
    for wheel, effect in pairs(EffectsList.wheel) do
        SetEffectPosition(effect, GetDevicePosition(tonumber(wheel)))
        local speed = VecMagnitude(NodeVelocity(GetDevicePlatformA(tonumber(wheel))))
        --Log(tostring(speed))
        SetAudioParameter(effect, "trackspeed", speed)
    end]]
end
function SoundAdd(saveName, deviceId)
    --attaches an effect to a new device that tracks sound

    --engine
    if saveName == ControllerSaveName then
        local id = SpawnEffect(path .. "/effects/engine_loop.lua", GetDevicePosition(deviceId))
        EffectsList.engine[tostring(deviceId)] = id
    --wheel
    --[[
    elseif saveName == WheelSaveName[1] or saveName == WheelSaveName[2] then
        local id = SpawnEffect(path .. "/effects/wheel_sound.lua", GetDevicePosition(deviceId))
        EffectsList.wheel[tostring(deviceId)] = id]]
    end
end
function SoundRemove(saveName, deviceId)
    --removes an effect when a device that tracks sound is removed

    --engine
    if saveName == ControllerSaveName then
        if EffectsList.engine[tostring(deviceId)] then
            CancelEffect(EffectsList.engine[tostring(deviceId)])
        end
        EffectsList.engine[tostring(deviceId)] = nil
    --wheel
    elseif saveName == WheelSaveName[1] or saveName == WheelSaveName[2] then
        if EffectsList.wheel[tostring(deviceId)] then
            CancelEffect(EffectsList.wheel[tostring(deviceId)])
        end
        EffectsList.wheel[tostring(deviceId)] = nil
    end
end
function SoundOnJoin()
    --attaches effects to devices that track sound upon joining
    for side = 1, 2 do
        local count = GetDeviceCountSide(side)
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            --engine
            if GetDeviceType(id) == ControllerSaveName then
                SoundAdd(ControllerSaveName, id)
            --wheel
            elseif GetDeviceType(id) == WheelSaveName[1] or GetDeviceType(id) == WheelSaveName[2] then
                SoundAdd(WheelSaveName[1], id)
            end
        end
    end
end