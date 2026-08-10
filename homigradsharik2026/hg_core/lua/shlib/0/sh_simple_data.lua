local util_JSONToTable = util.JSONToTable
local util_TableToJSON = util.TableToJSON

local file_Read = file.Read
local file_Write = file.Write

file.CreateDir("homigrad")
file.CreateDir("homigrad/sdata")

function SData_Get(name)
    return file_Read("homigrad/sdata/" .. name .. ".txt","DATA") or ""
end

function SData_Set(name,value)
    file_Write("homigrad/sdata/" .. name .. ".txt",value or "")
end

function SData_GetT(name)
    return util_JSONToTable(file_Read("homigrad/sdata/" .. name .. ".txt","DATA") or "") or {}
end

function SData_SetT(name,value)
    file_Write("homigrad/sdata/" .. name .. ".txt",util_TableToJSON(value) or "")
end