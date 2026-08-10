local SWEP = oop.Reg("wep_lib_camera","lib_event",true)
if not SWEP then return INCLUDE_BREAK end

SWEP:Event_Add("SetupDataTables","GetIsScoping",function(self)
    self:NetworkVar("Bool","IsScoping")
end)

function SWEP:IsScope()
    if not self:IsLocal() then return self:GetIsScoping() end

    local owner = self:GetOwner()

    return (owner.KeyDown and owner:KeyDown(IN_ATTACK2) and (owner:InFake() or owner:IsOnGround() or owner:InVehicle()) and self:CanFight("scope"))
end

if SERVER then
    SWEP:Event_Add("Think","self:SetIsScoping(self:IsScope())",function(self)
        self:SetIsScoping(self:IsScope())
    end)
end

SWEP.scopeInterp = 0.07

SWEP:Event_Add("Think","Scope",function(self)
    self.scopeLerp = LerpFT(self.scopeInterp,self.scopeLerp or 0,self:IsScope() and 1 or 0)

    if self.scopeLerp <= 0.001 then
        self.scopeLerp = 0
    elseif self.scopeLerp >= 0.999 then
        self.scopeLerp = 1
    end
end)