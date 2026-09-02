local MUTATOR = Mutator_Get("base")
if not MUTATOR then return end

function MUTATOR:CoreStart()
    self:ConstructPlug(true)
    self:Start()
end

function MUTATOR:CoreEnd()
    self:ConstructPlug(false)
    self:End()
end

local delaySound = 0

function MUTATOR:InputData(data)
    if self.enabled ~= data.enabled then
        self.enabled = data.enabled

        if self.enabled then
            self:Event_Call("On")
        else
            self:Event_Call("Off")
        end
    end

    if self.Sync then self:Sync(data) end
end

net.Receive("mutator_data",function()
    local className,data = net.ReadString(),net.ReadTable()

    MutatorClasses[className]:InputData(data)
end)

function MUTATOR:SendCMD(cmdName,args)
    net.Start("mutator_cmd")
    net.WriteString(self.ClassName)
    net.WriteString(cmdName)
    net.WriteTable(args)
    net.SendToServer()
end