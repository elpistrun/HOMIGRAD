local ANM = animationEntity.Reg("base_load","base",true)
if not ANM then return INCLUDE_BREAK end

function ANM:OnCreate()
    if SERVER then self.endless = true end
end

function ANM:Think(cycle)
    if self.Step then self:Step(cycle) end
    
    if CLIENT and not self.m_load and cycle >= self:GetLoadCycle() then--ждём от клиента SendLoad
        if CLIENT and self.isLocal then self:SendLoad() end

        if self.Load then self:Load() end

        self.m_load = true
    end

    if CLIENT and not self.m_skip and cycle >= self:GetSkipCycle() then--наврятле
        if self.Skip then self:Skip() end

        self.m_skip = true
    end
end

function ANM:GetLoadCycle() return self.load or 1 end
function ANM:GetSkipCycle() return self.skip or 1 end

function ANM:IsLoad() return self.m_load end
function ANM:IsSkip() return self.m_skip end

function ANM:GetEndCycle() return math.max(self:GetLoadCycle(),self:GetSkipCycle()) end

function ANM:IsEnd()
    local cycle = self:GetCycle()
    if cycle >= 1 then return true end

    if SERVER then
        return self:IsLoad() and self:GetCycle() >= self:GetEndCycle() or false
    else
        return self:IsLoad() and self:IsSkip() and self:GetCycle() >= self:GetEndCycle() or false--если skip и load равны, то без этого будет повторятся одна и таже анимация при зажатии R (актуально на клиенте мб)
    end
end