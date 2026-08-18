local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

function RenderPlayer_Weapon(ply,tag,link,flags)
    if not IsValid(link) or not link.IsPlayer or not link:IsPlayer() then return end

    local wep = link:GetActiveWeapon()

    if IsValid(wep) and wep.DrawFromPlayer then
        wep:DrawFromPlayer(ply,tag,link,flags)
    end

    local wepSecondary = link:GetActiveSecondaryWeapon()

    if IsValid(wepSecondary) and wepSecondary.DrawFromPlayer then
        wepSecondary:DrawFromPlayer(ply,tag,link,flags)
    end
end

function SWEP:CanDrawFromPlayer(ply,tag,link,flags) return true end

function SWEP:DrawFromPlayer(ply,tag,link,flags)
    local wm = self.wm
    if not IsValid(wm) then return end

    if self:CanDrawFromPlayer(ply,tag,link,flags) == false then return end
    
    if self:IsLocal() then
        SetAllLOD(self)
    else
        DeterminateLODFirst(self)
    end

    self:Render(wm,flags)
end

function SWEP:DrawFromNPC(rag)
    local wm = self:GetWorldModel()
    if not IsValid(wm) then return end

    DeterminateLODFirst(self)

    self:Render(wm)
end

local hg_dev_show_physbox

cvars.CreateDevOption("hg_dev_show_physbox","0",function(value)
    hg_dev_show_physbox = tonumber(value or 0) > 0
end)

function SWEP:DrawFromWorld(depth)--Не создаём wm.RenderOverride из за того что эта функция вызывается после всех RenderOverride
    local data
    
    if depth == 0 then
        data = (self.wmDropData and self.wmDropData.model and self.wmDropData) or (self.wmVeryFastData.model and self.wmVeryFastData)
    else
        data = (self.wmDropData and self.wmDropData.model and self.wmDropData) or (self.wmData.model and self.wmData) or self.wmFastData
    end
    
    local wm = self:InitWorldModel("world",false,depth,data)
    if not IsValid(wm) then return end

    self.wm = wm

    DeterminateLODFirst(self)

    if IsFirstFrame(wm,"SetupBonesChildrenTime") then
        local Pos,Ang = self:GetPos(),self:GetAngles()
        Pos,Ang = self:Transform_GetCenter(Pos,Ang,data)

        wm:SetSequence(0)
        wm:SetCycle(1)

        wm:SetPos(Pos)
        wm:SetAngles(Ang)

        self:SetupModel(wm)
    end

    if self.RenderOverride and self:RenderOverride(0,wm) == false then

    else
        self:Render(wm)
    end

    if hg_dev_show_physbox and self.PhysicsBox then
        local min,max = self.PhysicsBox[1],self.PhysicsBox[2]

        if min == Vector() then
            min,max = self:GetCollisionBounds()
        end
        
        debugoverlay.BoxAngles(self:GetPos(),min,max,self:GetAngles(),0.1,Color(0,0,255,0))
        debugoverlay.BoxAngles(self:GetPos(),-Vector(1,1,1),Vector(1,1,1),self:GetAngles(),0.1,Color(255,255,255,0))
        debugoverlay.BoxAngles(self:GetPos() + self:GetForward():Mul(3),-Vector(0.1,0.1,0.1),Vector(0.1,0.1,0.1),self:GetAngles(),0.1,Color(255,0,0,0))
    end
end

-- Render

function SWEP:DrawWorldModel()--engine function
    local owner = self:GetOwner()
    
    if IsValid(owner) then
        if not owner:IsPlayer() then
            self:DrawFromNPC(owner)
        end

        return
    end

    if DeterminateLODAlways then SetDeterminateLODAlways(self) end
    if IsDeterminateLODAlways(self) then self:DrawFromWorld() return end--блядь ну и что это

    if self[RenderLOD3_Distance] then return end
    
    self:DrawFromWorld(self[RenderLOD0_Distance] and 0)
end

function SWEP:PreRenderWM(wm) end
function SWEP:PostRenderWM(wm) end

function SWEP:RenderSetupBones(wm)
    if not wm.bones_matrix then return end

    if IsFirstFrame(self,"r_fSetupModelPost") then
        if self.SetupModelPost then self:SetupModelPost(wm) end
    end
    
    for bone,matrix in pairs(wm.bones_matrix) do
        if not isnumber(bone) or matrix:IsZero() then continue end
        if bone < 0 or bone >= wm:GetBoneCount() then continue end
        
        wm:SetBoneMatrixNow(bone,matrix)
    end
end

function SWEP:Render(wm)
    if self[RenderLODTPIK] then self:RenderSetupBones(wm) end
    self:PreRenderWM(wm)

    wm:DrawModel()

    if not self.renderLOD3 then return end

    local childrens = wm.childrens

    for i = 1,#childrens do
        local child = childrens[i]
        if not IsValid(child) then continue end

        if child.canDraw and not child.canDraw() then continue end

        child:DrawModel()
    end

    self:PostRenderWM(wm)
end

function SWEP:SetupBonesChildrens(wm)
    if not IsValid(wm) then return end

    local childrens = wm.childrens

    for i = 1,#childrens do
        local child = childrens[i]
        if not IsValid(child) then continue end

        self:SetupBonesChildren(child)
    end
end

local MatrixSetWorld = Matrix()
local MatrixSetLocal = Matrix()

local VecSet,AngSet = Vector(),Angle()

function SWEP:SetupBonesChildren(child)
    local parent = child.parent
    if not IsValid(parent) then return end--wtff
    
    if child.followBone then
        parent:CopyBoneMatrixHash(child.followBone,MatrixSetWorld)-- учитывает BonesManager_Init
    else
        MatrixSetWorld:Identity()
        MatrixSetWorld:SetTranslation(parent:GetPos())
        MatrixSetWorld:SetAngles(parent:GetAngles())
    end
    
    MatrixSetLocal:Identity()
    MatrixSetLocal:SetTranslation(child.localPos)
    MatrixSetLocal:SetAngles(child.localAng)

    MatrixSetWorld:Mul(MatrixSetLocal)

    MatrixSetWorld:SetXYZ_PYR(VecSet,AngSet)

    child:SetRenderOrigin(VecSet)
    child:SetRenderAngles(AngSet)

    if child.needUpdateBones then child:SetupBones() end
end

function SWEP:SetupModel(wm)
	wm:SetupBones()
	self:SetupBonesChildrens(wm)
end
