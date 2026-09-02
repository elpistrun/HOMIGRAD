FindMetaTable("Player").InFakeDeath = function(self) return self:GetNWBool("FakeDeath") end

if SERVER then return end

local oldValue

local white = Color(255,255,255)

hook.Add("HUDPaint","FakeDeath",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end
    
    local active = ply:InFakeDeath()

    if oldValue ~= active then
        oldValue = active

        start = RealTime()
    end

    if not ply:Alive() or not ply:InFake() then return end

    local k = math.max(start - RealTime() + 3,0) / 3
    k = math.min(k * 10,1)

    if active then
        if ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_LEFT) or ply:KeyDown(IN_RIGHT) then
            RunConsoleCommand("fake_dead","0")
        end
    end
    
    if k <= 0 then return end

    white.a = 255 * k

    draw.SimpleText(active and "FAKE DEATH" or "ALIVE","HS.25",ScrW() / 2,ScrH() * 0.9,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
end)