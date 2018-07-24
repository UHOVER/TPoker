local Network = {}
-- local _wsAddress = "ws://101.201.48.107:8080"
-- local _wsAddress = "ws://101.201.48.107:8060"
-- local _wsAddress = "ws://192.168.199.109:8080"
-- local _wsAddress = "ws://101.201.48.107:8066"
local _wsAddress = "ws://114.215.68.59:8080"

if DZ_MASTER_VERSION then
	_wsAddress = "ws://api.allbetspace.com:8080"
end

local TEXT_STATE_CONNECTING = '当前网络连接中...'
local TEXT_STATE_OPEN  		= '当前网络已经打开'
local TEXT_STATE_CLOSING 	= '当前网络关闭中...'
local TEXT_STATE_CLOSED		= '当前网络已经关闭'

local _broadcastHandlers = {}
local _requestHandlers = {}
local _wsocket = nil

--true:连接socket并且token初始化成功、false:网络close
local _isLinking = false
local _isIgnoreBro = false

-- ------------------------------ ------------------------
--[[
	--	一个简单的处理加密的方式
]]
-- --------------------------------------------------------
local function customCrypt(str, pw)
	local keystr = pw or "ydwx"
	local result = ""
	for i = 1, #str do 
		local char = string.byte(str, i)
		for j = 1, #keystr do
			 local pchar = string.byte(keystr, j)
			 char = bit.bxor(char, pchar)
		end
		result = result..string.char(char)
	end
	return result
end
------------------------------------------------------------

local function checkLinkSocket()
	if DZConfig.isInLogin() or _isLinking then return end

	Network.close()
	print('连接方式  checkLinkSocket')
	Network.connect()
end
local linkSchedulerId = DZSchedule.scheduleGlobal(5, checkLinkSocket)


local function broadcast(opcode, data)
	for i = #_broadcastHandlers,1,-1 do
        local v = _broadcastHandlers[ i ]
        
        if v.func == nil then
            table.remove(_broadcastHandlers, i)
        else
            v.func(opcode, data)
        end
    end
end

local function removeHandle(opcode, data, isOnlyRemove)
	for i = 1,#_requestHandlers do
        local v = _requestHandlers[ i ]

        if opcode == v.proid then
            if v.isbg then
            	ViewCtrol.hideWaitServer()
            end
			
            table.remove(_requestHandlers, i)

            if isOnlyRemove then return end

            if v.func ~= nil then
                v.func(data)
            end

			break
        end
    end
end

local function response(opcode, data)
	removeHandle(opcode, data, false)
end


local function wsOnMessage(jsonData)
	-- print('websocket ---- msg json response '..jsonData)
	--TODO:json解密
	--local jsonData = customCrypt(jsonData)
	local tabData = json.decode(jsonData, 1)
	local opcode = tabData['protocolNum']

	if not opcode then
		ViewCtrol.showMsg(tabData['errMsg'])
		ViewCtrol.hideWaitServer()
		return 
	end

	dump(tabData)

	--此时忽略广播
	if Network.isIgnoreBro() then
		if opcode ~= BRO_PHP_3000 then
			removeHandle(opcode, data, true)
			return
		end
	end

	if opcode >= 2000 then
		print('====== 广播 '..opcode)
		if not Network.isStopCacheBro() then
			broadcast(opcode, tabData)
		else 
			_packageMsg[#_packageMsg + 1] = tabData
		end
	else
		print(opcode..'--------请求')
		response(opcode, tabData)
	end
end

local function wsOnOpen(netData)
	print('websocket ---- open')
    local WaitServer = require 'ui.WaitServer'
	WaitServer.removeForeverWait()

	--充值计时
	local CheckNet = require 'network.CheckNet'
	CheckNet.resetWSCountTime()

	--是否显示屏蔽层
	local isDisLoading = false

	--游戏中链接node显示loding
	local GameScene = require 'game.GameScene'
	if GameScene.isDisGameScene() then
		isDisLoading = true
	end

	local tab = {}
	tab['token'] = XMLHttp.getGameToken()
	Network.request(WS_INIT_LINK, tab, function(data)
		ViewCtrol.removeWaitServer()
		_isLinking = true

		GameScene.EnterForeground(data)
	end, isDisLoading)
end

local function wsOnClose(netData)
	Network.closeOrError()
	ViewCtrol.removeWaitServer()
	print('websocket ---- close')
end

local function wsOnError(netData)
	Network.closeOrError()
	print('websocket ---- error')
	ViewCtrol.removeWaitServer()
end


--状态码
local function getWSocketState()
	if not _wsocket then return nil end
	return _wsocket:getReadyState()
end


function Network.request(pnum, tabData, funcBack, isShowWaitBg)
	local state = getWSocketState()
	if not state or state == cc.WEBSOCKET_STATE_CLOSING then
		ViewCtrol.showMsg('当前网络不好', 2)	
		Network.connect()	
		return
	end

	tabData['protocolNum'] = pnum

	local handler = {}
    handler.proid = tabData['protocolNum']
    handler.func = funcBack
    handler.isbg = isShowWaitBg
	handler.waitSecs = 0
	handler.data = tabData
	handler['startTime'] = os.time()
	
	if isShowWaitBg then	
        ViewCtrol.showWaitServer()
    end

    print_f(tabData)
	if cc.WEBSOCKET_STATE_OPEN == _wsocket:getReadyState() then
		table.insert(_requestHandlers, handler)
	--TODO:下面这段代码是加密函数
	--local str = customCrypt(json.encode(tabData))
		_wsocket:sendString(json.encode(tabData))
	end
end

local function checkWaitTime()
	for i=1,#_requestHandlers do
		local req = _requestHandlers[ i ]
		if os.time() - req['startTime'] > 9 then
			removeHandle(req['proid'], {}, true)
			ViewCtrol.showMsg('网络不好', 2)

			checkLinkSocket()
			
			break
		end
	end	
end
local waitSchedulerId = DZSchedule.scheduleGlobal(1, checkWaitTime)

function Network.bindBroadcast(funcBack)
	if type(funcBack) ~= 'function' or not funcBack then
		assert(nil, 'bindBroadcast funcBack error')
	end

	local maxId = 0
    for k,v in pairs(_broadcastHandlers) do
        maxId = math.max(maxId, v.id)
    end

    local handler = {}
    handler.id = maxId + 1
    handler.func = funcBack
    table.insert(_broadcastHandlers, handler)
    return handler.id
end


function Network.unbindBroadcast(id)
	if id == nil then
		assert(nil, 'unbindBroadcast id is nil')
	end

	for i = #_broadcastHandlers,1,-1 do
        local v = _broadcastHandlers[ i ]
        if v.id == id then
            table.remove(_broadcastHandlers, i)
        end
    end
end


function Network.connect()
	local state = getWSocketState()

	if state == cc.WEBSOCKET_STATE_CONNECTING then
		ViewCtrol.showMsg(TEXT_STATE_CONNECTING, 2)	
		return
	end

	Network.clearRequest()
	Network.close()
	print('重新连接 socket connect')
	-- 请求红点数据
	Notice.requestBuildCard(true, function (  )
		Notice.requestRedData( true, 0 )
	end, 0)
	
	--游戏界面显示加载
	local GameScene = require 'game.GameScene'
	if GameScene.isDisGameScene() then 
	    local WaitServer = require 'ui.WaitServer'
	    WaitServer.showForeverWait()
	end

	_wsocket = cc.WebSocket:create(_wsAddress)
	_wsocket:registerScriptHandler(wsOnOpen, cc.WEBSOCKET_OPEN)
	_wsocket:registerScriptHandler(wsOnMessage, cc.WEBSOCKET_MESSAGE)
	_wsocket:registerScriptHandler(wsOnClose, cc.WEBSOCKET_CLOSE)
	_wsocket:registerScriptHandler(wsOnError, cc.WEBSOCKET_ERROR)	
end



function Network.close()
	print('关闭  client close socket')
	_isLinking = false
	if _wsocket then
		_wsocket:close()
	end
	_wsocket = nil

	ViewCtrol.removeWaitServer()
end

function Network.closeOrError()
	Network.close()
end


function Network.switchUser()
	_broadcastHandlers = {}
	_requestHandlers = {}
	Network.close()
end


function Network.getWebsocket()
	return _wsocket
end

function Network.clearRequest()
	_requestHandlers = {}
end


function Network.setTestWSAddress(testws)
	_wsAddress = testws
end
function Network.getTestWSAddress(testws)
	return _wsAddress
end

--忽略广播
function Network.setIgnoreBro(ignore)
	_isIgnoreBro = ignore
end
function Network.isIgnoreBro()
	return _isIgnoreBro
end



---------------------------------------------
--广播开关测试
---------------------------------------------
local _isPause, _packageMsg = false, nil
function Network.launchCacheBro()
	_isPause = true
	_packageMsg = {}
end

function Network.closeCacheBro()
	_isPause = false
	if not _packageMsg then return end
	--推入到流中
	for i = 1, #_packageMsg do 
		local tabData = _packageMsg[i]
		local opcode = data['protocolNum']
		broadcast(opcode, tabData)
	end
	_packageMsg = nil
end

function Network.isStopCacheBro()
	return _isPause, _packageMsg
end

function Network.destory()
	local tscheduler = cc.Director:getInstance():getScheduler()
	if linkSchedulerId then 
		tscheduler:unscheduleScriptEntry(linkSchedulerId)
	end

	if waitSchedulerId then 
		tscheduler:unscheduleScriptEntry(waitSchedulerId)
	end

	Network.close()
	Network.clearRequest()
	Network.closeCacheBro()
end
--network 消息号测试 Debug
function Network.debug(protocolNum)
	-- TestCase.startTime()
	local TestCase = require('utils.TestCaseMessage')
	TestCase.wsOnMessage = wsOnMessage
	TestCase.sendMessageDelay(protocolNum, 0, wsOnMessage)
end

return Network