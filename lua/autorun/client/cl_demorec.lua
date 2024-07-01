DemoRec = DemoRec or {}
DemoRec.Queue = DemoRec.Queue or {}
DemoRec.settings = DemoRec.settings or {}
DemoRec.CurrentRecord = DemoRec.CurrentRecord or {}
DemoRec.recording = DemoRec.recording or {}

local saveDirectory = "rxscp" -- 在 data 目录下的子目录

function DemoRec.InitializePlayerData(ply)
    local id = ply:SteamID64()
    DemoRec.Queue[id] = DemoRec.Queue[id] or {}
    DemoRec.CurrentRecord[id] = DemoRec.CurrentRecord[id] or {}
    DemoRec.recording[id] = DemoRec.recording[id] or false
end

function DemoRec.EndRecord(ply)
    if not IsValid(ply) or GetGlobalInt("demorec_enabled") == 0 then return end

    local id = ply:SteamID64()
    DemoRec.InitializePlayerData(ply)

    RunConsoleCommand("stop")
    DemoRec.recording[id] = false
    local CurrentRecord = DemoRec.Queue[id][1] or DemoRec.CurrentRecord[id]
    table.remove(DemoRec.Queue[id], 1)
    if not CurrentRecord then
        return
    end

    local filename = CurrentRecord.filename --or "default.dem"
    local savePath = saveDirectory .. "/" .. filename
    print(savePath)
    if not file.Exists(saveDirectory, "DATA") then
        file.CreateDir(saveDirectory)
    end

    timer.Simple(1, function()
        if file.Exists(savePath, "DATA") then
            if GetGlobalInt("demorec_show_chat_messages") == 1 then
                ply:ChatPrint("[DEMO系统] 录像保存为: 'data/" .. savePath .. "'")
            end
        else
            if GetGlobalInt("demorec_show_chat_messages") == 1 then
                ply:ChatPrint("[DEMO系统] 找不到录像 'data/rxscp' 目录.")
            end
        end
    end)
end

function DemoRec.StartRecord()
    local ply = LocalPlayer()
    if not IsValid(ply) or GetGlobalInt("demorec_enabled") == 0 then return end

    local id = ply:SteamID64()
    DemoRec.InitializePlayerData(ply)

    if DemoRec.recording[id] then
        table.insert(DemoRec.Queue[id], DemoRec.CurrentRecord[id])
        DemoRec.EndRecord(ply)
    end

    DemoRec.CurrentRecord[id] = {}
    DemoRec.CurrentRecord[id].key = net.ReadUInt(18) or 0
    DemoRec.CurrentRecord[id].file_prefix = net.ReadString() or "default"
    DemoRec.CurrentRecord[id].filename = DemoRec.CurrentRecord[id].file_prefix .. ".dem"

    local savePath = "data/" .. saveDirectory .. "/" .. DemoRec.CurrentRecord[id].file_prefix
    RunConsoleCommand("record", savePath)
    if GetGlobalInt("demorec_show_chat_messages") == 1 then
        ply:ChatPrint("[DEMO系统] 开始录制")
    end
    DemoRec.recording[id] = true
end

net.Receive("DemoRec.StartRecord", DemoRec.StartRecord)

net.Receive("DemoRec.EndRecord", function()
    local ply = LocalPlayer()
    DemoRec.EndRecord(ply)
end)

hook.Add("Initialize", "DemoRec.Initialize", function()
    hook.Remove("HUDPaint", "DrawRecordingIcon")
end)

hook.Add("PlayerInitialSpawn", "DemoRec.InitializePlayerData", function(ply)
    DemoRec.InitializePlayerData(ply)
end)
