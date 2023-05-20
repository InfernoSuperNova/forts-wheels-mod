ModDebug = false


--config values

--wheels
WheelRadius = 75                                    --radius of the wheels
TrackWidth = 20                                     --width of the tracks
WheelSuspensionHeight = 150                         --height from the origin of the suspension to the wheel itself
SpringConst = 30000                                 --spring constant, the force that wheels will push off with. Higher spring value will necessitate a higher dampening value
Dampening = 3000                                    --spring dampening for wheel collisions (higher is less bouncy, lower is less stable)
--propulsion
PROPULSION_FACTOR = 2500000                         --engine power
MAX_POWER_INPUT_RATIO = 2                           --how much of an engine one wheel can recieve (0.5 is half an engine, 2 is 2 engines)
VEL_PER_GEARBOX = 800                               --velocity per engine, in grid units per sec
GEAR_CHANGE_RATIO = 0.95                            --upper threshold of current gear range to switch to the next one
THROTTLE_DEADZONE = 0.02                            --portion of the throttle to ingore
--devices
WheelSaveName = {"suspension", "suspensionInverted"}--savenames of the wheel devices
EngineSaveName = "engine_wep"                       --savename of engine device
ControllerSaveName = "engine_wep"                   --savename of the controller
GearboxSaveName = "gearbox"                         --savename of the transmission
MetalCostPerSecMaxThrottle = 5                      --upper limit to the metal per second consumption of engines
TrackLinkDistance = 40                              --distance between track links (visual)
--script.lua


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



--- forts script API ---

SpecialFrame = 1




