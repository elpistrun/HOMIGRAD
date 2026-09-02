local SWEP = oop.Get("wep_lib_attachment")
if not SWEP then return end

function SWEP:OnNWTable_Attachments(tbl)
    if self.override then return end
    
    attachmentGame.InputPkgData(self,tbl)
    self:OnAttachmentUpdate()
end

SWEP.AttachmentMenuWeaponAngRotate = Angle(0,180,0)

function SWEP:AttachmentMenu_Open()
    if IsValid(AttachmentMenuWeapon) then AttachmentMenuWeapon:Remove() end

    AttachmentMenuWeapon = attachmentGame.CreatePanel({self = self}):setSize(ScrW(),ScrH())
    AttachmentMenuWeapon.angleRotate:Set(self.AttachmentMenuWeaponAngRotate)
    AttachmentMenuWeapon:MakePopup()
    input.SetCursorPos(ScrW()/2,ScrH()/2)

    AttachmentMenuWeapon.DnAttachmentSet = function(path,pathVar)
        RunConsoleCommand("hg_attachment_set",path,pathVar)
    end

    AttachmentMenuWeapon.DoAttachmentSetCosmetic = function(path,cosmeticName)
        RunConsoleCommand("hg_attachment_set_cosmetic",path,cosmeticName)
    end
    
    AttachmentMenuWeapon.DoAttachmentSetSkin = function(path,name)
        RunConsoleCommand("hg_attachment_set_skin",path,name or "none",tostring(AttachmentMenuWeapon.skinSlotSelect))
    end
end

function SWEP:AttachmentMenu_Close()
    if IsValid(AttachmentMenuWeapon) then AttachmentMenuWeapon:Remove() end
end

SWEP:Event_Add("Attachment Update","Menu",function(self)
    if self:IsLocal() and IsValid(AttachmentMenuWeapon) then AttachmentMenuWeapon:Update() end
end)

local old
SWEP:Event_Add("Think","Attachment",function(self)
    if not self:IsLocal() or GetViewEntity() != LocalPlayer() then return end

    if IsValid(AttachmentMenuWeapon) then
        if vgui.GetKeyboardFocus() != AttachmentMenuWeapon then return end
    else
        if IsValid(vgui.GetHoveredPanel()) or IsValid(vgui.GetKeyboardFocus()) or gui.IsGameUIVisible() then return end
    end

    local active = input.IsButtonDown(KEY_C)

    if old ~= active then
        old = active

        if active then
            if not IsValid(AttachmentMenuWeapon) then
                self:AttachmentMenu_Open()
            else
                self:AttachmentMenu_Close()
            end
        end
    end
end)

event.Add("Player Death","AttachmentMenuWeapon",function(ply)
    if ply == LocalPlayer() and IsValid(AttachmentMenuWeapon) then AttachmentMenuWeapon:Remove() end
end)

SWEP:Event_Add("Off","AttachmentMenu",function(self)
    if self:IsLocal() and IsValid(AttachmentMenuWeapon) then AttachmentMenuWeapon:Remove() end
end)

SWEP.AttachmentMenuWeaponVec = Vector(10,0,0)
SWEP.AttachmentMenuWeaponAng = Angle()

function SWEP:SetupBones_Finish(tpikMatrix,Pos,Ang)
    if not self:IsLocal() or not IsValid(AttachmentMenuWeapon) then return end

    local k = AttachmentMenuWeapon:GetK()

    local eyePos,eyeAng = LocalPlayer():Eye()

    eyePos:Add(self.AttachmentMenuWeaponVec:Clone():Rotate(eyeAng))

    tpikMatrix.wm.anchorPos = eyePos:Clone()

    eyeAng[1] = 0

    eyeAng:Rotate(self.AttachmentMenuWeaponAng * k)

    self:Transform_GetCenter(eyePos,eyeAng)
    
    Pos:Lerp(k,eyePos)
    Ang:Lerp(k,eyeAng)
end

SWEP.AttachmentMenuWeaponCenter = Vector(100,0,0)

function SWEP:CalcViewAttachmentMenu(ply,view)
    if not self:IsLocal() or not IsValid(AttachmentMenuWeapon) then return end

    local k = AttachmentMenuWeapon:GetK()

    local anchorPos = self.wm.anchorPos
    local wmAngle = self.wm:GetAngles()

    local vecCenter = self.AttachmentMenuWeaponCenter

    view.vec:Lerp(k,anchorPos + Vector(vecCenter[1],0,0):Mul(k):Rotate(wmAngle + AttachmentMenuWeapon.angleRotate))
    view.ang:Lerp(k,(anchorPos - view.vec):Angle())

    view.vec:Add(Vector(0,AttachmentMenuWeapon.screenX * 25 + vecCenter[2],-AttachmentMenuWeapon.screenY * 25 + vecCenter[3]):Rotate(wmAngle + AttachmentMenuWeapon.angleRotate))
    view.fov = AttachmentMenuWeapon.fov / Lerp(math.ease.InSine(k),1,5)

    return view
end

event.Add("PreDrawLocalPlayer","!AttachmentMenuWeapon",function()
    if not IsValid(AttachmentMenuWeapon) then return end
    
    local k = AttachmentMenuWeapon:GetK()
    surface.SetDrawColor(255,255,255,255)
    
    cam.Start2D()
        surface.SetDrawColor(0,0,0,240 * k)
        surface.DrawRect(0,0,ScrW(),ScrH())
        DrawBlur(16 * k,0,0)
    cam.End2D()
    
    render.SuppressEngineLighting(true)
    render.SetAmbientLight(255,255,255)
    render.SetLightingOrigin(LocalPlayer():GetPos())
    render.SetModelLighting(BOX_TOP,1,1,1)
end)

event.Add("RenderLocalPlayerModel","AttachmentMenuWeapon",function()
    if not IsValid(AttachmentMenuWeapon) then return end

    cam.IgnoreZ(true)
    if AttachmentMenuWeapon.hideHandsMode then RenderPlayer_Weapon(LocalPlayer():GetDummy(),nil,LocalPlayer()) return false end
end)

event.Add("RenderLocalPlayerModelPost","AttachmentMenuWeapon",function()
    if not IsValid(AttachmentMenuWeapon) then return end

    cam.IgnoreZ(false)
    render.SuppressEngineLighting(false)
end)

event.Add("RenderLocalPlayerHead","AttachmentMenuWeapon",function(link)
    if IsValid(AttachmentMenuWeapon) then return false end
end)

if Initialize then
    timer.Simple(0,function()
        local wep = LocalPlayer():GetActiveWeapon()
        if not IsValid(wep) or not wep.AttachmentMenu_Open then return end

        --wep:AttachmentMenu_Open()
    end)
end

local color_gray = Color(128,128,128,128)

function SWEP:InvSelectPanelDrawOver(w,h,icon,item)
    DisableClipping(true)
    draw.SimpleText("НАЖМИТЕ 'C' В ИГРЕ, ЧТО-БЫ МОДИФИЦИРОВАТЬ","H.12",w/2,h + 6,color_gray,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
    DisableClipping(false)
end

SWEP:Event_Add("CreateFakeSelfFromItem","Attachment",function(self,item)
    attachmentGame.CreateFakeSelfFromItem(self,item)
end)

function SWEP:CreateWorldModelPostAttachment(wm,tag,typeDraw,depth)
    wm.attachments = {}

    for i = 0,wm:GetNumBodyGroups() do wm:SetBodygroup(i,0) end
    
    for path,key in SortedPairs(self.attachments) do
        if depth and key.depth > depth then continue end

        local mdl = attachmentGame.CreateAttachmentModel(self,wm,path,key)

        local config = attachmentGame.config[key[2][1]]
        if config and config.tpikLeft then mdl.needUpdateBones = true end
    end
end

SWEP:Event_Add("Attachment Update","WorldModel",function(self)
    local wm = self.wm

    if IsValid(wm) then
        --[[for path,key in SortedPairs(self.attachments) do
            if IsValid(wm.attachments[path]) then wm.container.Remove(wm.attachments[path]) end
        end

        for path,key in SortedPairs(self.attachments) do
            attachmentGame.CreateAttachmentModel(self,wm,path,key)
        end]]--

        self:RemoveWM()
        self:GetWorldModel()
    end
end,99)