local ITEM = inventoryManager:ItemReg("conventor","base",true)
if not ITEM then return INCLUDE_BREAK end

ITEM.type = "3_icons"

function ITEM:GetPrintName()
    return "Конвертатор"
end

function ITEM:GetRaryType()
    return "rary"
end

ITEM.DefaultUses = 50

function ITEM:GetCountUse()
    return self.data.countUse or self.DefaultUses
end

function ITEM:GetDesc()
    return "Конвертирует донат валюту в игровую"
end

function DonatItem_CanReceive(item)
    if item.CanReceive then return item:CanReceive() end

    return true
end

function ITEM:CanReceive() return false end

if SERVER then return end

local startShake

function ITEM:DrawObject(w,h,panel,desc)
    local mdl = self:GetCSM("models/props_c17/tools_vise01a.mdl")

    self:OpenScene(w,h,panel,20)
        mdl:SetPos(Vector(40,0,-6))
        mdl:SetAngles(Angle(25,45,0))
        mdl:DrawModel()
    self:CloseScene(w,h,panel)

    local k = math.max((startShake or 0) - RealTime() + 0.6,0) / 0.6

    local shakeX,shakeY = math.Rand(-3,3) * k,math.Rand(-3,3) * k

    if desc then
        draw.SimpleText("Осталось " .. self:GetCountUse() .. " использований","HS.25",w/2 + shakeX,h - 16 + shakeY,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    elseif panel.type != "shop" then
        draw.SimpleText("Осталось " .. self:GetCountUse(),"HS.12",w/2 + shakeX,8 + shakeY,nil,TEXT_ALIGN_CENTER)
    end
end

local wait

function ITEM:CreateDescPanel(panel)

end

event.Add("Donat Inventory Sync","UI Item Receiver",function()
    if wait then
        wait = nil
        startShake = RealTime()

        LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_contract_seal.wav")
    end
end)