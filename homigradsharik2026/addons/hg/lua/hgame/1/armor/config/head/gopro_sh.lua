local hg_dev_gopro

if CLIENT then
    cvars.CreateOption("hg_dev_gopro","0",function(value)
        hg_dev_gopro = tonumber(value or 0) > 0
    end,0,1,false)
end

armorGame.RegAtt("armor_att_go_pro",{
    printName = "Go Pro",
    model = "models/maxofs2d/camera.mdl",
    icon = "homigrad/gopro_icon.png",
    
    desc = "Записывает видео в корневую папку игры garrysmod/videos\nРазрешение 512x512\n24 Кадра в секунду\n50% Quality\n1400 BITRATE\nБудет лагать",

    category = "other",

    iframe = true,

    size = Vector(0.5,0.5,0.5),

    OnToggle = function()
        local stopRecord = function()
            if not iVideoWriter then return end

            event.Remove("PreRenderScene","Record")

            iVideoWriter:Finish()
            iVideoWriter = nil
        end

        if not iVideoWriter then
            local configRecord = {
                container = "webm",
                video = "vp8",
                audio = "vorbis",
                quality = 60,
                bitrate = 600,
                fps = 24,
                name = "HOMIGRADCOM_" .. os.date("%Y_%m_%d__%H_%M_%S",os.time()),
                width = 400,
                height = 400
            }

            local rView = {
                x = 0,
                y = 0,

                w = configRecord.width,
                h = configRecord.height,

                drawhud = false,
                drawviewmodel = false,
                dopostprocess = false,
                drawmonitors = false,
                bloomtone = true,

                fov = 90,
                drawviewer = false,

                origin = Vector(),
                angles = Angle(),

                viewid = 2,

                aspectratio = 1,

                znear = 1,
                zfar = 16000
            }

            iVideoWriter = iVideoWriter or video.Record(configRecord)
            iVideoWriter:SetRecordSound(true)

            local delay = 0
            local startStop

            local modelMatrix = Matrix()
            modelMatrix:Scale(Vector(ScrW() / configRecord.width,ScrH() / configRecord.height,1))

            local rtGoPro = GetRenderTarget("rtGoPro" .. rView.w .. rView.h,rView.w,rView.h)

            local angShake = Angle()
            local angShakeApply = Angle()
            local oldAng

            event.Add("PreRenderScene","Record",function()
                local ent = LocalPlayer():GetDummy()
                if not IsValid(ent) or not LocalPlayer():Alive() then stopRecord() return end

                if startStop then
                    if startStop < RealTime() then
                        stopRecord()

                        return
                    end
                else
                    if not LocalPlayer():Alive() then
                        startStop = RealTime() + 10
                    end
                end

                local pass = delay <= RealTime()

                local Pos,Ang,mdlGoPro

                for armorName,armorData in pairs(LocalPlayer().Armors.native) do
                    if not armorData.attachments or not IsValid(armorData.wm) then continue end
                    
                    for path,key in pairs(armorData.attachments) do
                        if key[2][1] == "armor_att_go_pro" then
                            mdlGoPro = armorData.wm.attachments[path]

                            Pos,Ang = mdlGoPro:GetPos(),mdlGoPro:GetAngles()
                            Pos,Ang = LocalToWorld(key[2].goProPos or Vector(0,0,0),key[2].goProAng or Angle(),Pos,Ang)
                        end
                    end
                end

                if Pos then
                    Ang[3] = Ang[3] / 1.33

                    if not oldAng then oldAng = Ang end

                    local diffAng = oldAng - Ang
                    diffAng:Normalize()

                    oldAng = Ang

                    angShake:Add(diffAng:Mul(0.02 + CameraLand:Length() / 10 + CameraFoot / 12))
                    angShake:LerpFT(0.1)

                    angShakeApply:LerpFT(0.5,AngleRand(-angShake:Length(),angShake:Length()))

                    Ang = Ang:Clone()
                    Ang[1] = Ang[1] + CameraFoot + CameraLand:Length()
                    Ang[2] = Ang[2] + CameraFoot * CameraFootSide
                    Ang:Add(angShakeApply)
                    Ang:Add(diffAng * 10)

                    rView.origin = Pos
                    rView.angles = Ang

                    if hg_dev_gopro or pass then
                        SetReplaceViewEntity("gopro")
                        SetReplaceRenderIsMeName(rtGoPro:GetName())

                        ClearRenderFrame()

                        mdlGoPro:SetSubMaterial(0,"null")

                        render.PushRenderTarget(rtGoPro)
                        render.RenderView(rView)
                        render.PopRenderTarget()
                    
                        mdlGoPro:SetMaterial(0)

                        cam.IgnoreZ(true)
                        cam.Start2D()
                        cam.PushModelMatrix(modelMatrix,true)

                        render.DrawTextureToScreenRect(rtGoPro,0,0,ScrW(),ScrH())

                        draw.SimpleText("HOMIGRAD.COM","HS.12",16,16)
                        draw.SimpleText(os.date("%d/%m/%Y %H:%M:%S",os.time()),"HS.12",16,28)

                        cam.PopModelMatrix()
                        cam.End2D()
                        cam.IgnoreZ(false)

                        SetReplaceViewEntity(nil)
                        SetReplaceRenderIsMeName(nil)
                    end
                else
                    cam.IgnoreZ(true)
                    cam.Start2D()
                    cam.PushModelMatrix(modelMatrix,true)

                    draw.SimpleText("NO SIGNAL","HS.45",ScrW()/2,ScrH()/2)

                    cam.PopModelMatrix()
                    cam.End2D()
                    cam.IgnoreZ(false)
                end

                GoProOrigin = nil
                GoProAngles = nil

                if pass then
                    delay = RealTime() + 1 / configRecord.fps

                    iVideoWriter:AddFrame(FrameTime(),true)
                end

                if hg_dev_gopro then return false end
            end)
        else
            stopRecord()
        end
    end,

    ToggleDraw = function(panel)
        if not iVideoWriter then return end

        local size = 16
        local corner = 4

        local w,h = panel:W(),panel:H()
        surface.SetDrawColor(255,0,0)
        surface.DrawRect(w - size - corner,h - size - corner,size,size)
    end
},armorGame.sound_goggles)

attachmentGame.ManualReg("gopro",{
    ["armor_att_go_pro"] = {
        "armor_att_go_pro",
        vec = Vector(),
        ang = Angle()
    }
})

event.Add("RenderLocalPlayerHead","GoPro",function()
    if GetViewEntity() == "gopro" then return false end
end)