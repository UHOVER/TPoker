local SelfLayer = {}
local _layer = nil
local _csl = nil
local _ctrolBtn = nil
local _self = nil
local _isAutoGiveup = false
local _isAutoLook = false
local _isAutoFollow = false
local _isLook = false
local _statusOne = StatusCode.POKER_NO_SHOW
local _statusTwo = StatusCode.POKER_NO_SHOW
local _isTouchPoker = false
local _removeNode = nil
local _headPos = cc.p(display.cx, 235)
local _befFollowBet = 0

local _insturanceLayer = nil
local CARD_ONEBG_NAME = 'CARD_ONEBG_NAME'
local CARD_TWOBG_NAME = 'CARD_TWOBG_NAME'

local function netSelectType(ctype, betNum)
	transition.stopTarget(_self._lcircle)
	transition.stopTarget(_self._gcircle)
	transition.stopTarget(_self._lparticle)
	transition.stopTarget(_self._gparticle)

	DZAction.delateShield(0.5)
	DZAction.delateTime(_csl, 0.3, function()
		_self:hideSaid()
	end)

	local function response()
	end

	DZPlaySound.stopClock()
	SocketCtrol.selectBet(ctype, betNum, response)
end

--btn
local function updateBet(betNum)
	netSelectType(StatusCode.GAME_ADD, betNum)
end

local function handleGiveup()
	local function giveupBack()
		if GSelfData.getSelfModel() then
			netSelectType(StatusCode.GAME_GIVEUP, 0)
		end
	end
	local function lookBack()
		if GSelfData.getSelfModel() then
			netSelectType(StatusCode.GAME_LOOK, 0)
		end
	end
	local function closeBack()
		if GSelfData.getSelfModel() then 
			_self:disSaidKeep()
		end
	end

	if _isLook then
		GWindow.showPrompt(giveupBack, lookBack, closeBack)
	else
		giveupBack()
	end
end
local function handleFollow()
	netSelectType(StatusCode.GAME_FOLLOW, 0)
end
local function handleLook()
	netSelectType(StatusCode.GAME_LOOK, 0)
end
local function handlePoolOne()
	netSelectType(StatusCode.GAME_ADD_11, 0)
end
local function handlePoolOneTwo()
	netSelectType(StatusCode.GAME_ADD_12, 0)
end
local function handlePoolTwoThree()
	netSelectType(StatusCode.GAME_ADD_23, 0)
end
local function handleAll()
	netSelectType(StatusCode.GAME_ALLIN, 0)
end

local function setAutoBtn()
	-- print('======  setAutoBtn')
	_csl:getChildByName('btnAutoGiveup'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoLook'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoFollow'):setColor(cc.c3b(255,255,255))

	if _isAutoGiveup then
		_csl:getChildByName('btnAutoGiveup'):setColor(cc.c3b(255,0,0))
	end
	if _isAutoLook then
		_csl:getChildByName('btnAutoLook'):setColor(cc.c3b(107,247,121))
	end
	if _isAutoFollow then
		_csl:getChildByName('btnAutoFollow'):setColor(cc.c3b(33,157,216))
	end
end
local function handleAutoGiveup(sender)
	_isAutoGiveup = not _isAutoGiveup
	if _isAutoGiveup and _isAutoLook then
		_isAutoLook = false
	end
	if _isAutoGiveup and _isAutoFollow then
		_isAutoFollow = false
	end
	setAutoBtn()
end

local function handleAutoLook(sender)
	_isAutoLook = not _isAutoLook
	if _isAutoGiveup and _isAutoLook then
		_isAutoGiveup = false
	end
	setAutoBtn()
end

local function handleAutoFollow(sender)
	_isAutoFollow = not _isAutoFollow
	if _isAutoGiveup and _isAutoFollow then
		_isAutoGiveup = false
	end
	setAutoBtn()	
end

local function handleDelay(sender)
	SocketCtrol.requestDelay(function() end)
end

local function setTwoEye()
	local isOne = false
	local isTwo = false
	if _statusOne == StatusCode.POKER_SHOW then
		isOne = true
	end
	if _statusTwo == StatusCode.POKER_SHOW then
		isTwo = true
	end
	_csl:getChildByName('imgCardOne'):getChildByName('imgEyeOne'):setVisible(isOne)
	_csl:getChildByName('imgCardTwo'):getChildByName('imgEyeTwo'):setVisible(isTwo)	
end

local function isTouchCard()
	if not _isTouchPoker then return false end
	if not GData.isTouchTwoCard() then 
		return false
	end
	return true
end

local function touchCardOne()
	if not isTouchCard() then return end
	if _csl:getChildByName(CARD_ONEBG_NAME) then
		return
	end
	
	if _statusOne == StatusCode.POKER_NO_SHOW then
		_statusOne = StatusCode.POKER_SHOW
	else
		_statusOne = StatusCode.POKER_NO_SHOW
	end
	setTwoEye()
	SocketCtrol.setShowPoker(_statusOne, _statusTwo, function() end)
end
local function touchCardTwo()
	if not isTouchCard() then return end
	if _csl:getChildByName(CARD_TWOBG_NAME) then
		return
	end

	if _statusTwo == StatusCode.POKER_NO_SHOW then
		_statusTwo = StatusCode.POKER_SHOW
	else
		_statusTwo = StatusCode.POKER_NO_SHOW
	end
	setTwoEye()
	SocketCtrol.setShowPoker(_statusOne, _statusTwo, function() end)
end

local function resetTwoCard(tone, ttwo)
	tone:setRotation3D(cc.vec3(0, 0, 0))
	tone:setRotation(0)
	ttwo:setRotation3D(cc.vec3(0, 0, 0))
	ttwo:setRotation(0)
end

function SelfLayer:isSelf()
	return true
end

function SelfLayer:isStand()
	return not self:isSeat()
end
function SelfLayer:isSeat()
	if GSelfData.isHavedSeat() then
		return true
	end
	return false
end



--action
function SelfLayer:runTime(isLook, rtime)
	DZPlaySound.playClock()

	self._gcircle:setVisible(false)
	self._lcircle:setVisible(false)
	self._gparticle:setVisible(false)
	self._lparticle:setVisible(false)

	local circle = self._gcircle
	local particle = self._gparticle
	local runBack = handleGiveup
	if isLook then
		circle = self._lcircle
		particle = self._lparticle
		runBack = handleLook
	end

	circle:setVisible(true)
	particle:setVisible(true)
	local function progressFinish()
	end

	local startV = 90
	local endV = 10
	local percent,runTime = DZConfig.getRunPercentAndTime(rtime)

	if percent > startV then
		percent = startV
	end
	DZAction.progressBack(circle, endV, runTime, progressFinish, percent)

    local rotateV = GMath.particleSelfValue(startV, endV, percent)
    particle:setRotation(rotateV)

	local rotate = cc.RotateTo:create(runTime, -325)
    particle:runAction(rotate)

    --控制震动播放
    local repeatAction = nil
    local btnDelay = _csl:getChildByName('btnDelay')
    local function delayCallback(sender,count)
    	if not btnDelay:isVisible() then 
    		sender:stopAction(repeatAction)
    		do return end
    	end
    	local limitCount = runTime - 5
    	
    	if count < limitCount then
    		do return end
    	end
		if count >= limitCount and count%2 == 1 then
		   DZAction.shakeWithTime(btnDelay, 0.5)
		   Single:paltform():shakePhone()
		end
    end
    repeatAction = DZAction.scheduleTimes(particle, 1, runTime, delayCallback, false)
end

function SelfLayer:runGiveUp(udata, aniBack)
	local cardOne = _csl:getChildByName('imgCardOne')
	local cardTwo = _csl:getChildByName('imgCardTwo')
	local imgD = _csl:getChildByName('imgDTag')
	local isDealer = false
	if imgD then isDealer = imgD:isVisible() end

	local tx1,ty1 = cardOne:getPosition()
	local tx2,ty2 = cardTwo:getPosition()

	local card1 = UIUtil.cloneNode(cardOne)
	local card2 = UIUtil.cloneNode(cardTwo)
	card1:setColor(cc.c3b(150,150,150))
	card2:setColor(cc.c3b(150,150,150))

	DZAction.easeInMove(card1, cc.p(tx1,display.top), 0.5, DZAction.MOVE_TO, function()
		card1:removeFromParent()
	end)
	DZAction.easeInMove(card2, cc.p(tx2,display.top), 0.5, DZAction.MOVE_TO, function()
		card2:removeFromParent()
		self:giveupWait(udata)
		imgD:setVisible(isDealer)
		if aniBack then
			aniBack()
		end
	end)
end


--隐藏显示
function SelfLayer:hideCtrolBet()
	_csl:getChildByName('btnAllIn'):setVisible(false)
	_ctrolBtn:setPositionX(1000)
	_ctrolBtn:setVisible(false)
end
function SelfLayer:disCtrolBet()
	local needbet = GMath.getMeNeedBet()
	local allbet = GSelfData.getSelfModel():getSurplusNum()
	if needbet >= allbet then
		_csl:getChildByName('btnAllIn'):setVisible(true)
		return
	end
	
	local minAddBet = GMath.getMinAddBet()
	-- if minAddBet > allbet then
	-- 	return
	-- end

	_ctrolBtn:setPositionX(display.width/2)
	_ctrolBtn:setVisible(true)
	_ctrolBtn:updateValue(allbet, minAddBet)
end

function SelfLayer:hideWin()
	_csl:getChildByName('imgWinTag'):setVisible(false)
end
function SelfLayer:disWin()
	_csl:getChildByName('imgWinTag'):setVisible(true)
end

function SelfLayer:disDelay()
	local sets,color = GSelfData.getDelayDiamondSet()

	local btnDelay = _csl:getChildByName('btnDelay')
	btnDelay:getChildByName('ttfMoney'):setColor(color)
	btnDelay:getChildByName('ttfMoney'):setString(sets[1])
	
	btnDelay:setVisible(true)
	btnDelay:setEnabled(sets[2])
end
function SelfLayer:hideDelay()
	_csl:getChildByName('btnDelay'):setVisible(false)
end

function SelfLayer:hideAuto()
	_csl:getChildByName('btnAutoGiveup'):setVisible(false)
	_csl:getChildByName('btnAutoLook'):setVisible(false)
	_csl:getChildByName('btnAutoFollow'):setVisible(false)
end
function SelfLayer:disAuto()
	if GJust.isMeGiveup() then return end
	if not GJust.isMeGaming() then return end

	-- _isAutoGiveup = false
	-- _isAutoLook = false
	-- _isAutoFollow = false
	_csl:getChildByName('btnAutoGiveup'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoLook'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoFollow'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoGiveup'):setVisible(true)
	_csl:getChildByName('btnAutoLook'):setVisible(true)
	_csl:getChildByName('btnAutoFollow'):setVisible(false)

	setAutoBtn()
	self:disAutoFollow()
end
function SelfLayer:resetAutoValue()
	--还原
	_isAutoGiveup = false
	_isAutoLook = false
	_isAutoFollow = false
	_befFollowBet = 0
end

function SelfLayer:disAutoFollow()
	--弃牌、不在游戏中
	if GJust.isMeGiveup() then return end
	if not GJust.isMeGaming() then return end

	local needBet = GMath.getMeNeedBet()
	if needBet <= 0 then return end

	--跟注无看牌
	_isAutoLook = false
	if needBet > _befFollowBet then
		_isAutoFollow = false
		_befFollowBet = needBet
	end

	_csl:getChildByName('btnAutoLook'):setColor(cc.c3b(255,255,255))
	_csl:getChildByName('btnAutoLook'):setVisible(false)

	local btnAFollow = _csl:getChildByName('btnAutoFollow')
	local ttfAvalue = btnAFollow:getChildByName('ttfAutoFollow')
	self:followAutoFollow(btnAFollow, ttfAvalue, true)
end

--跟注false、自动跟注true： isAuto
function SelfLayer:followAutoFollow(btnFollow, ttfFollow, isAuto)
	local needBet = GMath.getMeNeedBet()
	local mem = GSelfData.getSelfModel()

	btnFollow:setColor(cc.c3b(255,255,255))
	btnFollow:setEnabled(true)
	btnFollow:setVisible(true)

	--不足跟注
	if mem:getSurplusNum() < needBet then
		btnFollow:setColor(cc.c3b(170,170,170))
		btnFollow:setEnabled(false)
		ttfFollow:setString('all in')

		if isAuto then
			btnFollow:setEnabled(true)
		end
	else
		ttfFollow:setString(needBet)
	end

	setAutoBtn()
end

function SelfLayer:hideLookFollow()
	_csl:getChildByName('btnLook'):setVisible(false)
	_csl:getChildByName('btnGiveUp'):setVisible(false)
	_csl:getChildByName('btnFollow'):setVisible(false)
end
function SelfLayer:disLookFollow()
	self:hideLookFollow()
	_csl:getChildByName('btnGiveUp'):setVisible(true)
	local nbet = GMath.getMeNeedBet()

	--看牌或跟注
	local isLook = false
	if nbet == 0 then
		isLook = true
		_csl:getChildByName('btnLook'):setVisible(true)
		return isLook
	end

	local btnFollow = _csl:getChildByName('btnFollow')
	local ttfvalue = btnFollow:getChildByName('ttfFollowValue')
	self:followAutoFollow(btnFollow, ttfvalue, false)

	return isLook
end

function SelfLayer:getPokerPos()
	return cc.p(display.cx, 120)
end

function SelfLayer:showPoker(round)
	_isTouchPoker = true
	local tgm = Single:gameModel()
	if tgm:getCardOne() == nil or tgm:getCardTwo() == nil then return end
	
	--可以触摸显示两张手牌眼睛
	local function resetCard(tnode)
		tnode:setRotation3D(cc.vec3(0, 0, 0))
		tnode:setRotation(0)
	end

	GData.setTouchTwoCard(true)
	local imgRes, imgSp = nil, nil
	if round == 1 then
	    imgRes = DZConfig.cardName(tgm:getCardOne())
	    imgSp = _csl:getChildByName('imgCardOne')
	    imgSp:setTag(tgm:getCardOne())
	    _statusOne = StatusCode.POKER_NO_SHOW
	elseif round == 2 then 
		imgRes = DZConfig.cardName(tgm:getCardTwo())
		imgSp = _csl:getChildByName('imgCardTwo')
		imgSp:setTag(tgm:getCardTwo())
		_statusTwo = StatusCode.POKER_NO_SHOW
	end
	setTwoEye()
	resetCard(imgSp)
	imgSp:setColor(cc.c3b(255,255,255))
	imgSp:setVisible(true)
	imgSp:setTexture(imgRes)
	local sm = GSelfData.getSelfModel()
	if not sm:isSaid() then
		self:disBetHead()
	end
	--FIXED: tanhaiting 线上出现第一张牌被隐藏的问题，测不出来，在这里强制显示下
	if round == 2 then self:showPoker(1) end
end

function SelfLayer:hidePool()
	_csl:getChildByName('btnPool1'):setVisible(false)
	_csl:getChildByName('btnPool2'):setVisible(false)
	_csl:getChildByName('btnPool3'):setVisible(false)
end
function SelfLayer:disPool()
	local pbtn1 = _csl:getChildByName('btnPool1')
	local pbtn2 = _csl:getChildByName('btnPool2')
	local pbtn3 = _csl:getChildByName('btnPool3')

	local tabs = GameHelp.checkPoolsBtn()
	local checks = tabs[1]
	local text = tabs[2]
	local pools = tabs[3]
	local imgBtns = tabs[4]
	pbtn1:getChildByName('ttfValue1'):setString(pools[1])
	pbtn2:getChildByName('ttfValue2'):setString(pools[2])
	pbtn3:getChildByName('ttfValue3'):setString(pools[3])

	local ttfbtns = {'ttfPool1', 'ttfPool2', 'ttfPool3'}
	local function setBtn(btn, idx)
		local noUse = checks[ idx ]
		btn:loadTextures(imgBtns[1], imgBtns[2], imgBtns[3])
		if not noUse then
			btn:setColor(cc.c3b(195,199,202))
			btn:setEnabled(false)
		else
			btn:setColor(cc.c3b(255,255,255))
			btn:setEnabled(true)
		end

		btn:getChildByName(ttfbtns[idx]):setString(text[ idx ])
	end

	setBtn(pbtn1, 1)
	setBtn(pbtn2, 2)
	setBtn(pbtn3, 3)
	pbtn1:setVisible(true)
	pbtn2:setVisible(true)
	pbtn3:setVisible(true)
end

function SelfLayer:hideBetHead()
	self._betHead:setVisible(false)
end
function SelfLayer:disBetHead()
	self._betHead:setVisible(true)
end

--游戏已经开始了并且只有我自己在位置上
function SelfLayer:disWait(udata)
	self:hideAll()
	self:disBetHead()
	self:getDObj():disSurplusBet(udata)
end



function SelfLayer:disAnimation(aniImg)
	GUI.showAni(_headPos, _csl, aniImg)	
end


function SelfLayer:checkTrusteeship()
	local sm = GSelfData.getSelfModel()

	if not sm then return end

	if sm:isTrusteeship() then
		self:disBetHead()

		self:hideCtrolBet()
		self:hidePool()
		self:hideLookFollow()
		self:hideAuto()
	end
end

--不同的状态进行不同的页面显示
function SelfLayer:initDisStatus(status)
	if status == StatusCode.GAME_GIVEUP then
		self:cardGray()
	end
end

--player、selfLayer
function SelfLayer:hideSaid()
	self:hideCtrolBet()
	self:hidePool()
	self:hideLookFollow()

	self:disBetHead()
	self:disAuto()

	self:checkTrusteeship()
	self:hideDelay()
end

function SelfLayer:disSaidKeep()
	local sm = GSelfData.getSelfModel()
	if sm:isTrusteeship() then
		self:hideSaid()
		return 
	end
	self:disCtrolBet()
	self:disPool()
	self:disLookFollow()
	-- self:disBetHead()
	-- self:disAuto()
	self:disDelay()
	self:resetAutoValue()
	self:hideBetHead()
	self:hideAuto()
end

function SelfLayer:disSaid(ctime)
	local sm = GSelfData.getSelfModel()
	if sm:isTrusteeship() then
		self:hideSaid()
		return 
	end
	DZPlaySound.playTurnMe()

	self:disCtrolBet()
	self:disPool()

	local islook = self:disLookFollow()
	_isLook = islook
	self:runTime(islook, ctime)

	self:hideBetHead()
	self:hideAuto()

	if _isAutoGiveup then
		self:hideSaid()
		handleGiveup()
	elseif _isAutoLook and islook then
		self:hideSaid()
		handleLook()	
	elseif _isAutoFollow then
		handleFollow()
	end

	self:checkTrusteeship()
	self:disDelay()

	--还原
	self:resetAutoValue()
end

function SelfLayer:disTwoPokerTag()
	_isTouchPoker = true
	local tgm = Single:gameModel()
	if tgm:getCardOne() == nil or tgm:getCardTwo() == nil then return end
	
	--可以触摸显示两张手牌眼睛
	GData.setTouchTwoCard(true)

	local img1 = DZConfig.cardName(tgm:getCardOne())
	local img2 = DZConfig.cardName(tgm:getCardTwo())
	local tone = _csl:getChildByName('imgCardOne')
	local ttwo = _csl:getChildByName('imgCardTwo')

	resetTwoCard(tone, ttwo)

	tone:setColor(cc.c3b(255,255,255))
	ttwo:setColor(cc.c3b(255,255,255))
	tone:setVisible(true)
	ttwo:setVisible(true)
	tone:setTexture(img1)
	ttwo:setTexture(img2)

	--凑成牌型时候高亮显示
	tone:setTag(tgm:getCardOne())
	ttwo:setTag(tgm:getCardTwo())

	_statusOne = StatusCode.POKER_NO_SHOW
	_statusTwo = StatusCode.POKER_NO_SHOW
	setTwoEye()

	local sm = GSelfData.getSelfModel()
	if not sm:isSaid() then
		self:disBetHead()
	end
end

function SelfLayer:hideTwoCard()
	_isTouchPoker = false
	local tone = _csl:getChildByName('imgCardOne')
	local ttwo = _csl:getChildByName('imgCardTwo')
	tone:setVisible(false)
	ttwo:setVisible(false)
end


function SelfLayer:getDObj()
	return self._dobj
end

function SelfLayer:disWinner(endBack)
	local win = _csl:getChildByName('imgWinTag')
	-- win:setVisible(true)

	local posx, posy = win:getPosition()
	local winAni =  UIUtil.plistAni(ResLib.EFFECT_YOU_WIN, cc.p(posx,posy), _csl, 0.1, 'anim_youwin', 6, true)
	winAni:setScale(0.7)
	DZAction.scale(winAni, cc.p(0.4,0.4), cc.p(1.1,1.1), 3.5/2, false, function()
		-- win:setVisible(false)
		winAni:removeFromParent()
		endBack()
	end)
end


--亮手牌
function SelfLayer:showdown(cardNum1, cardNum2)
	local tone = _csl:getChildByName('imgCardOne')
	local ttwo = _csl:getChildByName('imgCardTwo')

	local function flipCard(card, cpos, cname)
		local rbg = UIUtil.addPosSprite(ResLib.COM_CARD, cpos, _removeNode, nil)
		rbg:setScale(0.65)
		rbg:setName(cname)

		local function onEvent(event)
			if event == "exit" then
				rbg = nil
			end
		end
		rbg:registerScriptHandler(onEvent)

		DZAction.flipTwoSprite(rbg, card, 0.15, function()
			if rbg then
				rbg:removeFromParent()
			end
		end)
	end

	if cardNum1 ~= StatusCode.POKER_BACK then
		local pox1,poy1 = tone:getPosition()
		flipCard(tone, cc.p(pox1,poy1), CARD_ONEBG_NAME)
	end
	if cardNum2 ~= StatusCode.POKER_BACK then
		local pox2,poy2 = ttwo:getPosition()
		flipCard(ttwo, cc.p(pox2,poy2), CARD_TWOBG_NAME)
	end
end

function SelfLayer:hideAll()
	local tarr = _csl:getChildren()
	for i=1,#tarr do
		tarr[ i ]:setVisible(false)
	end
	self:hideCtrolBet()
end

function SelfLayer:applayTime(atime)
	local GameLayer = require 'game.GameLayer'
	GameLayer:applayPrompt(atime)
end

function SelfLayer:removeApplayTime()
	local GameLayer = require 'game.GameLayer'
	GameLayer:removeApplayPrompt()
end

--设置战队图标
function SelfLayer:setTeamMark(isDis)
	-- 自己的图标平时不显示，只有在托管的时候才显示
	-- 因此，只关注setUITrusteeship
	if not isDis then 
	end
end
--sng
function SelfLayer:setUITrusteeship(isTrusteeship, isTeam)
	if isTrusteeship then

		self._trusteeshipImg:setVisible(true)
		self._trusteeshipBtn:setVisible(true)
		self:checkTrusteeship()
		self._teamSp:setVisible(isTeam)
	else
		self._trusteeshipImg:setVisible(false)
		self._trusteeshipBtn:setVisible(false)

		self._teamSp:setVisible(false)
	end
	-- self._teamSp:xxxxx()
end

function SelfLayer:trusteeshipMenu()
	SocketCtrol.sngCancelTrusteeship(function()end)
end

function SelfLayer:disGrayHeadRank(rankNum)
	-- self:getDObj():disGrayHead(self._meHead, rankNum)
	self:getDObj():disGrayHead(self._betHead, _headPos, rankNum)
end


function SelfLayer:initLayer(parent)
	print("SelfLayer:initLayer")
	self:resetAutoValue()
	_isTouchPoker = false
	_isLook = false
	_statusOne = StatusCode.POKER_NO_SHOW
	_statusTwo = StatusCode.POKER_NO_SHOW

	_self = self
	_layer = cc.LayerColor:create(cc.c4b(0,150,0,0))
	parent:addChild(_layer, 1)

	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.GSELF_CSB)
	_layer:addChild(cs)
	_csl = cs

	_removeNode = cc.Node:create()
	_layer:addChild(_removeNode)


	local btnFollow = _csl:getChildByName('btnFollow')
	local btnAutoFollow = _csl:getChildByName('btnAutoFollow')

	_csl:getChildByName('btnGiveUp'):touchEnded(handleGiveup)
	btnFollow:touchEnded(handleFollow)
	_csl:getChildByName('btnLook'):touchEnded(handleLook)
	_csl:getChildByName('btnPool3'):touchEnded(handlePoolOne)
	_csl:getChildByName('btnPool1'):touchEnded(handlePoolOneTwo)
	_csl:getChildByName('btnPool2'):touchEnded(handlePoolTwoThree)

	_csl:getChildByName('btnAutoGiveup'):touchEnded(handleAutoGiveup)
	_csl:getChildByName('btnAutoLook'):touchEnded(handleAutoLook)
	btnAutoFollow:touchEnded(handleAutoFollow)
	_csl:getChildByName('btnAllIn'):touchEnded(handleAll)
	_csl:getChildByName('btnDelay'):touchEnded(handleDelay)


	--circle
	local img1 = 'game/game_look_run.png'
	local img2 = 'game/game_giveup_run.png'
	local lgPos = cc.p(55,60+4.5)
	self._lcircle = UIUtil.progressReverse(img1, lgPos, _csl:getChildByName('btnLook'))
	self._gcircle = UIUtil.progressReverse(img2, lgPos, _csl:getChildByName('btnGiveUp'))
	self._lcircle:setReverseDirection(false)
	self._gcircle:setReverseDirection(false)
	self._lcircle:setRotation(180)
	self._gcircle:setRotation(180)

    self._lparticle = GUI.particleSelfUI(img1, lgPos, _csl:getChildByName('btnLook'), cc.p(64,11))
    self._gparticle = GUI.particleSelfUI(img2, lgPos, _csl:getChildByName('btnGiveUp'), cc.p(64,11))
    

	--控制杆
	local AddBet = require 'game.AddBet'
	local tbet = AddBet.createAddBet(_csl, updateBet, 893)
	tbet:setPosition(display.width/2, 219)--237
	
	tbet:regiaterEvent()
	tbet:setLocalZOrder(GMath.getMaxZOrder() - 1)
	_ctrolBtn = tbet


	--touch two card
	local tone = _csl:getChildByName('imgCardOne')
	local ttwo = _csl:getChildByName('imgCardTwo')
	tone.endedBack = touchCardOne
	TouchBack.registerImg(tone)	
	ttwo.endedBack = touchCardTwo
	TouchBack.registerImg(ttwo)

	--head
	local hnode = cc.Node:create()
	_csl:addChild(hnode, -1)
	local hpos = _headPos
	local turl = Single:playerModel():getPHeadUrl()
	local headImg = GData.getHeadImg()
	local headBg = UIUtil.addPosSprite(headImg, hpos, hnode, nil)
	local _,mehead = UIUtil.addUserHead(hpos, turl, hnode, true)
	self._meHead = mehead
	self._betHead = hnode
	self._headBg = headBg

	--战队图标
	local teamNode = cc.Node:create()
	teamNode:setPosition(cc.pAdd(hpos, cc.p(-56,11)))
	-- teamNode:setLocalZOrder(100)
	-- hnode:addChild(teamNode)
	UIUtil.addPosSprite("game/team_mark.png",cc.p(0,0),teamNode, cc.p(0,0))
	--[[
	-- local function successDown(path)
	-- 	-- print("战队: success ->",path)
	-- 	UIUtil.addPosSprite(path,cc.p(0,0),teamNode, cc.p(0,0))
	-- end
	-- local function errorDown(path)
	-- 	local layer = display.newLayer(cc.c4b(0,0,0,1))
	-- 	layer:setContentSize(cc.size(29,36))
	-- 	teamNode:addChild(layer)
	-- end
	-- CppPlat.downResFile(teamurl, successDown, errorDown, "", "rewardHintIdentifier")
	-- teamNode:setVisible(false)
	]]
	teamNode:setVisible(false)
	self._teamSp = teamNode

	local ttfsngRank = UIUtil.addLabelBold('', 55, hpos, cc.p(0.5,0.5), hnode, cc.c3b(255,255,255))
	--sng托管
	local trusteeship = UIUtil.addPosSprite('game/game_trusteeshiping.png', hpos, hnode, nil)
	trusteeship:setScale(1)

	trusteeship:setVisible(false)
	hnode:addChild(teamNode)
	local img1 = 'game/game_return_poker1.png'
	local img2 = 'game/game_return_poker2.png'
	local item = UIUtil.addMenuBtn(img1, img2, function()
		self:trusteeshipMenu()
		end, cc.p(display.cx, 300), hnode)
	-- item:setScale(1)
	item:setVisible(false)
	
	self._trusteeshipImg = trusteeship
	self._trusteeshipBtn = item

	
	--公共ui
	local tabui = {}
	tabui[1] = _csl:getChildByName('imgDTag')
	tabui[2] = _csl:getChildByName('imgPlayerStatus')
	tabui[3] = _csl:getChildByName('imgBetTag'):getChildByName('imgBetTagNum')
	tabui[4] = _csl:getChildByName('imgBetTag')
	tabui[5] = _csl:getChildByName('imgSurplusBetBg')
	tabui[6] = _csl:getChildByName('imgSurplusBetBg'):getChildByName('ttfSurplusBetNum')
	tabui[7] = ttfsngRank

	local display = require 'game.GDisplay'
	local dobj = display:create(tabui)
	self._dobj = dobj

	self:hideAll()

	--设置字体
	local pool1 = _csl:getChildByName('btnPool1')
	local pool2 = _csl:getChildByName('btnPool2')
	local pool3 = _csl:getChildByName('btnPool3')
	local ttfs1 = {tabui[6], tabui[3], pool1:getChildByName('ttfPool1'), pool1:getChildByName('ttfValue1')}
	local ttfs2 = {pool2:getChildByName('ttfPool2'), pool2:getChildByName('ttfValue2'), pool3:getChildByName('ttfPool3'), pool3:getChildByName('ttfValue3')}
	local ttfs3 = {btnFollow:getChildByName('ttfFollowValue'), btnAutoFollow:getChildByName('ttfAutoFollow')}
	GUI.setStudioFontBold(ttfs1)
	GUI.setStudioFontBold(ttfs2)
	GUI.setStudioFontBold(ttfs3)
end
--站起
function SelfLayer:standCall()
	self:hideAll()
	self:removeApplayTime()

	self._gcircle:stopAllActions()
	self._lcircle:stopAllActions()
	self._gparticle:stopAllActions()
	self._lparticle:stopAllActions()
end

function SelfLayer:changeNullHeadImg(hImg, hFontColor)
	if self._headBg then
		self._headBg:setTexture(hImg)
	end
end


--player无

--弃牌显示：头像、剩余筹码、两张牌(变黑了)、弃牌状态、当前押注
function SelfLayer:giveupWait(udata)
	self:disWait(udata)
	self:getDObj():disStatus(udata)
	self:getDObj():disNowBet(udata)

	self:cardGray()
end

function SelfLayer:cardGray()
	_csl:getChildByName('imgCardOne'):setVisible(true)
	_csl:getChildByName('imgCardTwo'):setVisible(true)
	_csl:getChildByName('imgCardOne'):setColor(cc.c3b(120,120,120))
	_csl:getChildByName('imgCardTwo'):setColor(cc.c3b(120,120,120))
end


function SelfLayer.getMeCards()
	local rets = {}
	table.insert(rets, _csl:getChildByName('imgCardOne'))
	table.insert(rets, _csl:getChildByName('imgCardTwo'))
	return rets
end


--数据
function SelfLayer:resetRoundLayer()
	local tone = _csl:getChildByName('imgCardOne')
	local ttwo = _csl:getChildByName('imgCardTwo')
	_csl:stopAllActions()
	_removeNode:stopAllActions()
	_removeNode:removeAllChildren()
	resetTwoCard(tone, ttwo)

	self:resetAutoValue()
	_isLook = false
end

function SelfLayer:disD()
	local imgD = _csl:getChildByName('imgDTag')
	if imgD then 
		imgD:setVisible(true)
	end
end

function SelfLayer:hideD()
	local imgD = _csl:getChildByName('imgDTag')
	if imgD then
		imgD:setVisible(false)
	end
end

return SelfLayer