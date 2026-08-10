local INV = oop.Reg("inv_backpack","inv_storage",true)
if not INV then return INCLUDE_BREAK end

event.Add("Move","Backpack Mul",function(ply,mv)
    local maxspeed = mv:GetMaxSpeed()

    maxspeed = maxspeed * ply:GetNW2Float("BackpackMul",1)

    mv:SetMaxSpeed(maxspeed)
    mv:SetMaxClientSpeed(maxspeed)
end)