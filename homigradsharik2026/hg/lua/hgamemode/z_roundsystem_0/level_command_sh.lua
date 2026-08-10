local cmd = adminPanel.commandRegistry("levelrandom",{"bool"},nil,nil,"levels")
function cmd.UICreate(panel,panelRight)
    local panel = panelRight:CreatePanel(panelRight:W()/4,{type = "bool",name = "Менять ли режим следущей игры?"})
    local switch = oop.CreatePanel("v_switch",panel):ad(function(self,w,h) self:setPos(0,30):setSize(w,h - self.y) end)
    switch:SetValue(GetGlobalBool("LevelRandom"))
    function switch:OnValue(value)
        RunConsoleCommand("ulx","levelrandom",value and 1 or 0)
    end
end

adminPanel.commandRegistry("levelend",{},nil,nil,"levels")
adminPanel.commandRegistry("levelstart",{},nil,nil,"levels")
adminPanel.commandRegistry("levelnext",{"string"},nil,nil,"levels")

local cmd = adminPanel.commandRegistry("levels",{},nil,nil,"levels")
function cmd.UICreate(panel,panelRight)
    panel:CreateVBar()

    local y = 0
    for name,level in pairs(Levels) do
        local Y = y
        local panel = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(w,75):setPos(0,Y) end)
        y = y + panel:H()
        function panel:Draw(w,h)
            draw.SimpleText(string.sub(name,7,#name),"HS.25",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    end
end

local cmd = adminPanel.commandRegistry("stopgame",{"bool"},nil,nil,"levels")

function cmd.UICreate(panel,panelRight)
    local panel = panelRight:CreatePanel(panelRight:W()/4,{type = "bool",name = "Остановить логику игры"})
    local switch = oop.CreatePanel("v_switch",panel):ad(function(self,w,h) self:setPos(0,30):setSize(w,h - self.y) end)
    switch:SetValue(GetGlobalBool("StopGame"))
    function switch:OnValue(value)
        RunConsoleCommand("ulx","stopgame",value and 1 or 0)
    end
end

local cmd = adminPanel.commandRegistry("aistop",{"bool"},nil,nil,"levels")

function cmd.UICreate(panel,panelRight)
    local panel = panelRight:CreatePanel(panelRight:W()/4,{type = "bool",name = "Остановить логику AI"})
    local switch = oop.CreatePanel("v_switch",panel):ad(function(self,w,h) self:setPos(0,30):setSize(w,h - self.y) end)
    switch:SetValue(GetConVar("ai_disabled"):GetBool())
    function switch:OnValue(value)
        RunConsoleCommand("ulx","aistop",value and 1 or 0)
    end
end

adminPanel.commandRegistry("roundactive",{},nil,nil,"levels").title = "Активировать игру"