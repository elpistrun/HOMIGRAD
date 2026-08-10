local Page = scoreboard:Page_Reg(1000)

Page.pages[6] = Page.pages[6] or {}
local PageSub = Page.pages[6]
PageSub.Name = "Клавиатура"

function PageSub.Open(frame)
    local panel = frame:CreateBlock("Советую отбиндить кнопки в консоли",nil)
    frame:Add(panel)

    panel.info = {
        description = "Если вы здесь назначите кнопку Fake на T, то лутче прописать в консоли unbind t - потому-что если вы нажмёте кнопку, она прожмётся 2 раза.\n\nЕсли не хотите использовать эту систему то можно отбиндить клавишу нажав ESCAPE при назначении.\nНазвание консольных команд написано справо маленьким шрифтом."
    }

    local panel,bind = frame:AddBind("Fake","fake","fake")
    panel.info = {
        description = "Кнопка переключения режима регдола, если вы упали в регдол и нажмёте на эту кнопку - вы встаните с регдола и наоборот."
    }

    local panel,bind = frame:AddBind("Suicide","suicide","suicide")
    panel.info = {
        description = "Кнопка переключения режима суицыда, если у вас в руках огнестрельное оружие, персонаж направит его на самого себя, если вы выстрельните - вы умрёте.\nСоветую отбинить кнопк U и назначить на неё, так как тут нет командного чата"
    }

    local panel,bind = frame:AddBind("Drop Weapon","drop","drop")
    panel.info = {
        description = "Кнопка для выброса оружия."
    }

    local panel,bind = frame:AddBind("Inspect","inspect","inspect")
    panel.info = {
        description = "Кнопка осмотра оружия."
    }

    local panel,bind = frame:AddBind("Foot Kick","footkick","footkick")
    panel.info = {
        description = "Кнопка пинка.\nВ зависемости от угла камеры, применяются разные виды ударов ногой."
    }

    local panel,bind = frame:AddBind("Fast Pick Up Items","inv_fastmove","inv_fastmove")
    panel.info = {
        description = "Кнопка зажатия которая подбирает быстро предметы из инвентаря.\nНаведитесь курсором на предмет и зажмите эту кнопку."
    }
end

if Initialize then scoreboard:Open() end