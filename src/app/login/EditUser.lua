local ViewBase = require("ui.ViewBase")
local EditUser = class("EditUser", ViewBase)
local LoginCtrol = require("login.LoginCtrol")



local avatarBtn = nil
local stencil 	= nil

function EditUser:buildLayer()

	local function menuBack(  )
		-- HttpUrl
		Single:paltform():backHttpUrl()
		-- 请求红点数据
		Notice.requestRedData( false )
		LoginCtrol.getAppConfig(function (  )
			LoginCtrol.getUserMsg(true)
		end)
	end
	-- addTopBar
	UIUtil.addTopBar({ title = "设置个人信息", menuFont = "跳过", menuFunc = menuBack, parent = self})
	
	--背景图片
	UIUtil.addImageView({image = "user/user_background.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	--头像
	local HeadImg = nil
	local function iconCallback(  )
	 	print('头像');
		local function funcback( iconName, iconPath )
			HeadImg = iconName
			self:buildIcon(iconPath)
		end
		ClubModel.buildPhoto( 0, funcback, {op_type = 1, photo_type = 2} )
	end
	-- 默认用户头像
	local icon = 'user/user_uploadAvatar.png'
	stencil, avatarBtn = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(display.cx, display.top-350), parent = self, nor = icon, sel = icon, listener = iconCallback, scale = 0.8, mask = ResLib.MASK_RING_WHITE})

	--上传头像Label
	local uploadAvatarLabel = cc.Label:create()
	uploadAvatarLabel:setString("上传头像")
	uploadAvatarLabel:setSystemFontSize(35)
	uploadAvatarLabel:setPosition(display.cx, display.cy+100)
	uploadAvatarLabel:setColor(cc.c3b(255, 255, 255))
	self:addChild(uploadAvatarLabel)

	--用户名输入框
	local usernameEditBox = ccui.EditBox:create(cc.size(599, 90),"user/user_commonBarWhite.png")
	usernameEditBox:setPosition(display.cx, display.cy)
	usernameEditBox:setPlaceholderFontSize(35)
    usernameEditBox:setPlaceHolder("请输入用户名")
    usernameEditBox:setMaxLength(LEN_NAME)
    usernameEditBox:setFontSize(35)
	usernameEditBox:setFontColor(cc.c3b(255, 255, 255))
	usernameEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self:addChild(usernameEditBox)

	local YHM = nil
	--[[local function editboxEventHandler(eventType,sender)
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			local str = sender:getText()
			local len = string.len(str)
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			YHM = str

			if (YHM ~= "") and (not cc.LuaHelp:IsGameName(YHM) or string.len(YHM) > LEN_NAME) then
				ViewCtrol.showTip({content = "名称为"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			end
		end
    end--]]
    local function editboxEventHandler(eventType,sender)
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			YHM = str
		end })
	end
    usernameEditBox:registerScriptEditBoxHandler(editboxEventHandler);

    local function EveltListener(  )
		--请求成功回调函数
		local function response(data)
			if data.code == 0 then
				-- HttpUrl
				Single:paltform():backHttpUrl()
				-- 请求红点数据
				Notice.requestRedData( false )
				LoginCtrol.getAppConfig(function (  )
					LoginCtrol.getUserMsg(true)
				end)
			end
		end
	   	local tabdata = {}
		tabdata['username'] = YHM
		tabdata['headimg'] 	= HeadImg or ''
		XMLHttp.requestHttp(PHP_FIRST_SET, tabdata, response, PHP_POST)
    end
	--完成按钮
    local confirmBtn = ccui.Button:create("user/user_commonBarWhite.png")
    confirmBtn:setPosition(display.cx, usernameEditBox:getPositionY() - 160)
    confirmBtn:setTitleText("完成")
	confirmBtn:setTitleFontSize(40)
	confirmBtn:setTitleColor(cc.c3b(255, 255, 255))
	self:addChild(confirmBtn);
    confirmBtn:addTouchEventListener(function(sender,event)
    	if event == 2 then
    		if YHM == nil or YHM == "" then
    			ViewCtrol.showTip({content = "请输入用户名！"})
    			return
    		else
    			if not cc.LuaHelp:IsGameName(YHM) or string.len(YHM) > LEN_NAME then
					ViewCtrol.showTip({content = "昵称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
					return
				end
    		end
	    	EveltListener()
    	end
    end)
    
end

function EditUser:buildIcon( iconPath )
	avatarBtn:loadTextureNormal(iconPath)
	avatarBtn:loadTexturePressed(iconPath)
	avatarBtn:loadTextureDisabled(iconPath)

	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	avatarBtn:setScale(scaleX, scaleY)
end

function EditUser:createLayer(  )
	self:setSwallowTouches()
	avatarBtn = nil
	stencil 	= nil
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:buildLayer()
end

return EditUser