--Metatable changes to be awesome

--credits to ATMunn & Bowserinator on the attacks (https://github.com/ATMunn & https://github.com/Bowserinator)
attacks={"drops a cool black planet on $",
"eats $ for breakfast.",
"tackles $ and annihilates $ completely, ending $'s thoughts of revenge. ",
"smashes $'s face through 4 layers of glass.",
"whacks $ into space.",
"breathes out a stream of white hot fire, melting $'s face instantly.",
"takes out a sharpness V sword and slices $ in half.",
"detonates an antimatter missile onto $.",
"fires the B.E. Space Laser, shooting a beam of death towards $.",
"takes the brush and drops some SING near where $ was standing.",
"borrows a banhammer and smashes it on $'s skull.",
"beats $ in a game of chess, causing $ to die of shame.",
"forces $ to listen to Justin Bieber, causing their eardrums to explode.",
"shoves $ into a vat of sodium hydroxide.",
"types /kill @p[Name=$]",
"types !set type $ none in the console.",
"straps $ onto a rocket heading towards the sun.",
"pours a bucket of lava on $'s head",
"drops a wrecking ball on $",
"sends $ to the gulags",
"forces $ to write Javscript code",
"sends $ to Uranus and leaves them there",
"puts $ in an American public school",
"crosses the hammer and sickle while facing $",
"bandwagons $",
"gives $ a totem of death",
"causes the earth to open up under $",
"tosses $ off the Burj Khalifa",
"tosses $ into a volcano for SCIENCE",
"makes North Korea declare war on $",
"exiles $ to St. Helena",
"sends $ back 1000 years"
}


local function _index(f,a) return function(...) return f(a,...) end end
local function _sub() return function(a,b)
	if type(a)=='function' and type(b)=='table' then
		return function(...) local t={} for k,v in pairs(b) do table.insert(t,arg[v]) end return a(unpack(t)) end
	end end end
local function _mod() return function(a,b)
	if type(a)=='function' and type(b)=='function' then
		return function(...) return b(a(...)) end
	end end end
local function _concat() return function(a,b)
	if type(a)=='function' and type(b)=='function' then
		return function(...) local ret={a(...)} b(unpack(ret)) return unpack(ret) end
	end end end
function fempty()end
function fproxy(...)return ... end
function fop(op)
	if op=="+" then
		return function(a,b)return a+b end
	elseif op=="-" then
		return function(a,b)return a-b end
	elseif op=="*" then
		return function(a,b)return a*b end
	elseif op=="/" then
		return function(a,b)return a/b end
	elseif op=="%" then
		return function(a,b)return a%b end
	elseif op=="^" then
		return function(a,b)return a^b end
	elseif op==">" then
		return function(a,b)return a>b end
	elseif op=="<" then
		return function(a,b)return a<b end
	elseif op=="=" then
		return function(a,b)return a==b end
	elseif op=="|" then
		return function(a,b)return a or b end
	elseif op=="&" then
		return function(a,b)return a and b end
	elseif op=="!" then
		return function(a)return not a end
	elseif op=="_" then
		return function(a)return -a end
	elseif op==":" then
		return function(a,b)return a[b][a] end
	elseif op=="." then
		return function(a,b)return a[b] end
	end
end
debug.setmetatable(fempty,{__index=_index,__sub=_sub(),__mod=_mod(),__concat=_concat()})
local smeta = debug.getmetatable("")
smeta["__mul"] = function(s,v) if type(v)=="number" then s=s:rep(v) end return s end
smeta["__add"] = function(s,v) s = s..v return s end
smeta["__metatable"] = {}
local _rand,first = math.random,true
math.random = function(...)
	if first then math.randomseed(os.time()) first=false for i=0,20 do _rand() end end
	return _rand(...)
end
function getArgs(msg)
	if not msg then return {} end
	local args = {}
	local index=1
	while index<=#msg do
		local s2,e2,word2 = msg:find("\"([^\"]-)\"",index)
		local s,e,word = msg:find("([^%s]+)",index)
		if s2 and s2<=s then
			word=word2
			e=e2
		end
		table.insert(args,word)
		index = e+1 or #msg+1
	end
	return args
end

function isChan(chan, checkprefix)
if string.sub(chan, 1, 1) == "#" then return true
elseif checkprefix and (string.sub(chan,1 ,1):match("%W") and string.sub(chan,2,2) == "#") then return true
else return false
end
end
