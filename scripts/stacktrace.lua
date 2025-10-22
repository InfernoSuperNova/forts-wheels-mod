

-- Custom error handler that logs the error message and stack trace
local function error_handler(err)
    -- Log the error
    Log("Error: " .. tostring(err))
    return err  -- Return the error so that xpcall can return it
end

-- Wrap any function so it runs under xpcall + our error handler,
-- and only logs on error. Preserves all return values on success.
local function wrap_with_stack_trace(func)
    return function(...)
        -- Capture the arguments passed to the wrapped function
        local args = { ... }

        -- Build a thunk to call the original function with those arguments
        local function thunk()
            return func(unpack(args))
        end

        -- Using xpcall: [1]=ok (boolean), [2]=ret1 or err, [3]=ret2, ...
        local results = { xpcall(thunk, error_handler) }
        local ok = results[1]

        if not ok then
            -- Error has already been logged by error_handler
            Log(debug.traceback())
            return nil  -- Or handle the error as you prefer (e.g., return default values)
        end

        -- Remove the first element (the boolean ok)
        table.remove(results, 1)

        -- Return all the real return values
        return unpack(results)
    end
end
EventFuncTable = {
    "OnStreamComplete",
    "OnDeviceCompleted",
    "OnDeviceConsumed",
    "OnDeviceCreated",
    "OnDeviceDeleted",
    "OnDeviceDestroyed",
    "OnDeviceHit",
    "OnDeviceHitBeam",
    "OnDeviceMoved",
    "OnDeviceSelected",
    "OnDeviceTeamUpdated",
    "OnGroundDeviceCreated",
    "OnWeaponFireAttemptFail",
    "OnWeaponFired",
    "OnWeaponFiredEnd",
    "OnWeaponOverheated",
    "OnBuildError",
    "OnContextButtonDevice",
    "OnContextButtonStrut",
    "OnContextMenuDevice",
    "OnContextMenuStrut",
    "OnDeviceCreateDisrupted",
    "OnGroupAddition",
    "OnGroupFired",
    "OnGroupMemberDeselected",
    "OnGroupMemberSelected",
    "OnStructureCreateDisrupted",
    "OnTabOpened",
    "OnKey",
    "OnExecuteProjectileAction",
    "OnLinkHit",
    "OnLinkHitBeam",
    "OnPortalUsed",
    "OnProjectileCollision",
    "OnProjectileDestroyed",
    "OnProjectileRedirected",
    "OnShieldReflection",
    "OnTargetDisrupted",
    "OnTerrainHit",
    "OnTerrainHitBeam",
    "OnAchievement",
    "OnGameResult",
    "OnShowResult",
    "OnTeamDefeated",
    "OnDoorControl",
    "OnDoorState",
    "OnLinkCreated",
    "OnLinkDestroyed",
    "OnMaterialSelected",
    "OnNodeBroken",
    "OnNodeCreated",
    "OnNodeDestroyed",
    "OnRepairArea",
    "OnStructurePainted",
    "Cleanup",
    "Load",
    "OnExit",
    "OnInstantReplay",
    "OnNext",
    "OnPreRestart",
    "OnPreSeek",
    "OnRestart",
    "OnSeek",
    "OnSeekStart",
    "OnUpdate",
    "OnDraw",
    "Update",
    "OnEnableTip",
    "OnTipHidden",
    "DismissResult",
    "OnControlActivated"
}


-- Wrap all functions named in EventFuncTable
function WrapEventFunctions()
    for i = 1, #EventFuncTable do
        
        local name = EventFuncTable[i]
        local fn = _G[name]
        if type(fn) == "function" then
            --Log("Hit for " .. name)
            --_G[name] = wrap_with_stack_trace(fn)
        end
    end
end


