local color_black = Color(0,0,0)

function draw.SipmleTextBackground(text,font,x,y,color,colorBackground,textalign,textvalign)
    surface.SetFont(font)
    local tw,th = surface.GetTextSize(text)
    
    local xBackground = x

    if textalign == TEXT_ALIGN_LEFT then
        xBackground = x
    elseif textalign == TEXT_ALIGN_CENTER then
        xBackground = x - tw / 2
    elseif textalign == TEXT_ALIGN_RIGHT then
        xBackground = x - tw
    end

    local yBackground = y

    if textvalign == TEXT_ALIGN_TOP then
        yBackground = y
    elseif textvalign == TEXT_ALIGN_CENTER then
        yBackground = y - tw / 2
    elseif textvalign == TEXT_ALIGN_BOTTOM then
        yBackground = y - tw
    end

    surface.SetDrawColor(colorBackground or color_black)
    surface.DrawRect(xBackground,yBackground,tw,th)

    draw.SimpleText(text,font,x,y,color,textalign,textvalign)
end