table.insert(Sprites, ButtonSprite("hud-brake-icon", "HUD/HUD-Brake", nil, ButtonSpriteBottom, true, nil, path) )
table.insert(Sprites, ButtonSprite("hud-brake-pressed-icon", "HUD/HUD-Brake-pressed", nil, ButtonSpriteBottom, true, nil, path))

local box = ButtonSprite("hud-smallui-box", "HUD/HUD-smallui-box", nil, ButtonSpriteBottom, true, nil, path)
box.States.Pressed = nil
box.States.Disabled = nil
table.insert(Sprites, box)

table.insert(Sprites, Sprite("hud-smallui-brake", path .. "/ui/textures/HUD/HUD-smallui-brake.dds"))
table.insert(Sprites, Sprite("hud-smallui-arrow", path .. "/ui/textures/HUD/HUD-smallui-arrow.dds"))