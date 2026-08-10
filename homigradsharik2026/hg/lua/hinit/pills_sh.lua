if not pk_pills then return true end

adminPanel.successRegistry("pills_access",nil,"rights")

if SERVER then
    RunConsoleCommand("pk_pill_admin_restrict","0")

    concommand.Add("pk_pill_apply", function(ply, cmd, args, str)
        if event.Call("Can Pills",ply) == false then return end

        pk_pills.apply(ply, args[1], "user", tonumber(args[2]))
    end)

    event.Add("Fake","Pils",function(ply)
        if IsValid(pk_pills.getMappedEnt(ply)) then return false end
    end)

    event.Add("Can Pills","Main",function(ply)
        return ply:HasSuccess("pills_access") 
    end,10)
else

    --hook.Add("CalcView", "momo_calcview", function(ply, pos, ang, fov, nearZ, farZ)

    event.Add("PreCalcView","Pills",function(ply,view)
        local ent = pk_pills.getMappedEnt(LocalPlayer())
    
        if IsValid(ent) and ply:GetViewEntity() == ply then
            return hook.Call("CalcView","momo_calcview",ply,view.origin,view.angles,view.fov,view.nearZ,view.farZ)
        end
    end,-100)
end

hook.Remove("Think", "xdeshe_ctk")