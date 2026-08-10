if CLIENT then
    net.Receive("debugoverlay.BoxAngles",function()
        debugoverlay.BoxAngles(net.ReadVector(),net.ReadVector(),net.ReadVector(),net.ReadAngle(),net.ReadFloat(),net.ReadColor())
    end)

    net.Receive("debugoverlay.Text",function()
        debugoverlay.Text(net.ReadVector(),net.ReadString(),net.ReadFloat(),net.ReadBool())
    end)

    net.Receive("debugoverlay.Sphere",function()
        debugoverlay.Sphere(net.ReadVector(),net.ReadFloat(),net.ReadFloat(),net.ReadColor())
    end)

    net.Receive("debugoverlay.Line",function()
        debugoverlay.Line(net.ReadVector(),net.ReadVector(),net.ReadFloat(),net.ReadColor())
    end)
else
    util.AddNetworkString("debugoverlay.BoxAngles")
    util.AddNetworkString("debugoverlay.Text")
    util.AddNetworkString("debugoverlay.Sphere")
    util.AddNetworkString("debugoverlay.Line")
end

debugoverlayNet = debugoverlayNet or {}

function debugoverlayNet.BoxAngles(pos,mins,maxs,ang,lifetime,color)
    if CLIENT then
        debugoverlay.BoxAngles(pos,mins,maxs,ang,lifetime,color)
    else
        net.Start("debugoverlay.BoxAngles",true)
        net.WriteVector(pos)
        net.WriteVector(mins)
        net.WriteVector(maxs)
        net.WriteAngle(ang)
        net.WriteFloat(lifetime)
        net.WriteColor(color)
        net.Broadcast()
    end
end

function debugoverlayNet.Text(pos,text,lifetime,viewCheck)
    if CLIENT then
        debugoverlay.Text(pos,text,lifetime,viewCheck)
    else
        net.Start("debugoverlay.Text",true)
        net.WriteVector(pos)
        net.WriteString(text)
        net.WriteFloat(lifetime)
        net.WriteBool(viewCheck)
        net.Broadcast()
    end
end

function debugoverlayNet.Sphere(pos,size,lifeTime,color)
    if CLIENT then
        debugoverlay.Sphere(pos,size,lifeTime,color)
    else
        net.Start("debugoverlay.Sphere",true)
        net.WriteVector(pos)
        net.WriteFloat(size)
        net.WriteFloat(lifeTime)
        net.WriteColor(color)
        net.Broadcast()
    end
end

function debugoverlayNet.Line(pos,posend,lifeTime,color)
    if CLIENT then
        debugoverlay.Line(pos,posend,lifeTime,color)
    else
        net.Start("debugoverlay.Line",true)
        net.WriteVector(pos)
        net.WriteVector(posend)
        net.WriteFloat(lifeTime)
        net.WriteColor(color)
        net.Broadcast()
    end
end
