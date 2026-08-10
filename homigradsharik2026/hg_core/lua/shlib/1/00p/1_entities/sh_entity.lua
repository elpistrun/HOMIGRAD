local ENT,CLASS = oop.Reg("base_entity",{"lib_event","lib_duplicate"})
if not ENT then return end

CLASS.NonRegisterGMOD = true

ENT.Base = "base_entity"
ENT.Type = "anim"

function ENT:Draw() self:DrawModel() end

function ENT:SpawnFunction(ply,tr,name)
    if not tr.Hit then return end

    local ent = ents.Create(name)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16 + ent:OBBCenter())
    ent.spawned = true
    ent:Spawn()
    ent:Activate()

    ent:PhysWake()

    return ent
end

function ENT:OnTakeDamage(dmgInfo)
    self:TakePhysicsDamage(dmgInfo)
end

ENT:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class.NonRegisterGMOD then return end

    scripted_ents.Register(content,content.ClassName)

    timer.Simple(0,function()
        for i,ent in pairs(ents.FindByClass(class[1].ClassName)) do
            ent:Event_Call("Construct Object",class)
        end
    end)
end,10)

function ENT:SetupDataTables()
	self:Event_Call("SetupDataTables")
end

//

oop.FirstInheritEnts = oop.FirstInheritEnts or {}

function ENT:InheritFromScriptedEnt(class)
    local content = oop.FirstInheritEnts[class]

    if not content then
        content = scripted_ents.Get(class) or (oop.listClass[class] and oop.listClass[class][1])
        if not content then return false end
        
        oop.FirstInheritEnts[class] = content
    end

    local ClassName = self.ClassName
    util.tableLink(self,content)
    self.ClassName = ClassName

    return true,content
end