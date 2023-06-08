--wheels
WHEEL_RADIUS = 75                                       --radius of the wheels
TRACK_WIDTH = 20                                        --width of the tracks
WHEEL_SUSPENSION_HEIGHT = {75, 150, 225}                --height from the origin of the suspension to the wheel itself
SPRING_CONST = 30000                                    --spring constant, the force that wheels will push off with. Higher spring value will necessitate a higher dampening value
DAMPENING = 3000                                        --spring dampening for wheel collisions (higher is less bouncy, lower is less stable)
WHEEL_SAVE_NAME = {"suspension", "suspensionInverted"}  --savenames of the wheel devices

WHEEL_SUSPENSION_HEIGHTS = {
    small = 75, 
    medium = 150, 
    large = 225
}
WHEEL_RADIUSES = 
{
    small = 75,
    medium = 75,
    large = 150
}
WHEEL_SAVE_NAMES = 
{
    small = {"smallSuspension", "smallSuspensionInverted"},
    medium = {"suspension", "suspensionInverted"},
    large = {"largeSuspension", "largeSuspensionInverted"},
}
TRACK_SPROCKET_EFFECT_PATHS = 
{
    sprocket = {
        small = "/effects/track_sprocket.lua",
        medium = "/effects/track_sprocket.lua",
        large = "/effects/track_sprocket_large.lua",
    },
    wheel = {
        small = "/effects/wheel.lua",
        medium = "/effects/wheel.lua",
        large = "/effects/wheel_large.lua"
    },
}