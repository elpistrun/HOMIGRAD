local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP.Actions = {}

function SWEP:CreateAction(name)
    local action = self.Actions[name]

    if not action then action = {} end

    self.Actions[name] = action

    return action
end

function SWEP:CanDoAction(cmd)
    local action = self.Actions[cmd.name]
    if not action then error(tostring(self) .. ":DoAction(" .. tostring(cmd.name) .. ") is not exists") end

    cmd.parent = self
    
    if CLIENT then
        cmd.ply = LocalPlayer()
        cmd.startTime = UnPredictedCurTime()
    else
        if not cmd.startTime then cmd.startTime = UnPredictedCurTime() end
        if not cmd.ply then cmd.ply = self:GetOwner() end--наврятле это будет..
    end

    local result,err = self:Event_Call("PreAction",cmd)
    if result != nil then return result,err end

    return true
end

function SWEP:DoAction(cmd)
    local result,err = self:CanDoAction(cmd)
    if not result then return false,err end

    local action = self.Actions[cmd.name]

    local result,err = action.Start(self,cmd)
    if not result then return false,err end

    if CLIENT then self:SendAction(cmd,action.unreliable) end

    return result,err
end

SWEP:Event_Add("PreAction","CanStart",function(self,cmd)
    local action = self.Actions[cmd.name]

    if action and action.CanStart then return action.CanStart(self,cmd) end
end)