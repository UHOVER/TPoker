local GAnimation = {}
local _is2000 = false
local _is2001 = false
local _is2002 = false
local _is2003 = false
local _is2005 = false
local _is2007 = false
local _is2101 = false
local _is2102 = false
local _is2104 = false
local _is2107 = false
local _is2108 = false
local _is2200 = false

local _queues = {}
local _scheduleId = nil
local _scheduler = cc.Director:getInstance():getScheduler()

--头像运动 0.8 秒，位置转动开始--转动结束
function GAnimation.startRun2000()
	_is2000 = true
end
function GAnimation.endRun2000()
	_is2000 = false
end
local function isRunning2000()
	return _is2000
end

--广播开始--move_to_now_bet结束
function GAnimation.startRun2001()
	_is2001 = true
end
function GAnimation.endRun2001()
	_is2001 = false
end
local function isRunning2001()
	return _is2001
end

--广播开始--move_to_now_bet 0.5、 定时0.6秒后结束 结束 或 没有运行move_to_now_bet
function GAnimation.startRun2002()
	_is2002 = true
end
function GAnimation.endRun2002()
	_is2002 = false
end
local function isRunning2002()
	return _is2002
end

--1.move_to_pool_bet 0.5、2.翻转底池里的牌 0.4超过两张0.8		广播开始--翻转后结束
function GAnimation.startRun2003()
	_is2003 = true
end
function GAnimation.endRun2003()
	_is2003 = false
end
local function isRunning2003()
	return _is2003
end

--
function GAnimation.startRun2005()
	_is2005 = true
end
function GAnimation.endRun2005()
	_is2005 = false
end
local function isRunning2005()
	return _is2005
end

--1.move_to_win_bet 0.5、2.过0.6秒后展示赢标示 0.8、3.过1秒后翻两张底牌 0.4+1+0.8		广播开始--翻转完结束
function GAnimation.startRun2007()
	_is2007 = true
end
function GAnimation.endRun2007()
	_is2007 = false
end
function GAnimation.isRun2007()
	return _is2007
end
local function isRunning2007()
	return _is2007
end

function GAnimation.startRun2101()
	_is2101 = true
end
function GAnimation.endRun2101()
	_is2101 = false
end
local function isRunning2101()
	return _is2101
end

function GAnimation.startRun2102()
	_is2102 = true
end
function GAnimation.endRun2102()
	_is2102 = false
end
local function isRunning2102()
	return _is2102
end

function GAnimation.startRun2104()
	_is2104 = true
end
function GAnimation.endRun2104()
	_is2104 = false
end
local function isRunning2104()
	return _is2104
end

function GAnimation.startRun2107()
	_is2107 = true
end
function GAnimation.endRun2107()
	_is2107 = false
end
local function isRunning2107()
	return _is2107
end

function GAnimation.startRun2200()
	_is2200 = true
end
function GAnimation.endRun2200()
	_is2200 = false
end
local function isRunning2200()
	return _is2200
end

function GAnimation.startRun2108()
	_is2108 = true
end

function GAnimation.endRun2108()
	_is2108 = false
end

local function isRunning2108()
	return _is2108
end

local function isRunning2101_2108_2107()
	if isRunning2107() == false and isRunning2108() == false and isRunning2101() == false then
		return false
	end
	return true
end
--复合
local function isRunning2102_2104()
	if isRunning2102() == false and isRunning2104() == false then
		return false
	end
	return true
end

local function isRunning2000_2007()
	if isRunning2000() == false and isRunning2007() == false then
		return false
	end
	return true
end

local function isRunning2000_2007_2200()
	if isRunning2000() == false and isRunning2007() == false and isRunning2200() == false then
		return false
	end
	return true
end

local function isRunning2002_2003_2108()
	if isRunning2002() == false and isRunning2003() == false and isRunning2108() == false then
		return false
	end
	return true
end

local function isRunning2002_2003_2001()
	if isRunning2002() == false and isRunning2003() == false and isRunning2001() == false then
		return false
	end
	return true
end

local function isRunning2002_2003_2005_2017()
	if isRunning2002() == false and isRunning2003() == false and isRunning2005() == false and isRunning2107() == false then
		return false
	end
	return true
end

local function isRunning2002_2003_2001_2007()
	if isRunning2002_2003_2001() == false and isRunning2007() == false then
		return false
	end
	return true
end


function GAnimation.init()
	_is2000 = false
	_is2001 = false
	_is2002 = false
	_is2003 = false
	_is2005 = false
	_is2007 = false
	_is2101 = false
	_is2102 = false
	_is2104 = false
	_is2107 = false
	_is2200 = false
end


--1.2000不影响、2002、2003、2005：执行2007前
--2.2000不影响、2001、2002、2003、2007：执行2005前
--3.2001、2002：执行2003前
local handles = {}
handles[ BRO_ANTE_BET ] 		= isRunning2000_2007			--2200必须等2000位置转动播放完
handles[ BRO_SEND_CARDS ] 		= isRunning2000_2007_2200		--2001必须等2000位置转动播放完
handles[ BRO_PLAYER_SELECT ]	= isRunning2002_2003_2001 		--2002必须要等2003和2002和2001结束
handles[ BRO_SEND_POOL ]		= isRunning2002_2003_2001 		--2003必须等2002运行完、2003必须等2003,有可能好几个2003同时发出
handles[ BRO_ROUND_RESULT ] 	= isRunning2002_2003_2005_2017	--2007必须等2003和2002和2005
handles[ BRO_STAND_LOOK ]		= isRunning2002_2003_2001_2007 	--2005必须要等2007结束
handles[ BRO_HOME_CLOSE ]		= isRunning2007 				--2009必须要等2007结束
handles[ BRO_CHECK_BET ]		= isRunning2007 				--2020必须要等2007结束
handles[ BRO_MTT_REVIVE ]		= isRunning2007 				--2028必须要等2007结束

handles[ BRO_INTO_INSURE_MODE ]	= isRunning2002_2003_2108 			--2101必须要等2007结束
handles[ BRO_INSURE_PURCHASE ]	= isRunning2101_2108_2107 		--2102必须要等2007结束
handles[ BRO_INSURE_BUY_END ]	= isRunning2102 				--2104必须要等2007结束
handles[ BRO_INSURE_FLOP_CARD ]	= isRunning2102_2104 			--2107必须要等2007结束
handles[ BRO_INSURE_LIGHT_CARD ]= isRunning2102

handles[ BRO_MTT_REST ]			= isRunning2007 				--2027必须要等2007结束
handles[ BRO_MTT_OVER ]			= isRunning2007 				--2029必须要等2007结束
handles[ BRO_CLOSE_ROOM ]		= isRunning2007 				--2031必须要等2007结束
handles[ BRO_PLAYER_SEAT ]		= isRunning2005 				--2000必须要等2005结束
handles[ BRO_ADD_SCORES ]       = isRunning2007 


--广播队列
local BroCtrol = require 'game.BroCtrol'

local count = 1
local _befPNum = 0
local function checkQueue()
	if #_queues == 0 or Single:gameModel():isPause() then return end
	local topData = _queues[ 1 ]

	count = count + 1

	local pnum = topData['protocolNum']
	if handles[ pnum ] == nil then
		GAnimation.popData(topData)
		count = 0
		_befPNum = pnum
	elseif handles[ pnum ]() == false then
		GAnimation.popData(topData)
		count = 0
		_befPNum = pnum
	end

	if count > 250 then
		local protext = '| '
		for proi = 1,#_queues do
			protext = protext.._queues[ proi ]['protocolNum']..' | '
		end

		count = 0
		-- ViewCtrol.showMsg('没有出栈协议'..pnum, 20)
		print('stack checkQueue没有出栈协议  '..pnum..'  '..protext)
		local logs = '没有出栈协议'
		local explain = protext..'  checkQueue  出问题的协议号 '..pnum..' 前一个协议号 '.._befPNum
		Single:appLogs(logs, explain)
		GAnimation.init()

		Single:requestGameDataAgain()
	end
end

function GAnimation.pushData(data)
	table.insert(_queues, data)
end


local function delayFunc()
	-- ViewCtrol.showMsg('网络延迟', 2)
	print('stack 网络延迟 delayFunc')
	Single:requestGameDataAgain()
end

--发2007时如果有2001或2002或2003或2007代表网络延迟
--2001、2002、2003   2007
local function handleDelayNet(pnum)
	local compareNum = -1
	-- if pnum == BRO_ROUND_RESULT then
	-- 	compareNum = BRO_SEND_CARDS
	-- elseif pnum == BRO_SEND_POOL then
	-- 	compareNum = BRO_SEND_POOL
	-- end
	if pnum == BRO_SEND_POOL then
		compareNum = BRO_SEND_POOL
	end

	for i=#_queues,1,-1 do
		local proNum = _queues[ i ]['protocolNum']

		if proNum == compareNum then
			delayFunc()
			break
		end
	end
end

--发牌延迟2002，有2003并且2003后面有两个2002
local function handleDelaySendCard()
	local tagNum = 0

	for i=#_queues,1,-1 do
		local proNum = _queues[ i ]['protocolNum']
		if tagNum == 2 and proNum == BRO_PLAYER_SELECT then
			delayFunc()
			break
		end

		if tagNum == 1 and proNum == BRO_PLAYER_SELECT then
			tagNum = 2
		end

		if proNum == BRO_SEND_POOL then
			tagNum = 1
		end
	end
end


function GAnimation.popData(topData)
	-- if #_queues == 0 then return end
	BroCtrol.sendBro(topData)
	table.remove(_queues, 1)

	local pnum = topData['protocolNum']
	if pnum == BRO_ROUND_RESULT or pnum == BRO_SEND_POOL then
		handleDelayNet(pnum)	
	elseif pnum == BRO_PLAYER_SELECT then
		handleDelaySendCard()
	end
end


--计时
function GAnimation.startSchedule()
	if _scheduleId then 
		GAnimation.removeSchedule()
	end

	GAnimation.clearData()
    _scheduleId = _scheduler:scheduleScriptFunc(checkQueue, 0.05, false)
end

function GAnimation.removeSchedule()
	if _scheduleId then
        _scheduler:unscheduleScriptEntry(_scheduleId)
        _scheduleId = nil
    end
end

function GAnimation.clearData()
	GAnimation.init()
	_queues = {}
end

return GAnimation