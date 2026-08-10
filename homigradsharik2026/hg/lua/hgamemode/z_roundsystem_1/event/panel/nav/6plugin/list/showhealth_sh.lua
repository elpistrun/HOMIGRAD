local Plugin = EventPlugin_Reg("hud","base")
if not Plugin then return end

Plugin.PrintName = "HUD Controller"

function Plugin:Sync(data)
    if SERVER then
        data.showhealth = self.showhealth
        data.disable_post_proccess = self.disable_post_proccess
    else
        self.showhealth = data.showhealth
        self.disable_post_proccess = data.disable_post_proccess
    end
end

if SERVER then
    Plugin:AddCMD("showhealth",function(self,ply,args)
        self.showhealth = (tonumber(args[1] or 0) or 0) > 0

        return true,tostring(value)
    end,true)

    Plugin:AddCMD("disable_post_proccess",function(self,ply,args)
        self.disable_post_proccess = (tonumber(args[1] or 0) or 0) > 0

        return true,tostring(value)
    end,true)
else
    Plugin.HookPlug = {
        ["Should Draw Screenspace"] = "ShouldDrawScreenspace",
        ["HUDPaint"] = "HUDPaint"
    }

    function Plugin:ShouldDrawScreenspace()
        if self.disable_post_proccess then return false end
    end

    function Plugin:HUDPaint()
        if not self.showhealth then return end

        local w,h = ScrW(),ScrH()

        local health = LocalPlayer():Health()
        
        if health > 0 then
            draw.SimpleText(health,"HS.25",w * 0.05,h - w * 0.05)
        end
    end

    function Plugin:Create(page)
        page:AddEditBool("showhealth")
        page:AddEditBool("disable_post_proccess")
    end
    
end
