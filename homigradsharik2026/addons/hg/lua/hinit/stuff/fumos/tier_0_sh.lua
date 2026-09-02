local SWEP = oop.Reg("fumos_fumo",{"hg_wep_base"})
if not SWEP then return end

SWEP.SpawnableSuperAdmin = true
SWEP.Category = "Fumos"
SWEP.PrintName = "Fumo"
SWEP.Spawnable = true

SWEP.NextBotClass = "npc_fumo"

SWEP.WorldModel = "models/tadano/fumo/pack/reimu.mdl"
SWEP.EnableTransformModel = true

SWEP.wmScale = 1
SWEP.wmFastVector = Vector(3,-2,2.7)
SWEP.wmFastAngle = Angle(0,-90,180)

SWEP.HoldType = "slam"

SWEP.DrawWeaponSelection = DrawWeaponSelection
SWEP.OverridePaintIcon = OverridePaintIcon

SWEP.Primary.Automatic = false

SWEP.dwsPos = Vector(0,-45,-8)

SWEP.SmoothDeployHand = true

if SERVER then
    function SWEP:PrimaryAttack()
        if (self.nextPrimaryAttack or 0) > CurTime() then return end
        self.nextPrimaryAttack = CurTime() + 0.05

        local prekol = math.random(1,10000) == 10000
        if prekol then self.nextPrimaryAttack = CurTime() + 0.3 end

        self:SetNWFloat("Start",CurTime())
        self:SetNWFloat("Delay",prekol and 0.3 or 0.2)

        sound.Emit(self:EntIndex(),"weapons/pick.wav",75,0.15,prekol and 55 or math.random(98,102),self:GetPos())
        
        local owner = self:GetOwner()
        owner:SetNWFloat("Shiza",math.min(owner:GetNWFloat("Shiza",0) + 0.1,100))

        if math.random(1,100) == 100 then
            //self:Arm()
        end
    end

    event.Add("Player Think 1","Fumos",function(ply)
        if not ply:Alive() then return end

        local shiza = ply:GetNWFloat("Shiza",0)

        if shiza > 0 then
            ply:SetNWFloat("Shiza",shiza - 1)
        end
    end)

    event.Add("Breath Ply","Shiza",function(ply,delay)
        local shiza = ply:GetNWFloat("Shiza",0) / 100

        if shiza > 0 then
            delay[1] = math.min(delay[1],1 - shiza * 0.7)
        end
    end)

    event.Add("Player Spawn","Shiza",function(ply)
        ply:SetNWFloat("Shiza",0)
    end)

    function SWEP:Reload()
        if (self.nextReload or 0) > CurTime() then return end
        self.nextReload = CurTime() + 0.5
        
        self:SetNWBool("Mode",not self:GetNWBool("Mode"))
    end
    
    function SWEP:Arm()
        local owner = self:GetOwner()
        if IsValid(owner) then owner:DropWeapon(self) end

        self:SetNWBool("Arm",true)

        sound.Emit(self:EntIndex(),"homigrad/scp/fumo/jump.mp3",120,1,100,self:GetPos())

        timer.Simple(10,function()
            if not IsValid(self) then return end

            self:Remove()

            local nextbot = ents.Create(self.NextBotClass)
            nextbot:SetPos(self:GetPos())
            nextbot:Spawn()
        end)
    end

    function SWEP:CanPickup(ply)
        if self:GetNWBool("Arm") then ply:PickupObject(self) return false end
    end

    local fumos = {}

    hook.Add("OnEntityCreated","Replcae",function(prop)
        if not IsValid(prop) or prop:GetClass() != "prop_physics" then return end

        timer.Simple(0,function()
            if IsValid(prop) and prop:GetModel() then
                local fumo = fumos[string.lower(prop:GetModel())]

                if fumo then
                    local ent = ents.Create(fumo)
                    ent:SetPos(prop:GetPos())
                    ent:SetAngles(prop:GetAngles())
                    ent:Spawn()
                    ent.Spawned = true

                    prop:Remove()

                    ent:PhysWake()
                end
            end
        end)
    end)

    SWEP:Event_Add("Construct","Fumos",function(class)
        if class[1].WorldModel then fumos[string.lower(class[1].WorldModel)] = class[1].ClassName end
    end)
else
    event.Add("PreCalcView","Fumos",function(ply,view)
        if not ply:Alive() then return end

        local shiza = ply:GetNWFloat("Shiza",0) / 100

        view.ang:Add(Angle(math.cos(CurTime() * 2),math.sin(CurTime() * 2)):Mul(15 * shiza))

        view.fov = view.fov - 25 * shiza
    end)

    hook.Add("HUDPaintBackground","Fumos",function()
        local ply = LocalPlayer()
        
        local shiza = ply:Alive() and ply:GetNWFloat("Shiza",0) / 100 or 0

        if shiza == 0 then
            if ShizaSound and ShizaSound:IsPlaying() then ShizaSound:Stop() end

            return
        end
        
        if not ShizaSound then
            ShizaSound = CreateSound(LocalPlayer(),"homigrad/scp/shiza.wav")
        end

        local volume = shiza

        if not ShizaSound:IsPlaying() then
            ShizaSound:PlayEx(volume,100)
        end

        ShizaSound:ChangeVolume(0.2 * volume,0.1)

        surface.SetDrawColor(0,0,0,255 * shiza)

        draw.GradientUp(0,0,ScrW(),ScrH() * 2)
    end)
end

function SWEP:DoBones(ply,link,tpikMatrix)
    self:SetupBones_WorldModel_ByHand(ply,link)
    
    local anim = math.max(self:GetNWFloat("Start",0) - CurTime() + self:GetNWFloat("Delay",1),0) / self:GetNWFloat("Delay",1)

    ply:AddBoneAng("rhand",Angle(5 * anim,0 * anim,0))

    ply:AddBoneAng("rupperarm",Angle(-10,-30,30))
    ply:AddBoneAng("rforearm",Angle(0,0,0))
end