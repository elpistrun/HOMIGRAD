temporary.Create("bleed",
function(data)
	net.WriteVector(data[1])
	net.WriteVector(data[2])
end,function(data)
    data[1] = net.ReadVector()
    data[2] = net.ReadVector()
end,function(data)
    gibParticles.bloodDrop.CreatePart(data[1],data[2])
end)

if SERVER then
    function gibParticles.bleedCreate(pos,vel)
        temporary.Output("bleed",pos,vel)
    end
end

temporary.Create("bleed_artery",
function(data)
	net.WriteVector(data[1])
	net.WriteVector(data[2])
end,function(data)
    data[1] = net.ReadVector()
    data[2] = net.ReadVector()
end,function(data)
    gibParticles.bloodDrop.CreatePartArtery(data[1],data[2])
end)

if SERVER then
    function gibParticles.bleedArteryCreate(pos,vel)
        temporary.Output("bleed_artery",pos,vel)
    end
end