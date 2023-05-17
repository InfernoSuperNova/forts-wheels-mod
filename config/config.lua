--script.lua


Displacement = {}
WheelPos = {}
TracksId = {}
FinalSuspensionForces = {}
FinalPropulsionForces = {}
FinalAddedForces = {}
WheelRadius = 75
TrackWidth = 20
WheelSuspensionHeight = 150

WheelSaveName = {"suspension", "suspensionInverted"}
ModDebug = false


--propulsion.lua

--engine power
PROPULSION_FACTOR = 2500000
--how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
MAX_POWER_INPUT_RATIO = 2
--velocity per engine, in grid units per sec
VEL_PER_GEARBOX = 800
GEAR_CHANGE_RATIO = 0.95
THROTTLE_DEADZONE = 0.02
EngineSaveName = "engine_wep"

ControllerSaveName = "engine_wep"

GearboxSaveName = "gearbox"
Motors = {}
Gearboxes = {}

--tracks.lua

--- forts script API ---
TrackOffsets = {}
SpecialFrame = 1
TrackLinkDistance = 40
Tracks = {}
SortedTracks = {}
PushedTracks = {}
LocalEffects = {}
TrackGroups = {}

--wheelCollision.lua
SpringConst = 30000
Dampening = 3000

Terrain = {}
