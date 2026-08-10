local Receivers = net.Receivers
local net_ReadHeader = net.ReadHeader
local util_NetworkIDToString = util.NetworkIDToString

local string_lower = string.lower

net.Incoming = function(len)
	local strName = util_NetworkIDToString(net_ReadHeader())
	if not strName then return end

	local func = Receivers[string_lower(strName)]
	if not func then ErrorNoHalt("net unkown channel: " .. string_lower(strName) .. "\n") return end
	
	func(len - 16)//я богатый парень маладой. ой ой
end

net.ReceiveBig = net.Receive