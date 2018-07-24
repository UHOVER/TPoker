local MineCtrol = require('mine.MineCtrol')
cc.exports.MainCtrol 	= require ('main.MainCtrol')
cc.exports.MainHelp 	= require ('main.MainHelp')
cc.exports.MainModel 	= require ('model.MainModel')

local LoginCtrol = {}

local phoneNumber = nil
local areaNum = nil
local is_regist = true

function LoginCtrol.getUserMsg( isRegist )
	
	-- NewMsgMgr.checkNewMsg(NewMsgMgr.FIRST_LOGIN)

	local function xmlResponse(data)
		if data.code == 0 then
			--获取个人信息请求

            --print("sajkdhkajsd")
			--dump(data)
	
			if(data.data == nil) then
				local logs = 'LoginCtrol.getUserMsg  '
				Single:appLogsJson(logs, data)
				return
			end
			

			--如果大版本不等，弹框
		 --    if(data.data['big_versions'] ~= UPDATE_VERSION) then
			--     -- local dlg = require("main/HelpDlg"):create(6)
			--     -- cc.Director:getInstance():getRunningScene():addChild(dlg)
			-- --如果小版本不等，弹框
			-- elseif(data.data['small_versions'] ~= DZ_VERSION) then
			-- 	-- local dlg = require("main/HelpDlg"):create(7)
			--  --    cc.Director:getInstance():getRunningScene():addChild(dlg)
			-- --其他情况是正常登入
			-- else
				local mdata = data.data
				local spm = Single:playerModel()
				local headurl = mdata['headimg']
				
				if isRegist then
					--融云
					DZChat.rongyuInit(mdata['rongyun_token'])
				end

				--设置用户数据
				spm:setPName(mdata['username'])
				spm:setId(mdata['id'])
				spm:setRYId(mdata['rongyun_id'])
				spm:setPBetNum(mdata['scores'])
				spm:setPSex(mdata['sex'])
				spm:setPHeadUrl(headurl)

				spm:setPNumber(mdata['u_no'])

				MineCtrol.setMineInfo(data.data)

				Network.connect()
				XMLHttp.registerSocket()
				DZConfig.setInLogin(false)

				-- Notice.requestBuildCard( false, function (  )
					local MineScene = require('mine.MineScene')
					MineScene.startScene()
				-- end ,0 )

				-- DZChat.getUnlookNum()

				--storage
				Storage.setStorageImgHeadUrl(DZConfig.getImgHeadUrl())
				Storage.setStorageUserName(mdata['username'])
				Storage.setStorageUserId(mdata['id'])
				Storage.setStorageUserHeadUrl(headurl)
				--关闭
				Storage.setIsCloseVoice(true)

				Single:paltform():intoCocos2dx()
				
				local CheckNet = require 'network.CheckNet'
				CheckNet.scheduleNet()

			-- end
		end
	end

	-- local tabData = {}
	-- tabData['big_versions'] = UPDATE_VERSION
	-- tabData['small_versions'] = DZ_VERSION
	local tabData = ''
	XMLHttp.requestHttp(PHP_GET_MSG, tabData, xmlResponse, PHP_GET)
end

function LoginCtrol.getAppConfig( callback )
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			local config = data.config

			DZ_SMS = config.Sms_invite_msg
			ABOUT_US_URL = config.About_us_url
			LICENSE_URL = config.License_url
			IMG_PREFIX_URL = config.Image_prefix_url
			SHARE_URL = config.Weixin_url or ""
			callback()
		end
		
	end
	XMLHttp.requestHttp("app_config", {}, response, PHP_POST, true)
end

function LoginCtrol.changeUser()
	Network.switchUser()
	DZConfig.setInLogin(true)
end

-- 设置电话号码
function LoginCtrol.setPhoneNumber( tel )
	phoneNumber = tel
end

-- 获取电话号码
function LoginCtrol.getPhoneNumber(  )
	return phoneNumber
end

-- 设置地区编号
function LoginCtrol.setAreaNumber( area )
	areaNum = area
end

-- 获取地区编号
function LoginCtrol.getAreaNumber(  )
	return areaNum
end

function LoginCtrol.setIsRegist( regist )
	is_regist = regist
end

function LoginCtrol.getIsRegist(  )
	return is_regist
end

--根据不同平台，返回平台号
function LoginCtrol.getPlamfNumber()
	local tPlatform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == tPlatform) or (cc.PLATFORM_OS_IPAD == tPlatform) or (cc.PLATFORM_OS_MAC == tPlatform) then
		return 1
	elseif tPlatform == cc.PLATFORM_OS_ANDROID then
		return 2
	else
		assert(nil, 'platform.getInstance')
	end
end

return LoginCtrol
