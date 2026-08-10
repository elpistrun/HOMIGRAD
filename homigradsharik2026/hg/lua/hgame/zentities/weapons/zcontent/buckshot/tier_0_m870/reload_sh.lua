local SWEP = oop.Get("wep_m870")
if not SWEP then return end

if CLIENT then
    function SWEP:Reload()
        if LocalPlayer():KeyDown(IN_WALK) or self.chamber == false or (self:Clip1() > 0 and self.chamber != true) then
            self:DoAction({name = "chamber"})
        elseif self:Clip1() < (self:GetMaxClip1() + (self.chamber and 1 or 0)) then
            self:DoAction({name = "pomp_insert",clip = self:Clip1()})
        end
    end
end

SWEP:ConstructAnimationAction("pomp_insert",
function(self,cmd)
    local ammo = self:FindAmmoInInv()
    if not ammo then return end
    
    self:PlayAnimationAction({name = "pomp_insert",ammo = ammo})

    return true
end,function(self,anim)
    anim.Start = function(object)
        if object.isLocal then
            local chamberPump = object.parent.chamberPump

            for i = object.parent:Clip1() + 1,#chamberPump do
                chamberPump[i] = nil
            end
        end
    end

    anim.Step = function(object,cycle)
        if not object.isLocal then return end
        
        if not IsValid(object.ammo) then object.parent:ResetAnimation() return end
    end

    anim.SetupModelPost = function(object,wm)
        wm:SetBodygroup(object.parent.wmData.chamberBodygroup,1)
    end

    anim.Load = function(object)
        if not object.isLocal then return end

        inventoryGame.TakeResource(object.ammo,1)

        local self = object.parent
        local max = self:GetMaxClip1() + (self.chamber and 1 or 0)

        self.chamberPump[#self.chamberPump+1] = object.ammo.data.ammoName
        self:SetClip1(#self.chamberPump)
    end

    anim.Skip = function(object)
        if not object.isLocal then return end

        local self = object.parent

        if CLIENT and #self.chamberPump < (self:GetMaxClip1() + (self.chamber and 1 or 0)) and ClientLastAttackDownTime + 0.1 < RealTime() then self:DoAction({name = "pomp_insert"}) end
    end
end)