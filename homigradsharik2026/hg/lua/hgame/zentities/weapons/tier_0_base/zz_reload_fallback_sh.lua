local SWEP = oop.Get("hg_wep")
if not SWEP then return end

-- Weapons spawned with sandbox/give do not have an inventory magazine to take
-- ammunition from. The inventory reload remains available when such ammo is
-- present; otherwise use a normal reserve-ammo-independent magazine reload.
local action = SWEP:CreateAction("reload_fallback")

function action.Start(self,cmd)
    local clipSize = self.Primary and tonumber(self.Primary.ClipSize) or 0
    if clipSize <= 0 then return false,"invalid clip size" end
    if self:Clip1() >= clipSize and self:GetMagazineItem() then return false,"magazine full" end

    self:SetCooldown("Reload",tonumber(self.ReloadTime) or 1.25)
    self:SetClip1(clipSize)
    self:SetGateDelay(false)
    self:SetChamber(true)

    if self.Primary.MagazineModel then
        self:SetMagazineItem({path = self.Primary.MagazineModel})
    end

    if ammoGame and ammoGame.callibreIndex then
        self:SetAmmoClass(ammoGame.callibreIndex[self.Primary.AmmoCalibre])
    end

    return true
end

if CLIENT then
    local inventoryReload = SWEP.Reload

    function SWEP:Reload()
        if self:IsCooldown("Reload") then return end

        local owner = self:GetOwner()
        local inventoryAvailable = IsValid(owner) and isfunction(owner.GetAllAutoItems)
        local ammo

        if inventoryAvailable and isfunction(self.FindAmmoInInv) then
            local ok,result = pcall(self.FindAmmoInInv,self)
            if ok then ammo = result end
        end

        if ammo and inventoryReload then
            return inventoryReload(self)
        end

        self:DoAction({name = "reload_fallback"})
    end
end
