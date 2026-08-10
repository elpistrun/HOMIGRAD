FOV = FOV or 100

cvars.CreateOption("hg_fov","90",function(value) FOV = tonumber(value or 90) or 90 end,100,140)

event.Add("PreCalcView","FOV",function(ply,view)
    view.fov = FOV
end,-1000)

local oldModel

event.Add("PreCalcView","EyeMode",function(ply,view)
	view.drawviewer = true
end,-20)

event.Add("PreCalcView","EyeMode",function(ply,view)
	if ply:Alive() and (ply:EyeMode() or GetViewEntity() != ply) then
		view.drawviewer = false
		view.drawviewmodel = true

		return view
	end

	if GetViewEntity() ~= ply then return view end
end,-23)