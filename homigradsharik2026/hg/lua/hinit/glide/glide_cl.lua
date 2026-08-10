if not Glide then return INCLUDE_BREAK end

local Camera = Glide.Camera
Camera.isInFirstPerson = true
Camera.SetFirstPerson = function() end//fuck you!

hook.Add("Glide_OnLocalEnterVehicle","ZHomigrad",function(vehicle)
	hook.Remove("CalcView","GlideCamera_CalcView")

    LocalVehicle = vehicle
    
	event.Add("PreCalcView","GLide",function(ply,view)
        view.drawviewer = true

		if not Camera.isActive then return end
        
        local viewVehicle = Camera:CalcView()
        if not viewVehicle then return end
        
        view.ang = viewVehicle.angles

        local mat = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Head1"))
        view.vec = mat:GetTranslation()
        view.vec:Add(Vector(3,0,0):Rotate(mat:GetAngles()))
	end,-10)

    local Floor = math.floor

    local mat = Material("icon16/lock.png")

    hook.Add("HUDPaint","GLide Homigrad",function()
        if not IsValid(vehicle) or not vehicle:GetIsLocked() then return end

        local screenH = ScrH()

        local margin = Floor( screenH * 0.03 )
        local padding = Floor( screenH * 0.006 )
        local spacing = Floor( screenH * 0.004 )

        local w, h = Floor( screenH * 0.3 ), Floor( screenH * 0.035 )

        local y = screenH - margin * 2 - (h + spacing) * (#vehicle.seats)
        
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRectRotated(padding + h / 2,y,h,h,0)
    end)
end)

hook.Add("Glide_OnLocalExitVehicle","ZHomigrad",function()
    LocalVehicle = nil

    event.Remove("PreCalcView","GLide",-10)
    hook.Remove("HUDPaint","GLide Homigrad")
end)

--

hook.Remove("HUDDrawTargetID","Glide.HUDDrawTargetID")

hook.Remove("InitPostEntity","Glide.CreateSkidMarkMeshes")
hook.Remove("PreCleanupMap","Glide.RemoveSkidMarkMeshes")
hook.Remove("PostCleanupMap","Glide.RecreateSkidMarkMeshes")
hook.Remove("PreDrawTranslucentRenderables","Glide.RenderSkidMarks")

event.Add("Wind","Glide Motocycle",function(tbl)
    if not IsValid(LocalVehicle) then return end

    tbl[1] = LocalVehicle:GetVelocity():Length() / 1300
    tbl.dsp = LocalVehicle.Base != "base_glide_motorcycle" and 30 or 0
end)

event.Add("Spray","GLide",function(ply,spray)
    if not ply:InVehicle() then return end

    Camera.angles:Add(spray)
end)