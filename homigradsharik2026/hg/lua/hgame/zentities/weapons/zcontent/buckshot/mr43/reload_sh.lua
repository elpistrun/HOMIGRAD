local SWEP = oop.Get("wep_mr43")
if not SWEP then return end

if CLIENT then
    function SWEP:Reload()
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
    if not ammo then return false,"No ammo" end

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
            if not IsValid(object.ammo) then self:ResetAnimation() end

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
    if not ammo then return false,"No ammo" end

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
            if not IsValid(object.ammo) then self:ResetAnimation() end

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