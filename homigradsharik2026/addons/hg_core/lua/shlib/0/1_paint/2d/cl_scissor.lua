if not HRenderSetScissorRect then HRenderSetScissorRect = render.SetScissorRect end

local XStart,YStart,XEnd,YEnd,Enable

function render.SetScissorRect(xStart,yStart,xEnd,yEnd,enable)
    XStart = xStart
    YStart = yStart

    XEnd = xEnd
    YEnd = yEnd
    Enable = enable

    if not enable then
        HRenderSetScissorRect(0,0,0,0,false)
    else
        HRenderSetScissorRect(xStart,yStart,xEnd,yEnd,enable)
    end
end

function render.SetScissor(xStart,yStart,w,h,enable)
    if not xStart then
        render.SetScissorRect()
    else
        render.SetScissorRect(xStart,yStart,xStart + w,yStart + h,enable)
    end
end

function render.GetScissorData()
    if not Enable then return end
    
    return XStart,YStart,XEnd,YEnd
end

event.Add("PreRender","ScissorReset",function()
    render.SetScissorRect()
end,-10)