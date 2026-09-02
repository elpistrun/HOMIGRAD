local Level = oop.Get("level_homicide")
if not Level then return end

local focus_ent
local focus_stick = 0
local size = 16

TTTButtons = TTTButtons or {}

hook.Add("PostCleanupMap","TTTButtons",function()
    timer.Simple(1,function()
        TTTButtons = {}

        for _, ent in ipairs(ents.FindByClass("ttt_traitor_button")) do
            if IsValid(ent) then
                TTTButtons[ent:EntIndex()] = ent
            end
        end
    end)
end)

local tbut_normal = Material("icon16/clock.png")
local tbut_focus = Material("icon16/clock_red.png")

local focus_range = 25

local abs = math.abs

function Level:DrawTTTButtons()
    local lply = LocalPlayer()
    
    local size = 16

    if table.Count(TTTButtons) > 0 then
        local plypos = LocalPlayer():GetPos()
        local midscreen_x = ScrW() / 2
        local midscreen_y = ScrH() / 2
        local pos, scrpos, d
        local focus_ent = nil
        local focus_d, focus_scrpos_x, focus_scrpos_y = 0, midscreen_x, midscreen_y
  
        for k,but in pairs(TTTButtons) do
            if not IsValid(but) or not but.IsUsable then continue end
            if but:GetDelay() == 0 then continue end

            pos = but:GetPos()
            scrpos = pos:ToScreen()
  
            if not scrpos.visible or not but:IsUsable() then continue end
            
            d = pos - plypos
            d = d:Dot(d) / (but:GetUsableRange() ^ 2)

            if d > 1 then continue end

            surface.SetMaterial(but:GetDelay() < 0 and tbut_normal or tbut_focus)

            surface.SetDrawColor(255,255,255,200 * (1 - d))
            surface.DrawTexturedRect(scrpos.x - size / 2,scrpos.y - size / 2,size,size)

            if d >= focus_d then
                local x = abs(scrpos.x - midscreen_x)
                local y = abs(scrpos.y - midscreen_y)

                if (x < focus_range and y < focus_range and x < focus_scrpos_x and y < focus_scrpos_y) then
                    focus_ent = but
                end
            end
        end
  
        if IsValid(focus_ent) then
            size = size * 2

            focus_ent = focus_ent
            focus_stick = CurTime() + 0.1

            local scrpos = focus_ent:GetPos():ToScreen()
            local sz = 16

            surface.SetMaterial(tbut_focus)
            surface.SetDrawColor(255,255,255,200)
            surface.DrawTexturedRect(scrpos.x - size / 2,scrpos.y - size / 2,size,size)

            surface.SetTextColor(255,255,255,255)
            surface.SetFont("H.18")

            local x = scrpos.x + sz + 10
            local y = scrpos.y - sz - 3
            surface.SetTextPos(x,y)
            surface.DrawText(focus_ent:GetDescription())

            y = y + 12

            surface.SetTextPos(x,y)

            if focus_ent:GetDelay() < 0 then
                surface.DrawText(L("tbut_single"))
            elseif focus_ent:GetDelay() == 0 then
                surface.DrawText(L("tbut_reuse"))
            else
                surface.DrawText(L("tbut_retime",focus_ent:GetDelay()))
            end

            if lply:KeyDown(IN_USE) then
                RunConsoleCommand("ttt_use_tbutton",tostring(focus_ent:EntIndex()))
            end
        end
    end
end