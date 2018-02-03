module("ping",package.seeall)

local function ping(usr,chan,msg)
    return "pong"
end
add_cmd(ping,"ping",0,"pong",true)

local function pong(usr,chan,msg)
    return "ping"
end
add_cmd(pong,"pong",0,"ping",true)

local function version(usr,chan,msg)
	return "Crackybot"
end
add_cmd(version,"version",0,"version",true)

local function source(usr, chan, msg)
	return "https://github.com/jztech101/CrackyBot"
end
add_cmd(source, "source", 0, "prints source of bot", true)
