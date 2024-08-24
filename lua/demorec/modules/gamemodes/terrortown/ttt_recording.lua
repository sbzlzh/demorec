local function IsTTTRecordingEnabled()
    return config.ForcedModules["terrortown"] == true
end

local function ManageDemoRecording(action)
    if GetGlobalInt("demorec_enabled") == 0 or not IsTTTRecordingEnabled() then return end

    local recordingCount = 0
    local playersAffected = {}

    for _, ply in ipairs(player.GetAll()) do
        local id = GetPlayerSteamID64(ply)

        if action == "start" then
            local key, file_prefix = DemoRec.GenerateRecordParams()
            net.Start("DemoRec.StartRecord")
            net.WriteUInt(key, 18)
            net.WriteString(file_prefix)
            net.Send(ply)

            DemoRec[id] = DemoRec[id] or {}
            DemoRec[id].key = key
            DemoRec[id].file_prefix = file_prefix
            DemoRec[id].recording = true
        elseif action == "stop" and DemoRec[id] and DemoRec[id].recording then
            net.Start("DemoRec.EndRecord")
            net.Send(ply)
            DemoRec[id].recording = false
        end

        recordingCount = recordingCount + 1
        table.insert(playersAffected, ply:Nick())
    end

    --print(string.format("[DEMO系统] %s录制的玩家总数: %d", action == "start" and "开始" or "结束", recordingCount))
    --print(string.format("[DEMO系统] %s录制的玩家: %s", action == "start" and "开始" or "结束", table.concat(playersAffected, ", ")))
end

hook.Add("TTTBeginRound", "AutoStartDemoRecording", function()
    ManageDemoRecording("start")
end)

hook.Add("TTTEndRound", "AutoStopDemoRecording", function()
    ManageDemoRecording("stop")
end)
