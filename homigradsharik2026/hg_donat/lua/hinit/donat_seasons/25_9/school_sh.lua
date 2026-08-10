DonatItem_PlayerModelEasyReg("models/mug/ncfom/anton_chigurh.mdl","Anton Chigurh","Новичкам тут не место...","epic")
modelSetting.Reg("models/mug/ncfom/anton_chigurh.mdl",{
    hitBoxBounds = {
        ["ValveBiped.Bip01_L_Thigh"] = {-Vector(3,3,3),Vector(17,3,3)},
        ["ValveBiped.Bip01_R_Thigh"] = {-Vector(3,3,3),Vector(17,3,3)},

        ["ValveBiped.Bip01_L_Calf"] = {-Vector(3,3,3),Vector(17,3,3)},
        ["ValveBiped.Bip01_R_Calf"] = {-Vector(3,3,3),Vector(17,3,3)},

        ["ValveBiped.Bip01_L_UpperArm"] = {-Vector(3,2,2),Vector(11,2,2)},
        ["ValveBiped.Bip01_R_UpperArm"] = {-Vector(3,2,2),Vector(11,2,2)},

        ["ValveBiped.Bip01_L_Forearm"] = {-Vector(1,2,2),Vector(15,2,2)},
        ["ValveBiped.Bip01_R_Forearm"] = {-Vector(1,2,2),Vector(15,2,2)},

        ["ValveBiped.Bip01_Head1"] = {-Vector(0,5,3),Vector(8,3,3)},
        ["Torso"] = {-Vector(12,7,4),Vector(9,6,6)}
    },
})

DonatItem_PlayerModelEasyReg("models/panman/wapple_citizen.mdl","Wapple Man","just watch","epic")

local desc = "Сезоные предметы с 1 сентебря 2025 года"

DonatItem_PlayerModelEasyReg("models/player/bully/bif/bif.mdl","Bif",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/bryce/bryce.mdl","Bryce",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/bucky/bucky.mdl","Bucky",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/casey/casey.mdl","Casey",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/constantinos/constantinos.mdl","Constantinos",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/cornelius/cornelius.mdl","Cornelius",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/earnest/earnest.mdl","Earnest",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/edward/edward.mdl","Edwart",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/gordon/gordon.mdl","Gornod",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/hal/hal.mdl","Hal",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/ivan/ivan.mdl","Ivan",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/parker/parker.mdl","Parker",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/seth/seth.mdl","Seth",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/tad/tad.mdl","Tad",desc,"uncommon")
DonatItem_PlayerModelEasyReg("models/player/bully/trevor/trevor.mdl","Ted",desc,"uncommon")

DonatItem_PlayerModelEasyReg("models/player/bully/gord/gord.mdl","Gord",desc,"rary")
DonatItem_PlayerModelEasyReg("models/player/bully/peanut/peanut.mdl","Peanut",desc,"rary")
DonatItem_PlayerModelEasyReg("models/player/bully/johnny/johnny.mdl","Johnny",desc,"rary")
DonatItem_PlayerModelEasyReg("models/player/bully/ted/ted.mdl","Ted",desc,"rary")

DonatItem_PlayerModelEasyReg("models/player/bully/karl/karl.mdl","Karl",desc,"legendary")
DonatItem_PlayerModelEasyReg("models/player/bully/damon/damon.mdl","Damon",desc,"legendary")
DonatItem_PlayerModelEasyReg("models/player/bully/norton/norton.mdl","Norton",desc,"legendary")
DonatItem_PlayerModelEasyReg("models/player/bully/chad/chad.mdl","Chad",desc,"legendary")

DonatCasesClasses["school"] = {
    raryType = "rary",

    model = "models/kali/props/cases/hard case c.mdl",
    name = "School Case",
    desc = "Сезоный кейс, не будет продаватся с 7 сентебря по 00:00 МСК",

    subMaterial0 = "models/props_c17/paper01",

    modelVec = Vector(-40,-2,-9),
    modelAng = Angle(15,20,0),

    modelLockVec = Vector(13,0,9.6),
    modelLockAng = Angle(0,90,90),

    keyName = "School Key",
    modelKey = "models/props_lab/bindergreen.mdl",
    modelKeyVec = Vector(80,-1,-6),
    modelKeyAng = Angle(0,20,-5),

    casino = {
        {
            weight = 6,
            list = {
                {class = "playermodel",model = "models/mug/ncfom/anton_chigurh.mdl"},
                {class = "playermodel",model = "models/panman/wapple_citizen.mdl"}
            }
        },
        {
            weight = 10,
            list = {
                {class = "playermodel",model = "models/player/bully/gord/gord.mdl"},
                {class = "playermodel",model = "models/player/bully/peanut/peanut.mdl"},
                {class = "playermodel",model = "models/player/bully/johnny/johnny.mdl"},

                {class = "playermodel",model = "models/player/bully/ted/ted.mdl"},
                {class = "playermodel",model = "models/player/bully/karl/karl.mdl"},
                {class = "playermodel",model = "models/player/bully/damon/damon.mdl"},
                {class = "playermodel",model = "models/player/bully/norton/norton.mdl"},
                {class = "playermodel",model = "models/player/bully/chad/chad.mdl"}
            }
        },
        {
            weight = 50,
            list = {
                {class = "playermodel",model = "models/player/bully/bif/bif.mdl"},
                {class = "playermodel",model = "models/player/bully/bryce/bryce.mdl"},
                {class = "playermodel",model = "models/player/bully/bucky/bucky.mdl"},
                {class = "playermodel",model = "models/player/bully/casey/casey.mdl"},
                {class = "playermodel",model = "models/player/bully/constantinos/constantinos.mdl"},
                {class = "playermodel",model = "models/player/bully/cornelius/cornelius.mdl"},
                {class = "playermodel",model = "models/player/bully/earnest/earnest.mdl"},
                {class = "playermodel",model = "models/player/bully/edward/edward.mdl"},
                {class = "playermodel",model = "models/player/bully/gordon/gordon.mdl"},
                {class = "playermodel",model = "models/player/bully/ivan/ivan.mdl"},
                {class = "playermodel",model = "models/player/bully/parker/parker.mdl"},
                {class = "playermodel",model = "models/player/bully/seth/seth.mdl"},
                {class = "playermodel",model = "models/player/bully/tad/tad.mdl"},
                {class = "playermodel",model = "models/player/bully/trevor/trevor.mdl"},
            }
        },
        {
            weight = 45,
            list = {
                {class = "bodygroup",type = 3}
            }
        }
    }
}