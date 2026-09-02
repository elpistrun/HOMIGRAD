local BULLET = oop.Get("bullet")
if not BULLET then return end

customEnts.list["BulletDraw"] = customEnts.list["BulletDraw"] or {}

BULLET.beamWide = 1

BULLET:Event_Add("Create","Main",function(self)
    self:SetList("think",true)
    self:SetList("cleanup",true)

    self.createRealTime = RealTime()

    self.filterTrace = {}
end)

BULLET:Event_Add("Sync","Main",function(self,pkg)
    if self.startRealTime then return end
    
    local pos,dir = pkg.pos,pkg.dir
    if not pos then return end
    
    local startPos = pkg.startPos

    self.pos = Vector(pos[1],pos[2],pos[3])
    self:SetDir(Vector(dir[1],dir[2],dir[3]))

    self.startPos = Vector(startPos[1],startPos[2],startPos[3])
    self.renderPosStart = self.startPos:Clone()
    self.renderPosEnd = self.startPos:Clone()

    self:SetClassBullet(pkg.classBullet)

    local ping = LocalPlayer():Ping() / 1000 / 2
    self.startPing = ping
    self.startTime = UnPredictedCurTime() - ping
end,-1)

BULLET:Event_Add("Init","Main",function(self)
    if self:GetPVSVar("Hit") then return end

    if self.pos then self.startPos = self.pos:Clone() end
    if self.startDir then self.startDir = self.dir:Clone() end

    self.startRealTime = RealTime()

    if self.attacker == LocalPlayer() and LocalPlayer():GetLagCompresionDebug() >= 2 then
        self.debug = true
    end

    if self.isServerCreated then
        self.startTime = UnPredictedCurTime() - self.startPing
    else
        self.startTime = UnPredictedCurTime()
    end
end)

local min,max = math.min,math.max

BULLET.bulletCracks_close = {
    "dwr/bulletcracks/close/1.ogg",
    "dwr/bulletcracks/close/2.ogg",
    "dwr/bulletcracks/close/3.ogg",
    "dwr/bulletcracks/close/4.ogg",
    "dwr/bulletcracks/close/5.ogg",
    "dwr/bulletcracks/close/6.ogg",
    "dwr/bulletcracks/close/7.ogg",
    "dwr/bulletcracks/close/8.ogg"
}

BULLET.bulletCracks_distant = {
    "dwr/bulletcracks/distant/1.ogg",
    "dwr/bulletcracks/distant/2.ogg",
    "dwr/bulletcracks/distant/3.ogg",
    "dwr/bulletcracks/distant/4.ogg",
    "dwr/bulletcracks/distant/5.ogg",
    "dwr/bulletcracks/distant/6.ogg",
    "dwr/bulletcracks/distant/7.ogg",
    "dwr/bulletcracks/distant/8.ogg",
    "dwr/bulletcracks/distant/9.ogg",
    "dwr/bulletcracks/distant/10.ogg",
    "dwr/bulletcracks/distant/11.ogg",
    "dwr/bulletcracks/distant/12.ogg",
}

BULLET.bulletCracks_distant_far = {
    "dwr/bulletcracks/distant/11.ogg",
    "dwr/bulletcracks/distant/12.ogg",
    "dwr/bulletcracks/distant/3.ogg",
    "dwr/bulletcracks/distant/5.ogg",
    "dwr/bulletcracks/distant/9.ogg"
}

BULLET.CloseCrackMetrs = 12
BULLET.MaxCrackMetrs = 140

local function ThinkGoAway(self)
    self.pos:LerpFT(0.5,self.endPos)
    
    local k = self.kCrack or 0
    k = Lerp(k,k,0)
    k = Lerp(self.volume,0,k)
    k = Lerp(k,0.9996,0.9)

    k = Lerp(self.dotLine,k,0)

    if k == 0 then
        self:SetPos(self.pos)
    else
        self:SetPos(self.pos + (RenderView.origin - self.pos):Mul(k))
    end
end

function BULLET:EmitCrack(pos,disMetrs,dir,dot,dotLine)
    sound.WaitDistance(disMetrs)

    local volume = 1 - disMetrs / self.MaxCrackMetrs
    volume = volume * dot

    local pitch = 100 + math.random(-6,6) - 40 * disMetrs / self.MaxCrackMetrs
    pitch = pitch + Lerp(self.dir:Length() / 343 / 3,0,50)
    
    local point = sound.GetVurtialEmit(pos)
    point.bullet = self

    local dsp = 0

    if dot > 0.3 then
        local kCrack = math.max(1 - disMetrs / self.CloseCrackMetrs,0)
        kCrack = kCrack * dot

        local countSnd = ((self.div or 1) == 1 and 4 or 0)
        
        if kCrack > 0 then
            point.kCrack = math.min(kCrack * 3,1)

            for i = 1,countSnd do sound.EmitNative(point,self.bulletCracks_close[math.random(1,#self.bulletCracks_close)],90,kCrack,pitch,nil,dsp,CHAN_STATIC) end
        end

        volume = volume - 0.1 * kCrack
    end

    local list = self.bulletCracks_distant
    if disMetrs > self.CloseCrackMetrs * 2 then list = self.bulletCracks_distant_far end

    for i = 1,1 do sound.EmitNative(point,list[math.random(1,#list)],90,volume,pitch,nil,dsp,CHAN_STATIC) end

    local dir = self.dir:GetNormalized()

    point.pos = pos - dir * 6024
    point.endPos = pos + dir * 2024
    point.dotLine = math.min(dotLine * 4,1)
    point.volume = math.min(volume * 2,1)
    point.Think = ThinkGoAway
    point:Think()
    --point:EnableMatrixScale(Vector(0.01,0.01,0.01))
end

function BULLET:ThinkBulletCrack()
    if self.doNotCrack or self.emitCrack then return end

    local eye = RenderView.origin
    local disMetrs = eye:Distance(self.pos) * UNITS_TO_METERS
    
    if disMetrs > self.MaxCrackMetrs then
        self.lastDisMetrs = disMetrs

        return
    end

    local lastDisMetrs = self.lastDisMetrs
    if not self:GetPVSVar("Hit") and (not self.lastDisMetrs or disMetrs < (lastDisMetrs or disMetrs)) then self.lastDisMetrs = disMetrs return end

    self.emitCrack = true

    local dir = (eye - self.startPos)
    dir:Normalize()

    local dirNormalize = self.startDir:Clone()
    dirNormalize:Normalize()

    local dot = math.max(dir:Dot(dirNormalize),0)
    if dot <= 0 then return end

    local dis,pos = util.DistanceToLine(self.startPos,self.pos,eye)

    local dotLine = math.max((eye - pos):GetNormalized():Dot(dirNormalize),0)
    dotLine = math.max(dotLine - 0.01,0) / (1 - 0.01)
    dot = Lerp(dotLine,dot,0.3)

    coroutine.wrap(self.EmitCrack)(self,pos,dis * UNITS_TO_METERS,dir,dot,dotLine)
end

function BULLET:SetupRenderBeam(eye,eyeDir)
    local renderPosStart = self.renderPosStart
    local renderPosEnd = self.renderPosEnd

    local passCalculate

    if not renderPosStart then
        renderPosStart = (self.startPos or self.pos):Clone()
        renderPosEnd = self.pos:Clone()

        self.renderPosStart = renderPosStart
        self.renderPosEnd = renderPosEnd

        passCalculate = true
    end

    if self:GetPVSVar("Hit") and renderPosStart:Distance(renderPosEnd) <= 30 then return false end

    local disMetrs = eye:Distance(renderPosStart) * UNITS_TO_METERS

    local col = self.color or col

    local dotVec = self.pos - eye
    dotVec:Normalize()
    dotVec = eyeDir:Dot(dotVec)
    dotVec = math.max(dotVec - 0.98,0) * 100

    local wide = self.beamWide
    local disMultiplyWide = min(disMetrs / 50 * (1 + dotVec),300)

    self.renderWide = wide * math.Rand(0.9,1.1) + disMultiplyWide
    self.renderBeamMiddle = LerpVector(0.1,renderPosStart,renderPosEnd)

    if not passCalculate then
        renderPosStart:LerpFT(0.8,self.pos)
        self.renderPosStart = renderPosStart
    end

    local dir = self.pos - renderPosEnd
    renderPosEnd:Add(dir:Mul((self:GetPVSVar("Hit") and 35 or 10) * FrameTime()))

    self.renderPosEnd = renderPosEnd
end

local StartBeam,AddBeam,EndBeam = render.StartBeam,render.AddBeam,render.EndBeam
local color_default = Color(255,255,125)

function BULLET:Draw(eye,eyeDir,isFirst)
    if isFirst then
        if self:SetupRenderBeam(eye,eyeDir) == false then return end
    end

    local renderPosStart,renderPosEnd = self.renderPosStart,self.renderPosEnd
    local col = self.color or color_default

    StartBeam(3)
        AddBeam(renderPosStart,0,0,col)
        AddBeam(self.renderBeamMiddle,self.renderWide,0,col)
        AddBeam(renderPosEnd,0,0,col)
    EndBeam()
end

hook.Add("PostDrawTranslucentRenderables","Bullets",function(bDrawingDepth,bDrawingSkybox)
    if bDrawingSkybox then return end
    
    local eye = EyePos()
    local eyeDir = Vector(1,0,0):Rotate(EyeAngles())

    render.SetColorMaterial()
    render.SuppressEngineLighting(true)

    local list = customEnts.list["BulletDraw"]

    local isFirst = IsFirstFrame(_G,"firstNumber_PostDrawOpaqueRenderables_Bullets")

    for i = 1,#list do
        list[i]:Draw(eye,eyeDir,isFirst)
    end

    render.SuppressEngineLighting(false)
end)

--[[if CLIENT then
    timer.Create("Test",1,0,function()
        local bullet = customEnts.Create("bullet")
		bullet.pos = Vector(-8034.682129, -5271.750977,100)

		bullet:SetDir(Vector(16000,0,0):Rotate(Angle(0,90,0)))
		
		bullet.startTime = CurTime()

		bullet:Spawn()
    end)
end]]--