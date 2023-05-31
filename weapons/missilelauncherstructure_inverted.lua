dofile("weapons/missilelauncher.lua")
Sprites = nil
WeaponMass = WeaponMass * 3.5
Root.Pivot = { 0, -0.11 }
Root.Angle = 180
MinFireAngle = MinFireAngle + 180
MaxFireAngle = MaxFireAngle + 180
SelectionOffset[2] = SelectionOffset[2]*-1
RecessionBox.Offset[2] = RecessionBox.Offset[2]*-1
IncendiaryRadius = 20
IncendiaryRadiusHeated = 50
StructureSplashDamage = 200
StructureSplashDamageMaxRadius = 150
DeviceSplashDamage = 150
DeviceSplashDamageMaxRadius = 400
DeviceSplashDamageDelay = 0.2
Recoil = 600000