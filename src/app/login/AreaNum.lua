local ViewBase = require("ui.ViewBase")
local AreaNum = class("AreaNum", ViewBase)

local _areaNum = nil
local imageView = nil
local curData = {}
local curTableView = nil
local callBackFunc = nil

local function Callback(  )
	-- _areaNum:removeFromParent()
	print("removeChildByName....1")
	local currScene = cc.Director:getInstance():getRunningScene()
	if currScene:getChildByName("AreaNum") then
		print("removeChildByName....2")
		currScene:removeChildByName("AreaNum")
	end
end

function AreaNum:initData(  )
	local areaTab = {
		{ area = "澳大利亚", code = "61", letter = "A", frist = 1 },
		{ area = "澳门", code = "853", letter = "A", frist = 0 },
		{ area = "巴西", code = "55", letter = "B", frist = 1 },
		{ area = "冰岛", code = "354", letter = "B", frist = 0 },
		{ area = "丹麦", code = "45", letter = "D", frist = 1 },
		{ area = "德国", code = "49", letter = "D", frist = 0 },
		{ area = "俄罗斯", code = "7", letter = "E", frist = 1 },
		{ area = "法国", code = "33", letter = "F", frist = 1 },
		{ area = "菲律宾", code = "63", letter = "F", frist = 0 },
		{ area = "韩国", code = "82", letter = "H", frist = 1 },
		{ area = "加拿大", code = "1", letter = "J", frist = 1 },
		{ area = "柬埔寨", code = "855", letter = "J", frist = 0 },
		{ area = "老挝", code = "856", letter = "L", frist = 1 },
		{ area = "马来西亚", code = "60", letter = "M", frist = 1 },
		{ area = "美国", code = "001", letter = "M", frist = 0 },
		{ area = "缅甸", code = "95", letter = "M", frist = 0 },
		{ area = "墨西哥", code = "52", letter = "M", frist = 0 },
		{ area = "日本", code = "81", letter = "R", frist = 1 },
		{ area = "瑞士", code = "41", letter = "R", frist = 0 },
		{ area = "台湾", code = "886", letter = "T", frist = 1 },
		{ area = "泰国", code = "66", letter = "T", frist = 0 },
		{ area = "香港", code = "852", letter = "X", frist = 1 },
		{ area = "新加坡", code = "65", letter = "X", frist = 0 },
		{ area = "意大利", code = "39", letter = "Y", frist = 1 },
		{ area = "英国", code = "44", letter = "Y", frist = 0 },
		{ area = "越南", code = "84", letter = "Y", frist = 0 },
		{ area = "中国", code = "86", letter = "Z", frist = 1 }
	}
	return areaTab
end

function AreaNum:buildLayer(  )
	
	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "选择国家和地区代码", parent = self})

	imageView = UIUtil.addImageView({touch=true, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	-- 搜索框
	local searchBg = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-50, 60), pos=cc.p(display.width/2, display.height-130-30), ah =cc.p(0.5, 1), parent=imageView})

	local searchEdit = UIUtil.addEditBox( nil, cc.size(display.width-50-120, 60), cc.p(10,searchBg:getContentSize().height/2), "国家和地区代码", searchBg )
	searchEdit:setMaxLength(18)
	searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	searchEdit:setAnchorPoint(cc.p(0, 0.5))
	local SEARCH_TEXT = ""
	local function callback( eventType, sender )
		if eventType == "began" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			SEARCH_TEXT = str
			if SEARCH_TEXT == "" then
				curData = self:initData()
				curTableView:reloadData()
			end
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )

	-- 搜索按钮
	local function ssFunc(  )
		if SEARCH_TEXT ~= "" then
			local tmpTab = self:addSearchArea(SEARCH_TEXT)
			if next(tmpTab) ~= nil then
				curData = tmpTab
				curTableView:reloadData()
			else
				ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "没有找到相关国家，请更换搜索条件再试。"})
			end
		end
	end
	UIUtil.addImageBtn({norImg = "common/s_ss_icon.png", selImg = "common/s_ss_icon.png", disImg = "common/s_ss_icon.png", ah = cc.p(1, 0.5), pos = cc.p(searchBg:getContentSize().width-1, searchBg:getContentSize().height/2), touch = true, listener = ssFunc, parent = searchBg})
	
	curTableView = self:createTableView()
	curTableView:reloadData()
end

function AreaNum:addSearchArea( area )
	local areaTab = self:initData(  )
	local tab = {}
	local str = tostring(area)
	for k,v in pairs(areaTab) do
		if str == v.area then
			tab = {}
			tab[#tab+1] = v
			break
		elseif k == #areaTab then
			for key,val in pairs(areaTab) do
				if str == val.code then
					tab ={}
					tab[#tab+1] = val
					break
				end
			end
		end
	end
	return tab
end

function AreaNum:createTableView(  )
	local function tableCellTouched( tableViewSender, tableCell )
	
	end
	local function cellSizeForTable( tableViewSender, cellIndex )
		if curData[cellIndex+1].frist == 1 then
			return 0, 140
		else
			return 0, 98
		end
	end
	local function numberOfCellsInTableView( tableViewSender )
		return #curData
	end
	local function tableCellAtIndex( tableViewSender, cellIndex )
		local index = cellIndex + 1
		local cellItem = tableViewSender:dequeueCell()
		if cellItem == nil then
			cellItem = cc.TableViewCell:new()

			self:buildCellTmpl(cellItem)
		end
		self:updateCellTmpl(cellItem, index)

		return cellItem
	end

	local tableView = cc.TableView:create(cc.size(display.width, display.height - 250))
	tableView:setPosition(cc.p(0, 0))
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	imageView:addChild(tableView)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
	tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	tableView:reloadData()
	tableView:setDelegate()
	return tableView
	
end

function AreaNum:buildCellTmpl( cellItem )
	local girdNodes = {}
	girdNodes = cellItem
	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 98),pos=cc.p(0,0), ah=cc.p(0,0), parent=cellItem})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	local function cellFunc( sender )
		local tag = sender:getTag()
		-- print("tag: ".. tag)
		-- print("code: "..curData[tag].code)
		-- dump(curData[tag])
		callBackFunc(curData[tag].code)
		Callback()
	end
	local cellBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0, 0), pos = cc.p(0,0), touch = true, scale9 = true, size = cc.size(width, height), listener = cellFunc, parent = cellItem})
	girdNodes.cellBtn = cellBtn

	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 42),pos=cc.p(width/2, 98), ah=cc.p(0.5,0), parent=cellItem})
	girdNodes.siteBg = siteBg

	local site = UIUtil.addLabelArial('北京', 27, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.site = site

	local name = UIUtil.addLabelArial('', 34, cc.p(20, height/2), cc.p(0,0.5), cellBg)
	girdNodes.name = name

	local code = UIUtil.addLabelArial('', 30, cc.p(width-20, height/2), cc.p(1,0.5), cellBg):setColor(ResLib.COLOR_GREY1)
	girdNodes.code = code

end

function AreaNum:updateCellTmpl( cellItem, cellIndex )
	local girdNodes = cellItem
	local data = curData[cellIndex]

	if data.frist == 1 then
		girdNodes.siteBg:setVisible(true)
		girdNodes.site:setString(data.letter)
	else
		girdNodes.siteBg:setVisible(false)
		girdNodes.site:setString('')
	end

	girdNodes.cellBtn:setTag(cellIndex)
	girdNodes.name:setString(data.area)
	girdNodes.code:setString("+"..data.code)
end

function AreaNum:createLayer( func )
	_areaNum = self
	_areaNum:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	imageView = nil
	callBackFunc = nil
	curData = {}
	curData = self:initData()
	callBackFunc = func

	-- dump(curData)
	self:buildLayer()
end

return AreaNum