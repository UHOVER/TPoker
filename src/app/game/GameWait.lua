local SceneBase = require 'ui.SceneBase'
local GameWait = class("GameWait", SceneBase)
local _layer = nil
local _cs = nil
local _mttCode = 0
local _countTime = 0

local function waitAni(time, funcBack)
	local timebg = _cs:getChildByName('imgCountDown')
	timebg:removeAllChildren()
	timebg:setPositionX(display.cx)

    local color = cc.c3b(254,240,163)

	local text1 = '比赛将在     秒后开始'
	UIUtil.addLabelBold(text1, 44, cc.p(269.5,86), cc.p(0.5,0.5), timebg, cc.c3b(255,255,255))
	local label = UIUtil.addLabelBold(time, 44, cc.p(271,86), cc.p(0.5,0.5), timebg, color)

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

	local function smallTen()
		timebg:removeAllChildren()
		timebg:setPositionX(-display.cx)
		tenLabel = UIUtil.addLabelBold(ten, 150, display.center, cc.p(0.5,0.5), _cs, color)
		tenLabel:setScale(3)
		DZAction.scale(tenLabel, cc.p(1,1), cc.p(1,1), 0.5, false, startSchedule)
	end

	local function scheduleFunc()
		time = time - 1
		label:setString(time)
		if time == 10 then
			smallTen()
		end
	end

	if time <= 10 then
		ten = time
		smallTen()
	else
		DZSchedule.runSchedule(scheduleFunc, 1, label)
	end
end

local function startGame()
	-- GameWait.intoWaitScene(_mttCode)
	-- DZAction.delateTime(_cs, 7, function()
	-- 	ViewCtrol.showMsg('当前网络不好', 1)
	-- end)
	-- DZAction.delateTime(_cs, 8, function()
	-- 	local CardScene = require('cards.CardScene')
	-- 	CardScene.startScene()	
	-- end)
end


local function createLayer()
	local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.GAME_WAIT_CSB)
	_layer:addChild(cs)
	_cs = cs
	local startText = cs:getChildByName('ttfMttStart')
	GUI.setStudioFontBold({startText})

	--头像
	local color = cc.c3b(255,255,255)
	local function addMeHead(center, parent)
		local url = Single:playerModel():getPHeadUrl()
		local _,ihead = UIUtil.addUserHead(center, url, parent, true)

		local betbg = UIUtil.addPosSprite('game/game_surplus_bg.png', cc.p(center.x, center.y-72), parent, nil)
		local snum = GMath.changeNumKW(1000)
		UIUtil.addLabelBold(snum, 27, cc.p(61, 18), nil, betbg, color)
	end

	local posarr = Single:playerManager():getPosNine()
	for i=1,9 do
		local imgNull = UIUtil.addSprite(ResLib.GAME_NULL, posarr[i], cs, cc.p(0.5,0.5))
		local nulls = imgNull:getContentSize()
		local pos = cc.p(nulls.width/2, nulls.height/2)
		UIUtil.addLabelBold('坐下', 28, pos, cc.p(0.5,0.5), imgNull, color)

		if i == 1 then
			addMeHead(pos, imgNull)
		end
	end

	--倒计时
	local function aniBack()
		startText:setPositionX(display.cx)
		DZAction.scale(startText, cc.p(0.6,0.6), cc.p(1.4,1.4), 2, false, function()
			startText:setPositionX(-display.cx)
			startGame()
		end)
	end
	waitAni(_countTime, aniBack)
end


local function handleNet(mttCode, waitBack, startBack)
	local function netBack(data)
		startBack(data)
		-- if data['countDown'] <= 0 then
		-- 	startBack(data)
		-- 	return
		-- end

		-- waitBack(data)
	end

	SocketCtrol.mttMttCode(mttCode, netBack)
end


function GameWait.intoWaitScene(mttCode, clubUnionId)
	print("############## mttCode: " .. mttCode)
	_mttCode = mttCode

	local function waitFunc(data)
		_countTime = data['countDown']

		local scene = GameWait:create()
		cc.Director:getInstance():replaceScene(scene)
		_layer = cc.LayerColor:create()
		scene:addChild(_layer)

		createLayer()
	end
	local function startFunc(data)
		GData.setMttCode(mttCode)
		GData.setUnionClubId(clubUnionId)
		
		local GameScene = require 'game.GameScene'
		GameScene.startScene(data['pokerId'])
	end

	handleNet(mttCode, waitFunc, startFunc)
end


function GameWait.requestPokerId(mttCode, back)
	_mttCode = mttCode

	local function waitFunc(data)
	end
	local function startFunc(data)
		back(data['pokerId'])	
	end

	handleNet(mttCode, waitFunc, startFunc)	
end


--mtt牌局列表请求观看比赛
function GameWait.requestMttCodeAndPokerId(mttCode, pokerId)
	_mttCode = mttCode
	GData.setMttCode(mttCode)
	local GameScene = require 'game.GameScene'
	GameScene.startScene(pokerId)
end




return GameWait