net.Receive("hg_inventory_sync",function()
    local pkg = net.ReadTable()
    if not istable(pkg) or not CustomEntity_InputPKG then return end
    CustomEntity_InputPKG(pkg)

    -- The scoreboard can be opened before the inventory objects arrive. Once
    -- the armor inventory has constructed its local panel, reopen an empty
    -- inventory page automatically instead of requiring a tab round-trip.
    if pkg.class == "inv_armor" or pkg.parentEntIndex == LocalPlayer():EntIndex() then
        timer.Create("HG Inventory Page Ready",0.05,20,function()
            if not inventoryGame.local_inv_armor then return end
            timer.Remove("HG Inventory Page Ready")

            if not scoreboard or scoreboard.curretPage ~= 2 or not scoreboard.status then return end
            if scoreboard:PageIsCreated(2) then return end
            scoreboard:OpenPage(2,true)
        end)
    end
end)
