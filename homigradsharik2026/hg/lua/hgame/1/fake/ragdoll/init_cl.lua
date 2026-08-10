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
        if not self.passRender then return end--block engine

        RenderLocalPlayer(self,nil,owner,flags)
    else
        RenderPlayer(self,nil,owner,flags)
    end
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