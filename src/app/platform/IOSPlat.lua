local IOSPlat = {}
local _className = "IOSLua"
local _luaoc = require "cocos.cocos2d.luaoc"

local function callLua(funcName, args)
	local ok,ret  = _luaoc.callStaticMethod(_className, funcName, args)

    if not ok then
        assert(nil, 'error func '..funcName)
    else
        print("成功调用  "..funcName)
    end		
end


--获得渠道名
function IOSPlat:getChannelName()
	local channelNum = Single:paltform():luaCallNativeFunc({}, StatusCode.NATIVE_TYPE3)
	return channelNum
end

function IOSPlat:requestMobilePhoneNumber()
	local args = {}
   	callLua('requestMobilePhoneNumber', args)
end



function IOSPlat:uploadHead(imgName, callBack, funcName)
	local function upBack(result, path, msg)
		local function falseBack(  )
			DZSchedule.schedulerOnce(0.2, function()
				if string.len(msg) == 0 then
					callBack(result, path, {})
				else
					callBack(result, path, jsonStr.decode(msg, 1))
				end
			end)
		end
		UIUtil.falseShield(falseBack, nil)
	end

	local args = {}
	args[ 'scriptHandler' ] = upBack
	args['IMG_NAME'] = imgName
	args['TOKEN_KEY'] = self:getToken()
	args['UP_URL'] = self:getUpHeadUrl()
	args['FILE_MOD'] = ClubModel.getOpType()
	args['FILE_FLAG'] = ClubModel.getPhotoType()
	local ok, ret = _luaoc.callStaticMethod(_className, funcName, args)
	if not ok then
	    assert(nil, 'not ok '..funcName)
	end
end

--callBack(result, path):result(cancel, error, success)、path图片路径
function IOSPlat:openPhotos(imgName, callBack)
	self:uploadHead(imgName, callBack, "openPhotos")
end

--callBack(result, path):result(cancel, error, success)、path图片路径
function IOSPlat:openCamera(imgName, callBack)
	self:uploadHead(imgName, callBack, "openCamera")
end



--商店
--购买砖石
function IOSPlat:buyShopMasonry(tradeId)
	local args = {}
	args[ 'TRADE_ID' ] = tradeId

    local ok,ret = _luaoc.callStaticMethod(_className, "buyShopMasonry", args)
    if not ok then
	    assert(nil, 'buyShopMasonry not ok')
    end	
end

-- 微信支付
function IOSPlat:buyShopOfWeiXin( tab )
	local args = {}
	args = tab
	args["timestamp"] = tostring(args["timestamp"])
	local ok,ret = _luaoc.callStaticMethod(_className, "buyShopOfWeiXin", args)
	if not ok then
		assert(nil, "buyShopOfWeiXin not ok")
	end
end

-- 支付宝
function IOSPlat:buyShopOfAliPay( str )
	local args = {}
	args["aliPay"] = str
	local ok,ret = _luaoc.callStaticMethod(_className, "buyShopOfAliPay", args)
	if not ok then
		assert(nil, "buyShopOfAliPay not ok")
	end
end

-- Apple Pay
function IOSPlat:buyShopOfApplePay( tab )
	local args = {}
	args["purchase"] = tab.purchase
	args["diamonds"] = tostring(tab.diamonds)
	args["id"] = tostring(tab.id)
	args["money"] = tostring(tab.money)
	local ok,ret = _luaoc.callStaticMethod(_className, "buyShopOfApplePay", args)
	if not ok then
		assert(nil, "buyShopOfApplePay not ok")
	end
end

function IOSPlat:backHttpUrl( )
	local args = {}
	args['url'] = XMLHttp.getHttpUrl()
	args['token'] = XMLHttp.getGameToken()
	local ok,ret = _luaoc.callStaticMethod(_className, "backHttpUrl", args)
	if not ok then
		assert(nil, "backHttpUrl not ok")
	end
end


--进入游戏界面
function IOSPlat:intoGame()
	local ok,ret = _luaoc.callStaticMethod(_className, "intoGame")
    if ok then
    end
end

--离开游戏界面
function IOSPlat:leaveGame()
	local ok,ret = _luaoc.callStaticMethod(_className, "leaveGame")
    if ok then
    end
end



function IOSPlat:getDeviceId()
	local deviceid = ''
	local args = {}
	local ok, ret = _luaoc.callStaticMethod(_className, "getDeviceId")
	if not ok then
	    assert(nil, 'getDeviceId not ok')
	else
	    deviceid = ret
	end

	return deviceid
end

--获取wifi 4g3g2g
function IOSPlat:getWiFiFlag()
	local deviceid = ''
	local args = {}
	local ok, ret = _luaoc.callStaticMethod(_className, "getWiFiFlag")
	if not ok then
	    assert(nil, 'getWiFiFlag not ok')
	else
	    deviceid = ret
	end

	return deviceid
end

function IOSPlat:isLastVoice(ryid, playerRYId)
	local isLast = false
	local args = {}
	args["ryid"] = tostring(ryid)
	args["playerRYId"] = tostring(playerRYId)
	local ok, ret = _luaoc.callStaticMethod(_className, "getLastVoice", args)
	if not ok then
		assert(nil, "getLastVoice not ok")
	else
		isLast = ret
	end
	return isLast
end

--args表、callType调用类型
--callType：0-打开web浏览器、无返回值
--callType：1-请求是否开启GPS、返回值 true或false
--callType：3-友盟统计渠道号
function IOSPlat:luaCallNativeFunc(args, callType)
	if not args then
		args = {}
	end
	args['NATIVE_TYPE'] = callType
	local ok, ret = _luaoc.callStaticMethod(_className, "callNativeFunc", args)
	if not ok then
		-- assert(nil, "callNativeFunc not ok")
		print('stack callNativeFunc '..callType)
		ret = nil
	end
	return ret
end
function IOSPlat:funcNative()
	local path = cc.FileUtils:getInstance():getWritablePath()
	local args = {}
	args[ 'IMG_PATH' ] = path..'wowo.png'

    local ok,ret = _luaoc.callStaticMethod(_className, "funcNative", args)
    if not ok then
	    assert(nil, 'funcNative not ok')
    end
end

function IOSPlat:shakePhone()
    local ok,ret = _luaoc.callStaticMethod(_className, "shakePhone")
    if ok then
        -- print("The ret is:")
    end
end


function IOSPlat:sendMessage(name, phone, content)
	local args = {}
	args['name'] = name
	args['phone'] = phone
	args['content'] = content
   	callLua('sendMessage', args)
end


function IOSPlat:shareWeiXin(shareType, conType, content)
	local tab = {}
	tab['shareType'] = shareType
	tab['conType'] = conType
	tab['content'] = content
	
	local str = self:tabToJson(tab)
	local args = {}
	args['JSON'] = str
   	callLua('shareWeiXin', args)
end

-- MTT战绩分享
function IOSPlat:shareWeiXinRich(shareType, conType, content, weburl, title, description)
	local tab = {}
	tab['shareType'] = shareType --朋友圈 or 好友
	tab['conType'] = conType	 --图片 or Url or Text
	tab['weburl']  = weburl      --跳转的链接
	tab['title']   = title       --标题
	tab['description'] = description --描述
   	callLua('shareWeChatURL', tab)
end

function IOSPlat:shareWeiXinCode( shareType, pokerId, inviteCode )
	local args = {}
	args["shareType"] = shareType
	args["pokerId"] = pokerId
	args["inviteCode"] = inviteCode
	callLua('shareWeChatCode', args)
end

function IOSPlat:intoCocos2dx()
end

function IOSPlat:new()
	local base = require 'platform.Platform'
	setmetatable(IOSPlat, base)
	return IOSPlat
end


function IOSPlat.createIOS()
	return IOSPlat:new()
end
	
--获取gps城市名
function IOSPlat.callGPSCity()
	--print("22222123123123dsfs")
	local city = ''
	local args = {}
	local ok, ret = _luaoc.callStaticMethod(_className, "callGPSCity")
	if not ok then
	    print('callGPSCity not ok')
	else
	    city = ret
	    print("gps City = "..city)
	end
end

return IOSPlat