local PLY = oop.Reg("player_fake","custom_entity",true)
if not PLY then return INCLUDE_BREAK end

local empty = {}

PLY:Event_Add("Create","csmParentTag",function(self)
    self.csmParentTag = tostring(self)

    self.renderLOD0 = true
    self.renderLOD1 = true
    self.renderLOD2 = true
    self.renderLOD2_5 = true
    self.renderLOD3 = true
    self.renderLOD4 = true

    self.modelName = "models/player/Group01/female_01.mdl"

    fakeObject.Parse(empty,self,empty)
end)

function PLY:SetModel(modelName)
    self.modelName = modelName
    if IsValid(self.mdl) then self.mdl:SetModel(modelName) end
end

function PLY:GetModel() return self.modelName end

function PLY:CreateModel()
    local mdl = CSM.CreateClientSideModel(self.modelName)
    self.mdl = mdl
    mdl.csmParentTag = tostring(self)
    mdl:SetNoDraw(true)

    mdl.renderLOD0 = true
    mdl.renderLOD1 = true
    mdl.renderLOD2 = true
    mdl.renderLOD2_5 = true
    mdl.renderLOD3 = true
    mdl.renderLOD4 = true

    mdl:CallOnRemove("player_fake",function()
        if not IsValid(self) or self.removed then return end

        self:CreateModel()
    end)

    self:Event_Call("Create Model",mdl)

    return mdl
end

function PLY:GetCSM()
    local mdl = self.mdl

    if not IsValid(mdl) then
        return self:CreateModel()
    else
        return mdl
    end
end

function PLY:Render()
    self:GetCSM()

    local mdl = self.mdl
    mdl:ResetSequence(mdl:LookupSequence("walk_all"))

    local link = self.link or self
    
    PlayerBones(mdl,"fake_player",link)
    RenderPlayer(mdl,"fake_player",link)
end

PLY:Event_Add("Remove","Model",function(self)
    if IsValid(self.mdl) then self.mdl:Remove() end
end)
