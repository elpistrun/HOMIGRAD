local PANEL = oop.Get("v_inv_slot")
if not PANEL then return end

function PANEL:OnMouse(key,value)
    if not value or (self.donotpressright and key == MOUSE_RIGHT) then return end--shit

    if self.CanSelectItem and self:CanSelectItem() == false then return end

    local item = self:GetItem()

    timer.Simple(math.Rand(0,0.01),function()
        inventoryGame.PlaySound(item,"InvGrabSnd",0,-0.2)
    end)
    
    if not self.cantSelectSlot then
        if key == MOUSE_LEFT then
            if inventoryGame.SelectSlot != self then
                inventoryGame.SetSelectItem(item)

                sound.EmitScreen("arc9_eft_shared/pistol_jam_slidelock_grab2.ogg")
            else
                sound.EmitScreen("arc9_eft_shared/weap_trigger_empty.wav",0.2,200)
            end
        end
    end
    
    inventoryGame.GrabSlot = self

    if self.OnMousePost then self:OnMousePost(key,value) end
end

function PANEL:OnMouseOut(key)
    local grabSlot = inventoryGame.GrabSlot
    if grabSlot != self then return end

    inventoryGame.GrabSlot = nil

    local hoverPanel = vgui.GetHoveredPanel()
    if hoverPanel == self then return end

    if key == MOUSE_LEFT and not grabSlot and grabSlot.cantSelectSlot then inventoryGame.SetSelectItem() end

    if not IsValid(grabSlot) or not grabSlot:GetItem() then return end
    
    if hoverPanel.CanMoveItem and hoverPanel:CanMoveItem(grabSlot) == false then return end

    if hoverPanel.GetItem then
        timer.Simple(math.Rand(0,0.01),function() inventoryGame.PlaySound(grabSlot:GetItem(),"InvMoveFromSnd",10)  end)
        timer.Simple(math.Rand(0.025,0.04),function() inventoryGame.PlaySound(hoverPanel:GetItem(),"InvMoveToSnd",10) end)

        count = (input.IsButtonDown(KEY_LCONTROL) or key == MOUSE_MIDDLE) and 1

        if key == MOUSE_MIDDLE and input.IsButtonDown(KEY_LSHIFT) then count = 2 end

        grabSlot:InvMove(hoverPanel,count)
    else
        self:InvDrop(not input.IsButtonDown(KEY_LCONTROL) and 1)
    end
end

hook.Add("DrawOverlay","Inv Grab",function()
    if not InitPostEntity then return end

    local grabSlot = inventoryGame.GrabSlot
    if not IsValid(grabSlot) then return end

    local item = grabSlot:GetItem()
    if not item then return end

    local mx,my = grabSlot:GetMousePos()
    local w,h = ScrW(),ScrH()

    if mx >= 0 and mx <= grabSlot:W() and my >= 0 and my <= grabSlot:H() then
        local x,y = grabSlot:LocalToScreen()

        render.SetViewPort(x,y,w,h)

        inventoryGame.DrawItemContent(item,grabSlot,x,y)

        render.SetViewPort(0,0,w,h)

        return
    end

    mx,my = gui.MouseX(),gui.MouseY()

    local size = grabSlot:W()

    mx = mx - size/2
    my = my - size/2

    surface.SetAlphaMultiplier(0.5)
    render.SetBlend(0.75)

    render.SetViewPort(mx,my,ScrW(),ScrH())

    inventoryGame.DrawItemContent(item,grabSlot,mx,my)

    render.SetViewPort(0,0,ScrW(),ScrH())

    surface.SetAlphaMultiplier(1)
    render.SetBlend(1)
end)