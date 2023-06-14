function OnKey(key, down)
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

function PrintKeybinds(showDebug)
    local lines = {}

    --filter out debug binds and put rest in new table so we can sort alphabetically
    for k,v in pairs(KEYBINDS) do
        if showDebug or not k:lower():find("debug") then
            table.insert(lines, {name = k, keys = v})
        end
    end

    table.sort(lines, function(a,b) return a.name < b.name end)

    for i,v in ipairs(lines) do
        local text = v.name:gsub("(%l)(%u)", "%1 %2")  .. ": " --put spaces between words

        for _, cur_key in pairs(v.keys) do
            cur_key = string.gsub(" "..cur_key, "%W%l", string.upper):sub(2) --capitalize first letters
            text = text .. cur_key .. "+"
        end

        Notice(text:sub(1, -2)) --cut off last +
    end
end