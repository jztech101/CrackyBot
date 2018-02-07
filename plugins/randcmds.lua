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
    ircSendChatQ(chan, "\001ACTION is a potato\001", true)
end
add_cmd(potato, "potato", 0, nil, false)

local function cookie(usr,chan,msg) 
    nick = usr.nick
    if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION gives " + nick +" a cookie\001", true) end
add_cmd(cookie,"cookie",0,false,false)

local function poke(usr,chan,msg) 
    nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION pokes " + nick +"\001", true) end
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

local function time(usr, chan, msg) 
        return "Time for you to get a watch!"
end
add_cmd(time, "time",0, false, false)

local function age(usr, chan, msg)
        return "The person in question's age is the square root of X divided by Y times Z. What are X, Y and Z? I dunno. I never cared enough to find out"  end
add_cmd(age, "age",0, false, false)

local function location(usr, chan, msg)
        return "The person in question's location is X miles away from you. What is X? I dunno. Some number I guess..?"  end
add_cmd(location, "location",0, false, false)
