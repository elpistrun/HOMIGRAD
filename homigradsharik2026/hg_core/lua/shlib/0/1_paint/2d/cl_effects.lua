local blurMaterial = Material('pp/bokehblur')

function RenderScreenspaceEffects_DrawBlur(k,mat,r,g,b)
    render.UpdateScreenEffectTexture()

    blurMaterial:SetTexture("$BASETEXTURE", mat and mat:GetTexture("$basetexture") or render.GetScreenEffectTexture())
    blurMaterial:SetTexture("$DEPTHTEXTURE", render.GetResolvedFullFrameDepth())
    blurMaterial:SetFloat("$size",(k * 300) ^ 0.5)
    blurMaterial:SetFloat("$focus", 1)
    blurMaterial:SetFloat("$focusradius", 1)

    render.SetMaterial(blurMaterial)
    
    if not mat then
        render.DrawScreenQuad()
    else
        surface.SetMaterial(blurMaterial)
    end
end