if CLIENT then
    function PlayerBones(ent,tag,link)
        BonesManager_Init(ent)
        BonesManager_Clear(ent)
        
        if link[RenderLODTPIK] then
            ent:SetupBones()
        elseif ent.bones_matrix_render_max and ent.bones_matrix_render_max > 0 then
            ent:SetupBones()
            ent.bones_matrix_render_max = 0
        end
        
        if tag then
            if link.renderLOD2 then
                PlayerBones_BackWeapons(ent,tag,link)
            end

            PlayerBones_Armor(ent,tag,link)
        else
            if ent.InFake and ent:InFake() then return end--ждём вызова от регдола
            
            ent:SetLOD(
                (ent.renderLOD0 and 0) or
                (ent.renderLOD1 and 3) or
                (ent.renderLOD2 and 4) or
                (ent.renderLOD3 and 5) or
                0
            )
            
            PlayerBones_PreManipulation(ent,nil,link)
            
            if link.renderLOD1 then
                PlayerBones_Mouth(ent,nil,link)
                PlayerBones_Breath(ent,nil,link)
            end

            if link.renderLOD2 then
                if PlayerBones_GlideBones then PlayerBones_GlideBones(ent,nil,link) end
            end

            if link:IsTPIKAviable() then
                PlayerBones_TPIK(ent,link)
            else
                PlayerBones_TPIKFast(ent,link)
            end
            
            PlayerBones_PostManipulation(ent,nil,link)

            if link.renderLOD1 then
                PlayerBones_BackWeapons(ent,nil,link)
            end

            if link.renderLOD4 then
                PlayerBones_Armor(ent,nil,link)
            end

            if link.GetAimVector then ent:SetEyeTarget(link:GetAimVector():Mul(1024)) end
        end

        BonesManager_SetupRender(ent)
        
        return true
    end
end

function TPIK_Pipeline(ply,link,tpikMatrix)
    TPIK_Hand_PickupObject(ply,link,tpikMatrix)
    --TPIK_Hand_CarryObject(ply,link,tpikMatrix)

    TPIK_Weapon(ply,link,tpikMatrix)
end

function TPIK_Lerp_Pipeline(ply,link,tpikMatrix)
    TPIK_Lerp_Weapon(ply,link,tpikMatrix)
end

function TPIKFast_Pipeline(ply,link,tpikMatrix)
    TPIKFast_Weapon(ply,link,tpikMatrix)
end