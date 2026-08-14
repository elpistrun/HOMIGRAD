local SWEP = oop.Get("tpik_animate")
if not SWEP then return end

SWEP:Event_Add("PreSequenceStart","IsLocal",function(self,sequenceObject)
    sequenceObject.isLocal = self:IsLocal()
end,-100)

if CLIENT then
    concommand.Add("hg_dev_wep_anim",function(ply,cmd,args)
        if not ply:IsSuperAdmin() then return end

        local wep = ply:GetActiveWeapon()

        local object = wep:PlayAnimation(args[1])
        object.Start = false
        object.Think = false
        object.Stop = false
    end)
    
    keyboard.DefaultBindCode("inspect",KEY_H,true,function() return not IsValid(vgui.GetKeyboardFocus()) end)

    concommand.Add("inspect",function(ply)
        local wep = ply:GetActiveWeapon()

        if IsValid(wep) and wep.Actions and wep.Actions["inspect"] then wep:DoAction({name = "inspect"}) end
    end)
    
    SWEP:Event_Add("CanSequenceByServer","Predicate",function(self,sequenceObject)
        if self:IsLocal() then return false end
    end)
end

--

function SWEP:OnGetSequenceIndex(sequenceObject,wm)
    if not wm.isWorldModel then return 0,1 end
end

function SWEP:ApplySequenceOnWorldModel(wm)
    if not wm.isWorldModel or not IsValid(self) then return end
    
    local index,cycle = self:GetSequenceIndex(self.sequenceObject,wm)

    wm:SetSequence(index)
    wm:SetCycle(cycle)
end

SWEP:Event_Add("SequenceStart","Instant Play World Model",function(self,sequenceObject,oldSequenceObject)
    local wm = self.wm

    if IsValid(wm) and sequenceObject and sequenceObject.playInstant then
        wm:SetSequence(sequenceObject and sequenceObject.index or 0)
        wm:SetCycle(self:GetSequenceCycle("animation"))
    end
end)

local tempCMD = {sendLoad = 0}

local function SendLoad(self)
    tempCMD.name = self.name
    self.parent:SendAction(tempCMD)
end

function SWEP:PlayAnimationAction(sequenceObject,callType)
    return self:PlayAnimation(sequenceObject,callType or "action")
end

function SWEP:PlayAnimationLoad(sequenceObject,callType)
    if TypeID(sequenceObject) == TYPE_STRING then sequenceObject = {name = sequenceObject} end
    
    sequenceObject.className = "base_load"
    sequenceObject.SendLoad = SendLoad

    return self:PlayAnimation(sequenceObject,callType or "action")
end

function SWEP:WaitConstructAnimation(name,funcConstruct)
    self:Event_Add("Construct","animation_" .. name,function(self)
        local anm = self[1].AnimationList[name]
        if not anm then return end
        
        if funcConstruct then funcConstruct(self,anm) end
    end)
end

function SWEP:ConstructAnimationAction(name,funcAction,funcConstruct,writeEye)
    local action = self:CreateAction(name)

    action.netWrite = function(self,cmd)
        net.WriteInt(cmd.sendLoad or -1,3)

        if writeEye then
            net.WriteEyeAttack(self:GetShootMatrix())
        end
    end

    action.netRead = function(self,cmd)
        cmd.sendLoad = net.ReadInt(3)
        if cmd.sendLoad == -1 then cmd.sendLoad = nil end

        if writeEye then
            local serverPos,serverAng = self:GetShootMatrix()

            local pos,ang,renderTime = net.ReadEyeAttack(serverPos,serverAng)
            cmd.pos = pos
            cmd.ang = ang
            cmd.renderTime = renderTime
        end
    end

    action.Start = function(self,cmd)
        if not self.AnimationList[name] then return false,"animation '" .. tostring(name) .. "' is not exists" end

        if cmd.sendLoad then
            if CLIENT then
                return false,"call cmd.sendLoad on client is error"
            else
                self.sequenceObject.DoNetLoad(self.sequenceObject,cmd)

                return true
            end
        else
            local result,err = funcAction(self,cmd)

            return result or false,err or "ConstructAnimationAction unkown error"
        end
    end

    self:WaitConstructAnimation(name,function(self,anm)
        anm.className = "base_load"
        anm.SendLoad = SendLoad

        if funcConstruct then funcConstruct(self,anm) end
    end)

    return action
end

event.Add("animationEntity.UpdateClass","tpik_animate",function()
    oop.Get("tpik_animate")
end)

local action = SWEP:CreateAction("stop")

function action.Start(self,cmd)
    if not self.sequenceObject then return false,"self.sequenceObject is null" end
    if not self.sequenceObject.canInputStop then return false,"self.sequenceObject canInputStop is null" end

    self:ResetAnimation()
    if SERVER then self:SyncAnimation() end

    return true
end

function SWEP:CreateAction_Attack(name)
    local action = self:CreateAction(name or "attack")
    action.unreliable = true

    action.netWrite = function(self,cmd)
        net.WriteEyeAttack(self:GetShootMatrix())
    end

    action.netRead = function(self,cmd)
        local serverPos,serverAng = self:GetShootMatrix()

        local pos,ang,renderTime = net.ReadEyeAttack(serverPos,serverAng)
        cmd.pos = pos
        cmd.ang = ang
        cmd.renderTime = renderTime
    end

    return action
end

SWEP.ParseAnimationFlags = {}

SWEP.ParseAnimationFlags.fire = {
    flags = {
        fire = true,
        dontChangeTPIKLerp = true,
        canFight = true
    },
    list = {
        "fire","fire_last","fire_empty","fire1","fire2"
    }
}

SWEP.ParseAnimationFlags.deploy = {
    flags = {
        deploy = true
    },
    list = {
        "deploy","deploy_empty"
    }
}

SWEP.ParseAnimationFlags.holster = {
    flags = {
        holster = true,
        endless = true
    },
    list = {
        "holster","holster_empty"
    }
}

SWEP.ParseAnimationFlags.inspect = {
    flags = {
        canInputStop = true,
        dontShake = true,
        canFight = true,
        cantAttack = true
    },
    list = {
        "inspect","inspect1","inspect2"
    }
}

SWEP:Event_Add("Construct","ParseAnimationFlags",function(self)
    local AnimationList = self[1].AnimationList

    for name,info in pairs(self[1].ParseAnimationFlags) do
        for i,name in pairs(info.list) do
            if not AnimationList[name] then continue end

            for k,v in pairs(info.flags) do
                AnimationList[name][k] = v
            end
        end
    end
end)

function SWEP:CalcViewAnimation(ply,view)
    local sequenceObject = self.sequenceObject

    if sequenceObject and sequenceObject.OnChangeCamera then sequenceObject:OnChangeCamera(view.vec,view.ang) end
end

function SWEP:DoBonesAnimation(ent,link,tpikMatrix)
    local sequenceObject = self.sequenceObject

    if sequenceObject and sequenceObject.OnBones then sequenceObject:OnBones(ent,link,tpikMatrix) end
end
