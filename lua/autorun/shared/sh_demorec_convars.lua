CreateConVar("demorec_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable or disable the Demo Recording system")
CreateConVar("demorec_show_chat_messages", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Enable or disable chat messages for Demo Recording")

hook.Add("Initialize", "AddDEMOGlobals", function()
    SetGlobalInt("demorec_enabled", GetConVar("demorec_enabled"):GetInt())
    SetGlobalInt("demorec_show_chat_messages", GetConVar("demorec_show_chat_messages"):GetInt())
end)

cvars.AddChangeCallback("demorec_enabled", function(name, old, new)
    SetGlobalInt("demorec_enabled", tonumber(new))
end)

cvars.AddChangeCallback("demorec_show_chat_messages", function(name, old, new)
    SetGlobalInt("demorec_show_chat_messages", tonumber(new))
end)
