function UpdateEffects()

    WheelSmoke()
end

function WheelSmoke()
    for structure, wheels in pairs(data.wheelsTouchingGround) do
        for deviceId, _ in pairs(wheels) do
            
            local nodeA = GetDevicePlatformA(deviceId)
            local nodeB = GetDevicePlatformB(deviceId)
            local velocity = NodeVelocity(nodeA)
            BetterLog(velocity)
            local velocityMag = VecMagnitude(velocity)
            BetterLog(velocityMag)
            if velocityMag > 50 then
                local pos = OffsetPerpendicular(NodePosition(nodeA), NodePosition(nodeB), WheelSuspensionHeight + WheelRadius)
                BetterLog("e")
                SpawnEffect(path .. "/effects/smoke_poof.lua", pos)
                
            end
        end
    end
end