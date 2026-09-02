adminPanel.successRegistry("guilt_no",nil,"rights")

adminPanel.commandRegistry("guilt_set",{{type = "steamid64",required = true},{type = "number",required = true}},nil,nil,"rcon")
adminPanel.commandRegistry("guilt_dev",{"player"},"game",nil,"rcon")