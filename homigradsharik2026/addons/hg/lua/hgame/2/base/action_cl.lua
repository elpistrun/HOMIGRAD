local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

net.Receive("weapon_action",function(len)
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or not wep.Actions then return end

    local cmd = net.ReadTable()

    MsgC(Color(255,180,80),"[HG weapon action] ",Color(255,255,255),
        tostring(cmd.name)," stopped by server: ",tostring(cmd.err),"\n")
    
    local action = wep.Actions[cmd.name]
    
    if action and action.Error then action.Error(wep,cmd) end
end)

function SWEP:SendAction(cmd,unreliable)
    local action = self.Actions[cmd.name]
    if not action then error(tostring(self) .. ":SendAction(" .. tostring(cmd.name) .. ") is not exists") end
    
    net.Start("weapon_action",unreliable)
    net.WriteString(cmd.name)

    if action.netWrite then action.netWrite(self,cmd) end

    net.SendToServer()
end
