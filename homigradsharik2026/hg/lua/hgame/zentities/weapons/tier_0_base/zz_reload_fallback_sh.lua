local SWEP = oop.Get("hg_wep")
if not SWEP then return end

-- Weapons spawned with sandbox/give do not have an inventory magazine to take
-- ammunition from. The inventory reload remains available when such ammo is
-- present; otherwise use a normal reserve-ammo-independent magazine reload.
local action = SWEP:CreateAction("reload_fallback")

function action.Start(self,cmd)
    local clipSize = self.Primary and tonumber(self.Primary.ClipSize) or 0
    if clipSize <= 0 then return false,"invalid clip size" end

    local hasMagazine = self:GetMagazineItem() != nil
    local unloadName = self:IsGateDelay() and self.AnimationList.unload_magazine_empty and "unload_magazine_empty" or "unload_magazine"
    local loadName = self:IsGateDelay() and self.AnimationList.load_magazine_chamber and "load_magazine_chamber" or "load_magazine"
    local unloadAnimation = self.AnimationList[unloadName]
    local loadAnimation = self.AnimationList[loadName]
    local unloadDelay = unloadAnimation and tonumber(unloadAnimation.delay) or 0
    local loadDelay = loadAnimation and tonumber(loadAnimation.delay) or tonumber(self.ReloadTime) or 1.25

    self.reloadFallbackToken = (self.reloadFallbackToken or 0) + 1
    local token = self.reloadFallbackToken
    local hadChamber = self.chamber == true and self:Clip1() > 0

    local function PlayReloadAnimation(name,animation)
        if not animation then return end
        -- Explicit false callbacks prevent util.tableLink from importing the
        -- inventory animation's Start/Load/Stop handlers. Those handlers need
        -- object.model/object.ammo, which sandbox fallback intentionally lacks.
        local sequenceObject = self:PlayAnimation({
            name = name,
            className = "base",
            reloadFallback = true,
            visualOnly = true
        })

        -- The sandbox fallback has no inventory ammo object, so the normal
        -- LoadMagazine.Start callback is intentionally disabled. Create its
        -- hand-held magazine model explicitly for the insertion animation.
        if CLIENT and string.StartWith(name,"load_magazine") and
            self.Primary.MagazineModel and IsValid(self.wm) then
            if IsValid(self.reloadFallbackMagazineModel) then
                CSM.Delete(self.reloadFallbackMagazineModel)
            end

            local mdl = self:InitWorldModelMagazine(
                self.wm,
                "reloadFallbackLoad",
                true,
                self.Primary.MagazineModel
            )
            self.reloadFallbackMagazineModel = mdl
            sequenceObject.magazineModel = mdl
        end

        if SERVER then self:SyncAnimation() end
    end

    if hasMagazine then
        -- First press: remove the magazine and stop. A second press is required
        -- to insert a replacement.
        self:SetCooldown("Reload",math.max(unloadDelay,0.1))
        PlayReloadAnimation(unloadName,unloadAnimation)

        timer.Simple(unloadDelay,function()
            if not IsValid(self) or self.reloadFallbackToken != token then return end

            self:SetMagazineItem()
            self:SetClip1(hadChamber and 1 or 0)
            self:ResetAnimation("reload_fallback_unload_end")
            if SERVER then self:SyncAnimation() end
        end)
    else
        -- Second press: insert and fill the new magazine.
        self:SetCooldown("Reload",math.max(loadDelay,0.1))
        PlayReloadAnimation(loadName,loadAnimation)

        timer.Simple(loadDelay,function()
            if not IsValid(self) or self.reloadFallbackToken != token then return end

            if CLIENT and IsValid(self.reloadFallbackMagazineModel) then
                CSM.Delete(self.reloadFallbackMagazineModel)
                self.reloadFallbackMagazineModel = nil
            end

            self:SetClip1(clipSize)
            self:SetGateDelay(false)
            self:SetChamber(true)

            if self.Primary.MagazineModel then
                self:SetMagazineItem({path = self.Primary.MagazineModel})
            end

            if ammoGame and ammoGame.callibreIndex then
                self:SetAmmoClass(ammoGame.callibreIndex[self.Primary.AmmoCalibre])
            end

            self:ResetAnimation("reload_fallback_load_end")
            if SERVER then self:SyncAnimation() end
        end)
    end

    return true
end

function action.Error(self)
    self.reloadFallbackToken = (self.reloadFallbackToken or 0) + 1
    if CLIENT and IsValid(self.reloadFallbackMagazineModel) then
        CSM.Delete(self.reloadFallbackMagazineModel)
        self.reloadFallbackMagazineModel = nil
    end
end

if CLIENT then
    local inventoryReload = SWEP.Reload

    function SWEP:Reload()
        if self:IsCooldown("Reload") then return end

        -- Manual-action weapons (bolt-action rifles, pump shotguns, etc.) must
        -- close/cycle the action before magazine toggle logic is considered.
        if self:GetMagazineItem() and self.chamber != true and self:Clip1() >= 1
            and self.AnimationList and self.AnimationList.chamber then
            return self:DoAction({name = "chamber"})
        end

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
