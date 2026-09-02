animationPlayer = animationPlayer or {}

animationPlayer.slotList = {
    ["main"] = GESTURE_SLOT_ATTACK_AND_RELOAD,
    ["hand"] = GESTURE_SLOT_FLINCH,
    ["foot"] = GESTURE_SLOT_GRENADE
}

event.Add("Player Create","Animation Slots",function(ply)
    ply.animationSlot = {}

    for slotName,slotGesture in pairs(animationPlayer.slotList) do
        ply.animationSlot[slotName] = {
            name = slotName,
            parent = ply,
            slotGesture = slotGesture
        }
    end
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:PlayAnimation(slotName,sequenceObject,dontCheck)
    local slot = self.animationSlot[slotName]
    if not slot then error("PLAYER:PlayAnimation slot " .. tostring(slotName) .. " is not exists") end

    sequenceObject = animationEntity.PlayAnimationEx(slot,sequenceObject)
    sequenceObject.parent = self
    sequenceObject.slot = slot
    sequenceObject.isLocal = SERVER or self == LocalPlayer()

    if not dontCheck and sequenceObject.CanStart and not sequenceObject:CanStart() then return end

    slot.sequenceObject = sequenceObject

    return sequenceObject
end

function PLAYER:IsAnimationSlotBusy(slotName) return self.animationSlots[slotName].sequenceInfo end
function PLAYER:GetAnimationSlotCycle(slotName,type) return self.animationSlot[slotName].sequenceObject:GetCycle() end

function PLAYER:ResetAnimation(slotName)
    local slot = self.animationSlot[slotName]
    if not slot.sequenceObject then return end

    animationEntity.ResetAnimation(slot.sequenceObject)
    slot.sequenceObject = nil
end

event.Add("Player Think","Animation_Slots",function(ply)
    for slotName,slot in pairs(ply.animationSlot) do
        local sequenceObject = slot.sequenceObject
        if not sequenceObject or not sequenceObject.Think then continue end

        local cycle = sequenceObject:GetCycle()
        sequenceObject:Think(cycle)

        if not sequenceObject.endless and cycle >= 1 then ply:ResetAnimation(slotName) end
    end
end)

event.Add("StartCommand","Animation_Slots",function(ply,mv,cmd)
    for slotName,slot in pairs(ply.animationSlot) do
        local sequenceObject = slot.sequenceObject
        if not sequenceObject then continue end

        if sequenceObject.dontSprint then mv:RemoveKey(IN_SPEED) end
    end
end)

event.Add("Move","Animation_Slots",function(ply,mv)
    for slotName,slot in pairs(ply.animationSlot) do
        local sequenceObject = slot.sequenceObject
        if not sequenceObject or not sequenceObject.MoveThink then continue end

        if sequenceObject.MoveThink then sequenceObject:MoveThink(mv) end
    end
end)
--[[
for i,ply in pairs(player.GetAll()) do
    for slotName in pairs(ply.animationSlot) do
        ply:ResetAnimation(slotName)
    end
end]]--