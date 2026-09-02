local SWEP = oop.Reg("wep_gnade_molotov","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = L("wep_gnade_molotov")

SWEP:TableLink("wmFastData",{model = "models/w_models/weapons/w_eq_molotov.mdl",vec = Vector(5,-2,0)})

SWEP.Granade = "ent_gnade_molotov"

SWEP.dwsPos = Vector(0,-45,-1.8)
SWEP.dwiSelectPos = Vector(0,-160,-1.8)

SWEP.EnableTransformModel = true

SWEP.wmVector = Vector(5,3,0)
SWEP.wmAngle = Angle(0,180,0)

SWEP.InvCount = 1

if SERVER then
    SWEP.ArmSound = "ambient/fire/mtov_flame2.wav"

    function SWEP:OnInit()
        self:AddCallback("PhysicsCollide",function(ent,data) self:PhysicsCollide(data) end)
    end

	function SWEP:PhysicsCollide(data)
		if data.DeltaTime > 0.2 and data.Speed > 40 then
			if self:IsOnFire() then
                self:Detonate()
            elseif data.Speed > 300 then
                sound.Emit(nil,"physics/glass/glass_largesheet_break" .. math.random(1,3) .. ".wav",75,1,200,self:GetPos())

                self:Remove()
            end
		else
			if data.DeltaTime > 0.2 and data.Speed > 30 then
				sound.Emit(self:EntIndex(),"physics/glass/glass_bottle_impact_hard" .. math.random(1,3) .. ".wav",75,1,100,self:GetPos())
			end
		end
	end

    function SWEP:ArmPost()
		self:Ignite(15)
    end

    function SWEP:Detonate()
		local vec = self:GetPos()

		local Boom = ents.Create("env_explosion")
		Boom:SetPos(vec)
		Boom:SetKeyValue("imagnitude","50")
		Boom:SetOwner(self.attacker)
		Boom:Spawn()
		Boom:Fire("explode",0)

		local att = self.attacker

		for i = 1,5 do
			local FireVec = (VectorRand() * 0.3 + Vector(0,0,0.3)):GetNormalized()
			FireVec.z = FireVec.z / 2

			local Flame = ents.Create("ent_jack_gmod_eznapalm")
			Flame:SetPos(vec + Vector(0,0,30))
			Flame:SetAngles(FireVec:Angle())
			Flame.Attacker = self.att
			
			Flame.SpeedMul = 0.2
			Flame.Creator = att
			Flame.HighVisuals = true
			Flame:Spawn()
			Flame:Activate()
		end
		
		self:Remove()

        sound.Emit(nil,"ambient/fire/mtov_flame2.wav",90,1,100,self:GetPos())
		sound.Emit(nil,"physics/glass/glass_largesheet_break" .. math.random(1,3) .. ".wav",90,1,200,self:GetPos())
	end
end