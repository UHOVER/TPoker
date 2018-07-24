
--[[
**************************************************************************
* NAME OF THE BUG :  YDWX_DZ_WANGXIAOXUE_BUG _20160722_006
* DESCRIPTION OF THE BUG :Page did not respond
* MODIFIED BY : 王礼宁
* DATE :2016-8-2
*************************************************************************/
]]

local ViewBase = require("ui.ViewBase")
local PersonInfo = class("PersonInfo", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local MineCtrol = require("mine.MineCtrol")

local _personInfo = nil
local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 30

local viewSize = {}

local userId = nil
local userData = {}

local personData = {}
local isFriend = nil

local PERSON_TAG = nil
local delBtn = nil

local function Callback(  )
	_personInfo:removeTransitAction()
	if PERSON_TAG then
		DZChat.showChatChangeData( userData )
	end
end

local function deleteUser(  )
	local layer = nil
	local function deleteFriend(  )
		local function response( data )
			dump(data)
			if data.code == 0 then
				layer:removeFromParent()

				MineCtrol.deleteFriend( userId )

				_personInfo:removeTransitAction()

				DZChat.clickClearRecord(personData["rongyun_id"], DZChat.TYPE_FRIEND)
				if PERSON_TAG then
					DZChat.getChatList()
				end

				local friend = require("friend.FriendList"):create()
				friend:addTableView()
			end
		end
		local tabData = {}
		tabData["user_id"] = userId
		XMLHttp.requestHttp("delFriend", tabData, response, PHP_POST)
	end
	layer = ViewCtrol.showTips({title = "删除好友", content = "你确定要删除吗？", rightListener = deleteFriend})
end

local function addCallBack(  )
	if isFriend then
		local MessageCtorl = require("message.MessageCtorl")
		MessageCtorl.setChatData(userId)
		MessageCtorl.setChatType(MessageCtorl.CHAT_USER)

		NoticeCtrol.removeNoticeById(10003)
		NoticeCtrol.removeNoticeById(20003)
		NoticeCtrol.removeNoticeById(20004)

		local Message = require('message.MessageScene')
		Message.startScene()

	else
		local tmpTab = {id = userId}

		local test = require("club.ClubTest")
		local layer = test:create()
		_personInfo:addChild(layer)
		layer:createLayer(tmpTab, "friend")
	end
end

function PersonInfo:addTop(  )
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "详细资料", parent = self})

	delBtn = UIUtil.addMenuFont(tab, '删除', cc.p(display.right-50, display.top-85), deleteUser, self)
	self:buildData()
end

function PersonInfo:buildData(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			personData = data.data

			self:buildLayer()
		end
	end
	local tabData = {}
	tabData["user_id"] = userId
	XMLHttp.requestHttp("user_detail", tabData, response, PHP_POST)
end

function PersonInfo:buildLayer(  )
	
	-- dump(personData)

	local photoShow_H = 344
	local scrollH = 0
	local viewH = 100
	local sizeH = {186}
	for i=1,#personData.clubs do
		if i == 1 then
			sizeH[#sizeH+1] = 110+36
		else
			sizeH[#sizeH+1] = 110
		end
	end
	if next(personData.team) ~= nil then
		sizeH[#sizeH+1] = 110+36
	end
	sizeH[#sizeH+1] = 98+36
	for i=1,#sizeH do
		scrollH = scrollH+sizeH[i]
	end

	if (scrollH+photoShow_H) > display.height then
		viewSize = {width = display.width, height = scrollH + photoShow_H+viewH}
	else
		viewSize = {width = display.width, height = display.height+viewH}
	end

	print(viewSize.height)

	local labelStr = nil
	if personData.friends == "yes" then
    	labelStr = "发送消息"
    	delBtn:setVisible(false)
    	isFriend = true
    else
    	labelStr = "加为好友"
    	delBtn:setVisible(false)
    	isFriend = false
    end

	-- 大背景scrollView
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})
	
	-- 相册
	local params = {bgArray=personData.imgs, pos=cc.p(0,viewSize.height-photoShow_H), parent=layer, tag=true, view=scrollView, rangeH=200, viewH=display.height-130}
	ClubModel.buildPageView( params )
	-- ClubModel.buildPageView( personData.imgs, cc.p(0,viewSize.height-photoShow_H), layer, true )

	local infoBg = {}
	local infoNode = {}
	local infoBgH = 0
	
	local line_bg = {}
	local line_text = {}

	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		infoNode[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (viewSize.height-photoShow_H-infoBgH)), parent=layer})
		local infoH = 0
		if sizeH[i] == (110+36) then
			infoH = sizeH[i]-36
			sizeH[i] = infoH
			local line = UIUtil.addImageView({image = ResLib.IMG_LINE_BG, touch=false, scale=true, size=cc.size(display.width, 36),pos=cc.p(0, 110), ah=cc.p(0,0), parent=infoNode[i]})
			line_text[#line_text+1] = UIUtil.addLabelArial('', 26, cc.p(20, 36/2), cc.p(0, 0.5), line):setColor(ResLib.COLOR_GREY)

			infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_BG3, touch=false, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), ah=cc.p(0,0), parent=infoNode[i]})
		elseif sizeH[i] == (98+36) then
			UIUtil.addImageView({image = ResLib.IMG_LINE_BG, touch=false, scale=true, size=cc.size(display.width, 36),pos=cc.p(0, 98), ah=cc.p(0,0), parent=infoNode[i]})
			infoH = sizeH[i]-36
			infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_BG1, touch=false, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), ah=cc.p(0,0), parent=infoNode[i]})
			sizeH[i] = infoH
		elseif sizeH[i] == 186 then
			infoH = sizeH[i]
			infoBg[i] = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), ah=cc.p(0,0), parent=infoNode[i]})
		else
			infoH = sizeH[i]
			infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_BG2, touch=false, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), ah=cc.p(0,0), parent=infoNode[i]})
		end
	end

	local bg = UIUtil.addPosSprite("user/icon_bg.png", cc.p(display.width/2-5, sizeH[1]+(154/2-50)), infoBg[1], cc.p(0.5, 0.5))
    local iconBg = UIUtil.addPosSprite("user/mine_icon_bg.png", cc.p(display.width/2+80, sizeH[1]+(154/2-50)), infoBg[1], cc.p(0.5, 0.5))

	local stencil, userIcon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(77, 76.5), iconBg, ResLib.CLUB_HEAD_STENCIL_200, 0.65)
	
	local url = personData.avatar
	local function funcBack( path )
		local rect = stencil:getContentSize()
		userIcon:setTexture(path)
		userIcon:setTextureRect(rect)
	end
	if personData.avatar ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	-- 用户编号
    local idBg = UIUtil.addPosSprite("user/mine_id.png", cc.p( 150,  25), iconBg, cc.p(0, 0.5))
    local userID = personData.u_no
    UIUtil.addLabelArial(':'..userID, 32, cc.p(idBg:getPositionX()+30, idBg:getPositionY()), cc.p(0, 0.5), iconBg)


	local name = StringUtils.getShortStr( personData.username, LEN_NAME)
	local labelName = UIUtil.addLabelArial(name, 36, cc.p(display.width/2, sizeH[1]/2), cc.p(0.5, 0.5), infoBg[1])

	local sex_sp = UIUtil.addPosSprite("user/user_icon_sex_female.png", cc.p( labelName:getPositionX()+ 10 + labelName:getContentSize().width/2,  labelName:getPositionY()), infoBg[1], cc.p(0, 0.5))
    local sexImg = DZConfig.getSexImg(tonumber(personData.sex))
    sex_sp:setTexture(sexImg)

    -- 钻石
	local diaSp = UIUtil.addPosSprite("user/icon_zhuanshi_small.png", cc.p(display.width/2-100, labelName:getPositionY()-50), infoBg[1], cc.p(0,0.5))
    local diamonds = personData.diamonds
    local dia = UIUtil.addLabelArial(diamonds, 25, cc.p(diaSp:getPositionX()+diaSp:getContentSize().width+10, labelName:getPositionY()-50), cc.p(0, 0.5), infoBg[1])

    -- 记分牌
	local spJiF = UIUtil.addPosSprite("user/icon_spades_small.png", cc.p(display.width/2+50, labelName:getPositionY()-50), infoBg[1], cc.p(0,0.5))
    local scores = personData.scores
    UIUtil.addLabelArial(scores, 25, cc.p(spJiF:getPositionX()+spJiF:getContentSize().width+10, labelName:getPositionY()-50), cc.p(0, 0.5), infoBg[1])

    -- dump(line_bg)
    -- dump(line_text)
    local count = #personData.clubs
    if count > 0 then
    	line_text[1]:setString("俱乐部")
    	for i=1,count do
    		if count == 1 then
    			infoBg[i+1]:loadTexture(ResLib.IMG_CELL_BG1)
    		else
    			if i == 1 then
	    			infoBg[i+1]:loadTexture(ResLib.IMG_CELL_BG3)
	    		elseif i == count then
	    			infoBg[i+1]:loadTexture(ResLib.IMG_CELL_BG2)
	    		else
	    			infoBg[i+1]:loadTexture(ResLib.IMG_CELL_BG2_1)
	    		end
    		end
    		
    		self:buildItem(i, infoBg[i+1])
    	end
    end

    -- team
    if next(personData.team) ~= nil then
    	line_text[#line_text]:setString("战队")
    	infoBg[#infoBg-1]:loadTexture(ResLib.IMG_CELL_BG1)
    	self:buildTeam( personData.team, infoBg[#infoBg-1] )
    end

    self:buildStatUser( infoBg[#infoBg] )
    
    --[[
    local label = cc.Label:createWithSystemFont(labelStr, "Arial", 36)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 60), cc.size(710,80), addCallBack, self)
	--]]
end

function PersonInfo:buildStatUser( node )
	local nodeH = node:getContentSize().height
	local function callback( ... )
		-- 个人数据统计
		self:dataStatUser()
	end
	local btn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0, 0), pos = cc.p(0, 0), touch = true, scale9 = true, size = cc.size(display.width, nodeH), listener = callback, parent = node})

	UIUtil.addLabelArial("数据统计", 36, cc.p(20, nodeH/2), cc.p(0, 0.5), btn)
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-15, nodeH/2), btn, cc.p(1, 0.5))
end

function PersonInfo:buildTeam( data, node )
	local nodeH = 110
	local function callback( sender)
		do return end
		MineCtrol.dataStatTeam( data.team_id, function ( data )
		    local MineTeam = require("mine.MineTeam")
		    local layer = MineTeam:create()
		    self:addChild(layer, 1)
		    layer:createLayer( 2, data )
		end )
	end
	local btn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0, 0), pos = cc.p(0, 0), touch = false, scale9 = true, size = cc.size(display.width, nodeH), listener = callback, parent = node})

	-- 队长
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(60,nodeH/2), btn, ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	local url = data.team_logo
	local function funcBack( path )
		local rect = Icon:getContentSize()
		Icon:setTexture(path)
		Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	local name = data.team_name.."战队"
	local teamName, team_icon = UIUtil.addNameByType({nameType = 5, nameStr = name, fontSize = 34, pos = cc.p(130, nodeH*2/3), parent = btn})
	local des = "来自"..data.club_name.."俱乐部"
	UIUtil.addLabelArial(des, 28, cc.p(130, nodeH/3-10), cc.p(0, 0.5), btn):setColor(ResLib.COLOR_GREY)

end

function PersonInfo:buildItem( idx, node )

	local nodeH = 110
	local clubData = {}
	clubData = personData.clubs
	local data = clubData[idx]

	local function callback( sender)
		ClubCtrol.dataStatClubInfo( clubData[idx].club_id, function (  )
			local tag = sender:getTag()
			local clubInfo = require('club.ClubInfo')
			local layer = clubInfo:create()
			self:addChild(layer)
			layer:createLayer( "club" )
		end)
	end
	local btn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0, 0), pos = cc.p(0, 0), touch = true, scale9 = true, size = cc.size(display.width, nodeH), listener = callback, parent = node})
	btn:setTag(idx)

	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(130, nodeH/3-10), btn, cc.p(0, 0.5))
	local count = UIUtil.addLabelArial("", 28, cc.p(180, nodeH/3-10), cc.p(0, 0.5), btn):setColor(ResLib.COLOR_GREY)

	local club_icon = nil
	local club_icon_small = nil
	local name_str = nil
	local color = nil
	if tonumber(data.club_type) == 0 then
		count:setString(data.count.."/"..data.max_count)
		club_icon = ResLib.CLUB_HEAD_GENERAL
		club_icon_small = ResLib.CLUB_HEAD_GENERAL_SMALL
		name_str = "俱乐部"
		color = ResLib.COLOR_BLUE
	else
		count:setString(data.count.."/".."无限制")
		club_icon = ResLib.CLUB_HEAD_ORIGIN
		club_icon_small = ResLib.CLUB_HEAD_ORIGIN_SMALL
		name_str = "创始俱乐部"
		color = ResLib.COLOR_YELLOW
	end

	local nameStr = StringUtils.getShortStr( data.club_name , LEN_NAME)
	local name = UIUtil.addLabelArial(nameStr..name_str, 34, cc.p(135, nodeH*2/3), cc.p(0, 0.5), btn):setColor(color)
	local icon_small = UIUtil.addPosSprite(club_icon_small, cc.p(name:getPositionX()+name:getContentSize().width+10, nodeH*2/3), btn, cc.p(0, 0.5))

	local stencil, clubIcon = UIUtil.createCircle(club_icon, cc.p(60,nodeH/2), btn, ResLib.CLUB_HEAD_STENCIL_200, 0.4)

	local url = data.avatar
	local function funcBack( path )
		local rect = stencil:getContentSize()
		clubIcon:setTexture(path)
		clubIcon:setTextureRect(rect)
	end
	if data.avatar ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	local site = ClubCtrol.getNumberOfSite(data.city)
	UIUtil.addLabelArial(site, 28, cc.p(330, nodeH/3-10), cc.p(0, 0.5), btn):setColor(ResLib.COLOR_GREY)

end
--[[
function PersonInfo:buildItem( idx, posY, parent)
	local node = cc.Node:create()
	parent:addChild(node)

	local clubData = {}
	clubData = personData.clubs
	local btn = nil
	local nodeH = 110
	if idx == #clubData+1 then
		node:setContentSize(cc.size(display.width, 100))
		node:setPosition(cc.p(0, posY-(idx*nodeH)+10))

		local function callback( ... )
			-- 个人数据统计
			self:dataStatUser()
		end
		local btn = UIUtil.addImageBtn({norImg = ResLib.TABLEVIEW_CELL_BG, selImg = ResLib.TABLEVIEW_CELL_BG, ah = cc.p(0, 0), pos = cc.p(0, 5), touch = true, scale9 = true, size = cc.size(display.width, 100), listener = callback, parent = node})

		UIUtil.addLabelArial("数据统计", 30, cc.p(20, 45), cc.p(0, 0.5), btn)
		UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(display.width-70, 50), btn, cc.p(0, 0.5))
	else
		local data = clubData[idx]
		node:setContentSize(cc.size(display.width, nodeH))
		node:setPosition(cc.p(0, posY-(idx*nodeH)))


		local function callback( sender)
			local tag = sender:getTag()
			local clubInfo = require('club.ClubInfo')
			local layer = clubInfo:create()
			self:addChild(layer)
			layer:createLayer( clubData[idx].club_id, "club" )
		end
		local btn = UIUtil.addImageBtn({norImg = ResLib.TABLEVIEW_CELL_BG_LINE_2, selImg = ResLib.TABLEVIEW_CELL_BG_LINE_2, ah = cc.p(0, 0), pos = cc.p(0, 5), touch = true, scale9 = true, size = cc.size(display.width, nodeH), listener = callback, parent = node})
		btn:setTag(idx)

		UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(130, nodeH/3), btn, cc.p(0, 0.5))
		local count = UIUtil.addLabelArial("", 30, cc.p(180, nodeH/3), cc.p(0, 0.5), btn):setColor(ResLib.COLOR_GREY)

		local club_icon = nil
		local club_icon_small = nil
		local name_str = nil
		local color = nil
		if tonumber(data.club_type) == 0 then
			count:setString(data.count.."/"..data.max_count)
			club_icon = ResLib.CLUB_HEAD_GENERAL
			club_icon_small = ResLib.CLUB_HEAD_GENERAL_SMALL
			name_str = "俱乐部"
			color = ResLib.COLOR_BLUE
		else
			count:setString(data.count.."/".."无限制")
			club_icon = ResLib.CLUB_HEAD_ORIGIN
			club_icon_small = ResLib.CLUB_HEAD_ORIGIN_SMALL
			name_str = "创始俱乐部"
			color = ResLib.COLOR_YELLOW
		end

		local nameStr = StringUtils.getShortStr( data.club_name , LEN_NAME)
		local name = UIUtil.addLabelArial(nameStr..name_str, 36, cc.p(135, nodeH*2/3), cc.p(0, 0.5), btn):setColor(color)
		local icon_small = UIUtil.addPosSprite(club_icon_small, cc.p(name:getPositionX()+name:getContentSize().width+10, nodeH*2/3), btn, cc.p(0, 0.5))

		local stencil, clubIcon = UIUtil.createCircle(club_icon, cc.p(60,nodeH/2), btn, ResLib.CLUB_HEAD_STENCIL_200, 0.4)

		local url = data.avatar
		local function funcBack( path )
			local rect = stencil:getContentSize()
			clubIcon:setTexture(path)
			clubIcon:setTextureRect(rect)
		end
		if data.avatar ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end

		local site = ClubCtrol.getNumberOfSite(data.city)
		UIUtil.addLabelArial(site, 30, cc.p(330, nodeH/3), cc.p(0, 0.5), btn):setColor(ResLib.COLOR_GREY)
	end
	
	return node
end--]]

function PersonInfo:dataStatUser(  )
	local function response(data)
		if data.code == 0 then
			local dataStat = require("friend.DataStat")
			local layer = dataStat:create()
			self:addChild(layer)
			layer:createLayer(data.data)
		end
	end
	local tabData = {}
	tabData["uid"] = userId
	XMLHttp.requestHttp(PHP_PERSONAL_STATS, tabData, response, PHP_POST)
end

function PersonInfo:createLayer( data, target )
	_personInfo = self
	_personInfo:setSwallowTouches()
	_personInfo:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	personData = {}
	userData = {}
	userId = nil
	PERSON_TAG = nil
	delBtn = nil

	if target then
		PERSON_TAG = target
		userData = data
		userId = data.playerBackId
	else
		userId = data.id
	end

	self:addTop()

end

return PersonInfo

--[[
**************************************************************************
* NAME OF THE BUG :  YDWX_DZ_WANGXIAOXUE_BUG _20160722_006
* DESCRIPTION OF THE BUG :Page did not respond
* MODIFIED BY : 王礼宁
* DATE :2016-8-2
*************************************************************************/
]]
