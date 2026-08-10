adminPanel.commandRegistry("closedev",{"bool"}):SetCategory("rcon")
adminPanel.commandRegistry("setmaxplayers",{"number"}):SetCategory("rcon")
adminPanel.commandRegistry("setworkshopid_formap",{"number"}):SetCategory("rcon")
adminPanel.commandRegistry("getlistentities",{}):SetCategory("rcon")
adminPanel.commandRegistry("slow_motion",{{type = "number",name = "delay",require = true},{type = "number",name = "multiply"}},"game",nil,"rcon") 

adminPanel.successRegistry("CanEmbedCustomChat",nil,"rights")
adminPanel.successRegistry("free_slot",nil,"rights")

adminPanel.successRegistry("CanChangePlayerModel",nil,"rights")

hook.Add("CanChangePlayerModel","!Homigrad",function(ply)
    if ply:HasSuccess("CanChangePlayerModel") then return true end
end)