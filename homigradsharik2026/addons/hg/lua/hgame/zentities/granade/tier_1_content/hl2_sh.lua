local SWEP = oop.Reg("wep_gnade_hl2","wep_gnade_base")
if not SWEP then return end

SWEP.PrintName = L("wep_gnade_hl2")

SWEP:TableLink("wmFastData",{model = "models/weapons/w_grenade.mdl",vec = Vector(4,-2,3.5)})

SWEP.Granade = "ent_gnade_hl2"

SWEP.dwsPos = Vector(0,-30,-4.5)
SWEP.dwiSelectPos = Vector(0,-120,-4.5)

SWEP.EnableTransformModel = true

SWEP.TimeDetonate = 4

SWEP.NeedArmThink = SERVER

if SERVER then
    function SWEP:ArmThink()
        self.nextpip = self.nextpip or CurTime()

		if self.nextpip + math.max(1 * (math.max(self.TimeStart + self.TimeDetonate - CurTime(),0) / self.TimeDetonate),0.1) <= CurTime() then
            self.nextpip = CurTime()

			sound.Emit(self:EntIndex(),"weapons/grenade/tick1.wav",75,1,100,self:GetPos())
		end
    end
else
	local GlowSprite = Material("particle/fire")
    local red = Color(255,0,0,255)

	function SWEP:Render(wm)
        wm:DrawModel()

        if self.GetNWBool and self:GetNWBool("Arm") then
            render.SetMaterial(GlowSprite)
            render.DrawSprite(wm:GetPos():Add(wm:GetUp():Mul(10)),12 + math.Rand(-1,1),12 + math.Rand(-1,1),red)
        end
	end
end

SWEP.ExplosiveClass = "explosive_hl2"