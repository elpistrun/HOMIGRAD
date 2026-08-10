local Level = oop.Get("level_nextbot")
if not Level then return end

local startBlock = 0

local function StartBlock(ply)
    sound.Emit(ply:EntIndex(),"weapons/melee/swing_fists_0" .. math.random(1,3) .. ".wav",90,1,math.random(99,101),ply:GetPos())

    local pos = ply:EyePos() + Vector(45,0,0):Rotate(ply:EyeAngles())
    
    local emitter = ParticleEmitter(pos,true)
    local part = emitter:Add("particle/particle_ring_wave_addnofog",pos)
    if part then
        local ang = ply:EyeAngles()
        ang:RotateAroundAxis(ang:Right(),90 + math.Rand(5,15) * (math.random(0,1) == 1 and -1 or 1))
        ang:RotateAroundAxis(ang:Up(),math.Rand(5,15) * (math.random(0,1) == 1 and -1 or 1))
        
        part:SetAngles(ang)

        part:SetColor(255,255,255)

        part:SetDieTime(0.6)
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)

        part:SetStartSize(35)
        part:SetEndSize(125)
    end

    emitter:Finish()
end

net.Receive("nextbot_def",function()
    StartBlock(net.ReadEntity())
end)

function Level:StartBlock()//Client side
    startBlock = RealTime()

    StartBlock(LocalPlayer())
end

function Level:PreCalcView(ply,view)
    if not ply:Alive() or GetViewEntity() ~= ply then return end

    local k = math.max(startBlock + 0.25 - RealTime(),0) / 0.25

    view.ang = view.ang + Angle(-1 * k,0,2 * math.sin(CurTime() * 15) * k)
    view.drawviewer = false

    return view
end

net.Receive("nextbot_def_accept",function()
    local nextbot = net.ReadEntity()
    local pos = net.ReadVector()

    if IsValid(nextbot) then
        local flash = DynamicLamp(pos,math.Rand(485,545),1000 / (1 / 24))
        flash:SetColor(Color(175,175,255))
        flash:SetBrightness(15):SetTexture("effects/flashlight/soft"):Spawn()
    end

    sound.Emit(nil,"physics/rubber/rubber_tire_impact_hard" .. math.random(1,3) .. ".wav",90,1,math.random(99,101),pos)
    for i = 1,3 do sound.Emit(nil,"physics/metal/metal_sheet_impact_bullet" .. math.random(1,2) .. ".wav",90,1,math.random(99,101),pos) end
    sound.Emit(nil,"snd_jack_fragsplodefar.ogg",90,1,math.random(99,101),pos)
end)

net.Receive("nextbot_def_back",function()
    local nextbot = net.ReadEntity()
    local pos = net.ReadVector()

    sound.Emit(nil,"weapons/melee/flesh_impact_sharp_0" .. math.random(1,6) .. ".wav",90,1,math.random(99,101),pos)

    local emitter = ParticleEmitter(pos)

    for i = 1,math.random(35,45) do
        local part = emitter:Add(ParticleMatSmoke[math.random(1,#ParticleMatSmoke)],pos)
    
        if part then
            part:SetColor(255,0,0)
    
            part:SetDieTime(3)
            part:SetStartAlpha(255)
            part:SetEndAlpha(0)
    
            part:SetStartSize(math.Rand(5,10))
            part:SetEndSize(0)
    
            part:SetGravity(ParticleGravity*4)
            part:SetVelocity(Vector(-math.Rand(256,1024),0,0):Rotate(Angle(math.Rand(45,75),math.Rand(-180,180),0)))
        end
    end
    
    emitter:Finish()
end)