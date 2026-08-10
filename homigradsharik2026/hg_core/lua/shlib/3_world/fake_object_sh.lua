fakeObject = fakeObject or {}
util.tableLink(fakeObject,oop.listClass.lib_event_noself[1])
fakeObject.IsValid = function() return true end

local fakeExample = fakeObject.fakeExample or {}
fakeObject.fakeExample = fakeExample

function fakeExample:GetNWBool(name,def) return def end
function fakeExample:GetNWString(name,def) return def end
function fakeExample:GetNWFloat(name,def) return def end
function fakeExample:GetNWVector(name,def) return def end
function fakeExample:GetNWAngle(name,def) return def end

local chacheFake = {}

function fakeObject.GetFakeObjectRender(class,item)
    local info = chacheFake[item]

    if not info or info.fake.LastRealTimeRegistry ~= class.LastRealTimeRegistry then
        info = fakeObject.CreateFakeObject(class,item,info)

        chacheFake[item] = info
    end

    timer.Create(tostring(item) .. "CreateFakeSelfFromItem",1,1,function() chacheFake[item] = nil end)

    return info.fake
end

local ENTITY = FindMetaTable("Entity")

function fakeObject.CreateFakeObject(class,item,info)
    info = info or {}
    info.class = class

    local fake = util.tableCopy(class)
    fake.csmParentTag = tostring(info.fake) .. "_"
    
    info.fake = fake

    fakeObject.Parse(class,fake,item)

    return info
end

function fakeObject.Parse(class,fake,item)
    for k,v in pairs(fakeExample) do fake[k] = v end
    
    fakeObject:Event_Call("Create",fake)

    if class.CreateFakeSelfFromItem then class.CreateFakeSelfFromItem(fake,item) end--NEED DATA ITEM
end