local PANEL = oop.Reg("v_spawnicon","v_panel")
if not PANEL then return end

PANEL.Base = "SpawnIcon"

function PANEL:OnMouse(key,value)
    if not value then return end

    if self.DoClick then self:DoClick(key) end
end

if true then return end

NEEDRENDER = NEEDRENDER or {}//из за того что я замен ил renderscene, из за этого сука не рендерится терь модели, приходится такой хуетой страдать

file.CreateDir("homigrad")
RENDERED =  JSONToTable(file.Read("homigrad/spawnicons.txt") or "") or {}

event.Add("RenderScene","SpawnIcons",function(vec,ang,fov)
	for mdl in pairs(NEEDRENDER) do
        NEEDRENDER[mdl] = NEEDRENDER[mdl] - 1

		if NEEDRENDER[mdl] <= 0 then
            NEEDRENDER[mdl] = nil
        	RENDERED[mdl] = true

            file.Write("homigrad/spawnicons.txt",util.TableToJSON(RENDERED))
		end

		return "nil"
    end//mdam....
end,-10)

function PANEL:Paint(w,h)
    if self.Draw then self:Draw(w,h) end
    
    local mdl = self:GetModelName()

    if not RENDERED[mdl] then
        RENDERED[mdl] = true
        NEEDRENDER[mdl] = 1

        local ent = ClientsideModel(mdl,RENDERGROUP_BOTH)
        local tbl = PositionSpawnIcon(ent,vector_origin)

        local data = {}
        data.cam_pos = tbl.origin
        data.cam_ang = tbl.angles
        data.cam_fov = tbl.fov
        data.ent = ent

        self:RebuildSpawnIconEx(data)//если бы не эта хуйня......

        ent:Remove()
    end
end

function PANEL:OnMouse(key,value)
    if not value then return end

    if self.DoClick then self:DoClick(key) end

    if key == MOUSE_RIGHT then RENDERED[self:GetModelName()] = nil end
end

local max = 0

local mat = Material("fumo/npc_fumo.png")

hook.Add("PostRender","RenderSpawnIcons",function()
    --[[if table.Count(NEEDRENDER) == 0 then max = 0 return end

    max = math.max(max,table.Count(NEEDRENDER))

    cam.Start2D()

    local w,h = ScrW(),ScrH()

    surface.SetDrawColor(0,0,0,200)
    surface.DrawRect(0,0,w,h)

    draw.SimpleText("RENDER MODELS " .. max - table.Count(NEEDRENDER) .. " / " .. max,"HS.25",ScrW() / 2,ScrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

    local wide = w * 0.8

    surface.SetDrawColor(15,15,15,255)
    surface.DrawRect(w / 2 - wide / 2,h / 1.25 - 25,wide,50)

    surface.SetDrawColor(255,255,255,255)
    local k = (max - table.Count(NEEDRENDER)) / max
    surface.DrawRect(w / 2 - wide / 2,h / 1.25 - 25,wide * k,50)

    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(w / 2 - wide / 2 + wide * k,h / 1.25 - 50 - 16,64,64,45 * math.cos(RealTime() * 10))

    cam.End2D()]]--
end)