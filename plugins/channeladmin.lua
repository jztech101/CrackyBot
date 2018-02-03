module("channeladmin",package.seeall)

local function chmod(usr,chan,msg,args)
	return changeLevel(usr, chan, msg, args, false)
end
add_cmd(chmod,"chmod",40,"Sets permission levels on a user, '/chmod [<channel>] [-noescape] <user/host> <level>'",true)
local function ignore(usr,chan,msg,args)
	return changeLevel(usr, chan, msg, args, true)
end
add_cmd(ignore,"ignore",40,"Sets a global or channel ignore on a user, '/ignore [<channel>] [-noescape] <user/host> [<seconds>]'",true)