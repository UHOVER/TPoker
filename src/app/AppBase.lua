
local AppBase = class("AppBase")
local GameScene = require 'game.GameScene'

local function isColseNetwork()
	local platform = cc.Application:getInstance():getTargetPlatform()
	if platform ~= cc.PLATFORM_OS_ANDROID then
		return true
	end

	--android 聊天
	-- if DZChat.isShowChatView() then
	if GameScene.isDisGameScene() then
		return true
	end

	return true
	-- return false
end


function AppBase:ctor()
end

local function LuaReomve(str,remove)
    local lcSubStrTab = {}  
    while true do  
        local lcPos = string.find(str,remove)  
        if not lcPos then  
            lcSubStrTab[#lcSubStrTab+1] =  str      
            break  
        end  
        local lcSubStr  = string.sub(str,1,lcPos-1)  
        lcSubStrTab[#lcSubStrTab+1] = lcSubStr  
        str = string.sub(str,lcPos+1,#str)  
    end  

    local lcMergeStr =""  
    local lci = 1
    while true do
        if lcSubStrTab[lci] then  
            lcMergeStr = lcMergeStr .. lcSubStrTab[lci]   
            lci = lci + 1 
        else
            break
        end  
    end
    return lcMergeStr  
end 

local _isRequest = true
function AppBase:client_logs(errMsg)
	-- if DZ_DEBUG then return end 
	-- print('errMsg 测试测试'..errMsg)
	if not _isRequest then return end
	local function netBack()
	end
	print("step1")
	_isRequest = false
	DZSchedule.schedulerOnce(1, function()
		_isRequest = true
	end)
	print("step2")

	local platformNum = cc.Application:getInstance():getTargetPlatform()
	local platformText = 'ios'
	if platformNum == cc.PLATFORM_OS_ANDROID then
		platformText = 'android'
	end
	print("step3")
	local msg = LuaReomve(errMsg,'"')

	--json中不能有tab 【\t】 转义[\'] 换行 
	msg = string.gsub(msg, "[\n\t\']", function(str) 
										local result = nil
										if str == "\n" then 
											result = "\\n"
										elseif str == "\t" then 
											result = "@@"
										elseif str == "\'" then 
											result = "##"
										end
										return result 
							end)

	local ret = {}
	ret['player_id'] = Single:playerModel():getId()
	ret['player_name'] = Single:playerModel():getPName()
	ret['platform'] = platformText
	ret['err_msg'] = tostring(msg)
	ret['php_url'] = 'version '..DZ_VERSION
	ret['nodejs_url'] = 'nodejs_url'
	-- XMLHttp.requestHttp(PHP_CLIENT_LOGS, ret , netBack, PHP_POST, true)
end

function AppBase:run()
	display.removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("user/country.plist", "user/country.png")

	local loginScene = require("login.LoginScene")
	loginScene.startScene()
end


function cc.exports.g_applicationDidEnterBackground()
	ccexp.AudioEngine:pauseAll()
	print('消失  g_applicationDidEnterBackground 0  消失')
	if not isColseNetwork() then
		return
	end

    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene then
		Network.close()
		GameScene.EnterBackground()
	else
		print('error  g_applicationDidEnterBackground')
	end
end
-- YDWX_DZ_ZHANGMENG_BUG _201606289_003
function cc.exports.g_applicationWillEnterForeground()
	ccexp.AudioEngine:resumeAll()
	print('显示  g_applicationWillEnterForeground  显示')

	NewMsgMgr.checkNewMsg(NewMsgMgr.INTO_BACKGROUND)
	
	if DZConfig.isInLogin() then 
		return 
	end
	
	if not isColseNetwork() then
		return
	end

    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene then
		Network.connect()
		local MttShowCtorl = require("common.MttShowCtorl")
		MttShowCtorl.connectMttStat()
	else
		print('error  g_applicationWillEnterForeground')
	end
end
-- YDWX_DZ_ZHANGMENG_BUG _201606289_003

function cc.exports.g_applicationWillTerminate()
end


local _isFirst1 = false
local _isFirst2 = false
function cc.exports.g_networkDisconnection(str)
	if _isFirst1 then return end
	print('网络断开 g_networkDisconnection')
	GameScene.NetworkDisconnection()	
	_isFirst1 = true

	DZSchedule.schedulerOnce(2, function()
		_isFirst1 = false
		end)
end
function cc.exports.g_networkConnectionAgain(str)
	if _isFirst2 then return end
	print('网络断开 g_networkConnectionAgain')
	GameScene.NetworkConnectionAgain()
	_isFirst2 = true
	
	DZSchedule.schedulerOnce(2, function()
		_isFirst2 = false
		end)
end

--来电话
function cc.exports.g_callingPhone(str)
end


--挂断电话
function cc.exports.g_hangupPhone(str)
end

return AppBase
