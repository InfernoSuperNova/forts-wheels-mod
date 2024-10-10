--wheels
WHEEL_RADIUS = 75                                       --radius of the wheels
TRACK_WIDTH = 20                                        --width of the tracks
WHEEL_SUSPENSION_HEIGHT = {75, 150, 225}                --height from the origin of the suspension to the wheel itself
SPRING_CONST = 30000                                    --spring constant, the force that wheels will push off with. Higher spring value will necessitate a higher dampening value
DAMPENING = 3000                                        --spring dampening for wheel collisions (higher is less bouncy, lower is less stable)
TORQUE_MUL = 3
WHEEL_SAVE_NAME = {"suspension", "suspensionInverted"}  --savenames of the wheel devices

WHEEL_SPRINGS = {
    smallSuspension = {springConst = 30000, dampening = 1000},
    smallSuspensionInverted = {springConst = 30000, dampening = 1000},
    suspension = {springConst = 30000, dampening = 3000},
    suspensionInverted = {springConst = 30000, dampening = 3000},
    largeSuspension = {springConst = 60000, dampening = 4000},
    largeSuspensionInverted = {springConst = 60000, dampening = 4000},
    extraLargeSuspension = {springConst = 100000, dampening = 6000},
    extraLargeSuspensionInverted = {springConst = 100000, dampening = 6000},
}

WHEEL_POWER_INPUT_RATIOS = {
    smallSuspension = 1,
    smallSuspensionInverted = 1,
    suspension = 1,
    suspensionInverted = 1,
    largeSuspension = 2,
    largeSuspensionInverted = 2,
    extraLargeSuspension = 4,
    extraLargeSuspensionInverted = 4,
}
WHEEL_BRAKE_FACTORS = {
    smallSuspension = 240000,   
    smallSuspensionInverted = 240000,
    suspension = 240000,
    suspensionInverted = 240000,
    largeSuspension = 480000,
    largeSuspensionInverted = 480000,
    extraLargeSuspension = 960000,
    extraLargeSuspensionInverted = 960000,
}

WHEEL_SUSPENSION_HEIGHTS = {
    small = 75, 
    medium = 150, 
    large = 225,
    extraLarge = 350,
}
WHEEL_RADIUSES = 
{
    small = 75,
    medium = 75,
    large = 150,
    extraLarge = 250,
}
WHEEL_SAVE_NAMES = 
{
    small = {"smallSuspension", "smallSuspensionInverted"},
    medium = {"suspension", "suspensionInverted"},
    large = {"largeSuspension", "largeSuspensionInverted"},
    extraLarge = {"extraLargeSuspension", "extraLargeSuspensionInverted"},
}
WHEEL_SAVE_NAMES_RAW = {
    ["smallSuspension"] = true,
    ["smallSuspensionInverted"] = true,
    ["suspension"] = true,
    ["suspensionInverted"] = true,
    ["largeSuspension"] = true,
    ["largeSuspensionInverted"] = true,
    ["extraLargeSuspension"] = true,
    ["extraLargeSuspensionInverted"] = true,
}
TRACK_SPROCKET_EFFECT_PATHS = 
{
    sprocket = {
        small = "/effects/track_sprocket.lua",
        medium = "/effects/track_sprocket.lua",
        large = "/effects/track_sprocket_large.lua",
        extraLarge = "/effects/track_sprocket_extraLarge.lua",
    },
    wheel = {
        small = "/effects/wheel.lua",
        medium = "/effects/wheel.lua",
        large = "/effects/wheel_large.lua",
        extraLarge = "/effects/wheel_extraLarge.lua",
    },
}
EFFECT_DISPLACEMENT_KEYS = {
    ["smallSuspension"] = 75,
    ["smallSuspensionInverted"] = -75,
    ["suspension"] = 75,
    ["suspensionInverted"] = -75,
    ["largeSuspension"] = 150,
    ["largeSuspensionInverted"] = -150,
    ["extraLargeSuspension"] = 300,
    ["extraLargeSuspensionInverted"] = -300,
}