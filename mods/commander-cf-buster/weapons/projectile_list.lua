function LCuranium(savename, maxage)
    local uraniumcannon = DeepCopy(FindProjectile("uraniumcannon"))
    uraniumcannon.SaveName = ("uranium"..savename)
    uraniumcannon.MaxAge = (maxage/DU_speed)
    table.insert(Projectiles, uraniumcannon)
    table.insert(ProjectilesToUranium, savename)
    ProjectileEffects[savename] = 
    {
        Trail = "mods/commander-cf-buster/effects/uranium_fly.lua",
        Impact =
        {
            ["shield"] = "mods/commander-cf-buster/effects/impact_uranium_shield.lua",
        },
    }
end
LCuranium("turretCannon", 1000)