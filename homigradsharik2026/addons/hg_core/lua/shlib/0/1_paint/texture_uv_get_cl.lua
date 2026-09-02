local mat_example = {
    ["$basetexture"] = "color/white",
    ["$model"] = 1,
    ["$vertexcolor"] = 1
}

function texture_uv.GetQuick(mdl,subID,textureName,tag)
    local texture = texture_uv.GetOriginal(textureName)
    
    local id = tag .. mdl.csmParentTag

    local rt,iteration = texture_uv.ClaimHashRT(textureName,id)

    local mat = CreateMaterial(textureName .. "_" .. iteration,"VertexLitGeneric",mat_example)
    mat:SetTexture("$basetexture",rt)
    
    texture_uv.CanvasClear(rt)

    mdl:SetSubMaterial(subID,"!" .. mat:GetName())
    mdl:CallOnRemove("ClearHashRT_" .. textureName,function() texture_uv.PopHashRT(textureName,id) end)

    return rt,iteration,id
end

function texture_uv.RemoveQuick(mdl,textureName,tag)
    local id = tag .. mdl.csmParentTag

    texture_uv.PopHashRT(textureName,id)
end