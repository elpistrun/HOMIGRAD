local ENT = oop.Reg("ent_moatarget",{"base_entity"},true)
if not ENT then return INCLUDE_BREAK end

ENT.PrintName = "Цель Minute Of Angle"
ENT.Category = L("weapon_category_item")
ENT.Spawnable = true

function ENT:Initialize()
    self:SetModel("models/hunter/plates/plate1x1.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)

    self:SetupNWTable("Hits")
end

local mat = Material("models/rendertarget")

local black = Color(0,0,0)

function ENT:Draw()
    --self:DrawModel()

    -- одна еденица = 1 см

    local pos,ang = self:GetPos(),self:GetAngles()
    
    local worldPos,worldAng = LocalToWorld(Vector(-26.5,26.5,1.5),Angle(),pos,ang)

    local qualityScale = 26
    local w,h = 100 * qualityScale,100 * qualityScale

    cam.Start3D2D(worldPos,worldAng,1 / UNITS_TO_METERS / 100 / qualityScale)
        surface.SetDrawColor(190,190,190)
        surface.DrawRect(0,0,w,h)

        draw.SimpleText("Minute Of Angle","H.45",0,0,black)
        draw.SimpleText("!CALCULATE DISTANCE IN BALISTIC SCALE!","H.25",w/2,h - 30,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        draw.SimpleText("Дели UNITS_TO_METERS на " .. BALISTIC_SCALE .. ", получишь метры в balistic scale","H.25",w/2,h,black,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

        surface.SetDrawColor(150,150,150)
        surface.DrawLine(w/2,0,w/2,h)
        surface.DrawLine(0,h/2,w,h/2)

        for i = 1,30 do
            local r = i % 5 == 0 and 255 or 0
            local g = i % 10 == 0 and 255 or 0

            local diametr = 2.91 * i
            surface.DrawCircle(w/2,h/2,diametr / 2 * qualityScale,r,g,0)
            draw.SimpleText(100 * i .. "m","H.18",w/2,h/2 - diametr / 2 * qualityScale,black,nil,TEXT_ALIGN_BOTTOM)
            draw.SimpleText(math.Round(diametr) .. "cm","H.18",w/2,h/2 + diametr / 2 * qualityScale,black,nil,TEXT_ALIGN_TOP)
            draw.SimpleText(i .. "moa","H.12",w/2 + diametr / 2 * qualityScale - 0.8 * qualityScale,h/2,black,TEXT_ALIGN_CENTER)
        end
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