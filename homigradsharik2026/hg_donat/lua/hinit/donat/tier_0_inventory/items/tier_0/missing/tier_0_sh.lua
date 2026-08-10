local ITEM,NoInherit = inventoryManager:ItemReg("missing","base",true)
if not ITEM then return INCLUDE_BREAK end

function ITEM:GetPrintName() return self.class end