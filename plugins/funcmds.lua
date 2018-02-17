module("funcmds",package.seeall)
local function funcmd(usr, chan)
if funcmds[chan] or getPerms(usr.host) == 101 then return true else return false end
end

local function annoy(usr,chan,msg)
	if funcmd(usr, chan) then
        nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end        
        nick = (nick.." ")*(math.floor(300 / (string.len(nick)) + 1))
        ircSendChatQ(chan, "\001ACTION pokes "..nick.."\001", true)
        ircSendChatQ(chan, "\001ACTION pokes "..nick.."\001", true)
        ircSendChatQ(chan, "\001ACTION pokes "..nick.."\001", true) end 
end
add_cmd(annoy,"annoy",0,false, false)

local function repeats(usr, chan, msg, args)
if funcmd(usr, chan) and args[2] then 
args[1] = tonumber(args[1])
if type(args[1]) ~= "number" then return "Invalid Number" 
elseif args[1] > 50 then return "too large"
else for i=1, args[1] do ircSendChatQ(chan, table.concat(args, " ", 2), false) end
end
end
end
add_cmd(repeats, "repeat", 0, false, false)  
