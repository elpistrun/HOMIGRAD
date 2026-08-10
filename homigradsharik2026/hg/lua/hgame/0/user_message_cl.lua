local PLAYER = FindMetaTable("Player")

local list = {}

local corner = 6
local fontText = "H.18"

net.Receive("user_message",function()
    LocalPlayer():UserMessage(net.ReadString(),net.ReadInt(4),net.ReadFloat())
end)

function PLAYER:UserMessage(text,type,delay)
    local msg = {
        text = string.Split(text,"\n"),
        type = type,
        delay = delay or 3,
        start = RealTime()
    }

    list[#list + 1] = msg

    surface.SetFont(fontText)

    local w,h = 0,0
    local textH = 0

    for i,text in pairs(msg.text) do
        local tw,th = surface.GetTextSize(text)

        w = math.max(tw,w)
        textH = math.max(th,textH)
        h = h + th
    end

    msg.textH = textH
    msg.wight = w + corner * 2
    msg.height = h + corner * 2

    if #list > 5 then
        table.remove(list,1)
    end

    if type == USERMSG_GENERAL then
        LocalPlayer():StopSound("homigrad/vgui/lobby_notification_chat.wav")
        LocalPlayer():EmitSound("homigrad/vgui/lobby_notification_chat.wav",75,255,0.3)
    elseif type == USERMSG_ERROR then
        LocalPlayer():StopSound("homigrad/vgui/lobby_notification_joined.wav")
        LocalPlayer():EmitSound("homigrad/vgui/lobby_notification_joined.wav",75,255,0.5)
    end
end

local black = Color(0,0,0,200)
local red = Color(255,25,7,245)
local white = Color(255,255,255)

hook.Add("DrawOverlay","User Message",function()
    if not InitPostEntity then return end

    local i = #list
    
    local y = ScrH() * 0.92
    local x = ScrW() / 2

    local time = RealTime()

    while true do
        local msg = list[i]
        if not msg then break end

        local alpha = math.max(msg.start - time + msg.delay,0) / msg.delay
        alpha = math.min(alpha * 5,1)
        
        if alpha == 0 then table.remove(list,i) continue end

        surface.SetAlphaMultiplier(alpha)

        local w,h = msg.wight,msg.height

        local Y = y - h

        local colBackground = black
        local colOutline = white
        local colSplash = white

        local type = msg.type

        if type == USERMSG_ERROR then
            colBackground = red
            colSplash = red
        end

        surface.SetDrawColor(colBackground)
        surface.DrawRect(x - w/2,Y,w,h)
        surface.SetDrawColor(colOutline)
        surface.DrawRect(x - w/2,Y,w,1)
        surface.DrawRect(x - w/2,Y + h - 1,w,1)

        local startAnim = math.max(msg.start - time + 0.2,0) / 0.2
        surface.SetAlphaMultiplier(math.min(startAnim * 1.5,1) * alpha)
        surface.SetDrawColor(colSplash.r,colSplash.g,colSplash.b,255)

        local wSplash = w * (2 * (1 - startAnim))
        draw.GradientRight(x - wSplash + 1,Y,wSplash,h)
        draw.GradientLeft(x,Y,wSplash,h)

        surface.SetAlphaMultiplier(alpha)

        for i,text in pairs(msg.text) do
            draw.SimpleText(text,fontText,x - w/2 + corner,Y + (i - 1) * msg.textH + corner)
        end

        y = y - h - corner * 1

        i = i - 1
    end

    surface.SetAlphaMultiplier(1)
end)