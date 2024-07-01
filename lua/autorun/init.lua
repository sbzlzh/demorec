if SERVER then
    AddCSLuaFile('autorun/shared/sh_demorec_convars.lua')
    include("autorun/shared/sh_demorec_convars.lua")
end

if CLIENT then
    include("autorun/shared/sh_demorec_convars.lua")
end
