local ENT = oop.Get("fake_ragdoll")
if not ENT then return end

function ENT:OnInit()
	self:DrawShadow(false)

    self:Event_Call("Init")
end

function ENT:GetPlayer() return self:GetController() end

function ENT:IsSpeaking()
    local ply = self:GetPlayer()
    if IsValid(ply) then return ply:IsSpeaking() end
end

function ENT:VoiceVolume()
    local ply = self:GetPlayer()
    if IsValid(ply) then return ply:VoiceVolume() end
end

local vec = Vector(1,1,1)

function ENT:GetPlayerColor() return self:GetPVSVar("PlayerColor",vec) end

function ENT:Draw(flags)
    DeterminateLODFirst(self)
    
    if not self.renderLOD2_5 then return end
    if not self.renderLOD2 then self:DrawModel() return end

    local owner = self:GetController()
    
    if owner == LocalPlayer() then
        -- Render ragdoll for local player when in fake death
        RenderLocalPlayer(self,nil,owner,flags)
    else
        RenderPlayer(self,nil,owner,flags)
    end
    
    -- Render weapon on ragdoll's right hand
    self:DrawWeaponOnHand(owner,flags)
end

-- Weapon offset from hand bone
local wepHandOffset = {
    pos = Vector(2, 0, 0),
    ang = Angle(0, 0, -90)
}

function ENT:DrawWeaponOnHand(owner,flags)
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if not owner:Alive() then return end
    
    local wep = owner:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() == "weapon_hands" then return end
    
    -- Get the world model
    local wm = wep.wm
    if not IsValid(wm) then return end
    
    -- Get right hand bone
    local handBone = self:LookupBone("ValveBiped.Bip01_R_Hand")
    if not handBone then return end
    
    local boneMatrix = self:GetBoneMatrix(handBone)
    if not boneMatrix then return end
    
    -- Calculate weapon position/angle from hand bone
    local handPos = boneMatrix:GetTranslation()
    local handAng = boneMatrix:GetAngles()
    
    local wepPos = handPos + wepHandOffset.pos:Rotate(handAng)
    local wepAng = handAng + wepHandOffset.ang
    
    -- Set weapon render position
    wm:SetPos(wepPos)
    wm:SetAngles(wepAng)
    
    -- Draw the weapon model
    wm:DrawModel()
end

local function setup(ent)
    if ragdollManager.entities[ent] then return end
    ragdollManager.entities[ent] = true

    ent:CallOnRemove("RagdollEntities",function()
        ragdollManager.entities[ent] = nil
        ent:OnRemove()
    end)

    for k,v in pairs(oop.listClass["fake_ragdoll"][1]) do ent[k] = v end

    ent:Initialize()
    ent.RenderOverride = function(self,flags) ent:Draw(flags) end
end

event.Add("EntityCreate","RagdollFake",function(ent)
    if ent:GetClass() != "prop_ragdoll" then return end

    ent:ProxyPVSVar("IsFakeRagdoll",function(_,_,value)
        if not value then return end

        setup(ent)
    end)
end)