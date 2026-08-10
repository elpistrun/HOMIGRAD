concommand.Add("hg_getentity",function()
	local ent = LocalPlayer():GetEyeTrace().Entity
	print(ent)
	if not IsValid(ent) then return end
	print(ent:GetModel())
	print(ent:GetClass())
end)

concommand.Add("hg_getswep",function()
	local ent = LocalPlayer():GetActiveWeapon()
	print(ent)
	if not IsValid(ent) then return end
	print(ent:GetModel())
	print(ent:GetClass())
end)

concommand.Add("hg_getsurfaceprops",function()
    local tr = {
        start = EyePos(),
        endpos = EyePos() - Vector(0,0,1000),
        filter = LocalPlayer()
    }

    PrintTable(TraceLine(tr))
end)