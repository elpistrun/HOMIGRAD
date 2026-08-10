include "sh_init.lua"
include "cl_maths.lua"
include "cl_panel.lua"

local mat = CreateMaterial("aeypad_baaaaaaaaaaaaaaaaaaase", "VertexLitGeneric", {
	["$basetexture"] = "white",
	["$color"] = "{ 36 36 36 }",
})

function ENT:Draw()
	render.SetMaterial(mat)

	render.DrawBox(self:GetPos(), self:GetAngles(), self.Mins, self.Maxs, color_white, true)

	local pos, ang = self:CalculateRenderPos(), self:CalculateRenderAng()

	local w, h = self.Width2D, self.Height2D
	local x, y = self:CalculateCursorPos()

	local scale = self.Scale -- A high scale avoids surface call integerising from ruining aesthetics

	cam.Start3D2D(pos, ang, self.Scale)
		self:Paint(w, h, x, y)
	cam.End3D2D()
end

function ENT:SendCommand(command, data)
	net.Start("Keypad")
		net.WriteEntity(self)
		net.WriteUInt(command, 4)

		if data then
			net.WriteUInt(data, 8)
		end
	net.SendToServer()
end

local white = Color(255,255,255)

function ENT:HUDTarget(ply,k,w,h)
	white.a = 255 * k * (1 - inventoryGame.AnimOpenK)

	draw.SimpleText("Keypad","HS.18",w / 2,h / 2 - 50 * (1 - k),white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

	if IsValid(KeypadMenu) then return false end
end

local black = Color(0,0,0,200)
local whiteadd = Color(255,255,255,15)

local buttSize = 48

concommand.Add("hg_keypad_openmenu",function(ply,cmd,args)
	if IsValid(KeypadMenu) then KeypadMenu:Remove() end

	local ent = Entity(tonumber(args[1] or -1))

	KeypadMenu = oop.CreatePanel("v_frame")
	KeypadMenu:SetSize(buttSize * 3,buttSize * 3 + buttSize * 2)
	KeypadMenu:Center()
	function KeypadMenu:Draw(w,h) draw.RoundedBox(0,0,0,w,h,black) end
	KeypadMenu:MakePopup()

	local text = ""

	local screen = oop.CreatePanel("v_panel",KeypadMenu)
	screen:SetSize(KeypadMenu:GetWide() - 4,buttSize - 4)
	screen:SetPos(2,2)
	function screen:Draw(w,h)
		draw.RoundedBox(0,0,0,w,h,black)

		draw.SimpleText(text,"DermaLarge",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	local x,y = 0,0

	for i = 1,9 do
		local butt = oop.CreatePanel("v_button",KeypadMenu)
		butt:SetSize(buttSize - 4,buttSize - 4)
		butt:SetPos(buttSize * x + 2,buttSize + buttSize * y + 2)
		butt:SetText("")
		function butt:Draw(w,h)
			draw.RoundedBox(0,0,0,w,h,black)
			if self:IsHovered() then draw.RoundedBox(0,0,0,w,h,whiteadd) end

			draw.SimpleText(i,"DermaDefault",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		function butt.OnClick()
			if #text < 4 then
				text = text .. i

				surface.PlaySound("buttons/button15.wav")
			end
		end

		x = x + 1
		
		if x >= 3 then
			x = 0
			y = y + 1
		end
	end

	local butt = oop.CreatePanel("v_button",KeypadMenu)
	butt:SetSize(buttSize - 4,buttSize - 4)
	butt:SetPos(2,KeypadMenu:GetTall() - butt:GetTall() - 2)
	butt:SetText("")

	function butt:Draw(w,h)
		draw.RoundedBox(0,0,0,w,h,black)
		if self:IsHovered() then draw.RoundedBox(0,0,0,w,h,whiteadd) end

		draw.SimpleText("X","DermaDefault",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end

	function butt.OnClick()
		text = ""
		surface.PlaySound("buttons/button15.wav")
	end

	local butt = oop.CreatePanel("v_button",KeypadMenu)
	butt:SetSize(buttSize * 2 - 4,buttSize - 4)
	butt:SetPos(KeypadMenu:GetWide() - butt:GetWide() - 2,KeypadMenu:GetTall() - butt:GetTall() - 2)
	butt:SetText("")
	function butt:Draw(w,h)
		if not IsValid(ent) then KeypadMenu:Remove() end

		draw.RoundedBox(0,0,0,w,h,black)
		if self:IsHovered() then draw.RoundedBox(0,0,0,w,h,whiteadd) end

		draw.SimpleText("Отправить","DermaDefault",w / 2,h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end
	function butt.OnClick()
		net.Start("Keypad")
		net.WriteEntity(ent)
		net.WriteString(tonumber(text or 0) or 0)
		net.SendToServer()

		KeypadMenu:Remove()
	end
end)