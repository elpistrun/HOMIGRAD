local Level = oop.Get("level_construct")
if not Level then return end

if not SERVER then return end

-- Construct mode: sandbox build mode
-- Players have god mode, physgun, and toolgun

function Level:StartServer()
    -- Give all players god mode and tools
    for _, ply in ipairs(player.GetAll()) do
        if ply.init and ply:Team() ~= 1002 then
            ply:GodEnable()
            ply:Give("weapon_physgun")
            ply:Give("gmod_tool")
        end
    end
end

function Level:EndServer()
    -- Remove god mode when round ends
    for _, ply in ipairs(player.GetAll()) do
        ply:GodDisable()
    end
end

-- Prevent damage in construct mode
hook.Add("EntityTakeDamage", "HG Construct NoDamage", function(target, dmginfo)
    if roundActiveName ~= "construct" and roundActiveName ~= "level_construct" then return end
    if target:IsPlayer() then
        dmginfo:SetDamage(0)
        return true
    end
end)

-- Respawn props on cleanup
hook.Add("PlayerSpawn", "HG Construct Spawn", function(ply)
    if roundActiveName ~= "construct" and roundActiveName ~= "level_construct" then return end
    timer.Simple(0, function()
        if IsValid(ply) then
            ply:GodEnable()
            ply:Give("weapon_physgun")
            ply:Give("gmod_tool")
        end
    end)
end)
