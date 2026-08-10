local max = math.max

local function determinateEntity(ent,pos)
    local entIndex

    if TypeID(ent) == TYPE_NUMBER then
        ent = Entity(ent)

        if IsValid(ent) then
            entIndex = ent:EntIndex()
            pos = pos or ent:GetPos()
        else
            entIndex = 0
        end
    elseif TypeID(ent) == TYPE_ENTITY then
        entIndex = max(ent:EntIndex(),0)
        pos = pos or ent:GetPos()
    else
        entIndex = 0
    end

    return ent,entIndex,pos
end

if CLIENT then
    local debugMode = false

    cvars.CreateOption("hg_dev_sound","0",function(value)
        if not LocalPlayer():IsSuperAdmin() then return end
        
        debugMode = (tonumber(value) or 0) > 0
    end)

    local tempSoundData = {}

    --[[
        в ogg можно хранить больше 0 дцб и игра будет воспроизводить звук громче чем wav
        движок может панаромировать стерео если это ogg файл

        нельзя воспроизводить одновремено несколько dsp, только один и звук не будет шакалится
    ]]--

    local function soundEmit(ent,sndName,pos,entIndex,volume,level,pitch,dsp,chan,flags)
        dsp = 0
        if not sound.Trace(pos,EyePos(),ent) then dsp = 30 end
    
        pitch = pitch or 100
        pitch = pitch * HostTimeScale

        if ent and ent:EntIndex() == -1 then
            ent:EmitSound(sndName,level,pitch,volume,chan,flags,dsp)
        else
            EmitSound(sndName,pos,entIndex,chan,volume,level,flags,pitch,dsp)
        end

        if debugMode then debugoverlay.Text(pos + VectorRand(),sndName,3) end
    end

    function sound.Emit(ent,sndName,level,volume,pitch,pos,dsp,filter,chan,flags)
        chan = chan or CHAN_AUTO
        local ent,entIndex,pos = determinateEntity(ent,pos)
        
        local metrs = pos:Distance(EyePos()) * UNITS_TO_METERS
        
        if metrs > SOUND_LESS_METERS_PLAY_INSTANT then
            timer.GameSimple(metrs / SOUND_SPEED,function()
                soundEmit(ent,sndName,pos,entIndex,volume,level,pitch,dsp,chan,flags)
            end)
        else
            soundEmit(ent,sndName,pos,entIndex,volume,level,pitch,dsp,chan,flags)
        end

        if debugMode then debugoverlay.Text(pos + VectorRand(),sndName,3) end
    end

    function sound.EmitPanorama(panoramaEffect,sndName,level,volume,pitch,pos,dsp,filter,chan,flags)
        chan = chan or CHAN_AUTO

        local ent = sound.GetVurtialEmit(pos,id,5)
        ent.pos = pos
        ent.Think = sound.ThinkGoAway
        ent.panoramaEffect = panoramaEffect or 0.6
        ent:Think()
        
        local metrs = pos:Distance(EyePos()) * UNITS_TO_METERS
        
        if metrs > SOUND_LESS_METERS_PLAY_INSTANT then
            timer.GameSimple(metrs / SOUND_SPEED,function()
                soundEmit(ent,sndName,pos,entIndex,volume,level,pitch,dsp,chan,flags)
            end)
        else
            soundEmit(ent,sndName,pos,entIndex,volume,level,pitch,dsp,chan,flags)
        end

        if debugMode then debugoverlay.Text(pos + VectorRand(),sndName,3) end

    end

    function sound.EmitNative(ent,sndName,level,volume,pitch,pos,dsp,chan,flags)
        chan = chan or CHAN_AUTO
        local ent,entIndex,pos = determinateEntity(ent,pos)

        pitch = pitch or 100
        pitch = pitch * HostTimeScale

        if ent and ent:EntIndex() == -1 then
            ent:EmitSound(sndName,level,pitch,volume,chan,flags,dsp)
        else
            EmitSound(sndName,pos,entIndex,chan,volume,level,flags,pitch,dsp)
        end

        if debugMode then debugoverlay.Text(pos + VectorRand(),sndName,3) end
    end

    sound.EmitNET = sound.Emit

    net.Receive("sound.Emit",function()
        sound.Emit(
            4096 + net.ReadInt(13),
            net.ReadString(),
            128 + net.ReadInt(8),
            net.ReadFloat(),
            128 + net.ReadInt(8),
            net.ReadVector(),
            128 + net.ReadInt(8),
            net.ReadEntity(),
            128 + net.ReadInt(8),
            512 + net.ReadInt(10)
        )
    end)

    net.Receive("sound.EmitPanorama",function()
        sound.EmitPanorama(
            net.ReadFloat(),
            net.ReadString(),
            128 + net.ReadInt(8),
            net.ReadFloat(),
            128 + net.ReadInt(8),
            net.ReadVector(),
            128 + net.ReadInt(8),
            net.ReadEntity(),
            128 + net.ReadInt(8),
            512 + net.ReadInt(10)
        )
    end)


    local vec_zero = Vector(0,0,0)

    function sound.EmitScreen(sndName,volume,pitch,level)
        EmitSound(sndName,vec_zero,-2,CHAT_ITEM,volume or 1,level or 75,nil,pitch or 100)
    end

    net.Receive("sound.EmitSurface",function()
        sound.EmitScreen(net.ReadString(),net.ReadFloat(),128 + net.ReadInt(8))
    end)
else
    util.AddNetworkString("sound.Emit")
    util.AddNetworkString("sound.EmitPanorama")
    util.AddNetworkString("sound.EmitSurface")

    function sound.EmitNET(ent,sndName,level,volume,pitch,pos,dsp,filter,chan,flags)
        chan = chan or CHAN_AUTO

        local ent,entIndex,pos = determinateEntity(ent,pos)

        net.Start("sound.Emit",true)
        net.WriteInt(entIndex - 4096,13)
        net.WriteString(sndName)
        net.WriteInt((level or 75) - 128,8)
        net.WriteFloat(volume or 1)
        net.WriteInt((pitch or 100) - 128,8)
        net.WriteVector(pos)
        net.WriteInt((dsp or 1) - 128,8)
        net.WriteEntity(filter or NULL)
        net.WriteInt(chan - 128,8)
        net.WriteInt((flags or 0) - 512,10)
    end

    function sound.Emit(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
        chan = chan or CHAN_AUTO

        sound.EmitNET(ent,sndName,level,volume,pitch,pos,dsp,filter,chan)
        net.Broadcast()
    end

    function sound.EmitPanoramaENT(panoramaEffect,sndName,level,volume,pitch,pos,dsp,filter,chan,flags)
        chan = chan or CHAN_AUTO

        local ent,entIndex,pos = determinateEntity(ent,pos)

        net.Start("sound.EmitPanorama",true)
        net.WriteFloat(panoramaEffect)
        net.WriteString(sndName)
        net.WriteInt((level or 75) - 128,8)
        net.WriteFloat(volume or 1)
        net.WriteInt((pitch or 100) - 128,8)
        net.WriteVector(pos)
        net.WriteInt((dsp or 1) - 128,8)
        net.WriteEntity(filter or NULL)
        net.WriteInt(chan - 128,8)
        net.WriteInt((flags or 0) - 512,10)
    end

    function sound.EmitPanorama(panoramaEffect,sndName,level,volume,pitch,pos,dsp,filter,chan)
        chan = chan or CHAN_AUTO

        sound.EmitPanoramaENT(panoramaEffect,sndName,level,volume,pitch,pos,dsp,filter,chan)
        net.Broadcast()
    end

    FindMetaTable("Player").EmitSurface = function(self,sndName,volume,pitch)
        net.Start("sound.EmitSurface")
        net.WriteString(sndName)
        net.WriteFloat(volume or 1)
        net.WriteInt((pitch or 100) - 128,8)
        net.Send(self)
    end

    function sound.EmitScreen(sndName,volume,pitch)
        net.Start("sound.EmitSurface")
        net.WriteString(sndName)
        net.WriteFloat(volume or 1)
        net.WriteInt((pitch or 100) - 128,8)
        net.Broadcast()
    end
end