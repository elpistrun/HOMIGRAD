local BULLET = oop.Get("bullet")
if not BULLET then return end

local list = {}

local hg_dev_balistic

cvars.CreateDevOption("hg_dev_balistic","0",function(value)
    hg_dev_balistic = tonumber(value or 0) > 0
end,0,1)

hook.Add("PostDrawTranslucentRenderables","hg_dev_balistic",function(bDrawingDepth,bDrawingSkybox)
    if not hg_dev_balistic or bDrawingSkybox then return end

    local i = 0
    local time = RealTime()

    for _ = 1,#list do
        i = i + 1

        local info = list[i]
        if not info then break end

        if info.time < time then
            table.remove(list,i)
            i = i - 1

            continue
        end

        render.DrawLine(info.start,info.endpos,info.color)
    end
end)

local color_red = Color(255,0,0)

function BULLET:PhysicalSimulation(ft)
    local add,sub = self:GetTransformDir(ft)

    if hg_dev_balistic then
        list[#list + 1] = {time = RealTime() + 10,start = self.pos:Clone(),endpos = self.pos + add,color = color_red}
    end
    
    self.lastDirTraced = add--for render

    if not self.hitedInSky then
        local traceResult = self:DoTrace(add)

        if traceResult.HitSky then
            self.hitedInSky = true
            self.LifeTime = 3
        elseif traceResult.Hit then
            local result = self:DoHit(traceResult,add,sub)

            if result == true then
                self:SetPVSVar("Hit",true)
                self:ThinkBulletCrack()

                self:DoHitEnd(traceResult)
                
                if self.RemoveOnHit then timer.Simple(1,function() self:Remove() end) end
            elseif result == false then
                return--ИЗМЕНИЛ self.pos
            end
        end
    end

    self.pos:Add(add)
    self.dir:Sub(sub)

    self:ThinkBulletCrack()
end

local ricoshet = {
    "weapons/ricochet/1.wav",
    "weapons/ricochet/2.wav",
    "weapons/ricochet/3.wav",
    "weapons/ricochet/4.wav",
    "weapons/ricochet/5.wav",
    "weapons/ricochet/6.wav",
    "weapons/ricochet/7.wav",
    "weapons/ricochet/8.wav",
    "weapons/ricochet/9.wav",
    "weapons/ricochet/10.wav"
}

local random = math.random

function BULLET:DoHit(traceResult,add,sub)
    local pos = traceResult.HitPos + traceResult.HitNormal
    local sndEmit = sound.GetVurtialEmit(pos)

    local result = self:DoPenetration(traceResult,add,sub)

    if self.CallbackTraceHit then self:CallbackTraceHit(traceResult) end

    if IsValid(traceResult.Entity) and util.IsHumanoid(traceResult.Entity) then return true end
    
    local surfaceName = surfaceWorld.GetSurfaceNameByTrace(traceResult)

    surfaceWorld.CreateSoundBullet(sndEmit,surfaceName)
    surfaceWorld.CreateEffectBullet(pos,traceResult.HitNormal,traceResult.Entity,surfaceName,self.SmokeMul,self.withoutSmoke)

    sound.Emit(sndEmit,ricoshet[random(1,#ricoshet)],70,1,random(81,83))
    
    return result
end

local start = RealTime()

local hg_dev_showhit

cvars.CreateDevOption("hg_dev_showhit","0",function(value)
    hg_dev_showhit = tonumber(value or 0) > 0
end)

net.Receive("hit_detect",function()
    if not hg_dev_showhit then return end

    start = RealTime()

    local snd = "eft/impact/impact_glassshield" .. math.random(1,3) .. "_me.wav"
    sound.EmitScreen(snd,1,100,100)

    snd = "eft/impact/body" .. math.random(1,6) .. ".wav"
    sound.EmitScreen(snd,1,100,100)
end)

local mat = CreateMaterial("HomigradHitMat" .. os.time(),"UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$vertexcolor"] = 1
})

mat:SetTexture("$basetexture",Material("decals/cross_model"):GetTexture("$basetexture"))
mat:Recompute()

hook.Add("HUDPaint","HitDetect",function()
    if not hg_dev_showhit then return end
    
    local k = (start - RealTime() + 0.5) / 0.5

    if k <= 0 then return end

    surface.SetDrawColor(255,255,255,255 * k)
    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(ScrW()/2,ScrH()/2,ScrH() * 0.012,ScrH() * 0.012,0)
end)