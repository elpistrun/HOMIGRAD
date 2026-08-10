local color_default = Color(255,255,255)

armorGame.Reg("armband",{
    printName = "Arm Band",
    model = "models/eft_props/gear/armbands/armband_colorable.mdl",
    icon = "entities/ent_jack_gmod_ezarmor_larmbandcolor.png",

	bone = "ValveBiped.Bip01_R_UpperArm",
	vec = Vector(3,0,1),
    size = Vector(1,1,1),
    ang = Angle(0,90,0),

    slots = {["other"] = true},
    category = "other",

    invColor = function(self,item)
        return item.data.color or color_default
    end,

    soundPickup = "eft_gear_sounds/gear_generic_pickup.wav",
    soundUse = "eft_gear_sounds/gear_generic_use.wav",
    soundDrop = "eft_gear_sounds/gear_generic_drop.wav",

    invUI = function(self,panel,item)
        panel:setW(panel:H() * 2)

        local sumbit = oop.CreatePanel("v_button",panel)
        sumbit:setSize(panel:H(),50):setPos(panel:H(),panel:H() - sumbit:H())
        sumbit.text = "Покрасить"

        local color = oop.CreatePanel("v_colormixer",panel)
        color:setSize(panel:H(),panel:H() - sumbit:H()):setPos(sumbit.x,0)
        color:SetPalette(false)
        color:SetAlphaBar(false)
        color:SetColor(item.color or Color(255,255,255))

        sumbit.OnClick = function()
            local inv = item.inv

            inv:SetWait(item,0)

            inv:SendCommand(function()
                sound.EmitScreen("weapons/spray/draw.wav")
                inv:SetWait(item,0.5)

                inventoryGame.NetInteractiveStart(inv.id,item.x,item.y)
                net.WriteColor(color:GetColor())
                inventoryGame:NetUserSend()

                sound.EmitScreen("weapons/spray/shoot.wav")

                inv:SetWait(item)
            end,function() inv:SetWait(item) end,LocalPlayer(),0.5)
        end
    end,

    iframe = true
})