inventoryGame = ManagerCreate("inventoryGame",{"node","node_network_user"})

customEnts.list["inv"] = customEnts.list["inv"] or {}
customEnts.listIndex["inv"] = customEnts.listIndex["inv"] or {}

inventoryGame.listIndex = customEnts.listIndex.inv--EZZZZ
inventoryGame.list = customEnts.list.inv

inventoryGame.DelayMove = 0.3
inventoryGame.DelayFastMove = 0.4