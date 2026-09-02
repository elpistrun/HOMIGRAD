local ENTITY = FindMetaTable("Entity")

if CLIENT then
    if not HSetLOD then HSetLOD = ENTITY.SetLOD end

    ENTITY.SetLOD = function(self,value)
        if self.currentLOD == value then return end
        self.currentLOD = value

        HSetLOD(self,value)
    end

    ENTITY.GetLOD = function(self) return self.currentLOD or 0 end
else
    ENTITY.SetLOD = function(self,value) end
    ENTITY.GetLOD = function(self) return 0 end
end