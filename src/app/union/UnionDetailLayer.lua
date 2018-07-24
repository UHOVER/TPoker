--
-- Author: Taylor
-- Date: 2017-08-01 14:33:40
-- 联盟详情

local ViewBase = require("ui.ViewBase")
local UnionDetailLayer = class("UnionDetailLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")
local thisView = nil

local _size = cc.size(display.width, display.height - 130 - 90)
local _pageSize = cc.size(750, 291)
local _cellsize = cc.size(362, 294)
--ui node
local _pageView = nil
local _pageIndicators = {}

local _unionIcon = nil

local _createTimeTf = nil
local _createUserTf = nil
local _adminNumTf = nil
local _unionNameTf = nil
local _unionIdTf = nil
local _clubnumTf = nil
local _clubNumSection = nil
local unionDetailEditNode = nil
local _nothingSp = nil

local _lastContainerY = 0
local _listView = nil
local _reuseItemOffset = nil
local _unionMemberNum = 0 

local _recylceNum = 4 --8个俱乐部才开启循环利用模式
local _interval = 1/5 -- 1秒10帧
local _bufferZone = 289


local refresUI = nil

local redPoint_bg = nil
-- 设置头像回调
local function iconCallback( tag, sender )
	print("点击头像")
	-- local function funcBack( iconName, iconPath )
	-- 	club_Avatar = iconName
	-- 	print(club_Avatar)
	-- 	_clubNew:buildIcon(iconPath)
	-- end
	-- ClubModel.buildPhoto( 0, funcBack, _clubNew )
end

local function updateUnionBg()
	local unionInfo = UnionCtrol.getUnionDetail()
	_pageView:removeAllPages()
	for i,v in ipairs(_pageIndicators) do
		if v then 
			_pageView:removeProtectedChild(v)
		 end
	end
	_pageIndicators = {}
	local imgs = unionInfo.union_background_img
	local width  = 20 * #imgs
	local posx = (display.width - width)/2
	for i = 1, #imgs do 
		local layout = ccui.Layout:create()
    	layout:setClippingEnabled(true)
    	layout:setContentSize(_pageView:getContentSize())
		local widget = ccui.ImageView:create(ResLib.COM_DEFUALT_PHOTO)
						:align(cc.p(0.5,0),display.cx,0):addTo(layout)
		widget:setContentSize(display.width, _pageView:getContentSize().height)

		_pageView:addPage(layout)
		local function funcBack(path)
			widget:loadTexture(path, 0)
		end
		local function ferror()
		end
		ClubModel.downloadPhoto(funcBack, imgs[i], false, ferror)
		local point = display.newSprite("bg/circle_point_bg.png", posx + (i-1)*20 + 10, _pageView:getContentSize().height - 21)
		_pageView:addProtectedChild(point, 1000000)
		_pageIndicators[i] = point
		if i == 1 then 
			point:setTexture("bg/circle_point_show.png") 
		end
	end
end

--联盟编辑
local function unionEditHandler()
 	local editNode =require('union.UnionEdit').show()
 	local function updateUI()
		local unionInfo = UnionCtrol.getUnionDetail()
		local avatar = unionInfo.union_avatar
		local name = unionInfo.union_name
		_unionNameTf:setString(name)
		local function callback(path)
			_unionIcon:loadTextureNormal(path)
			_unionIcon:loadTexturePressed(path)
			_unionIcon:loadTextureDisabled(path)
		end
		CppPlat.downResFile(avatar, callback, callback, ResLib.UNION_HEAD, 101)
		updateUnionBg()
	end
	editNode:onNodeEvent("exitTransitionStart", updateUI)
end
--管理员设置
local function adminSetHandler()
	local function updateUI()
		local unionInfo = UnionCtrol.getUnionDetail()
		_adminNumTf:setString(unionInfo.union_managers)
	end
	local optLayer = require("union.AdminOptLayer").show()
	optLayer:onNodeEvent("exitTransitionStart", updateUI)
end
--联盟消息
local function unionMsgHandler()
	local scene = cc.Director:getInstance():getRunningScene()
	local messageLayer = require('club.ClubMsg')
	local layer = messageLayer:create()
	scene:addChild(layer, StringUtils.getMaxZOrder(scene))
	layer:createLayer( "union" )

	layer:onNodeEvent("exitTransitionStart", function() 
				if refresUI then 
					_listView:removeAllChildren()
					refresUI()
				end
	 		end)	
end
--活跃统计
local function activeStatisticHandler()
	local scene = cc.Director:getInstance():getRunningScene()
	
	local ActivityCtorl = require("common.ActivityCtorl")
	ActivityCtorl.setActFlag(false)
	
	local union_id = UnionCtrol.getUnionDetail()["union_id"]
	ActivityCtorl.dataStatGroupActivity(ActivityCtorl.ACT_UNION, union_id, function (  )
		local actTotal = require("common.ActivityTotal")
		local scene = cc.Director:getInstance():getRunningScene()
		local layer = actTotal:create()
		scene:addChild(layer, StringUtils.getMaxZOrder(scene))
		layer:createLayer()
	end)
end

local function clickClubInfo(target)
	local clubDataArr = UnionCtrol.getUnionCMember()
	local tag = target:getTag()
	local cData = clubDataArr[tag]
	local clubEditView = require("union.UnionClubAuthEdit").show(nil, cData)
	clubEditView:onNodeEvent("exitTransitionStart", function()
				print("clubEditView", tostring(clubEditView.flagAction))
				-- if clubEditView.action == "delete" then 
					thisView:refreshContent()
				-- end
		end)
end


function UnionDetailLayer:ctor()
	thisView = self
	redPoint_bg = nil
	self:setContentSize(_size)
	self:enableNodeEvents()
	self:initData()
	self:initUI()
end

function UnionDetailLayer:onEnter()
	-- self:onUpdate(callback)
end

function UnionDetailLayer:onExit()
	self:unscheduleUpdate()
	NoticeCtrol.removeNoticeById(30003)

	 _pageView = nil
	 _pageIndicators =nil

	 _unionIcon = nil

	 _createTimeTf = nil
	 _createUserTf = nil
	 _adminNumTf = nil
	 _unionNameTf = nil
	 _unionIdTf = nil
	 _clubnumTf = nil
	 _clubNumSection = nil
	 unionDetailEditNode = nil
	 _lastContainerY = 0
	 _listView = nil
	 _reuseItemOffset = nil
	 _unionMemberNum = 0 
	 thisView = nil
end


function UnionDetailLayer:initData()
	self.lastTime = 0
	_lastContainerY = 0 
	_pageIndicators = {}
end

function UnionDetailLayer:initUI()
	--设置上半部分
	self:initUnionDesUI()
	--设置中部
	self:initUnionSetting()
	--俱乐部
	self:initClubDetail()
	--更新
	refresUI()
end

function UnionDetailLayer:initUnionDesUI()

	local unionData = UnionCtrol.getUnionDetail()
	local pagelist = unionData.unionbgs
	local posy = _size.height - _pageSize.height

	unionDetailEditNode = cc.CSLoader:createNodeWithVisibleSize("scene/UnionDetailEdit.csb")
	unionDetailEditNode:setPosition(cc.p(0, posy))
	self:addChild(unionDetailEditNode,10)

	_pageView = unionDetailEditNode:getChildByName("BgPageView")
	_unionIcon = unionDetailEditNode:getChildByName("unionicon")
	_createTimeTf = unionDetailEditNode:getChildByName("tfdate")
	_createUserTf = unionDetailEditNode:getChildByName("tfuser")
	_adminNumTf = unionDetailEditNode:getChildByName("tfAdmin")
	_unionNameTf = unionDetailEditNode:getChildByName("unionName")
	_unionIdTf = unionDetailEditNode:getChildByName("tfId")
	_clubnumTf = unionDetailEditNode:getChildByName("clubnum")
	-- 头像
	local headNode = display.newNode():addTo(unionDetailEditNode):move(_unionIcon:getPositionX(), _unionIcon:getPositionY())
	local  stencil, clubIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.5, pos = cc.p(0,0), parent = headNode, nor = ResLib.UNION_HEAD, sel = ResLib.UNION_HEAD, listener = iconCallback})
	_unionIcon:removeFromParent()
	_unionIcon = clubIcon

	local sharebtn = unionDetailEditNode:getChildByName("sharebtn"):move(_unionIdTf:getPositionX()+_unionIdTf:getContentSize().width/2 + 10, _unionIdTf:getPositionY())
	sharebtn:touchEnded(function() 
		local _url = SHARE_URL
		local contentStr = Single:playerModel():getPName()..'邀请您加入“'..unionData.union_name..'”'.."联盟,ID号为:"..unionData.union_no
		DZWindow.shareDialog(DZWindow.SHARE_URL, {title = "一起来玩"..DISPLAY_G_NAME, content = contentStr, url = _url})
	 end)

	_pageView:onEvent(function(evt) 
		if evt.name == "TURNING" then 
			local imgs = unionData.union_background_img
			for i = 1, #imgs do 
				local index = evt.target:getCurrentPageIndex()
				if i == index + 1 then 
					_pageIndicators[i]:setTexture("bg/circle_point_show.png")
				else 
					_pageIndicators[i]:setTexture("bg/circle_point_bg.png")
				end
			end
		end
	end)
end

function UnionDetailLayer:initUnionSetting()
	local from = UnionCtrol.getVisitFrom()
	if from ~= UnionCtrol.mine_union then 
		return 
	end

	local handls = {
						[10] = unionEditHandler,
						[20] = adminSetHandler,
						[30] = unionMsgHandler,
						[40] = activeStatisticHandler
			    	}
	local function clickUnionHandler(sender)
		print("联盟管理:"..tostring(sender:getTag()))
		local fuc = handls[sender:getTag()]
		fuc()
	end
	
	local isHeader = UnionCtrol.isStatus(UnionCtrol.STATUS_HEAD)
	local isAdd = UnionCtrol.isHasAuth(UnionCtrol.Auth_ADD_MEM)

	local settingText = {"联盟编辑", 10, "管理员设置", 20, "消息", 30, "活跃统计", 40}
	local settingIcon = { ResLib.UNION_EDIT_BTN, ResLib.UNION_ADMIN_BTN,  ResLib.UNION_MSG_BTN, ResLib.UNION_ACTIVE_BTN }
	local settingPos = {95, 283, 470, 655}
	local settingEnable = {isHeader, isHeader, isAdd, isHeader}
	local bgColor = UIUtil.addSection({bcolor = cc.c3b(27,32,46), pos = cc.p(0, _size.height-_pageSize.height-42), parent = self, text = "联盟管理", tcolor = ResLib.COLOR_GREY1})

	local bgColor2 = cc.LayerColor:create(cc.c3b(1,7,21))
	bgColor2:setPosition(cc.p(0, _size.height-_pageSize.height-42-150))
	bgColor2:setContentSize(cc.size(display.width, 150))
	self:addChild(bgColor2,9)
	
	for i=1, (#settingText)/2 do
		local icon = UIUtil.addPosSprite(settingIcon[i], cc.p(settingPos[i], 107), bgColor2)
		local text = UIUtil.addLabelArial(settingText[i*2 - 1], 30, cc.p(settingPos[i], 38), cc.p(.5,.5), bgColor2)
		local btn = UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, nil, cc.p(settingPos[i],73), cc.size(146,131), clickUnionHandler, bgColor2)
		btn:setTag(settingText[i * 2])

		local isEnable = settingEnable[i]
		btn:setTouchEnabled(isEnable)
		btn:setEnabled(isEnable)
		if isEnable then 
		 	icon:setColor(display.COLOR_WHITE)
		 	text:setColor(display.COLOR_WHITE)
		else 
			icon:setColor(ResLib.COLOR_GREY)
			text:setColor(ResLib.COLOR_GREY)
		end
		if i == 3 then
			redPoint_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(btn:getContentSize().width-80, btn:getContentSize().height-30), pos=cc.p(btn:getContentSize().width/2 + 17,btn:getContentSize().height/2+19), ah=cc.p(0.5, 0.5), parent= btn})
		end
	end

	-- 添加红点
	self:buildRedPoint()
end

function UnionDetailLayer:buildRedPoint(  )
	-- 红点提示联盟
    NoticeCtrol.setNoticeNode( POS_ID.POS_30003, redPoint_bg)
    Notice.registRedPoint( 3 )
end

------------------------------------
-- 生成俱乐部UI数据
------------------------------------

local function updateCell(cell, index, data)
	print(tostring(cell))
	if not cell  or not data then 
		cell:getParent():setVisible(false)
		return
	end
	cell:getParent():setVisible(true)
	cell:getParent():setTag(index)
	local clubiconNode = cell:getChildByName("clubicon")--俱乐部icon
	local clubname = cell:getChildByName("clubname")--俱乐部name
	local clubId = cell:getChildByName("clubId") --俱乐部ID
	local peopleNum = cell:getChildByName("peopleNum")--俱乐部人数
	local creditNum = cell:getChildByName("creditNumTf")--信用额度
	local usingNum = cell:getChildByName("usingNum")--使用中
	local joinTimeTitle = cell:getChildByName("joinTimeTitle")--加入的时间
	clubname:setString(data.club_name or "")
	clubId:setString("ID:"..data.club_no or "")
	peopleNum:setString(data.club_limit or "")
	creditNum:setString(data.club_credit or 0)
	usingNum:setString(data.club_using or 0)
	joinTimeTitle:setString(os.date("加入时间:%Y/%m/%d",data.club_join_time) or "00/00/00")
	local  stencil, clubIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.5, pos = cc.p(0,0), parent = clubiconNode, nor = ResLib.CLUB_HEAD_GENERAL, sel = data.club_avatar, listener = iconCallback})
	clubIcon:setTouchEnabled(false)
	local function callback(respath) 
		clubIcon:loadTextureNormal(respath)
		clubIcon:loadTexturePressed(respath)
		clubIcon:loadTextureDisabled(respath)
    end
    CppPlat.downResFile(data.club_avatar, callback, function(resPath)end, ResLib.CLUB_HEAD_GENERAL, 100)
end

local function generateCell(itemData, index, listView)
	 local isTouch = UnionCtrol.getVisitFrom() == UnionCtrol.mine_union
	 local item = ccui.Layout:create()
	 item:setContentSize(cc.size(750,294))
	 listView:pushBackCustomItem(item)
	 item.coms = {}
	 for i = 1, 2 do
	 	local data = itemData[i]
	 	local panel = cc.CSLoader:createNodeWithVisibleSize("scene/ClubDetailCell.csb")
 		local subLayout = ccui.Layout:create()
 		subLayout:setContentSize(_cellsize)
 		subLayout:addChild(panel)
 		subLayout:setPosition(10*i + _cellsize.width*(i-1), 0)
 		subLayout:setTouchEnabled(isTouch)
 		subLayout:touchEnded(clickClubInfo)
 		item:addChild(subLayout)

 		item:setTag(index-1)
 		item.coms[i] = panel
 		updateCell(panel, (index-1)*2+i, data)
	 end
end

function UnionDetailLayer:initClubDetail()
	local offsety = -485-42
	local from = UnionCtrol.getVisitFrom()
	if from ~= UnionCtrol.mine_union then
		offsety =  -_pageView:getContentSize().height - 42
	end

	local bgColor = UIUtil.addSection({bcolor = cc.c3b(33,38,50), pos = cc.p(0, _size.height+offsety), parent = self, text = "俱乐部", tcolor = ResLib.COLOR_GREY1})
	bgColor:setLocalZOrder(9)
	_clubNumSection = UIUtil.addLabelArial("-/无上限",26,cc.p(display.width-20, 42/2), cc.p(1,.5), bgColor, ResLib.COLOR_GREY1)
	
	local listSize = cc.size(display.width, _size.height+offsety)
	local listViewParams = {
		parent = self, margin = 0, pos= cc.p(0,0), size = listSize, bounce = true,
		dir = ccui.ScrollViewDir.vertical, magnetic = 0, gravity = ccui.ListViewGravity.centerVertical,
		onscroll = handler(self, self.onScroll)
	}
	_listView = UIUtil.addListView(listViewParams)

	_nothingSp = display.newNode():addTo(self):move(display.cx, _size.height + offsety - 96)
	local sp = UIUtil.addPosSprite(ResLib.COM_NO_ANYTHING, cc.p(0,0), _nothingSp, cc.p(.5,1))
	UIUtil.addLabelArial("您暂时没有获得奖励", 34, cc.p(0, sp:getPositionY() - sp:getContentSize().height - 82), cc.p(.5,1), _nothingSp, cc.c3b(170,170,170))
end

local function viewDisplayByData()
	--更新联盟信息
	local unionData = UnionCtrol.getUnionDetail()
	local unionMember = UnionCtrol.getUnionCMember()
	local unionHeadUrl = unionData.union_avatar
	local function callback(respath) 
    		_unionIcon:loadTextureNormal(respath)
			_unionIcon:loadTexturePressed(respath)
			_unionIcon:loadTextureDisabled(respath)
    	end
    CppPlat.downResFile(unionHeadUrl, callback, function(resPath)end, ResLib.UNION_HEAD, 100)

    updateUnionBg()
	_createTimeTf:setString(os.date("%Y/%m/%d",unionData.createtime))
	_createUserTf:setString(unionData.createhost or "")
	_adminNumTf:setString(unionData.union_managers or "0/0")
	_unionNameTf:setString(unionData.union_name or "")
	_unionIdTf:setString("联盟ID:"..tostring(unionData.union_no))
	_clubnumTf:setString((unionData.union_club_num.."/"..unionData.union_limit) or "0/无上限俱乐部")
	_clubNumSection:setString((unionMember and #unionMember) or 0)
	unionDetailEditNode:getChildByName("sharebtn"):move(_unionIdTf:getPositionX()+_unionIdTf:getContentSize().width/2 + 10, _unionIdTf:getPositionY())
	--调整坐标
	local clubIcon = unionDetailEditNode:getChildByName("clubicon")
	local  iconW = clubIcon:getContentSize().width
	local cX, numW = _clubnumTf:getPositionX(), _clubnumTf:getContentSize().width
	local posCx = (display.width - iconW - numW - 10 )/2
	clubIcon:setPositionX(posCx + iconW/2)
	_clubnumTf:setPositionX(posCx + 10 + iconW + numW/2)
	
	_listView:removeAllItems()
	_unionMemberNum  =  ((#unionMember % 2 == 0) and #unionMember/2) or (math.ceil(#unionMember/2))
	local totalHeight = _unionMemberNum * _cellsize.height
	_reuseItemOffset = _recylceNum * _cellsize.height
	print("成员奇数偶数".._unionMemberNum, totalHeight, _reuseItemOffset,_bufferZone)

	--更新俱乐部信息
	for i = 1, _unionMemberNum do 
		if i <= _recylceNum then 
			local data1 = unionMember[i*2-1]
			local data2 = unionMember[i*2]
			local data = {[1] = data1, [2]= data2}
			generateCell(data, i, _listView)
		end
	end
	_listView:forceDoLayout()
	_listView:setInnerContainerSize(cc.size(display.width, totalHeight))
	_lastContainerY = _listView:getInnerContainerPosition().y
	
	_nothingSp:setVisible( _unionMemberNum <= 0 )
end
refresUI = viewDisplayByData

function UnionDetailLayer:onScroll(event)
	-- print("listview event:"..tostring(event.name), "obj:",tostring(event.target))

end

function UnionDetailLayer:hideContent()
	self:unscheduleUpdate()
end

function UnionDetailLayer:showContent()
	-- _pageView
	self:refreshContent()
	if _unionMemberNum > _recylceNum then 
		self:onUpdate(handler(self, self.update))
	end
end

function UnionDetailLayer:refreshContent()
	local visitFrom = UnionCtrol.getVisitFrom()
	if visitFrom == UnionCtrol.club_union then
		local unionId = UnionCtrol.getUnionDetail()["union_id"]
		local clubId = UnionCtrol.getUnionCMember()[1]["club_id"]
		UnionCtrol.requestDetailUnionForClub(clubId, unionId, refresUI)
	else 
		UnionCtrol.requestDetailUnion(refresUI) 
	end
end
-- function UnionDetailLayer:updateItem(itemID, i)
-- 	 -- //If you have  the item ID and templateID, you could fill in the data here
-- 	local itemTemplate = _listView:getItem(i)
-- 	if itemID <= _unionMemberNum then 
	 	
-- 	end
-- end

function UnionDetailLayer:update(dt)
	if not _listView then  return end

	local memNumber = _unionMemberNum
	if not memNumber or memNumber <= 0 then return end

	self.lastTime = self.lastTime + dt
	-- print('self.lastTime:',self.lastTime, "_interval:", _interval, "dt", dt)
	if self.lastTime > _interval then 
		self.lastTime = 0
		return 
	end


	local totalHeight = _listView:getInnerContainerSize().height
	local viewPosy = _listView:getInnerContainerPosition().y
	local viewHeight = _listView:getContentSize().height
	local isDown =  viewPosy - _lastContainerY < 0
	local items = _listView:getItems()
	local unionMember =  UnionCtrol.getUnionCMember() 
	for i = 1, _recylceNum do
		if i < memNumber then 
			
			local item = _listView:getItem(i-1)
			local itemPos = _listView:convertToNodeSpaceAR(item:getParent():convertToWorldSpaceAR(cc.p(item:getPositionX(), item:getPositionY())))
			itemPos = itemPos.y
			
			if isDown then  -- 向下滑动
			  if itemPos < -_bufferZone and (item:getPositionY() + _reuseItemOffset) < totalHeight then
                 local itemID = item:getTag() - #items
                 item:setPositionY(item:getPositionY() + _reuseItemOffset)
                 -- print("itemPos = %f, itemID = %d, tempateID = %d", itemPos, itemID, i-1)
                 item:setTag(itemID)
                 updateCell(item.coms[1], itemID*2+1, unionMember[itemID*2+1])
                 updateCell(item.coms[2], itemID*2+2, unionMember[itemID*2+2])	
              end
			else --向上滑动
				-- print("i:" ,i, "size:", #(_listView:getItems()), _recylceNum, memNumber,"isDown:"..tostring(isDown))
				-- print("itemPos:"..tostring(itemPos), "viewPosy:",viewPosy,"viewHeight:",viewHeight,totalHeight, tostring(item))
			  if itemPos > _bufferZone + viewHeight and (item:getPositionY() - _reuseItemOffset >= 0) then 
			  	 local itemID = item:getTag() + #items
			  	 item:setPositionY(item:getPositionY() - _reuseItemOffset)
			  	 item:setTag(itemID)
			  	 -- print("itemPos = %f, itemposy=%f, itemID = %d, tempateID = %d,", itemPos, item:getPositionY(), itemID, i-1)
			  	 updateCell(item.coms[1], itemID*2+1, unionMember[itemID*2+1])
                 updateCell(item.coms[2], itemID*2+2, unionMember[itemID*2+2])
			  end
			end
		end
	end
	_lastContainerY = viewPosy
end


return UnionDetailLayer
