local PANEL = oop.Reg("v_inv_slot",{"v_panel"},true)
if not PANEL then return INCLUDE_BREAK end

PANEL:Event_Add("Init","Inv",function(self)
    self.hovered = 0
    
    self.slotX = 1
    self.slotY = 1

    self.inv = {
        slots = {
            [1] = {
                [1] = {list = {}}
            }
        }
    }
end)

function PANEL:SetInventory(inv,x,y)
    self.inv = inv--inv ссылается на настоящий customEntity объект

    self.slotX = x
    self.slotY = y

    local slot = inv.slots[x][y]

    slot.panel = self
    self.slot = slot
end

function PANEL:GetItem(depth)
    return self.inv.slots[self.slotX][self.slotY].list[depth or 1]
end

function PANEL:SetItem(item)
    if IsValid(self.inv) then error("v_inv_slot:SetItem-> self.inv is valid object") end

    self.inv.slots[self.slotX][self.slotY].list[1] = item
end

function PANEL:GetCount()
    return #self.inv.slots[self.slotX][self.slotY].list
end

function PANEL:GetItemTable(name)
    name = name or self:GetItem()

    if TypeID(name) == TYPE_TABLE then
        name = name.spawnname
    end

    return GetClassFromName(name)
end

keyboard.DefaultBindCode("inv_fastmove",KEY_H,true,function() return false end)

function PANEL:Think()
    local active = input.IsButtonDown(keyboard.GetBindCode("inv_fastmove"))

    if self:IsHovered() then
        if self.keyDownH != active then
            self.keyDownH = active

            if active then
                if self.UserInputFast then self:UserInputFast() end
            end
        end
    else
        self.keyDownH = nil
    end
end

--[[function PANEL:UpdateFromInventory(pkg)
    if self.wait == 0 then self.wait = nil end
    
    if self.OnUpdateFromInventory then self:OnUpdateFromInventory(pkg) end
end]]--

function PANEL:InvDrop()
    local slot = self.slot
    if slot.wait then return end

    local inv = slot.inv
    inv:SetWait(slot,0)

    inv:SendCommand(function()
        inv:SetWait(slot,inventoryGame.DelayMove)

        inventoryGame.PlaySound(self:GetItem(),"InvMoveFromSnd",-10,-0.1)

        inventoryGame.SendDrop(slot.inv.id,slot.x,slot.y)

        inv:SetWait(slot)
    end,function()
        inv:SetWait(slot)
    end,ply,inventoryGame.DelayMove)
end

function PANEL:InvMove(slotTo,count)
    local slot = self.slot
    if slot.wait then return end

    local inv = slot.inv
    inv:SetWait(slot,0)

    slotTo = slotTo.slot

    inv:SendCommand(function()
        inv:SetWait(slot,inventoryGame.DelayMove)

        inventoryGame.SendMove(slot.inv.id,slot.x,slot.y,slotTo.inv.id,slotTo.x,slotTo.y,count)
        
        inv:SetWait(slot)
    end,function()
        inv:SetWait(slot)
    end,ply,inventoryGame.DelayMove)
end

local delay = 0
local addition = 0

function PANEL:UserInputFast()
    local slot = self.slot
    if slot.wait or not slot.list[1] then return end

    local inv = slot.inv
    inv:SetWait(slot,0)

    if delay + 0.2 > RealTime() then
        addition = addition + 2
    else
        addition = 0
    end

    delay = RealTime()

    sound.EmitScreen("weapons/eft/bipod/bipod_atlas_fold_" .. math.random(1,2) .. ".ogg",0.33,math.random(100,102) + addition)
    inventoryGame.PlaySoundDecay(self:GetItem(),"InvMoveFromSnd",20,-0.1)

    inv:SendCommand(function()
        inventoryGame.PlaySoundDecay(self:GetItem(),"InvMoveToSnd",10,-0.1)
        sound.EmitScreen("weapons/eft/bipod/bipod_atlas_fold_" .. math.random(1,2) .. ".ogg",0.33,math.random(140,142))

        inv:SetWait(slot,inventoryGame.DelayFastMove)

        inventoryGame.SendFastMove(inv.id,slot.x,slot.y)
        
        inv:SetWait(slot)
    end,function()
        inv:SetWait(slot)
    end,ply,inventoryGame.DelayFastMove)
end

function PANEL:NetInteractiveStart()
    inventoryGame.NetInteractiveStart(self.slot.inv.id,self.slot.x,self.slot.y)
end