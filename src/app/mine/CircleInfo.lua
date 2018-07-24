local ViewBase = require("ui.ViewBase")
local CircleInfo = class("CircleInfo", ViewBase)

local MineCtrol = require("mine.MineCtrol")

local _circleInfo = nil
local scrollView = nil
local imageView = nil
local viewSize = {}

--圈子成员node高度
local PLAYER_H = nil

local stencil, circleIcon = nil, nil
local circleName = nil
local circle_icon = nil

--存放圈子ID
local circleTab = {}

local circleData = {}

local playerData = {}

local del_member_btn = {}

local chatCircleMsg = {}


local function Callback(  )
	_circleInfo:removeTransitAction()
	
	-- DZChat.showChatChangeData(chatCircleMsg)
	DZChat.checkChat(circleTab['id'], StatusCode.CHAT_CIRCLE)
end

-- 替换圈子头像
local function circleIconFunc(  )
	local function funcback( iconName, iconPath )
		-- headimg = iconName
		_circleInfo:buildIcon(iconName, iconPath)
	end
	ClubModel.buildPhoto( 0, funcback, _circleInfo )
end

-- 圈子名称
local function editCircleName(  )
	local editName = require("mine.EditCircleName")
	local layer = editName:create()
	_circleInfo:addChild(layer)
	layer:createLayer( circleTab )
end

-- 消息通知
local function msgFunc( isOk )

	local myId = Single:playerModel():getId()
	local key = myId .. chatCircleMsg.ryid
	local value = isOk
	print(">>>>>>>> " .. key)
	print(">>>>>>>> " .. isOk)
	Storage.setStringForKey(key, value)

end

-- 邀请限制
local function inviteFunc( isOk )
	local function response( data )
		dump(data)
	end
	local tabData = {}
	tabData["circle_id"] = circleTab.id
	tabData["invite"] = isOk
	XMLHttp.requestHttp("changeCircleInvite", tabData, response, PHP_POST)
end

-- 开局限制
local function beginFunc( isOk )
	local function response( data )
		dump(data)
	end
	local tabData = {}
	tabData["circle_id"] = circleTab.id
	tabData["begin"] = isOk
	XMLHttp.requestHttp("changeCircleBegin", tabData, response, PHP_POST)
end

-- 清空聊天记录
local function clearFunc(  )
	
	local layer = nil
	local function clearMsg(  )
		DZChat.clickClearRecord(chatCircleMsg["ryid"], chatCircleMsg["chatType"])
		layer:removeFromParent()
	end
	layer = UIUtil.clearChatMsg( {sureFunc = clearMsg, parent = _circleInfo} )
end

-- 删除退出圈子
local function deleteCallback(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			
			_circleInfo:removeTransitAction()

			DZChat.clickClearRecord(chatCircleMsg["ryid"], chatCircleMsg["chatType"])
			DZChat.getChatList()
		end
	end
	local tabData = {}
	tabData["circle_id"] = circleTab.id
	XMLHttp.requestHttp("quitCircle", tabData, response, PHP_POST)
end

function CircleInfo:buildLayer(  )

	circleData = MineCtrol.getCircleInfo()
	dump(circleData)

	viewSize = {width = display.width, height = display.height}

	local user_id = Single:playerModel():getId()

	local count = #circleData.playerInfo
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "圈子信息(".. count .."人)", parent = self})

	-- 大背景scrollView
    if scrollView then
        scrollView:removeFromParent()
        scrollView = nil
    end
    scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )

	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})
	local width = imageView:getContentSize().width
	local height = imageView:getContentSize().height

	
	-- 圈子信息  头像、 名称、 人数
	local infoBg = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 140), pos=cc.p(width/2, height), ah=cc.p(0.5,1), parent=imageView})

	stencil, circleIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(70, 140/2), parent = infoBg, nor = ResLib.CIRCLE_HEAD, sel = ResLib.CIRCLE_HEAD, listener = circleIconFunc})
	local url = circleData.avatar
	local function funcBack( path )
		circleIcon:loadTextureNormal(path)
		circleIcon:loadTexturePressed(path)
		circleIcon:loadTextureDisabled(path)
	end
	if circleData.avatar ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	local str = circleData.circle_nickname == "" and "我的圈子" or circleData.circle_nickname
	local name = StringUtils.getShortStr( str, LEN_NAME)

	circleName,circle_icon = UIUtil.addNameByType({nameType = 4, nameStr = name, fontSize = 30, pos = cc.p(140, 140-50), parent = infoBg})

	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(140, 140-90), infoBg, cc.p(0, 0.5))
	UIUtil.addLabelArial(count .. "/20", 30, cc.p(180, 140-90), cc.p(0,0.5), infoBg)

	UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, pos = cc.p(display.width, 140/2), ah = cc.p(1, 0.5), swalTouch = true, touch = true, scale9 = true, size = cc.size(300, 140), listener = editCircleName, parent = infoBg})
    UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-20, 140/2), infoBg, cc.p(1, 0.5))

	for k,v in pairs(circleData.playerInfo) do
		if v.player_id == tonumber(user_id) then
			table.insert(playerData, 1, v)
		else
			table.insert(playerData, v)
		end
	end
	-- dump(playerData)
	
	-- 圈子成员 头像、名称
	self:addMemberIcon(playerData, imageView)
	
	-- -- 圈子功能
	self:buildCircleUI()


	local label = cc.Label:createWithSystemFont("删除并退出", "Marker Felt", 30):setColor(ResLib.COLOR_BLUE)
	local btn = UIUtil.controlBtn(ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, ResLib.BTN_BLUE_BORDER, label, cc.p(display.width/2, 50), cc.size(display.width-40,80), deleteCallback, self)

end

-- 刷新圈子详情页

function CircleInfo.updateCircleInfo( str )
	if str then
		circleName:setString(str)
		UIUtil.updateNameByType( 4, circleName, circle_icon )
	else
		_circleInfo:init()
		_circleInfo:buildLayer( )
	end
end

-- 设置头像
function CircleInfo:buildIcon( name, iconPath )
	
	local function response( data )
		dump(data)
		if data.code == 0 then
			circleIcon:loadTextureNormal(iconPath)
			circleIcon:loadTexturePressed(iconPath)
			circleIcon:loadTextureDisabled(iconPath)

			local sp = cc.Sprite:create(iconPath)
			local scaleX = 200/sp:getContentSize().width
			local scaleY = 200/sp:getContentSize().height
			circleIcon:setScale(scaleX, scaleY)

			MineCtrol.editCircleInfo( {img = name} )

		end
	end
	local tabData = {}
	tabData["circle_id"] = circleTab.id
	tabData["avatar_name"] = name
	XMLHttp.requestHttp("modifyCircleAvatar", tabData, response, PHP_POST)
end

-------------------------------
------圈子成员
-------------------------------

-- 查看成员详情
local function iconCallback( sender )
	local tag = sender:getTag()

	local userData = {id = tag}

	local personInfo = require("friend.PersonInfo")
	local layer = personInfo:create()
	_circleInfo:addChild(layer)
	layer:createLayer( userData )
end

-- 添加圈子成员
local function addMemberFunc(  )
	local newCircle = require("message.NewCircle")
	local layer = newCircle:create()
	_circleInfo:addChild(layer)
	layer:createLayer("circle")
end

-- 删除圈子成员
local function subMemberFunc( sender )
	local tag = sender:getTag()
	print(tag)
	local function response( data )
		dump(data)
		if data.code == 0 then
			MineCtrol.editCircleInfo({playerId = tag})

			CircleInfo.updateCircleInfo( nil )
		end
	end
	local tabData = {}
	tabData["circle_id"] = circleTab['id']
	tabData["user_id"] = tag
	XMLHttp.requestHttp("deleteUserFromCircle", tabData, response, PHP_POST)
end

-- 圈子成员UI
function CircleInfo:addMemberIcon( playerTab, layer )

	local posH = layer:getContentSize().height - 140

	-- 圈子成员数组
	local tmpTab = playerTab

	local count = nil
	-- 成员数量
	-- --判断是否只能圈主邀请
	if tonumber(circleData.invite_root) == 0 then
		if circleData.host_id == 1 then
			count = #tmpTab + 2
		else
			count = #tmpTab
		end
	else
		count = #tmpTab + 2
	end

	-- 控制行数
	local line = math.ceil( count/5 )

	local node = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, line*180), pos=cc.p(display.width/2, posH), ah=cc.p(0.5,1), parent=layer})
	local width = node:getContentSize().width
	local height = node:getContentSize().height
	PLAYER_H = height

	-- UI
	local user_stencil, user_Icon, user_btn = {}, {}, {}
	local nameBg = {}

	for i=1,line do
		-- 控制列数
		local row = 5
		if count/i < 5 then
			row = count % 5
		end
		for j=1,row do
			-- index
			local idx = ( i - 1 ) * 5 + j
			if idx <= (#tmpTab) then
				nameBg[idx] = UIUtil.addImageView({image="common/com_opacity0.png", touch=false, scale=true, size=cc.size(100, 180), pos=cc.p( width*(2*j-1)/10, height-20-(i-1)*180), ah=cc.p(0.5,1), parent=node})
				-- 头像
				user_stencil[idx], user_Icon[idx] = UIUtil.createCircle(ResLib.USER_HEAD, cc.p( width*(2*j-1)/10, height-20-(i-1)*180), node, ResLib.CLUB_HEAD_STENCIL_200)
				user_Icon[idx]:setAnchorPoint(cc.p(0.5, 1))
				user_stencil[idx]:setAnchorPoint(cc.p(0.5, 1))


				user_btn[idx] = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0.5, 1),  pos = cc.p( width*(2*j-1)/10, height-(i-1)*180-20), touch = true, swalTouch = true, scale9 = true, size = cc.size(70, 80), listener = iconCallback, parent = node})

				-- user_stencil[idx], user_Icon[idx], user_mask[idx] = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p( width*(2*j-1)/10, height-(i-1)*140), parent = node, nor = ResLib.USER_HEAD, sel = ResLib.USER_HEAD, listener = iconCallback})
				
				user_btn[1]:setTouchEnabled(false)
				user_btn[idx]:setTag(tmpTab[idx].player_id)

				-- 头像下载
				if tmpTab[idx].player_avatar ~= "" then
					local url = tmpTab[idx].player_avatar
					local function funcBack( path )
						local rect = user_stencil[idx]:getContentSize()
						user_Icon[idx]:setTexture(path)
						user_Icon[idx]:setTextureRect(rect)
					end
					ClubModel.downloadPhoto(funcBack, url, true)
				end

				-- 名称
				local name = StringUtils.getShortStr( tmpTab[idx].player_name, LEN_NAME)
				UIUtil.addLabelArial(name, 20, cc.p( 50, 40 ), cc.p(0.5,0), nameBg[idx])

				-- 添加删除按钮
				if idx > 1 then
					del_member_btn[idx] = UIUtil.addImageBtn({norImg = "user/circle_btn_delete.png", selImg = "user/circle_btn_delete.png", ah = cc.p(0.5, 1),  pos = cc.p(width*(2*j-1)/10-45, height-20-(i-1)*180), touch = true, swalTouch = true, listener = subMemberFunc, parent = node})
					del_member_btn[idx]:setTag(tmpTab[idx].player_id)
					del_member_btn[idx]:setVisible(false)
				end

			elseif idx == #tmpTab+1 then
				-- 添加成员
				local addBtn = UIUtil.addMenuBtn("user/circle_btn_add.png", "user/circle_btn_add.png", addMemberFunc, cc.p( width*(2*j-1)/10, height-20-(i-1)*180 ), node)
				addBtn:setAnchorPoint(cc.p(0.5, 1))

			elseif idx == #tmpTab+2 then
				-- 删除成员
				local showDel = true
				local function deleteBack(  )
					if showDel then
						for k,v in pairs(del_member_btn) do
							del_member_btn[k]:setVisible(true)
						end
						showDel = false
					else
						for k,v in pairs(del_member_btn) do
							del_member_btn[k]:setVisible(false)
						end
						showDel = true
					end
					
				end
				local subBtn = UIUtil.addMenuBtn("user/circle_btn_sub.png", "user/circle_btn_sub.png", deleteBack, cc.p( width*(2*j-1)/10, height-20-(i-1)*180 ), node)
				subBtn:setAnchorPoint(cc.p(0.5, 1))
				if circleData.host_id == 1 then
					subBtn:setVisible(true)
				else
					subBtn:setVisible(false)
				end
			end
		end
	end
	
end

function CircleInfo:buildCircleUI(  )
	local circleLabel = {"新消息通知", "只能圈主邀请", "只能圈主开局", "清空聊天记录"}

	local function valueChanged( tag, pSender )
		local pControl = pSender
		if tag == 10 then
			if pControl:getSelectedIndex() == 0 then
				print("ON")
				msgFunc(1)
			else
				print("OFF")
				msgFunc(0)
			end
		elseif tag == 20 then
			if pControl:getSelectedIndex() == 0 then
				print("打开群主邀请限制")
				inviteFunc(0)
			else
				print("关闭群主邀请限制")
				inviteFunc(1)
			end
		elseif tag == 30 then
			if pControl:getSelectedIndex() == 0 then
				print("打开群主开局限制")
				beginFunc(0)
			else
				print("关闭群主开局限制")
				beginFunc(1)
			end
		end
	end

	local btnBg = {}
	local posY = viewSize.height-200-PLAYER_H
	local mask = {}
	local labelTab = {}
	local switch = {}

	for i,v in pairs(circleLabel) do
		if i <= 3 then
			btnBg[i] = UIUtil.addImageView({image=ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 98), pos = cc.p(display.cx, posY-(i-1)*98), ah = cc.p(0.5,0.5), parent=imageView})
			switch[i] = UIUtil.addTogMenu({pos = cc.p(btnBg[i]:getContentSize().width-20, btnBg[i]:getContentSize().height/2), listener = valueChanged, parent = btnBg[i]})
			switch[i]:setAnchorPoint(cc.p(1,0.5))
			switch[i]:setTag(i*10)
			if i > 1 then
				mask[i] = UIUtil.addImageView({image="common/com_grey_block.png", touch=true, scale=true, size=cc.size(display.width, btnBg[i]:getContentSize().height-6), pos = cc.p(0,3), ah = cc.p(0,0), parent=btnBg[i]})
				if circleData.host_id == 1 then
					mask[i]:setVisible(false)
				else
					mask[i]:setVisible(true)
				end
			end
		else
			btnBg[i] = UIUtil.addImageBtn({norImg = ResLib.TABLEVIEW_CELL_BG, selImg = ResLib.TABLEVIEW_CELL_BG, pos = cc.p(display.cx, posY-(i-1)*98-34), touch = true, scale9 = true, size = cc.size(display.width, 98), listener = clearFunc, parent = imageView})
        	btnBg[i]:setTag(i)

        	UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 34),pos=cc.p(0, 98), ah=cc.p(0,0), parent=btnBg[i]})
		end
		labelTab[i] = UIUtil.addLabelArial(v, 34, cc.p(20, btnBg[i]:getContentSize().height/2), cc.p(0,0.5), btnBg[i])
	end
	if circleData.host_id ~= 1 then
		labelTab[2]:setColor(ResLib.COLOR_GREY)
		labelTab[3]:setColor(ResLib.COLOR_GREY)
	end

	-- 消息通知
	local myId = Single:playerModel():getId()
	local key = myId .. chatCircleMsg.ryid

	local isOk = Storage.getStringForKey(key)
	if isOk == "" then
		isOk = 1
	end
	print("--------消息通知------->>>>> : " .. isOk)
	if tonumber(isOk) == 1 then
		switch[1]:setSelectedIndex(0)
	else
		switch[1]:setSelectedIndex(1)
	end

	-- 邀请限制
	-- 0 只能圈主邀请
	-- 1 成员可邀请
	if tonumber(circleData.invite_root) == 0 then
		switch[2]:setSelectedIndex(0)
	else
		switch[2]:setSelectedIndex(1)
	end

	-- 开局限制
	-- 0 只能圈主开局
	-- 1 成员可开局
	if tonumber(circleData.begin_root) == 0 then
		switch[3]:setSelectedIndex(0)
	else
		switch[3]:setSelectedIndex(1)
	end

end

function CircleInfo:createLayer( msg )
	_circleInfo = self
	_circleInfo:setSwallowTouches()
	_circleInfo:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	circleTab['id'] = MineCtrol.getCircleId()
	
	scrollView = nil

	self:init()

	chatCircleMsg = msg
	dump(chatCircleMsg)

	self:buildLayer()
end

function CircleInfo:init(  )
	imageView = nil

	PLAYER_H = nil
	
	stencil, circleIcon = nil, nil

	circleName = nil

	circleData = {}

	playerData = {}

	del_member_btn = {}

end

return CircleInfo