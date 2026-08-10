event.Add("Player Think","Breath Bone",function(ply)
    local time = ply.breathTime
    if not time then return end

    local delay = ply.breathDelay
    local mode = ply.breathMode

    local anim = (mode == "out" and 1 or 0) - (ply.breathTime - CurTime() + ply.breathDelay) / ply.breathDelay

    anim = math.cos(math.rad(180 * anim))

    if ply:KeyDown(IN_DUCK) then anim = anim / 5 end

    ply.breathAnim = LerpFT(0.8,ply.breathAnim or 0,anim)
end)

function PlayerBones_Breath(ply,tag,link)
    if not ply:IsPlayer() then return end

    local k = ply:GetBreathAnimK()
    if k == 0 then return end

    ply:AddBoneAng("spine",Angle(0,-k * 10,0))
end

FindMetaTable("Player").GetBreathAnimK = function(self)
    return (self.breathAnim or 0) * (1 - (self.breathDelay or 0))
end