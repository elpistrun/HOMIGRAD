if not adminPanel then return end

adminPanel.commandRegistry("dev_lagcompresion",{"players","number"},"game",nil,"dev")

FindMetaTable("Player").GetLagCompresionDebug = function(self)
    return self:GetNWInt("LagCompresionDebug",0)
end