local Level = oop.Reg("level_base","lib_event",true)
if not Level then return INCLUDE_BREAK end

Level.DelayStartRound = 5

function Level:Start()
    if SERVER then
        self:StartShared()

        self:StartServer()
        self:SetupFMTeams()
    else
        game.CleanUpMap(false)

        self:StartShared()

        self:StartClient()
    end
end

function Level:StartShared() end
function Level:StartServer() end
function Level:StartClient() end

function Level:End(data)
    self:EndShared(data)

    if SERVER then
        return self:EndServer()
    else
        self:EndClient()
    end
end

function Level:EndShared() end
function Level:EndServer() end
function Level:EndClient() end

function Level:DrawCenter() end

//

function Level:CheckEnd()

end

function Level:Log(content)
    return SendLog({
        type = "game",
        content = content
    })
end

Level:Event_Add("Construct","Level",function(self)
    local class = self[1]
    local className = class.ClassName
    
    if className == "level_base" then return end

    Levels[className] = class
    _G[className] = class
end)

local models = {}

for i = 1,9 do table.insert(models,"models/player/group01/male_0" .. i .. ".mdl") end
for i = 1,6 do table.insert(models,"models/player/group01/female_0" .. i .. ".mdl") end

Level.StandardPlayerModels = models