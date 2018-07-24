local GDisplay = class('GDisplay')

function GDisplay:hideD()
	self._D:setVisible(false)
end
function GDisplay:disD()
	self._D:setVisible(true)
end

function GDisplay:hideStatus(smodel)
	--弃牌、allin 的一直显示
	local status = smodel:getStatus()
	if status == StatusCode.GAME_GIVEUP or status == StatusCode.GAME_ALLIN then
		return
	end
	self._status:setVisible(false)
end
function GDisplay:disStatus(smodel)
	local timg = DZConfig.getStatusImg(smodel:getStatus())
	if timg then
		self._status:setVisible(true)
		self._status:setTexture(timg)
	end
end

function GDisplay:hideNowBet()
	self._nowBet:setVisible(false)
	self._nowBetbg:setVisible(false)
	self._isDisNowBet = false
end
function GDisplay:disNowBet(smodel)
	if smodel:getBetNum() == 0 then return end
	self._isDisNowBet = true
	self._nowBet:setVisible(true)
	self._nowBetbg:setVisible(true)

	local nnum = GMath.changeNumKW(smodel:getBetNum())
	self._nowBet:setString(nnum)

	self._nowBetbg:setTexture(ResLib.GAME_BET_TAG)
	if smodel:isBigBlind() then
		self._nowBetbg:setTexture('game/game_b.png')
	elseif smodel:isSmallBlind() then
		self._nowBetbg:setTexture('game/game_s.png')
	end
end

function GDisplay:isDisNowBet()
	return self._isDisNowBet
end

function GDisplay:hideSurplusBet()
	self._surplusBetbg:setVisible(false)
	self._surplusBet:setString('')
end
function GDisplay:disSurplusBet(smodel)
	--请求带入显示问题
	-- if smodel:getApplyTime() ~= 0 then
	-- 	self:hideSurplusBet()
	-- 	return
	-- end

	local snum = GMath.changeNumKW(smodel:getSurplusNum())
	self._surplusBetbg:setVisible(true)
	self._surplusBet:setString(snum)
end
function GDisplay:updateSurplusBet(smodel)
	local snum = GMath.changeNumKW(smodel:getSurplusNum())
	self._surplusBet:setString(snum)
end


--player selfLayer调用

--头像变灰
-- function GDisplay:disGrayHead(head, rankNum)
function GDisplay:disGrayHead(parent, pos, rankNum)
	if parent:getChildByName('DIS_GRAY_HEAD') then return end
	
	local sngNode = cc.Node:create()
	sngNode:setName('DIS_GRAY_HEAD')
	sngNode:setLocalZOrder( GMath.getMaxZOrder() )
	parent:addChild(sngNode)

	local sngRankBG = UIUtil.addPosSprite('game/game_rankbg.png', pos, sngNode, nil)
	sngRankBG:setLocalZOrder(4)
	local ttfpos = cc.p(85/2,85/2)
	UIUtil.addLabelBold(rankNum, 55, ttfpos, cc.p(0.5,0.5), sngRankBG, cc.c3b(255,255,255))
end


--action
function GDisplay:moveToNowBet(endBack)
	DZPlaySound.playBet()
	local tx1,ty1 = self._surplusBetbg:getPosition()
	local tx2,ty2 = self._nowBetbg:getPosition()
	--0.5
	local moveTime = GUI.getMoveBetToNowTime1()
	GUI.runMoveBet(cc.p(tx1,ty1), cc.p(tx2,ty2), moveTime, self._surplusBetbg:getParent(), endBack)
end

function GDisplay:moveToPoolBet(endBack)
	DZPlaySound.playGameSound("sound/game/movetopot.mp3", false)
	local GameLayer = require 'game.GameLayer'
	GameLayer:movePoolBet(self._nowBetbg, StatusCode.BET_TO_POOL, endBack)
end

function GDisplay:moveToWinBet(endBack)
	local GameLayer = require 'game.GameLayer'
	GameLayer:movePoolBet(self._surplusBetbg, StatusCode.POOL_TO_WIN, endBack)
end

function GDisplay:ctor(uiArr)
	self._isDisNowBet = false
	
	self._D 			= uiArr[1]
	self._status 		= uiArr[2]
	self._nowBet 		= uiArr[3]
	self._nowBetbg 		= uiArr[4]
	self._surplusBetbg 	= uiArr[5]
	self._surplusBet 	= uiArr[6]
	self._ttfSngRank 	= uiArr[7]
end

return GDisplay