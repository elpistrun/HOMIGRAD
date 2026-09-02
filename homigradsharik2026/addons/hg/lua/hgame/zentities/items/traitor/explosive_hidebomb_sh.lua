local EXP = oop.Reg("explosive_hidebomb","explosive_base",true)
if not EXP then return INCLUDE_BREAK end

EXP.Damage = 100
EXP.RadiusDamage = 250//наносит урон от взрывной волны
EXP.RadiusStun = 600//оглушает взрывной волной

EXP.FragCount = false

// Client

EXP.ParticleGround = "pcf_jack_groundsplode_small"
EXP.ParticleAir = "100lb_air"

EXP.Earrape = true
EXP.ExplosiveWave = false
EXP.ExplosivePunch = true

EXP.Power = 1

function EXP:EmitSound()
    sound.Emit(self.parent,"snd_jack_fragsplodefar.ogg",140,1,100,self.pos)

    for i = 1,4 do
        sound.Emit(self.parent,"snd_jack_fragsplodeclose.ogg",90,1,200,self.pos)
    end
end

if SERVER then
    function EXP:ExplosiveLogicPost()
        local ent = self.parent
        if not IsValid(ent) then return end
        
        if util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 3 or util.GetSurfaceIndex(ent:GetBoneSurfaceProp(0)) == 66 then
            Explosive_FragSplosion(ent,self.pos,1024,50,3500,self.attacker)
        end
    end

    function EXP:Attack(dmgTab)
        local target = dmgTab.target
        if not IsValid(target) then return end

        local k = math.max(self.RadiusStun - target:GetPos():Distance(self.pos),0) / self.RadiusStun
        
        k = math.min(k * 35,1)

        dmgTab.isExplosive = true
        dmgTab.pain = 50 * k
        dmgTab.impulse = 10 * k

        target:TakeDamageTab(dmgTab)
    end
end