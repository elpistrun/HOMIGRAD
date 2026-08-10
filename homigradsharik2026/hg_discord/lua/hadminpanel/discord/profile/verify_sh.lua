adminPanel.commandRegistry("verify_discord",{},"async")
adminPanel.commandRegistry("unverify_discord",{},"async")

adminPanel.commandRegistry("verify_discord_force",{{type = "steamid64",required = true},{type = "string",required = true}},"async")
adminPanel.commandRegistry("unverify_discord_force",{{type = "string",required = true}},"async")
