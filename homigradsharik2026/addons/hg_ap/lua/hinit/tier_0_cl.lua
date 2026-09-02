hook.Add("InitPostEntity","AdminPanel Init",function()
    if not Initialize then return end

    timer.Simple(1,function()
        if IsValid(adminpanel_menu) then return end
        RunConsoleCommand("adminpanel_menu")
    end)
end)
