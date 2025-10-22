dofile(path .. "/weapons/turretCannon.lua")

DestroyEffect = ""
ConstructEffect = ""
CompleteEffect = ""
HurtEffect = ""
Projectile = ""

SelectionWidth = 0
SelectionHeight = 0
SelectionOffset = { -0, -0 }
RecessionBox =
{
	Size = { 0, 0 },
	Offset = { 0, 0 },
}
DeviceSplashDamage = 0
DeviceSplashDamageMaxRadius = 0
DeviceSplashDamageDelay = 0
IncendiaryRadius = 0
IncendiaryRadiusHeated = 0
StructureSplashDamage = 0
StructureSplashDamageMaxRadius = 0

Sprites = {}
RemoveUserData(Root)



