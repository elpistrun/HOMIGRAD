local Level = oop.Get("level_homicide")
if not Level then return end

local colorRed = Color(255,0,0)

local delay = 0
Level.DelayScanTime = 60

local startScan = 0
HomicideScaned = HomicideScaned or {}
local scanMaxDis = 16000
local scanDelay = 2

local colorGray = Color(165,165,165,165)

local function startScanFunc()
    sound.EmitScreen("homigrad/vgui/freeze_cam.wav",0.075,30)
    sound.EmitScreen("homigrad/vgui/freeze_cam.wav",0.075,50)
    sound.EmitScreen("homigrad/vgui/freeze_cam.wav",0.075,65)
    sound.EmitScreen("homigrad/vgui/freeze_cam.wav",0.075,75)

    startScan = RealTime()
    for ply,info in pairs(HomicideScaned) do
        if IsValid(info.avatar) then info.avatar:Remove() end
    end

    HomicideScaned = {}
end

function Level:ScoreboradInventoruUICreate(frame,force)
    if not force and not LocalPlayer().roleT then return end

    local butt = oop.CreatePanel("v_button",frame):ad(function(self,w,h) self:setSize(200,50):setPos(w * 0.016,h - self:H() - h * 0.016) end)
    butt.text = L("find_survivor"); butt.font = "HS.18"

    function butt.DrawText(_,w,h)
        local time = delay - RealTime()

        if time > 0 then
            draw.SimpleText(math.floor(time),"HS.12",w-6,h - 6,colorGray,TEXT_ALIGN_RIGHT,TEXT_ALIGN_BOTTOM)

            surface.SetDrawColor(0,0,0)
            surface.DrawRect(0,h - 2,w,2)

            surface.SetDrawColor(255,255,255)
            surface.DrawRect(0,h - 2,w * (1 - (time / self.DelayScanTime)),2)

            draw.SimpleText(L("find_survivor"),butt.font,w/2,h/2,colorGray,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            butt:SetLock(true)
        else
            draw.SimpleText(L("find_survivor"),butt.font,w/2,h/2,nil,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            butt:SetLock(false)
        end
    end

    function butt.OnClick()
        if delay > RealTime() then return end
        delay = RealTime() + self.DelayScanTime

        startScanFunc()
    end
end

local delayScreenInfo = 5
local corner = 16

local mat = Material("homigrad/vgui/models/circle.png")

function Level:DrawScan()
    local dis = scanMaxDis * (1 - math.max(startScan - RealTime() + scanDelay,0) / scanDelay)
    
    if dis != scanMaxDis then
        local eyepos = EyePos()
        
        for i,ply in pairs(player.GetAll()) do
            if ply == LocalPlayer() or not ply:Alive() or HomicideScaned[ply] then continue end
            local pos = ply:GetPos():Add(ply:OBBCenter())
            if pos:Distance(eyepos) > dis then continue end

            local iconSize = 32
            local avatar = oop.CreatePanel("v_avataricons"):ad(function(self,w,h) self:setSize(iconSize + iconSize * 0.33,iconSize + iconSize * 0.33) end)
            avatar:Setup(iconSize)
            avatar:AddPlayer(ply)

            HomicideScaned[ply] = {
                origin = pos,
                name = ply:Name(),
                id = ply:SteamID(),
                start = RealTime(),
                avatar = avatar
            }

            timer.Simple(dis * UNITS_TO_METERS / SOUND_SPEED,function()
                local soundPos = EyePos() + (pos - EyePos()):GetNormalized():Mul(12)

                --SoundEmit("homigrad/vgui/playerping.wav",45,1,255,soundPos):SetParent(LocalPlayer())
            end)
        end
    end

    for ply,info in pairs(HomicideScaned) do
        local pos = info.origin
        
        local avatar = info.avatar
        local anim = math.max(info.start - RealTime() + delayScreenInfo,0) / delayScreenInfo

        if anim == 0 then
            if IsValid(avatar) then avatar:Remove() end

            HomicideScaned[ply] = nil

            return
        end

        local anim2 = math.min((1 - anim) * 25,1)
        local size = 8 + 128 * anim2
        
        pos = pos:ToScreen()

        anim = math.min(anim * 3,1)
        surface.SetAlphaMultiplier(anim)

        if Vector(pos.x,pos.y,0):Distance(Vector(ScrW()/2,ScrH()/2,0)) <= 64 then
            avatar:SetAlphaPanel(info.id,0)

            surface.SetDrawColor(255,0,0)
            surface.SetMaterial(mat)
            surface.DrawTexturedRectRotated(pos.x,pos.y,6,6,0)
            continue
        end//da

        surface.SetDrawColor(255,0,0,255 * (1 - anim2))
        surface.SetMaterial(mat)
        surface.DrawTexturedRectRotated(pos.x,pos.y,size,size,0)

        surface.SetFont("HS.12")
        local tw,th = surface.GetTextSize(info.name)
        tw,th = tw + corner,th + corner
        surface.SetDrawColor(255,0,0)
        draw.GradientDown(pos.x - tw/2,pos.y -corner/2,tw,th)
        draw.SimpleText(info.name,"HS.12",pos.x,pos.y,nil,TEXT_ALIGN_CENTER)

        if IsValid(avatar) then
            avatar:SetAlphaPanel(info.id,anim)
            avatar:SetPos(pos.x - tw/2 - avatar:W(),pos.y - avatar:H()/2)
        end
    end

    surface.SetAlphaMultiplier(1)
end

function Level:PreDrawSphereRing()
    if dis == scanMaxDis then return end

    local k = (1 - math.max(startScan - RealTime() + scanDelay,0) / scanDelay)
    local dis = scanMaxDis * k

    if k == 1 then return end
    
    DrawSphereRing(EyePos(),dis,colorRed,16 + 100 * k)
end