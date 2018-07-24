local DZPlaySound = require('gambling.DZPlaySound')
local scrollActionLogic = require('gambling.RunScrollActionLogic')
local scrollTxtLabelLogic = require("gambling.RunScrollTxtLabelLogic")

--cocostudio显示牌型5个panel
local showPanelArr = {}
local showPanelInitPosY = {}
--cocostudio显示牌型滚动的5个panel
local scrollPanelArr = {}
--cocostudio root根节点
local root = nil
--0没锁住 1锁住
local lockState = {[1]=1,[2]=0,[3]=0,[4]=0,[5]=0}
--记录出牌状态 0第一次出牌 1第二次赚牌
local goFlag = 0
local _count = nil--老虎机次数

local GamblingLayer = {}
local _layer = nil

--滚动数字控件
local aLabel_touzhu = {}
local aLabel_baiju = {}
local aLabel_getjifen = {} 
local aLabel_jifen = {}
local aLabel_jackp = {}
local aLabel_test = {}

local touzhu_num = 0--投注金额
local getJiFen_num = 0--赢取的积分累加
local firstRetData = {}--第一次返回数据
local seondRetData = {}--第二次返回数据
local daxiaoRetData = {}--比大小返回数据

local lockObjArr = {}--锁头对象
local flagNum = 1--第二次返回时候纪录动画次数
local currflagNum = 1--当前返回动画次数
local game1 = nil--游戏滚动层
local game2 = nil--游戏翻牌层
local isFanPai = false--是否可以翻牌
local paiObjArr = {}--翻牌对象 
local isDaXiao = -1--0小 1大
local schedulerEntryJack = nil--jackpop计时器
local schedulerEntrySendMeg = nil--开始发送消息计时器
local schedulerEntryUpdateUI = nil--更新UI
local showDlg = {}--显示对话框
local g_fTime = 0.05--全局翻牌时间
local g_game1winDlg = {}--老虎机界面胜利对话框
local g_game2loseDlg = {}--老虎机界面失败对话框 
local g_Panel_game1 = {}--老虎机滚动界面
local game2handType = 1--老虎机界面的牌型纪录
local currScore = nil--当前玩家底金
local betArr = {}--存储投注数组
local currBetIdx = 1
local beforeInGame2 = 10--进入比大小之前的牌型


local isUpdate_jackpot = false--更新jackpot
local isUpdate_bet = false--更新下注
local isUpdate_initGame = false--更新下注初始化信息
local isUpdate_ret1 = false--出牌返回1
local isUpdate_ret2 = false--出牌返回2

local jackpotNum = nil
local MAX_FP_NUM = 9--最大翻牌值
local isCanShowInGame = false--是否该显示询问进入比大小界面
local m_whichLayerIn_tag = 0--是那个界面进来的0-我的 1-大厅

local batchParNode = {}--粒子特效节点
local nameRet = {
[1] = '皇家同花顺',
[2] = '同花顺',
[3] = '四条', 
[4] = '葫芦', 
[5] = '同花', 
[6] = '顺子', 
[7] = '三条',
[8] = '两对', 
[9] = '对子',
[10] = '高牌'}
local gunSoundId = {
[1] = -1,
[2] = -1,
[3] = -1,
[4] = -1,
[5] = -1, 
}--滚动音效id
local BTN_SOUND = "sound/gambling/btn.wav"--按钮音效
local BGM_SOUND = "sound/gambling/bg.mp3"--背景音效
local GUN_SOUND = "sound/gambling/melon.wav"--滚动音效
local LUCKY_SOUND = "sound/gambling/lucky.wav"--获得积分或者奖励音效
local STOP_SOUND = "sound/gambling/bar.wav"--停止滚动音效
local FAIL_SOUND = "sound/gambling/fail.wav"--输了
--粒子特效
local PAR_JACKPOT = "particles/parBoom.plist"--粒子特效jackpot


local function adapterID()
	local id = Single:playerModel():getId()--31--  -->527
	return id
end

-------发送消息通讯的方法--------------------
--发送初始化游戏信息
local function sendInitGameMeg()
	--登录成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
--[[
			aLabel_baiju:setValue(data.data['count'])
			aLabel_jifen:setValue(data.data['scores'])
	]]		
			_count = data.data['count']
			goFlag = 0
			currScore = tonumber(data.data['scores'])

			isUpdate_initGame = true

			--各种按钮不可点击
			--ccui.Helper:seekWidgetByName(root, "Button_go"):setEnabled(true)
			
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/init", tabData, response, PHP_POST, true)
end

--发送第一次出牌协议
local function sendGo1()
	--登录成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			--aLabel_baiju:setValue(data.data['count'])
			--aLabel_jifen:setValue(data.data['scores'])
			firstRetData = {}
			firstRetData = data
			isUpdate_ret1 = true
			beforeInGame2 = firstRetData.data.handType
			--GamblingLayer:resultLogic()
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	tabData['bet'] = touzhu_num
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/bet", tabData, response, PHP_POST, true)
end

--发送第二次出牌协议
local function sendGo2()
	--登录成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			--aLabel_baiju:setValue(data.data['count'])
			--aLabel_jifen:setValue(data.data['scores'])
			seondRetData = {}
			seondRetData = data
			isUpdate_ret2 = true
			beforeInGame2 = seondRetData.data.handType
			--GamblingLayer:resultLogic2()
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	tabData['recordId'] = firstRetData.data.recordId
	tabData['lock'] = {}

	for i = 1, 5 do
		if(lockObjArr[i].value == true) then
			--协议索引从0开始 要减1
			table.insert(tabData['lock'], i - 1)
		end
	end

	--dump(tabData)
	XMLHttp.requestJSHttp("slot/bet/result", tabData, response, PHP_POST, true)
end

--发送进入翻牌界面初始化消息
local function sendInitGame2()
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			--aLabel_baiju:setValue(data.data['count'])

			--初始化一张牌
			paiObjArr[10 - game2handType].paiImg:runAction(cc.Sequence:create(
    		cc.ScaleTo:create(g_fTime, 0, 1),
            cc.CallFunc:create( 
                function(sender)
	                sender:loadTexture(DZConfig.cardName(data.data.card.key))
                end),
            cc.ScaleTo:create(g_fTime, 1, 1),
            cc.CallFunc:create( 
                function(sender)
	                isFanPai = true
	                local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
					btn:setEnabled(true)
					btn:setTouchEnabled(true)
					btn = ccui.Helper:seekWidgetByName(root, "Button_min")
					btn:setEnabled(true)
					btn:setTouchEnabled(true)
					btn = ccui.Helper:seekWidgetByName(root, "Button_over")
					btn:setEnabled(true)
					btn:setTouchEnabled(true)
                end)
            ))
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	tabData['recordId'] = firstRetData.data.recordId
	print("inhhhhhhhhh-------123")
	dump(tabData)
	XMLHttp.requestJSHttp("compare/init", tabData, response, PHP_POST, true)
end

--发送翻牌消息
local function sendFanPai()
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			--aLabel_baiju:setValue(data.data['count'])
			--_countDX = data.data['count']
			daxiaoRetData = {}
			daxiaoRetData = data
			GamblingLayer:resultLogicDaXiao()
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	tabData['recordId'] = firstRetData.data.recordId
	tabData['bigOrLittle'] = isDaXiao
	--print("ddddddddddddddd-----")
	--dump(tabData)
	XMLHttp.requestJSHttp("compare/turnover", tabData, response, PHP_POST, true)
end

--轮询发送jackPop
local function sendjackPop()
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			if(data.data['scores'] ~= nil) then
				isUpdate_jackpot = true
				jackpotNum = tonumber(data.data['scores'])
				--aLabel_jackp:setValue(data.data['scores'])
			end
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	--print("ddddddddddddddd-----")
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/jackpot/scores", tabData, response, PHP_POST, true)
end

--发送请求新的当前分数
local function sendGetNewCurrScore()
	--成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			
			aLabel_jifen:setValue(data.data['scores'])
			currScore = tonumber(data.data['scores'])
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/init", tabData, response, PHP_POST, true)
end

--发送请求投注
local function sendGetBetArr()
	--成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			--aLabel_jifen:setValue(data.data['scores'])
			betArr = data.data
			isUpdate_bet = true
			--[[
			local btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
			btn:setEnabled(true)
			btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
			btn:setEnabled(true)
			]]

			--print("--------123123")
			--dump(betArr)
		end	
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/bet/options", tabData, response, PHP_POST, true)
end

--发送消息
local function sendMeg()
	sendGetBetArr()
	sendInitGameMeg()
	sendjackPop()
	local scheduler = cc.Director:getInstance():getScheduler()
		schedulerEntryJack = scheduler:scheduleScriptFunc(function(dt)
		sendjackPop()
	end, 6, false)
end
---------------------------------------
---------------------------------------
local function updateUI()
	if(isUpdate_jackpot == true) then 
		isUpdate_jackpot = false
		if(aLabel_jackp.setValue ~= nil) then
			aLabel_jackp:setValue(jackpotNum)
		end
	end

	if(isUpdate_bet == true) then
		isUpdate_bet = false
		local btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
		btn:setEnabled(true)
		btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
		btn:setEnabled(true)
	end

	if(isUpdate_initGame == true) then	
		isUpdate_initGame = false
		aLabel_baiju:setValue(_count)
		aLabel_jifen:setValue(currScore)
		ccui.Helper:seekWidgetByName(root, "Button_go"):setEnabled(true)
	end	

	if isUpdate_ret1 == true then--出牌返回1
		isUpdate_ret1 = false
		GamblingLayer:resultLogic()
	end

	if isUpdate_ret2 == true then--出牌返回2
		isUpdate_ret2 = false
		GamblingLayer:resultLogic2()
	end
end

--btn一些按钮消息回调---------------------------
--test
local function stop(event)
	--GamblingLayer:resultLogic()
	GamblingLayer:inGame2()
end

--点击不玩了按钮
local function backGame1Event(event)
	scrollTxtLabelLogic:resetScrollTxtColor()

	DZPlaySound.playSound(BTN_SOUND, false)
	sendGetNewCurrScore()
	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	g_game2loseDlg:setVisible(false)
	g_Panel_game1:setVisible(true)

	local btn = nil 
	btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
	btn:setEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_go")
	btn:setEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
	btn:setEnabled(true)

	aLabel_getjifen:setValue(0)
	scrollTxtLabelLogic:resetScrollTxtColor()

	--停止跑马灯
	GamblingLayer:stopPMD()
end

--点击比大小按钮
local function goInBiDaXiaoEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	GamblingLayer:inGame2()
end

--翻牌按钮事件
local function fanPaiEvent(event)
	if(isFanPai == false) then
		return
	end

	if(event:getTag() ~= paiObjArr.isTouchIdx) then
		return
	end

	isFanPai = false
	--sendFanPai()
end

--锁头按钮
local function lockEvent(event)

	if(goFlag == -1) then
		return
	end
	DZPlaySound.playSound(BTN_SOUND, false)
	local idx = event:getTag()
	--print("tttttddddd==="..idx)

	if(lockObjArr[idx].value == true) then
		lockObjArr[idx].value = false
		lockObjArr[idx].lockImg:loadTexture("gambling/g_unlock.png")
		lockObjArr[idx].deng:setVisible(false)
	else
		lockObjArr[idx].value = true
		lockObjArr[idx].lockImg:loadTexture("gambling/g_lock.png")
		lockObjArr[idx].deng:setVisible(true)
	end
end

--点击加注按钮
local function jiaZhuEvent(event)
	--event:setVisible(false)
	DZPlaySound.playSound(BTN_SOUND, false)
	
	if(isCanShowInGame == true) then
		ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
		g_game1winDlg:setVisible(false)
		ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(true)
	else
		ccui.Helper:seekWidgetByName(root, "Panel_megDlg"):setVisible(false)
		if(currBetIdx > #betArr) then
			touzhu_num = 0
			currBetIdx = 1
		else
			touzhu_num = betArr[currBetIdx]
			currBetIdx = currBetIdx + 1
		end

		aLabel_touzhu:setValue(touzhu_num)
	end
end

--最大投注按钮
local function maxTzEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)

	if(isCanShowInGame == true) then
		ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
		g_game1winDlg:setVisible(false)
		ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(true)
	else
		ccui.Helper:seekWidgetByName(root, "Panel_megDlg"):setVisible(false)
		touzhu_num = betArr[#betArr]
		currBetIdx = #betArr + 1
		aLabel_touzhu:setValue(touzhu_num)
	end
end

--点击出牌按钮
local function chuPaiEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	isCanShowInGame = false
	ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(false)
	
	--第一次发第一次转
	if goFlag == 0 then
		--投注值小于等于0 或者 大于底金 不能出牌 
		if((touzhu_num <= 0) or (touzhu_num > (aLabel_jifen:getValue() + aLabel_getjifen:getValue()) )) then
			ccui.Helper:seekWidgetByName(root, "Panel_megDlg"):setVisible(true)

			if(touzhu_num <= 0) then
				ccui.Helper:seekWidgetByName(root, "Text_meg"):setString("请下注！")
			elseif (touzhu_num > (aLabel_jifen:getValue() + aLabel_getjifen:getValue()) ) then
				ccui.Helper:seekWidgetByName(root, "Text_meg"):setString("您底金不足！")
			end

			return
		end
	end
    
    --处理相关逻辑
	--sendGetNewCurrScore()
	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	g_game2loseDlg:setVisible(false)
	g_Panel_game1:setVisible(true)
	scrollTxtLabelLogic:resetScrollTxtColor()
	--停止跑马灯
	GamblingLayer:stopPMD()

	--各种按钮不可点击
	local btn = nil 
	btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_go")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
	btn:setEnabled(false)

	scrollTxtLabelLogic:resetScrollTxtColor()

	--第一次发第一次转协议，运行第一次转逻辑
	if goFlag == 0 then
		_count = _count + 1
		aLabel_baiju:setValue(_count)
		GamblingLayer:hideShowView()
		GamblingLayer:resetShowPanelPos()
		GamblingLayer:showScrollView()
		sendGo1()
		goFlag = -1

		for i = 1, 5 do
			gunSoundId[i] = DZPlaySound.playSound(GUN_SOUND, true)
		end

		--更新玩家显示积分
		aLabel_jifen:setValue(aLabel_jifen:getValue() - touzhu_num + aLabel_getjifen:getValue())
		aLabel_getjifen:setValue(0)

		--sendGetNewCurrScore()
    --第二次发第二次转协议，运行第二次带锁逻辑
    elseif goFlag == 1 then
    	--隐藏没锁的展示牌道
    	--显示没锁的滚动牌道
    	for i = 1, 5 do
    		if(lockObjArr[i].value == false) then
    			showPanelArr[i]:setVisible(false)
    			scrollPanelArr[i]:setVisible(true)
				gunSoundId[i] = DZPlaySound.playSound(GUN_SOUND, true)
    			print("meissssss="..i)
    		end
    	end
    	sendGo2()
		goFlag = -1
    end
end

--押注大比倍
local function maxBetEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	--if(isDaXiao ~= 1) then
	isDaXiao = 1
	local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:setTouchEnabled(false)
	sendFanPai()
	--end
end

--押注小比倍
local function minBetEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	--if(isDaXiao ~= 0) then
	isDaXiao = 0
	local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:setTouchEnabled(false)
	sendFanPai()
	--end
end

--结束比大小按钮
local function overGame2Event(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	scrollTxtLabelLogic:resetScrollTxtColor()
	GamblingLayer:inGame1()
	sendGetNewCurrScore()
end

--点击翻牌输了返回按钮
local function backFanPaiEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	showDlg:setVisible(false)
	scrollTxtLabelLogic:resetScrollTxtColor()
	GamblingLayer:inGame1()
	sendGetNewCurrScore()
end

--显示胜利对话框
local function showWinDlgEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_Win"):setVisible(true)
	paiObjArr[10]:setVisible(false)

	local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:setTouchEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:setTouchEnabled(false)
end

--显示胜利对话框后继续比大小
local function hideWinDlgEvent(event)
	DZPlaySound.playSound(BTN_SOUND, false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_Win"):setVisible(false)
	paiObjArr[10]:setVisible(true)

	local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:setTouchEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:setTouchEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:setTouchEnabled(true)
end

--显示帮助信息按钮
local function showHelpInfoEvent(event)
	ccui.Helper:seekWidgetByName(root, "Panel_panelHelpInfo"):setVisible(true)
	ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):setVisible(false)
end

--隐藏帮助信息按钮
local function hideHelpInfoEvent(event)
	ccui.Helper:seekWidgetByName(root, "Panel_panelHelpInfo"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):setVisible(true)
end

--点击是否进入比大小 否 按钮
local function noInBiDaXiaoEvent(event)
	isCanShowInGame = false
	ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(false)
	
	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	g_Panel_game1:setVisible(true)
end

--点击是否进入比大小 是 按钮
local function okInBiDaXiaoEvent(event)
	isCanShowInGame = false
	ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(false)

	DZPlaySound.playSound(BTN_SOUND, false)
	GamblingLayer:inGame2()
end

local function handleBig(event)
	--print("dadada")
end

local function handleOver(event)
end


local function closeBtn(event)
	--成功回调函数
	local function response(data)
		if data.code == 0 then
			--获取个人信息请求
			--dump(data)
			--print("==============")
			aLabel_jifen:setValue(data.data['scores'])
			currScore = tonumber(data.data['scores'])
			Single:playerModel():setPBetNum(currScore)
		else
			--4rewql
			Single:playerModel():setPBetNum(currScore)
			
		end

		ccexp.AudioEngine:stopAll()
		DZPlaySound.unloadSound(BGM_SOUND)
		local scheduler = cc.Director:getInstance():getScheduler()
		if(schedulerEntryJack ~= nil) then
			scheduler:unscheduleScriptEntry(schedulerEntryJack)
			schedulerEntryJack = nil
		end

		if(schedulerEntryUpdateUI ~= nil) then
			scheduler:unscheduleScriptEntry(schedulerEntryUpdateUI)
			schedulerEntryUpdateUI = nil
		end

		scrollTxtLabelLogic:removeScheduler()
		aLabel_touzhu:removeScheduler()
		aLabel_baiju:removeScheduler()
		aLabel_getjifen:removeScheduler()
		aLabel_jifen:removeScheduler()
		aLabel_jackp:removeScheduler()
		--test
		--aLabel_test:removeScheduler()

		scrollActionLogic:removeScheduler()
		--_layer:removeFromParent()

		--oldkc adapter
		-- local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	 --  	local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
	 --    local width, height = framesize.width, framesize.height

		-- width = framesize.width / scaleX-----
		-- height = framesize.height / scaleX----

		-- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
		-- local ratio = tframesize.height/tframesize.width
		-- print("exit----rrrr=="..ratio)
  --       if ratio >= 1.5 then
  --       	cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
		-- else
		    
		-- end

		--newdz adapter
		StringUtils.setDZAdapter()
		
	    --是那个界面进来的0-我的 1-大厅
	    if(m_whichLayerIn_tag == 0) then
			require("mine.MineScene"):startScene()
		elseif(m_whichLayerIn_tag == 1) then
			require('main.MainScene'):startScene(true)
		end
		
	end
	--请求
	local tabData = {}
	tabData['userId'] = adapterID()--Single:playerModel():getId()  -->527
	--dump(tabData)
	XMLHttp.requestJSHttp("slot/init", tabData, response, PHP_POST)	
end

--初始化层
local function createLayer()
	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.GAMBLING_CSB)
    _layer:addChild(cs)
	DZPlaySound.loadSound(BGM_SOUND)
    DZPlaySound.playSound(BGM_SOUND, true)
    _count = 0
	currScore = 0
	goFlag = -1
	getJiFen_num = 0
	g_fTime = 0.0618
	touzhu_num = 0
	currBetIdx = 1
	isUpdate_jackpot = false
	isUpdate_bet = false
	isUpdate_initGame = false
	isUpdate_ret1 = false--出牌返回1
	isUpdate_ret2 = false--出牌返回2
	isCanShowInGame = false
	jackpotNum = 0
	betArr = {}

	root = cs:getChildByName("Panel_root")

	--初始化一些按钮
	local btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
	btn:touchEnded(jiaZhuEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_go")
	btn:touchEnded(chuPaiEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
	btn:touchEnded(maxTzEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_info")
	btn:touchEnded(showHelpInfoEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_back")
	btn:touchEnded(closeBtn)
	
	btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:touchEnded(maxBetEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:touchEnded(minBetEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:touchEnded(showWinDlgEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_fBackGame")
	btn:touchEnded(backFanPaiEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_noplaywin")
	btn:touchEnded(backGame1Event)

	btn = ccui.Helper:seekWidgetByName(root, "Button_playdaxiao")
	btn:touchEnded(goInBiDaXiaoEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_playagain")
	btn:touchEnded(backGame1Event)

	btn = ccui.Helper:seekWidgetByName(root, "Button_Backgame1dx")
	btn:touchEnded(overGame2Event)

	btn = ccui.Helper:seekWidgetByName(root, "Button_goOndx")
	btn:touchEnded(hideWinDlgEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_Backgame2dx")
	btn:touchEnded(overGame2Event)
	
	btn = ccui.Helper:seekWidgetByName(root, "Button_back2p1")
	btn:touchEnded(hideHelpInfoEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_noplaywincp1")
	btn:touchEnded(backGame1Event)

	btn = ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1")
	btn:touchEnded(goInBiDaXiaoEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_noIn")
	btn:touchEnded(noInBiDaXiaoEvent)

	btn = ccui.Helper:seekWidgetByName(root, "Button_okIn")
	btn:touchEnded(okInBiDaXiaoEvent)

	

	--各种按钮不可点击
	btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_go")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
	btn:setEnabled(false)

	
	--初始化文字标签
	aLabel_touzhu = {}
	aLabel_baiju = {}
	aLabel_getjifen = {} 
	aLabel_jifen = {}
	aLabel_jackp = {}
	
	
	local aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_touzhu")
	--aLabel:setString("0")
	aLabel_touzhu = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_touzhu:setISBFH(false)
	_layer:addChild(aLabel_touzhu)
	aLabel_touzhu:setValue(0)

	aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_baiju")
	aLabel_baiju = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_baiju:setISBFH(false)
	_layer:addChild(aLabel_baiju)
	aLabel_baiju:setValue(0)

	aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_getjifen")
	aLabel_getjifen = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_getjifen:setISBFH(false)
	_layer:addChild(aLabel_getjifen)
	aLabel_getjifen:setValue(0)

	aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_jifen")
	aLabel_jifen = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_jifen:setISBFH(false)
	_layer:addChild(aLabel_jifen)
	aLabel_jifen:setValue(0)

	aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_jackp")
	aLabel_jackp = require('gambling.ScrollLabel'):create(aLabel)
	--ccui.Helper:seekWidgetByName(root, "AtlasLabel_jackp")
	--ccui.Helper:seekWidgetByName(root, "AtlasLabel_jackp")
	aLabel_jackp:setISBFH(true)
	_layer:addChild(aLabel_jackp)
	aLabel_jackp:setValue(0)


	--test
	--[[
	aLabel = ccui.Helper:seekWidgetByName(root, "AtlasLabel_test")
	aLabel_test = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_test:setISBFH(true)
	_layer:addChild(aLabel_test)
	aLabel_test:setValue(21234530)
	]]

--[[
	aLabel = cc.LabelAtlas:_create('1', "gambling/numberY.png", 40, 48, string.byte('/'))
	--cc.LabelAtlas:_create("12", "gambling/numberY.png", 31, 56,  string.byte("0"))
	aLabel_test = require('gambling.ScrollLabel'):create(aLabel)
	aLabel_test:setISBFH(false)
	_layer:addChild(aLabel_test)
	aLabel_test:setValue(21234530)
	ccui.Helper:seekWidgetByName(root, "AtlasLabel_test"):getParent():addChild(aLabel)
	aLabel:setPosition(ccui.Helper:seekWidgetByName(root, "AtlasLabel_test"):getPosition())
]]

	ccui.Helper:seekWidgetByName(root, "Image_here"):setVisible(false)	

	--初始化一些对话框
	g_game1winDlg = {}--老虎机界面胜利对话框
	g_game2loseDlg = {}--老虎机界面失败对话框
	g_Panel_game1 = {}

	g_game1winDlg = ccui.Helper:seekWidgetByName(root, "Panel_showWin")
	g_game2loseDlg = ccui.Helper:seekWidgetByName(root, "Panel_showLose")
	g_Panel_game1 = ccui.Helper:seekWidgetByName(root, "Panel_game1")
	
	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	g_game2loseDlg:setVisible(false)
	g_Panel_game1:setVisible(true)
	--初始化层
	game1 = ccui.Helper:seekWidgetByName(root, "Panel_gameGun")
	game2 = ccui.Helper:seekWidgetByName(root, "Panel_gameFan")
	game2:setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_fanScrolldi"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_megDlg"):setVisible(false)

	showDlg = ccui.Helper:seekWidgetByName(root, "Panel_showDlg")
	showDlg:setVisible(false)

	--隐藏一些层
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_Win"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_WinOver"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showIsCanInGame"):setVisible(false)
	
	--帮助信息
	ccui.Helper:seekWidgetByName(root, "Panel_panelHelpInfo"):setVisible(false)

	--初始化锁头
	lockObjArr = {}
	for i = 1, 5 do
		local obj = {}
		obj.deng = ccui.Helper:seekWidgetByName(root, "Image_lockDeng_"..i)
		obj.lockImg = ccui.Helper:seekWidgetByName(root, "Image_lock"..i)
		obj.value = false -- false没锁 true锁住

		obj.deng:setVisible(false)
		obj.lockImg:setTouchEnabled(false)
		obj.lockImg:touchEnded(lockEvent)
		obj.lockImg:setTag(i)
		table.insert(lockObjArr, obj)
	end

	table.insert(lockObjArr, ccui.Helper:seekWidgetByName(root, "Panel_lock"))

	--初始化翻牌层相关数据啊
	paiObjArr = {}

	for i = 1, 9 do
		local obj = {}
		obj.paiImg = ccui.Helper:seekWidgetByName(root, "Image_fp"..i)
		obj.paiImg:setTouchEnabled(true)
		obj.paiImg:touchEnded(fanPaiEvent)
		obj.paiImg:setTag(i)
		
		if(i >= 2) then
			obj.paidengImg = ccui.Helper:seekWidgetByName(root, "Image_yddd"..i)
			obj.paidengImg:setVisible(false)
		end
		table.insert(paiObjArr, obj)
	end
	paiObjArr[9].paiImg:setVisible(false)
	table.insert(paiObjArr, ccui.Helper:seekWidgetByName(root, "Panel_scrollGun"))
	paiObjArr.isTouchIdx = 2--默认第二个可以点击

	--获得文字标签
	local scrollTxtArr = {}
	for i = 1, 10 do
		local scrollTxt = ccui.Helper:seekWidgetByName(root, "Panel_txt_"..i)
		--table.insert(scrollPanelArr, scrollPl)
		scrollTxt:setTag(i)
		scrollTxtArr[i] = scrollTxt
	end

	local img = ccui.Helper:seekWidgetByName(root, "Image_here")
	scrollTxtLabelLogic:initScrollTxtLogic(scrollTxtArr, img)

	--获得cocostudio中的显示牌道，并存入showPanelArr中
	showPanelArr = {}
	showPanelInitPosY = {}
	for i = 1, 5 do
		local showPl = ccui.Helper:seekWidgetByName(root, "Panel_show"..i)
		table.insert(showPanelArr, showPl)
		showPanelInitPosY[i] = showPl:getPositionY()
		showPl:setTag(i)
		GamblingLayer:moveShowPanelWithIdx(i, 0)
	end
	--获得cocostudio中的滚动牌道，并存入scrollPanelArr中
	scrollPanelArr = {}
	for i = 1, 5 do
		local scrollPl = ccui.Helper:seekWidgetByName(root, "Panel_dao"..i)
		--table.insert(scrollPanelArr, scrollPl)
		scrollPanelArr[i] = scrollPl
		scrollPl:setTag(i)
	end

	batchParNode = {}
	local tpar = cc.ParticleSystemQuad:create(PAR_JACKPOT)
	tpar:unscheduleUpdate()
    batchParNode = cc.ParticleBatchNode:createWithTexture(tpar:getTexture())
	batchParNode:setPosition(cc.p(0, 0))
	ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(batchParNode)
	--初始化滚动牌道逻辑
	scrollActionLogic:runScrollAction(scrollPanelArr)

	--GamblingLayer:hideShowView()
	GamblingLayer:hideScrollView()

	lockObjArr[6]:setVisible(false)

	--停止跑马灯
	GamblingLayer:stopPMD()


	--获取下注数组
	--sendInitGameMeg()
	--sendGetBetArr()

	--初始化牌型
	--[[
 	GamblingLayer:setShowPanelValue(1, 1)
 	GamblingLayer:setShowPanelValue(2, 13)
 	GamblingLayer:setShowPanelValue(3, 17)
 	GamblingLayer:setShowPanelValue(4, 20)
	GamblingLayer:setShowPanelValue(5, 36)
]]
	--轮询发送jackpop信息
	--循环滚动逻辑
	--sendjackPop()
	
    --GamblingLayer:showScrollView()
    --GamblingLayer:hideShowView()
    
end

--比大小返回信息后逻辑
function GamblingLayer:resultLogicDaXiao()
	paiObjArr[paiObjArr.isTouchIdx].paidengImg:setVisible(true)
	paiObjArr[paiObjArr.isTouchIdx].paiImg:runAction(cc.Sequence:create(
    		cc.ScaleTo:create(g_fTime, 0, 1),
            cc.CallFunc:create( 
                function(sender)
	                sender:loadTexture(DZConfig.cardName(daxiaoRetData.data.card.key))
                end),
            cc.ScaleTo:create(g_fTime, 1, 1),
            --cc.DelayTime:create(0.5),
			cc.CallFunc:create( 
                function(sender)
                
                	--[[
	                if(paiObjArr.isTouchIdx > 3) then
	                	paiObjArr[9]:stopAllActions()
	                	--131x横向移动单位大小，根据编辑器来确定这个值
	                	paiObjArr[9]:runAction(cc.MoveTo:create(0.2, cc.p(-131*(paiObjArr.isTouchIdx - 3),paiObjArr[9]:getPositionY())))
	            	end
					]]
	            	if(sender:getPositionX() > 221.00 and paiObjArr.isTouchIdx > 2) then
	                	paiObjArr[10]:stopAllActions()
	                	--131x横向移动单位大小，根据编辑器来确定这个值
	                	paiObjArr[10]:runAction(cc.MoveTo:create(0.2, cc.p(-131*(paiObjArr.isTouchIdx - 2),paiObjArr[10]:getPositionY())))
	            	end

	            	--赢了
	            	if(daxiaoRetData.data.isWin == 1) then
	            		DZPlaySound.playSound(LUCKY_SOUND, false)
	            		isFanPai = true--可以点击牌
	            		getJiFen_num = daxiaoRetData.data.winScore
	                	aLabel_getjifen:setValue(getJiFen_num)
	            		paiObjArr.isTouchIdx = paiObjArr.isTouchIdx + 1

	            		local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
						btn:setTouchEnabled(true)
						btn = ccui.Helper:seekWidgetByName(root, "Button_min")
						btn:setTouchEnabled(true)
						btn = ccui.Helper:seekWidgetByName(root, "Button_over")
						btn:setTouchEnabled(true)
						
						--更新牌行
	            		game2handType = game2handType - 1
	            		scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - game2handType)
	            		--如果<=1证明牌行到头了，弹出胜利对话框
	            		--如果<=10 - MAX_FP_NUM 证明牌行到头了,弹出胜利对话框
	            		print("game2handType="..game2handType)
	            		print("MAX_FP_NUM="..MAX_FP_NUM)
	            		print("11 - MAX_FP_NUM="..11 - MAX_FP_NUM)
	            		if(game2handType <= 11 - MAX_FP_NUM)then
	            			GamblingLayer:runParBoom()
	            			local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
							btn:setTouchEnabled(false)
							btn = ccui.Helper:seekWidgetByName(root, "Button_min")
							btn:setTouchEnabled(false)
							btn = ccui.Helper:seekWidgetByName(root, "Button_over")
							btn:setTouchEnabled(false)

							sender:runAction(cc.Sequence:create(
								cc.DelayTime:create(1.618),
								--先弹出提示
								cc.CallFunc:create(
									function(sender)
										ccui.Helper:seekWidgetByName(root, "Panel_showDlg_WinOver"):setVisible(true)
	      								ccui.Helper:seekWidgetByName(root, "Button_Backgame2dx"):setVisible(false)
	      								paiObjArr[10]:setVisible(false)
									end),
								cc.DelayTime:create(1.618),
								--几秒钟后返回老虎机界面
								cc.CallFunc:create(
									function(sender)
										ccui.Helper:seekWidgetByName(root, "Panel_showDlg_WinOver"):setVisible(false)
										scrollTxtLabelLogic:resetScrollTxtColor()
										GamblingLayer:inGame1()
										sendGetNewCurrScore()
									end)
								))
						end
	            		
	            	--输了
	            	else
	            		DZPlaySound.playSound(FAIL_SOUND, false)
	            		--获取积分显示为0
	            		getJiFen_num = daxiaoRetData.data.winScore
	                	aLabel_getjifen:setValue(getJiFen_num)
	            		--aLabel_getjifen:setValue(0)
	            		--更新底金showDlg
						sendGetNewCurrScore()

	            		sender:runAction(cc.Sequence:create(
	            			cc.DelayTime:create(1),
	            			--显示返回对话框
	            			cc.CallFunc:create( 
                				function(sender)
                					isFanPai = true--可以点击牌
                					paiObjArr[10]:setVisible(false)
	            					showDlg:setVisible(true)
	            					ccui.Helper:seekWidgetByName(root, "Button_fBackGame"):setVisible(false)
                				end),
	            			cc.DelayTime:create(1),
	            			----几秒钟后自动回到老虎机界面
	            			cc.CallFunc:create( 
                				function(sender)
	            					showDlg:setVisible(false)
									scrollTxtLabelLogic:resetScrollTxtColor()
									GamblingLayer:inGame1()
									sendGetNewCurrScore()
                				end)
	            			))
	            	end
                end)
            ))
end

--进入game1老虎机界面
function GamblingLayer:inGame1()
	game1:setVisible(true)
	game2:setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_txt_10"):setVisible(true)
	ccui.Helper:seekWidgetByName(root, "Panel_fanScrolldi"):setVisible(false)
	showDlg:setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Text_jackpoptxt"):setVisible(false)
	--隐藏一些层
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_Win"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_WinOver"):setVisible(false)
	aLabel_getjifen:setValue(0)
	--sendGetNewCurrScore()
	--aLabel_baiju:setValue(_count)

	--各种按钮不可点击
	local btn = nil 
	btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
	btn:setEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_go")
	btn:setEnabled(true)
	btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
	btn:setEnabled(true)

	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	g_game2loseDlg:setVisible(false)
	g_Panel_game1:setVisible(true)

	scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - beforeInGame2)
end

--进入game2翻牌界面
function GamblingLayer:inGame2()
	isCanShowInGame = false
	--停止跑马灯
	GamblingLayer:stopPMD()
	ccui.Helper:seekWidgetByName(root, "Panel_txt_10"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(false)
	g_game1winDlg:setVisible(false)
	local btn = ccui.Helper:seekWidgetByName(root, "Button_max")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_min")
	btn:setEnabled(false)
	btn = ccui.Helper:seekWidgetByName(root, "Button_over")
	btn:setEnabled(false)

	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_WinOver"):setVisible(false)
	
	--paiObjArr[9]:setPositionX(0)
	beforeInGame2 = game2handType
	
	paiObjArr[10]:setPositionX(-131*(9 - game2handType))
	print("mmmmpos"..(-131*(9 - game2handType)))
	paiObjArr[10]:setVisible(true)
	paiObjArr.isTouchIdx = 11 - game2handType

	for i = 1, 9 do
		paiObjArr[i].paiImg:loadTexture("common/com_cardbg.png")
		if(i >= 2) then
			paiObjArr[i].paidengImg:setVisible(false)
		end
	end

	isFanPai = false--默认开始不可以翻牌
	isDaXiao = -1--
	game1:setVisible(false)
	game2:setVisible(true)
	ccui.Helper:seekWidgetByName(root, "Panel_fanScrolldi"):setVisible(true)

	ccui.Helper:seekWidgetByName(root, "Panel_showDlg_Win"):setVisible(false)

	sendInitGame2()
end

--运行跑马灯
function GamblingLayer:runPMD()
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):stopAllActions()
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng2"):setVisible(false)

	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):runAction(cc.RepeatForever:create(cc.Sequence:create(
		cc.CallFunc:create(
	        function(sender)
	        	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):setVisible(true)
	        	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng2"):setVisible(false)
	        end
		),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(
	        function(sender)
	        	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):setVisible(false)
	        	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng2"):setVisible(true)
	        end
		),
		cc.DelayTime:create(0.5)
		)))
end

--停止跑马灯
function GamblingLayer:stopPMD()
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):stopAllActions()
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng1"):setVisible(false)
	ccui.Helper:seekWidgetByName(root, "Panel_pmdeng2"):setVisible(false)
end

--隐藏所有牌型牌道
function GamblingLayer:hideShowView()
	for i, tPanel in ipairs(showPanelArr) do
        tPanel:setVisible(false)
    end
end

--隐藏所有滚动牌型牌道
function GamblingLayer:hideScrollView()
	for i, tPanel in ipairs(scrollPanelArr) do
        tPanel:setVisible(false)
    end
end

--显示所有滚动牌型牌道
function GamblingLayer:showScrollView()
	for i, tPanel in ipairs(scrollPanelArr) do
        tPanel:setVisible(true)
    end
end

--收到消息后停止转动逻辑
function GamblingLayer:resultLogic()
	----有获取jackpop，获取jackpop走jackpop逻辑
	--if(firstRetData.data.isJackpot == 1) then
		
	----没有获取jackpop直接第二次投注
	--else
		_layer:runAction(cc.Sequence:create(
				cc.DelayTime:create(1.0),
	            cc.CallFunc:create( 
	                function(sender)
	                	DZPlaySound.playSound(STOP_SOUND, false)
	                	DZPlaySound.stopSound(gunSoundId[1])
		                GamblingLayer:showPanelWithIdx(1)
		                GamblingLayer:hideScrollWithIdx(1)
		                GamblingLayer:moveShowPanelWithIdx(1, 0)
		                GamblingLayer:setShowPanelValue(1, firstRetData.data.cards[1].key)
		                --aLabel_touzhu:setValue(22)
		                --scrollTxtLabelLogic:setScrollTxtPosWithIdx(1)
		               	--local testidx = math.random(1,10)
		                --print('rand===='..testidx)
		                --scrollTxtLabelLogic:setScrollTxtPosWithIdx(testidx)
	                end),
	            cc.DelayTime:create(0.5),
	            cc.CallFunc:create( 
	                function(sender)
	                	DZPlaySound.playSound(STOP_SOUND, false)
	                	DZPlaySound.stopSound(gunSoundId[2])
		                GamblingLayer:showPanelWithIdx(2)
		                GamblingLayer:hideScrollWithIdx(2)
		                GamblingLayer:moveShowPanelWithIdx(2, 0)
		                GamblingLayer:setShowPanelValue(2, firstRetData.data.cards[2].key)
	                end),
	            cc.DelayTime:create(0.5),
	            cc.CallFunc:create( 
	                function(sender)
	                	DZPlaySound.playSound(STOP_SOUND, false)
	                	DZPlaySound.stopSound(gunSoundId[3])
		                GamblingLayer:showPanelWithIdx(3)
		                GamblingLayer:hideScrollWithIdx(3)
		                GamblingLayer:moveShowPanelWithIdx(3, 0)
		                GamblingLayer:setShowPanelValue(3, firstRetData.data.cards[3].key)   
	                end),
	            cc.DelayTime:create(0.5),
	            cc.CallFunc:create( 
	                function(sender)
	                	DZPlaySound.playSound(STOP_SOUND, false)
	                	DZPlaySound.stopSound(gunSoundId[4])
		                GamblingLayer:showPanelWithIdx(4)
		                GamblingLayer:hideScrollWithIdx(4)
		                GamblingLayer:moveShowPanelWithIdx(4, 0)
		                GamblingLayer:setShowPanelValue(4, firstRetData.data.cards[4].key)
	                	--结果动画label
		                scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - firstRetData.data.handType)
	                end),
	            cc.DelayTime:create(0.5),
	            cc.CallFunc:create( 
	                function(sender)
                        ----获取jackpop，获取jackpop走jackpop逻辑
		                if(firstRetData.data.isJackpot == 1) then
		                	DZPlaySound.playSound(STOP_SOUND, false)
		                	DZPlaySound.stopSound(gunSoundId[5])
		                	GamblingLayer:showPanelWithIdx(5)
			                GamblingLayer:hideScrollWithIdx(5)
			                GamblingLayer:moveShowPanelWithIdx(5, 0)
			                GamblingLayer:setShowPanelValue(5, firstRetData.data.cards[5].key)
			                
                            --currScore = tonumber(firstRetData.data.scores)
							--aLabel_jifen:setValue(firstRetData.data.scores)
							DZPlaySound.playSound(LUCKY_SOUND, false)
							--for i = 1, 5 do
							--	DZPlaySound.stopSound(gunSoundId[i])
							--end
							goFlag = 0
							--隐藏所有滚动牌道
							GamblingLayer:hideScrollView()
							--显示结果牌道
							--GamblingLayer:showPanelWithIdx(1)
							--GamblingLayer:showPanelWithIdx(2)
							--GamblingLayer:showPanelWithIdx(3)
							--GamblingLayer:showPanelWithIdx(4)
							--GamblingLayer:showPanelWithIdx(5)
							--g_game1winDlg:setVisible(true)
							--延迟弹框
							sender:runAction(cc.Sequence:create(
	                			cc.DelayTime:create(1.62),
	                			cc.CallFunc:create( 
                					function(sender)
                						--播放粒子特效
                						GamblingLayer:runParBoom()
                						--[[
		    							local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
		    							ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
				                		emitter:setPosition(cc.p(374, 694.87))
                						]]
                						--跑马灯
										GamblingLayer:runPMD()
                						ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(true)
                						--开启下注时，是否继续比大小询问提示
	                					isCanShowInGame = true
                						ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtpxjg"):setString(nameRet[tonumber(firstRetData.data.handType)])
										ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtcpjf1"):setString(tostring(firstRetData.data.jackpotMoney).."记分牌")
                            			ccui.Helper:seekWidgetByName(root, "Text_jackpopcp1jftt"):setString(tostring(firstRetData.data.winScore))
										g_Panel_game1:setVisible(false)

										local btn = nil 
										btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
										btn:setEnabled(true)
										btn = ccui.Helper:seekWidgetByName(root, "Button_go")
										btn:setEnabled(true)
										btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
										btn:setEnabled(true)

										ccui.Helper:seekWidgetByName(root, "Button_noplaywincp1"):setVisible(false)
            						end)
	                		 ))
							--ccui.Helper:seekWidgetByName(root, "Text_jackpoptxt"):setVisible(true)
							--ccui.Helper:seekWidgetByName(root, "Text_paiXingWin"):setString(nameRet[seondRetData.data.handType])
							
							--重置保存游戏2翻牌界面的牌形
							game2handType = firstRetData.data.handType

                            --皇家同花顺不能比大小
							if(game2handType == 1 or game2handType == 2) then 
								ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(false)
							else
								ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(true)
							end


							if(firstRetData.data.winScore ~= nil) then
								--getJiFen_num = getJiFen_num + seondRetData.data.winScore
								--aLabel_getjifen:setValue(getJiFen_num)
								getJiFen_num = firstRetData.data.winScore
								aLabel_getjifen:setValue(firstRetData.data.winScore)
						    end

							ccui.Helper:seekWidgetByName(root, "Image_here"):setVisible(true)
                            
                        ----没有获取jackpop直接第二次投注
		                else
		                	DZPlaySound.playSound(STOP_SOUND, false)
		                	DZPlaySound.stopSound(gunSoundId[5])
			                GamblingLayer:showPanelWithIdx(5)
			                GamblingLayer:hideScrollWithIdx(5)
			                GamblingLayer:moveShowPanelWithIdx(5, 0)
			                GamblingLayer:setShowPanelValue(5, firstRetData.data.cards[5].key)
			                
			                
			                --if(firstRetData.data.isJackpot == 0) then
			                goFlag = 1
			                lockObjArr[6]:setVisible(true)
			                GamblingLayer:isCanTouchLock(true)
			                --currScore = tonumber(firstRetData.data.scores)
			                --aLabel_jifen:setValue(firstRetData.data.scores)
			                --aLabel_touzhu:setValue(92823432)
							--开启发牌按钮
							local btn = nil 
							--btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
							--btn:setEnabled(true)
							btn = ccui.Helper:seekWidgetByName(root, "Button_go")
							btn:setEnabled(true)
							--btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
							--btn:setEnabled(true)
							
							--else
							ccui.Helper:seekWidgetByName(root, "Image_here"):setVisible(true)	
			            	--end
			            end
	                end)
	            )) 
    --end 
end

--第二次返回逻辑
function GamblingLayer:resultLogic2()
    flagNum = 1
    currflagNum = 1
    local isAllLock = true
    --获取锁着的id
    for i = 1, 5 do
    	if(lockObjArr[i].value == false) then
    		isAllLock = false
    		showPanelArr[i]:runAction(cc.Sequence:create(
    		cc.DelayTime:create(0.5*flagNum),
            cc.CallFunc:create( 
                function(sender)
                	print("meissssss="..currflagNum)
                	DZPlaySound.playSound(STOP_SOUND, false)
                	DZPlaySound.stopSound(gunSoundId[sender:getTag()])
	                GamblingLayer:showPanelWithIdx(sender:getTag())
	                GamblingLayer:hideScrollWithIdx(sender:getTag())
	                GamblingLayer:moveShowPanelWithIdx(sender:getTag(), 0)
	                GamblingLayer:setShowPanelValue(sender:getTag(), seondRetData.data.cards[sender:getTag()].key)
	                
	                --最后一个动画执行完毕重置成第一种状态
	                currflagNum = currflagNum + 1
	                --print("currflagNum"..currflagNum..",flagNum"..flagNum)

	                --延迟结果提示处理
	                if(flagNum - 3 <= 0) then 
	                	--滚动显示牌型
						scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - seondRetData.data.handType)
	                elseif(currflagNum == flagNum - 2) then
	                	--滚动显示牌型
						scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - seondRetData.data.handType)
	                end

	                if(currflagNum == flagNum) then
	                	if(seondRetData.data.scores ~= nil) then
	                		--currScore = tonumber(seondRetData.data.scores)
	                		--aLabel_jifen:setValue(seondRetData.data.scores)
	                	end
	                	
	                	if(seondRetData.data.winScore ~= nil) then
	                		--getJiFen_num = getJiFen_num + seondRetData.data.winScore
	                		--aLabel_getjifen:setValue(getJiFen_num)
	                		getJiFen_num = seondRetData.data.winScore
	                		aLabel_getjifen:setValue(seondRetData.data.winScore)
	                	end

	                	--先判断中没中jackpot
	                	--中了jackpot
	                	local tmpFlag = seondRetData.data.isJackpot
	                	if(tmpFlag == 1) then
	                		print("第二次发牌中jackpot")
	                		DZPlaySound.playSound(LUCKY_SOUND, false)
	                		--延迟弹框
	                		sender:runAction(cc.Sequence:create(
	                			cc.DelayTime:create(1.62),
	                			cc.CallFunc:create( 
                					function(sender)
                						--播放粒子特效
                						GamblingLayer:runParBoom()
                						--[[
		    							local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
		    							ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
				                		emitter:setPosition(cc.p(374, 694.87))
                						]]
                						goFlag = 0
                						
                						--播放粒子特效
                						--[[
		    							local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
		    							ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
				                		emitter:setPosition(cc.p(374, 694.87))
                						]]
                						--跑马灯
										GamblingLayer:runPMD()
                						ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(true)
                						--开启下注时，是否继续比大小询问提示
	                					isCanShowInGame = true
                						ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtpxjg"):setString(nameRet[tonumber(seondRetData.data.handType)])
										ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtcpjf1"):setString(tostring(seondRetData.data.jackpotScore).."记分牌")
                            			ccui.Helper:seekWidgetByName(root, "Text_jackpopcp1jftt"):setString(tostring(seondRetData.data.winScore))
										g_Panel_game1:setVisible(false)
										--跑马灯
										GamblingLayer:runPMD()
			            						
   										--重置保存游戏2翻牌界面的牌形
   										game2handType = seondRetData.data.handType
                						--GamblingLayer:inGame2()

                						 --皇家同花顺不能比大小
										if(game2handType == 1 or game2handType == 2) then 
											ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(false)
										else
											ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(true)
										end

										local btn = nil 
										btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
										btn:setEnabled(true)
										btn = ccui.Helper:seekWidgetByName(root, "Button_go")
										btn:setEnabled(true)
										btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
										btn:setEnabled(true)

										ccui.Helper:seekWidgetByName(root, "Button_noplaywincp1"):setVisible(false)
						
            						end)
	                		 ))

	                		
	                	--没中jackpot逻辑
	                	else
		                	--不为10证明中奖了
		                	if((11 - seondRetData.data.handType) ~= 1) then
		                		print("~~中奖了~~~")
		                		DZPlaySound.playSound(LUCKY_SOUND, false)

		                		--播放粒子特效
		                		--[[
    							local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
    							ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
		                		emitter:setPosition(cc.p(374, 694.87))
		                		]]
		                		--延迟1秒然后开始进入对话框
		                		sender:runAction(cc.Sequence:create(
		                			cc.DelayTime:create(1.62),
		                			cc.CallFunc:create( 
	                					function(sender)
	                						--播放粒子特效
	                						GamblingLayer:runParBoom()
	                						--[[
			    							local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
			    							ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
					                		emitter:setPosition(cc.p(374, 694.87))
	                						]]
	                						goFlag = 0
	                						g_game1winDlg:setVisible(true)
	                						--开启下注时，是否继续比大小询问提示
	                						isCanShowInGame = true
	                						g_Panel_game1:setVisible(false)
	                						ccui.Helper:seekWidgetByName(root, "Text_jackpoptxt"):setVisible(false)
	                						ccui.Helper:seekWidgetByName(root, "Text_paiXingWin"):setString(nameRet[seondRetData.data.handType])
	   										
	   										--重置保存游戏2翻牌界面的牌形
	   										game2handType = seondRetData.data.handType
	                						--GamblingLayer:inGame2()

	                						--皇家同花顺不能比大小
											if(game2handType == 1 or game2handType == 2) then 
												ccui.Helper:seekWidgetByName(root, "Button_playdaxiao"):setVisible(false)
											else
												ccui.Helper:seekWidgetByName(root, "Button_playdaxiao"):setVisible(true)
											end

											--发牌下注按钮弹起
											local btn = nil 
											btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
											btn:setEnabled(true)
											btn = ccui.Helper:seekWidgetByName(root, "Button_go")
											btn:setEnabled(true)
											btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
											btn:setEnabled(true)

											ccui.Helper:seekWidgetByName(root, "Button_noplaywin"):setVisible(false)

	            						end)
		                		 ))
		                	--没中奖逻辑
		                	else
		                		DZPlaySound.playSound(FAIL_SOUND, false)
		                		sender:runAction(cc.Sequence:create(
		                			--cc.DelayTime:create(1.62),
		                			cc.DelayTime:create(0.62),
		                			cc.CallFunc:create( 
	                					function(sender)
	                						goFlag = 0
	                						aLabel_getjifen:setValue(0)
	   										GamblingLayer:inGame1()
	   										--sendGetNewCurrScore()

       										--[[
	                						goFlag = 0
	                						g_game2loseDlg:setVisible(true)
	                						g_Panel_game1:setVisible(false)
	                						ccui.Helper:seekWidgetByName(root, "Text_losePaixing"):setString(nameRet[seondRetData.data.handType])
	   										aLabel_getjifen:setValue(0)
	                						sendGetNewCurrScore()
	                						]]
	            						end)
		                		 ))
								
		                	end
		                end

	                	GamblingLayer:resetLockState()
	                end
                end)
            ))

            flagNum = flagNum + 1
    	end
    end

    if(isAllLock == true) then
    	for i = 1, 5 do
			DZPlaySound.stopSound(gunSoundId[i])
		end
		--滚动显示牌型
		scrollTxtLabelLogic:setScrollTxtPosWithIdx(11 - seondRetData.data.handType)

    	if(seondRetData.data.scores ~= nil) then
    		--currScore = tonumber(seondRetData.data.scores)
    		--aLabel_jifen:setValue(seondRetData.data.scores)
    	end
    	
    	if(seondRetData.data.winScore ~= nil) then
    		--getJiFen_num = getJiFen_num + seondRetData.data.winScore
    		--aLabel_getjifen:setValue(getJiFen_num)
    		getJiFen_num = seondRetData.data.winScore
    		aLabel_getjifen:setValue(seondRetData.data.winScore)
    	end

    	--先判断中没中jackpot
    	--中了jackpot
    	local tmpFlag = seondRetData.data.isJackpot
    	if(tmpFlag == 1) then 
    		print("第二次发牌中jackpot")
    		DZPlaySound.playSound(LUCKY_SOUND, false)
    		--延迟弹框
    		_layer:runAction(cc.Sequence:create(
    			cc.DelayTime:create(1.62),
    			cc.CallFunc:create( 
					function(sender)
						--播放粒子特效
						GamblingLayer:runParBoom()
						--[[local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
						ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
                		emitter:setPosition(cc.p(374, 694.87))
						]]
						goFlag = 0
						
						--播放粒子特效
						--[[
						local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
						ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter, 1000)
                		emitter:setPosition(cc.p(374, 694.87))
						]]
						--跑马灯
						GamblingLayer:runPMD()
						ccui.Helper:seekWidgetByName(root, "Panel_showWincp1"):setVisible(true)
						--开启下注时，是否继续比大小询问提示
	                	isCanShowInGame = true
						ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtpxjg"):setString(nameRet[tonumber(seondRetData.data.handType)])
						ccui.Helper:seekWidgetByName(root, "Text_jackpoptxtcpjf1"):setString(tostring(seondRetData.data.jackpotScore).."记分牌")
            			ccui.Helper:seekWidgetByName(root, "Text_jackpopcp1jftt"):setString(tostring(seondRetData.data.winScore))
						g_Panel_game1:setVisible(false)
						--跑马灯
						GamblingLayer:runPMD()
        						
					    --重置保存游戏2翻牌界面的牌形
						game2handType = seondRetData.data.handType

						 --皇家同花顺不能比大小
						if(game2handType == 1 or game2handType == 2) then 
							ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(false)
						else
							ccui.Helper:seekWidgetByName(root, "Button_playdaxiaocp1"):setVisible(true)
						end
						--GamblingLayer:inGame2()

						local btn = nil 
						btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
						btn:setEnabled(true)
						btn = ccui.Helper:seekWidgetByName(root, "Button_go")
						btn:setEnabled(true)
						btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
						btn:setEnabled(true)

						ccui.Helper:seekWidgetByName(root, "Button_noplaywincp1"):setVisible(false)
						
					end)
    		 ))
    			
    	--没中jackpot逻辑
    	else
        	--不为10证明中奖了
        	if((11 - seondRetData.data.handType) ~= 1) then
        		DZPlaySound.playSound(LUCKY_SOUND, false)
        		print("~~中奖了2~~~")
        		GamblingLayer:runParBoom()	
				goFlag = 0
				g_game1winDlg:setVisible(true)
				--开启下注时，是否继续比大小询问提示
	            isCanShowInGame = true
				g_Panel_game1:setVisible(false)
				ccui.Helper:seekWidgetByName(root, "Text_jackpoptxt"):setVisible(false)
				ccui.Helper:seekWidgetByName(root, "Text_paiXingWin"):setString(nameRet[seondRetData.data.handType])
        		game2handType = seondRetData.data.handType

        		--皇家同花顺不能比大小
				if(game2handType == 1 or game2handType == 2) then 
					ccui.Helper:seekWidgetByName(root, "Button_playdaxiao"):setVisible(false)
				else
					ccui.Helper:seekWidgetByName(root, "Button_playdaxiao"):setVisible(true)
				end

				--发牌下注按钮弹起
				local btn = nil 
				btn = ccui.Helper:seekWidgetByName(root, "Button_tz")
				btn:setEnabled(true)
				btn = ccui.Helper:seekWidgetByName(root, "Button_go")
				btn:setEnabled(true)
				btn = ccui.Helper:seekWidgetByName(root, "Button_zdtz")
				btn:setEnabled(true)

				ccui.Helper:seekWidgetByName(root, "Button_noplaywin"):setVisible(false)
        	--没中奖逻辑
        	else
        		DZPlaySound.playSound(FAIL_SOUND, false)
        		goFlag = 0
    			aLabel_getjifen:setValue(0)
				GamblingLayer:inGame1()
				--sendGetNewCurrScore()
        		--[[
        		DZPlaySound.playSound(FAIL_SOUND, false)
				goFlag = 0
				g_game2loseDlg:setVisible(true)
				g_Panel_game1:setVisible(false)

				ccui.Helper:seekWidgetByName(root, "Text_losePaixing"):setString(nameRet[seondRetData.data.handType])
				aLabel_getjifen:setValue(0)
				sendGetNewCurrScore()
				]]
        	end
        end
    	GamblingLayer:resetLockState()       
    end
end

--播放粒子特效
function GamblingLayer:runParBoom()

	root:runAction(cc.Sequence:create(
		cc.CallFunc:create( 
			function(sender)
				--播放粒子特效
				local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
				--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
        		batchParNode:addChild(emitter)
        		emitter:setPosition(cc.p(488.35, 707.68))
        		emitter:setAutoRemoveOnFinish(true)
			end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create( 
			function(sender)
				--播放粒子特效
				local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
				--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
        		batchParNode:addChild(emitter)
        		emitter:setPosition(cc.p(293.92, 678.30))
        		emitter:setAutoRemoveOnFinish(true)
			end),
		cc.DelayTime:create(0.4),
		cc.CallFunc:create( 
			function(sender)
				--播放粒子特效
				local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
				--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
        		batchParNode:addChild(emitter)
        		emitter:setPosition(cc.p(445.87, 590.51))
        		emitter:setAutoRemoveOnFinish(true)
			end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create( 
			function(sender)
				--播放粒子特效
				local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
				--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
        		batchParNode:addChild(emitter)
        		emitter:setPosition(cc.p(198.74, 545.46))
        		emitter:setAutoRemoveOnFinish(true)
			end),
		cc.DelayTime:create(0.08),
		cc.CallFunc:create( 
			function(sender)
				--播放粒子特效
				local emitter = cc.ParticleSystemQuad:create(PAR_JACKPOT)
				--ccui.Helper:seekWidgetByName(root, "Panel_panelGame"):addChild(emitter)
        		batchParNode:addChild(emitter)
        		emitter:setPosition(cc.p(555.26, 557.46))
        		emitter:setAutoRemoveOnFinish(true)
			end)
	 ))

end

--重置锁状态
function GamblingLayer:resetLockState()
	--隐藏锁头
    lockObjArr[6]:setVisible(false)
    GamblingLayer:isCanTouchLock(false)

    for i = 1, 5 do
		lockObjArr[i].value = false
		lockObjArr[i].lockImg:loadTexture("gambling/g_unlock.png")
		lockObjArr[i].deng:setVisible(false)
	end
end

--设置锁头触摸状态
function GamblingLayer:isCanTouchLock(isEnable)
	for i = 1, 5 do
		lockObjArr[i].lockImg:setTouchEnabled(isEnable)
	end
end

--展示牌道移动到某个位置
function GamblingLayer:moveShowPanelWithIdx(idx, posY)
	showPanelArr[idx]:stopAllActions()
	showPanelArr[idx]:runAction(cc.MoveTo:create(0.1, cc.p(showPanelArr[idx]:getPositionX(), posY)))
end

--展示牌道重置初始位置
function GamblingLayer:resetShowPanelPos()
	for i, tPanel in ipairs(showPanelArr) do
        tPanel:setPositionY(showPanelInitPosY[i])
    end
end

--设置某个展示牌道牌值
function GamblingLayer:setShowPanelValue(idx, value)
	local tValue = value
	local tImg = nil
	for i = 1, 3 do
		tValue = value + i - 2
		
		if(value + i - 2 <= 0) then
			tValue = 52
		elseif (value + i - 2 >= 53) then
			tValue = 1
		end

		tImg = ccui.Helper:seekWidgetByName(showPanelArr[idx], "Image_s"..i)
		tImg:loadTexture(DZConfig.cardName(tValue))
	end
end

--显示某个牌道
function GamblingLayer:showPanelWithIdx(idx)
	showPanelArr[idx]:setVisible(true)
end

--隐藏某个滚动牌道
function GamblingLayer:hideScrollWithIdx(idx)
	scrollPanelArr[idx]:setVisible(false)
end

--隐藏某个滚动牌道
function GamblingLayer:setWhichLayerInTag(tag)
	m_whichLayerIn_tag = tag
end

function GamblingLayer.showGambling()
 	--cc.Director:getInstance():getTextureCache():removeUnusedTextures()
 	m_whichLayerIn_tag = 0
	local runScene = cc.Scene:create()
	cc.Director:getInstance():replaceScene(runScene)

    --local runScene = cc.Director:getInstance():getRunningScene()
    _layer = cc.LayerColor:create(cc.c4b(0,0,0,255))
	createLayer()
	local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
	local width = framesize.width / scaleY
	local height = framesize.height / scaleY
	--cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
	--local realx = (framesize.width / scaleY - 750)*0.5
	--_layer:setPosition(cc.p(realx, 0))

 	local function onEvent(event)
        if event == "enter" then
        	schedulerEntryJack = nil--jackpop计时器
 			schedulerEntrySendMeg = nil--开始发送消息计时器
			schedulerEntryUpdateUI = nil--更新UI
        elseif event == "enterTransitionFinish" then
			
			--oldkc adapter
			-- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
			-- local ratio = tframesize.height/tframesize.width
   --      	if ratio >= 1.5 then
			-- 	local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
			--   	local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
			--     local width = framesize.width / scaleY
			--     local height = framesize.height / scaleY
			--     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
			--     local realx = (framesize.width / scaleY - 750)*0.5
			-- 	_layer:setPosition(cc.p(realx, 0))
			-- end
			--newdz adapter
			local realx = StringUtils.setKCAdapter()
			if realx then
				_layer:setPosition(cc.p(realx, 0))
			end


        	local scheduler = cc.Director:getInstance():getScheduler()
			schedulerEntrySendMeg = scheduler:scheduleScriptFunc(function(dt)
				--createLayer()
				sendMeg()

				local scheduler = cc.Director:getInstance():getScheduler()
				if(schedulerEntrySendMeg ~= nil) then
					scheduler:unscheduleScriptEntry(schedulerEntrySendMeg)
				end

				schedulerEntryUpdateUI = scheduler:scheduleScriptFunc(function(dt)
					updateUI()
    			end, 0, false)
			
    		end, 0.1, false)

--[[
    		schedulerEntryUpdateUI = scheduler:scheduleScriptFunc(function(dt)
				updateUI()
    		end, 0, false)
]]
        	--获取下注数组
			--sendGetBetArr()
			--sendInitGameMeg()

--[[
			_layer:runAction(cc.Sequence:create(
    		cc.DelayTime:create(0.1),
            cc.CallFunc:create( 
                function(sender)
                	sendGetBetArr()
			    	sendInitGameMeg()
			    	
			    	local scheduler = cc.Director:getInstance():getScheduler()
						schedulerEntryJack = scheduler:scheduleScriptFunc(function(dt)
						sendjackPop()
    				end, 2, false)
					
                end)))
]]
			
        elseif event == "exit" then


			ccexp.AudioEngine:stopAll()
			DZPlaySound.unloadSound(BGM_SOUND)
			local scheduler = cc.Director:getInstance():getScheduler()
			if(schedulerEntryJack ~= nil) then
				scheduler:unscheduleScriptEntry(schedulerEntryJack)
				schedulerEntryJack = nil
			end

			if(schedulerEntryUpdateUI ~= nil) then
				scheduler:unscheduleScriptEntry(schedulerEntryUpdateUI)
				schedulerEntryUpdateUI = nil
			end

			scrollTxtLabelLogic:removeScheduler()
			aLabel_touzhu:removeScheduler()
			aLabel_baiju:removeScheduler()
			aLabel_getjifen:removeScheduler()
			aLabel_jifen:removeScheduler()
			aLabel_jackp:removeScheduler()
			--test
			--aLabel_test:removeScheduler()

			scrollActionLogic:removeScheduler()
			--_layer:removeFromParent()

			--oldkc
			-- local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
		 --  	local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
		 --    local width, height = framesize.width, framesize.height

			-- width = framesize.width / scaleX-----
			-- height = framesize.height / scaleX----

			-- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
			-- local ratio = tframesize.height/tframesize.width
			-- print("exit----rrrr=="..ratio)
	  --       if ratio >= 1.5 then
	  --       	cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
			-- else
			-- end
			--newdz
			StringUtils.setDZAdapter()

        	--[[
			ccexp.AudioEngine:stopAll()

			local scheduler = cc.Director:getInstance():getScheduler()
			if(schedulerEntryJack ~= nil) then
				scheduler:unscheduleScriptEntry(schedulerEntryJack)
			end

			if(schedulerEntryUpdateUI ~= nil) then
				scheduler:unscheduleScriptEntry(schedulerEntryUpdateUI)
			end

			scrollTxtLabelLogic:removeScheduler()
			aLabel_touzhu:removeScheduler()
			aLabel_baiju:removeScheduler()
			aLabel_getjifen:removeScheduler()
			aLabel_jifen:removeScheduler()
			aLabel_jackp:removeScheduler()
			--test
			aLabel_test:removeScheduler()

			scrollActionLogic:removeScheduler()
			--_layer:removeFromParent()

			local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
		  	local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
		    local width, height = framesize.width, framesize.height

			width = framesize.width / scaleX
			height = framesize.height / scaleX
		    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
        	]]
        end
    end
    
    _layer:registerScriptHandler(onEvent)

    -- framesize.width:(750 + 2x) = scaleY 求x
	--print("realX="..realx)
    runScene:addChild(_layer, 999)
    --cc.CSLoader:createNodeWithVisibleSize(ResLib.GAMBLING_CSB)
end

return GamblingLayer