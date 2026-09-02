local Level = oop.Reg("level_test","level_base",true)
if not Level then return INCLUDE_BREAK end

Level.noTwo = true

function Level:CanRandomNext() return false end

Level.red = {"",Color(255,255,255),
    models = Level.StandardPlayerModels
}

Level.teamEncoder = {
    "red"
}

function Level:HUDPaint(k)

end