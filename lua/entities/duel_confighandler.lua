function configcheck()
    if not file.Exists("server_duelconfig.txt", "DATA") then file.Write("server_duelconfig.txt", "enabled\n/duel\n100")end
    local f = file.Open( "server_duelconfig.txt", "r", "DATA" )
duel_status = f:ReadLine()
duel_command = f:ReadLine()
duel_reward = f:ReadLine()
f:Close()
end