DonatItem_PlayerModelEasyReg("models/player/gspace.mdl","GalaxySpace","","epic",{
    [-1] = {
        name = "Space",
        max = 4
    }
})
ModelSettings_Ragdoll["models/player/gspace.mdl"] = {
    handVelocity = 1000,
    handGrabVelocity = 125,


    handForceMul = 0.5
}

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman.mdl","GalaxyMan","","legendary")

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_blue.mdl","GalaxyMan Blue","","rary")
ModelSettings_Ragdoll["models/player/galaxyman/galaxyman_blue.mdl"] = ModelSettings_Ragdoll["models/player/gspace.mdl"]

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_green_blue.mdl","GalaxyMan Green Blue","","rary")
ModelSettings_Ragdoll["models/player/galaxyman/galaxyman_green_blue.mdl"] = ModelSettings_Ragdoll["models/player/gspace.mdl"]

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_red.mdl","GalaxyMan Red","","rary")
ModelSettings_Ragdoll["models/player/galaxyman/galaxyman_red.mdl"] = ModelSettings_Ragdoll["models/player/gspace.mdl"]

DonatItem_PlayerModelEasyReg("models/player/galaxyman/galaxyman_yellow.mdl","GalaxyMan Yellow","","rary")
ModelSettings_Ragdoll["models/player/galaxyman/galaxyman_yellow.mdl"] = ModelSettings_Ragdoll["models/player/gspace.mdl"]

DonatCasesClasses["galaxy"] = {
    raryType = "rary",

    model = "models/kali/props/cases/hard case c.mdl",
    name = "Galaxy Models",
    desc = "Сезоный кейс, не будет продаватся с 29 июля по 00:00 МСК",

    subMaterial0 = "models/gspace/galaxy_purple",

    modelVec = Vector(-40,-2,-9),
    modelAng = Angle(15,20,0),

    modelLockVec = Vector(13,0,9.6),
    modelLockAng = Angle(0,90,90),

    keyName = "Galaxy Models",
    modelKey = "models/jaggedsprings/key1.mdl",
    modelKeyVec = Vector(90,2,-3),
    modelKeyAng = Angle(90 + 45,90,90),

    casino = {
        {
            weight = 1,
            list = {
                {class = "playermodel",model = "models/player/gspace.mdl"},
            }
        },
        {
            weight = 10,
            list = {
                {class = "playermodel",model = "models/player/galaxyman/galaxyman.mdl"},
            }
        },
        {
            weight = 40,
            list = {
                {class = "playermodel",model = "models/player/galaxyman/galaxyman_blue.mdl"},
                {class = "playermodel",model = "models/player/galaxyman/galaxyman_green_blue.mdl"},
                {class = "playermodel",model = "models/player/galaxyman/galaxyman_red.mdl"},
                {class = "playermodel",model = "models/player/galaxyman/galaxyman_yellow.mdl"}
            }
        }
    }
}