attachmentGame.config_cosmetic = attachmentGame.config_cosmetic or {}
attachmentGame.category_cosmetic = attachmentGame.category_cosmetic or {}

function attachmentGame.RegCosmetic(name,data)
    local att = classFastManager.Reg(attachmentGame.config_cosmetic,nil,attachmentGame.category_cosmetic,name,data)

    if Initialize then timer.Create("attachmentGame.Update",0,1,function() event.Call("AttachmentGameUpdate") end) end

    return att
end

function attachmentGame.RegCosmeticCategory(name,data)
    return classFastManager.RegCategory(attachmentGame.category_cosmetic,name,data)
end

attachmentGame.RegCosmeticCategory("other",{name = "Разное",prio = 10})