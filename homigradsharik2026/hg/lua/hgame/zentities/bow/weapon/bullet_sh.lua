local SWEP = oop.Get("wep_bow")
if not SWEP then return end

local recipientFilter = SERVER and RecipientFilter()

function SWEP:FireBullet(data)
	local pos,ang = data.pos,data.ang

	local bullet = customEnts.Create("bullet_entity")
	bullet.pos = pos:Clone()

	local bulletInfo = ammoGame.config["arrow"].bulletInfo
	bullet:SetDir(Vector(bulletInfo.Speed,0,0):Rotate(ang))

	bullet.filterTrace = {[self:GetOwner():GetDummy()] = true}
	
	bullet.attacker = self:GetOwner()
	bullet.weapon = self

    bullet.startTime = data.startTime
    bullet.lagCompresion = data

    bullet.dmgType = DMG_BULLET

	bullet:SetClassBullet("arrow")
	bullet:SetWaitCustomEntityTag(self:EntIndex() .. data.renderTime)
	
    bullet.CallbackDamage = function(self,dmgTab)
        dmgTab.fakeDown = true
        dmgTab.pain = 30
    end

	bullet:Spawn()
end

local vecScale = Vector(0.8,0.8,0.8)

local ammo = ammoGame.Reg({
    name = "arrow",
    printname = "Стрела",
    desc = "Стрела",

    Material = "models/hmcd_ammobox_38",
    Scale = 1,

    icon = "homigrad/ammo/arrow.png",

    bulletInfo = {
        LifeTime = 20,

        Speed = 90,
        Mass = 150,
        Hardness = 3,

        Diameter = 10,
        BalisticCooperator = 8,

        Damage = 55,
		
		modelPath = "models/fc3bowa.mdl",

        MulPhysicsForce = 10,

        MultiplySpeed = 1,

        FlySound = {
            list = {"homigrad/wind/woosh0.wav"},
            volume = 1,
            level = 60,
            pitch = 110
        }
    },

    InvSoundUse = {"weapons/shells/9mm_shell_concrete1.wav","weapons/shells/9mm_shell_concrete2.wav","weapons/shells/9mm_shell_concrete3.wav"},

    AmmoCalibre = "arrow",

	DeterminateUseMin = -Vector(24,1,1),
	DeterminateUseMax = Vector(12,1,1)
})

if CLIENT then
	local vecScale = Vector(1,1,1):Mul(0.8)
	
	ammo.OnNetworkerCreate = function(cuent,sNetworker)
		sNetworker:EnableMatrixScale(vecScale)
	end

	ammo.OnClientSideNetworkerCreate = function(cuent,cNetworker)
		cNetworker:EnableMatrixScale(vecScale)
	end
end

ammoGame.callibreIndex["arrow"] = "arrow"