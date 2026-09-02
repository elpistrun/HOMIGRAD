local PANEL = oop.Get("v_panel")
if not PANEL then return end

local corner = 4
local value,valueParse,start = nil,nil,0

function SetTip(text,width)
    if value == text then return end

    value = text
    valueParse = markup.Parse(text,width or math.max(ScrW() / 4,400))
end

function vgui.DrawTip(text,delay,width)
    value = SetTip(text,width)
    start = RealTime() + 0.1
end

function PANEL:DrawTip(text,delay,width) 
    if not self:IsHovered() then return end
    
    vgui.DrawTip(text,delay,width)

    return true
end

hook.Add("PostRenderVGUI","TIP",function()
    if start < RealTime() then return end

    local mx,my = gui.MousePos()

    my = my - valueParse:GetHeight() - corner
    mx = mx + corner

    surface.SetDrawColor(20,20,20)
    surface.DrawRect(mx - corner,my - corner,valueParse:GetWidth() + corner*2,valueParse:GetHeight() + corner*2)
    valueParse:Draw(mx,my)
end)