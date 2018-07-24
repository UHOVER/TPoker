local CheckNet = {}

local _isInGame = false

local function checkWebsocket(netBack)
	local tab = {}
	Network.request(WS_LINK_PING, tab, netBack, false)
end

--进入游戏界面核查网络
--1.关闭之前每3分钟核查一次网络
--2.开启每12秒核查一次网络
local ADD_TIME = 10
local MAX_WAIT_TIME = 6
local count = 0
local requestTime = -1

--重置计时
local function resetTime()
	count = 0
	requestTime = -1
end

function CheckNet.checkGameNet(scene)
	local function netCount()
		count = count + 1

		local ws = Network.getWebsocket()
		-- if not ws or ws:getReadyState() ~= cc.WEBSOCKET_STATE_CONNECTING then
		if not ws then
			resetTime()
		end

		--请求网络计时
		if requestTime >= 0 then
			requestTime = requestTime + 1
			--网络延迟
			if requestTime > MAX_WAIT_TIME then
				resetTime()

				Single:requestGameDataAgain()
			end
		end

		if count > ADD_TIME then
			requestTime = 0
			count = 0
			checkWebsocket(function()
				resetTime()
			end)
		end
	end

	local function onEvent(event)
		if event == "enter" then
        elseif event == "enterTransitionFinish" then
        	_isInGame = true

			DZSchedule.runSchedule(netCount, 1, scene)
		elseif event == "exit" then
        	_isInGame = false
		end
	end

	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	scene:addChild(tnode)
end


--链接上network充值2及时
function CheckNet.resetWSCountTime()
	resetTime()
end


function CheckNet.broHandle(data)
	--[[local function sureBtn()
		local loginScene = require("login.LoginScene")
		loginScene.startScene()
	end

	if tonumber(data['code']) == 4000 then
		local LoginCtrol = require("login.LoginCtrol")
		LoginCtrol.changeUser()

		local params = {}
		params['listener'] = sureBtn
		params['title'] = '账号重复登录'
		params['content'] = '您的账号已在其他设备登录,请您重新登录'
		MessageWin.showTip(params)
	end]]
end


function CheckNet.scheduleNet()
	local MAX_TIME = 60 * 1
	local _rtime = 0

	local function checkSchedule()
		if _isInGame then return end

		_rtime = _rtime + 1

		if _rtime > MAX_TIME then
			_rtime = 0

			checkWebsocket(function()end)
		end
	end

	DZSchedule.scheduleGlobal(1, checkSchedule)
end


return CheckNet