local GUI = {}

--设置字体
function GUI.setStudioFontBold(ttfs)
	for i=1,#ttfs do
		ttfs[ i ]:setFontName('Helvetica-Bold')
	end
end

--看牌提示
function GUI.lookPokerPrompt(name, roundNum, parent)
	local roundName = GText.getRoundNameByNum(roundNum)
	--底池牌的上面
	local oneY = GMath.getPoolCardPercentY(POKER_Y_LOOK) / 100 * display.height + 94
	local cx = display.cx
	local img = 'common/com_line_bg1.png'
	local posY = {oneY+124, oneY+62, oneY}

	local prompt = UIUtil.addPosSprite(img, cc.p(cx,posY[ roundNum ]), parent, nil)

	local color1 = cc.c3b(255,255,255)
	local color2 = cc.c3b(3,140,221)
	local psize = prompt:getContentSize()
	local cy = psize.height / 2
	local fsize = 28
	UIUtil.addLabelBold(name, fsize, cc.p(260,cy), cc.p(1,0.5), prompt, color2)
	UIUtil.addLabelBold('想看', fsize, cc.p(260,cy), cc.p(0,0.5), prompt, color1)
	UIUtil.addLabelBold(roundName, fsize, cc.p(399,cy), cc.p(1,0.5), prompt, color2)
	UIUtil.addLabelBold('会发什么牌', fsize, cc.p(399,cy), cc.p(0,0.5), prompt, color1)

	GUI.lineImgYScale(prompt, function()end)
end



--action
--

--线提示y放大张开
function GUI.lineImgYScale(line, back)
	line:setScaleY(0)
	DZAction.scale(line, cc.p(1,0.5), cc.p(1,1), 0.2, nil, back)
end

--我思考时特效
function GUI.particleSelfUI(img, pos1, parent, pos2)
	local particle = UIUtil.addPosSprite(img, pos1, parent, nil)
	local par = cc.ParticleSystemQuad:create(ResLib.XING_PARTICLE)
    par:setPosition(pos2)
    local batchParNode = cc.ParticleBatchNode:createWithTexture(par:getTexture())
    batchParNode:addChild(par)
    particle:addChild(batchParNode)
    particle:setOpacity(0)

    return particle
end


--多个筹码移动
function GUI.runMoveBet(fpos, tpos, time, parent, endBack)
	local imgs = {}
	local tEndBack = endBack

	local betNum = GUI.getMoveBetNum()
	for i=0,betNum-1 do
		local betImg = UIUtil.addPosSprite(ResLib.GAME_BET_TAG, fpos, parent, nil)
		betImg:setLocalZOrder(15+betNum-i)
		table.insert(imgs, betImg)
		betImg:setVisible(false)
		betImg:setOpacity(255*(1- i*0.8/(betNum-1)))
	end

	local interval = GUI.getMoveBetIntervalTime1()
	for i=1,#imgs do
		local timg = imgs[ i ]

		local callfunc = cc.CallFunc:create(function()
			timg:removeFromParent()
			-- print("移动筹码 i:"..i.."#imgs"..#imgs.."back:"..tostring(tEndBack))
			if i == #imgs and tEndBack then 
				tEndBack()
			end
		end)
		local delTime = (i - 1) * interval
		local dealy = cc.DelayTime:create(delTime)
		local move = cc.MoveTo:create(time, tpos)
		-- local easeIn = cc.EaseIn:create(move, 2.5)
		timg:setVisible(true)
		local  seq = cc.Sequence:create(dealy, move, callfunc)
		timg:runAction(seq)
	end
end

--表情
function GUI.showEmoji(pos, parent, idx)
	local idx = tonumber(idx)
	local anis = nil
	local function aniBack()
		if anis then
			anis:removeFromParent()
			anis = nil
		end
	end

	local prefix = DZConfig.getEmojiPreFix(idx)
	local frameNum = DZConfig.getEmojiFrameNum(idx)
	local name = DZConfig.getEmojiName(idx)
	anis = UIUtil.plistAni(name, pos, parent, 0.15, prefix, frameNum, false, aniBack)
	anis:setLocalZOrder( GMath.getMaxZOrder() )

	return anis
end

--贞动画
function GUI.showAni(pos, parent, tag)
	local anis = nil
	local function aniBack()
		if anis then
			anis:removeFromParent()
			anis = nil
		end
	end

	local prefix = DZConfig.getAniPreFix(tag)
	local frameNum = DZConfig.getAniFrameNum(tag)
	local interval = 0.12
	if tag == ResLib.EFFECT_PANDA then
		interval = 0.07
	end
	anis = UIUtil.plistAni(tag, pos, parent, interval, prefix, frameNum, false, aniBack)
	anis:setLocalZOrder( GMath.getMaxZOrder() )
end

--翻转卡牌
-- 1张0.5=0.5、3张0.5+0.2=0.7、4张0.5+0.2+0.5-1.2、5张0.5+0.2+0.5+0.5=1.7
-- FIX  3张是翻转0.18+0.15+0.36   一张 0.15+0.15
function GUI.poolPokers(pokers, posarr, cscale, endBack, opacityVal)
	if not endBack then
		endBack = function()end
	end
	if #pokers < 1 then
		endBack()
		return 
	end

	if not opacityVal then
		opacityVal = 255
	end

	local maxIndex = math.min(3, #pokers)

	local tfirst = pokers[ maxIndex ]
	local fsize = tfirst:getParent():getContentSize()

	local function getPokerBg(pos)
		local pokerBg = UIUtil.addSprite(ResLib.COM_CARD, pos, tfirst:getParent(), nil)
		pokerBg:setLocalZOrder(5)
		pokerBg:setScale(cscale)
		pokerBg:setOpacity(opacityVal)
		return pokerBg
	end


	for i=#pokers,1,-1 do
		local pos = StringUtils.getPercentPos(posarr[1].x, posarr[1].y)
		pokers[i]:setPosition(pos)
		if i ~= maxIndex then -- 第四第5张才隐藏
			pokers[i]:setVisible(false)
		end

		pokers[i]:setOpacity(opacityVal)
	end

	local rbg = getPokerBg(posarr[1])
	local time1 = 0.18
	local time2 = 0.15
	local time3 = 0.36
	--不止一张牌
	if #pokers == 1 then 
		time1 = 0.15
	end
	
	local function delayCallBack()
		DZAction.delateTime(nil, 0.5, endBack)
	end
	--三个移动完
	local isMove = false
	local function moveEndBack()
		if isMove then return end
		isMove = true

		if #pokers <= 3 then
			--2-3个移动完成
			delayCallBack()
			return 
		end

		--5个移动完成
		-- local function fiveBack()
		-- 	delayCallBack()
		-- end

		--第5个
		local function fourBack()
			--4个移动完成
			if #pokers < 5 then
				delayCallBack()
				return 
			end
			local fifth = pokers[ 5 ]
			local fivebg = getPokerBg(posarr[5])
			DZAction.flipTwoSprite(fivebg, fifth, time2, delayCallBack, nil, time2)
		end

		--第4个
		local fourth = pokers[ 4 ]
		local fourbg = getPokerBg(posarr[4])
		DZAction.flipTwoSprite(fourbg, fourth, time2, fourBack, nil, time2)
	end

	local function rotateBack()
		rbg:removeFromParent()
		--1个移动完成
		if #pokers == 1 then
			delayCallBack()
			return
		end
		
		for i=#pokers,1,-1 do
			--2、3移动 1 翻滚
			local pos = StringUtils.getPercentPos(posarr[i].x, posarr[i].y)
			if i < 4 then
				pokers[i]:setVisible(true)
				if i == 1 then break end
				DZAction.easeInMove(pokers[ i ], pos, time3, DZAction.MOVE_TO, moveEndBack)
			else
				pokers[ i ]:setPosition(pos)
			end
		end
	end

	DZPlaySound.playFlop()
	DZAction.flipTwoSprite(rbg, tfirst, time1, rotateBack, nil, time2)
end


--还有多久牌局结束提示
function GUI.showPromptTime(text)
    local runScene = cc.Director:getInstance():getRunningScene()
	local prompt = UIUtil.addLabelArial('剩余时间：'..text, 35, cc.p(display.width/2,0), cc.p(0.5,1), runScene, cc.c3b(255,255,255))
	local function fadeFunc()
		DZAction.fadeInOut(prompt, 5, tag, function()
			prompt:removeFromParent()
		end)
	end

	DZAction.easeInMove(prompt, cc.p(display.width/2,60), 0.3, DZAction.MOVE_TO, function()
		DZAction.delateTime(prompt, 1, fadeFunc)
	end)
end

--mtt游戏开始倒计时
function GUI.mttStartCountDown(parent, time, funcBack)
	parent:removeAllChildren()
	parent:setPositionX(display.cx)
    local runScene = cc.Director:getInstance():getRunningScene()
    local color = cc.c3b(254,240,163)

	local text1 = '比赛将在     秒后开始'
	UIUtil.addLabelBold(text1, 44, cc.p(269.5,86), cc.p(0.5,0.5), parent, cc.c3b(255,255,255))
	local label = UIUtil.addLabelBold(time, 44, cc.p(271,86), cc.p(0.5,0.5), parent, color)

	local tenLabel = nil
	local ten = 10
	local function scheduleTen()
		ten = ten - 1
		tenLabel:setString(ten)

		if ten < 0 then
			tenLabel:removeFromParent()
			funcBack()
		end
	end

	local function startSchedule()
		scheduleTen()
		DZSchedule.runSchedule(scheduleTen, 1, tenLabel)
	end

	local function scheduleFunc()
		time = time - 1
		label:setString(time)
		if time == 10 then
			parent:removeAllChildren()
			parent:setPositionX(-display.cx)
			tenLabel = UIUtil.addLabelBold(ten, 150, display.center, cc.p(0.5,0.5), runScene, color)
			tenLabel:setScale(3)
			DZAction.scale(tenLabel, cc.p(1,1), cc.p(1,1), 0.5, false, startSchedule)
		end
	end
	DZSchedule.runSchedule(scheduleFunc, 1, label)
end


--mtt中场休息倒计时
function GUI.mttRestCountDown(text, time, parent)
	parent:removeAllChildren()
	parent:setPositionX(display.cx)
	local tx = 322
	if text == '中场休息' then
		tx = 296
	end
	
	local color = cc.c3b(254,240,163)
	local counttime = DiffType.getRestSeconds()
	local timeText = DZTime.secondsMinFormat(counttime)
	UIUtil.addLabelBold(text, 44, cc.p(tx,86), cc.p(1,0.5), parent, cc.c3b(255,255,255))
	local label = UIUtil.addLabelBold(timeText, 44, cc.p(tx+2,86), cc.p(0,0.5), parent, color)

	local function scheduleFunc()
		-- if time <= 0 then return end
		-- time = time - 1
		local counttime = DiffType.getRestSeconds()
		timeText = DZTime.secondsMinFormat(counttime)
		label:setString(timeText)
	end
	DZSchedule.runSchedule(scheduleFunc, 1.01, label)
end

function GUI.mttAwardHint(imgUrl)
	if not imgUrl then 
		do return end
	end
	local runScene = cc.Director:getInstance():getRunningScene()
  	local RewardHint = require("app.game.RewardHint")
  	local rewardLayer = RewardHint.new()
  	runScene:addChild(rewardLayer, ZOR_MAX_WINDOW)
  	rewardLayer:show()
  	local function successDown(path) 
    	print(" successDown path "..tostring(path))
   		if rewardLayer and rewardLayer:getParent() then 
	    	rewardLayer:setInfoImage(path)
	    end
    end
    local function errorDown(path) 
    	print(" errorDown path "..tostring(path))
    	successDown(path)
    end
    local resName = CppPlat.downResFile(imgUrl, successDown, errorDown, ResLib.REWARD_TEXT, "rewardHintIdentifier")
end

--翻玩家两张手牌,延迟一会后消失
function GUI.showDelayTwoPoker(card, cpos, time2, time3, callBack)
	DZAction.delateTime(card, time2, function()
		DZAction.fadeInOut(card, time3, DZAction.FADE_OUT, function()
			callBack()
		end)
	end)
end

--翻手牌回调,
function GUI.flipPokerBack(card, cpos, time, flipBack)
	local rbg = UIUtil.addPosSprite(ResLib.COM_CARD, cpos, card:getParent(), nil)
	rbg:setScale(0.45)

	DZAction.flipTwoSprite(rbg, card, time, function()
		rbg:removeFromParent()
		flipBack()
	end)
end

--显示保险模式的图片
function GUI.showInsuranceMode(spPath, parent, back)
	 local target = display.newSprite(spPath)
	 local startPos = cc.p(display.width + target:getContentSize().width, display.height/2)
	 local endPos = cc.p(display.width/2, display.height/2)

	 target:setPosition(startPos)
	 parent:addChild(target)

     local function removeFunc()
     	back()
     	parent:removeChild(target, true)
     	-- display.removeTexture(target:getTexture())
     	-- DZAction.delateTime(parent, 1/24, function() 
     	-- 	cc.Director:getInstance():getTexture():removeTexture(target:getTexture())
     	-- 	end)
     end

     local goOne =  cc.EaseIn:create(cc.MoveTo:create(0.2, cc.p(endPos.x - 10, endPos.y)), 2.5)
     local shakeOne = cc.EaseIn:create(cc.MoveTo:create(0.05, cc.p(endPos.x + 10, endPos.y)), 2.5)
     local shakeTwo = cc.EaseIn:create(cc.MoveTo:create(0.05, cc.p(endPos.x - 10, endPos.y)), 2.5)
     local shakeThree = cc.EaseIn:create(cc.MoveTo:create(0.05, cc.p(endPos.x + 10, endPos.y)), 2.5)
     local shakeEnd = cc.EaseIn:create(cc.MoveTo:create(0.25, cc.p(endPos.x, endPos.y)), 2.5)
     local fadeOut = cc.FadeOut:create(0.15)
     local callback = cc.CallFunc:create(removeFunc)
     local sequence = cc.Sequence:create(goOne, shakeOne, shakeTwo,shakeThree,
     								shakeEnd, fadeOut, callback)
     target:runAction(sequence)
end

--~~~横向背景 保险提示~~
function GUI.showHorizontalHint(texts,back)
	local line  = #texts
	local bgSp = cc.Scale9Sprite:create("insurance/alert_bg.png")

	local posArr = nil
	if line == 1 then 
		posArr = {bgSp:getContentSize().height/2}
	elseif line == 2 then 
		bgSp:setContentSize(cc.size(614, 102))
		posArr = {76,34}
	elseif line == 3 then
		bgSp:setContentSize(cc.size(614,139))
		posArr = {109 ,69, 27}
	end
	bgSp:setCascadeOpacityEnabled(true)
	local runScene = cc.Director:getInstance():getRunningScene()

	local startPos = cc.p(display.width/2, 0 - bgSp:getContentSize().height/2)
	local endPos = cc.p(display.width/2, display.height/2)
	bgSp:setPosition(startPos)
	runScene:addChild(bgSp)

	local color = nil
	for i = 1, line do
		if line > 1 and i == 1 then 
			color = cc.c3b(238,186,85)
		else 
			color = cc.c3b(255,255,255)
		end
		UIUtil.addLabelArial(texts[i], 26, cc.p(bgSp:getContentSize().width/2,posArr[i]), 
							cc.p(0.5,0.5), bgSp, color)
	end
	
	local function fadeFunc()
		DZAction.fadeInOut(bgSp, 0.25, tag, function()
			if back then 
				back()
			end
			bgSp:removeFromParent()
		    -- cc.Director:getInstance():getTextureCache():removeTexture(bgSp:getTexture())
		end)
	end

	DZAction.easeInMove(bgSp, endPos, 0.25, DZAction.EASE_IN, function()
		DZAction.delateTime(bgSp, 2, fadeFunc)
	end)
end



--动画时间

--从剩余记分牌移动到当前押注
function GUI.getMoveBetToNowTime1()
	-- return 0.4
	return 0.28
end

--移动6个虚拟筹码间隔时间每个是0.05后在移动下一个
function GUI.getMoveBetIntervalTime1()
	-- return 0.05
	return 0.04
end

--移动筹码个数
function GUI.getMoveBetNum()
	return 6
end


--替换按钮图片
function GUI.replaceUIButtonImg(button, normalImg, clickedImg, disabledImg)
	local normal = button:getRendererNormal()
    normal:initWithFile(normalImg)

    local clicked = button:getRendererClicked()
    clicked:initWithFile(clickedImg)

    local disabled = button:getRendererDisabled()
    disabled:initWithFile(disabledImg)
end

return GUI