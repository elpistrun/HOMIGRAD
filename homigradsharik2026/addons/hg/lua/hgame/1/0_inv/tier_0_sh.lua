-- custom_network's implementation is client-only in this addon snapshot.
-- The server still needs the class in the inheritance chain for authoritative
-- inventory objects; synchronization is supplied by inv_base/backend_sv.lua.
if SERVER and not oop.listClass["custom_network"] then
    oop.Reg("custom_network","lib_event",true)
end

inventoryGame = ManagerCreate("inventoryGame",{"node","node_network_user"})

customEnts.list["inv"] = customEnts.list["inv"] or {}
customEnts.listIndex["inv"] = customEnts.listIndex["inv"] or {}

inventoryGame.listIndex = customEnts.listIndex.inv--EZZZZ
inventoryGame.list = customEnts.list.inv

inventoryGame.DelayMove = 0.3
inventoryGame.DelayFastMove = 0.4
