local MUTATOR = Mutator_Reg("friction","gravity",true)
if not MUTATOR then return INCLUDE_BREAK end

MUTATOR.ResetWithRound = true

MUTATOR.Title = "mutator_friction"
MUTATOR.Desc = "mutator_friction_desc"
MUTATOR.Icon = Material("icon16/drive_web.png")

if SERVER then
    function MUTATOR:On()
        RunConsoleCommand("sv_friction",self:GetValue())
    end
    
    function MUTATOR:Off()
        RunConsoleCommand("sv_friction",GetConVar("sv_friction"):GetDefault())
    end

    MUTATOR:AddCMD("Value",function(self,ply,args)
        self:SetValue(tonumber(args[1] or GetConVar("sv_friction"):GetDefault()) or GetConVar("sv_friction"):GetDefault())
        if self:GetActive() then
            RunConsoleCommand("sv_friction",self:GetValue())
        end
    end)

    return
end

function MUTATOR:GetDescTextOnCursor()
    return {
        "friction: " .. GetConVar("sv_friction"):GetInt()
    }
end


function MUTATOR:CreateUI(page)
    self:CreatePanelEnabled(page)

    local slider = self:CreatePanelSlider(page,"Friction",nil,"Value")
    slider:SetMin(-100)
    slider:SetMax(100)
    slider.round = 10
    function slider.Step() if slider.startTimeChange + 1 < RealTime() then slider:SetValue(GetConVar("sv_friction"):GetFloat()) end end
end