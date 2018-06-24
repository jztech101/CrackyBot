local generalcmds = {}
--LIST
--HELP
local function help(usr,chan,msg)
	msg = msg or "help"
	msg = msg:lower()
	if commands[msg] then
		if commands[msg].helptext then
			return msg ..": ".. commands[msg].helptext
		end
	end
	return "No help for "..msg.." found!"
end
add_cmd(help,"help",0,"Returns hopefully helpful information, '/help <cmd>'",true)

--UNHELP, no idea
local function unhelp(usr,chan,msg)
	msg = msg or "unhelp"
	msg = msg:lower()
	if commands[msg] then
		if commands[msg].helptext then
			return msg ..": ".. string.reverse(commands[msg].helptext)
		end
	end
	if msg==string.reverse(usr.nick) then
		ircSendChatQ(usr.nick,"1 point gained")
	end
	return "No help for "..msg.." found!"
end
add_cmd(unhelp,"unhelp",0,"'>dmc< plehnu/' ,noitamrofni lufplehnu yllufepoh snruteR",true)

--TIMER
local function timer(usr,chan,msg,args)
	if #timers > 10 then
		return "Error: too many timers already"
	end
	local num = tonumber(args[1])
	local perms = getPerms(usr.host, chan)
	if num and num==num and (num<108000 or perms >= 101) and args[2] then
		local t={}
		for i=2,#args do
			table.insert(t,args[i])
		end
		local pstring, seconds = table.concat(t," "), tonumber(args[1])
		addTimer(ircSendChatQ[chan][pstring],seconds,chan,usr.nick)
		return "Timer will go off in "..seconds.." second"..(seconds ~= 1 and "s" or "")
	else
		return "Bad timer"
	end
end
add_cmd(timer,"timer",0,"Time until a print is done, '/timer <time(seconds)> <text>'",true)

--SEEN, display last message by a user
local function seen(usr,chan,msg,args)
	if not args[1] then return commands["seen"].helptext end
	local nick = args[1]
	if isChan(args[1], false) then
		if not args[2] then return commands["seen"].helptext end
		chan, nick = args[1], args[2]
	end
	if not irc.channels[chan] then
		return "not a channel: "..chan
	elseif not irc.channels[chan].users[nick] or not irc.channels[chan].users[nick].lastSaid then
		return "I have not seen "..nick
	end

	local sssss = function(moo) return moo == 1 and "" or "s" end
	local difference = os.difftime(os.time(), irc.channels[chan].users[nick].lastSaid.time) or 0
	local time = os.date("!*t", difference)
	local msg = time.sec.." second"..sssss(time.sec).." ago"
	if time.min ~= 0 or difference > 86400 then msg = time.min.." minute"..sssss(time.min).." and "..msg end
	if time.hour ~= 0 or difference > 86400 then msg = time.hour.." hour"..sssss(time.hour)..", "..msg end
	time.day = time.day - 1
	if time.day ~= 0 then msg = (time.day%7).." day"..sssss(time.day%7)..", "..msg end
	if time.day >= 7 then msg = math.floor(time.day/7).." week"..sssss(time.day/7)..", "..msg end
	if time.year-1970 ~= 0 then msg = (time.year-1970).." year"..sssss(time.year-1970)..", "..msg end
	msg = nick.." was last seen in "..chan.." "..msg..": <"..nick.."> "..irc.channels[chan].users[nick].lastSaid.msg
	return msg
end
add_cmd(seen,"seen",0,"Display a last seen message '/seen [<chan>] <nick>'",true)
return generalcmds
