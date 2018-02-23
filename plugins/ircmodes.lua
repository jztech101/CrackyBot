local ircmodes = {}
--IRC MODE STUFF
function ircmodes.setMode(chan,mode,tar)
	if not tar then return end
	if isChan(chan, false) then
		ircSendRawQ("MODE "..chan.." "..mode.." "..tar)
	else
		local _,_,channel,target = tar:find("^(.-)%s(.+)[^%s-]?")
		if channel and target then
			ircSendRawQ("MODE "..channel.." "..mode.." "..target)
		end
	end
end

local function checkPermissions(host, cmd, chan, message)
	local chanPerms = getPerms(host, chan)
	if chanPerms < getCommandPerms(cmd, chan) then
		error("No permission to "..message.." in "..chan)
	end
end
--MODE
local function mode(usr,chan,msg,args)
	if not msg then return "Usage: '/mode [<chan>] <mode> [...]', if no chan given, will use current" end
	local tochan = ""
	local tomode = ""
	local rest = ""
	if args[1]:sub(1,1)=="#" then
		if not args[2] then return "Need a mode" end
		tochan=args[1]
		tomode=args[2]
		rest = table.concat(args, " ", 3)
	else
		tomode=args[1]
		if not isChan(chan, false) then return "Need to specify channel in query" end
		tochan=chan
		rest = table.concat(args, " ", 2)
	end
	checkPermissions(usr.host, "mode", tochan, "set modes")
	ircSendRawQ("MODE "..tochan.." "..tomode.." "..rest)
end
add_cmd(mode,"mode",40,"Set a mode, '/mode [<chan>] <mode> [...]', if no chan given, will use current",true)

--OP
local function op(usr,chan,msg,args)
	if not args[1] then args[2]=usr.nick end
	if args[1] then
		if not isChan(args[1], false) then
			args[2]=args[1]
		else
			if not args[2] then args[2]=usr.nick end
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "op", chan, "op")
	ircmodes.setMode(chan,"+o", args[2] or msg)
end
add_cmd(op,"op",30,"Op a user, '/op [<chan>] <username>'",true)
--DEOP
local function deop(usr,chan,msg,args)
	if not args[1] then msg=usr.nick end
	if args[1] then
		if not isChan(args[1], false) then
			msg=args[1]
		else
			if not args[2] then msg=usr.nick end
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "deop", chan, "deop")
	ircmodes.setMode(chan,"-o",args[2] or msg)
end
add_cmd(deop,"deop",30,"DeOp a user, '/deop [<chan>] <username>'",true)

--VOICE
local function voice(usr,chan,msg,args)
	if not args[1] then args[2]=usr.nick end
	if args[1] then
		if not isChan(args[1], false) then
			args[2]=args[1]
		else
			if not args[2] then args[2]=usr.nick end
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "voice", chan, "voice")
	ircmodes.setMode(chan,"+v", nick)
end
add_cmd(voice,"voice",15,"Voice a user, '/voice [<chan>] <username>'",true)

--DEVOICE
local function devoice(usr,chan,msg,args)
	if not args[1] then args[2]=usr.nick end
	if args[1] then
		if not isChan(args[1], false) then
			args[2]=args[1]
		else
			if not args[2] then args[2]=usr.nick end
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "devoice", chan, "devoice")
	ircmodes.setMode(chan,"-v",args[2] or msg)
end
add_cmd(devoice,"devoice",10,"DeVoice a user, '/devoice [<chan>] <username>'",true)

--UNQUIET
local function unquiet(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local nick
	local host
	if isChan(args[1], false) then
		chan=args[1]
		if not args[2] then error("Missing target") end
		nick = args[2]
	else
		nick = args[1]
		host = getUserFromNick(args[1])
	end
	host = getUserFromNick(nick)
    if host and host.host then host = "*!*@"..host.host else host = nick end
	checkPermissions(usr.host, "unquiet", chan, "unquiet")
	ircmodes.setMode(chan,"-q",host)
end
add_cmd(unquiet,"unquiet",15,"UnQuiet a user, '/unquiet [<chan>] <host/username>'",true,{"unstab"})

--QUIET
local function quiet(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local unbanTimer
	local nick
	if isChan(args[1], false) then
		chan=args[1]
		if not args[2] then error("Missing target") end
		nick = args[2]
		unbanTimer = tonumber(args[3])
	else
		nick = args[1]
		unbanTimer = tonumber(args[2])
	end
	local host = getUserFromNick(nick)
	if host and host.host then host = "*!*@"..host.host else host = nick end
	checkPermissions(usr.host, "quiet", chan, "quiet")
	ircmodes.setMode(chan,"+q",host)
	if unbanTimer then
		addTimer(ircmodes.setMode[chan]["-q"][host],unbanTimer,chan)
		ircSendNoticeQ(usr.nick, nick.." has been quieted for "..unbanTimer.." seconds")
	end
end
add_cmd(quiet,"quiet",20,"Quiet a user, '/quiet [<chan>] <host/username> [<time>]. If no time is specified, picks a random time between 60 and 600 seconds.'",true,{"stab"})

--UNBAN
local function unban(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local nick
	local host
	if isChan(args[1], false) then
		chan = args[1]
		if not args[2] then error("Missing target") end
		nick = args[2]
	else
		nick = args[1]
	end
	host = getUserFromNick(nick)
	if host and host.host then host = "*!*@"..host.host else host = nick end
	checkPermissions(usr.host, "unban", chan, "unban")
	ircmodes.setMode(chan,"-b",host)
end
add_cmd(unban,"unban",20,"Unban a user, '/unban [<chan>] <host/username>'",true)

--BAN
local function ban(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local nick
	local host
	local unbanTimer
	if isChan(args[1], false) then
		chan=args[1]
		if not args[2] then error("Missing target") end
		nick = args[2]
		unbanTimer = tonumber(args[3])
	else
		nick = args[1]
		unbanTimer = tonumber(args[2])
	end
	host = getUserFromNick(nick)
	if host and host.host then host = "*!*@"..host.host else host = nick end
	checkPermissions(usr.host, "ban", chan, "ban")
	ircmodes.setMode(chan,"+b",host)
	if unbanTimer then
		addTimer(ircmodes.setMode[chan]["-b"][host],unbanTimer,chan)
	end
end
add_cmd(ban,"ban",25,"Ban a user, '/ban [<chan>] <username> [<time>]'",true)

--KICK

local function kickx(usr, chan, nick, reason)
	if nick == irc.nick then
		nick = usr.nick
	end
	ircSendRawQ("KICK "..chan.." "..nick.." :["..usr.nick.."] "..reason)
end

local function kick(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local reason = ""
	if not isChan(args[1], false) then
		local t={} for i=2,#args do table.insert(t,args[i]) end
		reason=table.concat(t," ")
		args[2]=args[1]
	else
		if not args[2] then error("Missing target") end
		local t={} for i=3,#args do table.insert(t,args[i]) end
		reason=table.concat(t," ")
		chan=args[1]
	end
	local nick = args[2] or msg
	if reason == "" then reason = "Your behavior is not conductive to the desired environment" end
	checkPermissions(usr.host, "kick", chan, "kick")
	if string.match(nick, ",") then
		for nic in nick:gmatch("([^,]+)") do kickx(usr, chan, nic, reason)end
	else
		kickx(usr, chan, nick, reason)
	end
end
add_cmd(kick,"kick",10,"Kick a user, '/kick [<chan>] <username> [<reason>]'",true)

local function kickme(usr,chan,msg,args)
	ircSendRawQ("KICK "..chan.." "..usr.nick.." :"..table.concat(args," "))
end
add_cmd(kickme,"kickme",0,"Places a 'kick me' sign on your back'",false)


--KBAN
local function kickban(usr,chan,msg,args)
	if string.match(msg, ",") then return end
	ban(usr,chan,msg,args)
	local timercheck = 2
	if isChan(args[1], false) then timercheck = 3 end
	if tonumber(timercheck) then table.remove(args, timercheck) end
	kick(usr,chan,msg,args)
end
add_cmd(kickban,"kban",30,"Kick and ban user, '/kban [<chan>] <username> [<time>] [<reason>]'",true)

--TOPIC
local function topic(usr,chan,msg,args)
	if not args[1] then error("No args") end
	local topic = msg
	if isChan(args[1], false) then
		local t={} for i=2,#args do table.insert(t,args[i]) end
		topic=table.concat(t," ")
		chan = args[1]
	end
	checkPermissions(usr.host, "invite", chan, "invite")
	ircSendRawQ("TOPIC "..chan.." :"..topic)
end
add_cmd(topic,"topic",30,"topic",true)

--INVITE
local function invite(usr,chan,msg,args)
	if not args[1] then args[2]=usr.nick end
	if args[1] then
		if not isChan(args[1], false) then
			args[2]=args[1]
		else
			if not args[2] then args[2]=usr.nick end
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "invite", chan, "invite")
	ircSendRawQ("INVITE "..args[2].." :"..chan)
end
add_cmd(invite,"invite",50,"Invite someone to the channel, '/invite <user>'",true)

--JOIN a channel
local function join(usr,chan,msg,args)
	if not args[1] then error("No args") end
	if not isChan(args[1], false) then
		error("Not a channel")
	else
		chan=args[1]
	end
	checkPermissions(usr.host, "join", chan, "use join")
	ircSendRawQ("JOIN "..chan)
end
add_cmd(join,"join",101,"Make bot join a channel, '/join <chan>'",true)

--PART a channel
local function part(usr,chan,msg,args)
	if args[1] then
		if not isChan(args[1], false) then
			error("Not a channel")
		else
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "part", chan, "use part")
	_G.expectedPart=chan
	ircSendRawQ("PART "..chan)
end
add_cmd(part,"part",101,"Make bot part a channel, '/part <chan>'",true)

--CYCLE a channel
local function cycle(usr,chan,msg,args)
	if args[1] then
		if not isChan(args[1], false) then
			error("Not a channel")
		else
			chan=args[1]
		end
	end
	checkPermissions(usr.host, "cycle", chan, "use cycle")
	ircSendRawQ("PART "..chan)
	--ircSendRawQ("JOIN "..chan) --cycle doesn't work, so lets just let the autorejoin fix it
end
add_cmd(cycle,"cycle",101,"Make bot part and rejoin channel, '/cycle <chan>'",true)



return ircmodes