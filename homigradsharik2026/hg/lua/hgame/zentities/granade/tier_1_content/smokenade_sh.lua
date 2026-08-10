local SWEP = oop.Reg("wep_gnade_smokenade","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = L("wep_gnade_smokenade")

SWEP:TableLink("wmFastData",{model = "models/jmod/explosives/grenades/firenade/incendiary_grenade.mdl",vec = Vector(4,-2,0)})

SWEP.Granade = "ent_gnade_smoke"

SWEP.dwsPos = Vector(0,-32,0.2)
SWEP.dwiSelectPos = Vector(0,-120,0.2)

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(5,2,0)
SWEP.wmAngle = Angle(0,180,0)

SWEP.TimeSmoking = 60

if SERVER then
    function SWEP:Detonate()
        sound.Emit(self:EntIndex(),"snd_jack_fragsplodeclose.ogg",90,1,150,self:GetPos())

        self:SetNWFloat("Start",CurTime())
    end
else
    SWEP.NeedArmThink = true
    
    function SWEP:OnInit()
        self.smokes = {}
    end

    function SWEP:AddSmoke(emitter)
		if #self.smokes > 100 then
			local part = self.smokes[1]
			if IsValid(part) then part:SetDieTime(1) end

			table.remove(self.smokes,1)
		end--epiiii

		local part = emitter:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],self:GetPos():Add(self:GetAngles():Up():Mul(1)))

		self.smokes[part] = true

		return part
    end

    function SWEP:ArmThink()
        if self:GetNWFloat("Start",0) == 0 then return end
        
        local anim_pos = (self:GetNWFloat("Start",0) + self.TimeSmoking - CurTime()) / self.TimeSmoking
		if anim_pos <= 0 then return end

		anim_pos = 1 - anim_pos
		anim_pos = math.Clamp(anim_pos * 2,0.75,1)

        local pos = self:GetPos()

		local emitter = self.emitter
        if not IsValid(emitter) then
            emitter = ParticleEmitter(pos)
            if not IsValid(emitter) then return end//WTF

            self.emitter = emitter
        end

        emitter:SetPos(pos)

        if (self.delaySmoke or 0) < RealTime() then
            self.delaySmoke = RealTime() + 0.1

            local part = self:AddSmoke(emitter)
            if part then
                part:SetDieTime(math.Rand(5,12))
        
                part:SetStartAlpha(200)
                part:SetEndAlpha(0)
                part:SetLighting(false)

                part:SetStartSize(75 * anim_pos)
                part:SetEndSize(700 * anim_pos)
        
                part:SetGravity(ParticleGravityWind + Vector(0,0,-15))
                part:SetVelocity(self:GetAngles():Up():Mul(75):Add(Vector(math.Rand(-55,55) * math.Rand(0.5,2),math.Rand(-157,157) * math.Rand(0.5,2),math.Rand(-5,5)):Rotate(self:GetAngles())))

                part:SetCollide(true)
                part:SetBounce(0.75)

                sound.Emit(self:EntIndex(),"snd_jack_sss.wav",75,0.1,math.random(90,110))
            end

            for part in pairs(self.smokes) do
                if not IsValid(part) then self.smokes[part] = nil continue end

                local dir = (pos - part:GetPos())
                local dis = dir:Length()
                dir:Normalize()
                dir:Mul(math.Rand(9,12) * (dis <= 200 and -1 or 1 ))
        
                part:SetVelocity(part:GetVelocity() + dir)
            end
        end
    end

    function SWEP:OnRemove() if IsValid(self.emitter) then self.emitter:Finish() end end
end