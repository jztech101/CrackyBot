permissions = {}
--insert host into permissions here
--example: permissions["Powder/Developer/cracker64"] = 101
--Owner should be 101, trusted global ops can be 100
--Set to -2 to ignore host
--Remember to escape .'s and other lua pattern special characters with %


--enable fun commands for a channel here
funcmds = {}
--example: funcmds["#apple"] = true (Must be set to true, default is false)

--insert per channel permissions here (channel specific ops)
channelPermissions = {
	--[[["##mychannel"] = {
		["Powder/Developer/jacob1"] = 50,
	},
	--Give everyone a permission level of -1 by default
	["##quietchannel"] = {
		["@default"] = -1,
	},]]
}

--to override the default permission level of a command, insert it here
commandPermissions = {
	--["mycommand"] = 10,
}
--to override the default permission level of a command only in one channel, insert it here
channelCommandPermissions = {
	--[[["##mychannel"] = {
		["mycommand"] = 0,
	},]]
}

-- Do not edit these functions. Go to the end of the file to configure the network settings

channelPrefixes = {
  --       ["#mychannel"] = '&',
}
function getPrefix(chan)
        if chan and channelPrefixes[chan] then return channelPrefixes[chan] end
end


--Get perm value for part of a hostmask (usually just host)
function getPerms(host,chan)
	local perms, chanPerms = -1/0, nil
	for k,v in pairs(permissions) do
		if host:match("^"..k.."$") then
			if v < 0 then
				perms = -1
				break
			elseif v > perms then
				perms = v
			end
		end
	end
	if chan and channelPermissions[chan] then
		for k,v in pairs(channelPermissions[chan]) do
			if host:match("^"..k.."$") then
				if v < 0 then
					return -1
				elseif v > (chanPerms or -1/0) then
					chanPerms = math.min(v, 99)
				end
			end
		end
	end
	if perms < -2 then perms=0 end
	if chanPerms and chanPerms < -2 then chanPerms=0 end
	if not chanPerms and channelPermissions[chan] and channelPermissions[chan]["@default"] then
		if perms == 0 then return channelPermissions[chan]["@default"] end
		return math.max(channelPermissions[chan]["@default"], perms)
	end
	return chanPerms or perms
end

function getCommandPerms(cmd,chan)
	if not commands[cmd] then return 101 end --if this command doesn't exist, default to 101
	local defaultlvl = commands[cmd].level
	if defaultlvl >= 100 then return defaultlvl end
	if chan and channelCommandPermissions[chan] then
		return channelCommandPermissions[chan][cmd] or defaultlvl
	end
	return defaultlvl
end

--This has server specific data
local config = {
	--Network to connect to, change to whatever network you use
	network = {
		server = "irc.freenode.net",
		port = 6697,
		--password = "",
		ssl = true,
		timeout = 30,
	},
	--User info, set these to whatever you need
	user = {
		nick = "FakeCrackybot",
		username = "Meow",
		realname = "moo",
		
		--account = "Crackybot",
		--password = "password"
	},
	--Owner info, only used now for terminal input
	owner = {
		nick = "jacob1",
		host = "Powder/Developer/jacob1",
		fullhost = "jacob1!~jacob1@Powder/Developer/jacob1"
	},
	--Channels to join on start
	autojoin = {
		--"##mychannel",
	},
	
	--logs all commands done in pm, and added aliases
	logchannel = "##logchannel",

	prefix = "%./",
	suffix = "moo+",

	--turns on terminal input, can be used on linux to input commands directly from a second terminal
	--terminal = "gnome-terminal -x",
	--terminalinput = true
}

return config
