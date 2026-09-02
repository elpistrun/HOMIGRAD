local math_hand1 = Material("icon32/hand_point_180.png")
local math_hand2 = Material("icon32/hand_point_090.png")

local Clamp = math.Clamp

local casual_nigger = (ConVarExists("hg_casual") and GetConVar("hg_casual") or CreateClientConVar("hg_casual","0",true,false,"казуал плееры идут нахуй!",0,1))

local function GetHandPos(rag,name)
    local boneId = rag:LookupBone(name)
    if not boneId or boneId < 0 then return end
    return rag:GetBonePosition(boneId)
end

hook.Add("HUDPaint","FakeIndicators",function()
    local ply = LocalPlayer()
    if not ply:GetNWBool("Fake") then return end
    if not casual_nigger:GetBool() then return end

    surface.SetDrawColor(255,255,255,255)

    local rag = ply:GetDummy()
    if rag == ply or not IsValid(rag) then return end

    local w,h = ScrW(),ScrH()

    if ply:GetNWBool("LeftArm") then
        local hand = GetHandPos(rag,"ValveBiped.Bip01_L_Hand")
        if not hand then return end

        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand2)
        surface.DrawTexturedRectRotated(pos.x,pos.y,64,64,-90 + 25)
    end

    if ply:GetNWBool("RightArm") then
        local hand = GetHandPos(rag,"ValveBiped.Bip01_R_Hand")
        if not hand then return end

        local pos = hand:ToScreen()
        pos.x = Clamp(pos.x,w / 2 - w / 4,w / 2 + w / 4)
        pos.y = Clamp(pos.y,h / 2 - h / 4,h / 2 + h / 4)

        surface.SetMaterial(math_hand1)
        surface.DrawTexturedRectRotated(pos.x,pos.y,-64,-64,180 - 25)
    end
end)