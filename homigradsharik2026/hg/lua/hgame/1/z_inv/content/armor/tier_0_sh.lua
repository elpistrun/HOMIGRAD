local INV = oop.Reg("inv_armor","inv_storage",true)
if not INV then return INCLUDE_BREAK end

INV.Size = {2,8}

--[[
    голова, лицо
    наушники, шея.

    торс, разгрузка,
    живот, рюкзак

    левое плево, правое плечо,
    левое запастье, правое запастье,

    левое бедро, правое бедро,
    левая ногна, правая нога
]]

local slotIndex = {
    head = {1,1},
    mask = {2,1},

    neck = {1,2},
    headset = {2,2},

    chest = {1,3},
    updump = {2,3},
    
    pelvis = {1,4},
    backpack = {2,4},

    left_forearm = {1,5},
    right_forearm = {2,5},

    left_arm = {1,6},
    right_arm = {2,6},

    left_thing = {1,7},
    right_thing = {2,7},

    left_leg = {1,8},
    right_leg = {2,8},
    other = {1,9}
}

function INV:GetPosBySlot(slotName)
    local info = slotIndex[slotName]
    if not info then return end

    return info[1],info[2]
end

function INV:GetArmorPos(armorName)
    for slotName in pairs(armorGame.config[armorName].slots) do
        local x,y = self:GetPosBySlot(slotName)
        if not x then continue end

        return x,y
    end
end

local slotIndexInverse = {}

for slotName,info in pairs(slotIndex) do
    local x,y = info[1],info[2]

    slotIndexInverse[x] = slotIndexInverse[x] or {}
    slotIndexInverse[x][y] = slotName
end

function INV:GetSlotByPos(x,y)
    return slotIndexInverse[x][y]
end

function INV:ParseSlotsBusy()
    local w,h = self:GetSize()

    local slotsBusyIndex = {}

    for i,item in pairs(self:GetAllItems()) do
        for slotName in pairs(armorGame.config[item.armorName or item.data.armorName].slots) do
            slotsBusyIndex[slotName] = true
        end
    end

    for x = 1,w do
        for y = 1,h do
            local slot = self.slots[x][y]
            slot.isBusy = slotsBusyIndex[self:GetSlotByPos(x,y)] and true or false
        end
    end
end