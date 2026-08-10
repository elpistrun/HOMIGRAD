DonatItemsList.fumos_crino = {swep = "fumos_crino",raryType = "rary"}
DonatItemsList.fumos_flandere = {swep = "fumos_flandere",raryType = "rary"}
DonatItemsList.fumos_fumo = {swep = "fumos_fumo",raryType = "rary"}
DonatItemsList.fumos_yuuka = {swep = "fumos_yuuka",raryType = "rary"}
DonatItemsList.fumos_sakuya = {swep = "fumos_sakuya",raryType = "rary"}
DonatItemsList.fumos_yuyuko = {swep = "fumos_yuyuko",raryType = "rary"}

DonatItemsList.fish_entity = {
    ent = "fish_entity",
    raryType = "uncommon",

    WorldModel = "models/sealplush/fish.mdl",
    WorldVec = Vector(80,-1,-1),
    WorldAng = Angle(-45,90,0),

    countUse = 25
}

DonatItemsList.sealplush1 = {
    ent = "sealplush1",
    raryType = "epic",

    WorldModel = "models/sealplush/sealplush.mdl",
    WorldVec = Vector(40,1,-1),
    WorldAng = Angle(20,20,0)
}

DonatCasesClasses["fumos"] = {
    raryType = "legendary",

    model = "models/kali/props/cases/rifle case b.mdl",
    name = "Fumos Case",
    desc = "Сезоный кейс, не будет продаватся с 20 сентебря по 27 до 00:00 по МСК",

    subMaterial0 = "models/MCModelPack/snow",

    modelVec = Vector(-20,-1,-4),
    modelAng = Angle(45,20,0),

    modelLockVec = Vector(0,0,6),
    modelLockAng = Angle(0,90,0),

    keyName = "Fumos Key",
    modelKey = "models/jaggedsprings/key1.mdl",
    modelKeyVec = Vector(90,2,-3),
    modelKeyAng = Angle(90 + 45,90,90),

    casino = {
        {
            weight = 6,
            list = {
                {class = "item",type =  "sealplush1"}
            }
        },
        {
            weight = 6,
            list = {
                {class = "item",type =  "fumos_crino"},
                {class = "item",type =  "fumos_flandere"},
                {class = "item",type =  "fumos_fumo"},
                {class = "item",type =  "fumos_yuuka"},
                {class = "item",type =  "fumos_sakuya"},
                {class = "item",type =  "fumos_yuyuko"}
            }
        },
        {
            weight = 45,
            list = {
                {class = "item",type =  "fish_entity"}
            }
        }
    }
}