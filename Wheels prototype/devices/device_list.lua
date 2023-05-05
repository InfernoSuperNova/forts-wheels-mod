local suspension = 
{
    SaveName = "suspension",
    FileName = path .. "/devices/suspension.lua",
    Icon = "hud-sandbags-icon",
    Detail = "hud-detail-sandbags",
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
    MaxUpAngle = 45,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/devices/ui_devices",
    HasDummy = false,
}

InsertDeviceBehind("sandbags", suspension)
local engine = 
{
    SaveName = "engine",
    FileName = path .. "/devices/engine.lua",
    Icon = "hud-battery-icon",
    Detail = "hud-detail-sandbags",
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
    ClaimsStructure = true
}


local barrel = FindDevice("barrel")
if barrel then
    barrel.Enabled = true
end
InsertDeviceBehind("sandbags", engine)