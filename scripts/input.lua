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
            if not HeldKeys[key] then held = false end
        end
        if held then 
            if not PressedKeyBinds[callback] then
                PressedKeyBinds[callback] = true
            _G[callback]() 
            end
        else
            PressedKeyBinds[callback] = nil
        end
    end
end

