local Panel = scoreboard:Page_Reg(2)
Panel.Name = "inventory"
Panel.Icon = Material("homigrad/vgui/icons/inventory.png","smooth")

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

local cframe1 = Color(255,255,255,3)

function Panel.Open(frame)
    inventoryGame.SetSelectItem()--по преколу

    if not LocalPlayer():Alive() then return end
    
    local invArmor = inventoryGame.local_inv_armor
    if not invArmor then return end

    local invH = invArmor.Size[2]

    local playerModel = oop.CreatePanel("v_playermodel",frame)
    local w,h = frame:W(),frame:H()
    playerModel:setSize(w * 0.15,math.floor(h * 0.7 / invH) * invH)

    local size = inventoryGame.SlotSize * 0.9

    playerModel:setPos(w * 0.075,h / 2 - playerModel:H()/2 - h / 40)

    playerModel:SetPlayer(LocalPlayer(),LocalPlayer():GetDummy())
    playerModel.cameraFOV = 15

    function playerModel:PreDraw(w,h)
        SetDrawColor(0,0,0,100)
        DrawRect(0,0,w,h)
        draw.GradientDown(0,0,w,h)

        DisableClipping(true)
        draw.SimpleText(LocalPlayer():Name(),"H.25",w/2,-size/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    function playerModel:DrawOver(w,h)
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end
    
    inventoryGame.InvLocalArmorCreate(playerModel,frame,invArmor,size)

    local panel_select = oop.CreatePanel("v_panel",frame):ad(function(self,w,h) self:setH(h * 0.3):setPos(w/2-self:W()/2,playerModel.y) end)
    inventoryGame.panel_select = panel_select

    panel_select:SetVisible(false)

    function frame:OnMouse(key,value)
        if value then inventoryGame.SetSelectItem() end
    end

    local ScoreboradInventoruUICreate = levelActive.ScoreboradInventoruUICreate

    if ScoreboradInventoruUICreate then levelActive:ScoreboradInventoruUICreate(frame) end
end

inventoryGame:Event_Add("ChangeSelectItem","UI",function(item)
    local panel = inventoryGame.panel_select
    if not IsValid(panel) then return end

    panel:Clear()
    panel:SetVisible(item and true or false)

    if item then
        local class = GetClassFromName(item.spawnname)
        if not class then return end
        
        local icon = oop.CreatePanel("v_panel",panel):ad(function(self,w,h) self:setSize(h,h) end)
        icon.drawtype = "select"
        panel.icon = icon
        
        local panel_slot = item.inv.slots[item.x][item.y].panel

        function icon:Draw(w,h)
            surface.SetDrawColor(20,20,20)
            surface.DrawRect(0,0,w,h)
            
            inventoryGame.DrawItemBackground(item,icon)
            inventoryGame.DrawItemContent(item,icon)
        end

        function icon:DrawOver(w,h)
            draw.Frame(0,0,w,h,cframe1,cframe2)

            class = GetClassFromName(item.spawnname)

            draw.SimpleText(class.GetInvName and class:GetInvName(item) or class.PrintName or item.spawnname,"HS.18",w/2,h - 8,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

            if class.InvSelectPanelDrawOver then class:InvSelectPanelDrawOver(w,h,icon,item) end
        end

        if class.invUI then
            class:invUI(panel,item)
        else
            panel:setW(panel:H())
        end
    end
end)

function inventoryGame.InvLocalArmorCreate(playerModel,frame,invArmor,size)
    local invH = invArmor.Size[2]

    local subY = playerModel:H() / 2 - (size * (invH + 1)) / 2
    
    local x = playerModel.x

    for i = 1,invH do
        invArmor:CreatePanelSlot(1,i,frame):setSize(size,size):setPos(x - size,playerModel.y + size * (i - 1) + subY):DeleteOnRemove(playerModel)
    end

    for i = 1,invH do
        invArmor:CreatePanelSlot(2,i,frame):setSize(size,size):setPos(x + playerModel:W(),playerModel.y + size * (i - 1) + subY):DeleteOnRemove(playerModel)
    end

    invArmor:CreatePanelSlot(1,9,frame):setSize(size,size):setPos(x - size,playerModel.y + size * 8 + subY):DeleteOnRemove(playerModel)
end

function Panel.Hovered(value,isClose)
    inventoryGame.InterfaceState = value

    inventoryGame:Event_Call("Interface State",value,isClose)
end

function scoreboard.OpenInventory()
    if scoreboard.curretPage == 2 and scoreboard.status then return end
    
    scoreboard.curretPage = 2
    scoreboard:Open()
end

event.Add("Player Spawn Local","scoreboard.curretPage = 2",function()
    scoreboard.curretPage = 2
end)

inventoryGame.InterfaceAnim = inventoryGame.InterfaceAnim or 0

event.Add("Think","inventoryGame.InterfaceAnim",function()
    if inventoryGame.InterfaceState then
        if inventoryGame.InterfaceAnim < 0.99 then
            inventoryGame.InterfaceAnim = LerpFT(0.5,inventoryGame.InterfaceAnim,1)
        else
            inventoryGame.InterfaceAnim = 1
        end
    else
        if inventoryGame.InterfaceAnim > 0.01 then
            inventoryGame.InterfaceAnim = LerpFT(0.5,inventoryGame.InterfaceAnim,0)
        else
            inventoryGame.InterfaceAnim = 0
        end
    end
end)

inventoryGame:Event_Add("Interface State","Panels",function(state,isClose)
    for inv,panel in pairs(inventoryGame.panels) do
        if IsValid(panel) and panel.OnChangeInterfaceState then
            panel:OnChangeInterfaceState(state,isClose)
        end
    end
end)

function Panel.CanOpen() return LocalPlayer():Alive() end

if Initialize then scoreboard:Open() end