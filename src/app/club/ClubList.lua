local ViewBase = require('ui.ViewBase')
local ClubList = class('ClubList', ViewBase)


local ClubCtrol = require("club.ClubCtrol")
local _clubList = nil
local imageView = nil

local curClubData 	= {}
local curTableView 	= nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local redPoint_bg = nil

local function addCallback( tag, sender )

	local clubMask = require("club.ClubMask").new( _clubList )
	_clubList:addChild(clubMask, 10)

end

-- 设置创世俱乐部
local function setClub(  )
	

	local layer = require("club.setClub").new()
	_clubList:addChild(layer, 10)
end

function ClubList:buildLayer(  )
	-- topBar
    UIUtil.addTopBar({title = "俱乐部", rightBtnFunc = addCallback, parent = self})

	imageView = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-230), pos=cc.p(0,100), parent=self})

	-- self:buildData()
	curClubData = ClubCtrol.getClubList(  )
	curTableView = self:createTableView( )
	curTableView:reloadData()
end

function ClubList.updateList(  )
	if curTableView then
		print("11111111111111111")
		curTableView:removeFromParent()
		curTableView = nil
		curTableView = _clubList:createTableView()
		curTableView:reloadData()
	else
		curTableView = nil
		curTableView = _clubList:createTableView()
		curTableView:reloadData()
	end
end

function ClubList:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		--print(tableViewSender.. '  tableCellTouched  ' ..tableCell)
		local index = tableCell:getIdx()+1
		self:tableCellTouch(index)
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		--print('cellSizeForTable')
		if curClubData[cellIndex+1].firstSite == 1 then
			return 0,242
		else
			return 0, 200
		end
	end

	local function numberOfCellsInTableView( tableViewSender )
		--print('numberOfCellsInTableView')
		return #curClubData
	end

	local function tableCellAtIndex( tableViewSender, cellIndex )
		--print('tableCellAtIndex')
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			-- 创建函数
			self:buildCellTmpl( cellItem )

		end
		self:updateCellTmpl( cellItem, curClubData[index] )
		-- 修改函数
		return cellItem
	end

	local tableView = cc.TableView:create( cc.size(display.width, display.height-230))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(0,0))
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

function ClubList:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem

	local function callback( sender, eventType )
		
	end
	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 200),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 42),pos=cc.p(width/2, 200), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.siteBg = siteBg

	local site = UIUtil.addLabelArial('北京', 26, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.site = site

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_001
* DESCRIPTION OF THE BUG : 【UE Integrity】Icon display error 
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]

	-- 俱乐部头像
	local stencil, clubIcon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(80,height/2), cellBg, ResLib.CLUB_HEAD_STENCIL_200, 0.6)
	girdNodes.stencil = stencil
	girdNodes.clubIcon = clubIcon

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_001
* DESCRIPTION OF THE BUG : 【UE Integrity】Icon display error 
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]
	-- 俱乐部名称、后缀
	local clubName, club_icon = UIUtil.addNameByType({nameType = 1, nameStr = "俱乐部", fontSize = 34, pos = cc.p(160, height/2+48), parent = cellBg})
	girdNodes.clubName = clubName
	girdNodes.club_icon = club_icon
	
	-- 俱乐部总人数/当前人数
	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(160, height/2), cellBg, cc.p(0, 0.5))
	local clubCount = UIUtil.addLabelArial('40/5', 22, cc.p(200, height/2), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.clubCount = clubCount

	-- 俱乐部所在地区
	local clubPlace = UIUtil.addLabelArial('北京', 22, cc.p(370, height/2), cc.p(0, 0.5), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.clubPlace = clubPlace

	local clubDes = UIUtil.addLabelArial('快来加入我们吧！', 24, cc.p(160, height/2-28), cc.p(0, 1), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.clubDes = clubDes
	-- 俱乐部消息
	local function msgCallback( sender )
		local tag = sender:getTag()
		for k,v in pairs(curClubData) do
			if tonumber(v.id) == tonumber(tag) then
				local messageLayer = require('club.ClubMsg')
				local layer = messageLayer:create()
				_clubList:addChild(layer)
				layer:createLayer( "club_list" )
				break
			end
		end
	end
	local clubMsg = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, ah = cc.p(0,0.5), pos = cc.p(width-130, height*3/4), touch = true, swalTouch = true, scale9 = true, size = cc.size(120, 100), listener = msgCallback, parent = cellBg})
	girdNodes.clubMsg = clubMsg
	local msg_icon = UIUtil.addPosSprite("common/com_icon_message.png", cc.p(clubMsg:getContentSize().width/2, clubMsg:getContentSize().height/2), clubMsg, cc.p(0.5, 0.5))
	local redPoint_bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=msg_icon:getContentSize(), pos=cc.p(width-90, height*3/4), ah=cc.p(0,0.5), parent=cellBg})
	girdNodes.redPoint_bg = redPoint_bg

end

function ClubList:updateCellTmpl( cellItem, cellData )
	local girdNodes = cellItem

	local data = cellData

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160607 _0013 
* DESCRIPTION OF THE BUG : No length limit of name
* MODIFIED BY : 王礼宁
* DATE :2016-7-16
*************************************************************************/
]]

	local name = StringUtils.getShortStr( data.club_name, 18)
	girdNodes.clubName:setString(name)

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160607 _0013 
* DESCRIPTION OF THE BUG : No length limit of name
* MODIFIED BY : 王礼宁
* DATE :2016-7-16
*************************************************************************/
]]

	local summaryStr = nil
	if data.summary == "" then
		summaryStr = "快来加入我们吧！"
	else
		summaryStr = data.summary
	end
	local summary = StringUtils.getShortStr( summaryStr, 50)
	girdNodes.clubDes:setString(summary)

	local site = ClubCtrol.getNumberOfSite(data.address)

	if data.is_create == "1" then
		girdNodes.clubMsg:setVisible(true)
		girdNodes.redPoint_bg:setVisible(true)

		girdNodes.siteBg:setVisible(true)
		girdNodes.site:setString("我创建的俱乐部")

		redPoint_bg = girdNodes.redPoint_bg

		_clubList.buildRedPoint()

	else
		girdNodes.clubMsg:setVisible(false)
		girdNodes.redPoint_bg:setVisible(false)

		if data.firstSite == 1 then
			girdNodes.siteBg:setVisible(true)
			girdNodes.site:setString(site)
		else
			girdNodes.siteBg:setVisible(false)
		end
	end
	
	if tonumber(data.union) == 0 then
		girdNodes.clubCount:setString(data.users_count .. '/' .. data.users_limit)
		UIUtil.updateNameByType( 1, girdNodes.clubName, girdNodes.club_icon )
		girdNodes.clubIcon:setTexture(ResLib.CLUB_HEAD_GENERAL)
	else
		girdNodes.clubCount:setString(data.users_count .. '/' .. "无限制")
		UIUtil.updateNameByType( 2, girdNodes.clubName, girdNodes.club_icon )
		girdNodes.clubIcon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
	end

	girdNodes.clubPlace:setString(site)
	-- girdNodes.clubPlace:setPositionX(girdNodes.clubCount:getPositionX()+girdNodes.clubCount:getContentSize().width+80)

	girdNodes.clubMsg:setTag(data.id)

	local url = data.avatar
	local function funcBack( path )
		local function onEvent(event)
			if event == "exit" then
				return
			end
		end
		girdNodes.clubIcon:registerScriptHandler(onEvent)
		local rect = girdNodes.stencil:getContentSize()
		girdNodes.clubIcon:setTexture(path)
		girdNodes.clubIcon:setTextureRect(rect)
	end
	if data.avatar ~= "" then
		ClubModel.downloadPhoto(funcBack, url, true)
	else
		if tonumber(data.union) == 0 then
			girdNodes.clubIcon:setTexture(ResLib.CLUB_HEAD_GENERAL)
		else
			girdNodes.clubIcon:setTexture(ResLib.CLUB_HEAD_ORIGIN)
		end
	end
end

function ClubList.buildRedPoint(  )
	NoticeCtrol.setNoticeNode( POS_ID.POS_20003, redPoint_bg )

	Notice.registRedPoint( 2 )
end

-- 点击cell进入俱乐部聊天
function ClubList:tableCellTouch( index )
	dump(curClubData[index])
	local tdata = curClubData[ index ]

	local MessageCtorl = require("message.MessageCtorl")
	MessageCtorl.setChatData(tdata["id"])
	MessageCtorl.setChatType(MessageCtorl.CHAT_CLUB)
	
	local Message = require('message.MessageScene')
	Message.startScene()
	
end

function ClubList:createLayer(  )

	_clubList = self
	_clubList:setSwallowTouches()
	_clubList:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	Bottom:getInstance():addBottom(4, self)

	local function onNodeEvent(event)
		if event == "enter" then
			
		elseif event == "exit" then
			NoticeCtrol.removeNoticeById(20003)
		end
    end
	self:registerScriptHandler(onNodeEvent)

	curTableView = nil
	
	redPoint_bg = nil

	self:buildLayer()
end

 --[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160722 _003
* DESCRIPTION OF THE BUG : Function erro
* MODIFIED BY : 王礼宁
* DATE :2016-8-16
*************************************************************************/
]]

function ClubList.lookClubMsg(clubId)

	print("$$$$$$$$$$$$$$$$$ClubList.lookClubMsg$$$$$$$$$$$$$$$$$$$$$$")
	local clubInfo = require('club.ClubInfoPlus')
	local layer = clubInfo:create()
	_clubList:addChild(layer)
	layer:createLayer( tonumber(clubId) )

end

 --[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGXINMIN_BUG _20160722 _003
* DESCRIPTION OF THE BUG : Function erro
* MODIFIED BY : 王礼宁
* DATE :2016-8-16
*************************************************************************/
]]

return ClubList
