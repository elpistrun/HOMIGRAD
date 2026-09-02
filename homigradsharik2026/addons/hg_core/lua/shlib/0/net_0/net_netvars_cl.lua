net.Receive("netvar_fast",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end//lox

    local data = net.ReadTable()
    
    ent["SetNW" .. data[1]](ent,data[2],data[3])
end)//боже блядь какой кринж но это работает