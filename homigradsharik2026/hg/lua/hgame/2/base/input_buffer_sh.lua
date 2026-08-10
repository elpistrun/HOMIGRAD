local SWEP = oop.Get("hg_wep_base")
if not SWEP then return end

SWEP:Event_Add("Init","InputBuffer",function(self)
    self.inputBuffer = inputBuffer.Create()
end,-10)

SWEP:Event_Add("Think","InputBuffer",function(self)
    self.inputBuffer:Think()
end,100)

function SWEP:InputBufferAdd(id,func,timeout)
    return self.inputBuffer:Add(id,func,timeout)
end