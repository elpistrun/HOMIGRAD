attachmentGame = attachmentGame or ManagerCreate("attachmentGame","node")

function attachmentGame.Init(self,classList)
    self.attachmentHooks = {}
    self.attachments = {}

    self.AttachmentSet = attachmentGame.AttachmentSet
    self.AttachmentCan = attachmentGame.AttachmentCan
    self.AttUpdate = attachmentGame.AttUpdate
    self.AttUpdateCall = attachmentGame.AttUpdateCall
end

function attachmentGame.AttachmentGetSlot(self,path,parent,value)
    local split = string.Split(path,".")
    
    parent = parent or self.MainAttachment
    if not parent then error("attachmentGame.AttachmentGetSlot parent or self.MainAttachment not exists") end
    
    local curretPath = ""

    for i = 1,#split do
        local step = split[i]
        curretPath = curretPath .. (i == 1 and "" or ".") .. step

        if not parent.slots then return false,nil,"parent.slots is null" end

        local newParent = parent.slots[step]
        if not newParent then return false,nil,"parent.slots[step] is null" end

        local key = self.attachments[curretPath]
        key = (curretPath == path and value and value.keyName) or key and key[1].keyName

        if not newParent.slots then return false,nil,"newParent.slots is null" end

        local slot = newParent.slots[key]
        if not slot then return false,nil,"newParent.slots[key] is null, key=" .. tostring(key) end

        if i == #split then return slot,newParent end

        parent = attachmentGame.config[slot[1]]

        if not parent then return false,nil,"attachmentGame.config[slot[1]] is null" end
    end

    return parent,parent
end

function attachmentGame.AttachmentValidate(self,path,value,parent)
    for path,key in pairs(self.attachments) do
        if key[3].canFunc then
            local success,err = key[3].canFunc(self,path,key)
            if success == false then return false,err or "AttachmentValidate error" end
        end
    end

    return true
end

function attachmentGame.AttachmentCan(self,path,value,parent)
    if TypeID(value) != TYPE_TABLE then value = {keyName = value} end

    local slot,slotParent,err = attachmentGame.AttachmentGetSlot(self,path,parent,value)
    if not slot then return false,nil,err end

    return slot,slotParent,err
end

local override = false

function attachmentGame.AttachmentSet(self,path,value,parent)
    if #string.Split(path,".") > 10 then error("stack overflow") end

    if TypeID(value) != TYPE_TABLE then value = {keyName = value} end
    
    local slot,slotParent,err = self:AttachmentCan(path,value,parent)

    if not slot then
        self.attachments[path] = nil
        
        return false,err
    end
    
    local split = string.Split(path,".")

    local parentPath

    for i = 1,#split - 1 do
        parentPath = (i == 1) and split[i] or (parentPath .. "." .. split[i])
    end

    local slotAtt = self.attachments[path]

    if not slotAtt then
        slotAtt = {}
        self.attachments[path] = slotAtt
    end
    
    local oldValue = slotAtt[1]

    slotAtt[1] = value and value or nil
    slotAtt[2] = slot
    slotAtt[3] = slotParent
    
    slotAtt.depth = #split
    slotAtt.path = path
    slotAtt.parentPath = parentPath
    slotAtt.parent = parentPath and self.attachments[parentPath] or nil

    if slot[1] then
        local att = attachmentGame.config[slot[1]]
        if not att then error("attachmentGame.AttachmentSet att " .. tostring(slot[1]) .. " is not exists") end

        if att.slots then
            for path2,slot in SortedPairs(att.slots) do
                attachmentGame.AttachmentSet(self,path .. "." .. path2,0)
            end
        end
    end

    if override then return true end

    local success,err = attachmentGame.AttachmentValidate(self,path)
    
    if not success then
        override = true
        attachmentGame.AttachmentSet(self,path,oldValue,parent)
        override = nil

        return false,err
    else
        return true
    end
end

local empty = {}

function attachmentGame.InitParse(self)
    for path in SortedPairs(self.MainAttachment.slots) do
        self:AttachmentSet(path,0)
    end

    for i,info in SortedPairs(self.AttachmentDefault or empty) do
        local success,err = self:AttachmentSet(info[1],info[2])

        if not success then print("attachmentGame.InitParse " .. tostring(info[1]) .. " " .. tostring(info[2]) .. " " .. err) end
    end

    if self.OnAttachmentUpdate then self:OnAttachmentUpdate() end
end

function attachmentGame.AttUpdate(self,id,funcInit,func,funcModel)
    self.attachmentHooks[id] = {funcInit,func,funcModel}
end

function attachmentGame.UpdateHooks(self)
    local attachmentHooks = self.attachmentHooks

    local class = GetClassFromName(self.ClassName)

    for id,info in pairs(attachmentHooks) do
        info[1](self,class)
    end

    for path,key in SortedPairs(self.attachments) do
        local slot = key[2]
        if not slot[1] then continue end

        for id,info in pairs(attachmentHooks) do
            info[2](self,attachmentGame.config[slot[1]],key)
        end
    end
end

function attachmentGame.CreateFakeSelfFromItem(self,item)
	for k in pairs(self.attachments) do self.attachments[k] = nil end

    for path in SortedPairs(self.MainAttachment.slots) do
        self:AttachmentSet(path,0)
    end

    if item.data then
        for path,key in SortedPairs(item.data.attachments or {}) do
            self:AttachmentSet(path,key)
        end
    end
end

function attachmentGame.ManualCreateEx(table,manual,vec,ang,source)
    local new = {}

    for path,att in pairs(manual) do
        att = util.tableCopy(att)
        
        att.vec,att.ang = LocalToWorld(att.vec or Vector(),att.ang or Angle(),vec,ang)

        new[path] = att

        if source then util.tableLink(att,source) end
    end

    util.tableLink(table,new)

    return new
end

function attachmentGame.IsData(attachments)
    if not attachments then return false end

    for path,key in SortedPairs(attachments) do
        if not key.path then return true end
    end

    return false
end

function attachmentGame.GetPkgData(attachments)
    if not attachments or attachmentGame.IsData(attachments) then return attachments end

    local pkg = {}

    for path,key in pairs(attachments) do
        pkg[path] = key[1]
    end

    return pkg
end

function attachmentGame.InputPkgData(self,pkg)
    if not pkg or not attachmentGame.IsData(pkg) then return pkg end
    
    local attachments = self.attachments

    for path,slot in SortedPairs(attachments) do
        if not pkg[path] then attachments[path] = nil end
    end

    for path,key in SortedPairs(pkg) do
        self:AttachmentSet(path,key)
    end
end

--[[if CLIENT then
    PrintTable(player.GetAll()[1]:GetActiveWeapon().attachments)
end]]--