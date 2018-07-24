local ViewBase = require('ui.ViewBase')
local ClubInfo = class('ClubInfo', ViewBase)

local ClubCtrol = require("club.ClubCtrol")
local CardCtrol = require("cards.CardCtrol")

local _clubInfo = nil
local viewSize = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local message = {}
local isJoin = nil

local CLUBINFO_TARGET = nil

local function Callback(  )
	-- _clubInfo:removeFromParent()
	_clubInfo:removeTransitAction()
end

--  YDWX_DZ_ZHANGXINMIN_BUG _20160627 _004 Button is invalid
local function addCallBack( tag, sender )
	print('申请加入')
	-- local tag = tag:getTag()
	if CLUBINFO_TARGET == "club" then
		if isJoin == 0 then
			local clubTest = require('club.ClubTest')
			local layer = clubTest:create()
			_clubInfo:addChild(layer)
			layer:createLayer( message, "club" )
		else
			print("进入俱乐部")
			local MessageCtorl = require("message.MessageCtorl")
			MessageCtorl.setChatData(message["id"])
			MessageCtorl.setChatType(MessageCtorl.CHAT_CLUB)

			NoticeCtrol.removeNoticeById(20003)
			NoticeCtrol.removeNoticeById(20004)
			NoticeCtrol.removeNoticeById(30003)
			
			local Message = require('message.MessageScene')
			Message.startScene()
		end
	else
		local clubTest = require('club.ClubTest')
		local layer = clubTest:create()
		_clubInfo:addChild(layer)
		layer:createLayer( message, "union_club" )
	end
end

function ClubInfo:buildLayer( data )

	local color = cc.c3b(165, 157, 157)
	local photoShow_H = 570
	local sizeH = {168, 110}
	local scrollH = 0
	for i=1,#sizeH do
		scrollH = sizeH[i] + scrollH
	end
	local viewH = scrollH+photoShow_H
	if viewH < display.height-130 then
		viewH = display.height-130
	end
	viewSize = {width = display.width, height = viewH}

	message = CardCtrol.getClubInfo()

	-- 0 当前用户和俱乐部没有关系，1加入的俱乐部，2创建的俱乐部
	-- isJoin = tonumber(message.flag)

	-- 大背景scrollView
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )
	scrollView:setScrollBarEnabled(false)


	-- 俱乐部名称
	local name = StringUtils.getShortStr( message.name , LEN_NAME)

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = name or '俱乐部', parent = self})

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})

	-- 相册
	-- ClubModel.buildPageView( message.club_bg, cc.p(0,viewSize.height-photoShow_H), layer )
	-- local params = {bgArray=message.club_bg or {}, pos=cc.p(0,viewSize.height-photoShow_H), parent=layer, view=scrollView, rangeH=466-250, viewH=display.height-130}
	-- ClubModel.buildPageView( params )
	local params = {bgArray=message.club_imgs or {}, pos=cc.p(0,viewSize.height-photoShow_H), parent=layer, view=scrollView, rangeH=200, viewH=display.height}
    ClubModel.buildPageView( params )

    local posY = viewSize.height-photoShow_H
	local infoBg = {}
	local infoBgH = 0
	local infoW = 20
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		infoBg[i] = UIUtil.addImageView({image = ResLib.IMG_CELL_GREY_BG, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, posY-infoBgH), parent=layer})
        infoBg[i]:setSwallowTouches(true)
	end

	-- 俱乐部头像
	-- local headUrl = nil
	-- if tonumber(message.union) == 0 then
	-- 	headUrl = ResLib.CLUB_HEAD_GENERAL
	-- else
	-- 	headUrl = ResLib.CLUB_HEAD_ORIGIN
	-- end
	local stencil, clubIcon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(80, sizeH[1]/2), infoBg[1], ResLib.CLUB_HEAD_STENCIL_200, 0.6)
	local url = message.avatar
	local function funcBack( path )
		local rect = stencil:getContentSize()
		clubIcon:setTexture(path)
		clubIcon:setTextureRect(rect)
	end
	if url ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	end

	-- 俱乐部名称
	-- local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = name, fontSize = 36, pos = cc.p(140, sizeH[1]-20), parent = infoBg[1]})
	local clubName = UIUtil.addLabelArial(name, 36, cc.p(160, sizeH[1]/2+30), cc.p(0, 1), infoBg[1])

	-- 俱乐部总人数/当前人数
	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(160, sizeH[1]/2-30), infoBg[1], cc.p(0, 1))
	local clubCount = UIUtil.addLabelArial(message.users_count or "10086", 25, cc.p(200, sizeH[1]/2-30), cc.p(0, 1), infoBg[1]):setColor(ResLib.COLOR_YELLOW1)
	-- clubCount:setString(message.users_count..'/'..message.users_limit)

	-- 地区
	local place = ClubCtrol.getNumberOfSite(message.address)
	local clubPlace = UIUtil.addLabelArial(place, 25, cc.p(360, sizeH[1]/2-30), cc.p(0, 1), infoBg[1]):setColor(ResLib.COLOR_YELLOW1)
	
	-- 创始人
	-- local clubMan = UIUtil.addLabelArial('创始人 ', 34, cc.p(infoW, sizeH[2]/2), cc.p(0, 0.5), infoBg[2])
	-- local clubManName = UIUtil.addLabelArial(message.creator_info or '', 30, cc.p(245, sizeH[2]/2), cc.p(0, 0.5), infoBg[2])
	-- local user_stencil, user_Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(190, sizeH[2]/2), infoBg[2], ResLib.CLUB_HEAD_STENCIL_200)

	-- local url = message.creator_imgs
	-- local function funcBack( path )
	-- 	local rect = user_stencil:getContentSize()
	-- 	user_Icon:setTexture(path)
	-- 	user_Icon:setTextureRect(rect)
	-- end
	-- ClubModel.downloadPhoto(funcBack, url, true)

	-- 简介
	local clubDes = UIUtil.addLabelArial('简介', 34, cc.p(infoW, sizeH[2]/2), cc.p(0, 0.5), infoBg[2]):setColor(cc.c3b(85, 85, 85))
	local str = StringUtils.getShortStr( message.summary, LEN_DES)
	local clubDesText = cc.Label:createWithSystemFont(str, "Arial", 20, cc.size(500, 80), cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	clubDesText:setColor(cc.c3b(85, 85, 85))
	clubDesText:setPosition(cc.p(160, sizeH[2]/2))
	clubDesText:setAnchorPoint(cc.p(0,0.5))
	infoBg[2]:addChild(clubDesText)

	
	-- 所属联盟
	--[[
	local union = UIUtil.addLabelArial('联盟 ', 34, cc.p(infoW, sizeH[4]/2), cc.p(0, 0.5), infoBg[4])
	
	local union_stencil, union_Icon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(union:getPositionX()+union:getContentSize().width+90, sizeH[4]/2), parent = infoBg[4], nor = ResLib.UNION_HEAD, sel = ResLib.UNION_HEAD, listener = unionCallback})

	local url = message.union_state.union_avatar or ""
	local function funcBack( path )
		union_Icon:loadTextureNormal(path)
		union_Icon:loadTexturePressed(path)
		union_Icon:loadTextureDisabled(path)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	local unionDes = UIUtil.addLabelArial('', 30, cc.p(230, sizeH[4]/2), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)

	local union_name = UIUtil.addLabelArial("", 25, cc.p(350, sizeH[4]/2), cc.p(0, 0.5), infoBg[4])
	local unionName = message.union_state.union_name or ""
	if unionName ~= "" then
		local union_name = UIUtil.addNameByType({nameType = 3, nameStr = unionName, fontSize = 25, pos = cc.p(union:getPositionX()+union:getContentSize().width+140+20, sizeH[4]/2), parent = infoBg[4]})
	end

	-- 创建日期
	local time = os.date("%Y-%m-%d",message.create_time)
	local clubDate = UIUtil.addLabelArial('创建于'..time, 24, cc.p(viewSize.width/2, sizeH[5]/2), cc.p(0.5, 0.5), infoBg[5]):setColor(cc.c3b(102,102,102))


	local markbottom = cc.LayerColor:create(cc.c3b(1,7,24))
	markbottom:setContentSize(cc.size(display.width, 110))
	markbottom:setPosition(cc.p(0, 0))
	markbottom:ignoreAnchorPointForPosition(false)
	markbottom:setAnchorPoint(cc.p(0,0))
	self:addChild(markbottom)
	

	local label = cc.Label:createWithSystemFont("", "Marker Felt", 36)
	label:setColor(display.COLOR_WHITE)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	--ResLib.BTN_BLUE_BORDER_NEW, ResLib.BTN_BLUE_BORDER_DIS_NEW, ResLib.BTN_BLUE_BORDER,
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(viewSize.width/2, 60), cc.size(710,80), addCallBack, self)
	if CLUBINFO_TARGET == "club" then
		local str = nil
		if isJoin == 0 then
			str = '申请加入'
		else
			str = '进入俱乐部'
		end
		btn:setEnabled(true)
		btn:setTitleForState(str, cc.CONTROL_STATE_NORMAL)
		if message.union_state.show == "2" then
			union_Icon:setVisible(true)
			union_Icon:setTouchEnabled(false)
			unionDes:setString("")
		else
			union_Icon:setVisible(false)
			union_name:setString("")
			unionDes:setString("尚未加入任何联盟")
		end
	else
		if message.union_state.show == "2" then
			union_Icon:setVisible(true)
			union_Icon:setTouchEnabled(false)
			unionDes:setString("")

			btn:setEnabled(false)
			btn:setTitleForState("已加入联盟", cc.CONTROL_STATE_DISABLED)
		else
			union_Icon:setVisible(false)
			union_name:setString("")
			unionDes:setString("尚未加入任何联盟")

			btn:setEnabled(true)
			btn:setTitleForState("邀请加入联盟", cc.CONTROL_STATE_NORMAL)
		end
	end--]]

end

function ClubInfo:buildProgress( exp, pos, parent )
	local bg = cc.Scale9Sprite:create(ResLib.LOAD_BAR_BG)
	bg:setAnchorPoint(cc.p(0,0.5))
	bg:setPosition(pos)
	parent:addChild(bg)

	local sprite = cc.Sprite:create(ResLib.LOAD_BAR)

	local progress = cc.ProgressTimer:create(sprite)
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setMidpoint(cc.p(0,0))
	progress:setBarChangeRate(cc.p(1,0))
	progress:setAnchorPoint(cc.p(0,0.5))
	progress:setPosition(cc.p(0,bg:getContentSize().height/2))
	local value1 = exp.current_score or 0
	local value2 = exp.total_score or 0
	local value = (value1/value2)*100
	progress:setPercentage(value)
	bg:addChild(progress)
	return progress
end

function ClubInfo:createLayer( target )
	_clubInfo = self
	_clubInfo:setSwallowTouches()
	_clubInfo:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	isJoin = nil
	CLUBINFO_TARGET = target

	self:buildLayer()
end

return ClubInfo