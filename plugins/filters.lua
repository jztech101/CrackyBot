local filters = {}
function filters.nicenum(text)
	return text:gsub("([-]?)(%d+)([.]?%d*)",function(minus, int, fraction) return minus..int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")..fraction end)
end
local function num(usr, chan, msg) return filters.nicenum(msg) end
add_cmd(num,"nicenum",0,"Inserts commas into numbers, '/nicenum <text>'", true)

local magn=setmetatable({"thousand","million","billion","trillion","quadrillion","quintillion","sextillion","septillion"},{__index=function(_,i)return i.."-bajillion"end})
local one={"one","two","three","four","five","six","seven","eight","nine"}
local ten={nil,"twenty","thirty","fourty","fifty","sixty","seventy","eighty","ninety"}
local eleven={"eleven","twelve","thirteen","fourteen","fifteen","sixteen","seventeen","eighteen","nineteen"}
local function mksmall(n)
    local s=""
    if n>=100 then
        s=one[math.floor(n/100)].." hundred "
        n=n%100
        if n~=0 then
            s=s.."and "
        end
    end
    if n>=20 then
        s=s..ten[math.floor(n/10)].." "
        n=n%10
        if n~=0 then
            s=s..one[n].." "
        end
        return s
    elseif n>10 then
        return s..eleven[n-10].." "
    elseif n==10 then
        return s.."ten "
    elseif n>0 then
        return s..one[n].." "
    else
        return s
    end
end
function filters.mknum(n)
    n=tonumber(n)
    if n~=n then return "Not A Number" end
    local p=""
    if n<0 then
        p="minus "
        n=-n
    end
    if n==0 then return p.."zero" end
    if n==1/0 then return p.."infinity" end
    if n>2^52 then io.stderr:write"Warning: mantissa overflow, result might be unprecise\n" end
    local t={}
    for i=0,math.floor(math.log(n)/math.log(1000)) do
        local g=math.floor(n/1000^i)%1000
        if g>999 or g<0 then break end
        if g~=0 then
            if i==0 then
                table.insert(t,1,mksmall(g):sub(1,-2))
            else
                table.insert(t,1,mksmall(g)..magn[i])
            end
        end
    end
    return p..table.concat(t," and ")
end
local function numify(usr, chan, msg) return filters.mknum(msg) end
add_cmd(numify,"numify",0,"Turns digits into their text, '/mknum <text>'",true)
function filters.scramble(text,args)
	local rstring
	local words={}
	if args.skip then args = getArgs(text) end
	for k,word in pairs(args) do
		if #word>2 then
			local t = {}
			for char in word:gmatch("[\3%d%d?[,%d%d?]*]-.") do
				table.insert(t,char)
			end
			local n = #t-1
			while n >= 2 do
				local k = math.random(#t-2)
				t[n], t[k+1] = t[k+1], t[n]
				n = n - 1
			end
			word = table.concat(t,"")
		end
		table.insert(words,word)
		rstring = table.concat(words," ")
	end
	return rstring
end
function filters.mknumscramb(n)
	local rnd=math.random(1,100)
	if rnd<15 then return tostring(n) end
	return filters.scramble(filters.mknum(n),{skip=true})
end
local function scramble2(usr, chan, msg) return filters.scramble(msg, {skip=true}) end
add_cmd(scramble2,"scramble",0,"scramble, 'scramble'",true)


local allColors = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15',white='00', black='01', blue='02', green='03', red='04', brown='05', purple='06', orange='07', yellow='08', lightgreen='09', turquoise='10', lightblue='11', skyblue='12', lightpurple='13', gray='14', lightgray='15'}
allColors[0]='00'
local rainbowOrder = {'04','07','08','03','10','02','06'}
local cchar = '\003'
--returns a table with data about where color codes are, might not be correct at all, old
local function tableColor(text)
	local t = {}
	if not text then return {} end
	local i = 0 --amount of color chars deleted
	local d = 0 --amount deleted
	local startOf = true
	while true do
		local st3,en3,cap3 = text:find("(\022?\003%d%d?,%d%d?)",1)
		local st2,en2,cap2 = text:find("(\022?\003%d%d?)",1)
		local st,en,cap = text:find("([\003\015\022])",1)
		local short=false
		if not en then break end --smallest check

		if st3 and st3==st then
			en=en3 cap=cap3 --first x03 is longest
		elseif st2 and st2==st then
			en=en2 cap=cap2 --first x03 is medium
		else --else first x03 is x03
			short=true
		end
		local ending,_ = text:find("([\003\015])",en+1)
		text = text:sub(en+1)
		local skip=false
		if startOf then
			if st==1 and short then
				skip=true
			end
			startOf=false
		end
		if not skip then
			ending = ending or 99999
			if en+1<ending or cap=="\022" then
				table.insert(t,{["start"]=st+d-i,["en"]=st+ending-en+d-i-2,["col"]=cap})
			end
		end
		i = i + #cap
		d = d + en
	end
	return t
end
--COLORSTRIP strips colors
function filters.colorstrip(text, ignore)
	local newstring = text:gsub("\003%d%d?,%d%d?","") --remove colors with backgrounds
	newstring = newstring:gsub("\003%d%d?","") --remove normal
	if not ignore then newstring = newstring:gsub("[\003\015\022]","") end --remove extra \003
	return newstring
end
local function colorstrip(usr, chan, msg) return filters.colorstrip(msg, true) end
add_cmd(colorstrip,"colorstrip",0,"colorstrip, 'colorstrip'",true)
--RAINBOW every letter is new color
local lastStart = 1
function filters.rainbow(text)
	local newtext= ""
	local rCount = lastStart
	lastStart = ((lastStart)%(#rainbowOrder))+1
	newtext = (filters.colorstrip(text,1,1,true)):gsub("([^%s%c])",function(c)
		c = cchar .. rainbowOrder[rCount] .. c
		rCount = ((rCount)%(#rainbowOrder))+1
		return c
	end)
	newtext = newtext .. cchar --end with color clear
	return newtext
end
local function rainbow(usr, chan, msg) return filters.rainbow(msg) end
add_cmd(rainbow,"rainbow",0,"rainbow, 'rainbow'",true)

function filters.reverse(text)
	local text=text:gsub("\3(%d?%d?)(,?)(%d?%d?)",function(a,b,c)
				     if #a==0 then return "\3\0\0,\0\0"..b..c end
				     if #c==0 or #b==0 then return "\3"..a..",\0\0"..b..c end
				     return "\3"..a..b..c end)
	local t={}
	for s,a,b,p in text:gmatch"()\3([%d%z][%d%z]?),([%d%z]?[%d%z]?)()" do
		a,b=tonumber(a) or -1,tonumber(b)or -1
		table.insert(t,{s,p,a,b})
	end
	for s,p in text:gmatch"()\15()" do
		table.insert(t,{s,p,-1,-1})
	end
	table.sort(t,function(a,b)return a[1]<b[1]end)
	table.insert(t,1,{0,1,-1,-1})
	table.insert(t,{#text+1,#text+2})
	local c={}
	local lastbg=-1
	for i=1,#t-1 do
		local a,b=t[i][3],t[i][4]
		if a==-1 then lastbg=-1 end
		if b~=-1 then lastbg=b end
		table.insert(c,{text:sub(t[i][2],t[i+1][1]-1),a,lastbg})
	end
	local s=""
	for i=#c,1,-1 do
		if c[i][2]==-1 then
			s=s.."\15"..c[i][1]:reverse()
		elseif c[i][3]==-1 then
			s=s.."\3"..("%02d"):format(c[i][2])..c[i][1]:reverse()
		else
			s=s.."\3"..("%02d,%02d"):format(c[i][2],c[i][3])..c[i][1]:reverse()
		end
	end
	return s
end
local function reverse(usr, chan, msg) return filters.reverse(msg) end
add_cmd(reverse,"reverse",0,"reverse, 'reverse'",true)

--HEX and UNHEX
function filters.hexStr(str,spacer)
	return (string.gsub(str,"(.)",
			    function (c)
				    return string.format("%02X%s",string.byte(c), spacer or "")
			    end)
	       )
end
local function hexStr(usr, chan, msg) return filters.hexStr(msg) end
add_cmd(hexStr,"hex",0,"hex, 'hex'",true)

function filters.unHexStr(str)
	return string.gsub(str, '(%x%x)', function(value) return string.char(tonumber(value, 16)) end)
end
local function unhexstr(usr, chan, msg) return filters.unHexStr(msg) end
add_cmd(unhexstr,"unhex",0,"unhex, 'unhex'",true)

--CAPS
function filters.toCaps(text)
	return string.upper(text)
end
local function toCaps(usr, chan, msg) return filters.toCaps(msg) end
add_cmd(toCaps,"cap",0,"caps, 'caps'",true)

function filters.toLower(text)
	return string.lower(text)
end
local function toLower(usr, chan, msg) return filters.toLower(msg) end
add_cmd(toLower,"lower",0,"lower, 'lower'",true)

return filters
