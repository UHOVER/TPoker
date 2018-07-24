local AndroidPlat = {}
local _className = "org/cocos2dx/lua/AndroidLua"
local _luaj = require "cocos.cocos2d.luaj"

local function delayBack(back)
	DZSchedule.schedulerOnce(0.08, back)
end

local function callLua(funcName, args, sigs)
	local function delayFunc()
		local ok,ret  = _luaj.callStaticMethod(_className, funcName, args, sigs)

	    if not ok then
	        -- assert(nil, 'error func '..funcName)
	        local logs = 'error func '..funcName
	        local explain = 'AndroidPlat.lua callLua function'
	        Single:appLogs(logs, explain)
	        return
	    else
	        print("成功调用  "..funcName)
	    end	
	end
	delayBack(delayFunc)
end

--获得渠道名
function AndroidPlat:getChannelName()
	local channelNum = Single:paltform():luaCallNativeFunc({}, StatusCode.NATIVE_TYPE3)
	return channelNum
	-- return 'ANDROID_CHANNEL_OPEN'
end

function AndroidPlat:requestMobilePhoneNumber()
	local args = {}
    local sigs = "()V"
   	callLua('requestMobilePhoneNumber', args, sigs)
end



function AndroidPlat:uploadHead(imgName, funcName, callBack)
	local function upBack(param)
		local function falseBack(  )
			DZSchedule.schedulerOnce(0.2, function()
				print(param)
				local tab = jsonStr.decode(param, 1)
				if tab['servermsg'] then
					local servermsg = jsonStr.decode(tab['servermsg'], 1)
					tab['servermsg'] = servermsg
				end

				callBack(tab['result'], tab['path'], tab['servermsg'])
			end)
		end
		UIUtil.falseShield(falseBack, nil)
	end

	local function delayFunc()
		local turl = self:getUpHeadUrl()
		local filemod = ClubModel.getOpType()
		local fileflag = ClubModel.getPhotoType()
		local args = {turl, imgName, self:getToken(), filemod, fileflag, upBack}
	    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"

	    local ok,ret  = _luaj.callStaticMethod(_className, funcName, args, sigs)
	    if not ok then
	        assert(nil, 'uploadHead')
	    else
	        print("The ret is:", ret)
	    end
	end
   delayBack(delayFunc)
end


--callBack(result, path):result(cancel, error, success)、path图片路径
function AndroidPlat:openPhotos(imgName, callBack)
	local function delayFunc()
		self:uploadHead(imgName, "openPhotos", callBack)
	end
   delayBack(delayFunc)
end

--callBack(result, path):result(cancel, error, success)、path图片路径
function AndroidPlat:openCamera(imgName, callBack)
	local function delayFunc()
		self:uploadHead(imgName, "openCamera", callBack)
	end
   delayBack(delayFunc)
end



--商店
--购买砖石
function AndroidPlat:buyShopMasonry(tradeId)
	local args = {tradeId}
    local sigs = "(Ljava/lang/String;)V"
   	callLua('buyShopMasonry', args, sigs)
end

-- 微信支付
function AndroidPlat:buyShopOfWeiXin( tab )
	tab["timestamp"] = tostring(tab["timestamp"])

	local args = {jsonStr.encode(tab)}
	local sigs = "(Ljava/lang/String;)V"
   	callLua('buyShopOfWeiXin', args, sigs)
end

-- 支付宝
function AndroidPlat:buyShopOfAliPay( str )
	local tab = {}
	tab["aliPay"] = str
	local args = {jsonStr.encode(tab)}
	local sigs = "(Ljava/lang/String;)V"
   	callLua('buyShopOfAliPay', args, sigs)
end

function AndroidPlat:backHttpUrl(  )
	local tab = {}
	tab['url'] = XMLHttp.getHttpUrl()
	tab['token'] = XMLHttp.getGameToken()
	local args = {jsonStr.encode(tab)}
	local sigs = "(Ljava/lang/String;)V"
   	callLua('backHttpUrl', args, sigs)
end



--进入游戏界面
function AndroidPlat:intoGame()
	local args = {}
    local sigs = "()V"
   	callLua('intoGame', args, sigs)	
end

--离开游戏界面
function AndroidPlat:leaveGame()
	local args = {}
    local sigs = "()V"
   	callLua('leaveGame', args, sigs)
end



function AndroidPlat:getDeviceId()
end

----获取wifi 4g3g2g
function AndroidPlat:getWiFiFlag()
	local funcName = "getWiFiFlag"
	local args = {}
	local sigs = '()Ljava/lang/String;'
	local ok,ret  = _luaj.callStaticMethod(_className, funcName, args, sigs)
    if not ok then
        print("调用  "..funcName.."失败")
    else
        print("成功调用  "..funcName)
    end	
	print("device = "..ret)
    return ret
end

-- 获取最后一条语音
function AndroidPlat:isLastVoice(ryid, playerRYId)
	local isLast = false
	local funcName = "getLastVoice"
	local tab = {}
	tab["ryid"] = tostring(ryid)
	tab["playerRYId"] = tostring(playerRYId)
	local args = {jsonStr.encode(tab)}
	local sigs = '(Ljava/lang/String;)Ljava/lang/String;'
	local ok, ret = _luaj.callStaticMethod(_className, funcName, args, sigs)
	if not ok then
		print(funcName.." not ok")
	else
		print(funcName.." success")
		isLast = ret
	end
	return isLast
end

--args表、callType调用类型
--callType：0-打开web浏览器、无返回值
--callType：1-请求是否开启GPS、返回值 true或false
--callType：3-友盟统计渠道号
function AndroidPlat:luaCallNativeFunc(args, callType)
	if not args then
		args = {}
	end
	args['NATIVE_TYPE'] = callType
	local argsjson = {jsonStr.encode(args)}
	local sigs = '(Ljava/lang/String;)Ljava/lang/String;'
	local ok, ret = _luaj.callStaticMethod(_className, 'callNativeFunc', argsjson, sigs)
	if not ok then
		print("callNativeFunc not ok  "..callType)
	end
	return ret
end
function AndroidPlat:funcNative()
end

function AndroidPlat:shakePhone()
	local args = {}
    local sigs = "()V"
   	callLua('shakePhone', args, sigs)
end

function AndroidPlat:sendMessage(name, phone, content)
	local args = {}
	args['name'] = name
	args['phone'] = phone
	args['content'] = content
	local str = self:tabToJson(args)
	local sigs = '(Ljava/lang/String;)V'
   	callLua('sendMessage', {str}, sigs)
end

function AndroidPlat:shareWeiXin(shareType, conType, content)
	local args = {}
	args['shareType'] = shareType
	args['conType'] = conType
	args['content'] = content

	local str = self:tabToJson(args)
	local sigs = '(Ljava/lang/String;)V'
   	callLua('shareWeiXin', {str}, sigs)
end

function AndroidPlat:shareWeiXinRich(shareType, conType, content, weburl, title, description)
	local args = {}
	local contentObj = {}
	contentObj['url'] = weburl       -- weburl链接
	contentObj['title'] = title         -- 分享标题
	contentObj['content'] = description --分享描述
	contentObj['imgPath'] = content

	args['shareType'] = shareType -- 朋友圈 or 好友
	args['conType'] = conType	 --图片 or Url or Text
	args['content'] = contentObj
	
	local str = self:tabToJson(args)
	local sigs = '(Ljava/lang/String;)V'
   	callLua('shareWeiXin', {str}, sigs)
end


function AndroidPlat:shareWeiXinCode( shareType, pokerId, inviteCode )
	local args = {}
	args["shareType"] = tostring(shareType)
	args["pokerId"] = tostring(pokerId)
	args["inviteCode"] = tostring(inviteCode)

	dump(args)
	local str = self:tabToJson(args)
	local sigs = '(Ljava/lang/String;)V'
   	callLua('shareWeiXinCode', {str}, sigs)
end

function AndroidPlat:intoCocos2dx()
   	local args = {}
    local sigs = "()V"
   	callLua('intoCocos2dx', args, sigs)
end

function AndroidPlat:new()
	local plat = require 'platform.Platform'
	setmetatable(AndroidPlat, plat)
	return AndroidPlat
end



function AndroidPlat.createAndroid()
	return AndroidPlat:new()
end

--获取gps城市名
function AndroidPlat.callGPSCity()
	local args = {}---------------------------
    local sigs = "(Ljava/lang/String;)V"------
   	callLua('callGPSCity', {args}, sigs)------ args 一定要加个{}，除非sigs = "(Ljava/lang/String;)V"传入参数为()
end





return AndroidPlat