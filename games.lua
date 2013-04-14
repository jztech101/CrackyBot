local function loadUsers()
	local f = io.open("cashList.txt","r")
	if not f then return end
	local t={}
	for line in f:lines() do
		local host,hcash,time = line:match("^(.-) (%d-) (%d-)$")
		t[host]= {cash=tonumber(hcash),lastDoor=tonumber(time)}
	end
	f:close()
	setmetatable(t,{__index=function(t,k) t[k]={cash=1000, lastDoor=os.time()} return t[k] end})
	return t
end
gameUsers = gameUsers or loadUsers()


--make function hook to reload user cash
local function loadUsersCMD()
	gameUsers = loadUsers()
end
local function saveUsers()
	local f = io.open("cashList.txt","w")
	for k,v in pairs(gameUsers) do
		f:write(k.." "..v.cash.." "..(v.lastDoor or os.time()).."\n")
	end
	f:close()
end
--make a timer loop save users every minute, errors go to me
local function timedSave()
	saveUsers()
	addTimer(timedSave,60,"cracker64","gameSave")
end
remTimer("gameSave")
addTimer(timedSave,60,"cracker64","gameSave")

--change cash, that resets if 0 or below
local function changeCash(usr,amt)
	gameUsers[usr.host].cash = gameUsers[usr.host].cash + amt
	if gameUsers[usr.host].cash <= 0 then
		gameUsers[usr.host].cash = 1000
		return " You went bankrupt, money reset"
	end
	return ""
end

--User cash
local function myCash(usr)
	return usr.nick .. ": You have $"..gameUsers[usr.host].cash
end
--50% chance to win double
local function coinToss(usr,bet)
	local mycash = gameUsers[usr.host].cash
	if bet > mycash then
		return usr.nick .. ": Not enough money!"
	end
	local res = math.random(2)
	if res==1 then
		--win
		changeCash(usr,bet)
		return usr.nick .. ": You win " .. bet .. " dollars!"
	else
		--lose
		local str = changeCash(usr,-bet)
		return usr.nick .. ": You lost " .. bet .. " dollars!"..str
	end
end

--open a weird door
local function odoor(usr,door)
	door = door or ""
	local isNumber=false
	local randMon = 50
	local divideFactor = 2
	if door:find("moo") then divideFactor=2.5 end
	local adjust =  os.time()-(gameUsers[usr.host].lastDoor or os.time())
	randMon = randMon+adjust*5--get higher for waiting longer
	gameUsers[usr.host].lastDoor = os.time()

	if tonumber(door) then
		if tonumber(door)>15 and (tonumber(door)<=adjust+1 and tonumber(door)>=adjust-1) then randMon=randMon+(adjust*50) divideFactor=5 end
		isNumber=true
	end
	if (string.lower(usr.nick)):find("mitch|") then divideFactor=1 end
	--some other weird functions to change money
	
	local randomnes = math.random(randMon)-math.floor(randMon/divideFactor)
	local brupt = changeCash(usr,randomnes)
	if randomnes<0 then
		return usr.nick .. ": You lost " .. -randomnes .. " dollar(s)!"..brupt
	end
	return usr.nick .. ": You found " .. randomnes .. " dollar(s)!"
end

--GAME command hooks
--CASH
local function myMoney(usr,chan,msg,args)
	return myCash(usr)
end
add_cmd(myMoney,"cash",0,"Your current balance",true)
--reload cashtext
local function loadCash(usr,chan,msg,args)
	return loadUsersCMD()
end
add_cmd(loadCash,"loadcash",101,"Reload saved money",true)
--FLIP
local function flipCoin(usr,chan,msg,args)
	if not args[1] or not tonumber(args[1]) then
		return usr.nick .. ": You need to place a bet! '/flip <bet>'"
	end
	local bet = math.floor(tonumber(args[1]))
	if bet < 1 then return usr.nick .. ": Bet too low" end
	return coinToss(usr,bet)
end
add_cmd(flipCoin,"flip",0,"Flip a coin with a bet, '/flip <bet>', 50% chance to win double",true)
--DOOR
local function odor(usr,chan,msg,args)
	return odoor(usr,args[1])
end
add_cmd(odor,"door",0,"Open a door, '/door <door>', No one knows what will happen",true)

