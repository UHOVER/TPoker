local UpdatePlayer = class('UpdatePlayer', require 'game.Player')

--common
function UpdatePlayer:getPlayer()
	local tpl = self
	if self:isSelf() then 
		if self:isVisible() then --等于true 才设置
			self:setVisible(false)
		end
		tpl = SelfLayer
	end

	return tpl
end

--2020头像变灰显示名次
function UpdatePlayer:disGrayHeadRankFather(rankNum)
	local tpl = self:getPlayer()
	tpl:disGrayHeadRank(rankNum)
end

--弃牌动画
function UpdatePlayer:runGiveUpFather(user, aniEndBack)
	DZPlaySound.playFold()

	local tpl = self:getPlayer()
	tpl:runGiveUp(user, aniEndBack)
end

--界面相关的回合数据
function UpdatePlayer:resetRoundLayerFather(user)
	local tpl = self:getPlayer()
	tpl:resetRoundLayer()
	tpl:disWait(user)
end

--显示赢家
function UpdatePlayer:disWinnerFather(aniEndBack)
	local tpl = self:getPlayer()
	tpl:disWinner(aniEndBack)
end

--显示说话玩家
function UpdatePlayer:disSaidFather(rtime)
	local tpl = self:getPlayer()
	tpl:disSaid(rtime)
end

--显示说话玩家设定了时间
function UpdatePlayer:disSaidTimeFather(saidTime)
	local tpl = self:getPlayer()
	tpl:disSaid(saidTime)
end

--隐藏说话玩家
function UpdatePlayer:hideSaidFather()
	local tpl = self:getPlayer()
	tpl:hideSaid()
end

--隐藏all
function UpdatePlayer:hideAllFather()
	local tpl = self:getPlayer()
	tpl:hideAll()
end

--显示发牌标示
function UpdatePlayer:disTwoPokerTagFather()
	local tpl = self:getPlayer()
	tpl:disTwoPokerTag()
end

--2026亮牌
function UpdatePlayer:showdownFather(cardNum1, cardNum2)
	if self:isStand() then return end
	local tpl = self:getPlayer()
	tpl:showdown(cardNum1, cardNum2)
end

--2014申请补充记分牌广播
function UpdatePlayer:applayTimeFather(applyTime)
	if self:isStand() then return end
	local tpl = self:getPlayer()
	if applyTime ~= 0 then
		tpl:applayTime(applyTime)
	end
end

--sng/mtt 2022托管
function UpdatePlayer:setUITrusteeshipFather(udata)
	if self:isStand() then return end
	local tpl = self:getPlayer()
	tpl:setUITrusteeship(udata:isTrusteeship(), udata:isTeam())
end

function UpdatePlayer:setPresentTeamMark(udata)
	if self:isStand() then return end
	local tpl = self:getPlayer()
	tpl:setTeamMark(udata:isTeam())
end
--等待
function UpdatePlayer:disWaitFather(udata)
	local tpl = self:getPlayer()
	tpl:disWait(udata)
end

--1000初始化状态：自己弃牌变灰色
function UpdatePlayer:initDisStatusFather(status)
	local tpl = self:getPlayer()
	tpl:initDisStatus(status)
end

--2024发送动画
function UpdatePlayer:disAnimationFather(udata)
	local tpl = self:getPlayer()
	tpl:disAnimation(udata:getAniTag())
end

--2016 2017申请通过或拒绝,移除申请倒计时
function UpdatePlayer:removeApplayTimeFather()
	local tpl = self:getPlayer()
	tpl:removeApplayTime()
end

--2015补充记分牌广播
function UpdatePlayer:updateSurplusBetFather(udata)
	if self:isStand() then return end
	local tpl = self:getPlayer()
	tpl:getDObj():updateSurplusBet(udata)
end



function UpdatePlayer:disNowBetObj(user)
	local tpl = self:getPlayer()
	tpl:getDObj():disNowBet(user)
end


function UpdatePlayer:moveToNowBetObj(aniEndBack)
	local tpl = self:getPlayer()
	tpl:getDObj():moveToNowBet(aniEndBack)	
end

function UpdatePlayer:isDisNowBetObj()
	local tpl = self:getPlayer()
	return tpl:getDObj():isDisNowBet()
end

function UpdatePlayer:moveToPoolBetObj(aniEndBack)
	local tpl = self:getPlayer()
	tpl:getDObj():moveToPoolBet(aniEndBack)
end

function UpdatePlayer:moveToWinBetObj(aniEndBack)
	local tpl = self:getPlayer()
	tpl:getDObj():moveToWinBet(aniEndBack)
end

function UpdatePlayer:disStatusObj(user)
	local tpl = self:getPlayer()
	tpl:getDObj():disStatus(user)
end

function UpdatePlayer:disSurplusBetObj(user)
	local tpl = self:getPlayer()
	tpl:getDObj():disSurplusBet(user)
end

function UpdatePlayer:hideStatusObj(user)
	local tpl = self:getPlayer()
	tpl:getDObj():hideStatus(user)
end

function UpdatePlayer:hideNowBetObj()
	local tpl = self:getPlayer()
	tpl:getDObj():hideNowBet()
end

function UpdatePlayer:disDObj()
	local tpl = self:getPlayer()
	tpl:disD()
end

function UpdatePlayer:hideDObj()
	local tpl = self:getPlayer()
	tpl:hideD()
end


--获取玩家手牌的位置
function UpdatePlayer:getCardPos()
	local tpl = self:getPlayer()
	local cp = tpl:getPokerPos()
	return cp
end

function UpdatePlayer:showApokerFather(round)
	local tpl = self:getPlayer()
	tpl:showPoker(round)
end



--2000自己坐下动画后替换显示
function UpdatePlayer:disSelfLayer(udata)
	local tpl = self:getPlayer()
	if tpl:isSelf() then
		tpl:disWait(udata)
	end
end

--是不是站起
function UpdatePlayer:isStand()
	if self:getSeatType() == StatusCode.SEAT_NULL then
		return true
	end
	return false
end

--是不是坐下
function UpdatePlayer:isSeat()
	return not self:isStand()
end

--玩家站起
function UpdatePlayer:standCall()
	-- self:stopAllActions()
	local text = '空位'
	if self:isSelf() then
		text = '坐下'
		Single:playerManager():changeSeatText(text)

		self:setVisible(true)
		SelfLayer:standCall()
	else
		if GSelfData.isHavedSeat() then
			text = '坐下'
		end
	end

	self:removeApplayTime()

	self:addNull(text)
	self:setUserData(nil)
end



--初始化数据
function UpdatePlayer:initData(udata)
	self:userUI(udata)
	self:setUserData(udata)
end

function UpdatePlayer:ctor(runPos, pos)
	self:initPlayer(runPos, pos)
end

return UpdatePlayer