local randcmds = {}
local function shrug(usr, chan, msg)
    return "┻━┻ ︵ ¯\\_(ツ)_/¯ ︵ ┻━┻"
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
    ircSendChatQ(chan, "\001ACTION gives " + nick +" a cookie\001", true) 
end
add_cmd(cookie,"cookie",0,false,false)
local function compat(usr, chan, msg, args)
    math.randomseed(os.time()) 
    math.random(); math.random(); math.random()
    nick1 = usr.nick
    nick2 = usr.nick
    if args[1] then nick1 = args[1] end
    if args[2] then nick2 = args[2] end
    return nick1.." and "..nick2.." are "..math.random(1,100).."% compatible"
end
add_cmd(compat, "compat", 0, false, false)

local function chance(usr, chan, msg)
    math.randomseed(os.time())
    math.random(); math.random(); math.random()
    chance = "There is a "..math.random(1, 100).."% chance"
    if not (msg == "" or msg == nil) then return  chance.." that "..msg else return chance end
end
add_cmd(chance, "chance", 0, false, false)

local function love(usr, chan, msg, args)
    nick1 = usr.nick
    nick2 = usr.nick
    if args[1] then nick1 = args[1] end
    if args[2] then nick2 = args[2] end
    return nick1.." and "..nick2.." sitting in a tree K-I-S-S-I-N-G, first comes love, then comes marriage, then comes the baby in the baby carriage"
end
add_cmd(love, "love",0, false, false)
local function eat(usr,chan,msg)
    nick = usr.nick
    if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION eats " + nick +" for breakfast\001", true) 
    return "mmhmm delicious"
end
add_cmd(eat,"eat",0,false,false)

local function poke(usr,chan,msg) 
    nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
    ircSendChatQ(chan, "\001ACTION pokes " + nick +"\001", true) end
add_cmd(poke,"poke",0,false,false)

local function sneaky(usr,chan,msg)
	return "You found me!"
end
add_cmd(sneaky,".",0,nil,false)

local function sneaky2(usr,chan,msg)
	ircSendChatQ(usr.nick,"1 point gained")
	return nil
end
add_cmd(sneaky2,".moo",0,nil,false)

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

local function slap(usr, chan, msg)
        nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
        ircSendChatQ(chan, "\001ACTION slaps " + nick + " with her bare hands\001", true) end
add_cmd(slap, "slap",0, false, false)

local function github(usr, chan, msg)
        nick = usr.nick if not (msg == "" or msg == nil) then nick = msg end
        return nick..": OH! Microsoft bought Github. I should totally switch to... wait. WHY? Because otherwise I support FOSS terrorism? OH FUCK OFF. Oh because Microsoft spies on you? Shit, if I gave a shit about that I wouldn\'t be on the internet. OOOH PATENT EXTORTION! I mean not like, that\'s a basic part of the corporate world or anything...., like is patent wars/DMCA and other shit new to you?" 
end
add_cmd(github, "github", 0, false, false)
return randcmds
