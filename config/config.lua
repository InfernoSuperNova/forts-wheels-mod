ModDebug = {
    collision = false,
    update = false,
}
DebugText = ""

--config values

--wheels
WHEEL_RADIUS = 75                                       --radius of the wheels
TRACK_WIDTH = 20                                        --width of the tracks
WHEEL_SUSPENSION_HEIGHT = 150                           --height from the origin of the suspension to the wheel itself
SPRING_CONST = 30000                                    --spring constant, the force that wheels will push off with. Higher spring value will necessitate a higher dampening value
DAMPENING = 3000                                        --spring dampening for wheel collisions (higher is less bouncy, lower is less stable)
--propulsion
PROPULSION_FACTOR = 5000000                             --engine power
MAX_POWER_INPUT_RATIO = 1                               --how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
VEL_PER_GEARBOX = 800                                   --velocity per engine, in grid units per sec
GEAR_CHANGE_RATIO = 0.95                                --upper threshold of current gear range to switch to the next one
THROTTLE_DEADZONE = 0.02                                --portion of the throttle to ingore
--devices
WHEEL_SAVE_NAME = {"suspension", "suspensionInverted"}  --savenames of the wheel devices
ENGINE_SAVE_NAME = {"engine"}                           --savename of engine device
CONTROLLER_SAVE_NAME = {"vehicleControllerStructure", "vehicleControllerNoStructure"}                           
                                                        --savename of the controller
GEARBOX_SAVE_NAME = {"gearbox"}                         --savename of the transmission
ENGINE_RUN_COST = 5                                     --upper limit to the metal per second consumption of engines
TRACK_LINK_DISTANCE = 40                                --distance between track links (visual)
--Core shields
SHIELD_RADIUS = 1800                                    --radius of the base protecting shield
SHIELD_DAMAGE = 2                                       --damage of the core shield at center (* 25 per sec)
SHIELD_FORCE = 2500000                                  --pushback force of the shield at center
--roads
ROAD_SAVE_NAME = {"RoadLink"}                           --SaveName for the road material

--binds
KEYBINDS = {
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
DrillsEnabled = false                               --whether to enable drills or not
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
SpecialTerrain = {moving = {}, ignored = {}}
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




