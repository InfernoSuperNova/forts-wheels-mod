--- forts script API --- --script.lua



dofile("scripts/forts.lua")
dofile(path .. "/scripts/debugMagic.lua")
dofile(path .. "/scripts/BetterLog.lua")
dofile(path .. "/scripts/VectorFunctions.lua")
dofile(path .. "/scripts/graphing.lua")
dofile(path .. "/scripts/Tracks.lua")
dofile(path .. "/scripts/WheelCollision.lua")
dofile(path .. "/scripts/PID.lua")
dofile(path .. "/scripts/helperDebug.lua")
dofile(path .. "/scripts/Propulsion.lua")
dofile(path .. "/scripts/effects.lua")

Displacement = {}
WheelPos = {}
WheelRadius = 75
WheelSuspensionHeight = 150

WheelSaveName = "suspension"

ModDebug = false



--for every wheel, calculate the distance between it and every terrain block median center
--if the distance between them is less than the distance between the radius of the terrain block and the wheel added, do collision checks with terrain
--then apply force to device nodes if there's a collision, perpendicular to the hit surface
function Load(GameStart)
    for side = 1, 2 do
        EnableWeapon("engine_wep", false, side)
    end
    InitializeTracks()
    InitializePropulsion()
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
    DebugLog("---------Start of update---------")
    IndexTerrainBlocks()
    DebugLog("Index terrain blocks good")
    WheelCollisionHandler()
    DebugLog("Wheel collision handler good")
    UpdatePropulsion()
    DebugLog("Propulsion good")
    UpdateTracks()
    DebugLog("Clear tracks good")
    TrueUpdateTracks()
    DebugLog("Update tracks good")
    UpdateGraphs()
    DebugLog("Update graphs good")
    UpdateEffects()
    DebugLog("Update effects good")
    
    


    
    
end

function OnDeviceCreated(teamId, deviceId, saveName, nodeA, nodeB, t, upgradedId)
	if (saveName == "engine") then
		ScheduleCall(0, CreateControllerWeapon, teamId, deviceId, saveName, nodeA, nodeB, t, GetDeviceTeamId(deviceId))
		ApplyDamageToDevice(deviceId, 1000000)
	end
end

--I stole this from fortships >:)
function CreateControllerWeapon(teamId, deviceId, saveName, nodeA, nodeB, t, side)
	EnableWeapon("engine_wep", true, side)
	CreateDevice(teamId, "engine_wep", nodeA, nodeB, t)
	EnableWeapon("engine_wep", false, side)
end

function OnRestart()
    InitializePropulsion()
end
function OnSeek()
    InitializePropulsion()
end
function OnDraw()

    


end

function ReinsertKeys(t)
    local newTable = {}
    for i, v in ipairs(t) do
        newTable[i] = v
    end
    return newTable
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
dofile(path .. "/debugMagic.lua")
