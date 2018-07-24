local bindsLayer = class("bindsLayer", function (  )
	return cc.LayerColor:create(cc.c4b(10, 10, 10, 200))
end)

local tableBg = nil
local curData = {}
local target = nil
local blindData = {}

function bindsLayer:ctor( cardMode, params )
	tableBg = nil

	target = cardMode
	curData = {}
	local data = require("common.bindsArr")
	if cardMode == "mtt" or cardMode == "status" then
		if params then
			blindData = params
		end
		curData = data["mtt"]
	elseif cardMode == "sng" then
		curData = data["sng"]
	elseif cardMode == "hall" then
		if params then
			blindData = params
		end
		curData = data["hall"]
	end
	self:buildBindStruct()
	self:touchFun()
end

function bindsLayer:buildBindStruct(  )
	local sp_w = display.width-100
	local sp_h = display.height-200
	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=self})
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	tableBg = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(sp_w-60, sp_h-150), pos=cc.p(sp_w/2, 30), ah =cc.p(0.5, 0), parent=bgSp3})

	local title = UIUtil.addLabelArial('', 36, cc.p(sp_w/2, sp_h-50), cc.p(0.5, 1), bgSp3)
	local bindBg = UIUtil.addImageView({image = "common/set_card_MTT_bind_bg.png", touch=false, scale=true, size=cc.size(tableBg:getContentSize().width, 50), pos=cc.p(tableBg:getContentSize().width/2, tableBg:getContentSize().height-10), ah =cc.p(0.5, 1), parent=tableBg})
	local bindTitle = {}
	if target == "mtt" or target == "status" or target == "hall" then
		bindTitle = {"级别", "盲注", "前注"}
		title:setString("MTT盲注结构")
	elseif target == "sng" then
		bindTitle = {"级别", "盲注"}
		title:setString("SNG盲注结构")
	end
	for i=1, #bindTitle do
		UIUtil.addLabelArial(bindTitle[i], 30, cc.p(bindBg:getContentSize().width*(2*i-1)/(2*(#bindTitle)), bindBg:getContentSize().height/2), cc.p(0.5, 0.5), bindBg):setColor(cc.c3b(142, 199, 223)):enableBold()
	end

	-- 关闭
	local function closeLayer(  )
		self:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/set_card_MTT_close.png", selImg = "common/set_card_MTT_close_height.png", ah = cc.p(0.5, 0.5), pos = cc.p(sp_w-10, sp_h-10), touch = true, listener = closeLayer, parent = bgSp3})

	if target == "status" or target == "hall" then
		-- curData = require("common.bindsArr").["mtt"]
		for i,v in ipairs(curData) do
			if i < tonumber(blindData.blind or 6) then
				curData[i]["rebuy"] = 1
				curData[i]["addbuy"] = 0
				curData[i]["stop"] = 0
			elseif i == tonumber(blindData.blind or 6) then
				curData[i]["rebuy"] = 0
				curData[i]["addbuy"] = 1
				curData[i]["stop"] = 1
			else
				curData[i]["rebuy"] = 0
				curData[i]["addbuy"] = 0
				curData[i]["stop"] = 0
			end
		end
		self:addMTTbindUI()
	end

	self:createTableView()
end

function bindsLayer:addMTTbindUI(  )
	local bg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(tableBg:getContentSize().width, 180), pos=cc.p(tableBg:getContentSize().width/2, 30), ah =cc.p(0.5, 0), parent=tableBg})

	local blind = blindData.blind or 6
	local rebuy = tonumber(blindData.rebuy) or 0
	local addbuy = tonumber(blindData.addbuy) or 0
	
	if rebuy == (-1) then
		rebuy = "无限制)"
	else
		rebuy = rebuy.."次)"
	end

	local sp_icon 	= {"card_mtt_bind_rebuy_icon.png", "card_mtt_bind_addbuy_icon.png", "card_mtt_bind_stop_icon.png"}
	local sp_text 	= {"重购", "增购", "终止报名"}
	local sp_des 	= {"1-"..tostring(blind-1).."盲注级别("..rebuy, "第"..tostring(blind).."盲注级别("..addbuy.."次)", "第"..tostring(blind).."盲注级别"}

	local sp1 = {}
	local sp2 = {}
	local sp3 = {}
	for i=1,3 do
		sp1[i] = UIUtil.addPosSprite("common/"..sp_icon[i], cc.p(150, 180-(i-1)*50-70), bg, cc.p(1, 0.5))
		sp2[i] = UIUtil.addLabelArial(sp_text[i]..": ", 30, cc.p(sp1[i]:getPositionX()+10, 180-(i-1)*50-70), cc.p(0, 0.5), bg)
		sp3[i] = UIUtil.addLabelArial(sp_des[i], 30, cc.p(sp2[i]:getPositionX()+sp2[i]:getContentSize().width+10, 180-(i-1)*50-70), cc.p(0, 0.5), bg)
	end
end

function bindsLayer:createTableView( bg )
	local function tableCellTouched( tableViewSender, tableCell )
		
	end

	local function cellSizeForTable( tableViewSender, cellIndex )
		--print('cellSizeForTable')
		return 0, 60
	end

	local function numberOfCellsInTableView( tableViewSender )
		--print('numberOfCellsInTableView')
		return #curData
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
		self:updateCellTmpl( cellItem, index )
		-- 修改函数
		return cellItem
	end
	local sizeH = 0
	local posH = 0
	if target == "mtt" or target == "sng" then
		sizeH = 80
		posH = 10
	elseif target == "status" or target == "hall" then
		sizeH = 280
		posH = 210
	end

	local tableView = cc.TableView:create( cc.size(tableBg:getContentSize().width-20, tableBg:getContentSize().height-sizeH))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setPosition(cc.p(10,posH))
	tableBg:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

function bindsLayer:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(tableBg:getContentSize().width, 60),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local level = UIUtil.addLabelArial('100', 30, cc.p(width/6-20, height/2), cc.p(0.5, 0.5), cellBg):setColor(display.COLOR_WHITE)
	girdNodes.level = level

	-- 终止报名
	local stopSp = UIUtil.addPosSprite("common/card_mtt_bind_stop_icon.png", cc.p(width/6-40, height/2), cellBg, cc.p(1, 0.5))
	girdNodes.stopSp = stopSp

	-- 重购
	local rebuySp = UIUtil.addPosSprite("common/card_mtt_bind_rebuy_icon.png", cc.p(width/6+30, height/2), cellBg, cc.p(1, 0.5))
	girdNodes.rebuySp = rebuySp

	-- 增购
	local addbuySp = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(width/6+30, height/2), cellBg, cc.p(1, 0.5))
	girdNodes.addbuySp = addbuySp

	local bindStr = UIUtil.addLabelArial('10/20', 30, cc.p(width/2-20, height/2), cc.p(0.5, 0.5), cellBg):setColor(display.COLOR_WHITE)
	girdNodes.bindStr = bindStr

	local bindStr1 = UIUtil.addLabelArial('10', 30, cc.p(width*5/6-10, height/2), cc.p(0.5, 0.5), cellBg):setColor(display.COLOR_WHITE)
	girdNodes.bindStr1 = bindStr1
end

function bindsLayer:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	girdNodes.level:setString(tostring(cellIndex))
	
	if target == "mtt" or target == "status" or target == "hall" then
		girdNodes.bindStr:setString(data.bind.."/"..data.bind*2)

		girdNodes.bindStr1:setString(data.ori_bind)
	elseif target == "sng" then
		girdNodes.level:setPositionX(tableBg:getContentSize().width/4-20)
		girdNodes.bindStr:setString("")
		girdNodes.bindStr1:setString(data.bind.."/"..data.bind*2)
		girdNodes.bindStr1:setPositionX(tableBg:getContentSize().width*3/4-10)
	end

	if target == "mtt" or target == "sng" then
		girdNodes.stopSp:setVisible(false)
		girdNodes.rebuySp:setVisible(false)
		girdNodes.addbuySp:setVisible(false)
	elseif target == "status" or target == "hall" then
		if data.rebuy == 1 then
			girdNodes.rebuySp:setVisible(true)
		else
			girdNodes.rebuySp:setVisible(false)
		end
		if data.addbuy == 1 then
			girdNodes.addbuySp:setVisible(true)
		else
			girdNodes.addbuySp:setVisible(false)
		end
		if data.stop == 1 then
			girdNodes.stopSp:setVisible(true)
		else
			girdNodes.stopSp:setVisible(false)
		end
	end

end

function bindsLayer:touchFun(  )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		print('触摸屏蔽*************')
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch, event )
		self:removeFromParent()
	end, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return bindsLayer