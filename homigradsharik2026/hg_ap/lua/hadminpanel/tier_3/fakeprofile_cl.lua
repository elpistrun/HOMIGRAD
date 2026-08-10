adminPanel.commandRegistry("fakeprofile",{
    {type = "string",name = "avatarURL"},
    {type = "string",name = "avatarFrameURL"},
    {type = "string",name = "bacgkroundURL"},
    {type = "string",name = "name"},
    {type = "number",name = "hours"}
},"async",nil,"rcon_spy")

adminPanel.commandRegistry("hideme",{
    {type = "bool",name = "value"},
},"async",nil,"rcon_spy")