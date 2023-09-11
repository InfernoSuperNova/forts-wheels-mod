--- forts script API --- --script.lua

dofile(path .. "/debugMagic.lua")
dofile("scripts/forts.lua")
dofile(path .. "/config/fileList.lua")
LoadFiles()


function Load(GameStart)
    
    if GetGameMode() == "Editor" then 
        InEditor = true 
        ModDebug.update = true
        ModDebug.collision = true
    end
    data.roadLinks = {}
    GetDeviceCounts()
    data.teams = {
        DiscoverTeams(1),
        DiscoverTeams(2)
    }
    InitializeScript()
    FillCoreShield()
    LocalizeStrings()
    OnLoad_Controls()
end

function InitializeScript()
    
    InitializeCommanders()
    InitializeTerrainBlockSats()
    for side = 1, 2 do
        EnableWeapon("engine_wep", false, side)
        EnableDevice("turbine", true, side)
        EnableDevice("smokestack", true, side)
    end
    IndexLinks()
    data.terrainCollisionBoxes = {}
    IndexTerrainBlocks()
    InitializeTracks()
    InitializePropulsion()
    InitializeDrill()
    InitializeCoreShield()
    InitializeEffects()
    LoadWeapons()
    data.previousVals = {}
    data.wheelsTouchingGround = {}
    data.wheelLinksColliding = {}
    -- local circle = MinimumBoundingCircle(terrain)
    -- Log(""..circle.x .. " " .. circle.y .. " " .. circle.r)
    -- local id = SpawnCircle(circle, circle.r, { r = 255, g = 20, b = 20, a = 255 }, 10)
    ScheduleCall(5, AlertJoinDiscord, "")
    SetControlFrame(1)
    AddTextControl("", "worldBlockDebug", "", ANCHOR_TOP_LEFT, {x = 0, y = 0, z = -10}, true, "Console")
end

function AlertJoinDiscord()
    Log(RGBAtoHex(82, 139, 255, 255, false) ..
    "For reporting bugs, making suggestions, and finding other players, join the Wheel Mod discord!")
    Log(RGBAtoHex(82, 139, 255, 255, false) .. "discord.gg/q676KyczFt")
end

function Update(frame)
    LocalScreen = GetCamera()
    local startUpdateTime = GetRealTime()
    local delta
    DebugLog("---------Start of update---------")
    if not ModDebug.update then
        ClearDebugControls()
    end
    UpdateFunction("ClearTerrainDebugControls", frame)
    DebugHighlightTerrain(frame)
    UpdateFunction("GetDeviceCounts", frame)
    UpdateFunction("IndexDevices", frame)
    UpdateFunction("UpdateDevices", frame)
    UpdateFunction("IndexMovingBlocks", frame)
    UpdateFunction("UpdateLinks", frame)
    UpdateFunction("WheelCollisionHandler", frame)
    UpdateFunction("UpdateRoads", frame)
    UpdateFunction("UpdateControls", frame)
    UpdateFunction("UpdatePropulsion", frame)
    --UpdateFunction("UpdateTracks", frame)
    UpdateFunction("TrueUpdateTracks", frame)
    UpdateFunction("UpdateDrill", frame)
    UpdateFunction("UpdateEffects", frame)
    UpdateFunction("ApplyForces", frame)
    UpdateFunction("UpdateResources", frame)
    UpdateFunction("UpdateCoreShields", frame)
    UpdateFunction("UpdateWeapons", frame)
    
    JustJoined = false
    DebugLog("---------End of update---------")
    delta = (GetRealTime() - startUpdateTime) * 1000
    DebugLog("Update took " .. string.format("%.2f", delta) .. "ms")
    UpdateFunction("DebugUpdate", frame)
end

function UpdateFunction(callback, frame)
    if ModDebug.update then
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
    SoundOnJoin()
end

function OnDraw(frame)
    if not IsPaused() then
        UpdateTracks()
    end
    
    if InEditor then
        UpdateEditor()
    end
end

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
    AddVehicleController(saveName, teamId, deviceId, nodeA, nodeB, t)
    DrillPlaceEffect(saveName, deviceId)
    SoundAdd(saveName, deviceId)
    CheckTurrets(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
end
function OnWeaponFired(teamId, saveName, weaponId, projectileNodeId, projectileNodeIdFrom)
    FillOLTable(saveName, weaponId)
end


function OnDeviceCompleted(teamId, deviceId, saveName)
    DrillAdd(saveName, deviceId)
end

function OnDeviceDestroyed(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
    RemoveCoreShield(deviceId)
    RemoveTurretDirection(deviceId)
end

function OnDeviceDeleted(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
    RemoveTurretDirection(deviceId)
end


function OnLinkCreated(teamId, saveName, nodeA, nodeB, pos1, pos2, extrusion)
    CheckNewRoadLinks(saveName, nodeA, nodeB)
end

function OnLinkHit(nodeIdA, nodeIdB, objectId, objectTeamId, objectSaveName, damage, pos, reflectedByEnemy)
    FillAwaitingOLTable(nodeIdA, nil)
    
end
function OnDeviceHit(teamId, deviceId, saveName, newHealth, projectileNodeId, projectileTeamId, pos, reflectedByEnemy)
    FillAwaitingOLTable(nil, deviceId)
end

function OnTerrainHit(terrainId, damage, projectileNodeId, projectileSaveName, surfaceType, pos, normal, reflectedByEnemy)
    FillAwaitingOLTable(nil, nil)
end
function OnLinkDestroyed(teamId, saveName, nodeA, nodeB, breakType)
--broken until beeman fixes
--     DestroyOldRoadLinks(saveName, nodeA, nodeB)
end


function ApplyForces()
    for deviceId, force in pairs(FinalSuspensionForces) do
        if FinalPropulsionForces[deviceId] then
            --Don't ask me why I have to do it like this, just trust that I do have to
            local newForce = {
                nodeA = {
                    x = force.DampenedForceA.x + FinalPropulsionForces[deviceId].x,
                    y = force.DampenedForceA.y + FinalPropulsionForces[deviceId].y,
                },
                nodeB = {
                    x = force.DampenedForceB.x + FinalPropulsionForces[deviceId].x,
                    y = force.DampenedForceB.y + FinalPropulsionForces[deviceId].y,
                }
            }
            

            FinalAddedForces[deviceId] = newForce
        else
            FinalAddedForces[deviceId] = {nodeA = force.DampenedForceA, nodeB = force.DampenedForceB}
        end
    end

    for deviceId, force in pairs(FinalAddedForces) do
        local device = FindDeviceInMasterIndex(deviceId)
        dlc2_ApplyForce(device.nodeA, force.nodeA)
        dlc2_ApplyForce(device.nodeB, force.nodeB)
    end
    FinalSuspensionForces = {}
    FinalPropulsionForces = {}
    FinalAddedForces = {}
end
function AddVehicleController(saveName, teamId, deviceId, nodeA, nodeB, t)
    --check savename matches
    if saveName == "vehicleController" then
        --destroy the device, to be replaced with weapon version so it can be control grouped
        ApplyDamageToDevice(deviceId, 1000000)
        local structureControllerCount = 0
        local existingControllerPositions = {}
        --search for controllers on the same structure, and count them
        for _, device in pairs(Devices) do
            if CheckSaveNameTable(device.saveName, CONTROLLER_SAVE_NAME) and device.strucId == GetDeviceStructureId(deviceId) then
                    structureControllerCount = structureControllerCount + 1
                    existingControllerPositions[device.id] = device.pos
            end
        end
        --if there are too many controllers, destroy the new one and give the player a refund
        if structureControllerCount >= MAX_CONTROLLERS then
            --deterministic
            AddResources(teamId, { metal = 300, energy = 2000 }, false, Vec3(0, 0, 0))
            --GetLocalTeamId is non deterministic, should only be used for effects
            if GetLocalTeamId() == teamId then
                SpawnEffect("effects/weapon_blocked.lua", GetDevicePosition(deviceId))
                for _, device in pairs(existingControllerPositions) do
                    SpawnEffect("effects/weapon_blocked.lua", device)
                end
            end

            return
        end
        --else, continue with the creation of the controller weapon
        ScheduleCall(0, CreateControllerWeapon, teamId, deviceId, saveName, nodeA, nodeB, t, GetDeviceTeamId(deviceId))
    end
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
    if not Structures[structure] then return nil end
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

function IgnoreDecimalPlaces(number, decimalPoint)
    local multiplier = 10 ^ decimalPoint
    local roundedNumber = math.floor(number * multiplier) / multiplier
    return roundedNumber
  end

  function OnContextMenuDevice(deviceTeamId, deviceId, saveName)
    TrackContextMenu(saveName)
end

function OnContextButtonDevice(name, deviceTeamId, deviceId, saveName)
    TrackContextButton(name, deviceId)
end

function GetHighestIndex(tbl)
    local highest = 0
    for k, v in pairs(tbl) do
        if k > highest then
            highest = k
        end
    end
    return highest
end
