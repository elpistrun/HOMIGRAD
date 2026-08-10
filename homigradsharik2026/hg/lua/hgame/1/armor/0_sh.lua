armorGame = ManagerCreate("armorGame",{"node","node_network_user"})

armorGame.config = armorGame.config or {}
armorGame.config_toggle = armorGame.config_toggle or {}
armorGame.category = armorGame.category or {}

function armorGame.Update()
	if Initialize then timer.Create("armorGame.Update",0,1,function() armorGame:Event_Call("Update") end) end
end

function armorGame.Reg(name,data,...)
	armorGame.Update()
	
	for i,tbl in pairs({...}) do util.tableLink(data,tbl) end

	return classFastManager.Reg(armorGame.config,armorGame.config_toggle,armorGame.category,name,data)
end

function armorGame.RegCategory(name,data)
	return classFastManager.RegCategory(armorGame.category,name,data)
end

function armorGame.GetConfig(armorData)
	if armorData.toggle then
		return armorGame.config_toggle[armorData.armorName][armorData.toggle]
	else
		return armorGame.config[armorData.armorName]
	end
end

--

armorGame.category_attachment = armorGame.category_attachment or {}

function armorGame.RegAtt(name,data,...)
	armorGame.Update()

	for i,tbl in pairs({...}) do util.tableLink(data,tbl) end

	return classFastManager.Reg(attachmentGame.config,attachmentGame.config_toggle,armorGame.category_attachment,name,data)
end

function armorGame.RegAttCategory(name,data)
	return classFastManager.RegCategory(armorGame.category_attachment,name,data)
end

function armorGame.GetConfigAttachment(attData)
	if attData.toggle then
		return attachmentGame.config_toggle[attData.keyName][attData.toggle]
	else
		return attachmentGame.config[attData.keyName]
	end
end

--

function armorGame.Create(object)
	object.Armors = {
		native = {},
		slots = {},

		parent = object
	}
end

function armorGame.IsFace(slots)
	return slots.mask or slots.head or slots.headset
end

function armorGame.IsBody(slots)
	return slots.chest
end

function armorGame.Give(Armor,armorName,data,typeCall)
	local config = armorGame.config[armorName]
	if not config then error("armorGame.Give " .. tostring(armorName) .. " is not exists") end
	
	local existsData = Armor.native[armorName] or data or {}
	Armor.native[armorName] = existsData
	
	if data then
		existsData.integrity = data.integrity or 1
		existsData.color = data.color
	end

	existsData.armorName = armorName

	local armorSlots = config.slots

	for slotName in pairs(armorSlots) do
		Armor.slots[slotName] = armorName
	end

	existsData.isFace = armorGame.IsFace(armorSlots)
	existsData.isBody = armorGame.IsBody(armorSlots)
	
	armorGame:Event_Call("Give",Armor,armorName,data or {},typeCall)

	return Armor.native[armorName]
end

function armorGame.Remove(Armor,armorName,typeCall,ent)
	local data = Armor.native[armorName]
	if not data then return false end

	data = data.data

	armorGame:Event_Call("Remove",Armor,armorName,typeCall,ent)

	Armor.native[armorName] = nil

	for slotName in pairs(armorGame.config[armorName].slots) do
		Armor.slots[slotName] = nil
	end

	return data
end

function armorGame.SlotsIsEmpty(Armor,requiredSlots)
	for slotName in pairs(requiredSlots) do
		if Armor.slots[slotName] then return false,slotName,Armor.slots[slotName] end
	end

	return true
end

adminPanel.commandRegistry("bot_armor_test",{"string"},"game")

event.Add("Player Create","Armor",function(ply)
	ply:SetupNWTable("Armor")
end)

--[[timer.Create("TESTBULLET",1 / 4,0,function()
	local ang = Angle(math.Rand(0,-1),math.Rand(-2,2),0)
	local pos = Vector(0,2000,-12700)

	local bulletInfo = ammoGame.config["46x30_fmj"]
	
	local bullet = customEnts.Create("bullet")
	bullet.pos = pos:Clone()

	local speed = bulletInfo.Speed or 676
	bullet:SetDir(Vector(speed,0,0):Rotate(ang))
	bullet:SetAngularDir(Vector(speed,0,0):Rotate(ang))

	bullet.startTime = UnPredictedCurTime()

	bullet:SetClassBullet("46x30_fmj")

	bullet.CallbackDamage = function(bullet,dmgTab)
		dmgTab.noHeadshot = bulletInfo.noHeadshot
	end

	bullet:Spawn()
end)]]--

modelSetting.Fast.ArmorOffset = modelSetting.Fast.ArmorOffset or {}
local modelSetting_ArmorOffset = modelSetting.Fast.ArmorOffset

local vecZero = Vector(0,0,0)
local angZero = Angle(0,0,0)

local varVector,varAngle = Vector(),Angle()

local VecSet,AngSet = Vector(),Angle()

local MatrixLocal = Matrix()
local MatrixSet = Matrix()

function armorGame.GetPosByEntity(ent,entModel,config)
	local boneName = config.bone
	if not boneName then return end

	local bone = ent:LookupBone(boneName)
	if not bone then return end
	
	ent:CopyBoneMatrixHash(bone,MatrixSet)

	local info = modelSetting_ArmorOffset[entModel]
	info = info and info[boneName]

	local addVec = vecZero
	local addAng = angZero

	if info then
		addVec = info.vec or vecZero
		addAng = info.ang or angZero
	end

	local pos = config.vec or vecZero
	local ang = config.ang or angZero

	varVector:Set(pos):Add(addVec)
	varAngle:Set(ang):Add(addAng)

	MatrixLocal:Identity()
	MatrixLocal:SetTranslation(varVector)
	MatrixLocal:SetAngles(varAngle)
	
	MatrixSet:Mul(MatrixLocal)

	MatrixSet:SetXYZ_PYR(VecSet,AngSet)
	
	return VecSet,AngSet
end