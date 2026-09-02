event.Add("EntityCreate","SetupFirstParametrs",function(ent)
    ent.obbMin = ent:OBBMins()
    ent.obbMax = ent:OBBMaxs()

    ent.obbLenght = ent.obbMin:Length() + ent.obbMax:Length()
    ent.obbLenghtMetrs = ent.obbLenght * UNITS_TO_METERS
end)