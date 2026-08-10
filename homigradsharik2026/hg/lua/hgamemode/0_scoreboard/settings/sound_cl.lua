local Page = scoreboard:Page_Reg(1000)

Page.pages[4] = Page.pages[4] or {}
local PageSub = Page.pages[4]
PageSub.Name = "sound"

local warningIcon = Material("homigrad/vgui/icons/warning.png")

function PageSub.Open(frame,panelInfo)
    --[[local panel,slider = frame:AddSlider(L("settings_volume_shootgun"),nil,"hg_shoot_volume")
    slider.round = 100
    panel.info = {description = ""}]]--

    local panel,slider = frame:AddSlider(L("settings_radio_volume"),nil,"hg_radio_volume")
    slider.round = 100
    panel.info = {description = "Множитель громкости игроков, которые говорят по рации"}

    --[[local panel,slider = frame:AddSlider(L("settings_dwr_volume"),nil,"cl_dwr_volume")
    slider.round = 100
    panel.info = {description = ""}]]--
end