local ITEM,NoInherit = inventoryManager:ItemReg("base_use",nil,true)
if not ITEM then return INCLUDE_BREAK end

NoInherit.doNotShowInUI = true

ITEM.DefaultCountUse = 250

function ITEM:GetCountUse()
    return self.data.countUse or self.DefaultCountUse
end

if SERVER then return end

function ITEM:DrawCountUse(w,h,panel,desc)
    local k = 0
    local shakeX,shakeY = 0,0

    k = math.max((self.startShake or 0) - RealTime() + 0.6,0) / 0.6

    if k > 0 then
        shakeX,shakeY = math.Rand(-3,3) * k,math.Rand(-3,3) * k
    end

    if desc then
        draw.SimpleText("Осталось " .. self:GetCountUse() .. " использований","HS.25",w/2 + shakeX,h - 16 + shakeY,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    elseif panel.type != "shop" then
        draw.SimpleText("Осталось " .. self:GetCountUse(),"HS.12",w/2 + shakeX,8 + shakeY,nil,TEXT_ALIGN_CENTER)
    end
end

function ITEM:Update(old)
    if (old.data.countUse or self.DefaultCountUse) < self:GetCountUse() then return end

    self.startShake = RealTime()
    LocalPlayer():EmitSound("homigrad/vgui/panorama/case_unlock_immediate_01.wav",75,125,0.33)

    if self.UpdatePost then self:UpdatePost(old) end
end

function ITEM:SendUse()
    local success,err = self:NetUserRequest({cmd = "use"})
    
    if not success then
        self.errorStart = RealTime()
        self.error = err
    else
        donatPanel.startLockSpawnItem = RealTime()
    end
end