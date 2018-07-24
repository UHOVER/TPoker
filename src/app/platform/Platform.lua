local Platform = {}
local _platform = cc.Application:getInstance():getTargetPlatform()
Platform.__index = Platform
local _GPSBack = nil

function Platform:getToken()
	return XMLHttp.getGameToken()
end

function Platform:getUpHeadUrl()
	return XMLHttp.getHttpUrl().."upload_img"
end

function Platform:tabToJson(tab)
	return jsonStr.encode(tab)
end
function Platform:jsonToTab(json)
	return jsonStr.decode(json, 1)
end

function Platform:getInstance()
	local plat = nil
	if (cc.PLATFORM_OS_IPHONE == _platform) or (cc.PLATFORM_OS_IPAD == _platform) or (cc.PLATFORM_OS_MAC == _platform)  then
		local ios = require 'platform.IOSPlat'
		plat = ios.createIOS()
	elseif _platform == cc.PLATFORM_OS_ANDROID then
		local android = require 'platform.AndroidPlat'
		plat = android.createAndroid()
	else
		assert(nil, 'platform.getInstance')
	end

	return plat
end


function Platform:isOpenGPS()
	local isOpen = Single:paltform():luaCallNativeFunc({}, StatusCode.NATIVE_TYPE1)
	if isOpen == 'true' then
		return true
	end
	return false
end

--获得不到时候返回1000,1000、没有开启GPS的牌局返回1000,1000
--callBack回调函数、isGPSPoker是否开启GPS限制
function Platform:getLatitudeAndLongitude(callBack, isGPSPoker)
	--没有开启GPS限制的牌局
	if not isGPSPoker then
		--同 g_setLatitudeAndLongitude 一样
		local ret = {}
		if callBack then
			callBack(1000, 1000)
		end
		return
	end

	--开启了GPS限制的牌局了，但手机没有允许获得GPS位置
	if not Single:paltform():isOpenGPS() then
		DZWindow.showGPSPrompt()
		return
	end

	ViewCtrol.showPHPWaitServer()
	_GPSBack = callBack
	local jsonStr = Single:paltform():luaCallNativeFunc({}, StatusCode.NATIVE_TYPE2)
	-- local tab = self:jsonToTab(jsonStr)
	-- return tab['longitude'], tab['latitude']
	return 1000,1000
end


local function delayBack(backFunc, tab)
	DZSchedule.schedulerOnce(0.1, function()
		backFunc()
	end)
end

function cc.exports.g_sendMobilePhoneNumber(jstr)
	local tab = jsonStr.decode(jstr, 1)	

	local function nativeBack()
		local phoneNumber = {}
		for k,v in pairs(tab["result"]) do
			for key,val in pairs(v) do
				local tmpTab = {}
				tmpTab["name"] = key
				tmpTab["number"] = val
				phoneNumber[#phoneNumber+1] = tmpTab
			end
		end
		local phoneNum = require("friend.phoneNum")
		phoneNum:getPhoneNumber( phoneNumber )
	end

	delayBack(nativeBack, 'g_sendMobilePhoneNumber')
end


function cc.exports.g_shopBuyDiamondSuccess(jstr)
	local function nativeBack()
		local PayLayer = require 'shop.PayLayer'
		PayLayer.checkDiamond()
	end
	delayBack(nativeBack, 'g_shopBuyDiamondSuccess')
end

function cc.exports.g_exitAccountLogin(jstr)
	local function nativeBack()
		local LoginCtrol = require("login.LoginCtrol")
		LoginCtrol.changeUser()
		DZChat.breakRYConnect()
		NoticeCtrol.removeNoticeNode()
		AUTO_LOGIN = false
		local loginScene = require("login.LoginScene")
		loginScene.startScene()
	end
	delayBack(nativeBack, 'g_exitAccountLogin')
end

--异步返回城市名称
function cc.exports.g_getCityName(cityNameStr)
	local function nativeBack()
		print("得到城市名称了====="..cityNameStr)
		if(cityNameStr ~= "") then
			require("main.MainLayer"):setCityValue(cityNameStr)
		else
		end
	end
	delayBack(nativeBack, 'g_getCityName')
end

--jstr：longitude：经度、latitude：纬度、isGet：0获取成功，1获取失败
--jstr：同 getLatitudeAndLongitude 一样
function cc.exports.g_setLatitudeAndLongitude(jstr)
	local tab = jsonStr.decode(jstr, 1)	
	dump(tab)
	local function nativeBack()
		ViewCtrol.removePHPWaitServer()

		--获取失败
		if tab['isGet'] == 1 then
			DZWindow.showGPSPrompt()
			_GPSBack = nil
			return
		end

		if _GPSBack then
			_GPSBack(tab['longitude'], tab['latitude'])
		end
		_GPSBack = nil
	end

	delayBack(nativeBack, 'g_setLatitudeAndLongitude')
end

return Platform