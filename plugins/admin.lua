local admin = {}
local function userstatus(usr,chan,msg,args)
	if chan:sub(1,1)~="#" then return "Be in chan idiot" end
	if irc.channels[chan].users[msg] then
		local info = msg.." on "..chan
		if irc.channels[chan].users[msg].access then
			info = info.." has "..irc.channels[chan].users[msg].access
		end
		ircSendChatQ(chan,info)
	end
end
add_cmd(userstatus,"userinfo",101,"Test info about someone",false)

--DISABLE a command for the bot
local function disable(usr,chan,msg,args)
	if not msg then return "Usage: '/disable <cmd> [<cmd2> ...]'" end
	if args[1]=="all" then
		for k,v in pairs(commands) do
			if k~="enable" then commands[k]=nil end
		end
		return "Disabled all"
	else
		local t={}
		for i=1,#args do
			local dcmd = args[i]:lower()
			if dcmd~="enable" and commands[dcmd] then
				commands[dcmd]=nil
				table.insert(t,dcmd)
			end
		end
		return "Disabled: "..table.concat(t," ")
	end
end
add_cmd(disable,"disable",100,"Disable a command for the bot, '/disable <cmd> [<cmd2> ...]'",true)

--ENABLE a command previously disabled
local function enable(usr,chan,msg,args)
	if not msg then return "Usage: '/enable <cmd> [<cmd2> ...]'" end
	if args[1]=="all" then
		for k,v in pairs(allCommands) do
			if not commands[k] then commands[k]=v end
		end
		return "Enabled all"
	else
		local t={}
		for i=1,#args do
			local ecmd = args[i]:lower()
			if not commands[ecmd] and allCommands[ecmd] then
				commands[ecmd]=allCommands[ecmd]
				table.insert(t,ecmd)
			end
		end
		return "Enabled: "..table.concat(t," ")
	end
end
add_cmd(enable,"enable",100,"Enables a command previously disabled, '/enable <cmd> [<cmd2> ...]'",true)

--QUIT
local function suicide(usr,chan,msg)
	ircSendRawQ("QUIT :moo")
	shutdown = true;
end
add_cmd(suicide,"suicide",101,"Quits the bot",true,{"quit","die"})

--PING
local function raw(usr, chan, msg)
        ircSendRawQ(msg)
end
add_cmd(raw, "raw", 101, "raw", false)
local function act(usr,chan,msg)
	if msg then
		msg2 = msg
		if isChan(msg, false) then
			msg2 = nil
			for word in string.gmatch(msg,"%S+") do
				if isChan(word, false) then
					chan = word
				else
					if msg2 == nil then msg2 = word else msg2 = msg2.." ".. word end

				end
			end
		end

		ircSendChatQ(chan, "\001ACTION "..msg2.."\001", true) end

end
add_cmd(act, "act", 101, false, false)
local function say(usr,chan,msg)
        if msg then
                msg2 = msg
                if isChan(msg, true) then
                        msg2 = nil
			for word in string.gmatch(msg, "%S+") do
                                if isChan(word,true) then
                                        chan = word
                                else
                                        if msg2 == nil then msg2 = word else msg2 = msg2.." ".. word end
                                end
                        end
                end
	ircSendChatQ(chan,msg2, true) end
end
add_cmd(say, "say", 101, false, false)


--RELOAD files
local function reload(usr,chan,msg,args)
	if not args[1] then args[1]="hooks" args[2]="commands"
	else
		if getPerms(usr.host)<101 then return "You can't use args" end
	end
	local rmsg=""
	for k,v in pairs(args) do
		local s,r = pcall(dofile,v..".lua")
		if s then
			rmsg = rmsg .. "Loaded: "..v.." "
		elseif r:find("No such file or directory") then
			s,r = pcall(dofile,"plugins/"..v..".lua")
			if s then
				rmsg = rmsg .. "Loaded: "..v.." "
			else
				rmsg = rmsg .. r .. " "
			end
		else
			rmsg = rmsg .. r .. " "
		end
	end
	return rmsg
end
add_cmd(reload,"load",100,"Loads file(s), '/load [<file1>] [<files...>]', Only admin can specify file names.",true,{"reload"})

--LUA full access
local function lua2(usr,chan,msg,args)
	local e,err = loadstring(msg, "..")
	if e then
		debug.sethook(infhook,"l")
		local s,r = pcall(e)
		debug.sethook()
		stepcount=0
		if s then
			local str = tostring(r)
			return str:gsub("[\r\n]"," ")
		else
			return "ERROR: " .. r
		end
		return
	end
	return "ERROR: " .. err
end
add_cmd(lua2,"..",101,"Runs full lua code, '/lua <code>'",false)
return admin