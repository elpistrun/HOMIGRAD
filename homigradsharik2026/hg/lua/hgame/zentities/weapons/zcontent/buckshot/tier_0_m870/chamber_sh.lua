local SWEP = oop.Get("wep_m870")
if not SWEP then return end

SWEP:Event_Add("Init","Clip",function(self)
    self.chamberPump = {}

    local ammoName = ammoGame.callibreIndex[self.Primary.AmmoCalibre]

    for i = 1,self:GetMaxClip1() do
        self.chamberPump[i] = ammoName
    end

    self:SetClip1(#self.chamberPump)

    self.chamber = true

    self:SetGateDelay(false)
end,-10)

function SWEP:FireBullet(data,pos,ang)
	--debugoverlayNet.BoxAngles(pos,-Vector(1,1,1),Vector(1,1,1),ang,1,Color(255,255,255,0))

    data.ammoBulletName = self.chamberPump[1]

	if GetConVar("hg_inv_ammo"):GetBool() then
		self:CreateBullet(data,pos,ang)

        return
	end

	self.chamber = false

    table.remove(self.chamberPump,1)

	self:CreateBullet(data,pos,ang)

    self:SetClip1(#self.chamberPump)

	if #self.chamberPump == 0 then
		if self.Primary.ChamberAuto then
			self.chamber = nil
			if self.Primary.ChamberAutoReload then self:SetGateDelay(true) end
		end
	elseif self.Primary.ChamberAuto then
		self.chamber = true
	end
end

if CLIENT then
    function SWEP:SetChamberFromServer(data)
        local i = tonumber(string.sub(data,1,2))
        local ammoName = string.sub(data,3,#data)

        if i == 0 then
            for k in pairs(self.chamberPump) do self.chamberPump[k] = nil end

            if ammoName == "2" then self.chamber = true end
            if ammoName == "1" then self.chamber = false end
            if ammoName == "0" then self.chamber = nil end
        else
            self.chamberPump[i] = ammoName
        end
    end
end

function SWEP:GetAmmoClass() return self.chamberPump[1] end