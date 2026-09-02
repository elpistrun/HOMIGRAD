local Page = scoreboard:Page_Reg(1000)

Page.pages[3] = Page.pages[3] or {}
local PageSub = Page.pages[3]
PageSub.Name = "Эффекты"

cvars.CreateOption("hg_color_modify","0",function(value)
    if tonumber(value or 0) > 0 then
        local pp_cc_tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0.0175,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1.2,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }

        hook.Add("RenderScreenspaceEffects","Color Modify",function()
            DrawColorModify(pp_cc_tab)
        end)
    else
        hook.Remove("RenderScreenspaceEffects","Color Modify")
    end
end)

cvars.CreateOption("hg_smaa2","0",function(value)
    if tonumber(value or 0) > 0 then
        RunConsoleCommand("r_smaa","1")
        RunConsoleCommand("r_smaa_corner_rounding","25")
        RunConsoleCommand("r_smaa_max_search_steps","32")
        RunConsoleCommand("r_smaa_max_search_steps_diag","16")
        RunConsoleCommand("r_smaa_threshold","0")
    else
        RunConsoleCommand("r_smaa","0")
    end
end)

local warningIcon = Material("homigrad/vgui/icons/warning.png")

function PageSub.Open(frame,panelInfo)
    local panel = frame:AddCategory("PostProcess")

    local panel,swith = frame:AddSwitch("Яркие цвета",nil,"hg_color_modify")
    panel.info = {
        description = "Делает картинку ярче, убирает серый тон"
    }

    local panel,swith = frame:AddSwitch("Размытие в движении",nil,"mat_motion_blur_enabled")
    panel.info = {
        description = ""
    }

    local panel,swith = frame:AddSwitch("SMAA",nil,"hg_smaa2")
    panel.info = {
        description = "Сглаживает лесенки и любые резки края пикселей",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/anti_aliasing_smaa.png","smooth mips") or
            Material("homigrad/settings/anti_aliasing_disable.png","smooth mips")
        end
    }
end