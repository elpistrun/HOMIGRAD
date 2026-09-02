classFastManager.SpawnmenuNode({
    name = "Снарежение",
    category = armorGame.category,
    ent = "item_armor",

    contentSort = function(a,b) return (a.ratedJoules or 0) > (b.ratedJoules or 1) end,

    onCreateContentIcon = function(icon,config)
        function icon:PaintOver(w,h)
            draw.SimpleText(config.armorTier or 0,"HS.12",10,8)
            if self:IsHovered() then vgui.DrawTip(armorGame.GetTipText(nil,config)) end
        end
    end
})
