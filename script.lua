--- forts script API --- --script.lua

dofile(path .. "/debugMagic.lua")

dofile("scripts/forts.lua")

dofile(path .. "/config/config.lua")
dofile(path .. "/config/commanders.lua")

dofile(path .. "/scripts/indexing.lua")
dofile(path .. "/scripts/RoadLinks.lua")
dofile(path .. "/scripts/input.lua")
dofile(path .. "/scripts/coreShield.lua")
dofile(path .. "/scripts/resources.lua")
dofile(path .. "/scripts/CommanderDetection.lua")
dofile(path .. "/scripts/BetterLog.lua")
dofile(path .. "/scripts/controls.lua")
dofile(path .. "/scripts/VectorFunctions.lua")
dofile(path .. "/scripts/graphing.lua")
dofile(path .. "/scripts/Tracks.lua")
dofile(path .. "/scripts/WheelCollision.lua")
dofile(path .. "/scripts/PID.lua")
dofile(path .. "/scripts/helperDebug.lua")
dofile(path .. "/scripts/Propulsion.lua")
dofile(path .. "/scripts/effects.lua")
dofile(path .. "/scripts/drillScript.lua")




--for every wheel, calculate the distance between it and every terrain block median center
--if the distance between them is less than the distance between the radius of the terrain block and the wheel added, do collision checks with terrain
--then apply force to device nodes if there's a collision, perpendicular to the hit surface
function Load(GameStart)
    GetDeviceCounts()
    data.teams = {}
    data.teams[1] = DiscoverTeams(1)
    data.teams[2] = DiscoverTeams(2)
    InitializeScript()
    FillCoreShield()
end

function InitializeScript()
    InitializeCommanders()
    for side = 1, 2 do
        EnableWeapon("engine_wep", false, side)
    end
    InitializeTracks()
    InitializePropulsion()
    InitializeDrill()
    InitializeCoreShield()
    InitializeEffects()
    data.terrainCollisionBoxes = {}
    data.previousVals = {}
    data.wheelsTouchingGround = {}
    -- local circle = MinimumBoundingCircle(terrain)
    -- Log(""..circle.x .. " " .. circle.y .. " " .. circle.r)
    -- local id = SpawnCircle(circle, circle.r, { r = 255, g = 20, b = 20, a = 255 }, 10)
    ScheduleCall(5, AlertJoinDiscord, "")
end

function AlertJoinDiscord()
    Log(RGBAtoHex(82, 139, 255, 255, false) ..
    "For reporting bugs, making suggestions, and finding other players, join the Wheel Mod discord!")
    Log(RGBAtoHex(82, 139, 255, 255, false) .. "discord.gg/q676KyczFt")
end

function Update(frame)
    local startUpdateTime = GetRealTime()
    local delta
    DebugLog("---------Start of update---------")
    if not ModDebug then
        ClearDebugControls()
    end
    UpdateFunction("GetDeviceCounts", frame)
    UpdateFunction("IndexDevices", frame)
    UpdateFunction("IndexLinks", frame)
    UpdateFunction("IndexTerrainBlocks", frame)
    UpdateFunction("WheelCollisionHandler", frame)
    UpdateFunction("UpdateControls", frame)
    UpdateFunction("UpdatePropulsion", frame)
    UpdateFunction("UpdateTracks", frame)
    UpdateFunction("TrueUpdateTracks", frame)
    UpdateFunction("UpdateDrill", frame)
    UpdateFunction("UpdateEffects", frame)
    UpdateFunction("ApplyForces", frame)
    UpdateFunction("UpdateResources", frame)
    UpdateFunction("UpdateCoreShields", frame)
    UpdateFunction("CheckHeldKeys", frame)
    LocalScreen = GetCamera()
    
    JustJoined = false
    DebugLog("---------End of update---------")
    delta = (GetRealTime() - startUpdateTime) * 1000
    DebugLog("Update took " .. string.format("%.2f", delta) .. "ms")
    DebugUpdate()
end

function UpdateFunction(callback, frame)
    if ModDebug then
        local prevTime = GetRealTime()
        _G[callback](frame)
        local delta = (GetRealTime() - prevTime) * 1000
        DebugLog(callback .. " took " .. string.format("%.2f", delta) .. "ms")
    else
        _G[callback](frame)
    end
end

function CheckSaveNameTable(input, table)
    for k, v in pairs(table) do
        if input == v then return true end
    end
    return false
end

function OnRestart()
    InitializeScript()
end

function OnSeekStart()
    InitializeScript()
end

function OnDraw()

end

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    if (saveName == "vehicleController") then
        ScheduleCall(0, CreateControllerWeapon, teamId, deviceId, saveName, nodeA, nodeB, t, GetDeviceTeamId(deviceId))
        ApplyDamageToDevice(deviceId, 1000000)
    end
    DrillPlaceEffect(saveName, deviceId)
end

function OnDeviceCompleted(teamId, deviceId, saveName)
    SoundAdd(saveName, deviceId)
    DrillAdd(saveName, deviceId)
end

function OnDeviceDestroyed(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
    RemoveCoreShield(deviceId)
end

function OnDeviceDeleted(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
end

function ApplyForces()
    for device, force in pairs(FinalSuspensionForces) do
        if FinalPropulsionForces[device] then
            --Don't ask me why I have to do it like this, just trust that I do have to
            local newForceX = force.x + FinalPropulsionForces[device].x
            local newForceY = force.y + FinalPropulsionForces[device].y

            FinalAddedForces[device] = { x = newForceX, y = newForceY }
        else
            FinalAddedForces[device] = force
        end
    end

    for device, force in pairs(FinalAddedForces) do
        dlc2_ApplyForce(device.nodeA, force)
        dlc2_ApplyForce(device.nodeB, force)
    end
    FinalSuspensionForces = {}
    FinalPropulsionForces = {}
    FinalAddedForces = {}
end

--I stole this from fortships >:)
function CreateControllerWeapon(teamId, deviceId, saveName, nodeA, nodeB, t, side)
    if DrillsEnabled then
        EnableWeapon("vehicleControllerNoStructure", true, side)
        CreateDevice(teamId, "vehicleControllerNoStructure", nodeA, nodeB, t)
        EnableWeapon("vehicleControllerNoStructure", false, side)
    else
        EnableWeapon("vehicleControllerStructure", true, side)
        CreateDevice(teamId, "vehicleControllerStructure", nodeA, nodeB, t)
        EnableWeapon("vehicleControllerStructure", false, side)
    end
end

function ReinsertKeys(t)
    local newTable = {}
    for i, v in ipairs(t) do
        newTable[i] = v
    end
    return newTable
end

function math.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

--RGBAtoHex, courtesy of Harder_天使的花园
function RGBAtoHex(r, g, b, a, UTF16)
    local hex = string.format("%02X%02X%02X%02X", r, g, b, a)
    if UTF16 == true then
        return L "[HL=" .. towstring(hex) .. L "]"
    else
        return "[HL=" .. hex .. "]"
    end
end

function SplitLines(str)
    local lines = {} -- Table to store the lines
    local index = 1  -- Index to track the current line
    for line in str:gmatch("[^\r\n]+") do
        lines[index] = line
        index = index + 1
    end
    return lines
end

function ControlExists(parent, control)
    if GetControlAbsolutePos(parent, control).x == 0 then
        return false
    end
    return true
end

function Clamp(val, min, max)
    if val > max then return max end
    if val < min then return min end
    return val
end

function GetDeviceKeyFromId(structure, Id)
    for key, device in pairs(Structures[structure]) do
        if device.id == Id then return key end
    end
end

function GetDeviceIdFromKey(structure, key)
    return Structures[structure][key].id
end

dofile(path .. "/debugMagic.lua")

function TimeCode(fn, arg0, arg1, arg2, arg3)
    --logs how long it takes to run a function
    local t1 = GetRealTime()
    fn(arg0, arg1, arg2, arg3)
    local t2 = GetRealTime()
    Log(tostring((t2 - t1) * 1000) .. " ms")
end

function DiscoverTeams(sideId)
	local teamFound = {}
	local teams = {}
	local count = DeviceCounts[sideId]
	for i = 0, count - 1 do
		local id = GetDeviceIdSide(sideId, i)
		local currTeam = GetDeviceTeamIdActual(id)
		if not teamFound[currTeam] and GetDeviceType(id) == "reactor" then
			teamFound[currTeam] = true
			table.insert(teams, currTeam)
		end
	end
	return teams
end