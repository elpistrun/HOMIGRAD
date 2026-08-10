event.Add("PlayerSwitchWeapon","fake",function(ply,old,new)
	if ply.Otrub then return false end
	if not ply:GetNWBool("Fake") then return end

	ply.ActiveWeapon = new

	if IsValid(new) and not new.SupportFake then
		return false
	end
end)