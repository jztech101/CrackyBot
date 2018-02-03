module("randcmds",package.seeall)

local function shrug(usr, chan, msg)
    return "┻━┻ ︵ ¯\_(ツ)_/¯ ︵ ┻━┻"
end
add_cmd(shrug, "shrug", 0, "shrug", true)

local function sneaky3(usr,chan,msg)
    return "MooOoOoooOooo"
end
add_cmd(sneaky3, "moo",0,nil, false)

local function potato(usr, chan, msg)
    ircSendChatQ(chan, "\001ACTION is a potato", false)
end
add_cmd(potato, "potato", 0, nil, false)

local function cookie(usr,chan,msg) 
    nick = usr.nick
    if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION gives " + nick +" a cookie\001", false) end
add_cmd(cookie,"cookie",0,false,false)

local function poke(usr,chan,msg) 
    nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION pokes " + nick +"\001", false) end
add_cmd(poke,"poke",0,false,false)

local function sneaky(usr,chan,msg)
	return "You found me!"
end
add_cmd(sneaky,"./",0,nil,false)

local function sneaky2(usr,chan,msg)
	ircSendChatQ(usr.nick,"1 point gained")
	return nil
end
add_cmd(sneaky2,"./moo",0,nil,false)
