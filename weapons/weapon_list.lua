
dofile(path .. "/scripts/BetterLog.lua")
table.insert(Sprites, ButtonSprite("hud-group-throttle", "groups/Group-throttle", GroupButtonSpriteBottom, GroupButtonSpriteBottom, nil, nil, path))
table.insert(Weapons, 1,
{
	SaveName = "vehicleControllerNoStructure",
	FileName = path .. "/weapons/controllerNoStructure.lua",
	Icon = "hud-engine-icon",
	GroupButton = "hud-group-throttle",
	Detail = "hud-detail-engine",
	BuildTimeComplete = 15.0,
	ScrapPeriod = 5,
	MetalCost = 0,
	EnergyCost = 0,
	MetalRepairCost = 40,
	EnergyRepairCost = 200,
    MetalReclaimMin = 25,
    MetalReclaimMax = 50,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 500,
	SpotterFactor = 0,
	MaxSpotterAssistance = 0.1, -- small benefit from other spotters
	MaxUpAngle = 45,
	BuildOnGroundOnly = false,
	DrawBlurredProjectile = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
    Enabled = false
})
table.insert(Weapons, 1,
{
	SaveName = "vehicleControllerStructure",
	FileName = path .. "/weapons/controllerStructure.lua",
	Icon = "hud-engine-icon",
	GroupButton = "hud-group-throttle",
	Detail = "hud-detail-engine",
	BuildTimeComplete = 15.0,
	ScrapPeriod = 5,
	MetalCost = 0,
	EnergyCost = 0,
	MetalRepairCost = 40,
	EnergyRepairCost = 200,
    MetalReclaimMin = 25,
    MetalReclaimMax = 50,
    EnergyReclaimMin = 0,
    EnergyReclaimMax = 500,
	SpotterFactor = 0,
	MaxSpotterAssistance = 0.1, -- small benefit from other spotters
	MaxUpAngle = 45,
	BuildOnGroundOnly = false,
	DrawBlurredProjectile = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
    Enabled = false
})


table.insert(Weapons, InheritType(Weapons[1], nil, {
    FileName = path .. "/weapons/observer_dummy.lua",
    SaveName = "observer_dummy",
    BuildTimeComplete = 0,
    Upgrades = {},
    Enabled = false
}))

--     local silo = DeepCopy(FindWeapon("missile"))
--     if silo then
--         silo.SaveName = silo.SaveName .. "Structure"
--         silo.BuildOnGroundOnly = false
--     end

-- InsertWeaponBehind("missile", silo)


