local SWEP = oop.Get("hg_wep")
if not SWEP then return end

SWEP.AttachmentBoneParent = "weapon"
SWEP.AttachmentAngle = Angle(0,-90,0)

local min,max = -Vector(16,16,16),Vector(16,16,16)

SWEP:Event_Add("Init","RenderBox",function(self)
    self:SetRenderBounds(min,max)
end)

function SWEP:CreateWorldModelPost(wm,tag,typeDraw,depth)
    self:CreateWorldModelPostAttachment(wm,tag,typeDraw,depth)

    if self.GetMagazineItem and depth != 0 then
        local magazineItem = self:GetMagazineItem()

        if magazineItem then
            local mdl = self:InitWorldModelMagazine(wm,tag,typeDraw,magazineItem.path)
            wm.magazineModel = mdl
        end
    end

    self:InitWorldModelBodygroup(wm,tag,typeDraw)

    wm:InvalidateBoneCache()
    wm:SetupBones()
end

SWEP.Primary.MagazineModelAng = Angle(0,0,0)

function SWEP:InitWorldModelMagazine(wm,tag,typeDraw,model)
    if not self.GetMagazineItem then return end

    local mdl,isCreate = self:CreateModelForWM(wm,model,"magazine" .. (tag or ""),typeDraw)
    if not IsValid(mdl) then return end
    
    mdl.followBone = wm:LookupBone("mod_magazine")

    mdl.localAng = self.Primary.MagazineModelAng
    mdl.localPos = self.Primary.MagazineModelPos or Vector()

    mdl.canDraw = function()
        if mdl.dontDraw then return false end

        if not self.GetPos or self:GetPos():Distance(EyePos()) > RenderLOD1_Distance then return true end

        local wm = self.wm
        if not IsValid(wm) then return end--lol

        local chamberBodygroup = self.wmData and self.wmData.chamberBodygroup

        local sequenceObject,cycle = self:GetSequenceData("start")
        
        local viewChamber = self.chamber != nil
        local canDraw = true

        if sequenceObject and sequenceObject.magazineDraw and sequenceObject:GetMark("magazineDraw")  == false then
            viewChamber = false
            canDraw = false
        end

        if chamberBodygroup then
            self:SetupModelChamber(wm,viewChamber,canDraw)
        end

        return canDraw
    end

    return mdl
end

function SWEP:InitWorldModelBodygroup() end

function SWEP:SetupModelChamber(wm,viewChamber,canDraw)
    wm:SetBodygroup(self.wmData.chamberBodygroup,viewChamber and (self.wmData.chamberBodygroup_Active or 1) or (self.wmData.chamberBodygroup_NoActive or 0))
end
