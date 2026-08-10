local SWEP = oop.Get("wep_mr43")
if not SWEP then return end

SWEP:Event_Add("Init","Clip",function(self)
    local ammoName = ammoGame.callibreIndex[self.Primary.AmmoCalibre]

    self.chamber1 = ammoName
    self.chamber2 = ammoName

    self:SetClip1(2)
end)

function SWEP:FireBullet(data,pos,ang)
	--debugoverlayNet.BoxAngles(pos,-Vector(1,1,1),Vector(1,1,1),ang,1,Color(255,255,255,0))

    local inv_ammo = GetConVar("hg_inv_ammo"):GetBool()

    if self.chamber1 then
        data.ammoBulletName = self.chamber1
        if not inv_ammo then self.chamber1 = false end
    elseif self.chamber2 then
        data.ammoBulletName = self.chamber2
        if not inv_ammo then self.chamber2 = false end
    end

	self:CreateBullet(data,pos,ang)

    if not inv_ammo then self:SetClip1((self.chamber1 and 1 or 0) + (self.chamber2 and 1 or 0)) end
end

if CLIENT then
    function SWEP:SetChamberFromServer(data)
        local i = tonumber(string.sub(data,1,1))
        local value = string.sub(data,2,#data)

        if value == "false" then value = false end
        if value == "nil" then value = nil end

        if i == 1 then
            self.chamber1 = value
        elseif i == 2 then
            self.chamber2 = value
        end
    end
end

function SWEP:CanPrimaryAttackChamber() return self.chamber1 or self.chamber2 end