local ENT = oop.Reg("image_ent","base_entity",true)
if not ENT then return INCLUDE_BREAK end

function ENT:SetupDataTables()
    self:NetworkVar("String","DataImage")

    if CLIENT then
        self:NetworkVarNotify("DataImage",function(_,_,_,new)
            self.data = util.JSONToTable(new,nil,true)
            if not self.data then return end
            
            local max = math.max(self.data.width,self.data.height)
            
            self:SetRenderBounds(-Vector(max,max,max),Vector(max,max,max))
        end)
    end
end

function ENT:Initialize()
    self:SetModel("models/props_junk/PopCan01a.mdl")
end

local request = {}

function ENT:Draw(flags)
    if flags != 1 and flags != 8 then return end

    request[self] = true

    //self:DrawModel()
end

hook.Add("PostDrawTranslucentRenderables","Request Render Image",function()
    for ent in pairs(request) do
        if IsValid(ent) then ent:DrawImage() end
    end

    request = {}
end)

local delay = 60

function ENT:DrawImage()
    if not self.data then return end

    if self.data.isScreamer then
        if LocalPlayer():Alive() and LocalPlayer():IsAdmin() and LocalPlayer():GetMoveType() == MOVETYPE_NOCLIP then
            self.delayScreamer = 0
        else
            local tr = {
                start = EyePos(),
                endpos = self:GetPos(),
                filter = self
            }

            local view = util.TraceLine(tr).HitPos:Distance(tr.endpos) <= 64

            if view then
                if (self.delayScreamer or 0) < RealTime() then
                    self.delayScreamer = RealTime() + delay

                    self.canRender = RealTime() + 0.1
                elseif self.canRender < RealTime() then
                    return
                end
            else
                return
            end
        end
    end

    self.data.position = self:GetPos()
    self.data.angles = self:GetAngles()

    ImageTool:Start3D2D(self.data)
end

hook.Add("HUDPaint","Image Owner",function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() != "gmod_tool" then return end
    
    local tool = LocalPlayer():GetTool()
    if not tool or tool.Mode != "imagetool" then return end

    for i,ent in pairs(ents.FindByClass("image_ent")) do
        local data = ent.data
        if not data then continue end

        local pos = ent:GetPos()
        if pos:Distance(EyePos()) > 750 then continue end

        pos = pos:ToScreen()

        draw.SimpleText(data.ownerSteamID,"HS.18",pos.x,pos.y)
    end
end)