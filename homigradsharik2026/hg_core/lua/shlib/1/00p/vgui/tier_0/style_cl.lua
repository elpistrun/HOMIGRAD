local PANEL = oop.Get("v_panel")
if not PANEL then return end

PANEL.styles = {}
PANEL.initDrawStyle = "dark"

function PANEL:SetDrawStyle(name,data)
    self.styles[name] = data

    if data.Construct then data.Construct(self) end
end

local blacklist = {
    ["PreDraw"] = true,
    ["Draw"] = true,
    ["DrawOver"] = true
}

function PANEL:SetupDrawStyle(name)
    local style = self.styles[name]
    if not style then return end

    for k,v in pairs(style) do
        if blacklist[k] then continue end
        
        self[k] = v
    end

    local preDraw = style.PreDraw
    local draw = style.Draw
    local drawOver = style.DrawOver

    self.Draw = function(self,w,h)
        if preDraw then preDraw(self,w,h) end
        if draw then draw(self,w,h) end
        if drawOver then drawOver(self,w,h) end
    end

    if IsValid(self) then
        self.setDrawStyle = name

        if style.Init then style.Init(self,style) end
    else
        self.initDrawStyle = name
    end
    
    return self
end

PANEL:Event_Add("Init","SetupDrawStyle",function(self)
    if self.initDrawStyle then self:SetupDrawStyle(self.initDrawStyle) end
end,5)