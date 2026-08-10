local ENT = oop.Reg("ent_squid_dummy","base_entity",true)
if not ENT then return INCLUDE_BREAK end

ENT.Category = "Squid Game"
ENT.PrintName = "Dummy Move Detect"
ENT.Spawnable = true

ENT.DrawWeaponSelection = DrawWeaponSelection
ENT.OverridePaintIcon = OverridePaintIcon

ENT.WorldModel = "models/kerry/doll/doll.mdl"
ENT.dwsItemPos = Vector(0,0,-70)
ENT.dwsItemAng = Angle(0,90,0)

function ENT:Initialize()
    self:SetModel(self.WorldModel)

    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:PhysicsInit(SOLID_OBB)

    self:SetCollisionBounds(Vector(-16,-16,0),Vector(16,16,72))

    self:GetPhysicsObject():SetMass(100)

    self.settings = {
        watch = {}
    }

    self.mode = "watch"
    self.delay = 0

    self.watch = {}
end

if SERVER then return end

function ENT:Draw()
    local anim = self:GetNWFloat("AnimHide",0)
    
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_UpperArm"),Angle(0,-70,0):Mul(anim),false)
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_UpperArm"),Angle(0,-70,0):Mul(anim),false)

    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Forearm"),Angle(15,-100,0):Mul(anim),false)
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Forearm"),Angle(-15,-100,0):Mul(anim),false)
    
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_R_Hand"),Angle(30,-30,90):Mul(anim),false)
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_L_Hand"),Angle(-30,-30,-90):Mul(anim),false)

    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Spine"),Angle(0,0,0):Mul(anim),false)
    self:ManipulateBoneAngles(self:LookupBone("ValveBiped.Bip01_Head1"),Angle(0,-20,0):Mul(anim),false)

    self:SetupBones()
    self:DrawModel()
end

function ENT:HUDTarget(ply,k,w,h)
    if PieMenu:IsOpen() then return false end
    
    local lockedBy = self:GetNWString("LockedBy","")
    if lockedBy ~= "" and lockedBy ~= LocalPlayer():SteamID() then return false end

    draw.SimpleText(L(self.PrintName),"HS.18",w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

net.Receive("squid_dummy",function()
    local pkg = net.ReadTable()

    PieMenu:Init()

    local option = PieMenu:CreateOption()

    if pkg.locked then
        option.title = "Открыть"
        option.desc = "Открыть другим людям для взаимодействия"
        option.icon = Material("icon16/key_delete.png")
    else
        option.title = "Закрыть"
        option.desc = "Запрещает доступ к изменению другим людям"
        option.icon = Material("icon16/key_add.png")
    end

    option.callback = function()
        net.Start("squid_dummy")
        net.WriteString(pkg.entIndex)
        net.WriteString("locked")
        net.SendToServer()
    end

    local option = PieMenu:CreateOption()

    if pkg.watch then
        option.title = "Отключится от кукле"
        option.desc = "Помечает противников на экране"
        option.icon = Material("icon16/ipod_cast_delete.png")
    else
        option.title = "Подключится к кукле"
        option.desc = "Помечает противников на экране"
        option.icon = Material("icon16/ipod_cast_add.png")
    end

    option.callback = function()
        net.Start("squid_dummy")
        net.WriteString(pkg.entIndex)
        net.WriteString("watch")
        net.SendToServer()
    end

    local option = PieMenu:CreateOption()
    
    if pkg.enabled then
        option.title = "Остановить"
        option.desc = ""
        option.icon = Material("icon16/delete.png")
    else
        option.title = "Запустить"
        option.desc = ""
        option.icon = Material("icon16/accept.png")
    end

    option.callback = function()
        net.Start("squid_dummy")
        net.WriteString(pkg.entIndex)
        net.WriteString("enabled")
        net.SendToServer()
    end

    PieMenu:Open()
end)

local watch = {}

net.Receive("squid_dummy_watch",function()
    watch[net.ReadEntity()] = RealTime() + 1    
end)

local red = Color(255,75,75)

hook.Add("HUDPaint","Squid Dummy Watch",function()
    for ent,time in pairs(watch) do
        if not IsValid(ent) then watch[ent] = nil continue end

        local k = math.max(time - RealTime(),0)
        if k <= 0 then watch[ent] = nil continue end

        surface.SetAlphaMultiplier(k)

        local pos = ent:GetPos():Add(ent:OBBCenter()):ToScreen()
        if not pos.visible then continue end

        draw.SimpleText("MOVE","HS.18",pos.x,pos.y,red,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    surface.SetAlphaMultiplier(1)
end)