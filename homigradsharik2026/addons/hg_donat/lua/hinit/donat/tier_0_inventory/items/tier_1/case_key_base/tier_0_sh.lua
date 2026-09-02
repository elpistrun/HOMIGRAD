local ITEM = inventoryManager:ItemReg("case_key","case",true)
if not ITEM then return INCLUDE_BREAK end

local empty = {}

function ITEM:GetPrintName()
    return (self:GetCaseInfo() or empty).keyName or "Missing Key"
end

function ITEM:CanReceive() return false end

if SERVER then return end

function ITEM:DrawObject(w,h,panel,desc)
    local caseInfo = self:GetCaseInfo()
    if not caseInfo then return end

    local mdl = self:GetCSM(caseInfo.modelKey)

    if caseInfo.subMaterial0 then
        mdl:SetSubMaterial(0,caseInfo.subMaterial0)
    end
    
    self:OpenScene(w,h,panel,20)
        mdl:SetPos(caseInfo.modelKeyVec)
        mdl:SetAngles(caseInfo.modelKeyAng)
        mdl:DrawModel()
    self:CloseScene(w,h,panel)
end