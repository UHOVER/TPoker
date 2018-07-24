local Player = class("Player", cc.LayerColor)

--null
-- circle 的tag跟 Player 的 _runPos 同步
function Player:getPNode()
	return self._node
end

function Player:getHandNode()
	return self._handCardNode
end

function Player:setSeatTTf(text)
	if not self._ttfSeat then return end
	self._ttfSeat:setString(text)
end

function Player:changeNullHeadImg(hImg, hFontColor)
	if self._nullHead then 
		self._nullHead:setTexture(hImg)
		self._ttfSeat:setColor(hFontColor)
	elseif self._seatHeadBg then
		self._seatHeadBg:setTexture(hImg)
	end
end

function Player:touchNull(touch, event)
	if GSelfData.isHavedSeat() then
		return
	end
	if UserCtrol.isSeatByPos(self:getPos()) then
		return
	end

	DZPlaySound.playGear()
	SocketCtrol.selectPosition(self:getPos(), function()end)
end

function Player:addNull(text)
	self:getPNode():removeAllChildren()

	self:initDealTag()

	-- local img = ResLib.GAME_NULL
	local img = GData.getHeadImg()
	local tcircle = UIUtil.addMenuBtn(img, img, function(tag, sender)
		self:touchNull(tag, sender)
	end, self:getCenter(), self:getPNode())
	tcircle:setOpacity(0)

	self._nullHead = UIUtil.addPosSprite(img, self:getCenter(), self:getPNode(), cc.p(0.5,0.5))
	local nullImg = self._nullHead

	local fcolor = GData.getHeadFontColor()
	local tpos = cc.p(nullImg:getContentSize().width/2, nullImg:getContentSize().height/2)
	self._ttfSeat = UIUtil.addLabelBold(text, 28, tpos, cc.p(0.5,0.5), nullImg,  fcolor)

	self:setSeatType(StatusCode.SEAT_NULL)
end


function Player:touchHead()
    local GPlayerMsg = require 'game.GPlayerMsg'
    GPlayerMsg.showMsg(self:getUserData())
end

--data
function Player:updateRunPos(pos)
	self._runPos = pos
	self:updateRunUIPos()
	-- self:LayoutOddsPos()
end
function Player:getRunPos()
	return self._runPos
end

function Player:getPos()
	return self._pos
end

function Player:setSeatType(ctype)
	--null、我、其他玩家
	self._seatType = ctype
end
function Player:getSeatType()
	return self._seatType
end


function Player:setUserData(udata)
	self._userData = udata
end
function Player:getUserData()
	return self._userData
end

function Player:getUId()
	assert(self:getUserData(), 'Player:getUId')
	return self:getUserData():getUserId()
end

function Player:isSelf()
	if self:isStand() then return false end

	if Single:playerModel():getId() == self:getUId() then
		return true
	end
	return false
end


--position
function Player:getCenter()
	local tsize = self:getContentSize()
	return cc.p(tsize.width/2,tsize.height/2)
end
function Player:getW()
	return self:getContentSize().width
end

function Player:getCX()
	return self:getCenter().x
end
function Player:getCY()
	return self:getCenter().y
end


--隐藏和显示
function Player:disTime()
	--思考计时
	self._imgTime:setVisible(true)
	self._particle:setVisible(true)
	self._ttfTime:setVisible(false)
end

function Player:hideSendTag()
	self._imgSendTag1:setVisible(false)
	self._imgSendTag2:setVisible(false)
end

--player、selfLayer
function Player:hideSaid()
	transition.stopTarget(self._imgTime)
	transition.stopTarget(self._particle)

	self._imgTime:setVisible(false)
	self._particle:setVisible(false)
	self._ttfTime:setVisible(false)
end
function Player:disSaid(ctime)
	-- if self:getUserData():isTrusteeship() then
	-- 	self:hideSaid()
	-- else
		self:runTime(ctime)
	-- end
end

function Player:disTwoPokerTag()
	local udata = self:getUserData()
	local status = udata:getStatus()
	-- 时间 or 弃牌不显示发牌标示
	if udata:getApplyTime() ~= 0 or status == StatusCode.GAME_GIVEUP then
		self._imgSendTag1:setVisible(false)
		self._imgSendTag2:setVisible(false)
	else
		self._imgSendTag1:setVisible(true)
		self._imgSendTag2:setVisible(true)
	end
end

function Player:hideTwoCard()
	self:hideSendTag()
end

function Player:getDObj()
	return self._dobj
end

function Player:disWinner(endBack)
	local pos1 = cc.p(self:getCX(), self:getCY() + 62)
	local pos2 = cc.p(self:getCX(), self:getCY() - 62)
	local pos3 = cc.p(self:getCX(), self:getCY())

	local tp = cc.Node:create()
	self:getPNode():addChild(tp, 3)--在状态之上，两张手牌之下

	local tdata = self:getUserData()
	local cardtype = tdata:getPokerType()
	local winNum = tdata:getWinBet()

	local effect = nil
	DZAction.delateTime(tp, 0.5, function()
		effect = UIUtil.plistAni(ResLib.EFFECT_STAR, pos3, tp, 0.15, 'starlight_', 20, true)
		effect:setScale(1.2)
	end)

	UIUtil.addPosSprite('game/game_winnum_bg.png', pos1, tp, nil)
	UIUtil.addLabelArial('+'..winNum, 25, pos1, cc.p(0.5,0.5), tp, cc.c3b(0,0,0))

	--未知类型不显示
	if string.len(cardtype) ~= 0 then
		UIUtil.addPosSprite('game/game_winnum_bg.png', pos2, tp, nil)
		UIUtil.addLabelArial(cardtype, 25, pos2, cc.p(0.5,0.5), tp, cc.c3b(0,0,0))
	end

	DZAction.delateTime(tp, 3.5, function()
		tp:removeFromParent()
		if effect then
			effect:removeFromParent()
		end

		endBack()
	end)
end

function Player:disVoice(vtime)
	local vnode = cc.Node:create()
	self:addChild(vnode)
	local pos = cc.p(self:getCX(), self:getCY() - 62)
	UIUtil.addPosSprite('game/game_voice_listen.png', pos, vnode, nil)
	UIUtil.addLabelArial(vtime..' \'', 22, cc.p(pos.x+18,pos.y), cc.p(0.5,0.5), vnode, cc.c3b(0,0,0))

	DZAction.delateTime(vnode, vtime + 0.5, function()
		vnode:removeFromParent()
	end)
end

function Player:disAnimation(aniImg)
	GUI.showAni(self:getCenter(), self, aniImg)
end

--不隐藏：名字、头像、剩余砝码、null背景
function Player:hideAll()
	if self:isStand() then return end

	-- self:getDObj():hideD()
	self:hideD()
	self:getDObj():hideNowBet()
	self:getDObj():hideStatus(self:getUserData())
	self:hideSendTag()

	self:hideSaid()
end

function Player:disWait()
	self:hideAll()
end

function Player:removeApplayTime()
	self._dobj:disSurplusBet(self:getUserData())

	local tnode = self:getPNode()
	if tnode:getChildByName('APPLAY_TIME') then
		tnode:getChildByName('APPLAY_TIME'):removeFromParent()
	end
end


--动作
function Player:applayTime(time)
	local tnode = self:getPNode()
	if tnode:getChildByName('APPLAY_TIME') then
		-- assert(nil, 'applayTime APPLAY_TIME')
		return
	end

	-- self._dobj:hideSurplusBet()
	local ttime = time
	local prompt = nil
	local function scheduleApplay()
		ttime = ttime - 1
		prompt:setString('请求中'..ttime..'s')

		if ttime <= 0 then 
			-- self:removeApplayTime()
			prompt:setString('等待')
			ttime = 0 
		end
	end

	-- local pos = cc.p(self:getCX(), self:getCY() - 64)
	local pos = cc.p(self:getCX(), self:getCY() - 100)
	prompt = UIUtil.addLabelArial('请求中'..ttime..'s', 22, pos, cc.p(0.5,0.5), self:getPNode(), cc.c3b(255,255,255))
	prompt:setName('APPLAY_TIME')
	DZSchedule.runSchedule(scheduleApplay, 1, prompt)
end

function Player:runTime(rtime)
	local percent,runTime = DZConfig.getRunPercentAndTime(rtime)
	self:disTime()
    DZAction.progressBack(self._imgTime, 2, runTime, function()end, percent)

    local particle = self._particle
    local rotateV = GMath.particleOtherValue(100, 2, percent)
    particle:setRotation(rotateV)
    local rotate = cc.RotateTo:create(runTime, 720)
    particle:runAction(rotate)

	-- DZAction.scheduleTimes(self._ttfTime, 1, time, function(sprite, times)
	-- 	self._ttfTime:setString(times..'s')
	-- end)
end


function Player:flipTwoPoker()
	if self:isSelf() then return end
	--延迟、消失渐变0.3
	local time2 = 3
	local time3 = 0.3

	local function flipBack1(p1, pos1)
		if not p1 then return end
		GUI.showDelayTwoPoker(p1, pos1, time2, time3, function()end)
	end
	local function flipBack2(p2, pos2)
		if not p2 then 
			print('stack  294 Player.lua  flipTwoPoker')
			return 
		end
		GUI.showDelayTwoPoker(p2, pos2, time2, time3, function()end)
	end
	self:showAllTimeTwoPoker(flipBack1, flipBack2)
end

function Player:showAllTimeTwoPoker(flipBack1, flipBack2)
	if self:isSelf() then return end

	local pos1 = cc.p(self:getCX()-26, self:getCY())
	local pos2 = cc.p(self:getCX()+26, self:getCY())
	local udata = self:getUserData()
	local tcards = udata:getDisPokers()

	if not tcards or #tcards == 0 then
		flipBack2()
		do return end
	end

	local imgName1 = DZConfig.cardName(tcards[1])
	local imgName2 = DZConfig.cardName(tcards[2])
	local p1 = UIUtil.addPosSprite(imgName1, pos1, self:getHandNode(), nil)
	local p2 = UIUtil.addPosSprite(imgName2, pos2, self:getHandNode(), nil)
	p1:setScale(0.45)
	p2:setScale(0.45)
	self._disCard1 = p1
	self._disCard2 = p2

	-- 翻牌2*0.2
	GUI.flipPokerBack(p1, pos1, 0.2, function()
		flipBack1(p1, pos1)
	end)
	GUI.flipPokerBack(p2, pos2, 0.2, function()
		flipBack2(p2, pos2)
	end)
end

function Player:removeAllTimeTwoPoker()
	if self:isSelf() then return end
	
	self:getHandNode():removeAllChildren()
	self._disCard1 = nil
	self._disCard2 = nil
end


--亮手牌执行2007时候
function Player:showdown(cardNum1, cardNum2)
	if self._disCard1 == nil or self._disCard2 == nil then
		return
	end
	if cardNum1 ~= StatusCode.POKER_BACK then
		self._disCard1:setTexture(DZConfig.cardName(cardNum1))
	end
	if cardNum2 ~= StatusCode.POKER_BACK then
		self._disCard2:setTexture(DZConfig.cardName(cardNum2))
	end
end

function Player:runShowEmoji(emojiStr)
	GUI.showEmoji(self:getCenter(), self, emojiStr)
end

function Player:runGiveUp(udata, aniBack)
	local imgst = self._imgSendTag
	imgst:setVisible(true)
	local posx,posy = imgst:getPosition()
	local tpos = imgst:getParent():convertToNodeSpace(display.center)

	local trunTime = 0.333
	DZAction.easeInMove(imgst, tpos, trunTime, DZAction.MOVE_TO, function()
	end)
	DZAction.fadeToCallback(imgst, trunTime, 30, function() 
			imgst:setOpacity(255)
			self:hideSendTag()
			imgst:setPosition(posx, posy)
		end)

	DZAction.delateTime(imgst, trunTime, function()
		if aniBack then
			aniBack()
		end
	end)
end

function Player:runPoolBet()
end

--不同的状态进行不同的页面显示
function Player:initDisStatus(status)
end

function Player:getSurplusBetTTF()
	return self._ttfSurplusBet
end

function Player:setTeamMark(isDis)
	if self._teamSp then
		self._teamSp:setVisible(isDis)		
	end
end
--sng
function Player:setUITrusteeship(isTrusteeship)
	if isTrusteeship then
		self._trusteeshipImg:setVisible(true)
	else
		self._trusteeshipImg:setVisible(false)
	end
end


function Player:disGrayHeadRank(rankNum)
	-- self:getDObj():disGrayHead(self._ihead, rankNum)
	self:getDObj():disGrayHead(self:getPNode(), self:getCenter(), rankNum)
end


function Player:updateRunUIPos()
	if self:isStand() then return end
	local cx = self:getCX()
	local tw = self:getW()
	local tDx = cx + 80
	local tnowbetx = tw - 50--68
	local tstatusx = cx + 38--40
	local teamx = cx - 52
	local maxpos = GJust.splitPos()

	--name
	local tname = self._name
	local tnameW = tname:getContentSize().width - 130
	local tnameX = tnameW / 2

	--右
	if self:getRunPos() >= maxpos then
		tDx = cx - 80
		tnowbetx = 50
		tstatusx = cx - 38
		tnameX = -tnameX
		teamx = cx + 20
	end

	-- if self:getRunPos() == 1 then 
	-- 	-- teamx = cx + 20
	-- end
	if tnameW >= 0 then
		--tname:getPositionX() 是变动的
		-- tname:setPositionX(tname:getPositionX() + tnameX)
		tname:setPositionX(cx + tnameX)
	end

	self._imgD:setPositionX(tDx)
	self._imgBet:setPositionX(tnowbetx)
	self._ttfNowBet:setPositionX(tnowbetx)
	self._imgStatus:setPositionX(tstatusx)
	self._teamSp:setPositionX(teamx)
end

function Player:getPokerPos()
	if not self._userData then return cc.p(0,0) end
	local pos = self:getRunPos()
	local maxpos = GJust.splitPos()
	local ptx, pty = self._ttfNowBet:getPositionX(), self._ttfNowBet:getPositionY()
	if pos == 1 then  -- 底部
		ptx, pty = self:getCX(), self:getCY() - 14
	elseif pos >= maxpos then --右
		ptx, pty = self:getCX()+20 , pty + self._ttfNowBet:getContentSize().height - 14
	else 			  -- 左边
		ptx, pty = self:getCX()-50, pty + self._ttfNowBet:getContentSize().height - 14
	end
	return self:convertToWorldSpace(cc.p(ptx, pty))
end

function Player:showPoker(round)
	if round == 1 then 
		self._imgSendTag1:setVisible(true)
	end

	if round == 2 then 
		self._imgSendTag2:setVisible(true)
	end
end


function Player:userUI(udata)
	self._ttfSeat = nil
	self._nullHead = nil
	self:getPNode():removeAllChildren()
	local tnode = self:getPNode()

	--游戏结束的时候显示两张牌
	self._disCard1 = nil
	self._disCard2 = nil

	self._userData = udata
	local cx = self:getCX()
	local cy = self:getCY()
	local center = self:getCenter()

	--nullbg
	local imgNull = GData.getHeadImg()
	local imgNulls = {imgNull, imgNull, imgNull}
	local nullBtn = UIUtil.addUIButton(imgNulls, center, tnode, function()
		self:touchHead()
		end)
	nullBtn:setOpacity(0)


	local function onEventHeadBg(event)
		if event == "exit" then
			self._seatHeadBg = nil
		end
	end

	self._seatHeadBg = UIUtil.addPosSprite(imgNull, center, tnode, cc.p(0.5,0.5))
	self._seatHeadBg:registerScriptHandler(onEventHeadBg)

	--头像
	local _,ihead = UIUtil.addUserHead(center, udata:getHeadUrl(), tnode, true)
	self._ihead = ihead

	local ttfsngRank = UIUtil.addLabelBold('', 55, center, cc.p(0.5,0.5), tnode, cc.c3b(255,255,255))

	--sng托管
	local trusteeship = UIUtil.addPosSprite('game/game_trusteeshiping.png', center, tnode, nil)
	trusteeship:setLocalZOrder(3) --在翻牌之下
	-- trusteeship:setScale(1.2)
	trusteeship:setVisible(false)
	self._trusteeshipImg = trusteeship


	--名字
	local color = cc.c3b(114,142,162)
	local tname = UIUtil.addLabelBold(udata:getUserName(), 23, cc.p(cx, cy+46), cc.p(0.5,0), tnode, color)
	if self:isSelf() then
		tname:setVisible(false)
	end
	self._name = tname

	--庄、剩余砝码、砝码bg
	self._imgD = UIUtil.addPosSprite(ResLib.GAME_TAG_D, cc.p(0, cy-69), tnode, nil)
	self._ttfSurplusBetBg = UIUtil.addPosSprite('game/game_surplus_bg.png', cc.p(cx, cy-68), tnode, nil)
	local snum = GMath.changeNumKW(udata:getSurplusNum())
	local sbcolor = cc.c3b(255,255,255)
	self._ttfSurplusBet = UIUtil.addLabelBold(snum, 27, cc.p(61, 18), nil, self._ttfSurplusBetBg, sbcolor)

	--筹码tag、筹码值、状态
	self._imgBet = UIUtil.addPosSprite(ResLib.GAME_BET_TAG, cc.p(0, cy+2), tnode, nil)
	self._ttfNowBet = UIUtil.addLabelBold('bet', 24, cc.p(0, cy-16), cc.p(0.5,1), tnode, cc.c3b(255,255,255))
	self._ttfNowBet:setLocalZOrder(2)
	self._imgStatus = UIUtil.addPosSprite('game/game_follows.png', cc.p(0, cy+25), tnode, nil)--60
	self._imgStatus:setScale(0.52)
	self._imgStatus:setLocalZOrder(3)--在倒计时之上

	--计时、发牌标示、特效
	local imgCircle = 'game/game_progress.png'
	self._imgTime = UIUtil.progressReverse(imgCircle, center, tnode)
	self._imgTime:setLocalZOrder(2)--在头像之上
	-- self._imgSendTag = UIUtil.addPosSprite('game/game_ic_xiaopai.png', cc.p(cx,cy-20), tnode, nil)
	-- self._imgSendTag:setLocalZOrder(1)--在头像之上
	-- self._imgSendTag:setVisible(false)

	self._imgSendTag = cc.Node:create()
	self._imgSendTag:setPosition(cc.p(cx, cy-20))
	tnode:addChild(self._imgSendTag, 1)
	local function addPoker(parent , pos, rotate)
		local card = UIUtil.addPosSprite('gambling/com_cardbg.png', pos, parent, nil)
		card:setScaleX(24/card:getContentSize().width)
		card:setScaleY(34/card:getContentSize().height)
		card:setRotation(rotate)
		card:setVisible(false)
		return card
	end
	self._imgSendTag1 = addPoker(self._imgSendTag,cc.p(-6,0), -15.3)
	self._imgSendTag2 = addPoker(self._imgSendTag,cc.p(8, 0), 14.6)

	self._particle = GUI.particleSelfUI(imgCircle, center, tnode, cc.p(41,82))
	self._particle:setLocalZOrder(2)

	--时间计时 暂时无用
	self._ttfTime = UIUtil.addLabelArial('0s', 18, center, cc.p(0.5,1), tnode, cc.c3b(255,0,0))
	self._ttfTime:setVisible(false)

	--公共ui
	local tabui = {self._imgD, self._imgStatus, self._ttfNowBet, self._imgBet, 
					self._ttfSurplusBetBg, self._ttfSurplusBet, ttfsngRank}
	local display = require 'game.GDisplay'
	local dobj = display:create(tabui)
	self._dobj = dobj


	--战队
	local teamNode = cc.Node:create()
	teamNode:setPosition(cc.p(cx + 20,cy + 11))
	teamNode:setLocalZOrder(3)
	tnode:addChild(teamNode)
	UIUtil.addPosSprite("game/team_mark.png",cc.p(0,0),teamNode, cc.p(0,0))
	--[[
	local function successDown(path)
		print("战队: success ->",path)
		UIUtil.addPosSprite(path,cc.p(0,0),teamNode, cc.p(0,0))
	end
	local function errorDown(path)
			print("头像错误", path)
			local layer = cc.LayerColor:create(cc.c3b(255,0,0))
			layer:setContentSize(cc.size(29,36))
			teamNode:addChild(layer)
	end
	CppPlat.downResFile(turl, successDown, errorDown, "", "rewardHintIdentifier")
	]]
	teamNode:setVisible(false)
	self._teamSp = teamNode
	

	--显示玩家的两张牌父类
	self._handCardNode = cc.Node:create()
	tnode:addChild(self._handCardNode, 4)--在状态之上

	self:updateRunUIPos()
	-- self:initOddsView()
end

function Player:LayoutOddsPos()
	if self.oddsLabel == nil then 
		return
	end

	local oddsParent = self.oddsLabel:getParent()
	local isLeft = (self:getPositionX()+self:getContentSize().width/2) < display.width/2
	local curPos = nil
	local baseX, baseY = self:getContentSize().width/2, self:getContentSize().height/2
	if self:isSelf() then  -- 如果是用户自己
		curPos = cc.p(baseX + 146, baseY -112)
	elseif isLeft then 	   -- 如果是左边的用户
		curPos = cc.p(baseX + 95, baseY)
	else 				   -- 如果是右边的用户
		curPos = cc.p(baseX - 110, baseY)
	end
	oddsParent:setPosition(curPos)
end

function Player:updateOddsVal(oddVal)
	if (self.oddsLabel == nil) then 
		self:initOddsView()
	end

	self.oddsLabel:setString(oddVal.."%")
end

function Player:initOddsView()
	if self._seatType == StatusCode.NO_STATUS then 
		return
	end
	local node = cc.Node:create()
    local sp = UIUtil.addPosSprite("insurance/self_winrate.png", cc.p(0,0), node, cc.p(0.5, 0.5))
    local label =  UIUtil.addLabelArial("0%", 24, cc.p(0,0), cc.p(0.5, 0.5), node, cc.c3b(255, 255, 255))
    -- node:setPosition(cc.p(self:getContentSize().width/2, self:getContentSize().height/2))
   	self._node:addChild(node)
    self.oddsLabel = label
    self:LayoutOddsPos()
end

function Player:initDealTag()
	self._imgD = UIUtil.addPosSprite(ResLib.GAME_TAG_D, cc.p(0, self:getCY()-69), self._node, nil)
	self:hideD()
	
	local cx = self:getCX()
	local tw = self:getW()
	local tDx = cx + 80
	local maxpos = GJust.splitPos()
	--右
	if self:getRunPos() >= maxpos then
		tDx = cx - 80
	end
	self._imgD:setPositionX(tDx)
end

function Player:initPlayer(runPos, pos)
	-- self:initWithColor(cc.c4b(23,233,23,0))
	self:setContentSize(300,300)
	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(cc.p(0.5,0.5))

	--运行位置、真正位置、自己
	self._runPos = runPos
	self._pos = pos
	self._seatType = StatusCode.NO_STATUS

	self._node = cc.Node:create()
	self:addChild(self._node)

	self:initDealTag()
	
	--公共显示
	self._dobj = nil

	--坐下标示、空头像
	self._ttfSeat = nil
	self._nullHead = nil
end

function Player:hideD()
	if self._imgD then 
		self._imgD:setVisible(false)
	end
end

function Player:disD()
	if self._imgD then 
		self._imgD:setVisible(true)
	end
end


function Player:ctor(runPos, pos)
	self:initPlayer(runPos, pos)
end



--数据
function Player:resetRoundLayer()
end

return Player