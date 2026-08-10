local INV = oop.Reg("inv_base",{"lib_event","custom_entity","custom_network"},true)
if not INV then return INCLUDE_BREAK end

INV:Event_Add("Create","Main",function(self)
    self:SetList("inv",true)
    self:SetList("think",true)
    
    self.slots = {}
end,-100)

function INV:Think()
    if SERVER then
        self:ServerThink()
        self:EntsThink()
    end
end

if SERVER then
    INV.ServerThink = function() end
end

function INV:ChangeSlots(w,h)
    local isChange

    for x = 1,w do//Create
        if not self.slots[x] then self.slots[x] = {} isChange = true end

        for y = 1,h do
            if self.slots[x][y] then continue end

            local slot = {
                list = {},
                inv = self,
                x = x,
                y = y,
            }

            self.slots[x][y] = slot
        end
    end

    local w2,h2 = self:GetSize()

    for x = 1,w2 do//Delete
        if x > w then self.slots[x] = nil isChange = true continue end

        for y = 1,h2 do
            if y > h then self.slots[x][y] = nil isChange = true end
        end
    end

    return isChange
end

local empty = {}

function inventoryGame.GetSafeInvsFromEntity(ent)
    for inv in pairs(ent.invListIndex or empty) do
        if not IsValid(inv) then ent.invListIndex[inv] = nil end
    end

    return ent.invListIndex or empty
end