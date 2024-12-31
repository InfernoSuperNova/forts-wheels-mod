
dofile("scripts/interpolate.lua")

FireEnd = 10
AngleTable =
{
	{ 0,		0,	 },
	{ 2,		-90, },
	{ 8,		-90, },
	{ FireEnd,	0,   },
}

Angle = 0

function Update(delta)
	if FireTimer then
		FireTimer = FireTimer + delta
		
		Angle = InterpolateTable(AngleTable, FireTimer, 2)
		SetNodeAngle("HeadDummy", Angle)
		if FireTimer > FireEnd then
			FireTimer = nil
		end
	end
end

function OnWeaponFired()
	--FireTimer = 0
end


