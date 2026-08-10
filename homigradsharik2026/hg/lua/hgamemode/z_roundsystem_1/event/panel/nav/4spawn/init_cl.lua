EventPanel_Pages[4] = {}
local Panel = EventPanel_Pages[4]
Panel.Name = "event_spawn"

local function sendCmd(args)
    net.Start("event_group_spawn")
    net.WriteTable(args)
    net.SendToServer()
end

function Panel.Create(frame)
    function frame:Draw(w,h)
        draw.SimpleText(L("event_spawn"),"HS.25",w / 2,30,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    
    local groupList = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setPos(0,60):setSize(w * 0.15,h - self.y) end)
    groupList:SetHighlightSide("right",nil,30)
    function groupList:Draw(w,h)
        surface.SetDrawColor(0,0,0,50)
        surface.DrawRect(0,0,w,h)
        surface.DrawRect(w - 1,0,1,h)
    end
    
    local groupSelect
    local modelSelect

    local avatar = oop.CreatePanel("v_playermodel",frame):ad(function(self,w,h) self:setSize(w * 0.25,h - groupList.y):setPos(groupList.x + groupList:W(),groupList.y) end)
    
    function avatar:Update()
        if not groupSelect then return end

        if not IsValid(self.mdl) then self:SetModel() end
        if modelSelect then
            if self.mdlName ~= modelSelect.mdlName then self:SetModel(modelSelect.mdlName) end

            local mdl = self.mdl

            if IsValid(mdl) then
                for k,v in pairs(groupSelect.models[self.mdlName] and groupSelect.models[self.mdlName].bodygroups or {}) do
                    if TypeID(v) == TYPE_TABLE then continue end

                    mdl:SetBodygroup(k,v)
                end
            end
        else
            self:SetModel()
        end
    end

    local delay = 0
    function avatar:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)

        if not groupSelect or not modelSelect then return end

        local time = RealTime()
        if delay > time then return end
        delay = time + 0.25

        for k,v in pairs(modelSelect.bodygroups) do
            if TypeID(v) != TYPE_TABLE then continue end

            self.mdl:SetBodygroup(k,math.random(v[1],v[2]))
        end
    end

    local navPanel = oop.CreatePanel("v_scrollnav",frame):ad(function(self,w,h) self:setPos(avatar.x + avatar:W(),groupList.y):setSize(w - self.x,30) end)
    navPanel:SetHighlightSide("bottom")
    function navPanel:Draw(w,h)
        surface.SetDrawColor(0,0,0,100)
        surface.DrawRect(0,0,w,h)
        surface.DrawRect(0,h - 1,w,1)
    end
    local scrollPage = oop.CreatePanel("v_scrollpage",frame):ad(function(self,w,h) self:setPos(avatar.x + avatar:W(),navPanel.y + navPanel:H()):setSize(w - self.x,h - self.y) end)
    scrollPage:SetHorizontal(true)
    
    // Edits

    local page = scrollPage:Add(); navPanel:Add(L("event_spawn_edits"),function(id) scrollPage:Set(id) end)
    local navCategory = oop.CreatePanel("v_scrollnav",page):ad(function(self,w,h) self:setSize(200,h) end)
    navCategory:SetHighlightSide("right",nil,30)

    local pagesCategory = oop.CreatePanel("v_scrollpage",page):ad(function(self,w,h) self:setPos(navCategory:W(),0):setSize(w - navCategory:W(),h) end)
    pagesCategory:SetHorizontal(false)

    for category,list in pairs(EventGroupEditsClient) do
        local page = pagesCategory:Add()
        navCategory:Add(L(category),function(id) pagesCategory:Set(id) end)

        for name,info in SortedPairs(list) do
            local i = #page:GetChildren()
            local panel = oop.CreatePanel("v_parametr",page):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
            panel.Callback = function(value) sendCmd({"edit",groupSelect.id,name,value}) end
            panel.GetText = function(self,number) return tostring(groupSelect[name]) end

            panel.text = L(info.title)
            panel.font = "HS.25"
        end
    end

    // RelationShips

    local page = scrollPage:Add(); navPanel:Add(L("event_group_relationships"),function(id) scrollPage:Set(id) end)
    local groupListRelationShips = oop.CreatePanel("v_scrollnav",page):ad(function(self,w,h) self:setSize(200,h) end)
    groupListRelationShips:SetHighlightSide("right",nil,30)

    function groupListRelationShips:OnClick(value)

    end

    local panelEdits = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setPos(groupListRelationShips:W(),0):setSize(w - self.x,h) end)
    local groupSelectRelationShips

    function groupListRelationShips:OnClick(id)
        groupSelectRelationShips = EventGroups[id]
    end

    for name,info in pairs(EventGroupRealships) do
        local i = #panelEdits:GetChildren()
        local panel = oop.CreatePanel("v_parametr",panelEdits):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
        panel.Callback = function(value) sendCmd({"relationship",groupSelect.id,name,groupSelectRelationShips.link,value}) end
        panel.GetText = function(self,number) return info.getText(groupSelect,groupSelectRelationShips) end
        panel.GetTextEntry = function(self,number) return (info.getTextEntry or info.getText)(groupSelect,groupSelectRelationShips) end
        panel.text = L(info.title)
        panel.font = "HS.25"
        panel.tip = info.tip
    end

    // Player Model

    local page = scrollPage:Add(); navPanel:Add(L("event_spawn_playermodel"),function(id) scrollPage:Set(id) end)
    local panel = oop.CreatePanel("v_panel",page):ad(function(self,w,h) self:setSize(w,h * 0.5) end)

    local listModelsSelected = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,64 + 32) end)
    listModelsSelected:CreateHBar()
    
    function listModelsSelected:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    function listModelsSelected:Update()
        self:Clear()

        if not groupSelect then return end
        
        local I = 0
        for mdlName,info in pairs(groupSelect.models) do
            info.mdlName = mdlName

            local i = I
            I = I + 1
            local icon = oop.CreatePanel("v_spawnicon",self):ad(function(self,w,h) self:setSize(64,64):setPos(self:W() * i,0) end)
            icon:SetModel(mdlName)
            function icon:Draw(w,h)
                if modelSelect.mdlName == self:GetModelName() then
                    surface.SetDrawColor(255,255,255,25)
                    surface.DrawRect(0,0,w,h)
                end
    
                if self:IsHovered() then
                    surface.SetDrawColor(255,255,255,5)
                    surface.DrawRect(0,0,w,h)
                end
            end
            function icon:OnMouse(key,value)
                if not value then return end
    
                if key == MOUSE_LEFT then
                    modelSelect = groupSelect.models[icon:GetModelName()]
                    
                    frame:Update()
                else
                    sendCmd({"modelremove",groupSelect.id,icon:GetModelName()})
                end
            end
        end

        if not modelSelect or not groupSelect.models[modelSelect.mdlName] then
            modelSelect = table.Random(groupSelect.models)
        end

        if modelSelect and modelSelect ~= groupSelect.models[modelSelect.mdlName] then modelSelect = groupSelect.models[modelSelect.mdlName] end//update table
    end

    local listModels = oop.CreatePanel("v_scrollpanel",panel):ad(function(self,w,h) self:setSize(w,h - listModelsSelected:H()):setPos(0,listModelsSelected:H()) end)
    listModels:CreateVBar()
    listModels.scrolling = 90

    function listModels:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    local pointX,pointY = 0,0
    for name,model in pairs(player_manager.AllValidModels()) do
        local x,y = pointX,pointY

        local icon = oop.CreatePanel("v_spawnicon",listModels):ad(function(self,w,h) self:setSize(64,64):setPos(x,y) end)
        icon:SetModel(model)
        
        function icon:Draw(w,h)
            if groupSelect.models[self:GetModelName()] then
                surface.SetDrawColor(255,255,255,25)
                surface.DrawRect(0,0,w,h)
            end

            if self:IsHovered() then
                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,w,h)
            end
        end
        function icon:DoClick(key,value)
            sendCmd({"modelcreate",groupSelect.id,icon:GetModelName()})
        end

        pointX = pointX + icon:W()
        if pointX + icon:W() >= listModels:W() then
            pointX = 0
            pointY = pointY + icon:H()
        end
    end

    local x,y = pointX,pointY
    local icon = oop.CreatePanel("v_button",listModels):ad(function(self,w,h) self:setSize(64,64):setPos(x,y) end)
    function icon:Draw(w,h)
        draw.SimpleText("CUSTOM","HS.12",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        if self:IsHovered() then
            surface.SetDrawColor(255,255,255,10)
            surface.DrawRect(0,0,w,h)
        end
    end

    function icon:OnClick()
        VParametrEdit(L("event_spawn_writemdlname"),"",function(value)
            sendCmd({"modelcreate",groupSelect.id,value})
        end)
    end

    local bodyPanel = oop.CreatePanel("v_scrollpanel",page):ad(function(self,w,h) self:setSize(w,h * 0.5):setPos(0,h * 0.5) end)
    bodyPanel:CreateVBar()
    bodyPanel.scrolling = 125

    function bodyPanel:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe2,cframe1)
    end

    local oldMdl
    function bodyPanel:Update()
        if not modelSelect then
            bodyPanel:Clear()
            oldMdl = nil

            return
        end

        local mdl = avatar.mdl
        
        if oldMdl ~= avatar.mdlName then
            bodyPanel:Clear()
            bodyPanel.sliders = {}
            
            oldMdl = avatar.mdlName

            if not IsValid(mdl) then return end

            for i in pairs(modelSelect.bodygroups) do
                local panel = oop.CreatePanel("v_panel",bodyPanel):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * i) end)
                
                local pages = oop.CreatePanel("v_scrollpage",panel):ad(function(self,w,h) self:setSize(w/2,h):setPos(w / 2,0) end)
                pages:SetHorizontal(false)

                local name = mdl:GetBodygroupName(i)
                function panel:Draw(w,h)
                    surface.SetDrawColor(125,125,125,64)

                    draw.GradientLeft(0,h - 1,w * 1.5,1)

                    if pages.setPage == 1 then
                        surface.SetDrawColor(64,64,64,64)
                        local size = w * 0.85
                        draw.GradientRight(w - size + 1,0,size,h)
                    end

                    draw.SimpleText(name,"HS.18",h / 2,h / 2,nil,nil,TEXT_ALIGN_CENTER)
                end

                local butt = oop.CreatePanel("v_button",panel):ad(function(self,w,h) self:setSize(60,h):setPos(w/2 - self:W(),0) end)
                function butt:OnClick()
                    if TypeID(modelSelect.bodygroups[i]) != TYPE_TABLE then
                        sendCmd({"bodygroup",groupSelect.id,modelSelect.mdlName,i,{0,mdl:GetBodygroupCount(i)}})
                    else
                        sendCmd({"bodygroup",groupSelect.id,modelSelect.mdlName,i,0})
                    end
                end

                local pageRandoms = pages:Add()
                local sliderMin = oop.CreatePanel("v_slider",pageRandoms):ad(function(self,w,h) self:setSize(w * 0.5,h):setPos(0,0) end)
                sliderMin.textW = 25
                sliderMin:SetMax(mdl:GetBodygroupCount(i))
                sliderMin.round = 1
                sliderMin:SetValue(0)
    
                function sliderMin:OnValue(value) sendCmd({"bodygroup",groupSelect.id,modelSelect.mdlName,i,{value,modelSelect.bodygroups[i][2]}}) end

                local sliderMax = oop.CreatePanel("v_slider",pageRandoms):ad(function(self,w,h) self:setSize(w * 0.5,h):setPos(w * 0.5,0) end)
                sliderMax.textW = 25
                sliderMax:SetMax(mdl:GetBodygroupCount(i))
                sliderMax.round = 1
                sliderMax:SetValue(mdl:GetBodygroupCount(i))
    
                function sliderMax:OnValue(value) sendCmd({"bodygroup",groupSelect.id,modelSelect.mdlName,i,{modelSelect.bodygroups[i][1],value}}) end

                local pageStatic = pages:Add()
                local slider = oop.CreatePanel("v_slider",pageStatic):ad(function(self,w,h) self:setSize(w,h):setPos(0,0) end)
                slider.textW = 25
                slider:SetMax(mdl:GetBodygroupCount(i))
                slider.round = 1
                slider:SetValue(0)
    
                function slider:OnValue(value) sendCmd({"bodygroup",groupSelect.id,modelSelect.mdlName,i,value}) end

                bodyPanel.sliders[i] = {{sliderMin,sliderMax},slider,pages,butt}
            end
        end

        if not IsValid(mdl) then return end

        for k,v in pairs(modelSelect.bodygroups) do
            local panels = bodyPanel.sliders[k]

            if TypeID(v) == TYPE_TABLE then
                panels[1][1]:SetValue(v[1])
                panels[1][2]:SetValue(v[2])

                panels[3]:Set(1,true)
                panels[4].text = "Rand"
            else
                panels[2]:SetValue(v)
                panels[3]:Set(2,true)
                
                panels[4].text = "Static"
            end
        end
    end

    //

    function groupListRelationShips:Update()
        groupListRelationShips:Clear()

        for id,group in pairs(EventGroups) do
            local button = groupListRelationShips:Add(group.name,function()
                groupSelectRelationShips = group
                frame:Update()
            end)

            function button:DrawOver(w,h)
                local color = group.color
                surface.SetDrawColor(color.r,color.g,color.b)
                surface.DrawRect(0,0,4,h)

                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,1,h)
                surface.DrawRect(0,0,4,1)
                surface.SetDrawColor(0,0,0,175)
                surface.DrawRect(0,h - 1,4,1)

                draw.SimpleText("#" .. id,"HS.12",h / 2,h / 2,white,nil,TEXT_ALIGN_CENTER)
            end
        end

        if groupSelectRelationShips then groupSelectRelationShips = EventGroups[groupSelectRelationShips.id] end

        if not groupSelectRelationShips and EventGroups[1] then
            groupSelectRelationShips = EventGroups[1]
        end

        if groupSelectRelationShips then groupListRelationShips:Set(groupSelectRelationShips.id) end

        panelEdits:SetVisible(groupSelectRelationShips and true or false)
    end

    function groupList:Update()
        groupList:Clear()

        for id,group in pairs(EventGroups) do
            if not groupSelect or group.id == groupSelect.id then groupSelect = group end

            local button = groupList:Add(group.name,function()
                groupSelect = group
                frame:Update()
            end)

            function button:DrawOver(w,h)
                local color = group.color
                surface.SetDrawColor(color.r,color.g,color.b)
                surface.DrawRect(0,0,4,h)

                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,1,h)
                surface.DrawRect(0,0,4,1)
                surface.SetDrawColor(0,0,0,175)
                surface.DrawRect(0,h - 1,4,1)

                draw.SimpleText("#" .. id,"HS.12",h / 2,h / 2,white,nil,TEXT_ALIGN_CENTER)
            end
        end

        if groupSelect and not EventGroups[groupSelect.id] then
            groupSelect = EventGroups[1]
        end

        if not groupSelect then
            scrollPage:Set(0)
            scrollPage:SetVisible(false)
        elseif not scrollPage:IsVisible() then
            scrollPage:SetVisible(true)
            scrollPage:Set(1)
        end
    end

    function frame:Update()
        groupList:Update()
        groupListRelationShips:Update()

        listModelsSelected:Update()
        
        avatar:Update()
        bodyPanel:Update()

        //scrollPage:Set(3)
    end

    frame:Update()
end

if Initialize then scoreboard:Open() end
//пиздец я насрал жёстко....