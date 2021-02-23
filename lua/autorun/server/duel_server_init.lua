--Code by Patryk Pilichowski, all rights reserved
util.AddNetworkString("duel")
util.AddNetworkString("duelreceive")
util.AddNetworkString("duelanswer")
util.AddNetworkString("duelcount")
util.AddNetworkString("duelstart")
util.AddNetworkString("protectedAttacked")
util.AddNetworkString("playerDisconnected")
duel_startTime = 5
function cutstring(string)
	if(string:sub(#string) == "\n") then
        string = string:sub(1, #string-1)
	end
	return string
end
function configcheck()
    if not file.Exists("server_duelconfig.txt", "DATA") then file.Write("server_duelconfig.txt", "enabled\n/duel\n100")end
    local f = file.Open( "server_duelconfig.txt", "r", "DATA" )
duel_status = f:ReadLine()
duel_command = f:ReadLine()
duel_reward = f:ReadLine()
f:Close()
end
hook.Add("PlayerSay", "playerSay01", function(player, text, teamchat)
     configcheck()
	 if(text == cutstring(duel_command)) then
		net.Start("duel")
		request = false
		if(cutstring(duel_status) == "enabled") then
			net.WriteInt(1, 3)
			if(player:Alive() == true) then
				net.WriteInt(1, 3)
				eyetrace = player:GetEyeTrace()
				if(eyetrace.Entity:IsPlayer() == true) then
					net.WriteInt(1,3)
					request = true
				elseif(eyetrace.Entity:IsPlayer() == false) then
					net.WriteInt(0,3)
				end
				elseif(player:Alive() == false) then
				net.WriteInt(0, 3)
			end
		elseif(cutstring(duel_status) == "disabled") then
			net.WriteInt(0, 3)
		end
	net.Send(player)
	if(request == true) then
		targets = {player, eyetrace.Entity}
		net.Start("duelreceive")
		net.WriteString(player:Nick())
		net.Send(eyetrace.Entity)
		hook.Add("PlayerDisconnected", "player_disc", function(disc_player) 
			net.Start("playerDisconnected")
			if(disc_player == eyetrace.Entity) then
				net.WriteInt(1, 3)
				net.Send(player)
			elseif(disc_player == player) then
				net.WriteInt(0, 3)
				net.Send(eyetrace.Entity)
			end
			targets = {}
			hook.Remove("player_disc")
		end)
		hook.Add("PlayerSay", "playerSay02", function(ply01, text, teamchat) 
			if(text == "/daccept") then
				previous_status = {player:Health(), player:Armor(), eyetrace.Entity:Health(), eyetrace.Entity:Armor()}
				net.Start("duelanswer")
				net.WriteInt(1,3)
				net.Send(player)
				hook.Remove("PlayerSay", "playerSay02")
				eyetrace.Entity:Freeze(true)
				player:Freeze(true)
				eyetrace.Entity:SetHealth(100)
				eyetrace.Entity:SetArmor(0)
				eyetrace.Entity:SetEyeAngles((player:GetBonePosition(player:LookupBone("ValveBiped.Bip01_Head1"))-eyetrace.Entity:GetShootPos()):Angle())
				player:SetHealth(100)
				player:SetArmor(0)
				player:SetEyeAngles((eyetrace.Entity:GetBonePosition(eyetrace.Entity:LookupBone("ValveBiped.Bip01_Head1"))-player:GetShootPos()):Angle())
				for i=1, 2 do 
					net.Start("duelcount")
					net.WriteInt(duel_startTime, 11)
					net.Send(targets[i])
				end
				timer.Create("dueltimer", duel_startTime+1, 1, function() 
					for i=1, 2 do 
						net.Start("duelstart")
						net.Send(targets[i])
					end
					eyetrace.Entity:Freeze(false)
					player:Freeze(false)
					hook.Add("PlayerShouldTakeDamage", "DuelProtection", function(attacked, attacker) 
						if(((attacked == player) and (attacker == eyetrace.Entity)) or ((attacked == eyetrace.Entity) and (attacker == player))) then
							return true
						else
							net.Start("protectedAttacked") 
							net.Send(attacker)
							return false
						end
					end)
				end)
			elseif(text == "/dreject") then
				net.Start("duelanswer")
				net.WriteInt(0,3)
				net.Send(player)
				hook.Remove("PlayerSay", "playerSay02")
			end
		end)
	 end
	 end
end)