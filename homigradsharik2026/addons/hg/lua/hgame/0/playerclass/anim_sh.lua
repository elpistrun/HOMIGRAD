hook.Add("CalcMainActivity","PlayerClass",function(ply,velocity)
	local tab = ply.GetPlayerClass and ply:GetPlayerClass()
	if not tab then return end

	local func = tab.CalcMainActivity 
	if not func then return end

	local ideal,override = func(ply,velocity)

	if ideal then return ideal,override end
end)