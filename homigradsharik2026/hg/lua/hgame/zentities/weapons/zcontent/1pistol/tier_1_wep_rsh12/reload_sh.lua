local SWEP = oop.Get("wep_rsh12")
if not SWEP then return end

if CLIENT then
    function SWEP:Reload()
        if self:GetChamberCount() > self:Clip1() then
            if self:Clip1() == 0 then
                self:DoAction({name = "rev_unload"})
            else
                self:DoAction({name = "rev_uninsert"})
            end
        elseif self:Clip1() < self:GetMaxClip1() then
            local ammo = self:FindAmmoInInv()
            if not ammo then return end

            self:DoAction({name = "rev_insert"})
        end
    end
end

SWEP:ConstructAnimationAction("rev_uninsert",
function(self,cmd)
    if self:GetChamberCount() <= 0 then return false,"ChamberCount <= 0" end

    self:PlayAnimationAction({name = "rev_uninsert"})
    if SERVER then self:SyncAnimation() end

    return true
end,
function(self,anim)
    anim.Start = function(object)
        local self = object.parent

        object.chamberCount = self:GetChamberCount()
        object.clip = self:Clip1()
        object.chamberCountStart = object.chamberCount - object.clip
        object.pass = 1 / object.chamberCountStart
        object.index = object.index + (self:GetAnimIterationMax() - (object.chamberCount - object.clip + 1)) * self:GetAnimIterationMax()

        object.delayStart = object.delay
    end

    anim.SetupModelPost = function(object,wm)
        local self = object.parent

        local start = self.wmData.chamberBodygroup
        local chamberCount = object.chamberCount + 1

        for i = 1,self:GetAnimIterationMax() do
            wm:SetBodygroup(start + (i - 1),chamberCount >= i and 1 or 0)
        end
    end

    anim.Step = function(object,cycle)
        local self = object.parent
        
        object.delay = object.delayStart + 0.5 * object.chamberCountStart

        local periodTime = 1 / object.chamberCountStart

        if cycle >= object.pass then
            object.pass = object.pass + periodTime

            self:AnimationEmitSound(object.soundUnInsert)

            if object.isLocal then
                self:RejectShell(object.chamberCount)

                object.chamberCount = math.max(object.chamberCount - 1,0)
                
                self:SetChamberCount(math.max(object.chamberCount,0))
                self:SetClip1(math.min(object.clip,object.chamberCount))
            end
        end
    end

    anim.SendLoad = function(object) end

    anim.Load = function(object,cmd)
        if not object.isLocal then return end

        local self = object.parent

        local stop = cmd and cmd.sendLoad == 1 

        if CLIENT then
            stop = not LocalPlayer():KeyDown(IN_RELOAD)
            
            self:SendAction({name = "rev_uninsert",sendLoad = stop and 1 or 0})
        end

        self:SetChamberCount(object.clip)
        self:SetClip1(object.clip)

        if stop then
            self:PlayAnimation({name = "drum_end"})
            self.animIteration = 1
        end
    end
end)

SWEP:ConstructAnimationAction("rev_unload",
function(self,cmd)
    if self:GetChamberCount() <= 0 then return false,"ChamberCount <= 0" end

    self:PlayAnimationAction({name = "rev_unload",dropCount = self:GetChamberCount()})
    if SERVER then self:SyncAnimation() end

    return true
end,
function(self,anim)
    anim.Start = function(object)
        object.parent.animIteration = 1
    end

    anim.Load = function(object)
        if not object.isLocal then return end

        local self = object.parent
        
        for i = 1,object.dropCount do
            self:RejectShell(i)
        end

        if SERVER then self:UnLoadAmmo(self:Clip1()) end

        self:SetChamberCount(0)
        self:SetClip1(0)
    end

    anim.Stop = function(object)
        local self = object.parent

        if SERVER then
            self:UnLoadAmmo(self:Clip1())
        end
    end
end)

SWEP:ConstructAnimationAction("rev_insert",
function(self,cmd)
    -- Server-side: handle stop signal (player released R)
    if SERVER and cmd.sendLoad == 1 then
        self:PlayAnimation({name = "drum_end"})
        self.animIteration = 1
        self:SyncAnimation()
        return true
    end

    local clip = cmd.clip or self:Clip1()
    if clip == self:GetMaxClip1() then return false,"Clip1 == GetMaxClip1" end
    
    local ammo = self:FindAmmoInInv()
    if not ammo then return false,"no ammo" end

    self:ResetAnimation("action")

    clip = cmd.clip or self:Clip1()
    self:PlayAnimationAction({name = "rev_insert",ammo = ammo,clip = clip})

    -- Server-side: consume ammo immediately when starting a new insert cycle
    if SERVER then
        inventoryGame.TakeResource(ammo,1)
        local max = self:GetMaxClip1()
        local newClip = math.min(clip + 1,max)
        self:SetClip1(newClip)
        self:SetChamberCount(newClip)
        self:SetAmmoClass(ammo.data.ammoName)
    end

    if SERVER then self:SyncAnimation() end

    return true
end,
function(self,anim)
    anim.Start = function(object)
        object.index = object.index + (object.clip or object.parent:Clip1())
    end

    anim.SetupModelPost = function(object,wm)
        local self = object.parent

        local start = self.wmData.chamberBodygroup
        local chamberCount = (object.clip or self:Clip1()) + 1
        
        for i = 1,self:GetAnimIterationMax() do
            wm:SetBodygroup(start + (i - 1),chamberCount >= i and 1 or 0)
        end
    end

    anim.Step = function(object,cycle)
        if not object.isLocal then return end
        
        if not IsValid(object.ammo) then object.parent:ResetAnimation() object.parent:SyncAnimation() return end
    end

    anim.Load = function(object,cmd)
        if not object.isLocal then return end

        local self = object.parent
        local max = self:GetMaxClip1()

        if SERVER then
            -- Server-side: ammo is consumed in the Start function (funcAction).
            -- The base_load Think calls Load at cycle 1.0 — on the server this
            -- is a no-op because DoNetLoad handles the server path instead.
            return
        end

        -- Client-side only from here
        local stop = cmd and cmd.sendLoad == 1

        inventoryGame.TakeResource(object.ammo,1)

        object.clip = math.min(object.clip + 1,max)

        self:SetClip1(object.clip)
        self:SetChamberCount(object.clip)
        self:SetAmmoClass(object.ammo.data.ammoName)

        stop = ClientLastAttackDownTime + 0.3 > RealTime()

        self:SendAction({name = "rev_insert",sendLoad = stop and 1 or 0})

        if object.clip < max then
            if stop then
                object:DrumEnd()
            else
                self:DoAction({name = "rev_insert",clip = object.clip})
            end
        else
            object:DrumEnd()
        end
    end

    anim.SendLoad = function(object) end

    anim.DrumEnd = function(object)
        local self = object.parent
        
        self:PlayAnimation({name = "drum_end"})
        self.animIteration = 1
    end
end)