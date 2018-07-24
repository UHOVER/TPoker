local UserCtrol = {}

--维护站起玩家
local _lookUsers = {}

local function removeUserModelById(uid)
	for i=1,#_lookUsers do
		local um = _lookUsers[ i ]

		if uid == um:getUserId() then
			table.remove(_lookUsers, i)
			break
		end
	end
end

local function addLookUser(data)
	removeUserModelById(data['userId'])
	
	local UserModel = require 'model.UserModel'
	local um = UserModel:create()
	um:init()

	um:setUserId(data['userId'])
	um:setUserRYId(data['rongyunId'])
	um:setHeadUrl(data['headUrl'])
	um:setUserName(data['userName'])
	um:setSurplusNum(data['surplusNum'])
	-- data['teamUrl'] = "game/game_chouma_tag.png"
	um:setTeamBool(data['hasTeam'])
	table.insert(_lookUsers, um)
end

--进入游戏或断网重连
function UserCtrol.intoGame(susers, lusers)
	_lookUsers = {}
	for i=1,#lusers do
		addLookUser(lusers[ i ])
	end
end

--退出离开游戏
function UserCtrol.leaveGame(uid)
	removeUserModelById(uid)
end

--其他玩家刚进入游戏
function UserCtrol.oneInto(data)
	addLookUser(data)
end

--坐下
function UserCtrol.seatDo(uid)
	removeUserModelById(uid)
end

--站起
function UserCtrol.standDo(data)
	addLookUser(data)
end



--user操作
--

--得到站起用户通过id
function UserCtrol.getStandUserById(uid)
	for i=1,#_lookUsers do
		if _lookUsers[i]:getUserId() == uid then
			return _lookUsers[ i ]
		end
	end
	return nil
end

--得到坐下用户通过id
function UserCtrol.getSeatUserById(uid)
	local users = GameCtrol.getAllUsers()
	for i=1,#users do
		if users[i]:getUserId() == uid then
			return users[ i ]
		end
	end
	return nil
end

--得到坐下用户通过位置
function UserCtrol.getSeatUserByPos(pos) 
	local users = GameCtrol.getAllUsers()
	for i=1,#users do
		if users[i]:getSeatNum() == pos then
			return users[ i ]
		end
	end
	return nil
end

--得到用户通过id
function UserCtrol.getUserById(uid)
	local seatUser = UserCtrol.getSeatUserById(uid)
	local standUser = UserCtrol.getStandUserById(uid)
	if seatUser then
		return seatUser
	end
	if standUser then
		return standUser
	end
	return nil
end

--得到所有的站起用户
function UserCtrol.getAllStandUsers()
	return _lookUsers
end

--重置回合玩家数据：2001开始、2020结束、2200开始会跟2001重合
--清除状态：庄、大盲、小盲、状态、当前押注
function UserCtrol.resetUsers(users)
	for i=1,#users do
		local tuser = users[ i ]

		tuser:setBigBlind(false)
		tuser:setSmallBlind(false)
		tuser:setDealerTag(false)
		tuser:setStatus(StatusCode.GAME_WAIT_ING)
		tuser:setBetNum(0)

		--清除赢牌标示、清除结算后赢的记分牌
		tuser:setWinnerTag(false)
		tuser:setWinBet(0)

		--亮的两张玩家手牌、玩家上回合的牌型
		tuser:setDisPokers(nil)
		tuser:setPokerType('')

		tuser:setAllSurplusNum( tuser:getSurplusNum() )
	end
end

--重置回合游戏数据
--回合底池、
function UserCtrol.resetGameModel()
	local gm = Single:gameModel()
	gm:setRoundNum(StatusCode.GAME_ROUND0)
	gm:clearRoundPoolBet()
	gm:setPoolNowBet(0)
	gm:clearPoolCard()
	gm:setStraddleSeatNum(-1)
end

function UserCtrol.isSeatByPos(pos)
	local users = GameCtrol.getAllUsers()
	for i=1,#users do
		if users[ i ]:getSeatNum() == pos then
			return true
		end
	end
	return false
end

function UserCtrol.getSeatUserNum()
	local users = GameCtrol.getAllUsers()
	return #users
end


--2003 和 2007 先亮玩家手牌数据设置
function UserCtrol.disPoker2003(dispokers)
	local displays = {}
	if not dispokers then 
		return displays
	end
	
	for i=1,#dispokers do
		local pok = dispokers[ i ]
		local tuser = UserCtrol.getSeatUserByPos(pok['seatNum'])
		if tuser then
			tuser:setDisPokers(pok['cards'])
			tuser:setPokerType(pok['cardsType'])
			table.insert(displays, tuser)
		else
			print('stack dzpoker UserCtrol.disPoker2003  '..pok['seatNum'])
		end
	end

	return displays
end

function UserCtrol.disPoker2007(dispokers)
	local displays = {}
	local results = {}
	if not dispokers then 
		return results, displays
	end

	for i=1,#dispokers do
		local pok = dispokers[ i ]
		if not pok['isLeaved'] then
			local tuser = UserCtrol.getSeatUserByPos(pok['seatNum'])

			if tuser then
				--2003没有在此处设置值
				if not tuser:getDisPokers() then
					table.insert(displays, tuser)
				end

				tuser:setDisPokers(pok['cards'])
				tuser:setPokerType(pok['cardsType'])

				table.insert(results, tuser)
			else
				print('stack UserCtrol.disPoker2007')
				local logs = pok['seatNum']..'用户的位置是 nil'
				Single:appLogs(logs, 'UserCtrol.disPoker2007 位置：'..pok['seatNum'])
			end
		end
	end

	return results, displays
end

--2102 亮玩家手牌的数据设置
function UserCtrol.disPoker2108(dispokers)
	local displays = {}
	if not dispokers then 
		return displays
	end

	for i = 1, #dispokers do 
		local pok = dispokers[i]
		local tuser = UserCtrol.getSeatUserByPos(pok['seatNum'])
		if tuser  then 
			tuser:setDisPokers(pok['cards'])
			table.insert(displays, tuser)
		else 
			printInfo('stack UserCtrol.disPoker2108')
			local logs = pok['seatNum']..'用户的位置是 nil'..UserCtrol.getUserDetailed()
			Single:appLogs(logs, 'UserCtrol.disPoker2108 位置：'..pok['seatNum'])
		end
	end
	return displays
end

--user 和 player

--user数据跟player连接
function UserCtrol.userLinkPlayer(user)
	local pm = Single:playerManager()
	local player = pm:getPlayerByPos(user:getSeatNum())
	player:setSeatType(StatusCode.SEAT_USER)
	player:initData(user)
end

--通过user得到player，users必须都是坐下的
function UserCtrol.getPlayerByUser(users)
	local pm = Single:playerManager()
	local players = {}
	for i=1,#users do
		if users[ i ] then
			local player = pm:getPlayerByPos(users[ i ]:getSeatNum())
			table.insert(players, player)
		end
	end
	return players
end

--通过一个user得到一个player
function UserCtrol.getOnePlayerByOneUser(user)
	local pm = Single:playerManager()
	local player = pm:getPlayerByPos(user:getSeatNum())
	return player
end

--我自己返回SelfLayer
function UserCtrol.getDisPlayer(player)
	local disPlayer = player
	if player:isSelf() then 
		player:setVisible(false)
		disPlayer = SelfLayer
	end

	return disPlayer
end

function UserCtrol.getUserDetailed()
	local _users = GameCtrol.getAllUsers()
	
	local userfmt = "name:%s, pos:%d, status:%d"
	local result = '['
	for i = 1, #_users do 
		if _users[i] then 
			result = result.."\n"..string.format(userfmt, _users[i]:getUserName(), _users[i]:getSeatNum(), _users[i]:getStatus())
		else 
			result = result.."\n"..tostring(_users[i])
		end
	end
	result = result.."\n]"
	return result
end


return UserCtrol