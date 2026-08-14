CustomChat.EnsureDataDir()

local preferences = {
    ["customchat.emojis"] = "server_emojis.json",
    ["customchat.theme"] = "server_theme.json",
    ["customchat.tags"] = "server_tags.json"
}

for key,path in pairs(preferences) do
    NetPrefs.Set(key,CustomChat.LoadDataFile(path) or "")
end

function CustomChat.SetServerPreference(key,value)
    local path = preferences[key]
    if not path then return false end

    CustomChat.SaveDataFile(path,value)
    NetPrefs.Set(key,value)

    return true
end
