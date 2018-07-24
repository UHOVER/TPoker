local ViewBase = require 'ui.ViewBase'
local GameLayer = class("GameLayer", ViewBase)
local _gameLayer = nil
local _gameCS = nil
local _voiceBtn = nil
local LIGHT_TAG = 'LIGHT_TAG'
local _poolPokerNode = nil

--实时显示底池、实时显示底池bg
local _nowPoolBet = nil
local _nowPoolBetBg = nil
local _roundNode = nil

--1.标准游戏没有开始 提示开始游戏(房主：点击开始、非房主：等待房主开始)
--2.标准玩家没有坐下 提示玩家坐下
--3.标准开启授权带入 提示授权倒计时(授权等待中提示授权倒计时、授权处理过了核查是否通过了给出相应提示)
--4.sng和mtt不应该有提示
local function updatePrompt()
	local tmsg = GText.promptMsg()
	_gameCS:getChildByName('ttfPromptMsg'):setString(tmsg)
	if tmsg == '' then
		_gameCS:getChildByName('ttfPromptBg'):setOpacity(0)
	else
		_gameCS:getChildByName('ttfPromptBg'):setOpacity(255)
	end
end


local function getPromptTtfs()
	local ttbase = _gameCS:getChildByName('ttfBase')
	local function getObj(name)
		return ttbase:getChildByName(name)
	end
	local ttfs = {
		getObj('ttfPrompt1'), getObj('ttfPrompt2'), getObj('ttfPrompt3'), getObj('ttfPrompt4'), 
		getObj('ttfPrompt5'), getObj('ttfPrompt6'), getObj('ttfPrompt7'), getObj('ttfPrompt8'),
		getObj('ttfPrompt9')
	}

	return ttfs
end


--btn
local function handleApplay()
	ViewCtrol.showApplyList(nil)
end

local function handleMenu(event)
	DiffType.diffMenuBtn()
end

local function handlePoker(event)
	local GReview = require 'game.GReview'
	GReview.showReview()
end

local function handleStart(event)
	SocketCtrol.startGame(function()
		_gameCS:getChildByName('startBtn'):setVisible(false)
		updatePrompt()
	end)
end

local function handlePencil(event)
	local GFighting = require 'game.GFighting'
	GFighting.shwoFight()
end

local function handleEmoji(evento)
	if not GSelfData.isHavedSeat() then
		ViewCtrol.showMsg('请先坐下')
		return
	end

	local function touchBack(idx, imgName)
		local tx,ty = _gameCS:getChildByName('emojiBtn'):getPosition()
		local anis = GUI.showEmoji(cc.p(tx,ty), _gameCS, idx)
		anis:setAnchorPoint(1,0)
	end
	GWindow.showEmoji(touchBack)
end

local function handleLookPoker(sender)
	SocketCtrol.lookPoolPoker(function()end)
end
--选中straddle
local function handleStraddle(sender)
	--straddle 界面变化
	local function response(data)
		local code = data["code"]
		if code ~= 0 then 
			print("是否更新一炮")
		end
	end
	sender:setEnabled(false)
	sender:setColor(cc.c3b(77,77,77))
	SocketCtrol.sendIsStraddle(Single:playerModel():getId(), response)
end
--mtt add on
local function handleAddOn(sender)
	local function response(data)
	end
	SocketCtrol.mttBuyScore(2, response)
end

--暂停
local _stopActions = {}
function GameLayer:stopGameLayer()
	local ispause = Single:gameModel():isPause()
	local tpause = Single:gameModel():getPauseTime()
	print(tostring(ispause).." stopGameLayer "..tostring(tpause))
	if ispause then
		_stopActions = cc.Director:getInstance():getActionManager():pauseAllRunningActions()
		local order = GMath.getMaxZOrder() - 2
		local gw = GWindow.showPause(_gameCS, tpause, order)
		gw:setName('STOP_LAYER')
	end
end
function GameLayer:goOnGameLayer()
	local gw = _gameCS:getChildByName('STOP_LAYER')
	if gw then
	    cc.Director:getInstance():getActionManager():resumeTargets(_stopActions)
		_stopActions = {}
		gw:removeFromParent()
		gw = nil
	end
end
function GameLayer:removeStopLayer()
	local gw = _gameCS:getChildByName('STOP_LAYER')
	if gw then
		gw:removeFromParent()
	end
end


function GameLayer:removePoolPoker()
	local mecards = SelfLayer.getMeCards()
	for i=1,#mecards do
		if mecards[i]:getChildByName(LIGHT_TAG) then
			mecards[i]:getChildByName(LIGHT_TAG):removeFromParent()
		end
	end

	for i=1,#self._imgPokers do
		self._imgPokers[ i ]:removeFromParent()
	end
	self._imgPokers = {}
end


--申请授权提示
function GameLayer:applayPrompt(ptime)
	if _gameCS:getChildByName('APPLAY_PROMPT') then
		return
	end
	local ttime = ptime
	local ttext = '请求房主带入同意中\n     请等待'..ttime..'s...'

	local function scheduleApplay()
		ttime = ttime - 1
		ttext = '请求房主带入同意中\n     请等待'..ttime..'s...'
		_gameCS:getChildByName('ttfPromptMsg'):setString(ttext)
		if ttime <= 1 then 
			ttime = 1 
		end
	end
	local tnode = cc.Node:create()
	tnode:setName('APPLAY_PROMPT')
	_gameCS:addChild(tnode)
	DZSchedule.runSchedule(scheduleApplay, 1, tnode)

	_gameCS:getChildByName('ttfPromptMsg'):setString(ttext)
	_gameCS:getChildByName('ttfPromptBg'):setOpacity(255)
end
function GameLayer:removeApplayPrompt()
	if _gameCS:getChildByName('APPLAY_PROMPT') then
		_gameCS:getChildByName('APPLAY_PROMPT'):removeFromParent()
	end
	_gameCS:getChildByName('ttfPromptMsg'):setString('')
	_gameCS:getChildByName('ttfPromptBg'):setOpacity(255)

	updatePrompt()
end


--hide、dis
function GameLayer:hideNowPoolBet()
	_nowPoolBet:setVisible(false)
	_nowPoolBetBg:setVisible(false)
end

function GameLayer:disNowPoolBet()
	local value = self:getModel():getPoolNowBet()
	if not value then return end

	local pnum = GMath.changeNumKW(value)
	_nowPoolBetBg:setVisible(true)
	_nowPoolBet:setVisible(true)
	_nowPoolBet:setString('底池:'..pnum)
end

function GameLayer:hideRoundPoolBet()
	_gameCS:getChildByName('imgPoolBetBg'):setVisible(false)
	_gameCS:getChildByName('GameBetTtf'):setVisible(false)
end
function GameLayer:disRoundPoolBet()
	local values = self:getModel():getRoundPoolBet()
	if #values == 0 or not values then return end

	--不分池
	if #values == 1 then
		_gameCS:getChildByName('imgPoolBetBg'):setVisible(true)
		_gameCS:getChildByName('GameBetTtf'):setVisible(true)

		local rnum = GMath.changeNumKW(values[1])
		_gameCS:getChildByName('GameBetTtf'):setString(rnum)
	else
		_gameCS:getChildByName('imgPoolBetBg'):setVisible(false)
		_gameCS:getChildByName('GameBetTtf'):setVisible(false)
		local nodePool = _gameCS:getChildByName('nodePool')
		GameHelp.manyPool(nodePool, _nowPoolBetBg, values)
	end
end

function GameLayer:hidePokerType()
	_gameCS:getChildByName('GameTypeTtf'):setVisible(false)
end
function GameLayer:disPokerType(value)
	_gameCS:getChildByName('GameTypeTtf'):setVisible(true)
	_gameCS:getChildByName('GameTypeTtf'):setString(value)
end

--标准没有补充记分牌、sng和mtt没有申请入局的了
function GameLayer:hideMsgPrompt()
	_gameCS:getChildByName('applayBtn'):setAnchorPoint(0,0.5)
end
function GameLayer:disMsgPrompt()
	-- if self:getModel():isManager() then
		-- _gameCS:getChildByName('applayBtn'):setAnchorPoint(1,0.5)
	-- end
end


--更新牌局提示信息
function GameLayer:updatePokerMsg()
	-- local ttbase = _gameCS:getChildByName('ttfBase')
	-- local function getObj(name)
	-- 	return ttbase:getChildByName(name)
	-- end
	
	-- local ttfs = {
	-- 	getObj('ttfPrompt1'), getObj('ttfPrompt2'), getObj('ttfPrompt3'), getObj('ttfPrompt4'), 
	-- 	getObj('ttfPrompt5'), getObj('ttfPrompt6'), getObj('ttfPrompt7'), getObj('ttfPrompt8'),
	-- 	getObj('ttfPrompt9')
	-- }	

	local pokerMsg = GText.getPokerMsg()
	local ttfs = getPromptTtfs()
	if #ttfs ~= #pokerMsg then return end
	
	GUI.setStudioFontBold(ttfs)
	local posy = GMath.getPokerMsgPos(#ttfs)

	for i=1,#ttfs do
		local obj = ttfs[ i ]
		local msg = pokerMsg[ i ]
		obj:setString(msg['msgText'])
		obj:setPositionY(posy[ i ])
	end
end
--开启授权、盲注、牌局名等
function GameLayer:promptChangeAuthorize()
	local text = GText.authorizeText()
	GText.setPokerMsg(StatusCode.PROMPT_AUTHOR, text)
	self:updatePokerMsg()
end
--更新盲注提示文字
function GameLayer:promptUPBlind(bigBlind)
	--更新盲注显示
	GText.setPokerMsg(StatusCode.PROMPT_BLIND, bigBlind)
	self:updatePokerMsg()
end
--提示ANTE改变
function GameLayer:promptChangeANTE(ante)
	GText.setPokerMsg(StatusCode.PROMPT_ANTE, ante)
	self:updatePokerMsg()
end
--提示straddle改变
function GameLayer:promptStraddle()
	GText.setPokerMsg(StatusCode.PROMPT_STRADDLE, '')
	self:updatePokerMsg()
end


--牌型高亮提示
function GameLayer:disPokerHighlight(typePokers)
	local mecards = SelfLayer.getMeCards()
	local tcards = StringUtils.linkArrayNew(self._imgPokers, mecards)

	for i=1,#typePokers do
		for j=#tcards,1,-1 do
			local imgp = tcards[ j ]
			if imgp:getChildByName(LIGHT_TAG) then
				imgp:getChildByName(LIGHT_TAG):removeFromParent()
			end

			if typePokers[ i ] == imgp:getTag() then
				table.remove(tcards, j)
				local typeTag = UIUtil.addPosSprite(ResLib.COM_POKER_LIGHT, cc.p(64,74.5), imgp, nil)
				typeTag:setScaleY(0.88)
				typeTag:setScaleX(0.89)
				typeTag:setName(LIGHT_TAG)
				-- break 高亮标示有时候移除不掉
			end
		end
	end
end

function GameLayer:disPoolCards(newPokers, endBack, opacityVal)
	local tstart = #self._imgPokers + 1
	local disarr = {}
	local posarr = {}
	local tscale = 0.7
	local pooly = GMath.getPoolCardPercentY(POKER_Y_POKER)

	for i=1,#newPokers do
		local tp = cc.p(28 + (tstart - 1) * 11, pooly)--54
		-- local imgp = UIUtil.addSprite(DZConfig.cardName(newPokers[ i ]), tp, _gameCS, nil)
		--底池出错超过5
		if #self._imgPokers >= 5 then
			local explain = ''
			for kk=1,#newPokers do
				explain = explain..'  '..newPokers[kk]
			end
			Single:checkGameData('GameLayer:disPoolCards  '..explain)
			break
		end

		local imgp = UIUtil.addSprite(DZConfig.cardName(newPokers[ i ]), tp, _poolPokerNode, nil)
		imgp:setTag(newPokers[ i ])
		imgp:setScale(tscale)
		imgp:setLocalZOrder(i)

		table.insert(self._imgPokers, imgp)
		table.insert(disarr, imgp)
		table.insert(posarr, tp)
		tstart = tstart + 1
	end

	GUI.poolPokers(disarr, posarr, tscale, endBack, opacityVal)
end


function GameLayer:movePoolBet(imgBet, dir, endBack)
	local tx1,ty1 = imgBet:getPosition()
	local tx2,ty2 = _gameCS:getChildByName('imgPoolBetBg'):getPosition()
	local fpos = imgBet:getParent():convertToWorldSpace(cc.p(tx1,ty1))
	local tpos = _gameCS:convertToWorldSpace(cc.p(tx2,ty2))

	if dir == StatusCode.BET_TO_POOL then
		GUI.runMoveBet(fpos, tpos, 0.4, _gameCS, endBack)
	elseif dir == StatusCode.POOL_TO_WIN then
		GUI.runMoveBet(tpos, fpos, 0.4, _gameCS, endBack)
	end
end


--更新界面显示：断网、刚进来
function GameLayer:handleDisplay()
	local gm = self:getModel()

	--牌局剩余时间
	DiffType.countTime(_gameCS)
	--开始按钮
	_gameCS:getChildByName('startBtn'):setVisible(GJust.isDisStart())
	--提示
	updatePrompt()
	--牌池()
	self:removePoolPoker()
	--底池回合押注
	self:disRoundPoolBet()
	--底池当前押注
	self:disNowPoolBet()

	local cards = gm:getPoolCard()
	if cards and #cards ~= 0 then
		self:disPoolCards(cards)
	end

	--牌型高亮(必须有牌)
	if #gm:getMeAllCards() > 1 then
		local text,pokers = gm:getCardsType()
		self:disPokerHighlight(pokers)
		self:disPokerType(text)
	end

	--房主暂停，暂停时候暂停界面
	
	self:removeStopLayer()
	DZAction.delateTime(self, 0.2, function()
		self:stopGameLayer()
	end)

	--授权带入
	if GData.getHaveUnhandledApply() then
		-- _gameCS:getChildByName('applayBtn'):setAnchorPoint(1,0.5)
		NewMsgMgr.setNewMsgTrue()
	end

	--sng
	DiffType.broDiffLayer(_gameCS)
end

local function initDeskColor()
	_gameCS:getChildByName('bg'):setTexture( GData.getDeskImg() )
	_gameCS:getChildByName('menuImg'):setTexture( GData.getMenuBtnImg() )
	_gameCS:getChildByName('ttfGameTime'):setTextColor( GData.getCountTimeColor() )

	_gameCS:getChildByName('game_downbg'):setTexture( GData.getDeskLightImg() )
	_gameCS:getChildByName('ttfPromptBg'):setTexture( GData.getPromptImg() )

	local ttfs = getPromptTtfs()
	local pColor = GData.getDeskFontCol()
	for i=1,#ttfs do
		ttfs[ i ]:setTextColor( pColor )
	end
end

function GameLayer:createLayer()
	GData.initGameDeskConf()

	require("main.AllGame"):rebackScreen()
	--2003发牌、2001给玩家发牌清空
	self._imgPokers = {}

	UIUtil.setBgScale(ResLib.GAME_BG, display.center, self)	
	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.GAME_CSB)
	self:addChild(cs)
	_gameCS = cs

	_nowPoolBetBg = cs:getChildByName('game_poolbg')
	_nowPoolBet = _nowPoolBetBg:getChildByName('GamePoolBetTtf')

	cs:getChildByName('menuBtn'):touchSoundEnded(handleMenu)
	cs:getChildByName('pokerBtn'):touchSoundEnded(handlePoker)
	cs:getChildByName('startBtn'):touchEnded(handleStart)
	cs:getChildByName('pencilBtn'):touchSoundEnded(handlePencil)
	cs:getChildByName('emojiBtn'):touchEnded(handleEmoji)
	cs:getChildByName('applayBtn'):touchEnded(handleApplay)
	cs:getChildByName('btnLookPool'):touchEnded(handleLookPoker)
	--btnStraddle 处理监听
	cs:getChildByName('btnStraddle'):touchEnded(handleStraddle)
	cs:getChildByName('btnAddOn'):touchEnded(handleAddOn)

	local tcode = self:getModel():getShareCode()
	local gname = self:getModel():getGameName()
	local ttfGameTime = _gameCS:getChildByName('ttfGameTime')
	ttfGameTime:setString('')
	_gameCS:getChildByName('ttfPromptMsg'):setString('')
	_gameCS:getChildByName('ttfPromptBg'):setOpacity(0)


	self:hideRoundPoolBet()
	self:hideNowPoolBet()
	self:hidePokerType()

	self:updatePokerMsg()

	_gameCS:getChildByName('imgVoicePrompt'):setOpacity(0)
	_voiceBtn = nil
	self:updateVoiceStatus()

	_roundNode = cc.Node:create()
	self:addChild(_roundNode)

	_poolPokerNode = cc.Node:create()
	_gameCS:addChild(_poolPokerNode)

	--set order  voice btn ZOrder
	local morder = GMath.getMaxZOrder()
	_gameCS:getChildByName('menuBtn'):setLocalZOrder(morder)
	_gameCS:getChildByName('pokerBtn'):setLocalZOrder(morder)
	_gameCS:getChildByName('pencilBtn'):setLocalZOrder(morder)
	_gameCS:getChildByName('emojiBtn'):setLocalZOrder(morder)
	_gameCS:getChildByName('btnVoice'):setLocalZOrder(morder)
	ttfGameTime:setLocalZOrder(morder)


	local function getObj(oname)
		return _gameCS:getChildByName(oname)
	end

	--适配
	local arrs = {}
	local arr1 = {getObj('imgPoolBetBg'), getObj('GameBetTtf'), _nowPoolBetBg}
	local arr2 = {getObj('ttfPromptBg'), getObj('ttfPromptMsg'), getObj('linePromptBg')}
	local arr3 = {getObj('startBtn')}

	table.insert(arrs, arr1)
	table.insert(arrs, arr2)
	table.insert(arrs, arr3)
	
	GMath.gameAdaptation(arrs)

	DiffType.initDiffLayer(_gameCS)

	--设置字体
	local ttfs1 = {ttfGameTime}
	GUI.setStudioFontBold(ttfs1)
	local ttfs2 = {getObj('GameTypeTtf'), getObj('GameBetTtf'),_nowPoolBet, getObj('ttfPromptMsg'), getObj('ttfMttStart')}
	GUI.setStudioFontBold(ttfs2)

	--设置位置
	GData.setNowPoolY(_nowPoolBetBg:getPositionY())


	initDeskColor()

	return cs
end



--mtt拆桌合桌提示
function GameLayer:disDeskPrompt(text)
	local deskPrompt = _gameCS:getChildByName('deskPrompt')
	deskPrompt:setPositionX(display.cx)
	deskPrompt:getChildByName('ttfLine'):setString(text)
end

function GameLayer:removeStartGame()
	local tx = -display.cx
	_gameCS:getChildByName('deskPrompt'):setPositionX(tx)
	local startText = _gameCS:getChildByName('ttfMttStart')
	startText:setPositionX(tx)
	startText:stopAllActions()
end

function GameLayer:updteLayerPrompt()
	updatePrompt()
end

--发发看提示
function GameLayer:lookPoker(name, roundNum)
	GUI.lookPokerPrompt(name, roundNum, _roundNode)
	if roundNum >= StatusCode.GAME_ROUND3 then 
		_gameCS:getChildByName('btnLookPool'):setPositionX(935)
	else 
		self:disLookPoolPoker()
	end
end

--显示发发看
function GameLayer:disLookPoolPoker()
	local btnLook = _gameCS:getChildByName('btnLookPool')
	local nameImg = btnLook:getChildByName('ttfRoundName')
	nameImg:setTexture(DiffType.switchLookPookBtn())
	btnLook:setPositionX(734)
end

--显示Straddle
function GameLayer:disStraddleOpt(hasStraddle)
	print("显示disStraddleOpt")
	local btn = _gameCS:getChildByName('btnStraddle')
	btn:setColor(cc.c3b(255,255,255))
	btn:setPositionX(16)

	if not hasStraddle then  --如果是空 or 没选中
		btn:setColor(cc.c3b(255,255,255))
		btn:setEnabled(true)
	else
		btn:setColor(cc.c3b(77,77,77))
		btn:setEnabled(false)
	end
end

function GameLayer:hideStraddleOpt()
	print("隐藏hideStraddleOpt")
	_gameCS:getChildByName('btnStraddle'):setPositionX(-172)
end

function GameLayer:clearRoundGameLayer()
	_roundNode:removeAllChildren()

	--removePoolPoker冲突
	_poolPokerNode:removeAllChildren()
	self._imgPokers = {}
	self:hideStraddleOpt()
	--发发看
	_gameCS:getChildByName('btnLookPool'):setPositionX(935)

	self:removePoolPoker()
	self:disNowPoolBet()
	self:disPokerType('')

	--恢复分池产生的位置移动
	_gameCS:getChildByName('nodePool'):setPositionX(display.height * 1.5)
	_nowPoolBetBg:setPositionY(GData.getNowPoolY())
end

--牌局开始倒计时
function GameLayer:mttCountDown(time)
	GUI.mttStartCountDown(_gameCS:getChildByName('imgCountDown'), time, function()
		local startText = _gameCS:getChildByName('ttfMttStart')
		startText:setPositionX(display.cx)
		DZAction.scale(startText, cc.p(0.6,0.6), cc.p(1.4,1.4), 2, true, nil)	
	end)
end

--中场或决赛休息
function GameLayer:disMttRest(time, text)
	GUI.mttRestCountDown(text, time, _gameCS:getChildByName('imgCountDown'))
end
--移除中场或决赛休息提示
function GameLayer:removeMttRest()
	_gameCS:getChildByName('imgCountDown'):setPositionX(-375)
	_gameCS:getChildByName('imgCountDown'):removeAllChildren()
end

function GameLayer:disMttRank(rankNum)
	if not _gameCS then 
		return
	end
	local imgRank = _gameCS:getChildByName('imgRank')
	imgRank:setPositionX(750)
	local imgs = {'ui_rank1.png', 'ui_rank2.png', 'ui_rank3.png'}
	local texts = {'一', '二', '三', '四', '五', '六', '七', '八', '九', '十'}
	local textNum = rankNum
	if rankNum < 11 then
		textNum = texts[ rankNum ]
	end

	local ttfRankNum = imgRank:getChildByName('ttfRankNum')
	if rankNum < 4 then
		imgRank:setTexture('ui/'..imgs[rankNum])
		ttfRankNum:setPosition(75,29)
	else
		imgRank:setTexture('ui/ui_rankbg.png')
		ttfRankNum:setPosition(58,26)
	end
	ttfRankNum:setString('第'..textNum..'名')
end

function GameLayer:removeMttRank()
	_gameCS:getChildByName('imgRank'):setPositionX(950)
end

--显示或隐藏增购标示
function GameLayer:disAddOn()
	if GData.isAddOn() then
		_gameCS:getChildByName('btnAddOn'):setPositionX(675)
	else
		_gameCS:getChildByName('btnAddOn'):setPositionX(950)
	end
end
function GameLayer:hideAddOn()
	_gameCS:getChildByName('btnAddOn'):setPositionX(950)
end

----------------------------------------------------------
----------------------------------------------------------
function GameLayer:setDealGroupVisible(isShow)
	--tanhaiting,这里显示牌堆
	if self.givePokerNode == nil then 
		self.givePokerNode = cc.Node:create()
		self:addChild(self.givePokerNode, GMath.getMaxZOrder() - 3)
	end

	self.givePokerNode:removeAllChildren()
	if isShow then 
		local card = display.newSprite("gambling/com_cardbg.png")
		card:setPosition(display.center)
		card:setLocalZOrder(GMath.getMaxZOrder() - 3)
		self.givePokerNode:addChild(card)
		card:setScaleX(24/card:getContentSize().width)
		card:setScaleY(34/card:getContentSize().height)
	else 
	end
end

function GameLayer:dealPokerToUser(pos, interval, callback)
	local card = display.newSprite("gambling/com_cardbg.png")
	card:setPosition(display.center)
	card:setLocalZOrder(GMath.getMaxZOrder() - 3)
	self.givePokerNode:addChild(card)
	card:setScaleX(24/card:getContentSize().width)
	card:setScaleY(34/card:getContentSize().height)
	pos = cc.p(pos.x, pos.y - 34)
	local delayTime = cc.DelayTime:create(interval)
	local moveTo = cc.MoveTo:create(0.2, pos)
	-- local easeInMove = cc.EaseIn:create(moveTo, 2.5)
	local rotateTo = cc.RotateTo:create(0.2, -105)
	local callHandler = cc.CallFunc:create(function() 
			print("移除 card"..interval)
			card:removeFromParent()
			callback()
		end)
	local spawnAction = cc.Spawn:create(moveTo, rotateTo)
	local seq = cc.Sequence:create(delayTime, spawnAction, callHandler)
	card:runAction(seq)
end


----------------------------------------------
--更新语音显示
function GameLayer:updateVoiceStatus()
	local isClose = Storage.getIsCloseVoice()

	if isClose then
		DZPlaySound.setGameQuiet(true)
	else
		DZPlaySound.setGameQuiet(false)
	end

	if isClose and _voiceBtn then
		_voiceBtn:removeFromParent()
		_voiceBtn = nil
		_gameCS:getChildByName('btnVoice'):setVisible(false)
	elseif isClose == false and _voiceBtn == nil then
		_gameCS:getChildByName('btnVoice'):setVisible(true)
		_voiceBtn = GameHelp.handleVoice(_gameCS)
	end
end

--播放语音
--
function GameLayer:playerVoice(pid, vtime)
	if _gameLayer == nil then return end

	local seats = Single:playerManager():getSeatPlayers()
	for i=1,#seats do
		if pid == seats[i]:getUId() then
			seats[i]:disVoice(vtime)
			return
		end
	end

	local um = UserCtrol.getStandUserById(pid)
	if um then
		GameHelp.personVoice(_gameCS, um:getUserName(), vtime)
	end
end

function GameLayer:getInstance()
	local function onEvent(event)
		if event == "exit" then
			_gameLayer = nil
		end
	end

	if _gameLayer == nil then
		_gameLayer = GameLayer:create()
		_gameLayer:registerScriptHandler(onEvent)
	end

	return _gameLayer
end

function GameLayer:clearGameLayer()
	_gameCS:removeFromParent()
	_gameLayer:removeFromParent()
	_gameLayer = nil
	_gameCS = nil

end

function GameLayer:getModel()
	return Single:gameModel()
end

function GameLayer:ctor()
end
--显示进入保险模式的动画
function GameLayer:showInsuranceMode(back)
 	GUI.showInsuranceMode("insurance/InsuranceMode.png", self, back)
end

--获取保险的view
function GameLayer:getInsurancePanel()
	local insuranceNode = _gameCS:getChildByName("InsuranceView")
	return insuranceNode
end

function GameLayer:showInsurancePanel(node)
	if (node == nil) or node:getParent()then 
		do return end
	end
	node:setName("InsuranceView")
	node:setLocalZOrder(GMath.getMaxZOrder() - 3)
	_gameCS:addChild(node)
end
--显示xxx购买了保险的通知
function GameLayer:showPurchaseResult(data, back)
   local selectSeatNum = data.selectSeatNum
   local selectType = data.selectType
   
   local outs 		= data.outs or {}
   local amount 	= data.amount or 0
   local oddsVal 	= DZConfig.getOddsValue(#outs)
   local conpensate =  oddsVal * amount
   local text = nil
   local user = UserCtrol.getSeatUserByPos(selectSeatNum)
   local userName = user and user:getUserName()
   if GSelfData.isHavedSeat() then
   	  local curUserpos = GSelfData:getSelfModel():getSeatNum()
   	  if curUserpos == selectSeatNum then  
   	  	 userName = "我~~"
   	  end
   end
   local text, text2 = "", ""
   local tb = nil 
   if selectType == 1 then 
   	  text = string.format("已购买%d张OUTS，保险费：%d",#outs,amount)
   	  text2 = string.format("预计赔付%d", conpensate)
   	  tb = {userName, text, text2}
   else 
   	  text = string.format("放弃了购买保险", userName)
   	  tb = {userName, text}
   end
	GUI.showHorizontalHint(tb, back) 
end
--显示保险是否买中的弹窗
function GameLayer:showInsureSetltement(data, back)
	local text = nil
	local isHit = data['isHit']
	local compensate = data['compensation'] or -1
	local selectSeatNum = data['insureSeatNum'] 
	local user = UserCtrol.getSeatUserByPos(selectSeatNum)
	local userName = user and user:getUserName()
    if GSelfData.isHavedSeat() then
    	local selfSeatNum = GSelfData.getSelfModel():getSeatNum()
    	if selfSeatNum == selectSeatNum then  --当前用户坐下并且买中保险
    		userName = "我~~"
    	end
    end
    local text = ""
    if isHit then 
		text = "购买保险中，赔付记分牌："..compensate
	else 
		text = "未买中保险，结算时将扣除保险费"
	end
	GUI.showHorizontalHint({userName, text}, back)
end


--更新桌面
function GameLayer:changeDeskImg(deskImg, menuImg, timeColor)
	initDeskColor()
end


return GameLayer