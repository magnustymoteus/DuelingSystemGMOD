protectedcooldown = false
function cutstring(string)
	if(string:sub(#string) == "\n") then
		string = string:sub(1, #string-1)
	end
	return string
end
function duelnet() 
net.Receive("duelEnd", function(len) 
	died = net.ReadInt(3)
	opponent = net.ReadString()
	if(died == 0) then
		chat.AddText("You lost the duel with "..opponent.."!")
		notification.AddLegacy("You lost the duel with "..opponent.."!", NOTIFY_ERROR, 2)
	elseif(died == 1) then
		chat.AddText("You won the duel with "..opponent.."!")
		notification.AddLegacy("You won the duel with "..opponent.."!", NOTIFY_GENERIC, 2)
	end
end)
net.Receive("playerDisconnected", function(len) 
	requester = net.ReadInt(3)
	if(requester == 1) then
		chat.AddText("The person you wanted a duel with disconnected!")
	elseif(requester == 0) then
		chat.AddText("The person that wanted to duel with you disconnected!")
	end
end)
net.Receive("protectedAttacked", function(len) 
	if(protectedcooldown == false) then
	chat.AddText("The player you're attacking is in a duel or on your team!")
	protectedcooldown = true
	timer.Create("pCooldownTimer", 2.5, 1, function() protectedcooldown = false end)
	end
end)
net.Receive("duelanswer", function(len)
	answer = net.ReadInt(3)
	if(answer == 1) then
		notification.AddLegacy("Your duel was accepted!", NOTIFY_GENERIC, 2)
	elseif(answer == 0) then
		notification.AddLegacy("Your duel was rejected!", NOTIFY_ERROR, 2)
	end
end)
net.Receive("duelreceive", function(len) 
	nick = net.ReadString()
	chat.AddText(nick.." wants to duel with you, accept (/daccept) or reject (/dreject) the duel")
end)
net.Receive("duel", function(len)
	status = net.ReadInt(3)
	alive = net.ReadInt(3)
	eyetrace = net.ReadInt(3)
	if(status == 1) then
		if(alive == 1) then
			if(eyetrace == 1) then
				induel = net.ReadInt(3)
				if(induel == 1) then
					notification.AddLegacy("You are already dueling that player!", NOTIFY_ERROR, 2)
				elseif(induel == 0) then
					notification.AddLegacy("Duel request sent!", NOTIFY_GENERIC, 2)
				end
			elseif(eyetrace == 0) then
				notification.AddLegacy("You must look at a player to request a duel!", NOTIFY_ERROR, 2)
			end
		elseif(alive == 0) then
			notification.AddLegacy("You cannot request a duel while being dead!", NOTIFY_ERROR, 2)
			end
	elseif(status == 0) then
		notification.AddLegacy("Dueling is currently disabled!", NOTIFY_ERROR, 2)
		end
	end)
net.Receive("duelcount", function(len) 
	duel_timer = net.ReadInt(11)
	duel_count = duel_timer
	timer.Create("dueltimer", 1, duel_timer, function() 
		chat.AddText(tostring(duel_count))
		duel_count = duel_count - 1
	end)
	net.Receive("duelstart", function(len) 
		chat.AddText("Duel has started!")
	end)
end)
end
hook.Add("InitPostEntity", "initpostentity", duelnet)
