local GameHelp = {}

--底池1/2、2/3、1对应的值
function GameHelp.selectPoolsValue()
	local rets = {}

	local gm = Single:gameModel()
	local selfModel = GSelfData.getSelfModel()
	local poolNum = gm:getPoolNowBet()
	local betNum = selfModel:getBetNum()
	local maxBet = GData.getMaxBetNum()
	local followBet = maxBet - betNum --计算出我的跟注
	if followBet < 0 then 
		Single:appLogs('| GameHelp.selectPoolsValue followBet is '..followBet..'maxBet'..maxBet..'betBet'..betNum..'poolNum'..poolNum..' |')
	end
	--[[ (公式： X 底池，  Y本轮下注和，Z当前玩家需要补齐的跟注  B结果)
		1倍:   (X+Y+Z)*1 + Z 
	   2/3:   (X+Y+Z)*2/3 + Z
	   1/2:	  (X+Y+Z)*1/2 + Z
	]]--
	-- print("poolNum", poolNum,"betNum", betNum,"maxBet",maxBet)
	local totalPool = poolNum + followBet
	-- local needbet = GMath.getMeNeedBet()
	-- if poolNum < 4 * needbet then
	-- 	poolNum = 4 * needbet
	-- end
	local text = {'x1/2', 'x2/3', 'x1'}
	local pool1 = math.floor((totalPool) / 2 + followBet)
	local pool2 = math.floor(totalPool / 3 * 2 + followBet)
	local pool3 = math.floor(totalPool + followBet)

	local sblind = gm:getSmallBlind()
	local mblind = sblind * 2
	local imgBtns = {ResLib.GAME_POOL_BTN1, ResLib.GAME_POOL_BTN1, ResLib.GAME_POOL_BTN2}
	-- if poolNum == mblind + sblind then
	if GJust.isRoundFirstAddBet() then
		text = {'x2', 'x3', 'x4'}
		imgBtns = {ResLib.GAME_BTN_BIG_BLIND1,ResLib.GAME_BTN_BIG_BLIND1,ResLib.GAME_BTN_BIG_BLIND2}
		pool1 = math.floor(mblind * 2)
		pool2 = math.floor(mblind * 3)
		pool3 = math.floor(mblind * 4)
	end

	table.insert(rets, pool1)
	table.insert(rets, pool2)
	table.insert(rets, pool3)

	return rets, text, imgBtns
end

--设置pool按钮
function GameHelp.checkPoolsBtn()
	local msurp = GSelfData.getSelfModel():getSurplusNum()
	local pools,text,imgBtns = GameHelp.selectPoolsValue()
	local needBet = GMath.getMeNeedBet()

	local function getBool(pbet)
		-- pbet == 0回合底池为0、pbet <= needBet算加注
		if msurp - pbet < 0 or pbet == 0 or pbet <= needBet then
			return false
		end
		return true
	end

	local pf1 = getBool(pools[1])
	local pf2 = getBool(pools[2])
	local pf3 = getBool(pools[3])

	local ptfs = {pf1, pf2, pf3}
	local rets = {ptfs , text, pools,imgBtns}
	return rets
end


--GameLayer
--语音按钮
function GameHelp.handleVoice(parent)
	local img1 = 'game/game_voice_press1.png'
	local img2 = 'game/game_voice_press2.png'
	local img3 = 'game/game_voice.png'

	local voiceBtn = UIUtil.addPosSprite(img3, cc.p(730,12), parent, nil)
	voiceBtn:setAnchorPoint(1,0)
	voiceBtn:setLocalZOrder(GMath.getMaxZOrder() + 1)

	local prebg = nil
	local ttfTime = nil
	local ptb = nil
	local count = 10

	local vprompt = parent:getChildByName('imgVoicePrompt')
	vprompt:setLocalZOrder(3)
	vprompt:setOpacity(0)

	local nullbtn = UIUtil.addPosSprite('game/game_null.png', cc.p(-19,5), voiceBtn, nil)
	nullbtn:setOpacity(0)
	nullbtn:setAnchorPoint(0,0)

	local isIn = false
	local isBegin = false

	local function sendVoice()
		DZPlaySound.gameResumeAll()
		
		if isIn then
			DZChat.sendRecord()
		else
			DZChat.cancelRecord()
		end
	end

	--结束和10秒回调
	local function progressBack(isEnd)
		if ptb then
			ptb:removeFromParent()
			ptb = nil

			--时间10s到了
			if isEnd ~= true then
				isIn = true
			end

			sendVoice()
		end
		if prebg then
			prebg:removeFromParent()
			prebg = nil
		end
		if ttfTime then
			ttfTime:removeFromParent()
			ttfTime = nil
		end
		vprompt:setOpacity(0)

		nullbtn._isBegin = false
	end

	local function timeBack()
		if count <= 0 then return end
		count = count - 1
		if ttfTime then
			ttfTime:setString(count)
		end
	end

	local function voiceEnd(event)
		if isBegin then
			progressBack(true)
		end
	end
	local function voiceBegin(event)
		DZPlaySound.playGear()
		DZChat.startRecord()

		DZPlaySound.gamePauseAll()

		count = 10
		vprompt:setOpacity(255)
		vprompt:setTexture(img1)
		
		local pos = cc.p(display.width/2 + 10, 18)
		prebg = UIUtil.addPosSprite('game/game_voice_pregress2.png', pos, parent)
		ptb = DZAction.ProgressToBack(0, 100, 10, 'game/game_voice_pregress1.png', pos, parent, progressBack)
		ttfTime = UIUtil.addLabelArial(count, 22, pos, cc.p(0.5,0.5), parent, cc.c3b(255,255,255))

		DZSchedule.runSchedule(timeBack, 1, ttfTime)

	end
	local function moveIn()
		isIn = true
		vprompt:setTexture(img1)
	end
	local function moveOut()
		isIn = false
		vprompt:setTexture(img2)
	end


	local function touchBack(event)
		if event.name == "began" then
			if not isBegin then
				isBegin = true
	            voiceBegin()
	        end
        elseif event.name == "ended" then
        	voiceEnd()
			isBegin = false
        elseif event.name == "cancelled" then 
        	voiceEnd()
			isBegin = false
        end
	end
	parent:getChildByName('btnVoice'):onTouch(touchBack)
	parent:getChildByName('btnVoice'):setOpacity(0)

	nullbtn.movedBack = moveIn
	nullbtn.moveOutBack = moveOut
	TouchBack.registerImg(nullbtn)

	return voiceBtn
end

function GameHelp.personVoice(parent, vname, time)
	local vnode = cc.Node:create()
	parent:addChild(vnode)

	local vname = UIUtil.addLabelArial(vname, 25, cc.p(display.cx, 20), cc.p(0.5,0.5), vnode, cc.c3b(255,255,255))
	local vx = vname:getContentSize().width / 2 + display.cx + 20
	UIUtil.plistAni(ResLib.EFFECT_VOICE, cc.p(vx,20), vnode, 0.4, 'game_voice', 4, true)

	DZAction.delateTime(vnode, time, function()
		vnode:removeFromParent()
	end)
end


function GameHelp.getDelaySprite()
	local runScene = cc.Director:getInstance():getRunningScene()
	local delaySprite = nil
	local gameNode = runScene:getChildByName(GAME_SCENE_NODE)
	if gameNode then
		delaySprite = gameNode
	end

	return delaySprite
end


--分池
--imgPool:当前底池bg、ttfPool:当前底池值
function GameHelp.manyPool(nodePool, imgPool, pools)
	nodePool:setPositionX(display.cx)

	for i=1,10 do
		nodePool:getChildByName('game_side'..i):setVisible(false)
	end

	for i=1,#pools do
		local poolBg = nodePool:getChildByName('game_side'..i)
		local ttfPool = poolBg:getChildByName('poolVal')
		poolBg:setVisible(true)
		ttfPool:setString(pools[ i ])
		GUI.setStudioFontBold({ttfPool})
	end

	imgPool:setPositionY(display.height * 0.55)
end


return GameHelp