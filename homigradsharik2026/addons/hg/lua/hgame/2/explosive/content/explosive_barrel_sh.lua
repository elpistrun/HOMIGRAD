local EXP = oop.Reg("explosive_barrel","explosive_base")
if not EXP then return end

EXP.Power = 25
EXP.Damage = 125
EXP.RadiusDamage = 375//наносит урон от взрывной волны
EXP.RadiusStun = 900//оглушает взрывной волной

EXP.FragCount = 0
EXP.FragDamage = 45
EXP.FragMaxDistance = 1500

if CLIENT then return end

hook.Add("PropBreak","PropVengeance",function(att,prop)
    if prop:GetModel() != "models/props_c17/oildrum001_explosive.mdl" then return end

    local pos = prop:GetPos()

    timer.Simple(0,function()
        Explosive("explosive_barrel",pos,nil,att)
    end)
end)

function EXP:ExplosiveLogicPost()
    local pos = self.pos

    if event.Call("Should Create Napalm") == false then return end
    
    for i = 1,3 do
        local FireVec = (VectorRand() * 1 + Vector(0,0,1)):GetNormalized()
        FireVec.z = FireVec.z / 2

        local Flame = ents.Create("ent_jack_gmod_eznapalm")
        Flame:SetPos(pos + Vector(0,0,30))
        Flame:SetAngles(FireVec:Angle())
        Flame.Attacker = self.attacker
        
        Flame.SpeedMul = 0.2
        Flame.Creator = self.attacker
        Flame.HighVisuals = true
        Flame:Spawn()
        Flame:Activate()
    end
end