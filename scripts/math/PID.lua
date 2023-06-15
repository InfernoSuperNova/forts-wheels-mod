--PID.lua
--- forts script API ---
-- local Kp = 16000 --Proportional
-- local Ki = 0.06  --Integral
-- local Kd = 2     --Derivative


function SpringDampenedForce(springConst, displacement, dampening, velocity)
    local force = springConst * displacement - dampening * velocity
    return force
end

-- function InitializeWheelPID(device)
--     --set up PID initialization values if they don't exist
--     if not data.previousVals[device] then
--         data.previousVals[device] = {
--             output = {
--                 x = 0,
--                 y = 0,
--             },
--             integral = {
--                 x = 0,
--                 y = 0,
--             },
--             lastError = {
--                 x = 0,
--                 y = 0,
--             }
--         }
--     end
-- end

-- --PID, but 2 vectors
-- ---@param setpoint{x:number, y:number} Where it wants to be
-- ---@param state {x:number, y:number} Where it is
-- ---@param integral {x:number, y:number} Integral
-- ---@param lastError {x:number, y:number} Last error
-- function Vector2PID(setpoint, state, integral, lastError)
--     local pidX = PID(setpoint.x, state.x, integral.x, lastError.x)
--     local pidY = PID(setpoint.y, state.y, integral.y, lastError.y)
--     return {
--         output = {
--             x = pidX.output,
--             y = pidY.output,
--         },
--         integral = {
--             x = pidX.integral,
--             y = pidY.integral,
--         },
--         lastError = {
--             x = pidX.lastError,
--             y = pidY.lastError,
--         }
--     }
-- end

-- --basic PID controller
-- function PID(setpoint, state, integral, lastError)
--     local error = setpoint - state
--     local integral = integral + error
--     local derivative = error - lastError
--     return {
--         output = Kp * error + Ki * integral + Kd * derivative,
--         integral = integral,
--         lastError = error
--     }
-- end
