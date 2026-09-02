attachmentGame.config_skin = attachmentGame.config_skin or {}
attachmentGame.category_skin = attachmentGame.category_skin or {}

function attachmentGame.RegSkin(name,data)
    local att = classFastManager.Reg(attachmentGame.config_skin,nil,attachmentGame.category_skin,name,data)

    if Initialize then timer.Create("attachmentGame.Update",0,1,function() event.Call("AttachmentGameUpdate") end) end

    local basetextureName = Material(data.material):GetName()
    data.materialName = basetextureName

    return att
end

function attachmentGame.RegSkinCategory(name,data)
    return classFastManager.RegCategory(attachmentGame.category_skin,name,data)
end

attachmentGame.RegSkinCategory("other",{printName = "Разное",prio = 10})
attachmentGame.RegSkinCategory("stickers",{printName = "Stickers",icon = "homigrad/vgui/icons/weapon_skin_category/stickers.png"})
attachmentGame.RegSkinCategory("tactical",{printName = "Tactical",icon = "homigrad/vgui/icons/weapon_skin_category/tactical.png"})

attachmentGame.RegSkin("tactical_desert_camo",{
    printName = "Desert Camo",
    desc = "Для засушливых регионов или песчаных дюн",
    material = "homigrad/weapon_skins/tactical/desert_camo.png",
    category = "tactical"
})

attachmentGame.RegSkin("tactical_digital_green_woodland",{
    printName = "Digital Woodland / MARPAT",
    desc = "Современый стандарт для лестной местности",
    material = "homigrad/weapon_skins/tactical/digital_green_woodland.png",
    category = "tactical"
})

attachmentGame.RegSkin("tactical_multicam_fox",{
    printName = "MultiCam FOX",
    desc = "Один из инуверсальных камуфляжов, предназначен для лесов и перелесков",
    material = "homigrad/weapon_skins/tactical/multicam_fox.png",
    category = "tactical"
})

attachmentGame.RegSkin("tactical_navy_camo",{
    printName = "Navy Camo",
    desc = "Navy / Blue Camo\nМорской тип камуфляжа",
    material = "homigrad/weapon_skins/tactical/navy_camo.png",
    category = "tactical"
})

attachmentGame.RegSkin("tactical_purple_fantasy",{
    printName = "Purple Fantasy",
    desc = "Фантастический розовый камуфляж\nВообще никак не маскирует, если только вы не находитесь в розовом мире...",
    material = "homigrad/weapon_skins/tactical/purple_fantasy.png",
    category = "tactical"
})

attachmentGame.RegSkin("tactical_urban_camo",{
    printName = "Urban Camo",
    desc = "Городской тип камуфляжа",
    material = "homigrad/weapon_skins/tactical/urban_camo.png",
    category = "tactical"
})

attachmentGame.RegSkin("hentai",{
    printName = "hentai",
    desc = "uff",
    material = "homigrad/weapon_skins/anime/hentai/3/main.png",
    category = "stickers"
})

attachmentGame.RegSkin("sticker_1",{
    printName = "skin_stickers_1",
    desc = "",
    material = "homigrad/weapon_skins/stickers/1.png",
    category = "stickers"
})

attachmentGame.RegSkin("sticker_2",{
    printName = "skin_stickers_2",
    desc = "",
    material = "homigrad/weapon_skins/stickers/2.png",
    category = "stickers"
})

attachmentGame.RegSkin("sticker_3",{
    printName = "skin_stickers_3",
    desc = "",
    material = "homigrad/weapon_skins/stickers/3.png",
    category = "stickers"
})