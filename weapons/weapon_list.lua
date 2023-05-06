

table.insert(Weapons, 1,
{
	SaveName = "engine_wep",
	FileName = path .. "/weapons/engine.lua",
	Icon = "hud-flak-icon",
	GroupButton = "hud-group-flak",
	Detail = "hud-detail-flak",
	BuildTimeComplete = 25.0,
	ScrapPeriod = 5,
	MetalCost = 0,
	EnergyCost = 0,
	MetalRepairCost = 40,
	EnergyRepairCost = 200,
	SpotterFactor = 0,
	MaxSpotterAssistance = 0.1, -- small benefit from other spotters
	MaxUpAngle = StandardMaxUpAngle,
	BuildOnGroundOnly = false,
	DrawBlurredProjectile = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
    Enabled = false
})

