local MUTATOR = Mutator_Reg("nextbot","base",true)
if not MUTATOR then return INCLUDE_BREAK end

MUTATOR.Title = "mutator_nextbot"
MUTATOR.Desc = "mutator_nextbot_desc"
MUTATOR.Icon = Material("icon16/tux.png")

function MUTATOR:SetupVars()
    self:SetupVar("ScanDistance")
    self:SetupVar("KillCount")
    self:SetupVar("SleepTime")
    self:SetupVar("Speed")
end

function MUTATOR:CreateUI(page)
    self:CreatePanelEnabled(page)

    local slider = self:CreatePanelSlider(page,"ScanDistance",nil,"ScanDistance")
    slider:SetMin(0)
    slider:SetMax(16000)

    local slider = self:CreatePanelSlider(page,"KillCount",nil,"KillCount")
    slider:SetMin(1)
    slider:SetMax(10)

    local slider = self:CreatePanelSlider(page,"SleepTime",nil,"SleepTime")
    slider:SetMin(0)
    slider:SetMax(600)

    local slider = self:CreatePanelSlider(page,"SpeedMul",nil,"Speed")
    slider:SetMin(0)
    slider:SetMax(1)
    slider.round = 100
end