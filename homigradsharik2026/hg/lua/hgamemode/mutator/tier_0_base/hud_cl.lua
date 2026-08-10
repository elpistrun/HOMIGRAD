local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

function MUTATOR:GetDescTextOnCursor() return {} end

MUTATOR:Event_Add("On","HUD",function(self) self:PingHUD() end)
MUTATOR:Event_Add("Off","HUD",function(self) self:PingHUD() end)

local delaySound = 0

function MUTATOR:PingHUD()
    if delaySound < RealTime() then
        delaySound = RealTime() + 1

        LocalPlayer():EmitSound("homigrad/vgui/deathnotice.wav",75,100,0.5)
    end

    showRoundInfo = RealTime() + 10
    
    self.pingHUD = RealTime() + 1
end

hook.Add("HUDPaint","Mutators",function()
    if table.Count(ActiveMutators) == 0 then return end

    surface.SetAlphaMultiplier(showRoundInfoColor.a / 255)

    local wide,tall = 300 * ScreenSize,48 * ScreenSize
    local x,y = ScrW() - wide,ScrH() * 0.125

    draw.SimpleText(L("mutators"),"HS.18",x + wide / 2,y - tall / 2,showRoundInfoColor,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    local mx,my = input.GetCursorPos()
    local corner = 6 * ScreenSize

    local time = RealTime()

    for name,mutator in pairs(ActiveMutators) do
        if (mutator.pingHUD or 0) > time then
            surface.SetDrawColor(0,255 * math.cos(time * 10 * 4),0)
        else
            surface.SetDrawColor(0,0,0)
        end

        draw.GradientRight(x,y,wide,tall)
        surface.SetDrawColor(255,255,255,15)
        draw.GradientRight(x,y,wide,1)
        surface.SetDrawColor(0,0,0,200)
        draw.GradientRight(x,y + tall - 1,wide,1)

        surface.SetMaterial(mutator.Icon)
        surface.SetDrawColor(255,255,255)

        local size = tall - corner * 2

        surface.DrawTexturedRect(x + corner,y + corner,size,size)
        
        draw.SimpleText(L(mutator.Title),"HS.18",x + tall + corner,y + corner)
        draw.SimpleText(L(mutator.Desc),"HS.12",x + tall + corner,y + (tall - 6) * ScreenSize,nil,nil,TEXT_ALIGN_BOTTOM)
    
        local desc = mutator:GetDescTextOnCursor()

        /*if math.pointinbox(mx,my,x,y,wide,tall) then
            local wideBox = 0

            surface.SetTextColor(255,255,255)
            surface.SetFont("HS.18")

            for i,text in pairs(desc) do
                local tw = surface.GetTextSize(text)
                if tw > wideBox then wideBox = tw end
            end

            mx = mx + wideBox / 2
            my = my - (#desc + 1) * 18 * ScreenSize

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(mx - wideBox,my,wideBox,#desc * 18 * ScreenSize)

            for i,text in pairs(desc) do
                local tw = surface.GetTextSize(text)
                if tw > wideBox then wideBox = tw end

                surface.SetTextPos(mx - tw,my + (i - 1) * 18 * ScreenSize)
                surface.DrawText(text)
            end
        end*/

        for i,text in pairs(desc) do
            draw.SimpleText(text,"HS.12",x + wide - corner,y + corner + ((i - 1) * (12 * ScreenSize)),nil,TEXT_ALIGN_RIGHT)
        end

        y = y + tall
    end

    surface.SetAlphaMultiplier(1)
end)