local BULLET = oop.Reg("bullet",{"custom_entity","custom_network","custom_networker"},true)
if not BULLET then return INCLUDE_BREAK end

BULLET:Event_Add("Construct","Dev Delete",function(class)
    --[[for id,ent in pairs(customEnts.listIndex["class_" .. class[1].ClassName] or {}) do
        customEnts.Delete(id)
    end]]--
end)

function BULLET:SetupDefaultVars()
    self:SetClassBullet(self.classBullet)
    
    if self.SetupDefaultVarsPost then self:SetupDefaultVarsPost() end
end

BULLET:Event_Add("Init","SetupDefaultVars",function(self)
    self:SetupDefaultVars()
end,-1)

local empty = {}

function BULLET:SetClassBullet(ammoName)
    self.classBullet = ammoName

    local classBullet = self:GetAmmoClassBullet() or empty
    local bulletInfo = classBullet.bulletInfo or empty

    local Count = bulletInfo.Count or 1
    
    self.mass = bulletInfo.Mass or self.mass or 2
    self.hardness = bulletInfo.Hardness or 1
    self.expansion = bulletInfo.Expansion or 1
    
    self.diameter = bulletInfo.Diameter or 9
    self.mulPhysicsForce = (bulletInfo.MulPhysicsForce or 1) / Count

    self.dragModelName = bulletInfo.DragModelName
    self.dragCoeff = bulletInfo.DragCoeff or 1
    self.balisticCoeff = bulletInfo.BalisticCoeff or 1
    self.multiplySpeed = bulletInfo.MultiplySpeed or 1

    self.withoutSmoke = bulletInfo.withoutSmoke
    self.SmokeMul = bulletInfo.SmokeMul
    self.color = bulletInfo.color

    self.dmgType = bulletInfo.DamageType or self.dmgType or DMG_BULLET
    self.dmg = (bulletInfo.Damage and bulletInfo.Damage / Count) or self.dmg

    self.LifeTime = bulletInfo.LifeTime or self.LifeTime

    self.doNotCrack = bulletInfo.DoNotCrack
    
    if bulletInfo.Tracer then self:SetList("BulletDraw",true) end

    self.traceManual = bulletInfo.TraceManual

    self.BulletThink = bulletInfo.Think
    self.BulletHitEnd = bulletInfo.HitEnd
    self.AlwaysReplicate = bulletInfo.AlwaysReplicate

    self:Event_Call("SetClassBullet",classBullet,bulletInfo)
end

BULLET:Event_Add("Think","BulletThink",function(self)
    if self.BulletThink then self:BulletThink() end
end,1)

BULLET:Event_Add("HitEnd","BulletHitEnd",function(self,traceResult)
    if self.BulletHitEnd then self:BulletHitEnd(traceResult) end
end,1)

function BULLET:GetAmmoClassBullet()
    if not self.classBullet then return empty end
    
    return ammoGame.config[self.classBullet]
end