cvars.CreateOption("hg_graph","0",function(value)
    if (tonumber(value) or 0) > 0 then
        local fpsResult = 0
        local fpsCount = 0
        local fpsSum = 0

        local delay = 0

        local delayMemory = 0
        local count = 0

        local white = Color(255,255,255)
        local white2 = Color(225,225,225,125)

        local soundPoints = 0
        local soundEmitters = 0

        hook.Add("DrawOverlay","FPS Counter",function()
            fpsCount = fpsCount + 1
            fpsSum = fpsSum + FrameTime()

            if delay < RealTime() then
                delay = RealTime() + (1 / 36)

                fps = math.Round(1 / (fpsSum / fpsCount))

                fpsSum = 0
                fpsCount = 0

                soundEmitters = table.Count(sound.vurtialEmitIndex)
            end

            draw.SimpleText("FPS","HS.12",ScrW() * 0.55,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText(fps,"HS.18",ScrW() * 0.55,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

            if CSM then
                draw.SimpleText("CSMGlobalIndex","HS.12",ScrW() * 0.25 - 150,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
                draw.SimpleText(table.Count(CSM.globalIndex),"HS.18",ScrW() * 0.25 - 150,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

                draw.SimpleText("CSMRenderList","HS.12",ScrW() * 0.25,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
                draw.SimpleText(#CSM.renderList,"HS.18",ScrW() * 0.25,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

                draw.SimpleText("CSMContainerTagIndex","HS.12",ScrW() * 0.25 + 150,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
                draw.SimpleText(table.Count(CSM.containerTagIndex),"HS.18",ScrW() * 0.25 + 150,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            end

            --draw.SimpleText("soundPoints","HS.12",ScrW() * 0.8,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            --draw.SimpleText(soundPoints,"HS.18",ScrW() * 0.8,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            
            draw.SimpleText("soundEmitters","HS.12",ScrW() * 0.8 + 100,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
            draw.SimpleText(soundEmitters,"HS.18",ScrW() * 0.8 + 100,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

            draw.SimpleText("hashRT","HS.12",ScrW() * 0.6 + 100,ScrH(),white2,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)

            local count = 0

            for textureName,list in pairs(texture_uv.hash) do
                count = count + table.Count(list)
            end

            draw.SimpleText(count,"HS.18",ScrW() * 0.6 + 100,ScrH() - 10,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_BOTTOM)
        end)
    else
        hook.Remove("DrawOverlay","FPS Counter")
    end
end)