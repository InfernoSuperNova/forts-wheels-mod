--- forts script API --- --script.lua

dofile("scripts/forts.lua")
dofile(path .. "/config/fileList.lua")
LoadFiles()


function Load(GameStart)
    if not type(dlc2_ApplyForce) == "function" then
        BetterLog("Error: Landcruisers will not function without High Seas. Please get someone who owns High Seas to host the game, or buy it yourself.")
        BetterLog(RGBAtoHex(100, 200, 100, 255, false) .. "This is because applyforce is not available in the base game, and is required for the suspension system.")
    end
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
    Gravity = GetConstant("Physics.Gravity")
    Fps = GetConstant("Physics.FramesRate")
    ScreenMaxY = GetMaxScreenY()
end


WheelSprite = 0



function InitializeScript()
    LocalTeam = GetLocalTeamId() % MAX_SIDES
    CompileWheelSaveNames()
    InitializeCommanders()
    InitializeTerrainBlockSats()
    for side = 1, 2 do
        EnableWeapon("engine_wep", false, side)
        EnableDevice("turbine", true, side)
        EnableDevice("smokestack", true, side)
    end
    IndexLinks()
    IndexTerrainBlocks()
    InitializeTracks()
    InitializePropulsion()
    InitializeDrill()
    InitializeCoreShield()
    InitializeEffects()
    EffectManager:Load()
    IndexDevices()
    LoadWeapons()
    data.previousVals = {}
    WheelsTouchingGround = {}
    WheelForces = {}
    data.wheelLinksColliding = {}
    -- local circle = MinimumBoundingCircle(terrain)
    -- Log(""..circle.x .. " " .. circle.y .. " " .. circle.r)
    -- local id = SpawnCircle(circle, circle.r, { r = 255, g = 20, b = 20, a = 255 }, 10)

    InitializePremiumIds()
    LoadWheelTypes()
    ScheduleCall(1, LoadPremiumWheels, "")
    ScheduleCall(5, AlertJoinDiscord, "")
    ScheduleCall(5, AlertReducedVisuals, "")
    
    SetControlFrame(1)
    AddTextControl("", "worldBlockDebug", "", ANCHOR_TOP_LEFT, {x = 0, y = 0, z = -100}, true, "Console")
end

function AlertJoinDiscord()
    Log(RGBAtoHex(82, 139, 255, 255, false) ..
    "For reporting bugs, making suggestions, and finding other players, join the Official Landcruisers discord!")
    Log(RGBAtoHex(200, 139, 255, 255, false) .. "discord.gg/q676KyczFt")
end

function AlertReducedVisuals()
    Notice(RGBAtoHex(150, 200, 50, 255, false) ..
    "Press Ctrl + LShift + LAlt + V to toggle reduced visuals")


end


local justUpdated = false
local lastUpdate = 0
CurrentFrame = 0
function Update(frame)
    CurrentFrame = frame
    justUpdated = true
    local rotation = AngleToVector(frame)
    SetEffectDirection(WheelSprite, rotation)
    LocalScreen = GetCamera()
    local startUpdateTime = GetRealTime()
    
    DebugLog("---------Start of update---------")
    if not ModDebug.update then
        ClearDebugControls()
    end
    EffectManager:Update()
    UpdateFunction("ClearTerrainDebugControls", frame)
    DebugHighlightTerrain(frame)
    UpdateFunction("GetDeviceCounts", frame)
    --UpdateFunction("IndexDevices", frame)
    UpdateFunction("UpdateDevices", frame)
    UpdateFunction("IndexMovingBlocks", frame)
    UpdateFunction("UpdateLinks", frame)
    UpdateFunction("WheelCollisionHandler", frame)
    UpdateFunction("UpdateRoads", frame)
    UpdateFunction("UpdateControls", frame)
    UpdateFunction("UpdatePropulsion", frame)
    UpdateFunction("UpdateTracks", frame)
    UpdateFunction("UpdateDrill", frame)
    UpdateFunction("UpdateEffects", frame)
    UpdateFunction("UpdateForceManager", frame)
    UpdateFunction("UpdateResources", frame)
    UpdateFunction("UpdateCoreShields", frame)
    UpdateFunction("UpdateWeapons", frame)
    MissileManager:Update()
    
    JustJoined = false
    DebugLog("---------End of update---------")
    local delta = (GetRealTime() - startUpdateTime) * 1000
    if ModDebug.update then
        DebugLog("Update took " .. string.format("%.3f", delta) .. "ms, " .. string.format("%.1f", delta/(data.updateDelta * 1000) * 100) .. "%")
        DebugLog("Memory Usage: " .. FormatNumberWithCommas(gcinfo()) .. " KB")

        DebugLog("EffectManager:")
        DebugLog("Current effect id: " .. FormatNumberWithCommas(EffectManager.MaxEffectId))
        EffectManager:DebugUpdate()

        UpdateFunction("DebugUpdate", frame)
    end
    
    --RogueTableChecker()
    lastUpdate = GetRealTime()
end

function FormatNumberWithCommas(number)
    return string.format("%d", number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end
function UpdateFunction(callback, frame)
    if ModDebug.update then
        local prevTime = GetRealTime()
        _G[callback](frame)
        local delta = (GetRealTime() - prevTime) * 1000
        DebugLog(callback .. " took " .. string.format("%.3f", delta) .. "ms, " .. string.format("%.1f", delta/(data.updateDelta * 1000) * 100) .. "%")
    else
        _G[callback](frame)
    end
end

function CheckSaveNameTable(input, t)
    for k, v in ipairs(t) do
        if input == v then return true end
    end
    return false
end

function CompileWheelSaveNames()
    local saveNames = {}
    for k, wheelType in pairs(WHEEL_SAVE_NAMES) do
        for _, name in ipairs(wheelType) do
            WHEEL_SAVE_NAMES_RAW[name] = true
        end
    end
    return saveNames
end

function IsWheelDevice(saveName)
    return WHEEL_SAVE_NAMES_RAW[saveName]
end

function OnRestart()
    InitializeScript()
end

function OnSeekStart()
    InitializeScript()
    SoundOnJoin()
end

function OnInstantReplay()
    InitializeScript()
end

LocalSide = 0
local previousDrawFrameTime = 0
local previousDrawFrameDelta = 0
function OnDraw()
    local startTime = previousDrawFrameTime
    OnDrawBody()
    local endTime = GetRealTime()
    local delta = (endTime - startTime) * 1000
    
    if (delta > 30 and previousDrawFrameDelta > 30 and not justUpdated and previousDrawFrameTime ~= 0 and CurrentFrame > 10) then -- Updating slower than 60fps
        Notice(RGBAtoHex(255, 255, 50, 255) .. "Drawing related performance dips detected, reduced visuals have been enabled. Press LCtrl + LShift + LAlt + V to toggle them back on.")
        ReducedVisuals = true
        OnDraw = OnDrawBody
    end
    previousDrawFrameTime = endTime
    previousDrawFrameDelta = delta
    justUpdated = false
end

function OnDrawBody()
    if not IsPaused() then
        local currentTime = GetRealTime()
        local deltaTime = currentTime - lastUpdate
        local t = deltaTime / data.updateDelta
        DrawTracks(LocalSide, t)
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
    IndexDevice(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
end


function OnWeaponFired(teamId, saveName, weaponId, projectileNodeId, projectileNodeIdFrom)
    FillOLTable(saveName, weaponId)
    --add weapon velocity to projectile
    if projectileNodeIdFrom == 0 and IsGroundDevice(weaponId) == false then
        --platform node velocity
        local velocityA = NodeVelocity(GetDevicePlatformA(weaponId))
        local velocityB = NodeVelocity(GetDevicePlatformB(weaponId))
        local velocityAB = Vec3((velocityA.x + velocityB.x) / 2, (velocityA.y + velocityB.y) / 2)
        --calculate force
        local mass = GetProjectileParamFloat(GetNodeProjectileSaveName(projectileNodeId), teamId, "ProjectileMass", 1)
        local force = Vec3((mass * velocityAB.x) / (1/Fps), (mass * velocityAB.y) / (1/Fps))
        --apply force
        dlc2_ApplyForce(projectileNodeId, force)
    end
    MissileManager:RegisterNewMissile(projectileNodeId)
end


function OnDeviceCompleted(teamId, deviceId, saveName)
    DrillAdd(saveName, deviceId)
end

function OnDeviceDestroyed(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
    RemoveCoreShield(deviceId)
    RemoveTurretDirection(deviceId)
    HandleDestroyedDevice(teamId, deviceId, saveName, nodeA, nodeB, t)
    UntrackDevice(deviceId)
end

function OnDeviceDeleted(teamId, deviceId, saveName, nodeA, nodeB, t)
    SoundRemove(saveName, deviceId)
    DrillRemove(saveName, deviceId)
    RemoveTurretDirection(deviceId)
    HandleDestroyedDevice(teamId, deviceId, saveName, nodeA, nodeB, t)
    UntrackDevice(deviceId)
end

function OnNodeBroken(nodeId, nodeIdNew)
    HandleBrokenNode(nodeId, nodeIdNew)
end

function OnDeviceTeamUpdated(oldTeamId, newTeamId, deviceId, saveName)
    UpdateDeviceTeam(oldTeamId, newTeamId, deviceId, saveName)
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
--     DestroyOldRoadLinks(saveName, nodeA, node

-- 29/01/2024: I don't remember what was broken? - DeltaWing
end


function AddVehicleController(saveName, teamId, deviceId, nodeA, nodeB, t)
    --check savename matches
    if saveName == "vehicleController" then
        --destroy the device, to be replaced with weapon version so it can be control grouped
        ApplyDamageToDevice(deviceId, 1000000)
        local structureControllerCount = 0
        local existingControllerPositions = {}
        --search for controllers on the same structure, and count them
        for _, device in pairs(data.devices) do
            if CheckSaveNameTable(device.saveName, CONTROLLER_SAVE_NAME) and device.strucId == GetDeviceStructureId(deviceId) and device.teamId == teamId then
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
        ScheduleCall(0.08, CreateControllerWeapon, teamId, deviceId, saveName, nodeA, nodeB, t, GetDeviceTeamId(deviceId))
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


function ToSide(team)
    
end


RogueTables = {}
function RogueTableChecker()
    CheckRogueTable(data, "data")
end

function CheckRogueTable(table, parentTree)
    local LogOnlyTablesThatHaventDecreased = true
    for tableType, obj in pairs(table) do
        if type(obj) == "table" then
            local parentTree = parentTree .. "." .. tableType
            local newCount = GetTableCount(obj)
            if not RogueTables[obj] then
                RogueTables[obj] = {length = newCount, parentTree = parentTree, hasDecreased = false, countSinceDecrease = 0}
            else
                local prevLength = RogueTables[obj].length
                RogueTables[obj].length = newCount
                if prevLength < RogueTables[obj].length then
                    RogueTables[obj].countSinceDecrease = RogueTables[obj].countSinceDecrease + 1
                    if LogOnlyTablesThatHaventDecreased then
                        if not RogueTables[obj].hasDecreased then
                            BetterLog(RogueTables[obj].parentTree .. " has increased in size from " .. prevLength .. " to " .. RogueTables[obj].length .. ". Count since decrease: " .. RogueTables[obj].countSinceDecrease)
                        end
                    else
                        BetterLog(RogueTables[obj].parentTree .. " has increased in size from " .. prevLength .. " to " .. RogueTables[obj].length .. ". Has decreased: " .. tostring(RogueTables[obj].hasDecreased) .. ". Count since decrease: " .. RogueTables[obj].countSinceDecrease)
                    end
                    
                end
                if prevLength > RogueTables[obj].length then
                    if LogOnlyTablesThatHaventDecreased then
                        if not RogueTables[obj].hasDecreased then
                            RogueTables[obj].hasDecreased = true
                            RogueTables[obj].countSinceDecrease = 0
                            BetterLog(RogueTables[obj].parentTree .. " has decreased in size from " .. prevLength .. " to " .. RogueTables[obj].length .. ", removing from tracker")
                        end
                    else
                        RogueTables[obj].hasDecreased = true
                        RogueTables[obj].countSinceDecrease = 0
                        BetterLog(RogueTables[obj].parentTree .. " has decreased in size from " .. prevLength .. " to " .. RogueTables[obj].length)
                    end
                end
            end 
            CheckRogueTable(obj, parentTree)
        end
    end
end

function GetTableCount(table)
    local count = 0
    for k, v in pairs(table) do
        count = count + 1
    end
    return count
end
function GetMaxScreenY()
	--Gets monitor aspect ratio. used for hud and camera stuff.
	local maxY = 600
	for i = 1889, 150, -1 do
		if IsPointVisible(ScreenToWorld(Vec3(1066, i)), "") then
			maxY = i
			break
		end
	end
	return maxY
end