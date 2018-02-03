--List of files to load
dofile("tableSave.lua")
math.randomseed(os.time())
commands = {}
allCommands = {}
local stepcount=0
local cmdcount = 0
local function infhook()
	stepcount = stepcount+1
	if stepcount>100000 then
		stepcount=0
		debug.sethook()
		error("Break INF LOOP")
	else
		return
	end
end
function add_cmd(f, name, lvl, help, shown, aliases)
	if type(f)~="function" then return end
	lvl = commandPermissions[name] or lvl
	allCommands[name]={["name"]=name,["f"]=f,["level"]=lvl,["helptext"]=help,["show"]=shown}
	commands[name]=allCommands[name]
	if aliases then
		for k,v in pairs(aliases) do
			allCommands[v] = {["name"]=name,["f"]=f,["level"]=lvl,["helptext"]=help,false}
			commands[v]=allCommands[v]
		end
	end
end

--Helper to return user object from a name
function getUserFromNick(nick)
	if not nick then return end
	nick = nick:lower()
	for k,v in pairs(irc.channels) do
		if v and v.users then
			for k2,v2 in pairs(v.users) do
				if v2 and v2.nick:lower() == nick then
					return v2
				end
			end
		end
	end
end

--Load all plugins in plugins/ here
local listcmd = WINDOWS and "dir /b" or "ls"
local pluginList = io.popen(listcmd.." \"plugins\"")
for file in pluginList:lines() do
	if file:sub(#file-3,#file) == ".lua" then
		local s,e = pcall(dofile, "plugins/"..file)
		if not s then
			if config.logchannel then
				ircSendChatQ(config.logchannel, e)
			end
			print("Error loading plugins/"..file..": "..e)
		else
			print("Loaded plugins/"..file)
		end
	end
end

local function changeLevel(usr,chan,msg,args,isignore)
	local channel, noescape = nil, false
	if #args > 1 and args[1]:sub(1,1) == "#" then
		channel = args[1]
		table.remove(args, 1)
	end
	if args[1] == "-noescape" then
		noescape = true
		table.remove(args, 1)
	end
	if not args[1] or (not isignore and not args[2]) then
		if isignore then
			return "Usage: '/ignore [<channel>] [-noescape] <user/host> [<seconds>]'"
		else
			return "Usage: '/chmod [<channel>] [-noescape] <user/host> <level>'"
		end
	end
	local user, seconds, host = args[1], tonumber(args[2]), nil
	if irc.channels[chan].users[user] then
		host = irc.channels[chan].users[user].host
	else
		local found = false
		for k,v in pairs(irc.channels) do
			if irc.channels[k].users[user] then
				host = irc.channels[k].users[user].host
				found = true
				break
			end
		end
		if not found then
			host = user
		end
	end
	if not noescape then
		host = host:gsub("([%.%-%+%*%%%?%(%)%[%]%^%$])","%%%1")
	end
	local perm, chanPerm, otherPerm = getPerms(usr.host), getPerms(usr.host, channel), getPerms(host, channel)
	if otherPerm >= perm and not channel then
		if isignore then
			return "You cannot ignore "..args[1]
		else
			return "You cannot modify the permissions for "..args[1]
		end
	elseif otherPerm >= chanPerm and channel then
		if isignore then
			return "You cannot ignore "..args[1].." in "..channel
		else
			return "You cannot modify the permissions for "..args[1].." in "..channel
		end
	elseif perm < getCommandPerms(isignore and "ignore" or "chmod") and not channel then
		if isignore then
			return "You cannot ignore people globally"
		else
			return "You cannot set permission levels globally"
		end
	elseif chanPerm < getCommandPerms(isignore and "ignore" or "chmod", channel) then
		if isignore then
			return "You cannot ignore people in "..channel
		else
			return "You cannot set permission levels in "..channel
		end
	elseif isignore then
		if otherPerm == -1 then
			return args[1].." is already ignored"
		end
	else
		if channel and seconds > chanPerm then
			return "You can't set permissions that high in "..channel
		elseif (not channel and seconds > perm) or seconds > 99 then
			return "You can't set permissions that high"
		end
	end
	if channel then
		if not channelPermissions[channel] then
			channelPermissions[channel] = {}
		end
		if isignore and seconds then
			local oldlevel = channelPermissions[channel][host]
			addTimer(function() channelPermissions[channel][host] = oldlevel end, seconds, chan, usr.nick)
		end
		channelPermissions[channel][host] = isignore and -1 or seconds
		if isignore then
			return "ignored "..host.." in "..channel..(seconds and " for "..seconds.." second"..(seconds==1 and "" or "s") or "")
		else
			return "permissions for "..host.." in "..channel.." changed to "..seconds
		end
	else
		if isignore and seconds then
			local oldlevel = permissions[host]
			addTimer(function() permissions[host] = oldlevel end, seconds, chan, usr.nick)
		end
		permissions[host] = isignore and -1 or seconds
		if isignore then
			return "ignored "..host..(seconds and " for "..seconds.." second"..(seconds==1 and "" or "s") or "")
		else
			return "permissions for "..host.." changed to "..seconds
		end
	end
end
