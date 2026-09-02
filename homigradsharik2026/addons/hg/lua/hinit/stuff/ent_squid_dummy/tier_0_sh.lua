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

function ENT:DeterminateUse(ply,trace)
    if not IsValid(ply) or not ply:Alive() then return false end
    if trace and IsValid(trace.Entity) and trace.Entity ~= self then return false end

    local eye = ply:EyePos()
    return eye:DistToSqr(self:GetPos()) < (PlayerDisUse + 32) * (PlayerDisUse + 32)
end

if SERVER then
    util.AddNetworkString("squid_dummy")
    util.AddNetworkString("squid_dummy_watch")

    ENT.WatchRadius = 400

    local function IsMoving(ply,pos)
        if not IsValid(ply) or not ply:Alive() or ply:InFake() then return false end
        if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_FLY then return false end

        if not pos then pos = ply:GetPos() end
        return ply:GetVelocity():Length2D() > 90 or (ply:GetPos():DistToSqr(pos) > 64 * 64)
    end

    function ENT:SendMenu(ply)
        local pkg = {
            entIndex = tostring(self:EntIndex()),
            locked = self.LockedBy ~= nil and self.LockedBy ~= ply:SteamID(),
            watch = self.watch[ply:SteamID()] and true or false,
            enabled = self.mode == "enabled"
        }

        net.Start("squid_dummy")
        net.WriteTable(pkg)
        net.Send(ply)
    end

    function ENT:AcceptInput(name,activator,caller)
        if string.lower(name or "") ~= "use" then return end

        local ply = IsValid(activator) and activator:IsPlayer() and activator or (IsValid(caller) and caller:IsPlayer() and caller or nil)
        if not ply then return end

        self:SendMenu(ply)

        return true
    end

    function ENT:OnThink()
        if self.mode ~= "enabled" then return end

        self.nextDetect = self.nextDetect or 0
        if self.nextDetect > CurTime() then return end
        self.nextDetect = CurTime() + (self.delay > 0 and self.delay or 1)

        local pos = self:GetPos()
        local radius = self.WatchRadius

        for _,ply in pairs(player.GetHumans()) do
            if not IsValid(ply) or not ply:Alive() or ply:InFake() then continue end

            local plyPos = ply:GetPos()
            if plyPos:DistToSqr(pos) > radius * radius then continue end

            if not IsMoving(ply,plyPos) then continue end

            for sid in pairs(self.watch) do
                local watcher = player.GetBySteamID(sid)
                if not IsValid(watcher) or not watcher:Alive() then continue end

                net.Start("squid_dummy_watch")
                net.WriteEntity(ply)
                net.Send(watcher)
            end
        end
    end

    local entityThink = {}

    function ENT:OnRemove()
        local key = self:EntIndex()
        if entityThink[key] then
            entityThink[key] = nil
            hook.Remove("Think","HG Squid Dummy " .. key)
        end
    end

    hook.Add("Think","HG Squid Dummy",function()
        for _,ent in pairs(ents.FindByClass("ent_squid_dummy")) do
            if not IsValid(ent) then continue end

            local key = ent:EntIndex()
            if not entityThink[key] then
                entityThink[key] = true
                hook.Add("Think","HG Squid Dummy " .. key,function()
                    if not IsValid(ent) then
                        hook.Remove("Think","HG Squid Dummy " .. key)
                        entityThink[key] = nil
                        return
                    end

                    ent:OnThink()
                end)
            end
        end
    end)

    net.Receive("squid_dummy",function(_,ply)
        if not IsValid(ply) then return end

        local index = tonumber(net.ReadString())
        local action = net.ReadString()

        local ent = Entity(index or 0)
        if not IsValid(ent) or ent:GetClass() ~= "ent_squid_dummy" then return end

        if ent:EyePos():DistToSqr(ply:EyePos()) > (PlayerDisUse + 48) * (PlayerDisUse + 48) then return end

        if action == "locked" then
            if ent.LockedBy and ent.LockedBy ~= ply:SteamID() then return end

            if ent.LockedBy == ply:SteamID() then
                ent.LockedBy = nil
            else
                ent.LockedBy = ply:SteamID()
            end

            ent:SetNWString("LockedBy",ent.LockedBy or "")
        elseif action == "watch" then
            if ent.LockedBy and ent.LockedBy ~= ply:SteamID() then return end

            if ent.watch[ply:SteamID()] then
                ent.watch[ply:SteamID()] = nil
            else
                ent.watch[ply:SteamID()] = true
            end
        elseif action == "enabled" then
            if ent.LockedBy and ent.LockedBy ~= ply:SteamID() then return end

            if ent.mode == "enabled" then
                ent.mode = "watch"
                ent:SetNWFloat("AnimHide",0)
            else
                ent.mode = "enabled"
                ent.nextDetect = 0
                ent:SetNWFloat("AnimHide",1)
            end
        end
    end)

    return
end

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