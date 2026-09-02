function inventoryGame.SendClose(invID)
    inventoryGame:NetUserStart()
    
    net.WriteString("Close")
    net.WriteInt(invID,14)

    return inventoryGame:NetUserSend()
end

function inventoryGame.SendDrop(invID,x,y,count)
    inventoryGame:NetUserStart()
    
    net.WriteString("Drop")

    net.WriteInt(invID,14)

    net.WriteInt(x,7)
    net.WriteInt(y,7)
    net.WriteInt(count or -1,7)

    return inventoryGame:NetUserSend()
end

function inventoryGame.SendMove(invFromID,xFrom,yFrom,invToID,xTo,yTo,count)
    inventoryGame:NetUserStart()

    net.WriteString("Move")

    net.WriteInt(invFromID,14)
    net.WriteInt(xFrom,7)
    net.WriteInt(yFrom,7)

    net.WriteInt(invToID,14)
    net.WriteInt(xTo,7)
    net.WriteInt(yTo,7)
    
    net.WriteInt(count or -1,7)

    return inventoryGame:NetUserSend()
end

function inventoryGame.SendFastMove(invID,x,y)
    inventoryGame:NetUserStart()

    net.WriteString("FastMove")

    net.WriteInt(invID,14)
    net.WriteInt(x,7)
    net.WriteInt(y,7)

    return inventoryGame:NetUserSend()
end

function inventoryGame.NetInteractiveStart(invID,x,y)
    inventoryGame:NetUserStart()

    net.WriteString("Interactive")

    net.WriteInt(invID,14)
    net.WriteInt(x,7)
    net.WriteInt(y,7)
end

function inventoryGame:NetUserErrorHandler()
    --return true
end--не выводим лог об ошибках