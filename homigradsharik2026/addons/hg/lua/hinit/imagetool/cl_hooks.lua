--[[
        © AsterionStaff 2022.
        This script was created from the developers of the AsterionTeam.
        You can get more information from one of the links below:
            Site - https://asterion.games
            Discord - https://discord.gg/CtfS8r5W3M
        
        developer(s):
            Selenter - https://steamcommunity.com/id/selenter

        ——— Chop your own wood and it will warm you twice.

        //https://music.youtube.com/watch?v=IACPtnopv3o&list=OLAK5uy_lYn6eB45YWaSUVdEyFniDjBYm-bCYuknE
        ЖУКИ НАХОДИТСЯ НА ВАШЕМ АНДРОИДЕ
]]--


-- Создаем конвар с настройкой прорисовки

-- Менюшка с настройкой
hook.Add( "PopulateToolMenu", "ImageTool.Menu", function()
    local l = "imagetool_"

    spawnmenu.AddToolMenuOption("Options", "Image Tool", "imagetoolsettings", "Image Tool Settings", nil, nil, function(CPanel)
        CPanel:ClearControls()

        CPanel:AddControl("Header",{
            Description = "In this menu you can change the settings for the ImageTool."
        })

        CPanel:AddControl("Slider", {
            Label = "Draw distance:",
            Command = "imagetool_dist",
            Min = 0,
            Max = 10000
        })

        local SettingsReset = vgui.Create("DButton")
        SettingsReset:SetText("Return to default settings")
        SettingsReset.DoClick = function()
            RunConsoleCommand(l .. "dist", ImageTool.dist:GetDefault())
        end
        CPanel:AddPanel(SettingsReset)

        local HistoryReset = vgui.Create("DButton")
        HistoryReset:SetText("Clear the history")
        HistoryReset.DoClick = function()
            ImageTool:SaveHistory({})

            timer.Simple(0.5, function()
                RunConsoleCommand("spawnmenu_reload")
            end)

            LocalPlayer():ChatPrint(ImageTool.prefix .. " You have successfully cleared your history!")
        end
        CPanel:AddPanel(HistoryReset)

        local ImageReset = vgui.Create("DButton")
        ImageReset:SetText("Delete all pictures on the map")
        ImageReset.DoClick = function()
            RunConsoleCommand(l .. "delete_all")
        end
        CPanel:AddPanel(ImageReset)
    end)
end)

hook.Add("PostDrawTranslucentRenderables", "ImageTool.PostDrawTranslucentRenderables", function()
    ImageTool:DrawImageTool() -- Тул-Ган отрисовка
end)