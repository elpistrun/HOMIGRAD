local Level = oop.Get("level_base")
if not Level then return end

/*event.Add("Start Round","CloseWinnerVGUI",function()
    levelActive:CloseWinnerVGUI()
end)*/

function Level:SetEndType(value)
    self.EndType = value

	self.End = function()
        self:StartWinnerVGUI(roundDataEnd.winnerVGUI)
    end
end

//

local start,getAnim
local wait = 0.5//pidorasi na 3vyki blaad

local black = Color(0,0,0,200)

function Level:StartWinnerVGUI(value)
    if IsValid(WinnerVGUI) then WinnerVGUI:Remove() end

    if not value then return end//lol типо
    
    start = RealTime()
    
    getAnim = function()
        local k = math.ease.InOutCirc(math.max(start + wait - RealTime(),0) / wait)

        return Lerp(k,1,0)
    end

    WinnerVGUI = oop.CreatePanel("v_panel"):ad(function(self,w,h)
        self:setSize(math.max(math.max(w * 0.3,500) * getAnim(),1),math.max(64,h * 0.075)):setPos(w / 2 - self:W() / 2,h * 0.1)
    end)

    local iconSize = WinnerVGUI:H()
    local corner = iconSize * 0.25

    WinnerVGUI:ad(function(self,w,h)
        self:setSize(self:W() + corner * 2,self:H() + corner * 2)
    end)

    local color = value.color

    function WinnerVGUI:Draw(w,h)
        local k = getAnim()

        surface.SetAlphaMultiplier(math.min(k * 7,1))

        surface.SetDrawColor(color.r,color.g,color.b,255 * (1 - k))

        DisableClipping(true)

        do//скобки внутрь
            local y = (h - h * 1.25) / 2
            local h = h * 1.25

            surface.SetDrawColor(color.r,color.g,color.b,25 * (1 - k))
            draw.GradientLeft(0,y,w / 10,h)
            draw.GradientRight(w - w / 10,y,w / 10,h)
        end

        do//раскрывающиеся
            local x = -w / 2
            local w = w * 2

            surface.SetDrawColor(color.r,color.g,color.b,255 * (1 - k))

            draw.GradientRight(x,0,w / 2,h)
            draw.GradientLeft(x + w / 2,0,w / 2,h)
        end

        DisableClipping(false)

        local x = value.avatar and (iconSize + corner * 2) or corner
        local y = corner
        h = h - corner * 2
        w = w - x

        surface.SetDrawColor(color.r / 5,color.g / 5,color.b / 5,255)
        surface.DrawRect(x,y,w,h)
        surface.SetDrawColor(color.r / 2,color.g / 2,color.b / 2 ,255)
        draw.GradientRight(x,y,w,h)

        surface.SetDrawColor(cframe1)
        draw.GradientRight(x,y + 1,w / 2,1)
        draw.GradientLeft(x + w / 2,y + 1,w / 2,1)

        surface.SetDrawColor(cframe2)
        draw.GradientRight(x,y + h - 2,w / 2,1)
        draw.GradientLeft(x + w / 2,y + h - 2,w / 2,1)

        draw.Frame(x,y,w,h,cframe1,cframe2)

        draw.SimpleText(L(value.name or ""),"HS.18",x + 8,y + 6)

        local text = value.subtext

        if TypeID(text) == TYPE_TABLE then
            text = L(text[1],L(text[2] or ""))
        else
            text = L(text or "")
        end

        draw.SimpleText(text,"HS.12",x + 8,y + h - 6,nil,nil,TEXT_ALIGN_BOTTOM)

        local text = value.text

        if TypeID(text) == TYPE_TABLE then
            text = L(text[1],L(text[2] or ""))
        else
            text = L(text or "")
        end

        draw.SimpleText(text,"H.25",x + w / 2,y + h / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        self:PerformLayout()

        surface.SetAlphaMultiplier(1)
    end

    if value.avatar then
        local html = oop.CreatePanel("v_avatarlist",WinnerVGUI):ad(function(self,w,h)
            self:setSize(h,h)
        end)

        html:Setup(iconSize,corner)

        html.OnReady = function()
            html:AddPanel("winner",value.name,value.avatar,value.avatarFrame,value.background,value.backgroundOpacity,value.backgroundY)
        end
    end

    surface.PlaySound(value.sound)

    timer.Simple(self.DelayStartRound,function()
        self:CloseWinnerVGUI()
    end)
end

function Level:CloseWinnerVGUI()
    start = RealTime()

    getAnim = function()
        local k = math.ease.InOutCirc(math.max(start + wait - RealTime(),0) / wait)

        k = Lerp(k,0,1)

        if k <= 0 then
            if IsValid(WinnerVGUI) then WinnerVGUI:Remove() end
        end

        return k
    end
end

/*local ply = player.GetAll()[1]
local color = math.random(1,2) == 1 and Color(255,0,0) or Color(0,255,0)

Level:StartWinnerVGUI({
    color = color,
    
    name = ply:Name(),
    avatar = ply:GetNWString("Avatar"),
    avatarFrame = ply:GetNWString("AvatarFrame"),
    text = "Winner!",
    sound = "homigrad/vgui/panorama/case_awarded_4_legendary_01.wav"
})*/