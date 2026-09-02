--[[ArmorListClasses["Ballon O2"] = {
    PrintName = "Ballon O2",
    mdl = "models/props_junk/propanecanister001a.mdl",
    slots = {
        back = 0.25,
    },
    def = {},
    bon = "ValveBiped.Bip01_Spine2",
    siz = Vector(0.6,0.6,1.4),
    pos = Vector(4,1,0),
    ang = Angle(90,0,0),
    wgt = 10,
    dur = 75,
    ent = "ent_jack_gmod_ezarmor_ballon_o2",
    gayPhysics = true
}]]--

if SERVER then return end

local black = Color(0,0,0)


hook.Add("RenderScreenspaceEffects","Water",function()
    if not LocalPlayer():Alive() then return end

    if LocalPlayer():GetNW2Bool("HeadInWater")  then
	    DrawToyTown(1,ScrH())
    end
end)

event.Add("DSP","Water",function()
    local ply = LocalPlayer()
    if ply:Alive() and ply:GetNW2Bool("HeadInWater") then return 14,false end
end)

hook.Add("HUDPaint","O2",function()
    local ply = LocalPlayer()
    if not ply:Alive() then return end

    local o2 = ply:GetNW2Float("o2",1)

    surface.SetDrawColor(0,0,0,125 * (1 - o2))
    surface.DrawRect(0,0,ScrW(),ScrH())

    local size = ScrH() * (1 - o2)

    draw.GradientUp(0,0,ScrW(),size)
end)