local SWEP = oop.Get("hg_wep")
if not SWEP then return end

local random,Rand = math.random,math.Rand

local hg_best_weaponlight
cvars.CreateOption("hg_best_weaponlight","-1",function(value) hg_best_weaponlight = tonumber(value) end,-2,1)

function SWEP:ShootLight(pos,dir,color)
	local t = math.min(1 / 24,self.Primary.Delay,0.7)

	if hg_best_weaponlight >= 0 then
		local dlight = DynamicLight(self:EntIndex())
		dlight.pos = pos
		dlight.r = color.r
		dlight.g = color.g
		dlight.b = color.b
		dlight.brightness = 2
        
		dlight.decay = 1000 / (t * 10)
		dlight.size = Rand(100,200)
	end
end