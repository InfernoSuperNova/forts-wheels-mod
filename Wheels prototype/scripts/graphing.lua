--graphing.lua
--- forts script API ---
function GraphingStart()
    data.graphedValues = {
        proportional = {},
        integral = {},
        derivative = {},
    }
end

function UpdateGraphs()
    for k, value in pairs(data.graphedValues) do
        local initialDisplacement = -(#value * 25)
        for time = 1, #value do
            SpawnLine(Vec3(initialDisplacement * time, value[time], 0),
                Vec3(initialDisplacement * time + 1, value[time + 1], 0), { r = 255, g = 255, b = 255, a = 255 },
                data.updateDelta)
        end
    end
end
