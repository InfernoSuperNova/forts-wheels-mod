
dofile(path .. "/scripts/BetterLog.lua")

function LCAddComp(weapons)
	--To streamline the tedious work of adding all possible group weapons to every single weapon in the group
	--example usage: LCAddComp({"rocketemp", "rocket", "firerocket", "acidrocket"})
	for k, v in pairs(weapons) do
		local weapon = FindWeapon(v)
		if weapon then
			if not weapon.CompatibleGroupTypes then
				weapon.CompatibleGroupTypes = {}
			end
			for k, vv in pairs(weapons) do
				if FindWeapon(vv) then
					table.insert(weapon.CompatibleGroupTypes, 1, vv)
				end
			end
		end
	end
end

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
    MetalReclaimMin = 0,
    MetalReclaimMax = 0,
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
    MetalReclaimMin = 0,
    MetalReclaimMax = 0,
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











--Courtesy of bryqnth3sup3r

table.insert(Weapons, IndexOfWeapon("missile2") + 1,
{	
	SaveName = "missilestructure",
	FileName = path.. "/weapons/missileswarmstructure.lua",
	Enabled = true,
	Icon = "hud-missileswarm-icon",
	GroupButton = "hud-group-missile",
	Detail = "hud-detail-missileswarm",
	AnimationScript = "weapons/missilelauncher_anim.lua",
	Prerequisite = "workshop",
	BuildTimeComplete = 70.0,		
	ScrapPeriod = 10,
	MetalCost = 1000,
	EnergyCost = 2500,
	MetalRepairCost = 80,
	EnergyRepairCost = 1250,
	MetalReclaimMin = 0.25,
	MetalReclaimMax = 0.5,
	EnergyReclaimMin = 0.1,
	EnergyReclaimMax = 0.5,
	SpotterFactor = 0.0, -- can't spot for itself (need a sniper with LOS)
	MaxSpotterAssistance = 0,
	MaxUpAngle = 360,
	BuildOnGroundOnly = false,
	AlignToCursorNormal = false,
	RequiresSpotterToFire = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
		
	Upgrades =
	{
		["missilestructure2"] =
		{
			Enabled = true,
			SaveName = "missilestructure2",
			MetalCost = 200,
			EnergyCost = 2000,
		},
	},
	
	CompatibleGroupTypes =
	{
		"missile",
		"missileinv",
		"missilestructure",
		"missilestructureinv",
		"missile2",
		"missile2inv",
		"missilestructure2",
		"missilestructure2inv",
	},
})

table.insert(Weapons, IndexOfWeapon("missilestructure") + 1,
{	
	SaveName = "missilestructure2",
	FileName = path.. "/weapons/missilelauncherstructure.lua",
	Enabled = false,
	Icon = "hud-missile-icon",
	GroupButton = "hud-group-missile",
	Detail = "hud-detail-missile",
	AnimationScript = "weapons/missilelauncher_anim.lua",
	Prerequisite = "upgrade",
	BuildTimeComplete = 65.0,
	ScrapPeriod = 8,
	MetalCost = 1200,
	EnergyCost = 4500,
	MetalRepairCost = 80,
	EnergyRepairCost = 1250,
	MetalReclaimMin = 0.25,
	MetalReclaimMax = 0.5,
	EnergyReclaimMin = 0.1,
	EnergyReclaimMax = 0.5,
	SpotterFactor = 0.0, -- can't spot for itself (need a sniper with LOS)
	MaxSpotterAssistance = 0,
	MaxUpAngle = 360,
	BuildOnGroundOnly = false,
	AlignToCursorNormal = false,
	RequiresSpotterToFire = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
	
	CompatibleGroupTypes =
	{
		"missile",
		"missileinv",
		"missilestructure",
		"missilestructureinv",
		"missile2",
		"missile2inv",
		"missilestructure2",
		"missilestructure2inv",
	},
})

table.insert(Weapons, IndexOfWeapon("missilestructure2") + 1,
{	
	SaveName = "missilestructureinv",
	FileName = path.. "/weapons/missileswarmstructure_inverted.lua",
	Enabled = true,
	Inverted = true,
	Icon = "hud-missileswarm-icon",
	GroupButton = "hud-group-missile",
	Detail = "hud-detail-missileswarm",
	AnimationScript = "weapons/missilelauncher_anim.lua",
	Prerequisite = "workshop",
	BuildTimeComplete = 70.0,		
	ScrapPeriod = 10,
	MetalCost = 1000,
	EnergyCost = 2500,
	MetalRepairCost = 80,
	EnergyRepairCost = 1250,
	MetalReclaimMin = 0.25,
	MetalReclaimMax = 0.5,
	EnergyReclaimMin = 0.1,
	EnergyReclaimMax = 0.5,
	SpotterFactor = 0.0, -- can't spot for itself (need a sniper with LOS)
	MaxSpotterAssistance = 0,
	MaxUpAngle = 360,
	BuildOnGroundOnly = false,
	AlignToCursorNormal = false,
	RequiresSpotterToFire = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
		
	Upgrades =
	{
		["missilestructure2inv"] =
		{
			Enabled = true,
			SaveName = "missilestructure2inv",
			MetalCost = 200,
			EnergyCost = 2000,
		},
	},
	
	CompatibleGroupTypes =
	{
		"missile",
		"missileinv",
		"missilestructure",
		"missilestructureinv",
		"missile2",
		"missile2inv",
		"missilestructure2",
		"missilestructure2inv",
	},
})

table.insert(Weapons, IndexOfWeapon("missilestructureinv") + 1,
{	
	SaveName = "missilestructure2inv",
	FileName = path.. "/weapons/missilelauncherstructure_inverted.lua",
	Enabled = false,
	Inverted = true,
	Icon = "hud-missile-icon",
	GroupButton = "hud-group-missile",
	Detail = "hud-detail-missile",
	AnimationScript = "weapons/missilelauncher_anim.lua",
	Prerequisite = "upgrade",
	BuildTimeComplete = 65.0,
	ScrapPeriod = 8,
	MetalCost = 1200,
	EnergyCost = 4500,
	MetalRepairCost = 80,
	EnergyRepairCost = 1250,
	MetalReclaimMin = 0.25,
	MetalReclaimMax = 0.5,
	EnergyReclaimMin = 0.1,
	EnergyReclaimMax = 0.5,
	SpotterFactor = 0.0, -- can't spot for itself (need a sniper with LOS)
	MaxSpotterAssistance = 0,
	MaxUpAngle = 360,
	BuildOnGroundOnly = false,
	AlignToCursorNormal = false,
	RequiresSpotterToFire = true,
	SelectEffect = "ui/hud/weapons/ui_weapons",
	
	CompatibleGroupTypes =
	{
		"missile",
		"missileinv",
		"missilestructure",
		"missilestructureinv",
		"missile2",
		"missile2inv",
		"missilestructure2",
		"missilestructure2inv",
	},
})



table.insert(Sprites, ButtonSprite("hud-turretCannon-icon", "HUD/HUD-turretcannon", nil, ButtonSpriteBottom, nil, nil, path))
table.insert(Sprites, DetailSprite("hud-detail-turretcannon", "turretcannon", path))
table.insert(Weapons, IndexOfWeapon("cannon") + 1, {
    SaveName = "turretCannon",
    FileName = path .. "/weapons/turretCannon.lua",
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    Prerequisite = "munitions",
    BuildTimeComplete = 150.0,
    ScrapPeriod = 8,
    MetalCost = 1500,
    EnergyCost = 9000,
    MetalRepairCost = 500,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = StandardMaxUpAngle,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannon2"] =
		{
			Enabled = true,
			SaveName = "turretCannon2",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
})
table.insert(Weapons, IndexOfWeapon("turretCannon") + 1, {
    SaveName = "turretCannon2",
    FileName = path .. "/weapons/turretCannon2.lua",
    Enabled = false,
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    BuildTimeComplete = 0.0,
    ScrapPeriod = 8,
    MetalCost = 0,
    EnergyCost = 0,
    MetalRepairCost = 150,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannonFlip1"] =
		{
			Enabled = true,
			SaveName = "turretCannonFlip1",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
    
})
table.insert(Weapons, IndexOfWeapon("turretCannon") + 1, {
    SaveName = "turretCannon3",
    FileName = path .. "/weapons/turretCannon3.lua",
    Enabled = false,
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    BuildTimeComplete = 0.0,
    ScrapPeriod = 8,
    MetalCost = 0,
    EnergyCost = 0,
    MetalRepairCost = 150,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannon2"] =
		{
			Enabled = true,
			SaveName = "turretCannon2",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
})
table.insert(Weapons, IndexOfWeapon("turretCannon") + 1, {
    SaveName = "turretCannonFlip1",
    FileName = path .. "/weapons/turretCannonFlip1.lua",
    Enabled = false,
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    BuildTimeComplete = 0.0,
    ScrapPeriod = 8,
    MetalCost = 0,
    EnergyCost = 0,
    MetalRepairCost = 150,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannonFlip2"] =
		{
			Enabled = false,
			SaveName = "turretCannonFlip2",
			MetalCost = 0,
			EnergyCost = 0,
		},
        ["turretCannon3"] =
		{
			Enabled = false,
			SaveName = "turretCannon3",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
})
table.insert(Weapons, IndexOfWeapon("turretCannon") + 1, {
    SaveName = "turretCannonFlip2",
    FileName = path .. "/weapons/turretCannonFlip2.lua",
    Enabled = false,
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    BuildTimeComplete = 0.0,
    ScrapPeriod = 8,
    MetalCost = 0,
    EnergyCost = 0,
    MetalRepairCost = 150,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannonFlip3"] =
		{
			Enabled = false,
			SaveName = "turretCannonFlip3",
			MetalCost = 0,
			EnergyCost = 0,
		},
        ["turretCannonFlip1"] =
		{
			Enabled = false,
			SaveName = "turretCannonFlip1",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
})
table.insert(Weapons, IndexOfWeapon("turretCannon") + 1, {
    SaveName = "turretCannonFlip3",
    FileName = path .. "/weapons/turretCannonFlip3.lua",
    Enabled = false,
    Icon = "hud-turretCannon-icon",
    GroupButton = "hud-group-cannon",
    Detail = "hud-detail-turretcannon",
    BuildTimeComplete = 0.0,
    ScrapPeriod = 8,
    MetalCost = 0,
    EnergyCost = 0,
    MetalRepairCost = 150,
    EnergyRepairCost = 3000,
    MaxSpotterAssistance = 1, -- major benefit from spotters
    MaxUpAngle = 90,
    BuildOnGroundOnly = false,
    SelectEffect = "ui/hud/weapons/ui_weapons",
    Upgrades =
	{
		["turretCannonFlip2"] =
		{
			Enabled = false,
			SaveName = "turretCannonFlip2",
			MetalCost = 0,
			EnergyCost = 0,
		},
	},
})
LCAddComp({"turretCannon", "turretCannon2", "turretCannon3", "turretCannonFlip1", "turretCannonFlip2", "turretCannonFlip3"})