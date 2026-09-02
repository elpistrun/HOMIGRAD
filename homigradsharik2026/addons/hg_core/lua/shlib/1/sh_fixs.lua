if SERVER then
    event.Add("Player Think 1","HasGodMode Rep",function(ply) ply:SetNWBool("HasGodMode",ply:HasGodMode()) end)
    hook.Add("UpdateAnimation","RemoveNoclipLayer",function(ply,event,data) ply:RemoveGesture(ACT_GMOD_NOCLIP_LAYER) end)
else
    FindMetaTable("Player").HasGodMode = function(self) return self:GetNWBool("HasGodMode") end
end