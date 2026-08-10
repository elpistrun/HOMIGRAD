attachmentGame.config = attachmentGame.config or {}
attachmentGame.config_toggle = attachmentGame.config_toggle or {}
attachmentGame.category = attachmentGame.category or {}

function attachmentGame.Reg(name,data)
    local att = classFastManager.Reg(attachmentGame.config,attachmentGame.config_toggle,attachmentGame.category,name,data)

    if Initialize then timer.Create("attachmentGame.Update",0,1,function() event.Call("AttachmentGameUpdate") end) end

    return att
end

WepAtt = attachmentGame.Reg

function attachmentGame.RegCategory(name,data)
    return classFastManager.RegCategory(attachmentGame.category,name,data)
end

attachmentGame.RegCategory("other",{name = "Разное",prio = 10})

attachmentGame.manual = attachmentGame.manual or {}

function attachmentGame.ManualReg(name,manual)
    if not attachmentGame.manual[name] then
        attachmentGame.manual[name] = manual
    else
        util.tableLink(attachmentGame.manual[name],manual)
    end
end

function attachmentGame.ManualRegEx(name,manual)
    attachmentGame.manual[name] = attachmentGame.manual[name] or manual
end

function attachmentGame.ManualCreate(table,name,vec,ang,source)
    return attachmentGame.ManualCreateEx(table,attachmentGame.manual[name],vec,ang,source)
end

function attachmentGame.GetConfig(name,toggleName)
    return attachmentGame.config_toggle[name][toggleName or 0]
end

if CLIENT then
    if cacheModelList then cacheModelList.AddByTreeFolder("models/weapons/arc9/") end
end