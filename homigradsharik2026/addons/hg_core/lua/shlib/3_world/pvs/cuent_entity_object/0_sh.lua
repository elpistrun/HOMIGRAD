local ENT = oop.Reg("cuent_entity_object",{"base_entity","lib_event"},true)
if not ENT then return INCLUDE_BREAK end

if CLIENT then
    function ENT:Draw()
        if not self.customEntity then return end
        
        self:DrawModel()
    end
end