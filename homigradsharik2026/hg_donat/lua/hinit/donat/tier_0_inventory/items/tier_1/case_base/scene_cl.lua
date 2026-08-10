local ITEM = inventoryManager:ItemReg("case","base",true)
if not ITEM then return INCLUDE_BREAK end

function ITEM:CreateRollMenu(winItem)
    if IsValid(CASE_ROLL_FRAME) then CASE_ROLL_FRAME:Remove() end

    local item = self

    CASE_ROLL_FRAME = oop.CreatePanel("v_frame"):ad(function(self,w,h) self:setSize(w,h) end)
    CASE_ROLL_FRAME:MakePopup()

    local start = RealTime()

    function CASE_ROLL_FRAME:Draw(w,h)
        local k = 1 - math.max(start - RealTime() + 0.5,0) / 0.5

        surface.SetDrawColor(0,0,0,200 * k)
        surface.DrawRect(0,0,w,h)

        DrawBlurByPanel(6 * k,self)
    end

    local RollCount = math.random(40,60)

    local iconSize = math.floor(CASE_ROLL_FRAME:H() / 6)

    local panel = oop.CreatePanel("v_panel",CASE_ROLL_FRAME):ad(function(self,w,h) self:setSize(w * 0.9,iconSize) end)

    local startRoll

    local panels = {}
    local chache = {}

    local RollCurret = 0

    local list = {}

    local wideKWin = math.Rand(0.05,0.95)

    local startUpDelay = 0.5

    timer.Create("CASE_ROLL_START",1,1,function()
        startRoll = RealTime()

        LocalPlayer():EmitSound("homigrad/vgui/freeze_cam.wav",75,100,0.3)
        LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_seal.wav",75,100,0.25)

        LocalPlayer():EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1,3) .. ".wav",75,200,0.3)
    end)

    LocalPlayer():EmitSound("homigrad/vgui/item_store_add_to_cart.wav")
    
    function CASE_ROLL_FRAME:OnMouse(key,value)
        if not value then return end
       
        if start + startUpDelay - RealTime() > 0 then return end

        startRoll = 0
    end

    function panel:Step()
        local delay = RollCount / 6

        if startRoll then
            local k = math.max(startRoll - RealTime() + 1,0) / 1

            local shakeX,shakeY = math.Rand(-16,16) * k,math.Rand(-16,16) * k

            local parent = self:GetParent()
            self:setPos(parent:W()/2-self:W()/2 + shakeX,parent:H()/2-self:H()/2 + shakeY)

            RollCurret = Lerp(1 - math.ease.OutSine(1 - math.max(startRoll - RealTime() + delay,0) / delay),RollCount,1)
        else
            local k = 1 - math.max(start - RealTime() + startUpDelay,0) / startUpDelay

            k = math.ease.OutCubic(k)

            local parent = self:GetParent()
            self:setPos(parent:W()/2-self:W()/2,(parent:H() * k / 2) -self:H()/2)
        end

        local w = self:W()
        local max = math.ceil(w / iconSize) + 1
        local half = math.floor(max/2)

        for i = 0,max do
            local panel = panels[i]

            if not panel then
                panel = oop.CreatePanel("v_panel",self):ad(function(self,w,h) self:setSize(iconSize,iconSize) end)//mdem
                panels[i] = panel
            end

            local curret = RollCurret - half
            local ID = i + math.floor(curret)
            
            if not list[ID] then
                if RollCurret != RollCount then
                    LocalPlayer():StopSound("homigrad/vgui/csgo_ui_crate_item_scroll.wav")
                    LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_crate_item_scroll.wav")
                end

                if ID == RollCount then
                    list[ID] = winItem
                else
                    list[ID] = item:GetCasinoItem()
                end
            end

            local item = chache[list[ID].model]

            if not item then
                item = inventoryManager:CreateItemObjectFromData(list[ID])
                chache[item.class] = item
            end
            
            panel:setPos((iconSize * (i - 1)) - iconSize * (curret % 1) - math.max(iconSize * half - w/2) + panel:W() * wideKWin,0)

            function panel:Draw(w,h)
                item:DrawIcon(iconSize,iconSize,panel)
            end
        end

        if RollCurret == RollCount then
            LocalPlayer():EmitSound("homigrad/vgui/buttonclick.wav")
            LocalPlayer():EmitSound("homigrad/vgui/counter_beep.wav")

            panel.Step = nil

            timer.Simple(0.75,function()
                CASE_ROLL_FRAME:Remove()

                DonatInventory_ShowNewItems(DonatInventoryNotification,nil,function()
                    DonatInventoryNotification = nil
                    InventoryNotificationManager.Clear()
                end)

                scoreboard:Open()
            end)
        end
    end

    function panel:DrawOver(w,h)
        surface.SetDrawColor(255,255,0)
        surface.DrawRect(w/2,0,1,h)

        draw.Frame(0,0,w,h,cframe1,cframe2)
    end
end

inventoryNotificationManager:Event_Add("Can","Case",function()
    if IsValid(CASE_ROLL_FRAME) then return false end
end)
