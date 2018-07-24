local ViewBase = require("ui.ViewBase")
local MineAward = class("MineAward", ViewBase)

local _mineAward = nil

local imageView = nil

local curData = {}
local curTableView = nil



local function Callback(  )
	Notice.deleteMessage( 7 )
	_mineAward:removeFromParent()
end

function MineAward:buildLayer(  )

	UIUtil.addTopBar({backFunc = Callback, title = "我的奖励", parent = self})

	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	curTableView = nil
	curTableView = self:createTableView()
	local nothingLayer = self:addBgAnything()
	nothingLayer:setVisible(false)
	--请求数据
	local function response( data )
		
		local error_code = data['code']

		local dataArray  = data['data']

		if not dataArray or #dataArray <= 0 then 
			nothingLayer:setVisible(true)
			do return end
		end
		
		curData = dataArray
		--FixMe，这里最好服务器做好排序
		-- table.sort(curData, function(a, b) 
		-- 						return a["get_time"] > b["get_time"]
		-- 					end)
		curTableView:reloadData()
		nothingLayer:removeFromParent()
	end
	local tabData = {}
	XMLHttp.requestHttp("prizeList",tabData, response , PHP_POST)
end

function MineAward:addBgAnything()
	local tmpSize = cc.size(display.width, display.height-130)
	local layer = display.newLayer()
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(cc.p(0,0))
	layer:setPosition(cc.p(0,0))
	layer:setContentSize(tmpSize)
	self:addChild(layer)

	UIUtil.addPosSprite(ResLib.COM_NO_ANYTHING, cc.p(display.cx, tmpSize.height-306), layer)
	UIUtil.addLabelArial("您暂时没有获得奖励",34,cc.p(display.cx, tmpSize.height-496), cc.p(.5,1), layer, cc.c3b(170,170,170))
	UIUtil.addLabelArial("可以进入赛场选择锦标赛(MTT)",34,cc.p(display.cx, tmpSize.height-560), cc.p(.5,1), layer,cc.c3b(170,170,170))
	UIUtil.addLabelArial("体验游戏并有机会获得奖励!",34,cc.p(display.cx, tmpSize.height-624), cc.p(.5,1), layer, cc.c3b(170,170,170))
	return layer 
end
function MineAward:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
		-- body
		local idx = tableCell:getIdx() + 1
		local cellData = curData[idx]
		local mtt_id = cellData["mtt_id"]
		if not mtt_id then 
			print("mtt_id 不存在，数据过旧 or 牌局不对 ？？？？？")
			do return end
		end
		local SysActivity = require("message.SysActivity").new({["mtt_id"] = mtt_id})
 		self:addChild(SysActivity)
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		return 0, 130
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end
	local function tableCellAtindex( tableViewSender, cellIndex )
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()
			self:buildCellTmpl(cellItem, curData[index])
		end

		self:updateCellTmpl(cellItem,  curData[index])
		return cellItem
	end
	
	local tableView = cc.TableView:create(cc.size(display.width, display.height-130))
	tableView:setPosition(cc.p(0,0))
	imageView:addChild(tableView)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtindex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:setBounceable(true)
	tableView:setDelegate()
	tableView:reloadData()
	return tableView
end

function MineAward:buildCellTmpl(cellItem, itemData)
	dump(itemData, "buildCellTmpl")
	if not itemData then 
		return 
	end
	dump(itemData, "lolo");
	local name = itemData['des']
	local itemType = itemData['type']
	local code = itemData['code']
	local get_time = itemData['get_time']
	local icon_url = itemData['img'];
	local cell_state = itemData['is_processed']
	get_time = os.date("%Y年%m月%d日", get_time)
	dump(get_time, "获奖时间")

	local girdNodes = {}
	girdNodes = cellItem

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 120),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	girdNodes.cellBg = cellBg
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height


	local sp = UIUtil.scale9Sprite(cc.rect(0, 0, 0, 0), ResLib.PLAYER_BG,cc.size(146, 90), cc.p(20,height/2),cellBg)

	local label = UIUtil.addLabelArial("加载中..", 24, cc.p(20, height/2), cc.p(0, 0.5), cellBg)
	-- local awardSp = UIUtil.addPosSprite(getCellIcon(itemType), cc.p(20, height/2), cellBg, cc.p(0, 0.5))
    local function successDown(path) 
    	print(" successDown path "..tostring(path))
    	local awardSp, isSuccess = UIUtil.addPosSprite(path, cc.p(20, height/2), cellBg, cc.p(0, 0.5))
    	awardSp:setScaleX(158/awardSp:getContentSize().width)
    	awardSp:setScaleY(90/awardSp:getContentSize().height)
    	label:removeFromParent()
    	sp:removeFromParent()
    	if cell_state == 1 and not DZ_MASTER_VERSION then 
    		UIUtil.setGLProgramStateToNode(awardSp, "ShaderUIGrayScale")
    	end
    end
    local function errorDown(path) 
    	print(" errorDown path "..tostring(path))
    	local awardSp, isSuccess = UIUtil.addPosSprite(path, cc.p(20, height/2), cellBg, cc.p(0, 0.5))
    	awardSp:setScaleX(158/awardSp:getContentSize().width)
    	awardSp:setScaleY(90/awardSp:getContentSize().height)
    	label:removeFromParent()
    	sp:removeFromParent()
    	if cell_state == 1 and not DZ_MASTER_VERSION  then 
    		UIUtil.setGLProgramStateToNode(awardSp, "ShaderUIGrayScale")
    	end
    end

    local resName = CppPlat.downResFile(icon_url, successDown, errorDown, "user/mine_award_fee_20.png", "rewardIdentifier")
	
	local awardTitle = UIUtil.addLabelArial(name, 30, cc.p(200, height*2/3+10), cc.p(0, 0.5), cellBg)

	local awardCode = UIUtil.addLabelArial("验证码："..code, 30, cc.p(200, height/2), cc.p(0, 0.5), cellBg)

	local awardDate = UIUtil.addLabelArial("获奖日期："..get_time, 25, cc.p(200, height/3-10), cc.p(0, 0.5), cellBg)

	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(width-50, height/2), cellBg, cc.p(1, 0.5))

end

function MineAward:updateCellTmpl(cellItem, cellIndex)-- body
end

function MineAward:createLayer(  )
	_mineAward = self
	_mineAward:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)


	imageView = nil
	curData = {}
	curTableView = nil

	self:buildLayer()
end

return MineAward