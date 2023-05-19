--- forts script API --- --script.lua

dofile(path .. "/debugMagic.lua")

dofile("scripts/forts.lua")

dofile(path .. "/config/config.lua")
dofile(path .. "/config/commanders.lua")

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


JustJoined = true --to run something once upon joining through Update. (used for effects)


--for every wheel, calculate the distance between it and every terrain block median center
--if the distance between them is less than the distance between the radius of the terrain block and the wheel added, do collision checks with terrain
--then apply force to device nodes if there's a collision, perpendicular to the hit surface
function Load(GameStart)
    InitializeScript()
   
end


function InitializeScript()
    InitializeCommanders()
    for side = 1, 2 do
        EnableWeapon("engine_wep", false, side)
    end
    InitializeTracks()
    InitializePropulsion()
    InitializeDrill()
    InitializeEffects()
    GraphingStart()
    data.terrainCollisionBoxes = {}
    data.previousVals = {}
    data.wheelsTouchingGround = {}
    data.structures = {}
    -- local circle = MinimumBoundingCircle(terrain)
    -- Log(""..circle.x .. " " .. circle.y .. " " .. circle.r)
    -- local id = SpawnCircle(circle, circle.r, { r = 255, g = 20, b = 20, a = 255 }, 10)
end
function Update(frame)
    LocalScreen = GetCamera()
    if frame == 125 then
        Notice(RGBAtoHex(82, 139, 255, 255, false) .. "For reporting bugs, making suggestions, and finding other players, join the Wheel Mod discord!")
        Notice(RGBAtoHex(82, 139, 255, 255, false) .. "discord.gg/q676KyczFt")
    end
    DebugLog("---------Start of update---------")
    IndexTerrainBlocks()
    DebugLog("Index terrain blocks good")
    WheelCollisionHandler()
    DebugLog("Wheel collision handler good")
    UpdateControls()
    DebugLog("Update controls good")
    UpdatePropulsion()
    DebugLog("Propulsion good")
    UpdateTracks()
    DebugLog("Clear tracks good")
    TrueUpdateTracks()
    DebugLog("Update tracks good")
    UpdateGraphs()
    DebugLog("Update graphs good")
    UpdateDrill(frame)
    DebugLog("Update drill good")
    UpdateEffects(frame)
    DebugLog("Update effects good")
    ApplyForces()
    DebugLog("apply forces good")
    UpdateResources()
    DebugLog("Update resources good")
    JustJoined = false
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
	if (saveName == "engine") then
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
            
            FinalAddedForces[device] = {x = newForceX, y = newForceY}
        else
            FinalAddedForces[device] = force
        end
        
    end
    
    for device, force in pairs(FinalAddedForces) do
        local nodeA = GetDevicePlatformA(device)
        local nodeB = GetDevicePlatformB(device)
        dlc2_ApplyForce(nodeA, force)
        dlc2_ApplyForce(nodeB, force)
    end
    FinalSuspensionForces = {}
    FinalPropulsionForces = {}
    FinalAddedForces = {}
end

--I stole this from fortships >:)
function CreateControllerWeapon(teamId, deviceId, saveName, nodeA, nodeB, t, side)
	EnableWeapon("engine_wep", true, side)
	CreateDevice(teamId, "engine_wep", nodeA, nodeB, t)
	EnableWeapon("engine_wep", false, side)
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


function DebugLog(string)
    if ModDebug == true then BetterLog(string) end
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

    for key, value in pairs(data.structures[structure]) do
        if value == Id then return key end
    end
end

function GetDeviceIdFromKey(structure, key)
    return data.structures[structure][key]
end
dofile(path .. "/debugMagic.lua")
