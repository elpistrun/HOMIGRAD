local COLOR = FindMetaTable("Color")

function COLOR:Clone() return Color(self.r,self.g,self.b,self.a) end

function COLOR:Set(colorTo)
    self.r = colorTo.r
    self.g = colorTo.g
    self.b = colorTo.b
    self.a = colorTo.a

    return self
end

function COLOR:Lerp(from,t)
    self.r = Lerp(t,self.r,from.r)
    self.g = Lerp(t,self.g,from.g)
    self.b = Lerp(t,self.b,from.b)
    self.a = Lerp(t,self.a,from.a)

    return self
end


function COLOR:LerpFT(t,from)
    self.r = LerpFT(t,self.r,from.r)
    self.g = LerpFT(t,self.g,from.g)
    self.b = LerpFT(t,self.b,from.b)
    self.a = LerpFT(t,self.a,from.a)

    return self
end