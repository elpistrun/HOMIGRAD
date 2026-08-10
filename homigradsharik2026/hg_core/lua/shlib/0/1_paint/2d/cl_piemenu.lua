local PIEMENU_COLOR = Color(35,35,35)
local PIEMENU_SELECT_OPTION_COLOR = Color(255,255,255)
local PieMenu_INVALID_COLOR = Color(125,125,125)

local INVALID_ICON_COLOR = Color(209,199,190)
local DEFAULT_WEDGE_COLOR = Color(205,64,42)
local TITLE_COLOR = Color(255,255,255)
local DESCRIPTION_COLOR = Color(235,235,235,225)
local FOOTER_COLOR = Color(200,200,200,225)
local ICON_COLOR = Color(255,255,255)

local TITLE_OFFSET = -36
local DESCRIPTION_OFFSET = 48
local FOOTER_OFFSET = 220
local ICON_OFFSET = 180

local ICON_SIZE = 100
local OUTER_ICON_SIZE = 52

local OPEN_ANIM_TIME = 0.1
local CLOSE_ANIM_TIME = 0.2
local SWITCH_ANIM_TIME = 0.2
local ROTATE_ANIM_TIME = 0.065

local BLUR_MATERIAL = Material("pp/blurscreen")
local BLUR_AMOUNT = 12

local PieMenu_OPTION = {}

PieMenu_OPTION.__index = PieMenu_OPTION

function PieMenu_OPTION:SetCondition(func)
    self.Condition = func

    return self
end

function PieMenu_OPTION:GetCondition()
    if (self.Condition) then return self.Condition() end

    return true
end

PieMenu = {}

function PieMenu:CreateOption()
    local option = {}
    setmetatable(option,PieMenu_OPTION)

    option.color = Color(235,235,235)

    self.Options[#self.Options + 1] = option

    return option
end

function PieMenu:Init()
    self.Options = {}
    self.AnimMatrix = Matrix()
    self.Index = 1
    self.LastIndex = 1
    self.StateK = 0
end

PieMenu:Init()

function PieMenu:GetRotation() return self.Rotation or 0 end

function PieMenu:Open()
    self.Circle = CreateCircle()
    self.Circle:SetStartAngle(0)
    self.Circle:SetEndAngle(360)
    self.Circle:SetRadius(490 * ScreenSize)
    self.Circle:SetThickness(170 * ScreenSize)
    self.Circle:SetCenter(ScrW() / 2, ScrH() / 2)
    self.Circle:SetColor(PIEMENU_COLOR)
    
    self.Wedge = CreateCircle()
    self.Wedge:SetRadius(504 * ScreenSize)
    self.Wedge:SetThickness(176 * ScreenSize)
    self.Wedge:SetCenter(ScrW() / 2, ScrH() / 2)
    self.Wedge:SetColor(DEFAULT_WEDGE_COLOR)

    self.Invalid = CreateCircle()
    self.Invalid:SetRadius(490 * ScreenSize)
    self.Invalid:SetThickness(170 * ScreenSize)
    self.Invalid:SetCenter(ScrW() / 2, ScrH() / 2)
    self.Invalid:SetColor(PieMenu_INVALID_COLOR)

    gui.EnableScreenClicker(true)
    LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_page_scroll.wav",75,100,0.5)

    self.OpenTime = CurTime()
    self.CloseTime = nil
    
    self.Success = false

    self.StateK = 0

    local options = {}

    self.AvailableOptions = self.Options
end

function PieMenu:Close(suppressSound)
    if (self.CloseTime) then return end

    gui.EnableScreenClicker(false)

    if (!suppressSound) then
        //gRust.PlaySound("PieMenu.close")
    end

    self.CloseTime = CurTime()
    self.OpenTime = nil
end

function PieMenu:SetAngleOffset(offset)
    self.AngleOffset = offset
end

local ANGLE_OFFSETS = {
    [2] = 45,
    [4] = -120
}

function PieMenu:GetAngleOffset()
    local offset = ANGLE_OFFSETS[#self.AvailableOptions] or 0

    return offset + (self.AngleOffset or 0)
end

function PieMenu:Draw()
    if (#self.AvailableOptions == 0) then return end

    local fullyOpen = self.OpenTime and (self.StateK == 1)
    local angleOffset = self:GetAngleOffset()
    local alpha = self.StateK

    surface.SetAlphaMultiplier(alpha)
    surface.SetDrawColor(0, 0, 0, 175)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    local circle = self.Circle
    local invalid = self.Invalid
    local wedge = self.Wedge

    local option = self.AvailableOptions[self.Index]

    if (!option) then return end

    if option:GetCondition() then
        wedge:SetColor(option.color)
    else
        wedge:SetColor(ColorAlpha(option.color,75))
    end

    cam.PushModelMatrix(self.AnimMatrix)

    circle:Draw()

    invalid:SetStartAngle(0)
    invalid:SetEndAngle(360 / #self.AvailableOptions)

    for i = 1, #self.AvailableOptions do
        if (!self.AvailableOptions[i]:GetCondition()) then
            invalid:SetRotation((360 / #self.AvailableOptions) * (i - 1) + angleOffset)
            invalid:Draw()
        end
    end

    wedge:Draw()

    -- Icons

    local cx, cy = circle:GetCenter()

    for i = 0, #self.AvailableOptions - 1 do
        local option = self.AvailableOptions[i + 1]
        local angle = math.rad(((360 / #self.AvailableOptions) * i + (360 / #self.AvailableOptions) / 2) + angleOffset)
        local radius = circle:GetRadius() - (circle:GetThickness() / 2)
        local iconPos = Vector(math.cos(angle), math.sin(angle), 0) * radius
        local iconX, iconY = cx + iconPos.x, cy + iconPos.y

        surface.SetMaterial(option.icon)

        if (option:GetCondition()) then
            if (self.Index == i + 1) then
                surface.SetDrawColor(PIEMENU_SELECT_OPTION_COLOR)
            else
                surface.SetDrawColor(option.color)
            end
        else
            surface.SetDrawColor(INVALID_ICON_COLOR)
        end

        surface.DrawTexturedRect(iconX - OUTER_ICON_SIZE * ScreenSize, iconY - OUTER_ICON_SIZE * ScreenSize, OUTER_ICON_SIZE * 2 * ScreenSize, OUTER_ICON_SIZE * 2 * ScreenSize)
    end

    if (fullyOpen or self.OpenTime) then
        local title = isfunction(option.title) and option.title() or option.title
        local description = isfunction(option.desc) and option.desc() or option.desc
        local footer = isfunction(option.footer) and option.footer() or option.footer

        if title then
            draw.SimpleText(title, "HS.45", cx, cy, TITLE_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if description then
            if TypeID(description) == TYPE_TABLE then

            else
                draw.SimpleText(description, "HS.25", cx, cy + DESCRIPTION_OFFSET * ScreenSize, DESCRIPTION_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if footer then
            draw.SimpleText(footer, "HS.25", cx, cy + FOOTER_OFFSET * ScreenSize, FOOTER_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    surface.SetMaterial(option.icon)
    surface.SetDrawColor(ICON_COLOR)
    surface.DrawTexturedRect(cx - ICON_SIZE * ScreenSize, cy - ICON_SIZE * ScreenSize - ICON_OFFSET * ScreenSize, ICON_SIZE * 2 * ScreenSize, ICON_SIZE * 2 * ScreenSize)

    cam.PopModelMatrix()
end

local LeftMouseDown = false
local Use = false

function PieMenu:Update()
    if self.OpenTime then
        self.StateK = math.min(CurTime() - self.OpenTime,0.05) / 0.05
    end

    if self.CloseTime then
        self.StateK = 1 - math.min(CurTime() - self.CloseTime,0.05) / 0.05
    end
    
    local angleOffset = self:GetAngleOffset()
    local circle = self.Circle
    local wedge = self.Wedge
    
    local fullyOpen = self.OpenTime and (self.StateK == 1)

    local cx, cy = circle:GetCenter()

    if input.IsKeyDown(KEY_E) then
        if fullyOpen and not Use then
            self:Close(true)
            self.Success = true
            //LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_page_scroll.wav",75,90,1)

            return
        end

        Use = true
    else
        Use = nil
    end

    if (fullyOpen) then
        local mx, my = gui.MousePos()
        local angle = (math.deg(math.atan2(my - cy, mx - cx)) - angleOffset) % 360

        if (angle < 0) then angle = angle + 360 end

        local index = math.max(math.ceil(angle / (360 / #self.AvailableOptions)), 1)

        if (index != self.Index) then
            self.LastIndex = self.Index
            self.Index = index
            self.RotateTime = CurTime()

            if (self.AvailableOptions[self.Index]:GetCondition()) then
                self.SelectTime = CurTime()
                
                LocalPlayer():EmitSound("homigrad/vgui/buttonrollover.wav",75,100,1)
            end
        end

        if input.IsMouseDown(MOUSE_RIGHT) then
            self:Close(true)
            self.Success = true
            //LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_page_scroll.wav",75,90,1)
        end

        if (input.IsMouseDown(MOUSE_LEFT)) then
            if (!LeftMouseDown) then
                local option = self.AvailableOptions[self.Index]
                if (option and option:GetCondition()) then
                    self:Close(true)
                    self.Success = true
                    LocalPlayer():EmitSound("homigrad/vgui/csgo_ui_page_scroll.wav",75,90,1)

                    local cback = option.callback
                    if cback then cback() end
                end
            end

            LeftMouseDown = true
        else
            LeftMouseDown = false
        end
    end

    self.SelectProgress = math.Clamp((CurTime() - (self.SelectTime or 0)) / SWITCH_ANIM_TIME, 0, 1)
    self.RotateProgress = math.Clamp((CurTime() - (self.RotateTime or 0)) / ROTATE_ANIM_TIME, 0, 1)

    wedge:SetStartAngle(0)
    wedge:SetEndAngle(360 / #self.AvailableOptions)

    local option = self.AvailableOptions[self.Index]
    local oldRotation = (self.LastIndex - 1) * (360 / #self.AvailableOptions)
    local newRotation = (self.Index - 1) * (360 / #self.AvailableOptions)

    if (self.Index == 1 and self.LastIndex == #self.AvailableOptions) then
        oldRotation = oldRotation - 360
    elseif (self.Index == #self.AvailableOptions and self.LastIndex == 1) then
        newRotation = newRotation - 360
    end

    local rotation = Lerp(self.RotateProgress, oldRotation, newRotation) + angleOffset

    wedge:SetRotation(rotation)

    local scale = 1

    self.AnimMatrix:Translate(Vector(cx, cy))
    self.AnimMatrix:SetScale(Vector(scale, scale, 1))
    self.AnimMatrix:Translate(Vector(-cx, -cy))
end

function PieMenu:IsOpen() return PieMenu.OpenTime or PieMenu.StateK > 0 end

hook.Add("HUDPaint","DrawPieMenu",function()
    if not PieMenu:IsOpen() then return end

    PieMenu:Update()
    PieMenu:Draw()
end)

/*PieMenu:Init()

local option = PieMenu:CreateOption()
option.title = "Разрядить"
option.desc = "Разряжает патрончики"
option.icon = Material("icon16/accept.png")

local option = PieMenu:CreateOption()
option.title = "Зарядить огненые"
option.desc = "Зарежает огненые"
option.footer = "Ты гей"
option.icon = Material("icon16/add.png")
option:SetCondition(function() return true end)

local option = PieMenu:CreateOption()
option.title = "Зарядить скорострельные"
option.desc = "Зарежает скорострельные"
option.icon = Material("icon16/application_form_magnify.png")


PieMenu:Open()

*/

