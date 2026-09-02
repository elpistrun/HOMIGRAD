AddCSLuaFile()
ENT.Type = "anim"
function ENT:Initialize() if SERVER then self:Remove() end end
function ENT:SetupDataTables() end