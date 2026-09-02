local Emitter = FindMetaTable("CLuaEmitter")


local Part = FindMetaTable("CLuaParticle")

function Part:IsValid() return self:GetLifeTime() <= self:GetDieTime() end
function Part:Remove() self:SetDieTime(0) end

cvars.CreateDevOption("hg_dev_dontparticles","0",function(value)
    hg_dev_dontparticles = tonumber(value or 0) > 0
end,0,1)