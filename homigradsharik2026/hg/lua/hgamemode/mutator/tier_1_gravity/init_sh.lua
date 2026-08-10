local MUTATOR = Mutator_Reg("gravity","base",true)
if not MUTATOR then return INCLUDE_BREAK end

MUTATOR.ResetWithRound = true

MUTATOR.Title = "mutator_gravity"
MUTATOR.Desc = "mutator_gravity_desc"
MUTATOR.Icon = Material("icon16/drive.png")

function MUTATOR:SetupVars()
    self:SetupVar("Value")
end

if SERVER then
    MUTATOR.ConVarName = "sv_gravity"
    
    function MUTATOR:On()
        RunConsoleCommand("sv_gravity",self:GetValue())
    end
    
    function MUTATOR:Off()
        RunConsoleCommand("sv_gravity",GetConVar("sv_gravity"):GetDefault())
    end

    MUTATOR:AddCMD("Value",function(self,ply,args)
        self:SetValue(tonumber(args[1] or GetConVar("sv_gravity"):GetDefault()) or GetConVar("sv_gravity"):GetDefault())
        if self:GetActive() then
            RunConsoleCommand("sv_gravity",self:GetValue())
        end
    end)

    return
end

function MUTATOR:GetDescTextOnCursor()
    return {
        "gravity: " .. GetConVar("sv_gravity"):GetInt()
    }
end

function MUTATOR:CreateUI(page)
    self:CreatePanelEnabled(page)

    local slider = self:CreatePanelSlider(page,"Gravity",nil,"Value")
    slider:SetMin(-16000)
    slider:SetMax(16000)
    function slider.Step() if slider.startTimeChange + 1 < RealTime() then slider:SetValue(GetConVar("sv_gravity"):GetFloat()) end end
end
