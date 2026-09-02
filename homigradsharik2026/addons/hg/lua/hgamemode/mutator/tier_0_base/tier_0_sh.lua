//https://music.youtube.com/watch?v=zQkDun6VPbY&si=a0Oc2ad-Bb_GKDQH

local MUTATOR = Mutator_Reg("base",nil,true)
if not MUTATOR then return INCLUDE_BREAK end

util.tableLink(MUTATOR,oop.listClass.lib_event[1])

MUTATOR.ClassName = "base"

MUTATOR.ResetWithRound = false
MUTATOR.ResetWithCleanUp = false

function MUTATOR:GetActive() return self.enabled end
function MUTATOR:GetPrintName() return self.Title or self.ClassName end

function MUTATOR:SetupVars() end

function MUTATOR:On() end
function MUTATOR:Off() end

//

ActiveMutators = ActiveMutators or {}

MUTATOR:Event_Add("On","Main",function(self)
    ActiveMutators[self.ClassName] = self

    self:On()
end)

MUTATOR:Event_Add("Off","Main",function(self)
    ActiveMutators[self.ClassName] = nil

    self:Off()
end)

MUTATOR:Event_Add("Construct","Class",function(self)
    if not MutatorClasses[self.ClassName] then
        MutatorClasses[self.ClassName] = {}
    end

    util.tableLink(MutatorClasses[self.ClassName],self[1])

    MutatorClasses[self.ClassName]:SetupVars()
end)

function MUTATOR:SetupVar(name)
    self["Set" .. name] = function(self,value)
        SetGlobalVar(self.ClassName .. "_" .. name,value)

        local func = self["OnChange" .. name]
        if func then func(self,value) end
    end

    self["Get" .. name] = function(self)
        return GetGlobalVar(self.ClassName .. "_" .. name)
    end
end