local Page = scoreboard:Page_Reg(1000)

Page.pages[5] = Page.pages[5] or {}
local PageSub = Page.pages[5]
PageSub.Name = "interface"

local warningIcon = Material("homigrad/vgui/icons/warning.png")

function PageSub.Open(frame)
    local panel,options = frame:AddOptions(L("interface_multiply_screen"),"Плохо поддерживается","hg_screensize",warningIcon)
    panel.info = {description = "Умножает размеры интерфейса на это число, шрифт и некоторые ui элементы станут меньше\nЭта опция не везде поддерживается и может плохо работать."}
    options:Add(0.5)
    options:Add(0.75)
    options:Add(1)
    options:Add(1.25)
    options:Add(1.5)
    options:Add(1.75)
    options:Add(2)

    function options:OnSet(id,value)
        RunConsoleCommand("hg_screensize",tostring(value))
    end

    local value = GetConVar("hg_screensize"):GetFloat()

    for i,item in pairs(options.list) do
        if value <= tonumber(item.text) then
            options:Set(i,true)
            break
        end
    end

    local text = "Нужна для разработки или для оценки состояние игры (наскок сильно нагружена игра)"
    
    local panel,swith = frame:AddSwitch("Graph",nil,"hg_graph")
    panel.info = {
        description = text
    }
end

if Initialize then scoreboard:Open() end