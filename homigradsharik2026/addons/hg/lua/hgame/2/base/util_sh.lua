local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

function SWEP:IsLocal() return IsValid(self) and (SERVER or self:GetOwner() == LocalPlayer()) end

hook.Add("DoAnimationEvent","Homigrad Weapons",function(ply,event,data)
    local wep = ply:GetActiveWeapon()

    if IsValid(wep) and wep.DoAnimationEvent then return wep:DoAnimationEvent(ply,event,data) end
end)

function SWEP:OwnerChanged()
    if WEAPONDROPNOW then return end

    self.deployed = nil
    self:Event_Call("OwnerChanged")
end

function SWEP:ShouldDropOnDie() return false end

function SWEP:OnDrop(owner,callType)
    if WEAPONDROPNOW then return end
    
    self:Event_Call("Drop",owner,callType)
end

SWEP:Event_Add("Drop","Off",function(self) self:Event_Call("Off") end,10)
SWEP:Event_Add("OwnerChanged","Off",function(self) self:Event_Call("Off") end,10)
SWEP:Event_Add("Remove","Off",function(self) self:Event_Call("Off") end,10)
SWEP:Event_Add("HolsterEnd","Off",function(self) self:Event_Call("Off","hold") end,10)

function SWEP:IsGhostWalk()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner.IsGhostWalk then return end

    return owner:IsGhostWalk()
end

function SWEP:GetSoundEntity()
    return IsValid(self:GetOwner()) and self:GetOwner() or self
end

if SERVER then
    function SWEP:EmitLocalSound(sndName,level,volume,pitch,pos)
        local src = self:GetSoundEntity()
        sound.EmitNET(src:EntIndex(),sndName,level,volume,pitch,pos or self:GetPos())
        if src == self then net.SendPAS(pos or self:GetPos()) else net.SendOmit(src) end
    end
else
    function SWEP:EmitLocalSound(sndName,level,volume,pitch,pos)
        if not self:IsLocal() then return end
        
        local src = self:GetSoundEntity()
        sound.Emit(src,sndName,level,volume,pitch,pos or self:GetPos())
    end
end

function SWEP:TableLink(key,table) util.tableLink(self[key],table) end

function SWEP:IsActive()
    local owner = self:GetOwner()

    return IsValid(owner) and (owner:GetActiveWeapon() == self or owner:GetActiveSecondaryWeapon() == self) or false
end

function SWEP:OwnerHasSecondaryWeapon()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    return IsValid(owner:GetActiveSecondaryWeapon())
end