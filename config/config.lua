ModDebug = {
    collision = false,
    update = false,
}
DebugText = ""

--config values

--wheels
WHEEL_RADIUS = 75                                    --radius of the wheels
TrackWidth = 20                                     --width of the tracks
WheelSuspensionHeight = 150                         --height from the origin of the suspension to the wheel itself
SpringConst = 30000                                 --spring constant, the force that wheels will push off with. Higher spring value will necessitate a higher dampening value
Dampening = 3000                                    --spring dampening for wheel collisions (higher is less bouncy, lower is less stable)
--propulsion
PROPULSION_FACTOR = 5000000                         --engine power
MAX_POWER_INPUT_RATIO = 1                           --how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
VEL_PER_GEARBOX = 800                               --velocity per engine, in grid units per sec
GEAR_CHANGE_RATIO = 0.95                            --upper threshold of current gear range to switch to the next one
THROTTLE_DEADZONE = 0.02                            --portion of the throttle to ingore
--devices
WheelSaveName = {"suspension", "suspensionInverted"}--savenames of the wheel devices
EngineSaveName = "engine"                           --savename of engine device
ControllerSaveName = {"vehicleControllerStructure", "vehicleControllerNoStructure"}                           
                                                    --savename of the controller
GearboxSaveName = "gearbox"                         --savename of the transmission
MetalCostPerSecMaxThrottle = 5                      --upper limit to the metal per second consumption of engines
TRACK_LINK_DISTANCE = 40                              --distance between track links (visual)
DrillsEnabled = false                               --whether to enable drills or not
--Core shields
ShieldRadius = 1800                                 --radius of the base protecting shield
ShieldDamage = 2                                    --damage of the core shield at center (* 25 per sec)
ShieldForce = 2500000                               --pushback force of the shield at center
--roads
RoadSaveName = "RoadLink"                           --SaveName for the road material

--binds
Keybinds = {
    ToggleUpdateDebug = {"left control", "left alt", "t"},
    ToggleCollisionDebug = {"left control", "left alt", "d"},
    
}
PressedKeyBinds = {}
HeldKeys = {}


--script.lua
BlockStatistics = {
    largestBlock = 0,
    totalNodes = 0,
    totalBlocks = 0,
} --stats for collision debug overlay
JustJoined = true --to run something once upon joining through Update. (used for effects)
Displacement = {}
WheelPos = {}
TracksId = {}
FinalSuspensionForces = {}
FinalPropulsionForces = {}
FinalAddedForces = {}
Motors = {}
Gearboxes = {}
TrackOffsets = {}
Tracks = {}
SortedTracks = {}
PushedTracks = {}
LocalEffects = {}
TrackGroups = {}
Terrain = {}
DeviceCounts = {}
---Devices table
--[[
{
    [structureId: number] = {
        nodeA:number
        nodeB:number
        team:number
        id:number
        saveName:number
        pos{x:number, y:number}

    }
}]]
Devices = {}
Structures = {}


--- forts script API ---

SpecialFrame = 1




