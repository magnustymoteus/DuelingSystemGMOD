--Code by Magnus Tymoteus, all rights reserved
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("../duel_confighandler.lua")
function ENT:Initialize()
    self:SetModel("models/squad/sf_plates/sf_plate4x7.mdl")
    self:SetMaterial("models/props_c17/frostedglass_01a")
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end
hook.Add("OnEntityCreated", "entSpawn", function(ent) 
    if ent:GetClass() == "duelpanel" then
        util.AddNetworkString("drawn")
        net.Receive("drawn", function(len, ply)
            configcheck()
            util.AddNetworkString("duelConfig")
            net.Start("duelConfig")
            net.WriteString(duel_status)
            net.WriteString(duel_command)
            net.WriteInt(tonumber(duel_reward), 16)
            net.Send(ply) end)
    util.AddNetworkString("duelconfig_clientsend")
    net.Receive("duelconfig_clientsend", function(len,ply)  
        local duelst = net.ReadString()
        local duelcom = net.ReadString()
        local rew = tostring(net.ReadInt(16))
            
        file.Write("server_duelconfig.txt", duelst.."\n"..duelcom.."\n"..rew)
    end)
    end
end)
