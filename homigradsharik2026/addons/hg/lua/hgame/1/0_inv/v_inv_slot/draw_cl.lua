local PANEL = oop.Get("v_inv_slot")
if not PANEL then return end

event.Add("Screen Size","Fonts Inv",function(mul)
    surface.CreateFont("InvFont",{
        font = "Arial",
        size = 12 * mul,
        weight = 0,
        outline = true,
        shadow = true,
        antialias = false,
        additive = true,
    })
end)

local SetDrawColor,DrawRect = surface.SetDrawColor,surface.DrawRect

function PANEL:DrawHovered(w,h)
    if self.CustomDrawHovered and self:CustomDrawHovered(w,h) == true then return end
    
    local isDown = self:IsDown() or inventoryGame.GrabSlot == self
    local isHovered = self:IsHovered()

    if isDown then
        SetDrawColor(0,0,0,125)
        DrawRect(0,0,w,h)
    elseif isHovered then
        SetDrawColor(255,255,255,5)
        DrawRect(0,0,w,h)
    end

    local set = (isHovered or self.isDown or inventoryGame.GrabSlot == self) and 1 or 0
    self.hovered = LerpFT(0.5,self.hovered,set)

    if set == 1 and self.hovered >= 0.95 then self.hovered = 1 end
    if set == 0 and self.hovered <= 0.05 then self.hovered = 0 end
    
    if inventoryGame.SelectItem and inventoryGame.SelectItem == self:GetItem() then
        surface.SetDrawColor(255,255,255,3)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(255,255,255,255)
        surface.DrawRect(0,h - 2,w,2)

        surface.SetDrawColor(128,128,128,128)
        draw.GradientDown(0,0,w,h)
    end
end

local cframe1,cframe2 = Color(255,255,255,5),Color(0,0,0)

function PANEL:Draw(w,h)
    if self.CustomDraw then
        self:CustomDraw(w,h)
    else
        SetDrawColor(30,30,30,255)
        DrawRect(0,0,w,h)
    end

    self:DrawHovered(w,h)
    self:DrawItem(self)

    if self.CustomPostDraw then
        self:CustomPostDraw(w,h)
    else
        draw.Frame(0,0,w,h,cframe1,cframe2)
    end
end

local black = Color(45,45,75)

function inventoryGame.DrawItemBackground(item,panel)
    local w,h = panel:W(),panel:H()

    local class = GetClassFromName(item.spawnname)

    if not class then
        draw.SimpleText(tostring(item.spawnname),"HS.12",0,0,Color(255,0,0))
        
        return
    end

    local col = inventoryGame.GetColorType(item)
    SetDrawColor(col.r,col.g,col.b,40)
    surface.DrawRect(0,0,w,h)
    
    SetDrawColor(col.r,col.g,col.b,125)

    draw.GradientDown(0,0,w,h)
end

local WeaponIconMatrix = render.WeaponIconMatrix

function inventoryGame.DrawItemContent(item,panel,x,y)
    local count = item.data.count or #item.inv.slots[item.x][item.y].list

    local class = GetClassFromName(item.spawnname)
    if not class then return end
    
    local w,h = panel:W(),panel:H()
    
    if not x then
        x,y = panel:LocalToScreen()
    end

    local success

    if class.invUI_Draw then
        success = class:invUI_Draw(panel,item)
    else
        if class.WorldModel or class.InitWorldModel then
            local SELF = class

            SELF = fakeObject.GetFakeObjectRender(class,item)
            SELF.csmParentTag = tostring(SELF)

            render.ClearWeaponIcon()

            if panel.drawtype == "select" then
                x,y = panel:LocalToScreen()
                
                WeaponIconMatrix.self = SELF
                WeaponIconMatrix.x = x
                WeaponIconMatrix.y = y
                WeaponIconMatrix.w = w
                WeaponIconMatrix.h = h
                WeaponIconMatrix.addFov = class.dwiSelectFOV or 0
                --WeaponIconMatrix.Pos = class.GetDWISelectPos and SELF:GetDWISelectPos() or class.dwiSelectPos
                --WeaponIconMatrix.Ang = class.GetDWISelectAng and SELF:GetDWISelectAng() or class.dwiSelectAng

                WeaponIconMatrix.Pos = class.dwiPos
                WeaponIconMatrix.Ang = class.dwiAng
                WeaponIconMatrix.tag = "invSelected"

                render.DrawWeaponIcon()
            else
                WeaponIconMatrix.self = SELF
                WeaponIconMatrix.x = x
                WeaponIconMatrix.y = y
                WeaponIconMatrix.w = w
                WeaponIconMatrix.h = h
                WeaponIconMatrix.addFov = -(panel.hovered or 0) * 3 * Lerp((20 + (class.dwiFOV or 0)) / 20,0,1) * (inventoryGame.GrabSlot and 0 or 1)
                WeaponIconMatrix.Pos = class.dwiPos
                WeaponIconMatrix.Ang = class.dwiAng
                WeaponIconMatrix.tag = "inv"

                render.DrawWeaponIcon()
            end
        else
            surface.SetMaterial(EntityIcon(item.spawnname))
            local size = h - 14 + (panel.hovered or 0) * 5
        
            surface.SetDrawColor(r or 255,g or 255,b or 255)
            surface.DrawTexturedRect(w / 2 - size / 2 + 1,h / 2 - size / 2 + 1,size,size)
        end
    end

    if class.DrawInvPost then class:DrawInvPost(self,panel,item) end

    if not panel.drawtype then
        if count > 1 then
            draw.SimpleText("x" .. count,"InvFont",4,2)
        end
    end
end

function PANEL:DrawItem(panel)
    panel = panel or self
    local tag = tostring(panel)
    
    local w,h = panel:W(),panel:H()
    local x,y = panel:LocalToScreen()

    local item = self:GetItem()

    if item then
        inventoryGame.DrawItemBackground(item,panel)

        if not inventoryGame.GrabSlot or inventoryGame.GrabSlot ~= self then
            inventoryGame.DrawItemContent(item,panel,x,y)
        end
    end

    local slot = self.slot

    if slot.wait then
        local k = 1

        if slot.wait == 0 then
            k = 1
        else
            k = math.max(slot.wait + slot.waitDelay - RealTime(),0) / slot.waitDelay
        end

        self:DrawWait(k,w,h)
    end
end

local triangle = {}
local rad = 16

function PANEL:DrawWait(k,w,h)
    for i = 1,#triangle do triangle[i] = nil end

    triangle[#triangle + 1] = {
        x = w/2,
        y = h/2
    }

    for i = 0,36 do
        i = i / 36
        i = (360 * k) * i
        i = math.rad(i - 90)

        triangle[#triangle + 1] = {
            x = w/2 + rad * math.cos(i),
            y = h/2 + rad * math.sin(i)
        }
    end

    surface.SetDrawColor(255,255,255,255)
    draw.NoTexture()
    surface.DrawPoly(triangle)
end