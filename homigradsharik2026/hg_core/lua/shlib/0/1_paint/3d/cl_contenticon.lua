local white = Color(255,255,255)

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)
local cameraPos,cameraAng
local angRotate = Angle(0,0,0)

local cam_Start3D = cam.Start3D

local render_SetLightingOrigin = render.SetLightingOrigin
local render_ResetModelLighting = render.ResetModelLighting
local render_SetColorModulation = render.SetColorModulation
local render_SetModelLighting = render.SetModelLighting
local render_SuppressEngineLighting = render.SuppressEngineLighting

local cam_IgnoreZ = cam.IgnoreZ

local cam_End3D = cam.End3D

local ClientsideModel = ClientsideModel
local RealTime = RealTime

local function PrintWeaponInfo(self,x,y,alpha)
	if self.DrawWeaponInfoBox == false then return end

	if self.InfoMarkup == nil then
		local str
		local title_color = "<color=230,230,230,255>"
		local text_color = "<color=150,150,150,255>"

		str = "<font=HudSelectionText>"
		--if self.Author != "" then str = str .. title_color .. L("weapon_author") .. ":</color>\t"..text_color..self.Author.."</color>\n" end
		--if ( self.Contact != "" ) then str = str .. title_color .. "Contact:</color>\t"..text_color..self.Contact.."</color>\n\n" end
		--if ( self.Purpose != "" ) then str = str .. title_color .. "Purpose:</color>\n"..text_color..self.Purpose.."</color>\n\n" end
		--if self.Instructions != "" then str = str .. title_color .. L("weapon_instruction") .. ":</color>\t" .. text_color .. L(self.Instructions) .. "</color>\n" end
		str = str .. "</font>"

		self.InfoMarkup = markup.Parse(str,250)
	end

	--surface.DrawTexturedRect(x,y - 64 - 5,128,64)
	draw.RoundedBox(0,x,y,260,self.InfoMarkup:GetHeight() + 2,Color(60,60,60,alpha))

	self.InfoMarkup:Draw(x + 5,y,nil,nil,alpha)
end

local white = Color(255,255,255)

local empty = {}

render.WeaponIconMatrix = render.WeaponIconMatrix or {}
local WeaponIconMatrix = render.WeaponIconMatrix

function render.ClearWeaponIcon()
    for k,v in pairs(WeaponIconMatrix) do WeaponIconMatrix[k] = nil end
end

function render.DrawWeaponIcon()
    local self = WeaponIconMatrix.self
    local x,y,wide,tall = WeaponIconMatrix.x,WeaponIconMatrix.y,WeaponIconMatrix.w,WeaponIconMatrix.h
    local addFov,Pos,Ang = WeaponIconMatrix.addFov,WeaponIconMatrix.Pos,WeaponIconMatrix.Ang

    local cameraPos = self.dwsPos or _cameraPos

    local lightColor = WeaponIconMatrix.lightColor or white
    local lightSide = WeaponIconMatrix.lightSide

    local wm

    local tag = WeaponIconMatrix.tag
    
    if self.InitWorldModelContent then
        wm = self:InitWorldModelContent(tag)
    else
        if not self.WorldModel or self.WorldModel == "" then return end//fuck you!

        wm = CSM.GetByID(self.WorldModel,"contentIcon" .. (tag or ""))
        wm:SetModel(self.WorldModel)
        wm:SetNoDraw(true)
        wm:SetMaterial(self.WorldMaterial)
        wm:SetSkin(self.WorldSkin or 0)
    end

    if not IsValid(wm) then return end

    render_SetColorModulation(1,1,1)

    if self.ApplySequenceOnWorldModel then self:ApplySequenceOnWorldModel(wm) end

    Pos = Pos or (self.GetDWSPos and self:GetDWSPos() or self.dwsPos or Vector())
    Ang = Ang or (self.GetDWSAng and self:GetDWSAng() or self.dwsAng or Angle())

    Ang = Ang:Clone()
    Pos = Pos:Clone()

    local cameraPos = WeaponIconMatrix.focusOnPos and Vector(150,150,60) or Vector(0,0,0)

    cam_Start3D(cameraPos,WeaponIconMatrix.focusOnPos and (-(cameraPos)):Angle() or (-Vector(0,Pos[2],0)):Angle() + Angle(0,180,0),20 + (self.dwsFOV or 0) + (addFov or 0),x,y,wide,tall)
        render_SuppressEngineLighting(true)

        render_SetLightingOrigin(vecZero)
        render_ResetModelLighting(50 / 255,50 / 255,50 / 255)
        render_SetModelLighting(lightSide or 4,lightColor.r / 255,lightColor.g / 255,lightColor.b / 255)
        
       // self:ApplyCenterPosWM(wm,nil,Pos,Ang)

        wm:SetRenderOrigin(Pos)
        wm:SetRenderAngles(Ang)

        if self.Render then
            self:Render(wm)
        else
            wm:SetupBones()
            wm:DrawModel()
        end

        // render_SetBlend(1)
        render_SuppressEngineLighting(false)
        //render.DrawSphere(Vector(),1,16,16,white)
    cam_End3D()
    
	//if not notPrint and self.PrintWeaponInfo then PrintWeaponInfo(self,x + wide,y + tall,alpha) end
end

hook.Add("Content Icon Paint","Homigrad",function(panel,w,h)
    local class = GetClassFromName(panel:GetSpawnName())
    if not class then return end--wtfffffff
    
    local table = fakeObject.GetFakeObjectRender(class,panel)
    if not table then return end

    if table.IconOverride then return end
    
    if table.WorldModel or table.CustomSpawnContentEnable then
        local x,y = panel:LocalToScreen(0,0)

        table.csmParentTag = table.ClassName
        
        render.ClearWeaponIcon()

        WeaponIconMatrix.self = table
        WeaponIconMatrix.x = x + 5
        WeaponIconMatrix.y = y + 5
        WeaponIconMatrix.w = w - 10
        WeaponIconMatrix.h = h - 30

        if table.dwsPos then
            WeaponIconMatrix.Pos = table.dwiPos or table.dwsPos
            WeaponIconMatrix.Ang = table.dwiAng or table.dwsAng
        else
            WeaponIconMatrix.focusOnPos = true
        end

        render.DrawWeaponIcon()
    elseif table.DrawSpawnContent then
        table.DrawSpawnContent(table,5,5,w - 10,h - 30)
    end
end)