local lerpImpulse = 0

hook.Add("RenderScreenspaceEffects","Impulse",function()
    if not LocalPlayer():Alive() then lerpImpulse = 0 return end
    
    lerpImpulse = LerpFT(0.1,lerpImpulse,LocalPlayer():GetNW2Float("impulse",0))

    if lerpImpulse <= 0.01 then return end

	--DrawToyTown(math.min(lerpImpulse * 6,6),ScrH())
end)