
table.insert(Sprites, ButtonSprite("hud-group-throttle", "groups/Group-throttle", GroupButtonSpriteBottom, GroupButtonSpriteBottom, nil, nil, path))
table.insert(Weapons, 1,
{
	SaveName = "engine_wep",
	FileName = path .. "/weapons/engine.lua",
	Icon = "hud-engine-icon",
	GroupButton = "hud-group-throttle",
	Detail = "hud-detail-engine",
	BuildTimeComplete = 25.0,
	ScrapPeriod = 5,
	MetalCost = 0,
	EnergyCost = 0,
	MetalRepairCost = 40,
	EnergyRepairCost = 200,
	SpotterFactor = 0,
	MaxSpotterAssistance = 0.1, -- small benefit from other spotters
	MaxUpAngle = 45,
	BuildOnGroundOnly = false,
	DrawBlurredProjectile = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
    Enabled = false
})

