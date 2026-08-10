local text = "<font=HS.18>"
text = text .. "Guilt System является системой ANTI-RDM (Anti Random Death Match)\nОна нужна что-бы игроки просто так не убивали друг друга и играли по правилам игры.\n\n"

text = text .. "Что-бы такого не происходило не наносите урон союзникам первым!\nВы можете атаковать игрока если он:\n1. Нанёс вам урон (любой)\n2. Замахивается возле вас кулаками, ближнем оружием, стреляет но промахивается <b>ВОЗЛЕ ВАС</b>\n\n"

text = text .. "В первом случии если <b>Guilt System посчитала его виновным</b>, то все игроки в течении определёного времени могут безнаказано убить его.\n"
text = text .. "Во втором случии если игрок замахнулся на вас и промахнулся, только вы имеете право убить его и не получить наказания от Guilt System\n\n"

text = text .. "У вас есть счётчик guilt и пока он не заполнится, вы можете убивать игроков, то-есть у вас есть право на ошибку.\nВы можете убить примерно троих игроков, после чего получите бан."
text = text .. "Этот счётчик пополняется от любого нанесёного урона (если Guilt System решила что вы виноваты, если же например в Homicide вы убили трейтора, счётчик не пополнится)"

text = text .. "</font>"

guiltText = text

concommand.Add("hg_guilt_menu",function()
    guilt_menu_frame = VguiCreateBlackScreen("guilt_menu")
    guilt_menu_frame.OnMouse = nil

    text = markup.Parse(guiltText,ScrW()/2)

    function guilt_menu_frame:DrawContent(w,h)
        draw.SimpleText("ВЫ УМЕРЛИ ОТ GUILT SYSTEM","HS.45",w/2,h* 0.2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        text:Draw(w/2,h/2,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local start = RealTime() + 5

    local sumbit = oop.CreatePanel("v_button",guilt_menu_frame)
    sumbit:setSize(ScrW() / 3,70):setPos(ScrW() / 2- sumbit:W()/2,ScrH() * 0.9 - sumbit:H()/2)
    sumbit.text = "Хорошо я понял"
    sumbit.font = "HS.25"
    sumbit:SetupDrawStyle("white")

    sumbit:SetLock(true)

    function sumbit:Step()
        if start < RealTime() then sumbit:SetLock(false) end
    end

    function sumbit:OnClick()
        guilt_menu_frame:Remove()
    end

    function sumbit:DrawOver(w,h)
        if not self.isNotClickable then return end

        surface.SetDrawColor(0,0,0,160)
        surface.SetBG("lines_dense_d_l")
        draw.BG2(0,0,w,h)
    end
end)

event.Add("DSP","guilt_menu_frame",function(ply)
    if IsValid(guilt_menu_frame) then return 30 end
end)

plyVoice:Event_Add("Volume","hg_guilt_menu",function(ply,value)
    if IsValid(guilt_menu_frame) then return false end
end)

local gulitData

net.Receive("guilt_dev",function()
    gulitData = net.ReadTable()
end)

hook.Add("DrawOverlay","Guilt Dev",function()
    local lply = LocalPlayer()
    if not gulitData or not gulitData.enable then return end

    local text = ""
    text = text .. "guilt: " .. gulitData.guilt .. "\n"
    text = text .. "noGuiltProtect: " .. math.max(math.floor((gulitData.noGuiltProtect or 0) - CurTime()),0) .. "\n"

    for ply,time in pairs(gulitData.noGuiltProtectIndex) do
        time = math.max(math.floor(time - CurTime()),0)
        if time <= 0 then continue end

        text = text .. tostring(ply) .. time .. "\n"
    end

    text = markup.Parse(text)

    surface.SetDrawColor(0,0,0)
    surface.DrawRect(0,0,text:GetWidth(),text:GetHeight())
    text:Draw(0,0)
end)