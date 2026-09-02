local ENT = oop.Reg("fake_ragdoll",{"lib_event","lib_duplicate"},true)
if not ENT then return INCLUDE_BREAK end

local PLAYER = FindMetaTable("Player")

PLAYER.InFake = function(self)
	return self:GetDummy() ~= self or self:GetNWBool("fake")
end

ragdollManager = ragdollManager or {}
ragdollManager.entities = ragdollManager.entities or {}

function ENT:Initialize()
	ragdollManager.entities[self] = true

	self:OnInit()
end

function ENT:OnRemove()
	ragdollManager.entities[self] = nil
end

ENT:Event_Add("Construct","RagdollEntities",function(class)
	if not ragdollManager.entities then return end

	for ent in pairs(ragdollManager.entities) do
		if not IsValid(ent) then ragdollManager.entities[ent] = nil continue end

		util.tableLink(ent,class[1])
	end
end)

function ENT:Eye()
	local owner = self:GetController()
	if not IsValid(owner) then return self:GetPos(),self:GetAngles() end//UFFFF

	return owner:Eye()
end