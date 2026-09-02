local PLAYER = FindMetaTable("Player")

net.Receive("console print",function() print(net.ReadString()) end)

net.Receive("chat print",function()
    local lply = LocalPlayer()
    if not lply.ChatPrint then return end--wtf

    LocalPlayer():ChatPrint(net.ReadString())
end)

net.Receive("notify print",function()
    notification.AddLegacy(net.ReadString(),net.ReadInt(16),net.ReadInt(16))
end)

function PLAYER:ConsolePrint(text)
    if self ~= LocalPlayer() then return end--lol

    print(text)
end

net.Receive("msgcall",function()
    MsgC(unpack(net.ReadTable()))
end)

net.Receive("chataddtext",function()
    chat.AddText(unpack(net.ReadTable()))
end)