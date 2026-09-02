local SWEP = oop.Get("wep_mr43_sawed")
if not SWEP then return end

if CLIENT then
    function SWEP:Reload()
        if self:IsReloading() then return end

        if self.chamber1 == false and self.chamber2 == false then
            self:DoAction({name = "mr43_reload2"})
        elseif self.chamber1 == false then
            self:DoAction({name = "mr43_reload1"})
        end
    end
end

SWEP:ConstructAnimationAction("mr43_reload2",
function(self,cmd)
    if self.chamber1 != false or self.chamber2 != false then return false,"chamber" end

    local ammo = self:ActionCMD_GetAmmoClient(cmd)
    if not ammo then
        local ammoName = ammoGame.callibreIndex[self.Primary.AmmoCalibre]
        self:PlayAnimation({name = "mr43_reload2",className = "base",sandboxFallback = true})
        if SERVER then self:SyncAnimation() end
        timer.Simple(2.0, function()
            if not IsValid(self) then return end
            self.chamber1 = ammoName
            self.chamber2 = ammoName
            self:SetClip1(2)
        end)
        return true
    end

    self:PlayAnimationAction({name = "mr43_reload2",ammo = ammo})
    if SERVER then self:SyncAnimation() end

    return true
end,
function(self,anim)
    anim.SetupModelPost = function(object,wm)
        wm:SetBodygroup(4,1)
        wm:SetBodygroup(5,2)
    end

    anim.Step = function(object,cycle)
        local self = object.parent

        if object.isLocal then
            if object.ammo and not IsValid(object.ammo) then self:ResetAnimation() end

            if object.rejectShell1 and not object.m_rejectshell1 and cycle >= object.rejectShell1 then
                object.m_rejectshell1 = true

                self:RejectShell(1)
            end

            if object.rejectShell2 and not object.m_rejectshell2 and cycle >= object.rejectShell2 then
                object.m_rejectshell2 = true

                self:RejectShell(2)
            end
        end
    end

    anim.Load = function(object)
        if not object.isLocal then return end
        
        local self = object.parent

        if SERVER then
            inventoryGame.TakeResource(object.ammo,2)
        end

        self.chamber1 = object.ammo.data.ammoName
        self.chamber2 = object.ammo.data.ammoName

        self:SetClip1(2)
    end
end)

SWEP:ConstructAnimationAction("mr43_reload1",
function(self,cmd)
    if self.chamber1 != false then return false,"chamber" end

    local ammo = self:ActionCMD_GetAmmoClient(cmd)
    if not ammo then
        local ammoName = ammoGame.callibreIndex[self.Primary.AmmoCalibre]
        self:PlayAnimation({name = "mr43_reload1",className = "base",sandboxFallback = true})
        if SERVER then self:SyncAnimation() end
        timer.Simple(1.5, function()
            if not IsValid(self) then return end
            self.chamber1 = ammoName
            self:SetClip1((self.chamber1 and 1 or 0) + (self.chamber2 and 1 or 0))
        end)
        return true
    end

    self:PlayAnimationAction({name = "mr43_reload1",ammo = ammo})
    if SERVER then self:SyncAnimation() end

    return true
end,
function(self,anim)
    anim.SetupModelPost = function(object,wm)
        wm:SetBodygroup(4,1)
        wm:SetBodygroup(5,2)
    end

    anim.Step = function(object,cycle)
        local self = object.parent

        if object.isLocal then
            if object.ammo and not IsValid(object.ammo) then self:ResetAnimation() end

            if object.rejectShell1 and not object.m_rejectshell1 and cycle >= object.rejectShell1 then
                object.m_rejectshell1 = true

                self:RejectShell(1)
            end
        end
    end

    anim.Load = function(object)
        if not object.isLocal then return end
        
        local self = object.parent

        if SERVER then
            inventoryGame.TakeResource(object.ammo,1)
        end

        self.chamber1 = object.ammo.data.ammoName

        self:SetClip1(2)
    end
end)
