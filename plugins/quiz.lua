module("quiz", package.seeall)


local charLookAlike={["0"]="O",["1"]="I",["2"]="Z",["3"]="8",["4"]="H",["5"]="S",["6"]="G",["7"]="Z",["8"]="3",["9"]="6",
["b"]="d",["c"]="s",["d"]="b",["e"]="c",["f"]="t",["g"]="q",["h"]="n",["i"]="j",["j"]="i",
["k"]="h",["l"]="1",["m"]="n",["n"]="m",["o"]="c",["p"]="q",["q"]="p",
["r"]="n",["s"]="c",["t"]="f",["u"]="v",["v"]="w",["w"]="vv",["x"]="X",["z"]="Z",
["A"]="&",["B"]="8",["C"]="O",["D"]="0",["E"]="F",["F"]="E",["G"]="6",["H"]="4",["I"]="l",
["J"]="U",["K"]="H",["L"]="J",["M"]="N",["N"]="M",["O"]="0",["P"]="R",["R"]="P",
["S"]="5",["T"]="F",["U"]="V",["V"]="U",["W"]="VV",["X"]="x",["Y"]="V",["Z"]="2",
["!"]="1",["@"]="&",["#"]="H",["$"]="S",["^"]="/\\",["&"]="8",["("]="{",[")"]="}",["-"]="=",["="]="-",
["{"]="(",["}"]=")",["\""]="'",["'"]="\"",["/"]="\\",["\\"]="/",["`"]="'",["~"]="-",
}
local questions={}
table.insert(questions,{
q= function() --Count a letter in string, with some other simple math
	if not filters.mknumscramb then return "Error: filter plugin must be loaded" end
	local chars = {}
	local extraNumber = math.random(10)
	if extraNumber<=7 then extraNumber=math.random(20000) else extraNumber=nil end
	local rstring=""
	local countChar,answer
	local timeout=25
	local multiplier=0.75
	local i,maxi = 1,math.random(2,7)

	--pick countChar first
	countChar,answer = string.char(math.random(93)+33),(math.random(16)-1)
	rstring = rstring.. string.rep(countChar,answer)
	chars[countChar]=true
	local pickedR=false
	while i<maxi do
		--pick 2-7 chars (2-7 filler) make sure all different
		local rchar
		--possibly add look-alike
		if not pickedR and math.random(10)==1 then
			rchar= charLookAlike[countChar] or string.char(math.random(93)+33)
			pickedR=true
		else
			rchar = string.char(math.random(93)+33)
		end

		if not chars[rchar] then
			chars[rchar]=true
			local amount=(math.random(16)-1)
			rstring = rstring.. string.rep(rchar,amount)
			i = i+1
		end
	end

	local t={}
	for char in rstring:gmatch(".") do
		table.insert(t,char)
	end
	local n=#t
	while n >= 2 do
		local k = math.random(n)
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
	local intro="Count the number of"
	if extraNumber then
		local randMod = math.random(43)
		if randMod<=15 then --subtract
			intro="What is "..filters.mknumscramb(extraNumber).." minus the number of"
			answer = extraNumber-answer
			multiplier=0.85
		elseif randMod<=22 then --Multiply
			extraNumber = extraNumber%200
			intro="What is "..filters.mknumscramb(extraNumber).." times the number of"
			answer = extraNumber*answer
			timeout,multiplier = 40,1.1
		elseif randMod==23 then --addition AND multiply
			extraNumber = extraNumber
			local extraNum2 = math.random(200)-1
			intro="What is "..filters.mknumscramb(extraNumber).." plus "..filters.mknumscramb(extraNum2).." times the number of"
			answer = extraNumber + (extraNum2*answer)
			timeout,multiplier = 50,1.3
		elseif randMod==24 then --subtraction AND multiply
			extraNumber = extraNumber
			local extraNum2 = math.random(200)-1
			intro="What is "..filters.mknumscramb(extraNumber).." minus "..filters.mknumscramb(extraNum2).." times the number of"
			answer = extraNumber - (extraNum2*answer)
			timeout,multiplier = 50,1.3
		elseif randMod<=26 and answer>0 then --Repeat string
			extraNumber = extraNumber%1000
			intro="Repeat the string \" "..extraNumber.." \" by the amount of"
			answer = (tostring(extraNumber)):rep(answer)
			timeout,multiplier = 40,1.2
		elseif randMod<=40 then --add
			intro="What is "..filters.mknumscramb(extraNumber).." plus the number of"
			answer = answer+extraNumber
			multiplier=0.85
		else
			local possibleAnswers = {"Ring-ding-ding-ding-dingeringeding", "Wa-pa-pa-pa-pa-pa-pow", "Hatee-hatee-hatee-ho", "Joff-tchoff-tchoffo-tchoffo-tchoff", "Jacha-chacha-chacha-chow", "Fraka-kaka-kaka-kaka-kow", "A-hee-ahee ha-hee", "A-oo-oo-oo-ooo"}
			answer = possibleAnswers[math.random(#possibleAnswers)]
			multiplier = 2
			return "What does the fox say?", answer, timeout, multiplier
		end
	end
	return intro.." ' "..countChar.." ' in: "..table.concat(t,""),tostring(answer),timeout,multiplier
end,
isPossible= function(s) --this question only accepts number answers
	if tonumber(s) then return true end
	local possibleAnswers = {"Ring-ding-ding-ding-dingeringeding", "Wa-pa-pa-pa-pa-pa-pow", "Hatee-hatee-hatee-ho", "Joff-tchoff-tchoffo-tchoffo-tchoff", "Jacha-chacha-chacha-chow", "Fraka-kaka-kaka-kaka-kow", "A-hee-ahee ha-hee", "A-oo-oo-oo-ooo"}
	for k,v in pairs(possibleAnswers) do
		if s == k then return true end
	end
	return false
end})
local allColors = {white='00', black='01', blue='02', green='03', red='04', brown='05', purple='06', orange='07', yellow='08', lightgreen='09', turquoise='10', cyan='11', skyblue='12', pink='13', gray='14', grey='14'}
local wordColorList = {'blue','green','red','brown','purple','orange','yellow','cyan','pink','gray',}
table.insert(questions,{
q= function() --Count the color of words, or what the word says.
	local guessC = wordColorList[math.random(#wordColorList)]
	local answer = math.random(0,5)
	local filler = math.random(3,10)
	local intro = "Count the number "
	local chance = math.random(1,100)
	local timeout,multiplier=25,.75
	local t,nt={},{}
	if chance<25 then --count words of a color
		for i=1,filler do
			local ch = wordColorList[math.random(#wordColorList)]
			if ch~= guessC then table.insert(t,"\003"..allColors[ch]) else i=i-1 end
		end
		for i=1,answer do
			table.insert(t,"\003"..allColors[guessC])
		end
		for k,v in pairs(t) do table.insert(nt,v..wordColorList[math.random(#wordColorList)]) end
		intro = intro.."of words that are colored "
	elseif chance<50 then --count words
		for i=1,filler do
			local ch = wordColorList[math.random(#wordColorList)]
			if ch~= guessC then table.insert(t,ch) else i=i-1 end
		end
		for i=1,answer do
			table.insert(t,guessC)
		end
		for k,v in pairs(t) do table.insert(nt,"\003"..allColors[wordColorList[math.random(#wordColorList)]]..v) end
		intro = intro.."of words that say "
	elseif chance<75 then --what does the colored word say
		for i=1,filler do
			local ch = wordColorList[math.random(#wordColorList)]
			if ch~= guessC then table.insert(t,"\003"..allColors[ch]) else i=i-1 end
		end
		answer = wordColorList[math.random(#wordColorList)]
		table.insert(nt,"\003"..allColors[guessC]..answer)

		for k,v in pairs(t) do table.insert(nt,v..wordColorList[math.random(#wordColorList)]) end
		intro = "What does the "..guessC.." word say" guessC=""
	else --what colour is the word
		for i=1,filler do
			local ch = wordColorList[math.random(#wordColorList)]
			if ch~= guessC then table.insert(t,ch) else i=i-1 end
		end
		answer = wordColorList[math.random(#wordColorList)]
		table.insert(nt,"\003"..allColors[answer]..guessC)

		for k,v in pairs(t) do table.insert(nt,"\003"..allColors[wordColorList[math.random(#wordColorList)]]..v) end
		intro = "What color is the word "
	end
	local n=#nt
	while n >= 2 do
		local k = math.random(n)
		nt[n], nt[k] = nt[k], nt[n]
		n = n - 1
	end

	return intro..guessC.." : "..table.concat(nt," "),tostring(answer),timeout,multiplier
end,
isPossible= function(s) --this question only accepts number and color answers
	if tonumber(s) or allColors[s] then return true end
	return false
end})

--[[
table.insert(questions,{
q= function() --A filler question, just testing
	return "Say moo, this is a test question","moo",15,1
end,
isPossible= function(s) --this question takes any string
	if not s:find("%./") then return true end
	return false
end})--]]
local activeQuiz= {}
local activeQuizTime={}
--QUIZ, generate a question, someone bets, anyone can answer
local function quiz(usr,chan,msg,args)
	--timeout based on winnings
	if os.time() < (gameUsers[usr.host].nextQuiz or 0) then
		return "You must wait "..(gameUsers[usr.host].nextQuiz-os.time()).." seconds before you can quiz!."
	end
	if not msg or not tonumber(args[1]) then
		return "Start a question for the channel, '/quiz <bet>'"
	end

	local qName = chan.."quiz"
	if activeQuiz[qName] then return
		"There is already an active quiz here!"
	end

	local bet= math.floor(tonumber(args[1]))
	if chan:sub(1,1)~='#' then
		if bet>10000 then
			return "Quiz in query has 10k max bid"
		end
	end
	if bet > 100000000000 then
		return "You cannot bet more than 100 billion"
	end

	local gusr = gameUsers[usr.host]
	if bet~=bet or bet<1000 then
		return "Must bet at least 1000!"
	elseif gusr.cash-bet<0 then
		return "You don't have that much!"
	end

	changeCash(usr,-bet)
	--pick out of questions
	local wq = math.random(#questions)
	local rstring,answer,timer,prizeMulti = questions[wq].q()
	print("QUIZ ANSWER: "..answer)
	activeQuiz[qName],activeQuizTime[qName] = true,os.time()
	local alreadyAnswered={}
	--insert answer function into a chat listen hook
	addListener(qName,function(nusr,nchan,nmsg)
		if nchan==chan then
			if nmsg==answer and not alreadyAnswered[nusr.host] then
				local answeredIn= os.time()-activeQuizTime[qName]-1
				if answeredIn <= 0 then answeredIn=1 end
				local earned = math.floor(bet*(prizeMulti+(math.sqrt(1.1+1/answeredIn)-1)*3))
				--Quiz Coupon Answer Bonus
				local discount = hasCoup(nusr,11,12,13)
				if discount then earned = earned * (1+couponList[discount]) remCoup(usr,discount,1) end

				local cstr = changeCash(nusr,earned)
				if nusr.nick==usr.nick then
					ircSendChatQ(chan,nusr.nick..": Answer is correct, earned "..(earned-bet)..cstr)
				else
					ircSendChatQ(chan,nusr.nick..": Answer is correct, earned "..earned..cstr)
				end
				gameUsers[nusr.host].nextQuiz = math.max((gameUsers[nusr.host].nextQuiz or os.time()),os.time()+math.floor(43*(math.log(earned-bet)^1.1)-360) )
				remTimer(qName)
				activeQuiz[qName]=false
				return true
			else
				--you only get one chance to answer correctly
				if questions[wq].isPossible(nmsg) then alreadyAnswered[nusr.host]=true end
			end
		end
		return false
	end)
	--insert a timer to remove quiz after a while
	addTimer(function() chatListeners[qName]=nil activeQuiz[qName]=false ircSendChatQ(chan,"Quiz timed out, no correct answers! Answer was "..answer) end,timer,chan,qName)
	ircSendChatQ(chan,rstring,true)
	--no return so you can't see nest result
	return nil
end
add_cmd(quiz,"quiz",0,"Start a question for the channel, '/quiz <bet>' First to answer correctly wins a bit more, only your first message is checked.",true)

--ASK a question, similar to quiz, but from a user in query
local function ask(usr,chan,msg,args)
	if chan:sub(1,1)=='#' then return "Can only start question in query." end
	if not msg or not args[3] then return commands["ask"].helptext end
	local toChan = args[1]
	if toChan:sub(1,1) ~= "#" then
		return "Error, you must ask questions to a channel"
	elseif not irc.channels[toChan] then
		return "Error, i'm not in that channel"
	elseif not irc.channels[toChan].users[usr.nick] then
		return "Error, you must be in "..toChan.." to ask a question there"
	elseif getPerms(usr.host, toChan) < getCommandPerms("ask", toChan) then
		return "Error, you don't have permission to ask a question in there"
	end
	local qName = toChan.."ask"
	if activeQuiz[qName] then return "There is already an active question there!" end
	local prize, argA = args[2]:match("(%d+)"), 0
	if prize then
		if not args[4] then return commands["ask"].helptext end
		if gameUsers[usr.host].cash-prize<0 then return "You don't have enough money for the prize!" end
		argA=1
	end
	local rstring,answer,timer = "Question from "..usr.nick..(prize and (" ($"..prize.."): ") or ": ")..args[2+argA],args[3+argA],30
	local answers= {}
	for i=3+argA,#args do
		answers[args[i]:lower()]=true
	end
	activeQuiz[qName] = true
	--insert answer function into a chat listen hook
	addListener(qName,function(nusr,nchan,nmsg)
		if nchan==toChan and answers[nmsg:lower()] then
			if prize then changeCash(usr,-prize) end
			ircSendChatQ(toChan,nusr.nick..": "..nmsg.." is correct, congratulations!"..(prize and " Got $"..prize..changeCash(nusr,prize) or ""))
			remTimer(qName)
			activeQuiz[qName]=false
			return true
		end
		return false
	end)
	--insert a timer to remove question after a while
	addTimer(function() chatListeners[qName]=nil activeQuiz[qName]=false ircSendChatQ(toChan,"Quiz timed out, no correct answers! Answer was "..answer) end,timer,toChan,qName)
	ircSendChatQ(toChan,rstring)
	return nil
end
add_cmd(ask,"ask",0,"Ask a question to a channel, '/ask <channel> [<prize($)>] <question> <mainAnswer> [<altAns...>]' Optional prize, It will help to put \" around the question and answer.",true)
