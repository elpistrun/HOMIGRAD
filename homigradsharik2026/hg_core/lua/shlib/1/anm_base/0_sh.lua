local ANM = animationEntity.Reg("base",nil,true)
if not ANM then return INCLUDE_BREAK end

function ANM:GetCycle(type) return animationEntity.GetSequenceCycle(self,type) end

function ANM:GetMark(key)
    return animationEntity.GetAnimationMark(self,key,self[key],true,"animation")
end

function ANM:GetMarkEmit(key)
    return animationEntity.GetAnimationMark(self,key,self[key],false,"animation")
end

function ANM:GetEndCycle() return self.skip or 1 end

function ANM:IsEnd()
    return self:GetCycle() >= self:GetEndCycle()
end