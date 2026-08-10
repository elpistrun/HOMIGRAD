cvars.permamentConsoleVars = {
    ["mat_queue_mode"] = -1,--обработка графики в нескольких потоках
    ["cl_threaded_bone_setup"] = 1,
    ["r_threaded_particles"] = 1,
    ["r_queued_ropes"] = 1,

    ["r_drawmodeldecals"] = 1,
    
    ["r_decal_cover_count"] = 4,
    ["r_decal_overlap_area"] = 0.4,
    ["r_decal_overlap_count"] = 3,
    ["r_decalstaticprops"] = 1,

    ["mp_decals"] = 4194304,
    ["r_maxmodeldecal"] = 4194304,
    ["r_decals"] = 4194304,
    ["r_decal_cover_count"] = 4194304
}

function cvars.SetPermament(name,def)
    cvars.permamentConsoleVars[name] = def
    
    cvars.AddChangeCallback(name,function() RunConsoleCommand(name,def) end,"go back")

    RunConsoleCommand(name,def)
end

function cvars.UpdatePermamentConsoleVars()
    for name,default in pairs(cvars.permamentConsoleVars) do
        cvars.SetPermament(name,default)
    end
end

cvars.UpdatePermamentConsoleVars()

concommand.Add("hg_flush",function()
    local int = GetConVar("gmod_mcore_test"):GetInt()

    RunConsoleCommand("gmod_mcore_test",0)
    RunConsoleCommand("r_flushlod")
    RunConsoleCommand("snd_restart")
    RunConsoleCommand("gmod_mcore_test",int)
end)

hook.Add("InitPostEntity","hg_flushlod",function()
    cvars.UpdatePermamentConsoleVars()

    RunConsoleCommand("hg_flush")
end)