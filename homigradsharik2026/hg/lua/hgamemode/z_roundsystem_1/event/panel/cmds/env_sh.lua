if SERVER then
    Event_ChatCommand_Add("fog",function(plyCaller,dis,r,g,b)
        if not r or not g or not b then
            SetGlobalVar("Fog Event Dis",0)

            return true,"fog remove"
        else
            SetGlobalVar("Fog Event Dis",dis)
            SetGlobalVar("Fog Event R",r)
            SetGlobalVar("Fog Event G",g)
            SetGlobalVar("Fog Event B",b)
        end

        return true,"fog " .. dis .. " " .. r .. " " .. g .. " " .. b
    end):SetArgs({"number","number","number","number"}):SetCategoryAndDesc("general")
else
    event.Add("SetupFog","Event",function()
        local dis = GetGlobalVar("Fog Event Dis")

        if not dis or dis <= 0 then return end

        local content = util.PointContents(EyePos())
        if
            ((bit.band(content,CONTENTS_SOLID) == CONTENTS_SOLID) and
            (LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP and not LocalPlayer():InVehicle()))
        then
            return
        end
        
        return dis,Color(GetGlobalVar("Fog Event R"),GetGlobalVar("Fog Event G"),GetGlobalVar("Fog Event B"))
    end,-1)

end