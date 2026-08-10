local PANEL = oop.Reg("v_label","v_panel")
if not PANEL then return end

function PANEL:FunctionCreate(parent)
	local panel = vgui.Create("DLabel",parent)
	
	local Paint = panel.Paint
	local Think = panel.Think

	for k,v in pairs(self) do panel[k] = v end

	for k,v in pairs({
		"SetTextColor"
	}) do
		local handle = panel[v]

		panel[v] = function(_,value)
			handle(panel,value)
			return panel
		end
	end

	local handle = panel.SetFont
	function panel:SetFont(value)
		surface.SetFont(value)
		local tw,th = surface.GetTextSize("A")
		self.TextHeight = th

		handle(panel,value)

		return self
	end

	function panel:SetValue(value)
		self:SetText(value)
	end

	local handle = panel.SetMultiline
	function panel:SetMultiline(value)
		handle(self,value)
		self.Multiline = value
		return self
	end

	panel:Init()

	panel.DrawTextEntry = Paint
	panel.Step = Think

	local function loseFocus()
		local frame = panel.lastEditablePanel
		if IsValid(frame) then
			panel.lastEditablePanel = nil
			frame:SetKeyboardInputEnabled(false)
			frame:KillFocus()
		end
	end

	function panel:OnMouse(key,value)
		if not value or key ~= MOUSE_LEFT then return end

		local frame = self

		while true do
			local parent = frame:GetParent()
			if not IsValid(parent) then break end

			frame = parent

			if parent.Base == "EditablePanel" then break end
		end

		local x,y = self.x,self.y

		self.lastEditablePanel = frame
		frame:SetKeyboardInputEnabled(true)--cring????
		frame:MakePopup()
	end

	function panel:OnLoseFocus()
		loseFocus()

		self:OnUnFocus()
	end

	function panel:OnUnFocus() end

	panel:Event_Add("Remove","OnLoseFocus",function(self) loseFocus() end)

	return panel--mdem
end

function PANEL:DrawCenterLineText(w,h)
	local color = self:GetTextColor()
	surface.SetDrawColor(color.r,color.g,color.b,15)
	surface.DrawRect(2,h / 2 + self.TextHeight / 2 + 4,w - 4,1)
end

//

local TextColor = Color(255,255,255)
local PlaceholderColor = Color(255,255,255,125)
local HighlightColor = Color(125,125,125)

PANEL:SetDrawStyle("dark",{
PreDraw = function(self,w,h)
	surface.SetDrawColor(16,16,16,200)
	surface.DrawRect(0,0,w,h)

	draw.Frame(0,0,w,h,cframe2,cframe1)
end,
Draw = function(self,w,h)
	--self:DrawTextEntry(w,h)
	//if not self.Multiline then self:DrawCenterLineText(w,h) end
end,
Init = function(self)
	self:SetTextColor(TextColor):SetFont("HS.18")
end})

PANEL:SetDrawStyle("white",{
Draw = function(self,w,h)
	--self:DrawTextEntry(w,h)
	//if not self.Multiline then self:DrawCenterLineText(w,h) end
end,
Init = function(self)
	self:SetTextColor(TextColor):SetFont("HS.18")
end})