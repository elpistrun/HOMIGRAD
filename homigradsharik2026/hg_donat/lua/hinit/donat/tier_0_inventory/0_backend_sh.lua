-- Item definitions are shared and therefore also execute serverside. Create
-- their registry before the loader enters the items directory.
inventoryManager = inventoryManager or ManagerCreate("inventory",{
    "node",
    "node_network",
    "node_network_user"
})
