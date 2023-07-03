ModDebug = {
    collision = false,
    update = false,
}
DebugText = ""

--config values


--propulsion
PROPULSION_FACTOR = 5000000                             --engine power
MAX_POWER_INPUT_RATIO = 1                               --how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
VEL_PER_GEARBOX = 800                                   --velocity per engine, in grid units per sec
GEAR_CHANGE_RATIO = 0.95                                --upper threshold of current gear range to switch to the next one
THROTTLE_DEADZONE = 0.02                                --portion of the throttle to ingore
--devices

ENGINE_SAVE_NAME = {"engine"}                           --savename of engine device
CONTROLLER_SAVE_NAME = {"vehicleControllerStructure", "vehicleControllerNoStructure"}     
MAX_CONTROLLERS = 2                                     --maximum amount of controllers                     
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
--Turrets
TURRET_SAVE_NAME = {"turretCannon2"}
TURRET_ANIM_NAMES = {"turretCannonFlip1", "turretCannonFlip2", "turretCannonFlip3"} 
--binds
KEYBINDS = {
    ToggleUpdateDebug = {"left control", "left alt", "t"},
    ToggleCollisionDebug = {"left control", "left alt", "d"},
    ToggleForcesDebug = {"left control", "left alt", "f"},

    MoveLeft = {"left shift", "a"},
    MoveRight = {"left shift", "d"},
    ToggleBrake = {"left shift", "f"}
}
---@class PressedKeyBinds Keybinds that are currently being pressed.
---@field [callback] boolean
PressedKeyBinds = {}
---@class PressedKeys Keys that are currently being pressed.
---@field [key] boolean
HeldKeys = {}


---@class BlockStatistics Table for block statistics
---@field largestBlock number The node count of the largest block in the map
---@field totalNodes number The total node count across all blocks
---@field totalBlocks number The total amount of blocks in the map
BlockStatistics = {
    largestBlock = 0,
    totalNodes = 0,
    totalBlocks = 0,
}
InEditor = false                                    --Whether the user is in the editor
DrillsEnabled = false                               --whether to enable drills or not
JustJoined = true --to run something once upon joining through Update. (used for effects)
Metric = true --switch hud elements between mph and km/h
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
TerrainCorners ={}
SpecialTerrain = {moving = {}, ignored = {}}
DeviceCounts = {}
DrivechainDetails = {}
OrbitalLasers = {}
AwaitingOrbitalLasers = {}
---@class Pos
---@field x number
---@field y number

---@class Devices Table containing relevant device detail
---@field key{strucId:number, team:number, id:number, saveName:string, pos:Pos, nodeA:number, nodeB:number, nodeVelA:Pos, nodeVelB:Pos}
Devices = {}
Structures = {}


--- forts script API ---

SpecialFrame = 1




