local SWEP = oop.Get("hg_wep")
if not SWEP then return end

util.AddNetworkString("hg_wep_shoot")

local function GetBulletInfo(ammoName)
    local ammo = ammoGame.config[ammoName]
    return ammo and ammo.bulletInfo or {}
end

function SWEP:CreateBullet(data)
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end

    local ammoName = data.ammoBulletName or self:GetAmmoClass()
    local bulletInfo = GetBulletInfo(ammoName)
    local count = math.max(bulletInfo.Count or 1,1)
    local pos = data.pos or owner:GetShootPos()
    local ang = data.ang or owner:EyeAngles()
    local spray = bulletInfo.Spray or 0
    local spread = math.tan(math.rad(spray))

    owner:FireBullets({
        Attacker = owner,
        Inflictor = self,
        Src = pos,
        Dir = ang:Forward(),
        Num = count,
        Spread = Vector(spread,spread,0),
        Damage = (bulletInfo.Damage or self.Primary.Damage or 10) / count,
        Force = bulletInfo.Force or bulletInfo.MulPhysicsForce or 1,
        Tracer = 0,
        AmmoType = self.Primary.Ammo or "none",
        Distance = bulletInfo.Distance or 56756
    })

    net.Start("hg_wep_shoot")
    net.WriteString(self:GetClass())
    net.WriteString(ammoName or "")
    net.WriteDouble(data.renderTime or UnPredictedCurTime())
    net.WriteString(tostring(spray))
    net.WriteBool(data.silence == true)
    net.WriteInt(self:EntIndex(),14)
    net.WriteVector(pos)
    net.WriteAngle(ang)
    net.SendPVS(pos)

    return true
end
