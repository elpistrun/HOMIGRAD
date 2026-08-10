attachmentGame.config_sticker = attachmentGame.config_sticker or {}
attachmentGame.category_sticker = attachmentGame.category_sticker or {}

function attachmentGame.RegSticker(name,data)
    local att = classFastManager.Reg(attachmentGame.config_sticker,nil,attachmentGame.category_sticker,name,data)

    if Initialize then timer.Create("attachmentGame.Update",0,1,function() event.Call("AttachmentGameUpdate") end) end

    return att
end

function attachmentGame.RegStickerCategory(name,data)
    return classFastManager.RegCategory(attachmentGame.category_sticker,name,data)
end

attachmentGame.RegStickerCategory("other",{name = "Разное",prio = 10})