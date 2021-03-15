--Code by Patryk Pilichowski, all rights reserved
util.AddNetworkString("duel")
util.AddNetworkString("duelreceive")
util.AddNetworkString("duelanswer")
util.AddNetworkString("duelcount")
util.AddNetworkString("duelstart")
util.AddNetworkString("protectedAttacked")
util.AddNetworkString("playerDisconnected")
util.AddNetworkString("duelEnd")
duel_startTime = 5
targets = {}
d_accepted = false
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
					if((player == targets[1] and eyetrace.Entity == targets[2]) or (eyetrace.Entity == targets[1] and player == targets[2])) and (d_accepted == true) then
						net.WriteInt(1,3)
					else 
						net.WriteInt(0,3)
						request = true
					end
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
			d_accepted = false
			request = false
		end)
		hook.Add("PlayerSay", "playerSay02", function(ply01, text, teamchat) 
			if(text == "/daccept") then
				d_accepted = true
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
					hook.Add("PlayerDeath", "deathInDuel", function(victim, inflictor, attacker) 
						if(victim == player) and (attacker == eyetrace.Entity) then
							for i=0, 1 do
								net.Start("duelEnd")
								net.WriteInt(i, 3)
								net.WriteString(targets[(math.abs(i)*-1)+2]:Nick())
								net.Send(targets[i+1])
								eyetrace.Entity:SetHealth(previous_status[3])
								eyetrace.Entity:SetArmor(previous_status[4])
							end
						elseif(victim == eyetrace.Entity) and (attacker == player) then
							for i=0, 1 do
								net.Start("duelEnd")
								net.WriteInt((math.abs(i)*-1)+1, 3)
								net.WriteString(targets[(math.abs(i)*-1)+2]:Nick())
								net.Send(targets[i+1])
								player:SetHealth(previous_status[1])
								player:SetArmor(previous_status[2])
							end
						end
						previous_status = {}
						targets = {}
						request = false
						d_accepted = false
						hook.Remove("PlayerDisconnected", "player_disc")
						hook.Remove("PlayerShouldTakeDamage", "DuelProtection")
						hook.Remove("PlayerDeath", "deathInDuel")
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