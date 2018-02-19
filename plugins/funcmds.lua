local funcmds = {}
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


local function cow_text(text,length)
	if (#text < length) then return {text} end
	local t,start,en = {},1,length
	local s = text:sub(start,en)
	while (#s>0) do
		if (#s<length) then s = s..string.rep(" ",length-#s) end
		table.insert(t,s)
		start = en+1
		en = en + length
		s = text:sub(start,en)
	end
	return t
end
local function get_border(lines,i)
	if lines < 2 then
		return '<','>'
	elseif i==0 then
		return '/','\\'
	elseif i==(lines-1) then
		return '\\','/'
	else
		return '|','|'
	end
end
local function get_cow()
    return [[
          \   ^__^
           \  (oo)\_______
              (__)\       )\/\\
                  ||----w |
                  ||     ||
     ]]
end
local function get_bubble(text)
	local bubble = {}
	local lines = cow_text(text,40)
	local bordersize = #lines[1]
	table.insert(bubble,"   "..string.rep("_",bordersize))
	for i,v in ipairs(lines) do
		local b1,b2 = get_border(#lines,i-1)
		table.insert(bubble,string.format(" %s %s %s",b1,v,b2))
	end

	table.insert(bubble,"   "..string.rep("-",bordersize))
	return table.concat(bubble,'\n')..'\n'
end

local function docowsay(text)
	return get_bubble(text)..get_cow()
end

local function cowsay(usr, chan, text)
        if funcmd(usr, chan) then
                if #text>1000 then return '' end
                local t = {}
                local s = docowsay(text)
                for line in s:gmatch('(.-)\n') do
                        table.insert(t,line)
                end
                return t
                end
        end
add_cmd(cowsay, "cowsay", 0, false, false)

local function cow(usr, chan, msg)
	if funcmd(usr,chan) then
		local t = {}
		local s = get_cow()
	for line in s:gmatch('(.-)\n') do
                        table.insert(t,line)
                end
		return t
	end
end
add_cmd(cow, "cow", 0, false, false)

return funcmds

