local ENT,CLASS = oop.Reg("base_nextbot","lib_event")
if not ENT then return end

CLASS.NonRegisterGMOD = true

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

ENT:Event_Add("Construct","register",function(class)
    local content = class[1]
    if content.NonRegisterGMOD or class[2].NonRegisterGMOD then return end

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

ENT:Event_Add("Construct","NextBot",function(class)
	local class = class[1]

    if not class.Category then return end
    
	list.Set("NPC",class.ClassName,{
		Name = class.PrintName,
		Class = class.ClassName,
		Category = class.Category,
		AdminOnly = class.AdminOnly,
		IconOverride = class.IconOverride
	})
end)