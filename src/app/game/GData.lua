local GData = {}

--游戏相关的数据

--游戏id
local _gid = nil
function GData.setGamePId(gid)
	_gid = gid
end
function GData.getGamePId()
	assert(_gid, 'GData getGameId  is nil')
	return _gid
end

local _uClubId = -1
function GData.setUclubId(clubId)
	if not clubId then
		return
	end
	_uClubId = clubId
end
function GData.getUclubId()
	return _uClubId
end

--发牌2001可以结算
local _touchCard = false
function GData.setTouchTwoCard(isTouch)
	--true:显示玩家两张牌时候
	--false:2007动画结束
	_touchCard = isTouch
end
function GData.isTouchTwoCard()
	return _touchCard
end

--此房间有未处理的补充记分牌请求(仅房主有此字段)
local _haveUnhandledApply = nil
function GData.setHaveUnhandledApply(hua)
	_haveUnhandledApply = hua
end
function GData.getHaveUnhandledApply()
	return _haveUnhandledApply
end

--游戏是否已经结束
local _isOverGame = false
function GData.setGameOverStatus(gs)
	_isOverGame = gs
end
function GData.isGameOver()
	return _isOverGame
end

--设置购买保险中
local _insureBuying = false
function GData.setInsureBuying(isBuying)
	_insureBuying = isBuying
end
function GData.isInsureBuying()
	return _insureBuying
end
--ante
local _ante = 0
--开始1000、2200
function GData.setNowAnte(cante)
	if not cante then cante = 0 end
	_ante = cante
end
function GData.getNowAnte()
	return _ante
end


--sng相关的数据

--sng报名费
local _entryFee = 0
function GData.setSngEntryFee(seFee)
	_entryFee = seFee
end
function GData.getSngEntryFee()
	return _entryFee
end

--升盲时间
local _blindTime = 0
function GData.setUPBlindTime(btime)
	_blindTime = btime
end
function GData.getUPBlindTime()
	return _blindTime
end
function GData.getUPBlindMinute()
	return _blindTime / 60
end


--升盲剩余时间
local _upTime = 0
function GData.setUpblindSurplusTime(uptime)
	if tonumber(uptime) == 0 and not Single:gameModel():isStarting() then
		_upTime = 60
	else
		_upTime = uptime
	end
end
function GData.getUpblindSurplusTime()
	return _upTime
end



--mtt相关的数据

--mtt联盟俱乐部id
local _unionClubId = nil
function GData.setUnionClubId(ucId)
	_unionClubId = ucId
end
function GData.getUnionClubId()
	return _unionClubId
end

--报名费
local _mttEntryFee = 0
function GData.setMttEntryFee(seFee)
	_mttEntryFee = seFee
end
function GData.getMttEntryFee()
	return _mttEntryFee
end

--起式记分牌
local _mttScore = 0
function GData.setMttInitScore(initScore)
	_mttScore = initScore
end
function GData.getMttInitScore()
	return _mttScore
end

--增购是重购的倍数
local _mttBuyMul = 1.5
function GData.getMttBuyMul()
	return tonumber(_mttBuyMul)
end
function GData.setMttBuyMul(addMul)
	if addMul then
		_mttBuyMul = addMul
	end
end

--最大重购次数
local _mttMaxAgainTimes = 5
function GData.getMaxAgainTimes()
	return _mttMaxAgainTimes
end
function GData.getMaxAgainTimesText()
	--复活次数：无限 1/N、有限 1/6
	if _mttMaxAgainTimes == AGAIN_LIMITLESS then
		return 'N'
	end
	return _mttMaxAgainTimes
end
function GData.setMaxAgainTimes(maxAgainTimes)
	--无限重构
	if maxAgainTimes == -1 then
		_mttMaxAgainTimes = AGAIN_LIMITLESS
		return
	end
	_mttMaxAgainTimes = maxAgainTimes
end

--重购次数
local _mttAgainTimes = 5
function GData.setAgainTimes(againTimes)
	--已经重构次数
	_mttAgainTimes = againTimes
end
function GData.getAgainTimes()
	return tonumber(_mttAgainTimes)
end
function GData.subAgainTimes()
	--重构成功，重构次数+1
	_mttAgainTimes = _mttAgainTimes + 1
	if _mttAgainTimes > GData.getMaxAgainTimes() then
		_mttAgainTimes = GData.getMaxAgainTimes()
	end
end
function GData.getSurplusAgainTimes()
	local surplus = GData.getMaxAgainTimes() - _mttAgainTimes
	if surplus < 0 then
		return 0
	end
	return surplus
end

--最大增购次数
local _mttMaxAddTimes = 0
function GData.getMaxAddTimes()
	return _mttMaxAddTimes
end
function GData.setMaxAddTimes(maxAddTimes)
	_mttMaxAddTimes = maxAddTimes
end

--增购次数
local _mttAddTimes = 1
function GData.setAddTimes(addTimes)
	--已经增购的次数
	_mttAddTimes = addTimes
end
function GData.getAddTimes()
	return tonumber(_mttAddTimes)
end
function GData.subAddTimes()
	_mttAddTimes = _mttAddTimes + 1
	if _mttAddTimes > GData.getMaxAddTimes() then
		_mttAddTimes = GData.getMaxAddTimes()
	end
end
function GData.getSurplusAddTimes()
	local surplus = GData.getMaxAddTimes() - _mttAddTimes
	if surplus < 0 then
		return 0
	end
	return surplus
end

--是否可以增购
function GData.isAddOn()
	local havedAdd = GData.getAddTimes()
	local maxAdd = GData.getMaxAddTimes()
	--已经增购次数小于0，看客
	if havedAdd < 0 then return false end
	--最大增购次数小于等于0，没设置增购
	if maxAdd <= 0 then return false end
	--已经增购次数>=最大增购次数，不能增购了
	if havedAdd >= maxAdd then return false end

	--当前盲注级别==终止报名盲注级别了
	if GData.getNowBlindLevel() == GData.getOverBlindLevel() then
		return true
	end
end

--当前盲注级别
local _nowBlindLevel = 1
function GData.setNowBlindLevel(nbLevel)
	if not nbLevel then
		print('没有忙住级别啊啊 stack')
		return
	end
	_nowBlindLevel = nbLevel
end
function GData.getNowBlindLevel()
	return _nowBlindLevel
end
function GData.addNowBlindLevel()
	_nowBlindLevel = _nowBlindLevel + 1
end

--终止报名盲注级别
local _overBlindLevel = 1
function GData.setOverBlindLevel(obLevel)
	_overBlindLevel = obLevel
end
function GData.getOverBlindLevel()
	return _overBlindLevel
end

--mtt code
local _mttCode = 0
function GData.setMttCode(mttCode)
	_mttCode = mttCode
	if tonumber(mttCode) then
		_mttCode = tonumber(mttCode)
	end
end
function GData.getMttCode()
	return _mttCode
end

--mtt盲注表选择块、慢
local _blindNote = StatusCode.BLIND_SLOW
function GData.setBlindNote(blindTag)
	if blindTag then
		_blindNote = blindTag
	end
end
function GData.getBlindNote()
	return _blindNote
end

--mtt起始盲注级别
local _startBlind = 10
function GData.setStartBlind(startBlind)
	if startBlind then
		_startBlind = startBlind
	end
end
function GData.getStartBlind()
	return _startBlind
end


--得到mtt盲注表
function GData.getMttBlinds()
	return DZConfig.getBlindNote(GData.getBlindNote(), GData.getStartBlind())
end

--位置

--实施底池位置
local _nowPooly = 0
function GData.setNowPoolY(npy)
	_nowPooly = npy
end
function GData.getNowPoolY()
	return _nowPooly
end



--有效最低加注
local _availableRiseVal = 0
function GData.setAvailableRaiseVal(val)
	_availableRiseVal = val
end

function GData.getAvailableRaiseVal()
	return _availableRiseVal
end

--跟注值
local _followBetNum = 0
function GData.setMaxBetNum(val)
	_followBetNum = val
end

function GData.getMaxBetNum()
	return _followBetNum
end


--换桌面
local _menuBtn = 'game/game_menu.png'
local _deskImg = 'game/game_bg.png'
local _headImg = 'game/game_null.png'
local _headFont = cc.c3b(126,160,188)
local _timeColor = cc.c4b(114,142,162,255)
local _deskLight = 'game/game_downbg.png'
local _deskPrompt = 'game/game_waitbg.png'
local _deskFont = cc.c3b(22,59,92)

function GData.initGameDeskConf()
	local color = Storage.getDeskColor()

	if color == StatusCode.DESK_GREEN then
		_menuBtn = 'game/game_menu1.png'
		_deskImg = 'game/game_bg1.jpg'
		_headImg = 'game/game_null1.png'
		_headFont = cc.c3b(100,143,131)
		_timeColor = cc.c4b(255,255,255,255)

		_deskFont = cc.c3b(24,66,43)
		_deskLight = 'game/game_downbg1.png'
		_deskPrompt = 'game/game_waitbg1.png'
	elseif color == StatusCode.DESK_RED then
		_menuBtn = 'game/game_menu2.png'
		_deskImg = 'game/game_bg2.jpg'
		_headImg = 'game/game_null2.png'
		_headFont = cc.c3b(142,121,133)
		_timeColor = cc.c4b(255,255,255,255)

		_deskFont = cc.c3b(75,44,56)
		_deskLight = 'game/game_downbg2.png'
		_deskPrompt = 'game/game_waitbg2.png'
	elseif color == StatusCode.DESK_BLUE then
		_menuBtn = 'game/game_menu.png'
		_deskImg = 'game/game_bg.png'
		_headImg = 'game/game_null.png'
		_headFont = cc.c3b(126,160,188)
		_timeColor = cc.c4b(114,142,162,255)

		_deskFont = cc.c3b(22,59,92)
		_deskLight = 'game/game_downbg.png'
		_deskPrompt = 'game/game_waitbg.png'

	end
end

function GData.getMenuBtnImg()
	return _menuBtn
end
function GData.getDeskImg()
	return _deskImg
end
function GData.getHeadImg()
	return _headImg
end

--头像上空位|坐下字体颜色
function GData.getHeadFontColor()
	return _headFont
end
--牌局倒计时字体颜色
function GData.getCountTimeColor()
	return _timeColor
end
--桌下面两个灯颜色
function GData.getDeskLightImg()
	return _deskLight
end
--提示用户点击坐下颜色
function GData.getPromptImg()
	return _deskPrompt
end
function GData.getDeskFontCol()
	return _deskFont
end





--返回大盲和小盲位置
local _noSeat = -100
function GData.getBigSmallBlindSeat(susers, limitNum)
	if not susers or #susers == 0 then return _noSeat,_noSeat end
	if #susers == 1 then return _noSeat,_noSeat end

	local dealer = _noSeat
	local dic = {}
	for i=1,#susers do
		local tuser = susers[ i ]
		local seatNum = tuser['seatNum']

		if tuser['isDealer'] then
			dealer = seatNum
		end

		local isGaming = GJust.isGamingByStatus(tuser['status'])
		if isGaming then
			dic[ seatNum ] = true
		end
	end

	--只要有庄dic数量一定大于等于2
	if dealer == _noSeat then return _noSeat,_noSeat end

	local big = _noSeat
	local small = _noSeat
	local idx = dealer

	--规则：庄的下家是小盲，小盲的下家是大盲。只有两个人规则不一样
	while true do
		idx = idx + 1
		if idx > limitNum then
			idx = 1
		end

		if dic[ idx ] then
			if small == _noSeat then
				small = idx
			elseif big == _noSeat then
				big = idx
				break
			end
		end

		if idx == dealer then
			break
		end
	end

	--两个人规则不一样
	if dealer == big then
		return small,big
	end

	return big,small
end



--====test
local _tmpMTTCode = "12"
function GData.setTMPMTTCode(mcode)
	_tmpMTTCode = mcode
end
function GData.getTMPMTTCode()
	return _tmpMTTCode
end


function GData.get1000()
	local jsonStr = '{"roomName":"中午场-100元话费赛","roomRongyunId":"gaming_mtt_14081_1486445402073","joinCode":434188,"bigBlind":800,"limitPlayers":9,"gameMode":"53","isInRoom":true,"isManager":false,"isStart":true,"thinkTime":15,"insureTime":25,"cuoTime":25,"isPause":false,"ante":100,"raiseBlindSurplusTime":5,"entryFee":200,"raiseBlindTime":120,"mtt":{"overLevel":12,"blindLevel":8,"repurchaseMaxNum":10,"addMaxNum":1,"initScore":10000,"restType":-1,"restTime":0,"deskTag":-1,"mttRank":30,"repurchaseNum":0,"addNum":0},"poolBet":4600,"roundPoolBet":[4600],"poolCard":[24,39,17],"dealerSeatNum":5,"smallBlindSeatNum":6,"bigBlindSeatNum":7,"beforeTalkBet":1800,"diamonds":0,"addTimePrice":{"thinking":0,"insuranceThinking":0,"cuo":0},"addThinkTimePrice":0,"users":[{"userId":"967","rongyunId":"0.659549001479884289","userName":"那一年的我","headUrl":"0.432689001486311518809423.jpg","surplusNum":109844,"seatNum":2,"status":6,"isAuto":false,"isDealer":false,"betNum":0},{"userId":"1192","rongyunId":"0.399373001486207492","userName":"吉A","headUrl":"","surplusNum":8850,"seatNum":5,"status":0,"isAuto":true,"isDealer":true,"betNum":0},{"userId":"1197","rongyunId":"0.273631001486210801","userName":"黑皮","headUrl":"0.686818001486353094916587.jpg","surplusNum":10181,"seatNum":6,"status":5,"isAuto":false,"isDealer":false,"betNum":0,"surplusThinkingTime":15},{"userId":"1199","rongyunId":"0.169489001486212227","userName":"大眼","headUrl":"","surplusNum":8325,"seatNum":7,"status":6,"isAuto":true,"isDealer":false,"betNum":0,"cards":[15,12]},{"userId":"1231","rongyunId":"0.954504001486266682","userName":"乙丙橡胶","headUrl":"0.351136001486266777368751.jpg","surplusNum":9100,"seatNum":9,"status":6,"isAuto":false,"isDealer":false,"betNum":0},{"userId":"1272","rongyunId":"0.096138001486297573","userName":"榮少","headUrl":"0.503933001486385829812839.jpg","surplusNum":9100,"seatNum":3,"status":6,"isAuto":false,"isDealer":false,"betNum":0},{"userId":"963","rongyunId":"0.813656001479883022","userName":"可乐","headUrl":"0.037414001479883102104131.jpg","surplusNum":10000,"seatNum":1,"status":7,"isAuto":false},{"userId":"1190","rongyunId":"0.188869001486206979","userName":"海洋","headUrl":"0.438627001486207007787439.jpg","surplusNum":10000,"seatNum":8,"status":7,"isAuto":false}],"result":1,"protocolNum":1000}'
	local tabData = json.decode(jsonStr, 1)
	return tabData
end

function GData.sendBro2000()
	local jsonStr = '{"userId":"819","rongyunId":"0.994451001475748434","userName":"leo","headUrl":"0.679530001476453771340173.jpg","surplusNum":10000,"seatNum":4,"status":7,"isAuto":false,"protocolNum":2000}'
	local tabData = json.decode(jsonStr, 1)
	local BroCtrol = require 'game.BroCtrol'
	BroCtrol.sendBro(tabData)
	-- GAnimation.pushData(tabData)
end

function GData.sendBro2001()
	local jsonStr = ""
	local tabData = json.decode(jsonStr, 1)
	local BroCtrol = require 'game.BroCtrol'
	BroCtrol.sendBro(tabData)
end

function GData.sendBro2032()
	local data = {}
	data['protocolNum'] = 2032
	data['round'] = 3
	data['name'] = '2032'
	data['newCards'] = {4}
	local BroCtrol = require 'game.BroCtrol'
	BroCtrol.sendBro(data)
end


function GData.testData()
	local PokerType = require 'game.PokerType'
	-- local test = {39, 13, 21, 8, 40, 3, 27}
	local test = {49, 13, 47, 24, 22, 46, 51}
	print_f(PokerType.change_china(test))
    local text,array = PokerType.get_poker_type(test)
    print('=============')
    print(text)
    print_f(array)
	print_f(PokerType.change_china(array))
end

return GData