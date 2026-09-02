local protocol = "HGAC-2026-1"

-- Capture trusted references as soon as this module loads. A later detour is
-- reported to the server. This cannot make client Lua secret, but catches a
-- common class of injected menu hooks and broken dumpers.
local original = {
    netStart = net.Start,
    netSend = net.SendToServer,
    runCommand = RunConsoleCommand,
    getInfo = debug and debug.getinfo
}

local function IntegrityFlags()
    local flags = 0
    if net.Start ~= original.netStart then flags = flags + 1 end
    if net.SendToServer ~= original.netSend then flags = flags + 2 end
    if RunConsoleCommand ~= original.runCommand then flags = flags + 8 end
    if debug and debug.getinfo ~= original.getInfo then flags = flags + 16 end
    return flags
end

net.Receive("hg_ac_challenge",function()
    local nonce = net.ReadString()

    original.netStart("hg_ac_response")
        net.WriteString(util.CRC(nonce .. protocol))
        net.WriteUInt(IntegrityFlags(),16)
    original.netSend()
end)
