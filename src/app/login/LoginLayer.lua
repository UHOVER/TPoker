local ViewBase = require("ui.ViewBase")
local LoginLayer = class("LoginLayer", ViewBase)
local LoginCtrol = require("login.LoginCtrol")

local YHstr = ""
local MMstr = ""
local areaNum = nil
local areaLabel = nil
local loginBtn = nil;
local imgs_array = {};
local g_callBcakType = 1--回调方法，显示对应的界面；1-登入游戏，2-注册，3-忘记密码

local _nodeJs = ''
local _xmlhttp = ''

local xmls = {
	'http://101.201.48.107:9989/',
	'http://101.201.48.107:9901/', 'http://101.201.48.107:9987/',
	'http://118.190.88.93:80/' , 'http://api.allbetspace.com:9999/',
	'http://114.215.68.59:80/','http://api.allbetspace.com/',
	'http://101.201.48.107:9900/', "http://192.168.199.109:8089/"
}
local nodes = {
	"ws://101.201.48.107:8080", "ws://101.201.48.107:8060", 
	"ws://192.168.199.109:8080", "ws://114.215.68.59:8080",
	"ws://api.allbetspace.com:8080", "ws://118.190.88.93:8080/"
}
local js = {
	'http://101.201.48.107:8999/', 'http://139.129.213.1:8999/'
}

local g_isCanUpdate = false

local function serverTest(parent)
	if not DZ_DEBUG then return end

	local tnode = cc.Node:create()
	parent:addChild(tnode, 10)
	local function updateBtn(tag, sender)
		if(g_isCanUpdate == false) then
			g_isCanUpdate = true
			sender:setString("更新：开")
		else
			g_isCanUpdate = false
			sender:setString("更新：关")
		end
	end

	g_isCanUpdate = false
	local updateBtn = UIUtil.addMenuFont(tab, "更新：关", cc.p(50, display.height/2+200), updateBtn, tnode)
	 

	local items = {}
	local nowLinkUrl = XMLHttp.getHttpUrl()

	local function selectBtn(tag, sender)
		for i=1,#items do
			items[i]:setColor(cc.c3b(255,255,255))
		end

		print('修改了 php 链接地址：'..xmls[ tag ])
		sender:setColor(cc.c3b(255,0,0))
		XMLHttp.setTestHttpUrl(xmls[ tag ])
	end

	local upx = -70
	for i=1,#xmls do
		local item = UIUtil.addMenuFont(tab, xmls[i], cc.p(display.cx, display.height+upx), selectBtn, tnode)
	    item:setAnchorPoint(0.5,1)
	    item:setTag(i)

	    if nowLinkUrl == xmls[i] then
	    	item:setColor(cc.c3b(255,0,0))
	    end

	    table.insert(items, item)

	    upx = upx - 60
	end


	local nodeurl = Network.getTestWSAddress()
	local nodeItems = {}

	local function nodeBtn(tag, sender)
		for i=1,#nodeItems do
			nodeItems[i]:setColor(cc.c3b(255,255,255))
		end
		sender:setColor(cc.c3b(255,0,0))
		print('修改了 websocket 地址：'..nodes[ tag ])
		Network.setTestWSAddress(nodes[ tag ])
	end

	local nodey = 0
	
	for i=1,#nodes do
		local item = UIUtil.addMenuFont(tab, nodes[i], cc.p(display.cx, nodey), nodeBtn, parent)
	    item:setAnchorPoint(0.5,0)
	    item:setTag(i)

	    if nodeurl == nodes[i] then
	    	item:setColor(cc.c3b(255,0,0))
	    end

	    table.insert(nodeItems, item)

	    nodey = nodey + 40
	end

	print('当前链接服务器地址  php：'..nowLinkUrl)
	print('当前链接服务器地址  websocket：'..nodeurl)
end

--更新结束后回调，根据点击按钮回调各自的方法
function LoginLayer:loginGame()
	--根据不同情况点击按钮
	--回调不同内容
	--1-登入游戏，2-注册，3-忘记密码
	if(g_callBcakType == 1) then
		if YHstr == "" then
			ViewCtrol.showTip({content = "请输入手机号码！"})
			return
		end
		if MMstr == "" then
			ViewCtrol.showTip({content = "请输入密码！"})
			return
		end
		-- if not cc.LuaHelp:IsPhoneNumber(YHstr) then
		-- if not StringUtils.isPhoneNumber(YHstr) then
		-- 	ViewCtrol.showTip({content = "不是一个标准的手机号码！"})
		-- 	return
		-- end
		if not cc.LuaHelp:IsPassWord(MMstr) then
			ViewCtrol.showTip({content = "密码由6-12位大小写字母、数字组成！"})
			return
		end
		
		self:funback( YHstr, MMstr )
	elseif(g_callBcakType == 2) then
		print("注册");
		LoginCtrol.setIsRegist(true)
		local Register = require("login.RegistScene")
        Register:startScene("regist")
	elseif(g_callBcakType == 3) then
		print("忘记密码")
		LoginCtrol.setIsRegist(false)
		local Register = require("login.RegistScene")
        Register:startScene("forget")
	end
end

function LoginLayer:buildLayer()
	-- Storage.setStringForKey("kc_litV", "V10_201704280954")
	-- Storage.setStringForKey("kc_vpV", "V10")

	VISITOR_LOGIN = false
		
	--背景图片
	local backgroundPic = cc.Sprite:create("user/login_bg.png")
	backgroundPic:setPosition(cc.p(display.cx, display.cy))
	self:addChild(backgroundPic)


	serverTest(self)

	UIUtil.addPosSprite("user/user_registerLogo.png", cc.p(display.cx, display.top - 166), backgroundPic, cc.p(0.5, 1))
	UIUtil.addPosSprite("user/user_registerPoker.png", cc.p(display.cx, display.top - 166-147-40), backgroundPic, cc.p(0.5, 1))

	local color_grey = cc.c3b(145, 145, 145)

	--用户图标
	local area = Storage.getStringForKey(Storage.INTERNAT_KEY)
	areaNum = '86'
	if string.len(area) ~= 0 then
		areaNum = area
	end
	
	local function addAreaNum(  )
		local function callBack( code )
			areaNum = code
			areaLabel:setString("+"..code)
		end
		local currScene = cc.Director:getInstance():getRunningScene()
		local area = require('login.AreaNum')
		local layer = area:create()
		layer:setName("AreaNum")
		currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))
		layer:createLayer(callBack)
	end
	local bg = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(100, 60), ah = cc.p(0,0), pos = cc.p(104, display.height*0.5), touch = true, swalTouch = false, listener = addAreaNum, parent = self})
	areaLabel =  UIUtil.addLabelArial("+"..areaNum, 30, cc.p(5, 20), cc.p(0, 0.5), bg)
	UIUtil.addPosSprite("user/icon_sanjiao.png", cc.p(80, 20), bg, cc.p(0, 0.5))

	UIUtil.addPosSprite("user/login_icon_user.png", cc.p(104, display.height*0.5), self, cc.p(0, 0))
	UIUtil.addPosSprite("user/user_loginOrLine1.png", cc.p(display.cx,  display.height*0.5-15), self, cc.p(0.5, 0))

	--用户文本框
	local userPhone = ccui.EditBox:create(cc.size(500, 60),"common/com_opacity0.png")
	userPhone:setAnchorPoint(cc.p(0,0))
	userPhone:setPosition(cc.p(204, display.height * 0.5 - 10))
    userPhone:setFontSize(30)
   	userPhone:setFontColor(cc.c3b(255, 255, 255))
	userPhone:setPlaceHolder("请输入手机号")
	userPhone:setPlaceholderFontColor(cc.c3b(255, 255, 255))
	userPhone:setPlaceholderFontSize(30)
	userPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)

	local function editboxEventHandler(eventType,sender)
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			YHstr = str
			--判断如果用户名和密码都不为空的登录按钮才可以点击，如果用户名或者密码有一个为空，则登录按钮不可以点击
			if YHstr ~= "" and MMstr ~= "" then
				loginBtn:setEnabled(true)
			elseif YHstr == "" or MMstr == "" then
				loginBtn:setEnabled(false)
			end
		end
    end
    userPhone:registerScriptEditBoxHandler(editboxEventHandler);
	self:addChild(userPhone);
    
    --密码图标
	-- local user_icon =  UIUtil.addLabelArial("密码", 30, cc.p(104, display.height*0.4), cc.p(0, 0), self)
	UIUtil.addPosSprite("user/login_icon_pwd.png", cc.p(104, display.height*0.4), self, cc.p(0, 0))
	UIUtil.addPosSprite("user/user_loginOrLine2.png", cc.p(display.cx,  display.height*0.4-15), self, cc.p(0.5, 0))
	
	--密码输入框
	local userPwd = ccui.EditBox:create(cc.size(500, 60),"common/com_opacity0.png");
	userPwd:setAnchorPoint(cc.p(0, 0))
	userPwd:setPosition(204, display.height*0.4 - 10);
    userPwd:setFontSize(30);
	userPwd:setFontColor(cc.c3b(255, 255, 255));
	userPwd:setPlaceHolder("请输入密码")
	userPwd:setPlaceholderFontColor(cc.c3b(255, 255, 255))
	userPwd:setPlaceholderFontSize(30)
	userPwd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

	local function editboxEventHandler(eventType,sender)
		if eventType == "began" then
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			MMstr = str
			--判断如果用户名和密码都不为空的登录按钮才可以点击，如果用户名或者密码有一个为空，则登录按钮不可以点击
			if YHstr ~= "" and MMstr ~= "" then
				loginBtn:setEnabled(true)
			elseif YHstr == "" or MMstr == "" then
				loginBtn:setEnabled(false)
			end
		end	 
    end
    userPwd:registerScriptEditBoxHandler(editboxEventHandler);
	userPwd:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	self:addChild(userPwd);
	
	--  YDWX_DZ_ZHANGMENG_BUG _20160629 _001
	local function loginFunc(  )
		g_callBcakType = 1

		--不再debug状态走正常热更新
		if not DZ_DEBUG then 
			--请求热更新
			--在热更新内跳转游戏
			if(self:getChildByTag(666) ~= nil) then
				self:loginGame()
			else
				local downLoadNode = require('download.DownLoadUI'):create()
				downLoadNode:setParentNode(self)
				downLoadNode:setTag(666)
				self:addChild(downLoadNode)

			end
		--debug状态添加按钮关闭热更新
		else
			if(g_isCanUpdate == true) then
				--请求热更新
				--在热更新内跳转游戏
				if(self:getChildByTag(666) ~= nil) then
					self:loginGame()
				else
					local downLoadNode = require('download.DownLoadUI'):create()
					downLoadNode:setParentNode(self)
					downLoadNode:setTag(666)
					self:addChild(downLoadNode)
				end
			else
				self:loginGame()
			end
		end
	end
	--登陆按钮 初始为不可点击状态
	local label = cc.Label:createWithSystemFont("", "Arial", 32)
	local _img1 = "user/login_btn_nor.png"
	local _img2 = "user/login_btn_dis.png"
	loginBtn = UIUtil.controlBtn(_img1, _img2, _img2, label, cc.p(display.cx, display.height*0.3), cc.size(548,97), loginFunc, self)
	loginBtn:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_NORMAL)
	loginBtn:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_HIGH_LIGHTED)
	loginBtn:setTitleColorForState(cc.c3b(82, 146, 244), cc.CONTROL_STATE_DISABLED)
	if YHstr == "" and MMstr == "" then
		loginBtn:setEnabled(false)
	end

	--注册按钮
    --[[local registerBtn = ccui.Button:create("user/login_btn_regist.png")
    registerBtn:setAnchorPoint(cc.p(0.5, 0.5))
	registerBtn:setPosition(display.cx-185, display.height*0.2+40)
	registerBtn:setTitleFontSize(40)
	registerBtn:setTitleColor(cc.c3b(255, 255, 255))
	registerBtn:addTouchEventListener(function(sender,event)
		if event == 2 then
			g_callBcakType = 2

			--self:loginGame()
			--不再debug状态走正常热更新
			if not DZ_DEBUG then 
				--请求热更新
				--在热更新内跳转游戏
				if(self:getChildByTag(666) ~= nil) then

					print("注册");
					LoginCtrol.setIsRegist(true)
					local Register = require("login.RegistScene")
			        Register:startScene("regist")

				else

					local downLoadNode = require('download.DownLoadUI'):create()
					downLoadNode:setParentNode(self)
					downLoadNode:setTag(666)
					self:addChild(downLoadNode)

				end
			--debug状态添加按钮关闭热更新
			else
				if(g_isCanUpdate == true) then
					--请求热更新
					--在热更新内
					if(self:getChildByTag(666) ~= nil) then

						print("注册");
						LoginCtrol.setIsRegist(true)
						local Register = require("login.RegistScene")
				        Register:startScene("regist")

					else

						local downLoadNode = require('download.DownLoadUI'):create()
						downLoadNode:setParentNode(self)
						downLoadNode:setTag(666)
						self:addChild(downLoadNode)

					end
				else
					print("注册");
					LoginCtrol.setIsRegist(true)
					local Register = require("login.RegistScene")
			        Register:startScene("regist")
				end
			end
		end
	end)
	self:addChild(registerBtn);

    --忘记密码按钮  
	local forgetPwdBtn= ccui.Button:create("user/login_btn_forget.png"):addTo(self);
	forgetPwdBtn:setAnchorPoint(cc.p(0.5, 0.5))
	forgetPwdBtn:setTitleColor(cc.c3b(255, 255, 255));
	forgetPwdBtn:setPosition(display.cx+185, display.height*0.2+40);
	forgetPwdBtn:addTouchEventListener(function(sender,event)
		if event == 2 then
			g_callBcakType = 3

			--不再debug状态走正常热更新
			if not DZ_DEBUG then 
				--请求热更新
				--在热更新内跳转游戏
				if(self:getChildByTag(666) ~= nil) then

					print("忘记密码")
					LoginCtrol.setIsRegist(false)
					local Register = require("login.RegistScene")
			        Register:startScene("forget")

				else

					local downLoadNode = require('download.DownLoadUI'):create()
					downLoadNode:setParentNode(self)
					downLoadNode:setTag(666)
					self:addChild(downLoadNode)

				end
			--debug状态添加按钮关闭热更新
			else
				if(g_isCanUpdate == true) then
					--请求热更新
					--在热更新内跳转游戏
					if(self:getChildByTag(666) ~= nil) then

						print("忘记密码")
						LoginCtrol.setIsRegist(false)
						local Register = require("login.RegistScene")
				        Register:startScene("forget")

					else

						local downLoadNode = require('download.DownLoadUI'):create()
						downLoadNode:setParentNode(self)
						downLoadNode:setTag(666)
						self:addChild(downLoadNode)

					end
				else
					print("忘记密码")
					LoginCtrol.setIsRegist(false)
					local Register = require("login.RegistScene")
			        Register:startScene("forget")
				end
			end
		end
	end)--]]

	-- 游客登录
	local function visitorLogin(  )
		local visitor = Storage.getStringForKey(Storage.VISITOR_KEY)
		
		local function response( data )
			Storage.setStringForKey(Storage.VISITOR_KEY, data.data)
			YHstr = data.data
			MMstr = "123456"
			self:funback(nil, nil, true)
		end

		if string.len(visitor) == 0 then
			XMLHttp.requestHttp("touristlogin", {}, response, PHP_POST)
		else
			print("visitor: "..visitor)
			YHstr = visitor
			MMstr = "123456"
			self:funback(nil, nil, true)
		end
	end
	local visitBtn = UIUtil.addImageBtn({norImg = "user/visitor_login_btn.png", selImg = "user/visitor_login_btn_height.png", disImg = "user/visitor_login_btn.png", ah = cc.p(0.5, 0), pos = cc.p(display.cx, 170), touch = true, listener = visitorLogin, parent = self})
	local _platform = cc.Application:getInstance():getTargetPlatform()
	if (cc.PLATFORM_OS_IPHONE == _platform) or (cc.PLATFORM_OS_IPAD == _platform) or (cc.PLATFORM_OS_MAC == _platform)  then
		visitBtn:setVisible(true)
	elseif _platform == cc.PLATFORM_OS_ANDROID then
		visitBtn:setVisible(false)
	else
		assert(nil, 'platform.getInstance')
	end

	-- 版本
	local versions =  UIUtil.addLabelArial(DZ_VERSION .. "版本", 22, cc.p(display.cx, 45), cc.p(0.5, 0.5), self):setColor(cc.c3b(67, 57, 40))
	--提示健康游戏内容
	UIUtil.addLabelArial("抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。", 22, cc.p(display.cx, 125), cc.p(0.5, 0.5), self):setColor(cc.c3b(66, 66, 66))
	UIUtil.addLabelArial("适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。", 22, cc.p(display.cx, 95), cc.p(0.5, 0.5), self):setColor(cc.c3b(66, 66, 66))

	-- 已经登录过记住的账户、密码
	local tel = Storage.getStringForKey(Storage.ACCOUNT_KEY)
	local pwd = Storage.getStringForKey(Storage.PWD_KEY)
	if string.len(tel) ~= 0 and string.len(pwd) ~= 0 then
		-- 已注册过账号屏蔽游客登录
		userPhone:setText(tel)
		userPwd:setText(pwd)
		MMstr = pwd
		YHstr = tel

		visitBtn:setVisible(false)
		loginBtn:setEnabled(true)
		
		-- 自动登录
		if DZ_MASTER_VERSION and AUTO_LOGIN then
			DZSchedule.schedulerOnce(0.05, function()
				self:autoLogin()
			end)
		end

	end



	local function onEvent(event)
        if event == "enter" then

        elseif event == "enterTransitionFinish" then
        	--[[
        	local function xmlResponse(data)
				if data.code == 0 then
					--获取个人信息请求

		            --print("sajkdhkajsd")
					--dump(data)

					--如果大版本不等，弹框
					if(data.data['big_versions'] ~= UPDATE_VERSION_IN) then
					    --清除旧版文件
						local m_pathToSave = cc.FileUtils:getInstance():getWritablePath()
						local m_dirName = "download/"
						local path = m_pathToSave..m_dirName
					    print("os.rmdir:"..path)
						print("before dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))

						local tPlatform = cc.Application:getInstance():getTargetPlatform()
						
						if (cc.PLATFORM_OS_IPHONE == tPlatform) or (cc.PLATFORM_OS_IPAD == tPlatform) or (cc.PLATFORM_OS_MAC == tPlatform) then
							cc.FileUtils:getInstance():removeDirectory(path)
						elseif tPlatform == cc.PLATFORM_OS_ANDROID then
							local cmdStr = "rm -rf "..path
							os.execute(cmdStr)
						end

						--清除内存
						for k,v in pairs(package.loaded) do
							print("value===="..k)
							if(k ~= 'math' 
								and k ~= 'string' 
								and k ~= 'table' 
								and k ~= '_G'
								and k ~= 'libs.jsonStr') then
								package.loaded[k] = nil
							end
							--require(k)
						end

						--重新加载
						require "main"
						cc.Director:getInstance():getTextureCache():removeAllTextures()
						require("app.AppBase"):create():run()
					end
				end
			end

			local tabData = {}
			tabData['big_versions'] = UPDATE_VERSION
			tabData['small_versions'] = DZ_VERSION

			XMLHttp.requestHttp(PHP_GET_MSG, tabData, xmlResponse, PHP_POST)
		]]

		    --判断大版本是否一致
			--如果版本不一致，清楚文件，缓存，重新加载界面
			print("UPDATE_VERSION="..UPDATE_VERSION)
			print("UPDATE_VERSION_IN="..UPDATE_VERSION_IN)
			if(UPDATE_VERSION ~= UPDATE_VERSION_IN) then

				--清除内存
				for k,v in pairs(package.loaded) do
					print("value===="..k)
					if(k ~= 'math' 
						and k ~= 'string' 
						and k ~= 'table' 
						and k ~= '_G'
						and k ~= 'libs.jsonStr') then
						package.loaded[k] = nil
					end
					--require(k)
				end


				--清除旧版文件
				local m_pathToSave = cc.FileUtils:getInstance():getWritablePath()
				local m_dirName = "download/"
				local path = m_pathToSave..m_dirName
			    print("os.rmdir:"..path)
				print("before dddddddir="..tostring(CCFileUtils:sharedFileUtils():isFileExist(path)))

				local tPlatform = cc.Application:getInstance():getTargetPlatform()
				
				if (cc.PLATFORM_OS_IPHONE == tPlatform) or (cc.PLATFORM_OS_IPAD == tPlatform) or (cc.PLATFORM_OS_MAC == tPlatform) then
					cc.FileUtils:getInstance():removeDirectory(path)
				elseif tPlatform == cc.PLATFORM_OS_ANDROID then
					local cmdStr = "rm -rf "..path
					os.execute(cmdStr)
				end

				cc.FileUtils:getInstance():purgeCachedEntries() 
				--重新加载
				require "main"
				--require "main"
				--cc.LuaHelp:jsonStr("")
			end

        elseif event == "exit" then

        end
    end
    
    self:registerScriptHandler(onEvent)

    self:onUpdate(handler(self, self.update))

end

function LoginLayer:update(_dt)
	--print("ddd---")
	--判断大版本是否一致
	if(UPDATE_VERSION ~= UPDATE_VERSION_IN) then
		--[[
		print("eeeeokokokokok")
		cc.Director:getInstance():getTextureCache():removeAllTextures()
		require("app.AppBase"):create():run()
		]]
	end
end

--登录按钮回调函数
function LoginLayer:funback(tel, pwd, isVisit)

	--登录成功回调函数
	local function response(data)
		if data.code == 0 then

			-- 非游客保存账号、密码到本地
			if not isVisit then
				Storage.setStringForKey(Storage.ACCOUNT_KEY, YHstr)
				Storage.setStringForKey(Storage.PWD_KEY, MMstr)
				Storage.setStringForKey(Storage.INTERNAT_KEY, areaNum)
			end

			--是游客、不是游客
			if isVisit then
				VISITOR_LOGIN = true
			else
				VISITOR_LOGIN = false
			end

			-- HttpUrl
			Single:paltform():backHttpUrl()

			--融云
			DZChat.rongyuInit(data.data['rongyun_token'])
			-- 请求红点数据
			-- Notice.requestRedData( false )
			if tonumber(data.data['modified']) == 0 then  --修改初始密码
				local setPwd = require('login.SetPwd')
				local layer = setPwd:create()
				self:addChild(layer, 100)
				layer:createLayer()
			else
				-- LoginCtrol.getAppConfig(function (  )
					LoginCtrol.getUserMsg(false)
				-- end)
			end
		end
	end
	--登录请求
	local tabData = {}
	tabData['tel'] = '86-'..YHstr
	tabData['pwd'] = MMstr
	-- tabData['internatCode'] = areaNum
	-- tabData["versions_no"] = DZ_VERSION
	-- tabData["sys"] = LoginCtrol.getPlamfNumber()
	-- tabData["channel_no"] = Single:paltform():getChannelName()

	-- dump(tabData)
	XMLHttp.requestHttp(PHP_LOGIN, tabData, response, PHP_POST)
end

-- 自动登录
function LoginLayer:autoLogin(  )
	g_callBcakType = 1
	--不再debug状态走正常热更新
	if not DZ_DEBUG then 
		--请求热更新
		--在热更新内跳转游戏
		if(self:getChildByTag(666) ~= nil) then
			self:loginGame()
		else
			local downLoadNode = require('download.DownLoadUI'):create()
			downLoadNode:setParentNode(self)
			downLoadNode:setTag(666)
			self:addChild(downLoadNode)
		end
		--debug状态添加按钮关闭热更新
	else
		if(g_isCanUpdate == true) then
			--请求热更新
			--在热更新内跳转游戏
			if(self:getChildByTag(666) ~= nil) then
						self:loginGame()
			else
				local downLoadNode = require('download.DownLoadUI'):create()
				downLoadNode:setParentNode(self)
				downLoadNode:setTag(666)
				self:addChild(downLoadNode)
			end
		else
			self:loginGame()
		end
	end
end

function LoginLayer:createLayer(  )
	g_callBcakType = 1
	YHstr = ""
	MMstr = ""
	areaNum = nil
	areaLabel = nil
	loginBtn = nil;
	imgs_array = {}
	self:buildLayer()
end

return LoginLayer