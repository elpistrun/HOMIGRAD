local Page = scoreboard:Page_Reg(1000)

Page.pages[1] = Page.pages[1] or {}
local PageSub = Page.pages[1]
PageSub.Name = "game"

function PageSub.Open(frame,panelInfo)
    local panel,slider = frame:AddSlider("FOV",nil,"hg_fov")
    slider.round = 1
    panel.info = {
        description = "Меняет угол обзора камеры, золотой стандарт это 90 (иначе голова противника станет ещё меньше)\nНо и при 120 всё выгледет менее реалистичное и обзора куда больше для мнговеной оценки ситуации... выберайте сами!"
    }
    
    local panel,swith = frame:AddSwitch("История игрового чата",nil,"hg_chat_visible")
    panel.info = {
        description = "Отключает отображение истории игрового чата,\nкто знает зачем вам оно ( ͡° ͜ʖ ͡°)\nЕсли открыть, чат появится"
    }
    
    local panel,swith = frame:AddSwitch("HUD Наблюдятеля",nil,"hg_show_hudspectate")
    panel.info = {
        description = "Отключает отображение 'Spectate HUD',\nвсё ещё кто знает зачем вам оно ( ͡° ͜ʖ ͡°)"
    }

    local panel,swith = frame:AddSwitch("HUD Voice",nil,"hg_show_voicehud")
    panel.info = {
        description = "Отключает отображение 'Voice HUD' ( ͡° ͜ʖ ͡°)"
    }

    local panel,swith = frame:AddSwitch("Streamer Mode",nil,"hg_streamer_mode")
    panel.info = {
        description = "нуу... не лутчая идея стримить на твиче... но если вы так хотите (.❛ ᴗ ❛.)\nСуществуют специальные правила которые запрещают нарушать правила Twitch НО если вы стример и вас хоть кто-то смотрет.\nВы можете подать жалобу на человека который вам мешает.. ну или просто замутить его, подробности на сайте https://homigrad.com/wiki/rules\n\nНа самом деле по преколу добавил"
    }

    local panel,swith = frame:AddSwitch("Ragdoll Always E",nil,"hg_ragdoll_always_e")
    panel.info = {
        description = "При выключении этой опции спина регдола не будет работать, она будет работать если вы будете зажимать Е\nС этой отключённой опцией ползать неудобно, но зато удобно проползать/ползти в узких ушельях (Cave Daving) но там скорее всего она будет автоматически отключятся"
    }

    local panel,swith = frame:AddSwitch("Ragdoll Spine Cave Daving",nil,"hg_ragdoll_cave_spine")
    panel.info = {
        description = "Ваш регдол примит форму палки, то-есть спина не будет подыматся на 90 градусов относительно выпряменых рук",
        getImage = function(value)
            return tonumber(value) > 0 and
            Material("homigrad/settings/ragdoll_cave_spine_enable.png","smooth mips") or
            Material("homigrad/settings/ragdoll_cave_spine_disable.png","smooth mips")
        end
    }

    local panel,slider = frame:AddSlider("Scope Sensivity",nil,"hg_scope_sensivity_mul")
    slider.round = 100
    panel.info = {
        description = "Множитель чуствительности мыши при прицеливании"
    }
    
end

cvars.CreateOption("hg_chat_visible","1")

local PLAYER = FindMetaTable("Player")

if not HNameStreamerMode then HNameStreamerMode = PLAYER.Name end

cvars.CreateOption("hg_streamer_mode","0",function(value)
    if tonumber(value) > 0 then
        PLAYER.Name = function(self) return tostring(self:UserID()) end
        PLAYER.Nick = PLAYER.Name

        StreamMode = true
    else
        PLAYER.Name = HNameStreamerMode
        PLAYER.Nick = PLAYER.Name

        StreamMode = false
    end
end)