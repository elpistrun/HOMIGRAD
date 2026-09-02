_EventPluginsClasses = _EventPluginsClasses or {}
EventPluginsClasses = EventPluginsClasses or {}

function EventPlugin_Reg(class,base,isFolder) return oop.Reg(class,base,isFolder,0,_EventPluginsClasses) end
function EventPlugin_Get(class) return oop.Get(class,_EventPluginsClasses) end