--Code by Patryk Pilichowski, all rights reserved
protectedcooldown = false
function cutstring(string)
	if(string:sub(#string) == "\n") then
		string = string:sub(1, #string-1)
	end
	return string
end
function duelnet() 
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
		chat.AddText("Your duel was accepted!")
	elseif(answer == 0) then
		chat.AddText("Your duel was rejected!")
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
				chat.AddText("Duel request sent!")
			elseif(eyetrace == 0) then
				chat.AddText("You must look at a player to request a duel!")
			end
		elseif(alive == 0) then
			chat.AddText("You cannot request a duel while being dead!")
			end
	elseif(status == 0) then
		chat.AddText("Dueling is currently disabled!")
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