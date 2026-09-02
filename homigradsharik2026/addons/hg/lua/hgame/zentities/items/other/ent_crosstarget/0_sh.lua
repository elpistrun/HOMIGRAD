local ENT = oop.Reg("ent_crosstarget",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Цель"
ENT.Category = L("weapon_category_item")
ENT.Spawnable = true

adminPanel.commandRegistry("ent_crosstarget_clear",{},"game")

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate1x1.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetupNWTable("Hits")
end

local mat = Material("models/rendertarget")

local black = Color(0,0,0)

function ENT:Draw()
    --self:DrawModel()

    local pos,ang = self:GetPos(),self:GetAngles()
    
    local worldPos,worldAng = LocalToWorld(Vector(-23.7,23.7,1.5),Angle(),pos,ang)

    local qualityScale = 10
    local w,h = 90 * qualityScale,90 * qualityScale

    cam.Start3D2D(worldPos,worldAng,1 / UNITS_TO_METERS / 100 / qualityScale)
        surface.SetDrawColor(255,255,255)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("90x90cm","H.25",0,0,black)

        surface.SetDrawColor(0,0,0)

        surface.DrawCircle(w/2,h/2,3 * qualityScale,0,0,0)
        draw.SimpleText("3cm","H.18",w/2,h/2 - 3 * qualityScale,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        surface.DrawCircle(w/2,h/2,10 * qualityScale,0,0,0)
        draw.SimpleText("10cm","H.18",w/2,h/2 - 10 * qualityScale,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        surface.DrawCircle(w/2,h/2,20 * qualityScale,0,0,0)
        draw.SimpleText("20cm","H.18",w/2,h/2 - 20 * qualityScale,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        surface.DrawCircle(w/2,h/2,30 * qualityScale,0,0,0)
        draw.SimpleText("30cm","H.18",w/2,h/2 - 30 * qualityScale,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        surface.DrawCircle(w/2,h/2,40 * qualityScale,0,0,0)
        draw.SimpleText("40cm","H.18",w/2,h/2 - 40 * qualityScale,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
    cam.End3D2D()
    
    local hits = self:GetNWTable("Hits")
    if not hits then return end

    render.SetMaterial(mat)

    for i = 1,#hits do
        local hit = hits[i]

        local worldPos,worldAng = LocalToWorld(hit[1],hit[2],pos,ang)
        
        render.DrawSphere(worldPos,0.6,16,16)
    end
end

function ENT:HUDTarget()
    
end