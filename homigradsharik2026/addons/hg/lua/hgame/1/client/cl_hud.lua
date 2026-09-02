local hide = {
	["NetGraph"] = true,
	["CHudGMod"] = true
}

hook.Add("HUDShouldDraw","HideHUD",function(name)
	if not hide[name] then return false end
end)
