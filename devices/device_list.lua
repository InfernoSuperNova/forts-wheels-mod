table.insert(Sprites, ButtonSprite("hud-engine-icon", "HUD/HUD-engine", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-engine", "engine", path))
local engine = 
{
    SaveName = "engine",
    FileName = path .. "/devices/engine.lua",
    Icon = "hud-engine-icon",
    Detail = "hud-detail-engine",
    BuildTimeComplete = 15,
    ScrapPeriod = 8,
    MetalCost = 350,
    EnergyCost = 3000,
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



table.insert(Sprites, ButtonSprite("hud-gearbox-icon", "HUD/HUD-gearbox", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-gearbox", "gearbox", path))
local gearbox = 
{
    SaveName = "gearbox",
    FileName = path .. "/devices/gearbox.lua",
    Icon = "hud-gearbox-icon",
    Detail = "hud-detail-gearbox",
    BuildTimeComplete = 15,
    ScrapPeriod = 8,
    MetalCost = 150,
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

InsertDeviceBehind("engine", gearbox)




table.insert(Sprites, ButtonSprite("hud-suspension-icon", "HUD/HUD-suspension", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-suspension", "suspension", path))
local suspension = 
{
    SaveName = "suspension",
    FileName = path .. "/devices/suspension.lua",
    Icon = "hud-suspension-icon",
    Detail = "hud-detail-suspension",
    BuildTimeComplete = 15,
    ScrapPeriod = 8,
    MetalCost = 100,
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



table.insert(Sprites, ButtonSprite("hud-suspensionInverted-icon", "HUD/HUD-suspension_inv", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-suspensionInverted", "suspension_inv", path))
local suspension2 = DeepCopy(suspension)

if suspension2 then
    suspension2.SaveName = "suspensionInverted"
    suspension2.FileName = path .. "/devices/suspensionInverted.lua"
    suspension2.Icon = "hud-suspensionInverted-icon"
    suspension2.Detail = "hud-detail-suspensionInverted"
end

InsertDeviceBehind("suspension", suspension2)



local barrel = FindDevice("barrel")
if barrel then
    barrel.Enabled = true
end


local drill = DeepCopy(FindDevice("battery"))
if drill then
    --base drill device
    drill.SaveName = "drill"
    drill.FileName = path .. "/devices/drill.lua"
    drill.MaxUpAngle = 45
    drill.Upgrades =
    {
        {
            Enabled = false,
            SaveName = "drill2",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0,
        },
    }

    --drill upgrades to new device when it is able to drill
    local drill2 = DeepCopy(drill)
    drill2.SaveName = "drill2"
    --drill2.Enabled = false
    drill2.FileName = path .. "/devices/drill2.lua"
    drill2.Upgrades =
    {
        {
            Enabled = false,
            SaveName = "drill",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0,
        },
    }

    table.insert(Devices, 1, drill2)
    table.insert(Devices, 1, drill)
end