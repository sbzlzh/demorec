include("autorun/shared/sh_demorec_convars.lua")

if SERVER then
    AddCSLuaFile("autorun/shared/sh_demorec_convars.lua")
    AddCSLuaFile("demorec_config.lua")

    DemoRec = DemoRec or {}

    include("demorec_config.lua")

    function DemoRec.LoadDelayedModules()
        local gamemodesData = file.Read("demorec/modules/gamemodes/gamemodes.json", "LUA")
        local gamemodes = util.JSONToTable(gamemodesData)

        local currentGamemode = (GM or GAMEMODE).Name or (GM or GAMEMODE).BaseClass.Name
        local function includeGamemodeFiles(folder)
            local files = file.Find("demorec/modules/gamemodes/" .. folder .. "/*.lua", "LUA")
            for _, v in pairs(files) do
                include("demorec/modules/gamemodes/" .. folder .. "/" .. v)
            end
        end

        if gamemodes[currentGamemode] then
            includeGamemodeFiles(gamemodes[currentGamemode])
        end

        for i, v in pairs(config.ForcedModules) do
            if gamemodes[i] and v == true then
                includeGamemodeFiles(gamemodes[i])
            end
        end

        print("[DEMO系统] 已加载模块")
    end

    hook.Add("Initialize", "DemoRec_LoadModules", function()
        DemoRec.LoadDelayedModules()
    end)
end
