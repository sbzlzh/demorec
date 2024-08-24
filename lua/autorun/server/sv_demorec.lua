util.AddNetworkString("DemoRec.StartRecord")
util.AddNetworkString("DemoRec.EndRecord")

DemoRec = DemoRec or {}

hook.Add("PlayerInitialSpawn", "DemoRec.PlayerInitialSpawn", function(ply)
    local id = GetPlayerSteamID64(ply)
    DemoRec[id] = DemoRec[id] or { recording = false }
end)

function DemoRec.GenerateRecordParams()
    local key = math.random(100000)
    local file_prefix = os.date("%Y-%m-%d_%H-%M-%S", os.time())
    return key, file_prefix
end

net.Receive("DemoRec.StartRecord", function(len, ply)
    if GetGlobalInt("demorec_enabled") == 0 then return end

    local key, file_prefix = DemoRec.GenerateRecordParams()
    local id = GetPlayerSteamID64(ply)

    net.Start("DemoRec.StartRecord")
    net.WriteUInt(key, 18)
    net.WriteString(file_prefix)
    net.Send(ply)

    --print("[DEBUG] 发送到客户端的文件前缀: ", file_prefix)
    --print("[DEMO系统] 开始录制: " .. ply:Nick())
end)

net.Receive("DemoRec.EndRecord", function(len, ply)
    if GetGlobalInt("demorec_enabled") == 0 then return end

    net.Start("DemoRec.EndRecord")
    net.Send(ply)

    --print("[DEMO系统] 结束录制: " .. ply:Nick())
end)

hook.Add("ShutDown", "DemoRec.ShutDown", function()
    if GetGlobalInt("demorec_enabled") == 0 then return end

    for _, ply in ipairs(player.GetAll()) do
        net.Start("DemoRec.EndRecord")
        net.Send(ply)
    end
end)
