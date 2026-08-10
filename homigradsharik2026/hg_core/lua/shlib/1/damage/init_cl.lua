hg_damage_showhealth = CreateClientConVar("hg_damage_showhealth","0",false)

event.Add("HUDPaint","ShowHealth",function(lply)
    if not hg_damage_showhealth:GetBool() then return end

    if not lply:IsAdmin() then
        draw.SimpleText("пенисы мои любимые","ChatFont",ScrW() / 2,SCrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        return
    end

    local ent = lply:GetEyeTrace().Entity
    if not IsValid(ent) or not ent.Health then return end

    draw.SimpleText(tostring(ent:Health()),"ChatFont",ScrW() / 2,ScrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end)

local logs = {}

net.Receive("damage log",function()
    --logs[#logs + 1] = {CurTime(),5,net.ReadTable()}
    PrintTable(net.ReadTable())
end)

/*
event.Add("HUDPaint","ShowHealth",function(lply)
    if not hg_damage_showlogs:GetBool() then return end

    if not lply:IsAdmin() then
        draw.SimpleText("пенисы мои любимые","ChatFont",ScrW() / 2,ScrH() / 2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)

        return
    end

    local i = 1
    local text = ""

    while true do
        local log = logs[i]
        if not log then break end

        local k = log[1] + log[2] - CurTime()

        if k <= 0 then table.remove(logs,i) continue end

        local tab = log[3]
        text = text .. "<a" .. math.Round(k,3) .. "," .. tab.dmg .. " > " .. tab.logInput.dmg .. "\n"

        for i,kill in pairs(tab.killReason) do
            text = text .. kill .. "\n"
        end

        i = i + 1
    end

    text = string.sub(text,1,#text - 1)

    draw.RichText(text,ScrW(),0,nil,nil,-1)
end)*/

hook.Add("ScalePlayerDamage","Homigrad",function() return true end)

net.Receive("death",function()
    event.Call("Death",net.ReadTable())
end)

event.Add("Death","Player",function(dmgTab)
    local ply = dmgTab.target
    if not IsValid(ply) or not ply:IsPlayer() then return end

    event.Call("Player Death",ply,dmgTab)
end)

DeathStartTime = DeathStartTime or 0

event.Add("Player Death","LocalPlayer",function(ply,dmgTab)
    if ply == LocalPlayer() then
        DeathDmgTab = dmgTab
        DeathStartTime = CurTime()
    end
end)

event.Add("PlayerSpawn","LocalPlayer",function(ply)
    if ply == LocalPlayer() then
        DeathStartTime = 0--uff
    end
end)

local ENTITY = FindMetaTable("Entity")

function ENTITY:SetAlive(value) self:SetSaveValue("m_lifeState",value and 0 or 2) end