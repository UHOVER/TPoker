local PlayerManager = class('PlayerManager')
local _players = {}
local _manager = nil

local firstp = 233 / display.height * 100
local maxHeight = 86.43

local _posarr = {}

local _posarr9 = {cc.p(50,firstp), cc.p(9.2,33.28), cc.p(9.2,51.8), cc.p(9.2,72.86),
			cc.p(27.07,86.43), cc.p(72.93,86.43), cc.p(90.93,72.86), cc.p(90.93,51.8), cc.p(90.93,33.28)
		}
local _posarr8 = {
					cc.p(50, firstp), cc.p(9.2,33.28), cc.p(9.2, 51.8), cc.p(9.2,72.86), cc.p(50, maxHeight),
					cc.p(90.93, 72.86), cc.p(90.93, 51.8), cc.p(90.93, 33.28)
				 }

local _posarr7 = {
				    cc.p(50, firstp), cc.p(9.2, 33.28), cc.p(9.2,65.36), cc.p(27.2, maxHeight), cc.p(72.8, maxHeight), 
				    cc.p(90.93, 65.36), cc.p(90.93, 33.28) 
				 }

local _posarr6 = {cc.p(50,firstp), cc.p(9.73,42.41), cc.p(9.73,71.61),  
			cc.p(50,maxHeight), cc.p(90.5,71.61), cc.p(90.5,42.41)
		}
local _posarr5 = {cc.p(50, firstp), cc.p(9.2, 58.0), cc.p(29.3, maxHeight), cc.p(70.7, maxHeight), cc.p(90.93, 58.0)}

local _posarr4 = {cc.p(50, firstp) , cc.p(9.2, 57.9) , cc.p(50, maxHeight) , cc.p(90.93, 57.9)}

local _posarr3 = {cc.p(50, firstp) , cc.p(9.2, 72.3) , cc.p(90.93, 72.3)}

local _posarr2 = {cc.p(50,firstp), cc.p(50,maxHeight)}


local function getPlayerById(pid)
	for i=1,#_players do
		local tplayer = _players[i]
		if not tplayer:isStand() and tplayer:getUId() == pid then
			return tplayer
		end
	end
	-- assert(nil, 'getPlayerById '..pid)

	return nil
end

function PlayerManager:getPlayerByPos(pos)
	for i=1,#_players do
		local tplayer = _players[i]
		if tplayer:getPos() == pos then
			return tplayer
		end
	end
end

--更新 大盲位置，小盲位置，庄家位置
function PlayerManager:updateBlindBet(bigSeat, smallSeat, dealerSeat)
	local _gameModel = Single:gameModel()
	local origin_BigBlindSeat = _gameModel:getBigBlindSeatNo()
	local origin_SmallBlindSeat = _gameModel:getSmallBlindSeatNo()
	local origin_DealerSeat = _gameModel:getDealerSeatNo()

	for i = 1, #_players do 
		local playerObj = _players[i]
		if not  playerObj then return end

		local curPos = playerObj:getPos()
		--隐藏
		if curPos == origin_BigBlindSeat then 
		end
		if curPos == origin_SmallBlindSeat then 
		end
		if curPos == origin_DealerSeat then 
			playerObj:hideD()
		end

		--显示
		if curPos == bigSeat then 
		end
		if curPos == smallBlind then 
		end
		if curPos == dealerSeat then 
			playerObj:disD()
		end
	end
end

function PlayerManager:changePos(curpos, noAni, aniEndBack)
    local function actionBack()
    	if aniEndBack then
    		aniEndBack()
    	end
    end
    if not noAni then 
		DZAction.delateShield(1)
	end

    local players = {}
    for i=curpos,#_players do
    	if #_players == #players then break end
    	table.insert(players, _players[ i ])
    end
    for i=1,curpos do
    	if #_players == #players then break end
    	table.insert(players, _players[ i ])
    end

    _players = players
    
    local function circleRun(idx, pos)
    	if idx == #_players then
			DZAction.easeInMove(_players[idx], pos, 0.5, DZAction.MOVE_TO, actionBack)
		else
			DZAction.easeInMove(_players[idx], pos, 0.5, DZAction.MOVE_TO, nil)
		end
	end

    for i=1,#_players do
		local tx = _posarr[i].x
		local ty = _posarr[i].y
		local pos = StringUtils.getPercentPos(tx, ty)
		
		if noAni then
			_players[i]:setPosition(pos)
		else
			circleRun(i, pos)
		end

		_players[ i ]:updateRunPos(i)
    end

    self:changeSeatText('空位')
end


function PlayerManager:changeSeatText(text)
	for i=1,#_players do
		_players[ i ]:setSeatTTf(text)
	end
end

function PlayerManager:changeNullHeadImg(hImg, hFontColor)
	for i=1,#_players do
		_players[ i ]:changeNullHeadImg(hImg, hFontColor)
	end

	SelfLayer:changeNullHeadImg(hImg, hFontColor)
end

function PlayerManager:moveAnimation(fromUser, toUser, aniTag, moveBack)
	local toUserId = toUser:getUserId()
	local fromPlayer = getPlayerById(fromUser:getUserId())
	local toPlayer = getPlayerById(toUserId)

    local runScene = cc.Director:getInstance():getRunningScene()
	local mPos = fromPlayer:convertToWorldSpace(fromPlayer:getCenter())
	local toPos = toPlayer:convertToWorldSpace(toPlayer:getCenter())

	local oneImg = DZConfig.getAniOneImg(aniTag)
	local ani = UIUtil.addPosSprite(oneImg, mPos, runScene, cc.p(0.5,0.5))

	local isHave = true
	local function onEvent(event)
		if event == "exit" then
			isHave = false
		end
	end

	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	toPlayer:addChild(tnode)

	DZAction.easeInMove(ani, toPos, 0.43, DZAction.MOVE_TO, function()
		ani:removeFromParent()
		if not isHave then return end
		--没有站起
		if not toPlayer:isStand() then
		-- local toUser = UserCtrol.getSeatUserById(toUserId)
		-- if toUser then
			moveBack()
		end
	end)
end


function PlayerManager:init(parent)
	_players = {}

	local pnum = Single:gameModel():getGameNum()
	local posArr = {
					 [1] = "error",
					 [2] = _posarr2,
					 [3] = _posarr3,
					 [4] = _posarr4,
					 [5] = _posarr5,
					 [6] = _posarr6,
					 [7] = _posarr7,
					 [8] = _posarr8,
					 [9] = _posarr9
				   }
	_posarr = posArr[pnum]
	local postype = type(_posarr)
	if postype == "string" then 
		assert(nil, 'PlayerManager init '..pnum)
	end					   

	local UpdatePlayer = require 'game.UpdatePlayer'
	for i=1,#_posarr do
		local tplayer = UpdatePlayer:create(i, i)
		local pos = StringUtils.getPercentPos(_posarr[i].x, _posarr[i].y)
		tplayer:setPosition(pos)
		parent:addChild(tplayer)

		tplayer:addNull('坐下')

		table.insert(_players, tplayer)
	end
end


function PlayerManager:getInstance()
	if _manager == nil then
		_manager = PlayerManager:create()
	end
	return _manager
end

function PlayerManager:getSeatPlayers()
	local tabs = {}
	for i=1,#_players do
		if not _players[i]:isStand() then
			table.insert(tabs, _players[i])
		end
	end

	return tabs
end

function PlayerManager:getGamingPlayers()
	local tabs = {}
	for i=1,#_players do
		local tplayer = _players[ i ]

		if not tplayer:isStand() then
			local tuser = tplayer:getUserData()
			local status = tuser:getStatus()

			if GJust.isGamingByStatus(status) then
				table.insert(tabs, tplayer)
			end
		end
	end

	return tabs
end

function PlayerManager:getAllPlayers()
	return _players
end

function PlayerManager:getPosNine()
	return _posarr9
end


function PlayerManager:testFunc(tag)
end

function PlayerManager:ctor()
end
return PlayerManager