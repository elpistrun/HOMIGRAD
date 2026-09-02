concommand.Add("hg_dev_get_matrixhand",function(ply)
    local wep = ply:GetActiveWeapon()

    local handEnt = wep:GetNWEntity("HandEntity")
    local handNum = wep:GetNWEntity("HandNum") == 0 and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand"

    local prefix = handNum == "ValveBiped.Bip01_R_Hand" and "R" or "L"

    local mat = handEnt:GetBoneMatrix(handEnt:LookupBone(handNum)):GetInverse()

    local finger42 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger42"))
    local finger41 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger41"))
    local finger4 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger4"))

    local finger32 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger32"))
    local finger31 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger31"))
    local finger3 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger3"))

    local finger22 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger22"))
    local finger21 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger21"))
    local finger2 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger2"))

    local finger12 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger12"))
    local finger11 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger11"))
    local finger1 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger1"))

    local finger02 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger02"))
    local finger01 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger01"))
    local finger0 = handEnt:GetBoneMatrix(handEnt:LookupBone("ValveBiped.Bip01_" .. prefix .. "_Finger0"))

    local function writeTable(mat)
        mat = mat:ToTable()

        return [[Matrix({
            {]] .. mat[1][1] .. "," .. mat[1][2] .. "," .. mat[1][3] .. "," .. mat[1][4] .. [[},
            {]] .. mat[2][1] .. "," .. mat[2][2] .. "," .. mat[2][3] .. "," .. mat[2][4] .. [[},
            {]] .. mat[3][1] .. "," .. mat[3][2] .. "," .. mat[3][3] .. "," .. mat[3][4] .. [[},
            {]] .. mat[4][1] .. "," .. mat[4][2] .. "," .. mat[4][3] .. "," .. mat[4][4] .. [[},
        }),]]
    end

    local text = ""

    if finger42 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger42"] = ]] .. writeTable(mat * finger42) .. "\n" end
    if finger41 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger41"] = ]] .. writeTable(mat * finger41) .. "\n" end
    if finger4 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger4"] = ]] .. writeTable(mat * finger4) .. "\n" end

    if finger32 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger32"] = ]] .. writeTable(mat * finger32) .. "\n" end
    if finger31 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger31"] = ]] .. writeTable(mat * finger31) .. "\n" end
    if finger3 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger3"] = ]] .. writeTable(mat * finger3) .. "\n" end

    if finger22 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger22"] = ]] .. writeTable(mat * finger22) .. "\n" end
    if finger21 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger21"] = ]] .. writeTable(mat * finger21) .. "\n" end
    if finger2 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger2"] = ]] .. writeTable(mat * finger2) .. "\n" end

    if finger12 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger12"] = ]] .. writeTable(mat * finger12) .. "\n" end
    if finger11 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger11"] = ]] .. writeTable(mat * finger11) .. "\n" end
    if finger1 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger1"] = ]] .. writeTable(mat * finger1) .. "\n" end

    if finger02 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger02"] = ]] .. writeTable(mat * finger02) .. "\n" end
    if finger01 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger01"] = ]] .. writeTable(mat * finger01) .. "\n" end
    if finger0 then text = text .. [[["ValveBiped.Bip01_]] .. prefix .. [[_Finger0"] = ]] .. writeTable(mat * finger0) .. "\n" end

    SetClipboardText(text)
end)

concommand.Add("hg_dev_get_materials",function(ply,cmd,args,line)
    local mdl = ClientsideModel(line)
    
    for i,path in pairs(mdl:GetMaterials()) do
        print(i,Material(path):GetTexture("$basetexture"):GetName())
    end

    mdl:Remove()
end)