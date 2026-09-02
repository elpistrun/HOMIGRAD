keyboard.DefaultBindCode("fake",30,true,function() return not input.IsKeyDown(KEY_LALT) end)
keyboard.DefaultBindCode("fake_dead",30,true,function() return input.IsKeyDown(KEY_LALT) end)

event.Add("Player Spawn","Other",function(ply)
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	ply:RemoveAllDecals()
end)

//

local delays = {}

event.Add("Death","RemoveNPClientRagdoll",function(dmgTab)
    local ent = dmgTab.target

    if not IsValid(ent) or not ent:IsNPC() then return end

    local pos = ent:GetPos()
    local mdl = ent:GetModel()

    delays[#delays + 1] = {mdl,pos,RealTime() + LocalPlayer():Ping() + 0.05}
end)

hook.Add("Think","RemoveNPCClientRagdoll",function()
    local time = RealTime()
    
    for id,info in pairs(delays) do
        local mdl = info[1]

        for i,ent in pairs(ents.FindInSphere(info[2],128)) do
            if ent:GetClass() == "class C_ClientRagdoll" and ent:GetModel() == mdl then ent:Remove() end
        end

        if info[3] < time then delays[id] = nil continue end
    end
end)

//

local Clamp = math.Clamp

hook.Add("HUDPaint","Fake",function()
    local ply = LocalPlayer()
    if not ply:GetNWBool("Fake") or GetViewEntity() != ply then return end

    surface.SetDrawColor(255,255,255,255)

    local rag = ply:GetDummy()
    if rag == ply then return end
    
    local w,h = ScrW(),ScrH()

    local wep = ply:GetActiveWeapon()

    local pos = EyePos() + ply:EyeAngles():Forward() * 8000
    pos = pos:ToScreen()

    pos.x = Clamp(pos.x,w / 2 - w / 3,w / 2 + w / 3)
    pos.y = Clamp(pos.y,h / 2 - h / 3,h / 2 + h / 3)
    
    local dis = math.Distance(pos.x,pos.y,w / 2,h / 2) / (h / 2)

    local a = 25 + dis * 255

    local size = math.max(dis * 32,6)

    if IsValid(wep) and wep:GetClass() ~= "weapon_hands" then a = a * 0.35 end
end)

cvars.CreateReplicateOption("hg_ragdoll_always_e","1")
cvars.CreateReplicateOption("hg_ragdoll_cave_spine","1")

hook.Add("HandlePlayerSwimming","!Remove",function()
    return false
end)