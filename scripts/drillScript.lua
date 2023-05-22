local savename_drill = "drill"
local savename_drill2 = "drill2"
local savename_drill3 = "drill3"
local savename_drill4 = "drill4"

local idsPerFrame = 15
function InitializeDrill()
    data.drills = {}
    GetDrills()
    --if the map already starts with drills, then enable the device, otherwise disable it.
    if #data.drills > 0 then
        EnableDevice(savename_drill, true, 1)
        EnableDevice(savename_drill, true, 2)
        DrillsEnabled = true
    else
        EnableDevice(savename_drill, false, 1)
        EnableDevice(savename_drill, false, 2)
        DrillsEnabled = false
    end
end

function UpdateDrill(frame)
    --the unlaginator (spread checks over several frames). 
    local framesToDistribute = math.ceil(#data.drills / idsPerFrame)
    for i = frame%framesToDistribute * idsPerFrame, frame%framesToDistribute * idsPerFrame + idsPerFrame do
        local id = data.drills[i]
        --gather condition info
        if id ~= nil then
            local speed = VecMagnitude(NodeVelocity(GetDevicePlatformA(id))) --speed of device
            local radians = GetDeviceAngle(id) - 1.570796 --angle of device in radians (needs to be rotated 90 degrees towards ground)
            local position = GetDevicePosition(id)
            local source = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 61)) --source position to cast from. (device position plus angular vector multiplied by device radius)
            --test conditions
            if GetDeviceType(id) == savename_drill2 then
                --if drilling conditions are not ideal, retract drills.
                local target = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 250)) --target position to cast to.
                local terraincast = CastRay(source, target, RAY_INCLUDE_DISABLED, FIELD_DISRUPT_BUILDING) --make cast
                if speed > 100 or terraincast ~= RAY_HIT_TERRAIN then
                    UpgradeDevice(id, savename_drill)
                    table.remove(data.drills, i)
                end
                --upgraded version
            elseif GetDeviceType(id) == savename_drill4 then
                local target = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 250))
                local terraincast = CastRay(source, target, RAY_INCLUDE_DISABLED, FIELD_DISRUPT_BUILDING)
                if speed > 100 or terraincast ~= RAY_HIT_TERRAIN then
                    UpgradeDevice(id, savename_drill3)
                    table.remove(data.drills, i)
                end
            elseif GetDeviceType(id) == savename_drill then
                --if drilling conditions are ideal, start drilling.
                local target = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 240))
                local terraincast = CastRay(source, target, RAY_INCLUDE_DISABLED, FIELD_DISRUPT_BUILDING)
                if speed < 50 and terraincast == RAY_HIT_TERRAIN then
                    UpgradeDevice(id, savename_drill2)
                    table.remove(data.drills, i)
                end
                --upgraded version
            elseif GetDeviceType(id) == savename_drill3 then
                local target = AddVectors(position, ScaleVector(Vec3(math.sin(radians), math.cos(radians)), 240))
                local terraincast = CastRay(source, target, RAY_INCLUDE_DISABLED, FIELD_DISRUPT_BUILDING)
                if speed < 50 and terraincast == RAY_HIT_TERRAIN then
                    UpgradeDevice(id, savename_drill4)
                    table.remove(data.drills, i)
                end
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
            if GetDeviceType(id) == savename_drill or GetDeviceType(id) == savename_drill2 or GetDeviceType(id) == savename_drill3 or GetDeviceType(id) == savename_drill4 then
                table.insert(data.drills, id)
            end
        end
    end
end
function DrillAdd(saveName, deviceId)
    --adds a new drill device to the tracking table
    if saveName == savename_drill or saveName == savename_drill2 or saveName == savename_drill3 or saveName == savename_drill4 then
        table.insert(data.drills, deviceId)
    end
end
function DrillRemove(saveName, deviceId)
    --removes a drill device from the tracking table
    if saveName == savename_drill or saveName == savename_drill2 or saveName == savename_drill3 or saveName == savename_drill4 then
        for i, id in ipairs(data.drills) do
            if id == deviceId then
                table.remove(data.drills, i)
            end
        end
    end
end

--spawn the device place effect if the building isnt instant (placed by player)
function DrillPlaceEffect2(id, type)
    if IsDeviceFullyBuilt(id) == false then
        if type == 1 then
            SpawnEffect("effects/device_construct.lua", GetDevicePosition(id))
        elseif type == 2 then
            SpawnEffect("effects/device_upgrade.lua", GetDevicePosition(id))
        end
    end
end
function DrillPlaceEffect(saveName, id)
    if saveName == savename_drill then
        ScheduleCall(0.04,  DrillPlaceEffect2, id, 1)
    elseif saveName == savename_drill3 then
        ScheduleCall(0.04,  DrillPlaceEffect2, id, 2)
    end
end
