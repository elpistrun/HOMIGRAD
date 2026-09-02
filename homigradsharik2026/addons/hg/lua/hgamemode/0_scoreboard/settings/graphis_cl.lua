local Page = scoreboard:Page_Reg(1000)

Page.pages[2] = Page.pages[2] or {}
local PageSub = Page.pages[2]
PageSub.Name = "graphics"

local warningIcon = Material("homigrad/vgui/icons/warning.png")

function PageSub.Open(frame,panelInfo)
    --
    frame:AddCategory("Графика")
    --
    

    local panel,switch = frame:AddSwitch("gmod_mcore_test","Игра может вылетать","gmod_mcore_test",warningIcon)
    panel.info = {
        description = "Включает многопоточность, но из за этого игра может вылетать\nНе советую выключать, даёт очень высокий прирост производительности.",
    }

    local panel,options = frame:AddOptions("Качество текстур","При измненении игра зависает","mat_picmip",warningIcon)
    panel.info = {
        description = "Сжимает текстуры, возможно на более современых видеокартах нет смысла сжимать текстуры",
        getImage = function(value)
            local value = options.curretOption

            return
            value == 1 and Material("homigrad/settings/picmic_2.png","smooth mips") or
            value == 2 and Material("homigrad/settings/picmip_1.png","smooth mips") or 
            Material("homigrad/settings/picmip_0.png","smooth mips")
        end
    }

    options:Add("Самые низкие",function() RunConsoleCommand("mat_picmip","2") end)
    options:Add("Низкие",function() RunConsoleCommand("mat_picmip","1") end)
    options:Add("Среднее",function() RunConsoleCommand("mat_picmip","0") end)
    options:Add("Высокие",function() RunConsoleCommand("mat_picmip","-10") end)

    local value = GetConVar("mat_picmip"):GetInt()

    options:Set((value == 2 and 1) or (value == 1 and 2) or (value == 0 and 3) or 4,true)

    local panel,swith = frame:AddSwitch("Skybox",nil,"r_3dsky")
    panel.info = {
        description = "Отключает отображение Sky-Box\nПовышает фпс",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/skybox_enable.png","smooth mips") or
            Material("homigrad/settings/skybox_disable.png","smooth mips")
        end
    }

    local panel,swith = frame:AddSwitch("Пиксельные текстуры",nil,"mat_filtertextures")
    swith:SetInvert(true)
    panel.info = {
        description = "Убирает сглаживания между пикселями в любой текстуре",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/pixel_texture_disable.png","smooth mips") or
            Material("homigrad/settings/pixel_texture_enable.png","smooth mips")
        end
    }

    --
    frame:AddCategory("Освещение")
    --

    local panel,swith = frame:AddSwitch("Динамические тени от ламп","При измненении игра зависает","r_flashlightdepthtexture",warningIcon)
    panel.info = {
        description = "Отбрасывать ли динамические тени от ламп?",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/shadow_enable.png","smooth mips") or
            Material("homigrad/settings/shadow_disable.png","smooth mips")
        end
    }

    local panel,slider = frame:AddSlider("Качество динамических теней",nil,"r_flashlightdepthres",nil)
    slider:SetClamp(128,8096)
    slider.round = 1 / 128
    
    panel.info = {
        description = "Чем меньше значение, тем больше будет пикселей",
        getImage = function(value)
            value = tonumber(value)

            return
                value >= 4096 and Material("homigrad/settings/shadow_4096.png","smooth mips") or
                value >= 2048 and Material("homigrad/settings/shadow_2048.png","smooth mips") or
                value >= 1024 and Material("homigrad/settings/shadow_1024.png","smooth mips") or
                value >= 512 and Material("homigrad/settings/shadow_512.png","smooth mips") or
                value >= 256 and Material("homigrad/settings/shadow_256.png","smooth mips") or
                value >= 128 and Material("homigrad/settings/shadow_128.png","smooth mips") or
                Material("homigrad/settings/shadow_128.png","smooth mips")
        end
    }

    local panel,swith = frame:AddSwitch("Писельное освещение",nil,"mat_filterlightmaps")
    swith:SetInvert(true)
    panel.info = {
        description = "Убирает сглаживания в освещении (только от карты)",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/pixel_light_disable.png","smooth mips") or
            Material("homigrad/settings/pixel_light_enable.png","smooth mips")
        end
    }

    --
    frame:AddCategory("Игра")
    --

    local panel,swith = frame:AddSwitch("Отображение брони",nil,"hg_draw_armor")
    panel.info = {
        description = "Отключает отображение брони полностью\nНа дальних растояних автоматически отключяется",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/armor_enable.png","smooth mips") or
            Material("homigrad/settings/armor_disable.png","smooth mips")
        end
    }

    local panel,swith = frame:AddSwitch("Отображение заднего оружия",nil,"hg_draw_backweapons",nil)
    panel.info = {
        description = "Отключает отображение заднего оружия\nНа дальних растояних автоматически отключяется.",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/weapon_enable.png","smooth mips") or
            Material("homigrad/settings/weapon_disable.png","smooth mips")
        end
    }

    local panel,options = frame:AddOptions("Качество фонариков",nil,"hg_best_flashlight")
    panel.info = {
        description = "Определяет тип отображения фонариков у игроков",
        getImage = function()
            local value = options.curretOption
            return
            value == 1 and Material("homigrad/settings/flashlight_1.png","smooth mips") or
            value == 2 and Material("homigrad/settings/flashlight_2.png","smooth mips") or
            value == 3 and Material("homigrad/settings/flashlight_3.png","smooth mips")
        end
    }

    options:Add("Источник света у всех",function() RunConsoleCommand("hg_best_flashlight","-1") end)
    options:Add("Источник света только у других",function() RunConsoleCommand("hg_best_flashlight","0") end)
    options:Add("Направленый свет у всех",function() RunConsoleCommand("hg_best_flashlight","1") end)

    options:Set(2 + GetConVar("hg_best_flashlight"):GetInt(),true)

    --

    local panel,options = frame:AddOptions("Качество света от выстрелов",nil,"hg_best_weaponlight")
    panel.info = {
        description = "Будет ли оружие отбрасывать свет?\nИсточник света с тенями очень дорогостоющий",
        getImage = function()
            local value = options.curretOption
            return
            value == 1 and Material("homigrad/settings/weapon_shoot_light_-1.png","smooth mips") or
            value == 2 and Material("homigrad/settings/weapon_shoot_light_0.png","smooth mips") or
            value == 3 and Material("homigrad/settings/weapon_shoot_light_1.png","smooth mips")
        end
    }

    options:Add("Без света",function() RunConsoleCommand("hg_best_weaponlight","-1") end)
    options:Add("Источник света",function() RunConsoleCommand("hg_best_weaponlight","0") end)
    options:Add("Источник света с тенями",function() RunConsoleCommand("hg_best_weaponlight","1") end)

    options:Set(2 + GetConVar("hg_best_weaponlight"):GetInt(),true)

    --[[local panel,swith = frame:AddSwitch("Fast Scope",nil,"hg_fast_scope")
    panel.info = {
        description = "Не рендерит новую сцену для оптического прицела, вместо этого изменяется fov текущей сцены.\n+FPS но выгледеть будет не очень."
    }]]--

    local panel,swith = frame:AddSwitch("TPIK Fast","Плохо поддерживается","hg_tpik_fast")
    panel.info = {
        description = "Отключает TPIK кроме самого себя или на тех, за кем вы наблюдаете\nДаёт ложное представление о игроке (хитбоксы будут немного отличятся от настоящих, так-же не будут видны анимации перезарядки и т.п)"
    }

    local panel,swith = frame:AddSwitch("TPIK Lerp",nil,"hg_tpik_lerp")
    panel.info = {
        description = "Включает сглаживание анимации рук и оружия, без этой опции анимации будут очень резкими (влияет на стрельбу)\nНекоторые оружия имеют много костей и мне пока лень их оптимизировать, поэтому если отключить эту опцию, то фпс повысится в разы (прирост до 60)"
    }

    local panel,slider = frame:AddSlider("TPIK FPS",nil,"hg_tpik_fps")
    slider.round = 1
    panel.info = {
        description = "Просчитывает анимации n-ое количество раз в секунду, и между кадрами (интервалом) интерполирует старые кости к новым\nРекомендуемое значение 20 кадра в секунду\nЧем меньше значение, тем дёрганая анимация У ДРУГИХ ПЕРСОНАЖЕЙ, на своего за которого вы играете эта настройка никак не влияет\nЕсли поставить 0 то будет каждый кадр обробатывать <b>ЭТО СИЛЬНО СЖИРАЕТ FPS</b> (лутче поставить 18)"
    }

    local panel = frame:CreateBlock("Что такое TPIK?",nil)
    frame:Add(panel)

    panel.info = {
        description = "TPIK это трансформация костей рук на анимации оружия, проще говоря руки двигаются и взаимодействуют с оружием (перезарядка, взвод оружия и т.п)"
    }

    --
    frame:AddCategory("LOD")
    --

    local panel = frame:CreateBlock("Что такое LOD",nil)
    frame:Add(panel)

    panel.info = {
        description = "Система которая оценивает растояние до объекта и присваивает ей ярлык детализации.\nНапример вдалике нам не нужно рисовать много деталей поэтому мы можем рисовать только силует.\nРекомендую оставлять дистанции по наростающей."
    }


    local panel,slider = frame:AddSlider("LOD0","default 300","hg_lod0",nil)
    slider:SetClamp(0,300)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 0\nОчень мелкие детали на оружии, рисуем пальцы"}

    local panel,slider = frame:AddSlider("LOD1","default 600","hg_lod1",nil)
    slider:SetClamp(0,600)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 1\nРисуем детали"}

    local panel,slider = frame:AddSlider("LOD2","default 1200","hg_lod2",nil)
    slider:SetClamp(0,1200)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 2\nВ этой зоне работает TPIK"}

    local panel,slider = frame:AddSlider("LOD2/5","default 2000","hg_lod2_5",nil)
    slider:SetClamp(0,2000)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 2/5\nПереход между 2 и 3, Рисуем средние детали"}

    local panel,slider = frame:AddSlider("LOD3","default 4000","hg_lod3",nil)
    slider:SetClamp(0,4000)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 3\nРисуем силует, примерно 12x6 пикселей видно от объекта\nВ этой зоне рисуются силуэты оружий, дальше рендерится только игрок"}

    local panel,slider = frame:AddSlider("LOD4","default 7000","hg_lod4",nil)
    slider:SetClamp(0,7000)
    slider.round = 1 / 100
    panel.info = {description = "Дистанция в которой объект имееет уровень детализации 4\nТут уже пару пикселей остаётся от игрока"}
end

RunConsoleCommand("mat_motion_blur_enabled","1")
RunConsoleCommand("mat_bloomscale","0")