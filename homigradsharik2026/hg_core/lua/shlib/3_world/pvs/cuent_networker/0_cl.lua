local ENT = oop.Reg("custom_networker","lib_event",true)
if not ENT then return INCLUDE_BREAK end

ENT:Event_Add("Init","Networker",function(self)
    self.pos = self.pos or Vector()
    self.ang = self.ang or Angle()
end,-10)

function ENT:SetNetworker(cNetworker)
    if self:IsExistsServerNetworker() then return false end
    
    if not cNetworker then self:RemoveClientSideNetworker() error("CUENT:SetNetworker(" .. tostring(cNetworker) .. ") is null") end

    if self.cNetworker == cNetworker then return end

    self:RemoveClientSideNetworker()

    cNetworker = TypeID(cNetworker) == TYPE_ENTITY and cNetworker or CSM.CreateClientSideModel(cNetworker)
    self.cNetworker = cNetworker

    cNetworker.customEntity = self

    cNetworker:CallOnRemove("CustomEntity",function() self:Remove() end)

    self:OnClientSideNetworkerCreate(cNetworker)

    return cNetworker
end

function ENT:RemoveClientSideNetworker()
    local cNetworker = self.cNetworker
    self.cNetworker = nil

    if IsValid(cNetworker) then
        cNetworker:RemoveCallOnRemove("CustomEntity")
        CSM.Delete(cNetworker)
    end--EZ
end

function ENT:OnClientSideNetworkerCreate(networker)

end

function ENT:OnNetworkerCreate(oldNetworker)
    self:RemoveClientSideNetworker()
end

function ENT:LooseNetworker()
    ErrorNoHalt("[" .. self.ClassName .. "] Loose Networker\n")

    self:Remove()--pidoras ebani
end

ENT:Event_Add("Remove","Networker",function(self)
    self:RemoveClientSideNetworker()
end)

local wait = {}
local waitTimeout = {}

event.Add("PreCustomEntityCreate","Replace ClientSide Entity To Network Entity",function(pkg)
    local tag = pkg.mirrorTag
    
    local clientSideEnt = wait[tag]
    if not clientSideEnt then return end

    wait[tag] = nil
    waitTimeout[tag] = nil

    local copyListHas = {}

    for name in pairs(clientSideEnt.listHas) do
        copyListHas[name] = true

        clientSideEnt:SetList(name,false)
    end

    clientSideEnt.id = pkg.id

    for name in pairs(copyListHas) do
        clientSideEnt:SetList(name,true)
    end
end)

event.Add("Think","Timeout Wait Custom Entity Tag",function()
    local time = RealTime()

    for tag,start in pairs(waitTimeout) do
        if start > time then continue end

        local cuent = wait[tag]

        waitTimeout[tag] = nil
        wait[tag] = nil

        if IsValid(cuent) and cuent.LooseNetworker then cuent:LooseNetworker() end
    end
end,100)

function ENT:SetWaitCustomEntityTag(tag)
    wait[tag] = self
    waitTimeout[tag] = RealTime() + 5
end

function ENT:IsExistsServerNetworker() return self:GetPVSVar("NetworkerEntityIndex") and true or false end

function ENT:SetServerNetworker(newNetworker,isCreate)
    if self.sNetworker == newNetworker then return end
    
    local callAboutOldNetworker

    if newNetworker then
        newNetworker.customEntity = self
        self.sNetworker = newNetworker

        callAboutOldNetworker = self.sNetworker or false
    else
        if self.sNetworker then
            self.sNetworker.customEntity = nil
            
            callAboutOldNetworker = self.sNetworker
        end

        self.sNetworker = nil
    end

    if callAboutOldNetworker != nil then
        self:OnNetworkerCreate(self.sNetworker,callAboutOldNetworker,isCreate)

        self:Event_Call("SetNetworkServer",self.sNetworker)
    end
end

function ENT:WaitServerNetworker(entIndex,isCreate)
    local callAboutOldNetworker

    if entIndex then
        local newNetworker = EntityCoroutine(entIndex,0.5)

        if not newNetworker then
            self:LooseNetworker()

            return
        end

        self:SetServerNetworker(newNetworker)
    else
        self:SetServerNetworker()
    end
end

event.Add("CustomEntitySync","WaitServerNetworker",function(ent,pkg)
    if ent.WaitServerNetworker then ent:WaitServerNetworker(ent:GetPVSVar("NetworkerEntityIndex"),true) end
end)