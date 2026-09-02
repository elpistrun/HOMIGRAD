local INV = oop.Reg("inv_player","inv_storage",true)
if not INV then return INCLUDE_BREAK end

local PLAYER = FindMetaTable("Entity")

function PLAYER:GetAutoItems()
    local items = {}

    local inv = self.inv

    if IsValid(inv) then
        for x = 1,#inv.slots do
            for y = 1,#inv.slots[1] do
                for depth,item in pairs(inv.slots[x][y].list) do
                    items[#items+1] = item
                end
            end
        end
    end

    local invDump = self.invDump

    if IsValid(invDump) then
        for x = 1,#invDump.slots do
            for y = 1,#invDump.slots[1] do
                for depth,item in pairs(invDump.slots[x][y].list) do
                    items[#items+1] = item
                end
            end
        end
    end

    return items
end