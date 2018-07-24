--
-- Author: Taylor
-- Date: 2017-08-03 10:33:30
--

local ViewBase = require("ui.ViewBase")
local SearchAdminLayer = class("SearchAdminLayer", ViewBase)
local UnionCtrol = require("union.UnionCtrol")
local curTableView = nil
local cSize = cc.size(display.width, 144)
local _datasouce = nil
local _selectAdmin = nil
local _lev = 1
local _admin_count = 0 --现在已经拥有的联盟管理员数量
local _delegate = nil --代理
function SearchAdminLayer:ctor()
	self:initData()
	self:initUI()

	local function sureHandle()
		local function response(data) 
			print "添加成功"
			local added_admin = _selectAdmin
			if _delegate and _delegate.addAdmin then 
				_delegate.addAdmin(added_admin, _lev)
				_delegate =nil
			end
			self:removeFromParent()
			--弹出提示
		-- if #_selectAdmin ~= added_admin then 
		-- 	ViewCtrol.showTick({content = "已添加"})
		-- else
		-- end
		end
		UnionCtrol.requestAddAdmin(_selectAdmin, _lev, response)
	end
	local function saveHandler()
		if #_selectAdmin <= 0 then 
			ViewCtrol.showTick({content = "请选择管理员"})
			return 
		end
		ViewCtrol.popHint({content = "确定要添加"..#_selectAdmin.."管理员吗?", sureFunBack = sureHandle,bgSize = cc.size(display.width-100, 300)})
	end
	local function backHandler()
		_selectAdmin = nil
		self:removeFromParent()
	end
	UIUtil.addTopBar({["backFunc"]=backHandler,title = "添加管理员", parent = self, menuFont="确定", menuFunc=saveHandler})
end


function SearchAdminLayer:initData()
	--test
	_datasouce = {
					-- {userName = "王者无敌", userId="111111", headUrl = ""}
				 }
	_selectAdmin = {}
end


local function generateCell(idx, layer, uiTable)
	--local tdata = data[idx]
	tdata = _datasouce[idx]
	local bgLayer = cc.LayerColor:create(cc.c3b(8,11,25))
	bgLayer:setContentSize(cSize)

	local linebottom = cc.LayerColor:create(cc.c3b(21,24,31))
	linebottom:setContentSize(cc.size(display.width, 2)) 
	bgLayer:addChild(linebottom)

	local stencil,head = UIUtil.addUserHead(cc.p(138,cSize.height/2), tdata['headimg'], bgLayer, true)
	stencil:setScale(1)
	head:setScale(1)
	local textTmpX = 198
	UIUtil.addLabelArial(tdata['username'], 34, cc.p(textTmpX,cSize.height - 34), cc.p(0,1), bgLayer,  display.COLOR_WHITE)
	UIUtil.addLabelArial("ID:"..tdata['u_no'], 28, cc.p(textTmpX,34), cc.p(0,0), bgLayer, display.COLOR_WHITE)

	local function selectHandler(sender,eventType)

		if eventType == ccui.CheckBoxEventType.selected then 
			local total = #_selectAdmin + _admin_count
			if total > UnionCtrol.LIMIT_ADMIN_COUNT then -- 上限判断
				sender:setSelected(false)
				return
			end 
			local index = table.indexof(_selectAdmin, tdata['id'])
			if not index then 
				_selectAdmin[#_selectAdmin+1] = tdata['id']
			end
		else 
			table.removebyvalue(_selectAdmin, tdata['id'], true)
		end
	end
	local checkbtn = UIUtil.addCheckBox( {pos = cc.p(39, cSize.height/2), checkboxFunc = selectHandler, parent = bgLayer})
	checkbtn:setSelected(false)
	layer:addChild(bgLayer)
	return bgLayer
end

function SearchAdminLayer:initUI()
	local bg = display.newLayer(ResLib.COLOR_BLACK, display.width, display.height):addTo(self)
	bg._isSwallowImg = true
	TouchBack.registerImg(bg)
	self:addSearchNode()
	local posy = display.height-130-140

	local layer = UIUtil.addSection({text = "" ,tcolor = cc.c3b(131,131,131), fsize = 22, bcolor=cc.c3b(11,17,33), pos=cc.p(0, posy), size = cc.size(display.width, 36), parent = self})
	display.newLayer(cc.c3b(30,36,50), display.width, 1):addTo(layer):move(0,0)
	display.newLayer(cc.c3b(30,36,50), display.width, 1):addTo(layer):move(0,35)
	curTableView = UIUtil.addTableView(cc.size(display.width, posy), cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL,self)
	DZUi.addTableView(curTableView, cSize, #_datasouce, generateCell)
	local function numberOfCellsInTableView()
		return #_datasouce
	end
	curTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
end

function SearchAdminLayer:addSearchNode()
	-- 搜索框
	local searchBg = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-40, 64), pos=cc.p(display.width/2, display.height-130-20), ah =cc.p(0.5, 1), parent=self})

	local searchEdit = UIUtil.addEditBox( nil, cc.size(display.width-40-120, 64), cc.p(10,searchBg:getContentSize().height/2), "请输入玩家ID/昵称", searchBg )
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
			end
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )
	-- 搜索按钮
	local function ssFunc(  )
		local function searchResultHandle(data)
			if SEARCH_TEXT ~= "" then
				if next(data) ~= nil then
					_datasouce = data
					curTableView:reloadData()
				else
					ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "没有找到该用户，请更换搜索条件再试。"})
				end
			end
		end
		UnionCtrol.requestSearchUser(SEARCH_TEXT, searchResultHandle)
	end
	UIUtil.addImageBtn({norImg = "common/s_ss_icon.png", selImg = "common/s_ss_icon.png", disImg = "common/s_ss_icon.png", ah = cc.p(1, 0.5), pos = cc.p(searchBg:getContentSize().width-4, searchBg:getContentSize().height/2), touch = true, listener = ssFunc, parent = searchBg})
end


function SearchAdminLayer.show(parent, params)
	_lev = params.lev or 1
	_adminCount = params.admin_count or 32
	_delegate = params.delegate
	parent = parent or cc.Director:getInstance():getRunningScene()
	local adminLayer = SearchAdminLayer:create()
	print(tostring(parent))
	parent:addChild(adminLayer, StringUtils.getMaxZOrder(parent))
end


return SearchAdminLayer