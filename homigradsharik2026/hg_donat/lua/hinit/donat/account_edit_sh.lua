adminPanel.commandRegistry("account_edit",{{type = "steamid64"}},"game",nil,"rcon")

FindMetaTable("Player").GetAccountID = function(self) return self:GetNWString("AccountSteamID64",self:SteamID64()) end