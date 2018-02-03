module("funcmds",package.seeall)

local function annoy(usr,chan,msg)
	if funcmds[chan] then
        nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
        nick = nick.." "*20
        ircSendChatQ(chan, "\001ACTION pokes " + nick +"\001", false) end
     end
end
add_cmd(annoy,"annoy",0,false, false)
