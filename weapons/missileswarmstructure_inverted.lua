dofile("weapons/missileswarm.lua")
Sprites = nil
WeaponMass = WeaponMass * 3
Root.Pivot = { 0, -0.11 }
Root.Angle = 180
MinFireAngle = MinFireAngle + 180
MaxFireAngle = MaxFireAngle + 180
SelectionOffset[2] = SelectionOffset[2]*-1
RecessionBox.Offset[2] = RecessionBox.Offset[2]*-1
IncendiaryRadius = 50
IncendiaryRadiusHeated = 60
StructureSplashDamage = 70
StructureSplashDamageMaxRadius = 170
Recoil = 60000