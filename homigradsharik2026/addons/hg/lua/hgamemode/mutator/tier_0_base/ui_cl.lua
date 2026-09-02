local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

function MUTATOR:CreatePanel(className,parent)
    local I = #parent:GetChildren()
    return oop.CreatePanel(className,parent):ad(function(self,w,h) self:setSize(w,50):setPos(0,self:H() * I) end)
end

local green,red = Color(0,255,0),Color(255,0,0)

function MUTATOR:CreatePanelEnabled(parent)
    local param = self:CreatePanel("v_parametr",parent)
    param.text = "Enabled"; param.font = "HS.18"
    function param.GetText()
        param.color = self:GetActive() and green or red
        return tostring(self:GetActive() and true or false)
    end
    function param.OnClick() self:SendCMD("enabled",{self:GetActive() and 0 or 1}) end
end

function MUTATOR:CreatePanelSlider(parent,text,desc,key)
    local panel = self:CreatePanel("v_panel",parent)
    local slider = oop.CreatePanel("v_slider",panel):ad(function(self,w,h) self:setSize(w/2,h):setPos(w/2,0) end)

    function panel:Draw(w,h)
        draw.SimpleText(text,"HS.18",h/2,h/2,nil,nil,TEXT_ALIGN_CENTER)
        draw.Frame(0,0,w,h,cframe1,cframe2)

        if desc then self:DrawTip(L(desc)) end
    end

    slider.round = 1

    function slider.Step() if slider.startTimeChange + 1 < RealTime() then slider:SetValue(self["Get" .. key](self) or 0) end end
    function slider.OnValue(_,value)
        timer.Create(tostring(slider) .. key .. "changevalue",0.1,1,function()
            self:SendCMD(key,{value})
        end)
    end

    return slider
end

//

adminPanel.commandCreate("mutator",function()
    RunConsoleCommand("hg_mutator_open")
end)

concommand.Add("hg_mutator_open",function()
    if IsValid(MutatorUI) then MutatorUI:Remove() return end

    MutatorUI = oop.CreatePanel("v_frame"):setDSize(0.8,0.8)
    MutatorUI:setPos(ScrW()/2-MutatorUI:W()/2,ScrH()/2-MutatorUI:H()/2)
    MutatorUI:MakePopup()
    
    function MutatorUI:Draw(w,h)
        gui.EnableScreenClicker(true)
        surface.SetDrawColor(0,0,0,200)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("Mutators Menu","HS.25",w / 2,50/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function MutatorUI:OnRemove()
        gui.EnableScreenClicker(false)
    end

    function MutatorUI:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end

    local exit = oop.CreatePanel("v_button",MutatorUI):ad(function(self,w,h) self:setSize(100,50):setPos(w - self:W(),0) end)
    exit:SetupDrawStyle("white_gradient") exit.gradientSide = "right"
    exit.text = "EXIT"; exit.font = "HS.18"
    function exit:OnClick() MutatorUI:Remove() end

    local scrollnav = oop.CreatePanel("v_scrollnav",MutatorUI):ad(function(self,w,h) self:setPos(0,50):setSize(300,h - self.y) end)
    scrollnav:SetHighlightSide("left",nil,60)
    scrollnav:SetFont("HS.18")

    function scrollnav:DrawHighlightSide(w,h,y,size)
        surface.SetDrawColor(255,255,255,5)
        surface.DrawRect(0,y,w,size)

        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,y,2,size)
    end

    local scrollpage = oop.CreatePanel("v_scrollpage",MutatorUI):ad(function(self,w,h) self:setPos(scrollnav:W(),50):setSize(w - scrollnav:W(),h - self.y) end)
    scrollpage:SetHorizontal(false)

    local iteration = 0
    for class,mutator in SortedPairs(MutatorClasses) do
        if class == "base" then continue end

        iteration = iteration + 1
        local I = iteration
        local butt = scrollnav:Add(L(mutator.Title or class),function() scrollpage:Set(I) MutatorUIPage = I end)
        
        local desc = L(mutator.Desc or "")
        
        function butt:Draw(w,h)
            if mutator:GetActive() then
                surface.SetDrawColor(0,255,0,64)
                draw.GradientLeft(0,0,w / 2,h)
            end

            local icon = mutator.Icon
            if icon then
                surface.SetDrawColor(255,255,255)
                surface.SetMaterial(icon)
                surface.DrawTexturedRectRotated(h/2,h/2,h/3,h/3,self:IsHovered() and 45 * math.cos(CurTime() * 15) or 0)
            end

            draw.SimpleText(self.text,self.font,w - h/2,h/2,nil,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)

            if self:IsHovered() then
                surface.SetDrawColor(255,255,255,5)
                surface.DrawRect(0,0,w,h)
            end

            if desc != "" then self:DrawTip(desc) end
        end

        local page = scrollpage:Add()

        if mutator.CreateUI then
            mutator:CreateUI(page)
        else
            function page:Draw(w,h)
                draw.SimpleText("Nothing here ;c","HS.45",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
        end
    end

    if MutatorUIPage then
        scrollnav:Set(MutatorUIPage)
        scrollpage:Set(MutatorUIPage,true)
    end
end)

if Initialize then
    if IsValid(MutatorUI) then MutatorUI:Remove() end
    RunConsoleCommand("hg_mutator_open")
end