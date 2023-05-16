local savename_drill = "drill"
local savename_drill2 = "drill2"
local savename_drill3 = "drill3"
local savename_drill4 = "drill4"
function InitializeDrill()
    data.drills = {}
    GetDrills()
    --if the map already starts with drills, then enable the device, otherwise disable it.
    --[[
    if #data.drills > 0 then
        EnableDevice(savename_drill, true, 1)
        EnableDevice(savename_drill, true, 2)
    else
        EnableDevice(savename_drill, false, 1)
        EnableDevice(savename_drill, false, 2)
    end]]
end

function UpdateDrill(frame)
    --BetterLog(data.drills)
    for i, id in ipairs(data.drills) do
        --gather condition info
        local speed = VecMagnitude(NodeVelocity(GetDevicePlatformA(id))) --speed of device
        local radians = GetDeviceAngle(id) - 1.570796 --angle of device in radians (needs to be rotated 90 degrees towards ground)
        local position = GetDevicePosition(id)
        local source = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 41)) --source position to cast from. (device position plus angular vector multiplied by device radius)
        local target = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 250)) --target position to cast ray to. (device position plus angular vector multiplied by wheel height)
        local terraincast = CastRay(source, target, RAY_DEBUG, FIELD_DISRUPT_BUILDING) --test if device is near ground
        --test conditions
        if GetDeviceType(id) == savename_drill2 then
            --if drilling conditions are not ideal, retract drills.
            if speed > 100 or terraincast ~= RAY_HIT_TERRAIN then
                local newId = UpgradeDevice(id, savename_drill)
                table.remove(data.drills, i)
                table.insert(data.drills, newId)
                break
            end
        elseif GetDeviceType(id) == savename_drill then
            --if drilling conditions are ideal, start drilling.
            if speed < 100 and terraincast == RAY_HIT_TERRAIN then
                local newId = UpgradeDevice(id, savename_drill2)
                table.remove(data.drills, i)
                table.insert(data.drills, newId)
                break
            end
        end
    end
end

--deviceId tracking functions
function GetDrills()
    --gets the ids of all drills currently present
    for side = 1, 2 do
        local count = GetDeviceCountSide(side)
        for index = 0, count do
            local id = GetDeviceIdSide(side, index)
            --engine
            if GetDeviceType(id) == savename_drill or GetDeviceType(id) == savename_drill2 then
                table.insert(data.drills, id)
            end
        end
    end
end
function DrillAdd(saveName, deviceId)
    --adds a new drill device to the tracking table
    if saveName == savename_drill or saveName == savename_drill2 or saveName == "cannon" or saveName == "battery" then
        table.insert(data.drills, deviceId)
    end
end
function DrillRemove(saveName, deviceId)
    --removes a drill device from the tracking table
    if saveName == savename_drill or saveName == savename_drill2 then
        BetterLog("DrillRemove called")
        for i, id in ipairs(data.drills) do
            if id == deviceId then
                table.remove(data.drills, i)
            end
        end
    end
end