local ViewBase = require("ui.ViewBase")
local addFriend = class("addFriend", ViewBase)

local _addFriend = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local searchEdit = nil
local btn = nil
local SEARCH_TEXT = nil

local function Callback(  )
	-- _addFriend:removeFromParent()
	_addFriend:removeTransitAction()
end

-- YDWX_DZ_ZHANGXINMIN_ BUG _20160708 _002 Tip Repeat
local function searchCallback(  )
	print("搜索")
	--  YDWX_DZ_ZHANGXINMIN_BUG _20160627 _001
	if SEARCH_TEXT == nil or SEARCH_TEXT == "" then
		ViewCtrol.showMsg("请输入好友昵称或手机号码！")
		return
	else
		if not cc.LuaHelp:IsGameName(SEARCH_TEXT) or string.len(SEARCH_TEXT) > LEN_NAME then
			ViewCtrol.showTip({content = "昵称或手机号码格式不正确！"})
			return
		end
	end

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			if data.msg == "success" then
				local search = require("club.SearchList")
				local layer = search:create()
				_addFriend:addChild(layer)
				layer:createLayer(data.data, "friend")
			elseif data.msg == "failed" then
				ViewCtrol.showTip({title = "搜索的用户不存在", content = "没有找到相关用户，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["target"] = SEARCH_TEXT
	XMLHttp.requestHttp(PHP_FRIEND_SEARCH, tabData, response, PHP_POST)
end
-- YDWX_DZ_ZHANGXINMIN_ BUG _20160708 _002 Tip Repeat

local function phoneCallBack(  )
	print("打开手机联系人")
	local phoneNum = require("friend.phoneNum")
	local layer = phoneNum:create()
	_addFriend:addChild(layer)
	layer:createLayer()
end

local function shareCallBack(  )
	local _url = SHARE_URL
	local contentStr = Single:playerModel():getPName().."邀请您玩"..DISPLAY_G_NAME
	DZWindow.shareDialog(DZWindow.SHARE_URL, {title = "一起来玩"..DISPLAY_G_NAME, content = contentStr, url = _url})
end

function addFriend:buildLayer(  )

	-- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "添加好友", parent = self})

	local imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), parent=self})
	local function callback( sender )
		local tag = sender:getTag()
		if tag == 2 then
			phoneCallBack()
		elseif tag == 3 then
			shareCallBack()
		end
	end

	local viewHeight = imageView:getContentSize().height
	-- 好友搜索
	local sizeH = {100, 140, 100}
	local infoNode = {}
	local FriendBtnBg = {}
	local FriendBtn = {}
	local infoBgH = 0
	local img = {ResLib.IMG_CELL_BG1, ResLib.IMG_CELL_BG3, ResLib.IMG_CELL_BG2}
	for i=1, #sizeH do
		infoBgH = infoBgH + sizeH[i]
		infoNode[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, viewHeight - infoBgH), parent=imageView})

		local infoH = 0
		if sizeH[i] == 140 then
			infoH = sizeH[i]-40
			sizeH[i] = infoH
			UIUtil.addImageView({image = ResLib.IMG_LINE_BG, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(0, 100), ah=cc.p(0,0), parent=infoNode[i]})
		else
			infoH = sizeH[i]
		end
		local img = img[i]
		FriendBtnBg[i] = UIUtil.addImageView({image=img, touch=false, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), parent=infoNode[i]})
		
		if i > 1 then
			FriendBtn[i] = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0, 0.5), pos = cc.p(0, sizeH[i]/2), touch = true, scale9 = true, size = cc.size(display.width, sizeH[i]), listener = callback, parent = FriendBtnBg[i]})
			FriendBtn[i]:setTag(i)
			UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, 50), FriendBtnBg[i], cc.p(1, 0.5))
		end
	end
	
	local width = FriendBtnBg[1]:getContentSize().width
	local height = FriendBtnBg[1]:getContentSize().height

	-- 搜索框
	local searchBg = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-50, 60), pos=cc.p(width/2, height/2), ah =cc.p(0.5, 0.5), parent=FriendBtnBg[1]})

	searchEdit = UIUtil.addEditBox( nil, cc.size(display.width-50-120, 60), cc.p(10,searchBg:getContentSize().height/2), "好友名称/电话号码", searchBg )
	searchEdit:setMaxLength(18)
	searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	searchEdit:setAnchorPoint(cc.p(0, 0.5))
	SEARCH_TEXT = ""
	local function callback( eventType, sender )
		if eventType == "began" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			SEARCH_TEXT = str
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )

	-- 搜索按钮
	local function ssFunc(  )
		if SEARCH_TEXT ~= "" then
			searchCallback()
		end
	end
	UIUtil.addImageBtn({norImg = "common/s_ss_icon.png", selImg = "common/s_ss_icon.png", disImg = "common/s_ss_icon.png", ah = cc.p(1, 0.5), pos = cc.p(searchBg:getContentSize().width-1, searchBg:getContentSize().height/2), touch = true, listener = ssFunc, parent = searchBg})

	-- btn = UIUtil.addPosSprite(ResLib.SEARCH_BTN, cc.p(display.width-90, 30), searchEdit, cc.p(0.5, 0.5))
	-- btn:setScale(1.5)

	-- 添加手机联系人
	local addFriend = UIUtil.addPosSprite("common/icon_add_friend1.png", cc.p(26, height/2), FriendBtnBg[2], cc.p(0, 0.5))
	local label = cc.Label:createWithSystemFont("添加手机联系人", "Arial", 34, cc.size(300, 40), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
				label:setTextColor(cc.c3b(255, 255, 255))
				label:setAnchorPoint(cc.p(0,0.5))
				label:setPosition(cc.p(addFriend:getPositionX()+addFriend:getContentSize().width+40, 50))
				FriendBtnBg[2]:addChild(label)

	local zhaomu = UIUtil.addPosSprite("common/icon_zhaomu_friend.png", cc.p(26, height/2), FriendBtnBg[3], cc.p(0, 0.5))
	local label = cc.Label:createWithSystemFont("发布好友招募令", "Arial", 34, cc.size(300, 40), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	label:setTextColor(cc.c3b(255, 255, 255))
	label:setAnchorPoint(cc.p(0,0.5))
	label:setPosition(cc.p(zhaomu:getPositionX()+zhaomu:getContentSize().width+40, 50))
	FriendBtnBg[3]:addChild(label)

end

function addFriend:createLayer(  )
	_addFriend = self
	_addFriend:setSwallowTouches()
	_addFriend:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:buildLayer()

end

return addFriend