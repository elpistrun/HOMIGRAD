local active,oldActive,catchView

local addView = Angle()
local angZero = Angle()

local vecZero = Vector()

event.Add("PreCalcView","Alt Look",function(ply,view)
    if VRMODENABLED then catchView = nil return end

    if not (not ply:GetNWBool("Fake") and ply:IsSprinting()) then
        catchView = nil
        addView:Set(vecZero)

        return
    end

    active = ply:KeyDown(IN_WALK)

    if oldActive ~= active then
        oldActive = active

        if active then
            addView = Angle()
            catchView = ply:EyeAngles()
        else
            catchView = nil
        end
    end

    if not active then
        addView:LerpFT(0.25,angZero)

        if addView:Length() < 0.01 then addView:Set(angZero) end
    end
        
    view.ang:Sub(addView)
end,1)

hook.Add("CreateMove","Alt Look",function(cmd)
    if catchView then
        addView:Add(catchView - cmd:GetViewAngles())
        addView[1] = math.Clamp(addView[1],-90,90)
        addView[2] = math.Clamp(addView[2],-145,145)

        cmd:SetViewAngles(catchView)
    end
end)