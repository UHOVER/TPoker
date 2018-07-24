--
-- Author: Taylor
-- Date: 2016-12-01 16:26:21
--
-- 用来伪造消息， 以及一些测试用例
-- 

local TestCase = {}

local _quene = {}
local _isRegister = false
local _revFunc = nil
function TestCase.startTest(time)

	local function update(dt) 
		local waitDelete = {}
		local nowTime = os.time()
		for i,v in ipairs(_quene) do
			local startTime = v.startTime
			local data = v.source
			local totalTime = v.totalTime
			local receiveFunc = v.rev 
			if (startTime - nowTime >= totalTime) or totalTime == 0 then 
				waitDelete[#waitDelete + 1] = i
				if receiveFunc then 
					receiveFunc(data)
				end
			else 
				startTime = startTime + nowTime - startTime
			end
		end

		for i,v in ipairs(waitDelete) do
			table.remove(_quene, v)
		end
	end
	DZSchedule.scheduleGlobal(time, update)
end

function TestCase.receivePackage1000()
	--[[
		{"roomName":"111","roomRongyunId":"gaming14110",
		"joinCode":null,"bigBlind":50,"limitPlayers":9,
		"gameMode":"21","isInRoom":true,"isManager":true,
		"isStart":true,"thinkTime":15,"insureTime":25,
		"cuoTime":25,"isPause":false,"isInsure":true,
		"ante":25,"surplusTime":2126,"controlBuyin":true,
		"haveUnhandledApply":false,"diamonds":0,
		"addTimePrice":{"thinking":0,"insurseanceThinking":0,"cuo":0},
		"addThinkTimePrice":0,
		"users":[
				{"userId":"868","rongyunId":"0.774397001476907388","userName":"该用户没有名","headUrl":"0.988832001476907418575283.jpg","surplusNum":18397,"seatNum":3,"status":7,"surplusRefuseTime":0},
				{"userId":"1139","rongyunId":"0.628422001484907112","userName":"无敌霸王","headUrl":"0.402262001486247792277002.jpg","surplusNum":56770,"seatNum":2,"status":7,"surplusRefuseTime":0},
				{"userId":"890","rongyunId":"0.395248001477658522","userName":"DG","headUrl":"0.808884001477674692293536.jpg","surplusNum":43718,"seatNum":4,"status":7,"surplusRefuseTime":0},
				{"userId":"1162","rongyunId":"0.871509001485265984","userName":"天洲","headUrl":"default_avatars.png","surplusNum":8324,"seatNum":6,"status":7,"surplusRefuseTime":0},
				{"userId":"963","rongyunId":"0.813656001479883022","userName":"可乐","headUrl":"0.037414001479883102104131.jpg","surplusNum":0,"seatNum":-1,"status":-1,"surplusRefuseTime":0},
				{"userId":"1165","rongyunId":"0.031404001485267952","userName":"皮卡丘","headUrl":"0.132336001485716806485082.jpg","surplusNum":0,"seatNum":-1,"status":-1,"surplusRefuseTime":0},
				{"userId":"1146","rongyunId":"0.870073001485092972","userName":"无敌木马","headUrl":"","surplusNum":5000,"seatNum":5,"status":7,"surplusRefuseTime":0},
				{"userId":"1240","rongyunId":"0.704835001486270994","userName":"司令","headUrl":"","surplusNum":7329,"seatNum":1,"status":7,"surplusRefuseTime":0}
				],
	   "result":1,"protocolNum":1000
	   }
	 ]]--
	local function getUser(userId, rongyunId, userName, headUrl, surplusNum, seatNum, status, surplusRefuseTime)
		local userData = {}
		userData.userId = userId
		userData.rongyunId = rongyunId
		userData.userName = userName
		userData.headUrl = headUrl
		userData.surplusNum = surplusNum
		userData.seatNum = seatNum
		userData.status = status
		userData.surplusRefuseTime = surplusRefuseTime
		return userData
	end
	local message1000 = { 
				['protocolNum'] = 1000, 
				['result'] = 1, 
				['roomName'] = "111", 
				['roomRongyunId'] = "gaming14110",
			}
	message1000['joinCode'] = null
	message1000['bigBlind'],message1000['limitPlayers'] = 50, 9
	message1000['gameMode'],message1000['isInRoom'],message1000['isManager'] = "21", true,  true
	message1000['isStart'] = true
	message1000['thinkTime'] = 15
	message1000['insureTime'] = 25
	message1000['cuoTime']  = 25
	message1000['isPause']  = false
	message1000['isInsure']  = true
	message1000['ante']  = 25
	message1000['surplusTime']  = 2126
	message1000['controlBuyin']  = true
	message1000['haveUnhandledApply']  = false
	message1000['diamonds']  = 0
	message1000['addTimePrice']  = {['thinking'] = 0, ['insuranceThinking'] = 0, ['cuo'] = 0}
	message1000['addThinkTimePrice']  = 0
	message1000['users']  = {
						 		getUser("868","0.774397001476907388","该用户没有名","0.988832001476907418575283.jpg",18397,3,7,0),
								getUser("1139","0.628422001484907112","无敌霸王", "0.402262001486247792277002.jpg",56770,2,7,0),
								getUser("890","0.395248001477658522","DG","0.808884001477674692293536.jpg",43718,4,7,0),
								getUser("1162","0.871509001485265984","天洲","default_avatars.png",8324,6,7,0),
								getUser("963", "0.813656001479883022","可乐","0.037414001479883102104131.jpg",0,-1,-1,0),
						 		getUser("1165","0.031404001485267952","皮卡丘","0.132336001485716806485082.jpg",0,-1,-1,0),
						 		getUser("1146","0.870073001485092972","无敌木马","", 5000,5,7,0),
						        getUser("1240","0.704835001486270994","司令","",7329,1,7,0)
							}
	return message1000
end

function TestCase.receivePackage2200()
	 local msg = {}
	 msg['roundPoolBet'] = {150}
	 msg['players'] = {
	 					 {["seatNum"]=1, ["bet"]=25, ["surplus"]= 7304},
	 					 {["seatNum"]=2, ["bet"]=25, ["surplus"]= 56745},
	 					 {["seatNum"]=3, ["bet"]=25, ["surplus"]= 18372},
	 					 {["seatNum"]=4, ["bet"]=25, ["surplus"]= 43693},
	 					 {["seatNum"]=5, ["bet"]=25, ["surplus"]= 4975},
	 					 {["seatNum"]=6, ["bet"]=25, ["surplus"]= 8299},
					  }
	msg['ante'] = 25
	msg['protocolNum'] = 2200
	return json.encode(msg)
end

function TestCase.receivePackage2001()
	local msg = {}
	msg['protocolNum'] = 2001
	msg['dealerSeatNum'] = 3
	msg['smallBlindSeatNum'] = 4
	msg['bigBlindSeatNum'] = 5
	msg['smallBlindBetNum'] = 25
	msg['bigBlindBetNum'] = 50
	msg['smallBlindsurplusNum'] = 43668
	msg['bigBlindsurplusNum'] = 4925
	msg['currentSeatNum'] = 6
	msg['inGameSeatNums'] = {1, 2, 3, 4, 5, 6}
	msg['beforeTalkBet'] = 225
	return json.encode(msg)
end

function TestCase.receivePackage2005()
	local msg = {}
	msg['protocolNum'] = 2005
	msg['seatNum'] = 1
	return json.encode(msg)
end

function TestCase.receivePackage2000()
	local msg = {}
	msg['userId'] = '1240'
	msg['rongyunId'] = '0.704835001486270994'
	msg['userName'] = "司令"
	msg['headUrl'] = ""
	msg['surplusNum'] = 7304
	msg['seatNum'] = 7
	msg['status'] = 7
	msg['surplusRefuseTime'] = 0
	msg['protocolNum'] = 2000
	return json.encode(msg)
end

function TestCase.receivePackage2011()
	local msg = {}
	msg['userId']  = 1240
	msg['protocolNum'] = 2011
	return json.encode(msg)
end

function TestCase.receivePackage2002_0()
	local msg = {}
	msg['selectSeatNum'] = 6
	msg['currentSeatNum'] = 1
	msg['selectType'] = 0
	msg['betNum'] = 0
	msg['poolBet'] = 225
	msg['surplusBetNum'] = 8299
	msg['lastRaiseBetNum'] = 0
	msg['isRoundEnd'] = false
	msg['isGameEnd'] = false
	msg['protocolNum'] = 2002
	return json.encode(msg)
end

function TestCase.receivePackage2002_1()
	local msg = {}
	msg['selectSeatNum'] = 1
	msg['currentSeatNum'] = 2
	msg['selectType'] = 0
	msg['betNum'] = 0
	msg['poolBet'] = 225
	msg['surplusBetNum'] = 7304
	msg['lastRaiseBetNum'] = 0
	msg['isRoundEnd'] = false
	msg['isGameEnd'] = false
	msg['protocolNum'] = 2002
	return json.encode(msg)
end

function TestCase.receivePackage2002_2()
	local msg = {}
	msg['selectSeatNum'] = 2
	msg['currentSeatNum'] = 3
	msg['selectType'] = 3
	msg['betNum'] = 400
	msg['poolBet'] = 625
	msg['surplusBetNum'] = 56345
	msg['lastRaiseBetNum'] = 400
	msg['isRoundEnd'] = false
	msg['isGameEnd'] = false
	msg['protocolNum'] = 2002
	return json.encode(msg)
end

function TestCase.receivePackage2002_3()
	local msg = {}
	msg['selectSeatNum'] = 4
	msg['currentSeatNum'] = -1
	msg['selectType'] = 1
	msg['betNum'] = 50
	msg['poolBet'] = 225
	msg['surplusBetNum'] = 43718
	msg['lastRaiseBetNum'] = 0
	msg['isRoundEnd'] = true
	msg['isGameEnd'] = false
	msg['protocolNum'] = 2002
	return json.encode(msg)
end

function TestCase.receivePackage2003()
	local msg = {}
	msg['round'] = 1
	msg['currentSeatNum'] = 3
	msg['roundPoolBet'] = {225}
	msg['newCards'] = {2, 4, 46}
	msg['isRoundEnd'] = false
	msg['protocolNum'] = 2003
	return json.encode(msg)
end

function TestCase.receivePackage2010()
	
	local msg = {}
	msg['userId'] = "1240"
	msg['rongyunId'] = "0.704835001486270994"
	msg['userName'] = "司令"
	msg['headUrl'] = ""
	msg['surplusNum'] = 7329
	msg['seatNum'] = -1
	msg['status'] = -1
	msg['surplusRefuseTime'] = 0
	msg['protocolNum'] = 2010
	return json.encode(msg)
end


--
function TestCase.receivePackage2102()
	local message = {}
	message.protocolNum = 2102
	message.needSelect = true
	message.reason = "不能购买的原因是应为RP不够"
	message.insureSeatNum = 1
	message.cuoSeatNum = 1 --搓牌的人
	message.poolBet = 4000 --最大的底池
	message.poolCards = {2, 3, 4} --池底的牌
	message.outsCards = {5,6,7,8,9,15} --可以out的牌
	message.mustBuy = false
	message.turnRoundInsured = 15 --转牌局的投保额
	message.players = {
						{
						   seatNum = 1, --座位号
						   betInPool = 400, --此选手下注
						   winRate = 30, -- 胜率
						   outs = {5,7}, -- 该玩家的outs
						   cards = {15, 20} --改用户的手牌
						},
						-- {
						-- 	seatNum= 9, 
						-- 	betInfoPool = 900,
						-- 	winRate = 20,
						-- 	outs = {5,7},
						-- 	cards = {14,29}
						-- },
						-- {
						--    seatNum = 4, --座位号
						--    betInPool = 900, --此选手下注
						--    winRate = 20, -- 胜率
						--    outs = {6,9}, -- 该玩家的outs
						--    cards = {18, 25} --改用户的手牌
						-- },
						-- {
						--    seatNum = 4, --座位号
						--    betInPool = 900, --此选手下注
						--    winRate = 20, -- 胜率
						--    outs = {8,10}, -- 该玩家的outs
						--    cards = {19, 21} --改用户的手牌
						-- },
					  }
	return json.encode(message)
end

function TestCase.sendPackage1023()
end

function TestCase.receivePackage1023()
end

function TestCase.receivePackage2101()
	local message2101 =  {}
	message2101.protocolNum = 2101
	return json.encode(message2101)
end

function TestCase.receivePackage2103()
	local message = {}

	message.unselected = {}
	message.amountsPercent = math.random(0, 100)
	
	return json.encode(message)
end

function TestCase.receivePackage2104()
	local message = {}
	message.protocolNum = 2104
	message.selectSeatNum = 1
	message.selectType = math.random(0, 1)
	message.outs = {1, 2, 3, 4, 5}
	message.amount = 10
	return json.encode(message)
end

function TestCase.receivePackage2105()
end

function TestCase.receivePackage2106()
end

function TestCase.receivePackage2107()
	local message = {}
	message.protocolNum = 2107
	message.card = 8
	message.hasBuy = true
	message.hasCuo = true
	message.isHit = math.random(0, 1)
	message.compensation = 160
	return json.encode(message)
end

function TestCase.receivePackage2023()
	local message = {}
	message.protocolNum = 2023
	message.addType = 1
	message.surplusThinkingTime = 25
	message.seatNum = 1
	return json.encode(message)
end

function TestCase.sendMessageDelay(protocolNum, time, receFunc)
	print(">>>>>测试协议 ----"..protocolNum)
	local data = nil
	if protocolNum == 2023 then 
		data = TestCase.receivePackage2023() 
	elseif protocolNum == 2101 then 
		data = TestCase.receivePackage2101()
	elseif protocolNum == 2102 then 
		data = TestCase.receivePackage2102()
	elseif protocolNum == 2103 then 
		data = TestCase.receivePackage2103()
	elseif protocolNum == 2104 then 
		print("heihei 2104")
		data = TestCase.receivePackage2104()
	elseif protocolNum == 2105 then 
		data = TestCase.receivePackage2105()
	elseif protocolNum == 2106 then 
		data = TestCase.receivePackage2106()
	elseif protocolNum == 2107 then 
		data = TestCase.receivePackage2107()

	elseif protocolNum == 2200 then 
		data = TestCase.receivePackage2200()
	elseif protocolNum == 2001 then 
		data = TestCase.receivePackage2001()
	elseif protocolNum == 5002 then 
		data = TestCase.receivePackage2002_0()
	elseif protocolNum == 5003 then 
		data = TestCase.receivePackage2002_1()
	elseif protocolNum == 5004 then 
		data = TestCase.receivePackage2002_2()
	elseif protocolNum == 2005 then 
		data =  TestCase.receivePackage2005()
	elseif protocolNum == 2000 then 
		data = TestCase.receivePackage2000()
	elseif protocolNum == 5008 then 
		data = TestCase.receivePackage2002_3()
	end

	if (time == 0) then
		receFunc(data)
	else 
		_quene[#_quene + 1] = {
							   source = data, 
							   totalTime = time, 
							   startTime = -1, 
							   rev = receFunc}
	end
end

--俱乐部
function TestCase.getStatsitic()
	local data = {
		{
	      ["name"] = "黄家驹几",
	      ["avatar"] = "",
	      ["union"] = "0",
	      ["x_num"] = 1,
	      ["club_id"] = 965
	    },
	    {
	      ["name"]= "我路过",
	      ["avatar"]= "",
	      ["union"]= "0",
	      ["x_num"]=1,
	       ["club_id"]=966
	    },
	    {
	      ["name"]= "bjkk",
	      ["avatar"]= "",
	      ["union"]= "0",
	      ["x_num"]=1, 
	      ["club_id"]=964
	    }
	 }
	 return data
end

--俱乐部的统计
function TestCase.getStatsiticDetial(isInsure)
	local data = nil
	print("是不是保险 ",tostring(isInsure))
	if isInsure <= 0 then 
	   data = {
			["p_num"] = 1,
		    ["spends_num"]=  400,
		    ["total_buyin"]= 1600,
		    ['access_times_r'] = 10,
		    ['access_times_a'] = 20,
		    ['total_award'] = 10,
		    ["list"]= {
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ["bet_num"]= 1600,
		      },
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ["bet_num"]= 1600,
		        ['r_num'] = 10,
		        ['a_num'] = 1,
		      },
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ["bet_num"]= 1600,
		        ['r_num'] = 10,
		      },
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ["bet_num"]= 1600,
		        ['a_num'] = 1,
		      }
		    }
		}
	else 
	   data = {
			["p_num"] = 1,
		    ["spends_num"]=  400,
		    ["total_buyin"]= 1600,
		    ["insurance_num"]= 319,
		    ["list"]= {
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ["insurance_pool"] = 100,
		        ["bet_num"]= 1600
		      },
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ['insurance_pool'] = -100,
		        ["u_no"]="1019928",
		        ["bet_num"]= 1600
		      },
		      {
		        ["username"]= "百搭款",
		        ["spends"] =400,
		        ["u_no"]="1019928",
		        ['insurance_pool'] = 0,
		        ["bet_num"]= 1600
		      }
		    }
		}
	end
	return data
end

--获得管理员id
function TestCase.getManagerIds()
	local data = {
				['u_nos'] = {
						[1] = "1019928",
						[2] = "1020032",
						[3] = "0102312",
					}
				}
	return data
end

--搜索返回的数据
function TestCase.getAuthorizeData(mod)
	local data = {}
	if mod ~= 4 then 
		 data = {
	    	["p_num"]= 1,
	    	["spends_num"]= 400,
	    	["list"]= {
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928"
	     		 },
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928"
	     		 },
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928"
	     		 },
	   		 }
	  	}
	  else 
	  	 data = {
	    	["p_num"]= 1,
	    	["spends_num"]= 400,
	    	['access_times_r'] = 10,
	    	['access_times_a'] = 2,
	    	["list"]= {
	    		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928",
	     		 },
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928",
	       			 ['r_num'] = 1
	     		 },
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928",
	       			 ['a_num'] = 1
	     		 },
	     		 {
	        		["username"]="百搭款",
	        		["spends"]=400,
	       			 ["u_no"]="1019928",
	       			 ['a_num'] = 1,
	       			 ['r_num'] = 10
	     		 },
	   		 }
	  	}

	  end
  return data
end

--俱乐部中用户保险详情
function TestCase.getClubUserInsure()
	local bxData = {}
	bxData['dataList'] = {}
	bxData['dataList'][1] = {['poolNum'] = 100, ["headurl"] = nil, ['name'] = "niubi", ['playerID'] = 1000, ['pid'] = 100}
	bxData['dataList'][2] = {['poolNum'] = 100, ["headurl"] = nil, ['name'] = "niubi", ['playerID'] = 1000, ['pid'] = 100}
	bxData['dataList'][3] = {['poolNum'] = 100, ["headurl"] = nil, ['name'] = "niubi", ['playerID'] = 1000, ['pid'] = 100}
	bxData['dataList'][4] = {['poolNum'] = 100, ["headurl"] = nil, ['name'] = "niubi", ['playerID'] = 1000, ['pid'] = 100}
	bxData['dataList'][5] = {['poolNum'] = 100, ["headurl"] = nil, ['name'] = "niubi", ['playerID'] = 1000, ['pid'] = 100}
	return bxData
end

--mtt赛事自动报名
function TestCase.sendMttAutoSingUp(mtt_id, funcback)
	local function response(data)
		funcback()
	end
	local tab = {}
	tab['mtt_id'] = mtt_id
	XMLHttp.requestHttp("unionMttApply",tab, response, PHP_POST)
end

return  TestCase