table.insert(Sprites, ButtonSprite("hud-suspension-icon", "HUD/HUD-suspension", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-suspension", "suspension", path))
local suspension = 
{
    SaveName = "suspension",
    FileName = path .. "/devices/suspension.lua",
    Icon = "hud-suspension-icon",
    Detail = "hud-detail-suspension",
    BuildTimeComplete = 25,
    ScrapPeriod = 8,
    MetalCost = 150,
    EnergyCost = 1000,
    MetalRepairCost = 25,
    EnergyRepairCost = 500,
    MetalReclaimMin = 0,
    MetalReclaimMax = 0,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0,
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/devices/ui_devices",
    HasDummy = false,
}



InsertDeviceBehind("sandbags", suspension)





table.insert(Sprites, ButtonSprite("hud-suspensionInverted-icon", "HUD/HUD-suspension", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-suspensionInverted", "suspension", path))
local suspension2 = DeepCopy(suspension)

if suspension2 then
    suspension2.SaveName = "suspensionInverted"
    suspension2.FileName = path .. "/devices/suspensionInverted.lua"
end

InsertDeviceBehind("suspension", suspension2)


table.insert(Sprites, ButtonSprite("hud-engine-icon", "HUD/HUD-engine", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-engine", "engine", path))
local engine = 
{
    SaveName = "engine",
    FileName = path .. "/devices/engine.lua",
    Icon = "hud-engine-icon",
    Detail = "hud-detail-engine",
    BuildTimeComplete = 25,
    ScrapPeriod = 8,
    MetalCost = 200,
    EnergyCost = 2000,
    MetalRepairCost = 25,
    EnergyRepairCost = 500,
    MetalReclaimMin = 0,
    MetalReclaimMax = 0,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0,
    MaxUpAngle = 45,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/devices/ui_devices",
    HasDummy = false,
    ClaimsStructure = true,
}



InsertDeviceBehind("sandbags", engine)




local barrel = FindDevice("barrel")
if barrel then
    barrel.Enabled = true
end