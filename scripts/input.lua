function OnKey(key, down)
    --BetterLog(key)
    if down == true then
        HeldKeys[key] = true
    else
        HeldKeys[key] = nil
    end
end



function CheckHeldKeys()
    for callback, bind in pairs(KEYBINDS) do
        local held = true
        for _, key in pairs(bind) do
            if not HeldKeys[key] then
                held = false
                break
            end
        end
        if held then 
            if not PressedKeyBinds[callback] then
                PressedKeyBinds[callback] = true
                _G[callback]() 
            end
        else
            if PressedKeyBinds[callback] then
                PressedKeyBinds[callback] = nil

                if _G[callback .. "_Up"] then
                    _G[callback .. "_Up"]()
                end
            end
        end
    end
end

