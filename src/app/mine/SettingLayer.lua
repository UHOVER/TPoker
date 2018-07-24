local ViewBase = require("ui.ViewBase")
local SettingLayer = class("SettingLayer", ViewBase)

local _setting = nil

local function Callback( tag, sender )
	_setting:removeTransitAction()
end

local function GameSound( isOn )
	-- Storage.setStringForKey("gameSound", isOn)
	print("________________isOn " .. isOn)
	if isOn == 1 then
		-- DZPlaySound.setGameQuiet(false)
		Storage.setIsCloseGameSound(false)
		DZPlaySound.isQuiet = false
	else
		-- DZPlaySound.setGameQuiet(true)
		DZPlaySound.isQuiet = true
		Storage.setIsCloseGameSound(true)
	end
end

local function MsgSound( isOn )
	Storage.setStringForKey("msgSound", isOn)
end

function SettingLayer:buildLayer(  )

	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "设置", parent = self})

	local layer = UIUtil.addImageView({image=ResLib.IMG_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos = cc.p(0, 0), ah = cc.p(0,0), parent=self})

	local sizeH = {110, 110, 110, 110, 110, 110, 110}
	-- local img = {ResLib.IMG_CELL_BG3, ResLib.IMG_CELL_BG2, ResLib.IMG_CELL_BG3, ResLib.IMG_CELL_BG2, ResLib.IMG_CELL_BG3, ResLib.IMG_CELL_BG2, ResLib.IMG_CELL_BG1}
	local infoBg = {}
	local infoNode = {}
	local infoBgH = 0
	local infoW = 20 -- 左边距
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		infoNode[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (display.height-130) - infoBgH), parent=layer})

		local infoH = 110
		infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_GREY_BG, touch=true, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), parent=infoNode[i]})
		infoBg[i]:setSwallowTouches(true)
	end

	local label = {"切换账号", "修改密码", "游戏音效", "消息声音", "违法举报", "关于我们", "版本号  "}
	local btnBg = {}
	local switch = {}
	-- local posY = display.height - 200
	local btnBg_h = 110
	local togMenu_on = {}
	local togMenu_off = {}
	for i=1,3 do
		togMenu_on[i] = ResLib.COM_SWITCH4
		togMenu_off[i] = ResLib.COM_SWITCH3
	end

	local function valueChanged(tag, pSender)
       	local pControl = pSender
       	if tag == 3 then
			if pControl:getSelectedIndex() == 0 then
				print("ON")
				GameSound( 1 )
			else
				print("OFF")
				GameSound( 0 )
			end
       	elseif tag == 4 then
       		if pControl:getSelectedIndex() == 0 then
				print("ON")
				MsgSound(1)
			else
				print("OFF")
				MsgSound(0)
			end
       	end
    end
	local function callfunc( sender )
		print(sender:getTag())
		local tag = sender:getTag()
		if tag == 1 then
			self:exitUser()
		elseif tag == 2 then
			local modiPwd = require("mine.ModiPwd"):create()
			self:addChild(modiPwd)
		elseif tag == 5 then
			local report = require("mine.report").new()
			self:addChild(report)
		elseif tag == 6 then
			local about = require("mine.about").new()
			self:addChild(about)
		end
	end
	for i=1, #label do
		if i == 3 or i == 4 then
			btnBg[i] = UIUtil.addImageView({image=ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, btnBg_h), pos = cc.p(display.cx, sizeH[i]/2), ah = cc.p(0.5,0.5), parent=infoBg[i]})
			switch[i] = UIUtil.addTogMenu({imgTab1 = togMenu_on, imgTab2 = togMenu_off,pos = cc.p(display.width-20, btnBg[i]:getContentSize().height/2), listener = valueChanged, parent = btnBg[i]})
			switch[i]:setAnchorPoint(cc.p(1, 0.5))
			switch[i]:setTag(i)
   		else
			btnBg[i] = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, pos = cc.p(display.cx, sizeH[i]/2), touch = true, scale9 = true, size = cc.size(display.width, btnBg_h), listener = callfunc, parent = infoBg[i]})
        	btnBg[i]:setTag(i)
        	if i ~= #label then
        		UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, 50), btnBg[i], cc.p(1, 0.5))
        	end
		end

        local labelT = UIUtil.addLabelArial(label[i], 34, cc.p(20, btnBg[i]:getContentSize().height/2), cc.p(0, 0.5), btnBg[i])
        
        if i == #label then
        	UIUtil.addLabelArial(DZ_VERSION, 30, cc.p(display.width-20, btnBg[i]:getContentSize().height/2), cc.p(1, 0.5), btnBg[i]):setColor(cc.c3b(169, 170, 171))
        end
	end
	-- 游戏音效
	-- local gameS = nil
	-- gameS = Storage.getStringForKey("gameSound") or 1
	-- -- print(">>>>>>>>>>>>> " .. gameS)
	-- if tonumber(gameS) == 0 then
	-- 	switch[2]:setSelectedIndex(1)
	-- else
	-- 	switch[2]:setSelectedIndex(0)
	-- end

	local isClose = Storage.isCloseGameSound()
	if isClose then
		switch[3]:setSelectedIndex(1)
	else
		switch[3]:setSelectedIndex(0)
	end

	-- 消息音效
	local msgS = nil
	msgS = Storage.getStringForKey("msgSound") or 1
	-- print(">>>>>>>>>>>>> " .. msgS)
	if tonumber(msgS) == 0 then
		switch[4]:setSelectedIndex(1)
	else
		switch[4]:setSelectedIndex(0)
	end


end

function SettingLayer:exitUser(  )

	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10,100))
	self:addChild(layer)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		print('触摸屏蔽')
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSp = UIUtil.addImageView({image = ResLib.COM_OPACITY0, scale = true, size = cc.size(display.width, 301), ah = cc.p(0,1), pos = cc.p(0, 0), parent = layer})

	local color = cc.c3b(0, 119, 255)
	local bg = UIUtil.addImageView({image=ResLib.BTN_PHOTO_TOP, touch=false, scale=true, size=cc.size(700, 80), pos = cc.p(display.cx, 261), ah = cc.p(0.5,0.5), parent=bgSp})
	local label1 = cc.Label:createWithSystemFont("退出后不会删除数据，下次登录依然可以使用本账号", "Marker Felt", 20):addTo(bg)
	label1:setPosition(cc.p(350, 40))
	label1:setColor(color)

	local function sureFunc( ... )
		local LoginCtrol = require("login.LoginCtrol")
		LoginCtrol.changeUser()
		DZChat.breakRYConnect()
		Storage.deleteValueForKey(Storage.ACCOUNT_KEY)
		Storage.deleteValueForKey(Storage.PWD_KEY)
		Storage.deleteValueForKey(Storage.INTERNAT_KEY)
		
		NoticeCtrol.removeNoticeNode()

		local loginScene = require("login.LoginScene")
		loginScene.startScene()
	end
	local label2 = cc.Label:createWithSystemFont("确定", "Marker Felt", 30)
	label2:setColor(display.COLOR_RED)
	local PhotoBtn2 = UIUtil.controlBtn(ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, label2, cc.p(display.cx, 170), cc.size(700,100), sureFunc, bgSp)
	
	local function callFunc(  )
		layer:removeFromParent()
	end
	local label3 = cc.Label:createWithSystemFont("取消", "Marker Felt", 30)
	label3:setColor(display.COLOR_BLUE)
	local PhotoBtn3 = UIUtil.controlBtn(ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, label3, cc.p(display.cx, 50), cc.size(700,100), callFunc, bgSp)

	local move = cc.MoveTo:create(0.2, cc.p(0, 301))
    bgSp:runAction(move)
end

function SettingLayer:createLayer(  )
	_setting = self
	_setting:setSwallowTouches()
	_setting:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)


	self:buildLayer()
end

return SettingLayer