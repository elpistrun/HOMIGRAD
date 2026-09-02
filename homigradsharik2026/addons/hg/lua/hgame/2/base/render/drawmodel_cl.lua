local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

local empty = {}

function SWEP:InitWorldModelEx(tag,typeDraw,depth,data)
    depth = depth or false

    local isWorld = typeDraw == true
    
    if not tag and not self:WeaponIsReady() then return end--wtf

    data = data or self.wmData
    
    local mdlName = data.model or self:GetWorldModelName()

    local containerWeapon = CSM.GetContainer(self,self)
    self.csmContainer = containerWeapon

    tag = tag or ""

    local wm,isCreate = containerWeapon.tagIndex[tag],false

    if IsValid(wm) and (wm.depth ~= depth or wm:GetModel() ~= mdlName) then CSM.Delete(wm) wm = nil end

    if not IsValid(wm) then
        wm,isCreate = containerWeapon.GetByID(mdlName,tag or "",isWorld)
        if not wm then return end
    end
    
    wm.csmLocalTag = tag

    if isCreate then
        BonesManager_Init(wm)
        
        if isWorld then wm.isWorldModel = true end

        local container = CSM.GetContainer(wm,wm)
        wm.container = container

        wm.childrens = container.childrens

        wm.typeDraw = typeDraw
        wm.tag = tag
        wm.depth = depth

        if data.scale then
            wm:EnableMatrixScale(data.scale)
        end

        wm:SetNoDraw(typeDraw == "nodraw")
    end
    
    return wm,isCreate
end
function SWEP:InitWorldModel(tag,typeDraw,depth,data)
    local wm,IsCreate = self:InitWorldModelEx(tag,typeDraw,depth,data)

    if IsCreate then
        if not tag and self.ApplySequenceOnWorldModel then self:ApplySequenceOnWorldModel(wm) end
        if self.CreateWorldModelPost then self:CreateWorldModelPost(wm,tag,typeDraw,depth,mdlName) end

        wm:SetupBones()
        wm:InvalidateBoneCache()
    end

    return wm,IsCreate
end

local data = {}

function SWEP:InitWorldModelContent(tag)
    data.model = self.WorldModelContentLink_wmDropData and self.wmDropData.model or self:GetWorldModelName()
    
    local wm = self:InitWorldModel("content_icon_" .. (tag or ""),"nodraw",false,data)
    if not IsValid(wm) then return end
    
    wm:SetSequence(0)
    wm:SetCycle(1)

    self:SetupModel(wm)
    
    return wm
end

local vector_zero,angle_zero = Vector(),Angle()

function SWEP:CreateModelForWM(wm,model,tag,typeDraw)
    if not IsValid(wm) then return end
    if TypeID(model) != TYPE_STRING or model == "" then return end
    if not wm.container or not wm.container.GetByID then return end
    
    local mdl,isCreate = wm.container.GetByID(model,tag,typeDraw == true)
    if not IsValid(mdl) then return end
    mdl.renderTime = nil
    mdl.parent = wm
    mdl:SetParent(wm)

    mdl.localPos = vector_zero
    mdl.localAng = angle_zero

    mdl.isWorldModel = wm.isWorldModel

    if isCreate then
        if typeDraw == "nodraw" then mdl:SetNoDraw(true) end

        mdl:DrawShadow(false)
    end

    return mdl,isCreate
end

function SWEP:RemoveWM(wm)
    wm = wm or self.wm
    
    if IsValid(wm) then
        CSM.Delete(wm)

        if wm == self.wm then self.wm = nil end
    end
end

SWEP:Event_Add("Construct Object","RemoveWM",function(self)
    self:RemoveWM()
    self:RemoveWM(self.dropWM)
end)

SWEP:Event_Add("Off","WM",function(self) self:RemoveWM() end)--сразу убираем из рендера
