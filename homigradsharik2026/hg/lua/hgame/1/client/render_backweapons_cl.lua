cvars.CreateOption("hg_draw_backweapons","1",function(value)
    if tonumber(value) > 0 then
        function PlayerBones_BackWeapons(ent,tag,link)
            local WeaponRender = GetHashTable(ent,"WeaponRender")
            for i = 1,#WeaponRender do WeaponRender[i] = nil end

            if not tag and link == LocalPlayer() and link:EyeMode() then return end

            local weapons = link:GetNWTable("WeaponEntIndexList")
            if not weapons then weapons = link:GetWeapons() end--maybe fake object
            
            local activeWeapon = link:GetActiveWeapon()

            local isWorld = not tag
            local typeDraw = isWorld and true or "nodraw"

            for i = 1,#weapons do
                local wep = weapons[i]
                if TypeID(wep) == TYPE_NUMBER then wep = Entity(wep) end

                if not IsValid(wep) or not wep.vbwPos or activeWeapon == wep or not wep.Render then continue end

                local Pos,Ang = PlayerBackWeapons_Get(ent,wep)
                if not Pos then continue end
                
                Pos,Ang = wep:Transform_GetCenter(Pos,Ang)
                
                local wm,isCreate = wep:InitWorldModel((tag or "") .. "_backspine",typeDraw,false,wep.vbwUseWMDropData and wep.wmDropData)
                if not IsValid(wm) then return end
                
                if isCreate then
                    --wm:SetParent(ent)
                end

                wm:SetPos(Pos)
                wm:SetAngles(Ang)
                wep:SetupModel(wm)
                
                wep.backWM = wm
                
                WeaponRender[#WeaponRender + 1] = wep
            end
        end

        function RenderPlayer_BackWeapons(ent,tag,link,flags)
            local WeaponRender = ent.WeaponRender
            if not WeaponRender then return end--WTF

            for i = 1,#WeaponRender do
                local wep = WeaponRender[i]
                
                if not wep.Render or not IsValid(wep.backWM) then continue end--WTTF
                wep:Render(wep.backWM)
            end
        end
    else
        function PlayerBones_BackWeapons() end
        function RenderPlayer_BackWeapons() end
    end
end)