dofile(path .. "/weapons/turretLaser2.lua")



Sprites = {}

Root =
{
	Name = "turretLaser",
	Angle = 0,
	Pivot = { 0.0, -0.445 },
	PivotOffset = { 0, 0 },
	Sprite = "turretLaser-flip3",
	UserData = 0,
	ChildrenBehind = {

        {
            Name = "Basket",
            Pivot = {0.0, 0.515},
            Sprite = "turretLaser-basket"
        },
    }
}