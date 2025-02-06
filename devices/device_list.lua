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
    EnergyCost = 1500,
    MetalRepairCost = 25,
    EnergyRepairCost = 500,
    MetalReclaimMin = 0.16,
    MetalReclaimMax = 0.5,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0.5,
    MaxUpAngle = 45,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/devices/ui_devices",
    HasDummy = false,
}

InsertDeviceBehind("engine", gearbox)

table.insert(Sprites, ButtonSprite("hud-controller-icon", "HUD/HUD-controller", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-controller", "controller", path))
local controller = 
{
    SaveName = "vehicleController",
    FileName = path .. "/devices/controller.lua",
    Icon = "hud-controller-icon",
    Detail = "hud-detail-controller",
    BuildTimeComplete = 15,
    ScrapPeriod = 8,
    MetalCost = 300,
    EnergyCost = 2000,
    MetalRepairCost = 25,
    EnergyRepairCost = 500,
    MetalReclaimMin = 0.16,
    MetalReclaimMax = 0.5,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0.5,
    MaxUpAngle = 45,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/devices/ui_devices",
    HasDummy = false,
}

InsertDeviceBehind("sandbags", controller)

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
    MetalReclaimMin = 0.25,
    MetalReclaimMax = 0.5,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 0.5,
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



local suspensionLarge = DeepCopy(suspension)
if suspensionLarge then
    suspensionLarge.MetalCost = 225
    suspensionLarge.EnergyCost = 2000
    suspensionLarge.SaveName = "largeSuspension"
    suspensionLarge.FileName = path .. "/devices/largeSuspension.lua"
    suspensionLarge.Prerequisite = "upgrade"
end
InsertDeviceBehind("suspensionInverted", suspensionLarge)



local suspensionLarge2 = DeepCopy(suspensionLarge)
if suspensionLarge2 then
    suspensionLarge2.SaveName = "largeSuspensionInverted"
    suspensionLarge2.FileName = path .. "/devices/largeSuspensionInverted.lua"
    suspensionLarge2.Icon = "hud-suspensionInverted-icon"
    suspensionLarge2.Detail = "hud-detail-suspensionInverted"
end
InsertDeviceBehind("largeSuspension", suspensionLarge2)




local suspensionSmall = DeepCopy(suspension)
if suspensionSmall then
    suspensionSmall.MetalCost = 75
    suspensionSmall.EnergyCost = 500
    suspensionSmall.SaveName = "smallSuspension"
    suspensionSmall.FileName = path .. "/devices/smallSuspension.lua"
    suspensionSmall.Prerequisite = "upgrade"
end
InsertDeviceBehind("sandbags", suspensionSmall)



local suspensionSmall2 = DeepCopy(suspensionSmall)
if suspensionSmall2 then
    suspensionSmall2.SaveName = "smallSuspensionInverted"
    suspensionSmall2.FileName = path .. "/devices/smallSuspensionInverted.lua"
    suspensionSmall2.Icon = "hud-suspensionInverted-icon"
    suspensionSmall2.Detail = "hud-detail-suspensionInverted"
end
InsertDeviceBehind("smallSuspension", suspensionSmall2)



local suspensionExtraLarge = DeepCopy(suspensionLarge)
if suspensionExtraLarge then
    suspensionExtraLarge.MetalCost = 700
    suspensionExtraLarge.EnergyCost = 8000
    suspensionExtraLarge.SaveName = "extraLargeSuspension"
    suspensionExtraLarge.FileName = path .. "/devices/extraLargeSuspension.lua"
    suspensionExtraLarge.Prerequisite = "upgrade"
end
InsertDeviceBehind("largeSuspensionInverted", suspensionExtraLarge)

local suspensionExtraLarge2 = DeepCopy(suspensionExtraLarge)
if suspensionExtraLarge2 then
    suspensionExtraLarge2.SaveName = "extraLargeSuspensionInverted"
    suspensionExtraLarge2.FileName = path .. "/devices/extraLargeSuspensionInverted.lua"
    suspensionExtraLarge2.Icon = "hud-suspensionInverted-icon"
    suspensionExtraLarge2.Detail = "hud-detail-suspensionInverted"
end

InsertDeviceBehind("extraLargeSuspension", suspensionExtraLarge2)


--add drills
table.insert(Sprites, ButtonSprite("hud-drills-icon", "HUD/HUD-drill", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-drills", "drill", path))
local drill = DeepCopy(FindDevice("battery"))
if drill then
    --base drill device
    drill.SaveName = "drill"
    drill.BuildTimeComplete = 30.0
    drill.MetalCost = 200
    drill.EnergyCost = 2000
    drill.Icon = "hud-drills-icon"
    drill.Detail = "hud-detail-drills"
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
        {
            Enabled = true,
            SaveName = "drill3",
            Prerequisite = "upgrade",
            MetalCost = 100,
            EnergyCost = 2500,
            BuildDuration = 20,
        },
    }

    --drill upgrades to new device when it is able to drill
    local drill2 = DeepCopy(drill)
    drill2.SaveName = "drill2"
    drill2.Enabled = false
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
        {
            Enabled = true,
            SaveName = "drill3",
            Prerequisite = "upgrade",
            MetalCost = 100,
            EnergyCost = 2500,
            BuildDuration = 20,
        },
    }

    --upgrade for drill that does more metal
    local drill3 = DeepCopy(drill)
    drill3.SaveName = "drill3"
    drill3.MetalCost = 300
    drill3.EnergyCost = 4500
    drill3.Enabled = false
    drill3.FileName = path .. "/devices/drill3.lua"
    drill3.Upgrades =
    {
        {
            Enabled = false,
            SaveName = "drill4",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0,
        },
    }
    --upgrade to the upgradable drill that drills.
    local drill4 = DeepCopy(drill3)
    drill4.SaveName = "drill4"
    drill4.FileName = path .. "/devices/drill4.lua"
    drill4.Upgrades =
    {
        {
            Enabled = false,
            SaveName = "drill3",
            MetalCost = 0,
            EnergyCost = 0,
            BuildDuration = 0,
        },
    }
    --insert to table
    table.insert(Devices, 1, drill4)
    table.insert(Devices, 1, drill3)
    table.insert(Devices, 1, drill2)
    table.insert(Devices, 1, drill)
end

dofile(path .. "/scripts/helpers/BetterLog.lua")
