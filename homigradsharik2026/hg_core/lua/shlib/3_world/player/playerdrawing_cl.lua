local vec = Vector(1,1,1)

hook.Add("InitPostEntity","PlyColor",function()
    matproxy.Add({
        name = "PlayerColor",
        init = function(self,mat,values)
            self.ResultTo = values.resultvar or "$color"
        end,
        bind = function(self,mat,ent)
            mat:SetVector(self.ResultTo,(IsValid(ent) and ent.GetPlayerColor and ent:GetPlayerColor()) or vec)
       end 
    })
end)

event.Add("Player Spawn","RenderOverride",function(ply)
    --ply:SetRenderBounds(-Vector(512,512,512),Vector(512,512,512)) не помогает
    --ply:SetRenderMode(RENDERMODE_NORMAL)
    
    ply.csmParentTag = ply:EntIndex()

    if ply == LocalPlayer() then
        ply.RenderOverride = function(self,flags)
            if not self.passRender then return end
            
            RenderLocalPlayer(ply,nil,ply,flags)
        end
    else
        ply.RenderOverride = function(self,flags)
            RenderPlayer(ply,nil,ply,flags)
        end
    end
end)

function RenderFlagsIsShadow(flags) return flags != 1 and flags != 9 and flags != 134217729 and flags != -2147483647 end

local STUDIO_FLAGS = {
    STUDIO_RENDER = 1,
    STUDIO_VIEWXFORMATTACHMENTS = 2,
    STUDIO_DRAWTRANSLUCENTSUBMODELS = 4,
    STUDIO_TWOPASS = 8,
    STUDIO_STATIC_LIGHTING = 16,
    STUDIO_WIREFRAME = 32,
    STUDIO_ITEM_BLINK = 64,
    STUDIO_NOSHADOWS = 128,
    STUDIO_WIREFRAME_VCOLLIDE = 256,
    STUDIO_GENERATE_STATS = 16777216,
    STUDIO_SSAODEPTHTEXTURE = 134217728,
    STUDIO_SHADOWDEPTHTEXTURE = 1073741824,
    STUDIO_TRANSPARENCY = 2147483648
}

function RenderSplitFlags(flags)
    local table = {}
    
    for key,value in pairs(STUDIO_FLAGS) do
        if bit.band(flags,value) ~= 0 then table[key] = value end
    end

    return table
end

hook.Add("PostDrawTranslucentRenderables","LocalPlayer",function(isDepth,isSkybox,is3DSkybox)
    if isSkybox or isDepth or is3DSkybox then return end

    local lply = LocalPlayer()
    if not lply:Alive() or lply:GetNoDraw() then return end

    local ent = lply:GetDummy()

    event.Call("PreDrawLocalPlayer")
    
	render.SetColorModulation(1,1,1)
    render.SetBlend(1)--сучка умри

    ent.passRender = true
    ent:DrawModel()
    ent.passRender = nil
end)

function EntityFirstSetupBones(ent)
    if RENDER_BEFORE_WORLD or IsFirstFrame(ent,"r_setupbones") then ent:SetupBones() return true end
end