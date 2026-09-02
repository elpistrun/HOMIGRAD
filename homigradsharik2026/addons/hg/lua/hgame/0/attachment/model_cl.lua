local empty = {}
local mat_example = {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$vertexcolor"] = 1
}

local function getRT(wm,subMaterialID,id)
    local textureName = wm:GetMaterials()[subMaterialID + 1]
    local texture = texture_uv.GetOriginal(textureName)

    local id = "weapon_skin_" .. id .. "_" .. textureName

    local rt,iteration = texture_uv.ClaimHashRT(textureName,id)

    local mat = CreateMaterial(textureName .. "_" .. iteration,"VertexLitGeneric",mat_example)
    mat:SetTexture("$basetexture",rt)
    
    texture_uv.CanvasClear(rt)

    wm:SetSubMaterial(subMaterialID,"!" .. mat:GetName())
    wm:CallOnRemove("ClearHashRT_" .. textureName,function() texture_uv.PopHashRT(textureName,id) end)

    return rt,texture,textureName
end

local function apply_skin(key,wm,subMaterialID,objectID)
    subMaterialID = subMaterialID or 0

    local skinName = key[1].skin_0

    if skinName then
        local rt,texture,textureName = getRT(wm,subMaterialID,objectID)

        local layer = texture_uv.GetLayer(rt)

        local w,h = layer:Width(),layer:Height()
        render.PushRenderTarget(layer,0,0,w,h)
            texture_uv.Start()
            surface.SetMaterial(MaterialHash(attachmentGame.config_skin[skinName].material,"noclamp"))
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(0,0,w,h)
            texture_uv.End()
        render.PopRenderTarget()

        texture_uv.PaintTexture(rt,texture)
        texture_uv.PaintLayer(rt,layer,40)
    else
        wm:SetSubMaterial(subMaterialID,"")
    end

    if key[1].skin then
        local subMaterialList = {}

        for skinSlot,subMaterialID in pairs(key[3].skin) do
            local skinName = key[1].skin[skinSlot]

            local rt,texture,textureName = getRT(wm,subMaterialID,objectID)

            local layer = texture_uv.GetLayer(rt)

            if not subMaterialList[subMaterialID] then
                subMaterialList[subMaterialID] = {
                    layer = layer,--холст
                    texture = texture,--оригинальная текстура
                    rt = rt,--$basetexture материала

                    list = {}
                }
            end

            if not skinName then continue end

            texture_uv.PaintUV(layer,texture_uv.GetUV(textureName,skinSlot),MaterialHash(attachmentGame.config_skin[skinName].material,"noclamp"))
            
            subMaterialList[subMaterialID].list[layer] = true
        end

        for subMaterialID,info in pairs(subMaterialList) do
            local layer = info.layer
            local texture = info.texture
            local rt = info.rt

            texture_uv.PaintTexture(rt,texture)

            for layer in pairs(info.list) do
                texture_uv.PaintLayer(rt,layer,40)
            end
        end
    end
end

function attachmentGame.CreateAttachmentModel(self,wm,path,key,config)
    local slot = key[2]
    config = config or key[1].toggle and attachmentGame.config_toggle[slot[1]][key[1].toggle] or attachmentGame.config[slot[1]]
    
    local objectID = tostring(wm.csmContainerTag or "") .. wm.csmTag

    if path == "0" then apply_skin(key,wm,config,objectID) end
    
    if not config then return end

    local isWorldModel = wm.isWorldModel
    local container = wm.container
    
    local returnMDL

    local cosmeticName = key[1].cosmetic
    local cosmetic = cosmeticName and config.cosmetic[cosmeticName] or empty

    if config.model then
        local mdl,isCreate = wm.container.GetByID(cosmetic.model or config.model,wm.csmTag .. path,isWorldModel)
        returnMDL = mdl

        BonesManager_Init(mdl)

        if isCreate then
            mdl.renderTime = nil
            mdl.parent = wm
            mdl.localPos = vector_zero
            mdl.localAng = angle_zero
            mdl.isWorldModel = wm.isWorldModel

            if not isWorldModel then mdl:SetNoDraw(true) end
            mdl:DrawShadow(false)
        end

        mdl.path = path
        mdl.key = key
        
        local parentMDL = (slot.parentWM and wm) or wm.attachments[key.parentPath] or wm
        local boneName = slot.bone or config.bone or (wm == parentMDL and self.AttachmentBoneParent)

        if not IsValid(parentMDL) then return end

        local pos = (slot.vec or config.vec or Vector()):Clone()
        local ang = (slot.ang or config.ang or Angle()):Clone()

        mdl.parent = parentMDL
        mdl.followBone = boneName and parentMDL:LookupBone(boneName)

        mdl:SetParent(parentMDL)
        
        mdl.localPos = pos
        mdl.localAng = ang

        mdl:SetNoDraw(wm:GetNoDraw())

        if isWorldModel then key.mdl = mdl end

        if config.bodygroups then
            for id,set in pairs(config.bodygroups) do mdl:SetBodygroup(id,set) end
        end

        if config.size then
            mdl:EnableMatrixScale(config.size)
        end

        apply_skin(key,mdl,nil,objectID)

        wm.attachments[path] = mdl
        
        for id,info in pairs(self.attachmentHooks) do
            if info[3] then info[3](self,config,key,mdl) end
        end

        if config.modelCreate then config.modelCreate(wm,mdl) end
    else
        if config.subMaterialID then
            apply_skin(key,wm,config.subMaterialID,objectID)
        end
    end

    local bodygroupWM = cosmetic.bodygroupWM or config.bodygroupWM

    if bodygroupWM then
        wm:SetBodygroup(bodygroupWM[1],bodygroupWM[2])
    end

    return returnMDL
end