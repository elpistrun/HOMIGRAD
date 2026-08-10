local SWEP = oop.Get("wep_melee_base")
if not SWEP then return end

local cmd = {
    name = "attack_primary"
}

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end

    if self.Primary.Disable then return end

    local pos,ang = self:GetShootMatrix()
    local typeAttack = 1

    for k in pairs(cmd) do cmd[k] = nil end
    
    cmd.name = "attack_primary"
    cmd.type = "primary"
    cmd.pos = pos
    cmd.ang = ang
    cmd.renderTime = GetRenderTime()

    if self:CanDoAction(cmd) then self:DoInputAttackClient(cmd) end
end

local cmd = {
    name = "attack_secondary"
}

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    if self.Secondary.Disable then return end

    for k in pairs(cmd) do cmd[k] = nil end

    cmd.name = "attack_secondary"
    cmd.type = "secondary"
    cmd.pos = pos
    cmd.ang = ang
    cmd.renderTime = GetRenderTime()

    if self:CanDoAction(cmd) then self:DoInputAttackClient(cmd) end
end

function SWEP:DoInputAttackClient(cmd)
    if cmd.type == "secondary" and self.Secondary.Throw then
        cmd.name = "attack_throw"
    elseif cmd.type == "primary" then
        if self.sequenceObject and self.sequenceObject.name == "attack_throw_start" then return end
    end

    self:DoAction(cmd)
end

function SWEP:PreCalcView(ply,view)
    self:CalcViewAnimation(ply,view)
end

function SWEP:CreateWorldModelBodygroup() end

function SWEP:CreateWorldModelPost(wm,tag,typeDraw,depth,mdlName)
    self:CreateWorldModelBodygroup(wm)

    if wm.csmLocalTag == "CameraModel" then return end

    self:TextureUV_Update(wm)
end

function SWEP:TextureUV_Update(wm)
    local subIndex = self.TextureSubIndex or 0

    local materials = wm:GetMaterials()
    local textureName = self.TextureMaterialName or materials[1 + subIndex]

    if not textureName then--content model and world model is different, ебаный костыль похуйй
        textureName = materials[1]
        subIndex = 0
    end

    local texture = texture_uv.GetOriginal(textureName)
    local rt = texture_uv.GetQuick(wm,subIndex,textureName,"melee_weapon_")

    local layer = texture_uv.GetLayer(rt)

    local w,h = layer:Width(),layer:Height()
    render.PushRenderTarget(layer,0,0,w,h)
        texture_uv.Start()
        render.SetColorModulation(1,1,1)
        if self:GetPVSVar("IsBlooded") then self:TextureUV_PaintBlood(w,h) end
        texture_uv.End()
    render.PopRenderTarget()

    texture_uv.PaintTexture(rt,texture)
    texture_uv.PaintLayer(rt,layer,255)
end

SWEP.textureUVBlood_X = 0
SWEP.textureUVBlood_Y = 0

function SWEP:TextureUV_PaintBlood(w,h)
    local unlitGeneric = gibParticles.bloodDrop.unlitGeneric
    
    for i = 1,#unlitGeneric do
        surface.SetMaterial(unlitGeneric[i])
        surface.SetDrawColor(255,0,0)
        surface.DrawTexturedRect(w * self.textureUVBlood_X,h * self.textureUVBlood_Y,w,h)
    end
end

SWEP:Event_Add("Init","IsBlooded",function(self)
    self:ProxyPVSVar("IsBlooded",function(self,old,new)
        local wm = self.wm
        if not IsValid(wm) then return end

        self:TextureUV_Update(wm)
    end)
end)
