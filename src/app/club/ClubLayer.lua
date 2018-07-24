local ViewBase = require('ui.ViewBase')
local ClubLayer = class('ClubLayer', ViewBase)

local _clubLayer = nil
local addBox = nil
local addMenu = nil

local addText = nil

local function addCallback( tag, sender )
	local clubMask = require("club.ClubMask").new( _clubLayer )
	_clubLayer:addChild(clubMask, 10)
end

-- 新建俱乐部回调
local function newClubCallback( tag, sender )
	print('新建俱乐部')
	local newClub = require('club.ClubNew')
	local layer = newClub:create()
	_clubLayer:addChild(layer)
	layer:createLayer("club")
end

local function addClubFun(  )
	--[[local addClub = require('club.ClubAdd')
	local layer = addClub:create()
	_clubLayer:addChild(layer)
	layer:createLayer("club")--]]
	
	AddCtrol.setAddTarget( AddCtrol.CLUB )
	local _cityLayer = require("main.CityLayer"):create("add")
	_clubLayer:addChild(_cityLayer)
end

-- 加入俱乐部回调
local function addClubCallback( tag, sender )
	print('加入俱乐部'..addText)

	if addText == nil or addText == "" then
		ViewCtrol.showTip({content = "请输入俱乐部名称或名片！"})
		return
	end
	
	local function response( data )
		if data.code == 0 then
			if data.msg == "ok" then
				local addClub = require('club.SearchList')
				local layer = addClub:create()
				_clubLayer:addChild(layer,10)
				layer:createLayer(data.data, "club")
			elseif data.msg == "failed" then
				ViewCtrol.showTip({title = "俱乐部不存在", content = "没有找到相关俱乐部，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["category"] = "key"
	tabData["user_id"] = Single:playerModel():getId()
	tabData["search_key"] = addText
	XMLHttp.requestHttp( PHP_CLUB_FIND, tabData, response, PHP_POST )
end

function ClubLayer:buildLayer(  )

	local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

	-- topBar
    UIUtil.addTopBar({title = "俱乐部", rightBtnFunc = addCallback, parent = self})

	local color = cc.c3b(165, 157, 157)
	-- bg
	local imageView = UIUtil.addImageView({image=ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-230), pos=cc.p(0,100), parent=self})

	-- logo
	local Logo = cc.Sprite:create("common/poker_logo.png")
	Logo:setAnchorPoint(cc.p(0.5, 1))
	Logo:setPosition(cc.p(display.cx+50, display.height-190))
	self:addChild(Logo)

	local str = "当前您未创建或加入任何俱乐部"
	UIUtil.addLabelArial(str, 28, cc.p(display.cx, display.height-430), cc.p(0.5, 0), self):setColor(color)
	UIUtil.addLabelArial("马上", 28, cc.p(234, display.height-470), cc.p(0, 0), self):setColor(color)
	UIUtil.addLabelArial("或创建吧！", 28, cc.p(354, display.height-470), cc.p(0, 0), self):setColor(color)
	UIUtil.addMenuBtn("club/club_btn_font_add.png","club/club_btn_font_add.png", addClubFun, cc.p(294, display.height-470), self):setAnchorPoint(cc.p(0, 0))
	
	-- 搜索俱乐部
	-- local addClubBg = UIUtil.addPosSprite(ResLib.CLUB_BTN_BG, cc.p(display.cx, display.cy+20), self, cc.p(0.5, 0))
	local addClubBg = UIUtil.addImageView({image = ResLib.BTN_BLUE_BORDER, touch=false, scale=true, size=cc.size(570, 80), pos= cc.p(display.cx, display.cy+20), parent=self, ah = cc.p(0.5,0)})
	local width = addClubBg:getContentSize().width
	local height = addClubBg:getContentSize().height
	addBox = UIUtil.addEditBox( ResLib.COM_OPACITY0, cc.size(560, 80), cc.p(width/2, height/2), '加入俱乐部的ID/名称', addClubBg ):setFontColor(cc.c3b(100, 125, 165))
	addBox:setMaxLength(18)
	addBox:setPlaceholderFontColor(cc.c3b(100, 125, 165))
	addBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	local function funcback( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			local lenStr = ""
            if string.len(str) > 18 then
                lenStr = StringUtils.checkStrLength( str, 18 )
            else
                lenStr = str
            end
			sender:setText(lenStr)
			addText = lenStr
			if addText ~= "" then
				addClubCallback()
			end
		end
	end
	addBox:registerScriptEditBoxHandler(funcback)

	UIUtil.addPosSprite("club/club_icon_or.png", cc.p(display.cx, display.cy-80), self, cc.p(0.5, 0.5))

	-- new club
	local label1 = cc.Label:createWithSystemFont("新建俱乐部", "Marker Felt", 36)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label1, cc.p(display.cx, display.cy-220), cc.size(570,80), newClubCallback, self)
end
--]]

function ClubLayer:createLayer(  )
	print('ClubLayer')
	_clubLayer = self
	_clubLayer:addLayerOfTable()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	Bottom:getInstance():addBottom(4, self)
	
	self:buildLayer()

end

return ClubLayer