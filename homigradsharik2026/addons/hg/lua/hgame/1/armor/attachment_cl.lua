concommand.Add("hg_armor_attachment_menu",function(ply,cmd,args)
    armorGame.AttachmentMenu(args[1] and tostring(args[1]))
end)

armorGame:Event_Add("OnChangeEntity","AttachmentMenuArmor",function(ply,armor)
    if IsValid(AttachmentMenuArmor) then
        AttachmentMenuArmor:Update()
    end
end,1)

function armorGame.AttachmentMenu(armorNameSelect)
    if IsValid(AttachmentMenuArmor) then AttachmentMenuArmor:Remove() end

    if not armorNameSelect then
        for armorName,armorData in pairs(LocalPlayer().Armors.native) do
            if armorData.attachments then armorNameSelect = armorName break end
        end

        if not armorNameSelect then return end
    end

    local armorData = LocalPlayer().Armors.native[armorNameSelect]
    if not armorData then return end

    armorData.PrintName = armorGame.config[armorNameSelect].printName

    AttachmentMenuArmor = attachmentGame.CreatePanel({self = armorData,hideHands = true,hideCosmetic = true}):setSize(ScrW(),ScrH())
    AttachmentMenuArmor:MakePopup()
    AttachmentMenuArmor.armorName = armorNameSelect

    input.SetCursorPos(ScrW()/2,ScrH()/2)

    local exit = vCreate("v_button",AttachmentMenuArmor)
    exit:setSize(100,40)
    exit:setPos(32,32)

    function exit:Draw(w,h)
        draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackground)
        if self:IsHovered() then draw.RoundedBox(6,0,0,w,h,attachmentGame.colorBackgroundHovered2) end

        draw.SimpleText("EXIT","HS.12",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    function exit:OnClick()
        AttachmentMenuArmor:Remove()
    end

    AttachmentMenuArmor.DnAttachmentSet = function(path,pathVar)
        RunConsoleCommand("hg_armor_attachment_set",armorNameSelect,path,pathVar)
    end

    AttachmentMenuArmor.DoAttachmentSetCosmetic = function(path,cosmeticName)

    end
    
    AttachmentMenuArmor.DoAttachmentSetSkin = function(path,name)

    end
end

event.Add("PreDrawLocalPlayer","AttachmentMenuArmor",function()
    if not IsValid(AttachmentMenuArmor) then return end
    
    local k = AttachmentMenuArmor:GetK()
    surface.SetDrawColor(255,255,255,255)

    cam.Start2D()
        surface.SetDrawColor(0,0,0,240 * k)
        surface.DrawRect(0,0,ScrW(),ScrH())
        DrawBlur(6 * k,0,0)
    cam.End2D()

    render.SuppressEngineLighting(true)
    render.SetAmbientLight(255,255,255)
    render.SetLightingOrigin(LocalPlayer():GetPos())
    render.SetModelLighting(BOX_TOP,1,1,1)
end)

event.Add("RenderLocalPlayerHead","AttachmentMenuArmor",function(link)
    if IsValid(AttachmentMenuArmor) then return false end
end)

event.Add("RenderLocalPlayerModelPost","AttachmentMenuArmor",function()
    if not IsValid(AttachmentMenuArmor) then return end

    render.SuppressEngineLighting(false)
end)

event.Add("Player Death","AttachmentMenuArmor",function(ply)
    if ply == LocalPlayer() and IsValid(AttachmentMenuArmor) then AttachmentMenuArmor:Remove() end
end)

event.Add("PreCalcView","attachmentGame",function(ply,view)
    if ply != LocalPlayer() then return end

    if not IsValid(AttachmentMenuArmor) then return end
    if not LocalPlayer():Alive() then AttachmentMenuArmor:Remove() return end

    local ent = ply:GetDummy()

    local armorName = AttachmentMenuArmor.armorName

    local armorData = LocalPlayer().Armors.native[armorName]
    if not armorData then AttachmentMenuArmor:Remove() return end

    local ent = LocalPlayer():GetDummy()
    local armorConfig = armorGame.config[armorName]
    
    local mat = ent:GetBoneMatrix(ent:LookupBone(armorConfig.bone))

    local k = AttachmentMenuArmor:GetK()

    local eyeAng = AttachmentMenuArmor.angleRotate:Clone()

    eyeAng[1] = -eyeAng[1]

    view.fov = AttachmentMenuArmor.fov / Lerp(math.ease.InSine(k),1,5)
    view.vec:Lerp(k,mat:GetTranslation():Add(Vector(3,0,0):Rotate(mat:GetAngles())) - Vector(100,0,0):Rotate(eyeAng))
    view.ang:Lerp(k,eyeAng)

    return view
end,1)