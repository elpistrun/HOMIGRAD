local Index_Registry_Event = function(name,manual) surfaceWorld.Index_Registry_Event(name,"steps",manual) end

local FOOTSTEP_VOLUME = 0.25
local LAND_VOLUME = 0.6

local snd_land_default = {"homigrad/player/land1.wav","homigrad/player/land2.wav","homigrad/player/land3.wav","homigrad/player/land4.wav"}

-- Base

Index_Registry_Event("default",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/concrete_ct_",1,17,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = snd_land_default,
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("glass",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/glass_",1,13,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_glass_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("rubber",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/bass_",1,10,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_rubber_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("chainlink",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/metal_chainlink_",1,7,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_metal_grate_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

-- Concrete

Index_Registry_Event("concrete",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/concrete_ct_",1,17,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_concrete_",1,1,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("tile",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/tile_",1,14,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_tile_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

-- Wood

Index_Registry_Event("wood",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/wood_",1,15,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = snd_land_default,
		volume = LAND_VOLUME
	}
})

-- Sand

Index_Registry_Event("dirt",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/dirt_",1,14,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_dirt_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("sand",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/sand_",1,12,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_sand_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("grass",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/grass_",1,13,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_grass_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("gravel",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/gravel_",1,11,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_gravel_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("snow",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/snow_",1,12,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_snow_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("mud",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/mud_",1,9,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_mud_",1,5,".wav"),
		volume = LAND_VOLUME
	}
})

-- Metal

Index_Registry_Event("metal",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/metal_solid_",1,16,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_metal_solid_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("metalvent",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/metal_auto_",1,6,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_metal_vent_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("metalgrate",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/metal_grate_",1,15,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_metal_grate_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

Index_Registry_Event("metalvehicle",{
	foot = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/metal_auto_",1,6,".wav"),
		volume = FOOTSTEP_VOLUME
	},
	land = {
		list = sound.CreateFormatedListZero("homigrad/player/footsteps/land_metal_vent_",1,6,".wav"),
		volume = LAND_VOLUME
	}
})

local Fast = surfaceWorld.Fast.steps
local remove,random = table.remove,math.random

local function getRandomFromAviable(self,name,list)
	self.steps = self.steps or {}
	
	local aviable = self.steps[name]

	if not aviable or #aviable == 0 then
		aviable = {}

		for k,v in pairs(list) do aviable[k] = v end
	end

	local id = random(1,#aviable)
	local snd = aviable[id]
	remove(aviable,id)

	return snd
end

local mins,maxs = Vector(),Vector()

local tr = {
	mins = mins,
	maxs = maxs
}

player.GetFootstepSurface = function(ply)
	local pos = ply:GetPos()

	local min = ply:OBBMins()
	mins[1] = min[1]
	mins[2] = min[2]
	
	local max = ply:OBBMaxs()
	maxs[1] = max[1]
	maxs[2] = max[2]

	pos[3] = pos[3] + max[3]
	tr.start = pos

	pos = pos:Clone()
	pos[3] = pos[3] - max[3] - 16
	tr.endpos = pos

	tr.filter = ply:GetDummy()

	local result = util.TraceHull(tr)

	return surfaceWorld.GetSurfaceName(result.SurfaceProps),result.HitPos + result.HitNormal
end

SOUND_FOOTSTEP_METRS = 20
SOUND_LAND_METRS = 30

local filter

if SERVER then
	filter = RecipientFilter()
end

event.Add("Footstep","Sound",function(ply,footSide,surfaceName,pos)
	local surfaceData = Fast[surfaceName] or Fast.default
	surfaceData = surfaceData.foot

	local snd = getRandomFromAviable(ply,surfaceName,surfaceData.list)

	local volume = surfaceData.volume / (ply:IsSprinting() and 1.5 or 3)

	if SERVER then
		sound.EmitNET(nil,snd,75,volume,100,pos)
		filter:RemoveAllPlayers()
		filter:AddPAS(pos)
		filter:RemovePlayer(ply)
		net.Send(filter)
	else
		sound.Emit(ply,snd,75,volume,100,pos)
	end

	return true
end,100)

event.Add("Landing","Sound",function(ply,inWater,onFloat,speed,surfaceName,pos)
	if CLIENT and ply != LocalPlayer() then return end

	local surfaceData = Fast[surfaceName] or Fast.default
	surfaceData = surfaceData.land

	local snd = getRandomFromAviable(ply,surfaceName,surfaceData.list)

	if SERVER then
		sound.EmitNET(nil,snd,75,surfaceData.volume,100,pos)
		filter:RemoveAllPlayers()
		filter:AddPAS(pos)
		filter:RemovePlayer(ply)
		net.Send(filter)
	else
		sound.Emit(ply,snd,80,surfaceData.volume / 2,100,pos)
	end

	return true
end,100)

--

hook.Add("PlayerFootstep","SHLib",function(ply,pos,foot,snd,volume,filter) return true end)

hook.Add("OnPlayerHitGround","SHLib",function(ply,inWater,onFloat,speed)
	if (ply.move_lastLandTime or 0) > RealTime() then return end
	ply.move_lastLandTime = RealTime() + 0.2

	local surfaceName,pos = player.GetFootstepSurface(ply)

	return event.Call("Landing",ply,inWater,onFloat,speed,surfaceName,pos)
end)

event.Add("Player Create","startJump",function(ply) ply.startJump = 0 end)

hook.Add("OnPlayerJump","SHLib",function(ply,speed)
	ply.startJump = CurTime()

	return event.Call("Jump",ply,speed)
end)