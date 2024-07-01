util.AddNetworkString("DemoRec.StartRecord")
util.AddNetworkString("DemoRec.EndRecord")

DemoRec = DemoRec or {}

hook.Add("PlayerInitialSpawn", "DemoRec.PlayerInitialSpawn", function(ply)
    DemoRec[ply:SteamID64()] = DemoRec[ply:SteamID64()] or { Queue = {}, recording = false }
end)

function DemoRec.GenerateRecordParams()
    local key = math.random(100000)
    local file_prefix = os.date("%Y-%m-%d %H-%M-%S", os.time())
    return key, file_prefix
end

net.Receive("DemoRec.StartRecord", function(len, ply)
    if GetGlobalInt("demorec_enabled") == 0 then return end

    local key = net.ReadUInt(18)
    local file_prefix = net.ReadString()
    
    DemoRec[ply:SteamID64()] = DemoRec[ply:SteamID64()] or {}
    DemoRec[ply:SteamID64()].key = key
    DemoRec[ply:SteamID64()].file_prefix = file_prefix

    net.Start("DemoRec.StartRecord")
    net.WriteUInt(key, 18)
    net.WriteString(file_prefix)
    net.Send(ply)

    print("[DEMO系统] 开始录制: " .. ply:Nick())
end)

net.Receive("DemoRec.EndRecord", function(len, ply)
    if GetGlobalInt("demorec_enabled") == 0 then return end

    net.Start("DemoRec.EndRecord")
    net.Send(ply)

    print("[DEMO系统] 结束录制: " .. ply:Nick())
end)

hook.Add("ShutDown", "DemoRec.ShutDown", function()
    if GetGlobalInt("demorec_enabled") == 0 then return end

    for _, ply in ipairs(player.GetAll()) do
        net.Start("DemoRec.EndRecord")
        net.Send(ply)
    end
end)

hook.Add("TTTBeginRound", "AutoStartDemoRecording", function()
    if GetGlobalInt("demorec_enabled") == 0 then return end

    local recordingCount = 0
    local startedPlayers = {}

    for _, ply in ipairs(player.GetAll()) do
        local key, file_prefix = DemoRec.GenerateRecordParams()
        
        net.Start("DemoRec.StartRecord")
        net.WriteUInt(key, 18)
        net.WriteString(file_prefix)
        net.Send(ply)

        DemoRec[ply:SteamID64()] = DemoRec[ply:SteamID64()] or {}
        DemoRec[ply:SteamID64()].key = key
        DemoRec[ply:SteamID64()].file_prefix = file_prefix
        DemoRec[ply:SteamID64()].recording = true

        recordingCount = recordingCount + 1
        table.insert(startedPlayers, ply:Nick())
    end

    print("[DEMO系统] 开始录制的玩家总数: " .. recordingCount)
    print("[DEMO系统] 开始录制的玩家: " .. table.concat(startedPlayers, ", "))
end)

hook.Add("TTTEndRound", "AutoStopDemoRecording", function()
    if GetGlobalInt("demorec_enabled") == 0 then return end

    local recordingCount = 0
    local stoppedPlayers = {}

    for _, ply in ipairs(player.GetAll()) do
        if DemoRec[ply:SteamID64()] and DemoRec[ply:SteamID64()].recording then
            net.Start("DemoRec.EndRecord")
            net.Send(ply)
            DemoRec[ply:SteamID64()].recording = false

            recordingCount = recordingCount + 1
            table.insert(stoppedPlayers, ply:Nick())
        end
    end

    print("[DEMO系统] 结束录制的玩家总数: " .. recordingCount)
    print("[DEMO系统] 结束录制的玩家: " .. table.concat(stoppedPlayers, ", "))
end)
