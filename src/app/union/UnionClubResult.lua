--
-- Author: Taylor
-- Date: 2017-08-21 20:55:05
-- 联盟战绩-俱乐部列表 & 详情
-- 界面状态
-- >俱乐部进入
--		>>未结算				->正常 -> 点击结算 ->成功进入历史
--		>>历史牌局           ->正常
--		>>历史牌局时间查询    ->需要按照时间排序
--
-- >我的联盟进入
--		>>未结算				->正常 -> 点击结算 ->成功进入历史
--		>>历史牌局           ->正常
--		>>历史牌局时间查询    ->需要按照时间排序
--
--
local ViewBase = require("ui.ViewBase")
local UnionClubResult = class("UnionClubResult", ViewBase)
local UnionCtrol = require("union.UnionCtrol")

local ever_page = 15
local _size = cc.size(display.width, display.height - 130)

local _isClubVisit = false -- 是否从俱乐部访问
--------------------------------------------
--是否时间模式
local isTimemode = false  -- 
local times = nil -- times = {gtime = xx, stime = xx, etime = xx}

--游戏模式
local gameData = {}

UnionClubResult.Settled = {
	Yes = 1, --已经结算完毕了--代表历史牌局
	No = 0,  --还没有结算，代表未结算牌局
	Prohibit = 5,--备用， 代表禁止结算，跟权限相关
}

local settled = UnionClubResult.Settled --是否结算
local function isSettledState(state)
	if settled == state then
		return true
	end
	return false
end

local function isClubNoSettleAccount() --返回是否处于俱乐部未结算
	return _isClubVisit and gameData.select_type == 0
end
--------------------------------------------
---------------------------------------------
--游戏数据
local _data = {}
local _detail = {}
local _mergeData = {}
local function resetData()
	_isClubVisit =(UnionCtrol.getVisitFrom() == UnionCtrol.club_union)
	_data = {}
	_detail = {}
	_mergeData = {}
	_pageIndex = 1
end
--合并数据
local function reMergeData()
	_mergeData = {}
	local sectionLen = #_data
	for i = 1, sectionLen do
		local sData = _data[i]
		sData.flag = "header"
		_mergeData[#_mergeData + 1] = sData
		if sData.reveal then  --展开后要重新计算 是否拥有“more的框”，标记flag，计算页码
			local detailData = _detail[sData.club_id]
			if detailData then
				-- 如果有match_num优先使用，其次查看people_count
				local limitLen = 0
				if isTimemode then
					limitLen = sData.match_num or 0
				else
					limitLen = sData.total_people or 0
				end
				
				local len = #detailData
				sData.pageIndex = math.ceil((len) / ever_page) --+1后确保15/15代表准备加载第二页
				for j = 1, len do
					local tempData = detailData[j]
					tempData.flag = "children"
					tempData.reveal = true
					_mergeData[#_mergeData + 1] = tempData
					
					if j == len then  --检查是否是最后一组数据
						print("len:" .. len, "limitLen:" .. limitLen)
						if len >= limitLen then  --full show border
							tempData.curHave = len
						else
							len = len + 1 -- 添加 more
							_mergeData[#_mergeData + 1] = {curHave = len, more = true, flag = "more", pageIndex = sData.pageIndex, club_id = sData.club_id, reveal = true}--, total = limitLen, curLen = len}
						end
						break
					end
				end
				sData.curHave = len
			end
		else
			sData.curHave = 0
		end
	end
	-- dump(_mergeData, "合并结果")
end

local _pageIndex = 1
---------------------------------------------
--回调函数
local loadMoreByGidFunc = nil
local loadMoreByTimeFunc = nil
local loadMoreDetailByGidFunc = nil
local loadMoreDetailByTimeFunc = nil
local loadMoreHandle = nil
local callbackFuc = nil
--
---------------------------------------------
--UI 对象
local _uiTableView = nil
local _uiFooterView = nil
local _uiFooterAct = nil
local _refrehFooterPos = nil
-------------------------------------------------------------------------------------------------------------
--ui title pos
local subcellPosArr = {
	[1] = { --历史牌局时间查询
		[43] = {texts = {"牌局名称", "人数", "人次", "总报名费", "总奖励"}, poss = {115, 247, 350, 516, 671}},
		[42] = {texts = {"牌局名称", "人数", "总报名费", "总奖励"}, poss = {115, 282, 492, 668}},
		[41] = {texts = {"牌局名称", "手数", "带入量", "保险盈利", "盈利"}, poss = {117, 248, 363, 515, 664}}
	},
	[2] = {--非时间查询
		[42] = {texts = {"名次", "玩家", "报名费", "奖励"}, poss = {70, 267, 476, 648}},
		[43] = {texts = {"名次", "玩家", "报名费", "奖励"}, poss = {70, 267, 476, 648}},
		[41] = {texts = {"玩家", "手数", "带入量", "保险盈利", "盈利"}, poss = {72, 211, 343, 500, 668}}
	}
}
--TODO:tanhaiting 这里转换为ResultCtrol需要的标识 ps.战绩那块类似的转换太繁杂了需要统一
local function getResultModByTag(tag)
	if tag == 43 then return 4 end
	if tag == 42 then return 2 end
	if tag == 41 then return 1 end
	return 0
end

-- ui table view touch
local function clickedTableViewCell(table, cell, section, row)
	print("点击tablecell", tostring(cell), tostring(section))
end


--审核
local function clickAuthHandle(sender, evt)
	local sData = _mergeData[sender.section + 1]
	--****shit  sng and general is string, mtt is int 43, -.-!, for match server post
	local game_mod = gameData.gmod
	if game_mod ~= UnionCtrol.game.mtt then
		game_mod = UnionCtrol.game[gameData.gmod]
	end
	
	local callback = function(data)
		
		local oldData = {
			['mod'] = getResultModByTag(gameData.gmod),
			['game_mod'] = game_mod,
			['clubname'] = sData.club_name,
			['selectClubId'] = sData.club_id,
			['pid'] = gameData.gId,
			['isInsure'] = gameData.insure,
			['is_access'] = true,
			['ctlsrc'] = 2
		}
		require('result.LookAuthorizeUserLayer').show(self, {['itemsData'] = data['data'], ['pData'] = oldData})
	end
	-- warn!!!!!ResultCtrol是全局的，但是必须在这里面引入 why！
	local DataStat = require("friend.DataStat")
	ResultCtrol.sendRequireAdmins(gameData.gId, game_mod, sData.club_id, callback)
end

--------------------------------------------------
--加载详情 & 加载更多
--------------------------------------------------
local function loadDetailHandle(tdata, section)
	local function loadFunc()
		--重加载，定好位
		local posx, posy, th = _uiTableView:getContentOffset().x, _uiTableView:getContentOffset().y, _uiTableView:getContentSize().height
		_uiTableView:reloadData()
		th = _uiTableView:getContentSize().height - th
		_uiTableView:setContentOffset(cc.p(posx, posy - th), false)--设置为之前的坐标
	end
	
	if tdata.reveal then --详情展开
		if isTimemode then
			loadMoreDetailByTimeFunc((tdata.pageIndex or 0) + 1, tdata.club_id, section + 1, loadFunc)
		else
			loadMoreDetailByGidFunc((tdata.pageIndex or 0) + 1, tdata.club_id, section + 1, loadFunc)
		end
	else
		reMergeData()
		loadFunc()
		_refrehFooterPos()
	end
end

local function clubdetailHandle(sender, evt)
	local tdata = _mergeData[sender.section + 1]
	tdata.reveal = not tdata.reveal
	sender:setSelected(not tdata.reveal)
	sender:setHighlighted(not tdata.reveal)
	loadDetailHandle(tdata, sender.section)
end

local function loadMoreDetailHandle(sender, evt)
	local tdata = _mergeData[sender.section + 1]
	loadDetailHandle(tdata, sender.section)
end
------------------------------------------------------------------------------------------------------------
--tableView有多少节
local function tableCellNumOfSection(table)
	return #_mergeData
end

local function sizeOfSection(table, section)
	local tdata = _mergeData[section + 1]
	if tdata.flag == "children" or tdata.flag == "more" then --俱乐部内容详情 and 更多
		return _size.width, 90
	end
	if isClubNoSettleAccount() then --如果是俱乐部进来的且未结算
		if tdata and section == 0 then
			return _size.width, 279
		elseif tdata and tdata.reveal then
			return _size.width, 244
		else
			return _size.width, 181
		end
	else
		if tdata and tdata.reveal then
			return _size.width, 314
		else
			return _size.width, 251
		end
	end
end

local function sizeOfBorder(table, section)
	-- 实际内容宽，高， 距离cell高的偏移量（height - offsety）
	local tdata = _mergeData[section + 1]
	local curHave = tdata.curHave or 0
	local borderw, borderh, offsety, ch = 729, 291, 0, 0
	if isClubNoSettleAccount() then --俱乐部未结算
		offsety = 119
		if tdata and tdata.reveal then
			borderh = 225
			ch = curHave * 90 --计算子节点的高度
		else
			borderh = 162
		end
	else
		offsety = 188
		if tdata and tdata.reveal then
			borderh = 288
			ch = curHave * 90 --计算子节点的高度
		else
			borderh = 225
		end
	end
	return borderw, borderh, offsety, ch
end


local function getGameIconTag(_mod)
	if _mod == UnionCtrol.game.stand then return "common/com_icon_biao.png" end
	if _mod == UnionCtrol.game.sng then return "common/com_icon_sng.png" end
	if _mod == UnionCtrol.game.mtt then return "common/com_icon_mtt.png" end
end
---------------------------------------------
local function createSmallFlag(text, number, resPath, color)
	local imageViewA = ccui.ImageView:create()
	imageViewA:loadTexture(resPath)
	imageViewA:setAnchorPoint(cc.p(0, 1))
	imageViewA:setColor(color or cc.c3b(26, 255, 150))
	if number and number > 0 then
		local node = cc.Node:create()
		local left_label = UIUtil.addLabelArial(text, 30, cc.p(0, 0), cc.p(0, 0), node, cc.c3b(25, 25, 25))
		local leftSize = left_label:getContentSize()
		local right_label = UIUtil.addLabelArial(number, 10, cc.p(leftSize.width, 0), cc.p(0, 0), node, cc.c3b(25, 25, 25))
		local rightSize = right_label:getContentSize()
		node:setContentSize(cc.size(leftSize.width + rightSize.width, leftSize.height))
		node:setAnchorPoint(cc.p(0.5, 0.5))
		node:setPosition(cc.p(imageViewA:getContentSize().width / 2, imageViewA:getContentSize().height / 2))
		imageViewA:addChild(node)
		local tmpW = node:getContentSize().width
		if tmpW > imageViewA:getContentSize().width then
			node:setScale(imageViewA:getContentSize().width / tmpW - 0.1)
		end
	else
		UIUtil.addLabelArial(text, 30, cc.p(imageViewA:getContentSize().width / 2, imageViewA:getContentSize().height / 2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25, 25, 25))
	end
	return imageViewA
end

local function addAddBuy(number, followSp, pos, parent)
	local tf_abuy = UIUtil.addLabelBold("+" .. number, 28, pos, cc.p(0, 0.5), parent)
	local sp = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", pos, parent, cc.p(0, 0.5))
	local csize, asize, ssize = followSp:getContentSize(), tf_abuy:getContentSize(), sp:getContentSize()
	local totalwidth = csize.width + asize.width + ssize.width
	local offsetx = pos.x - totalwidth / 2
	followSp:setPositionX(offsetx + csize.width / 2)
	tf_abuy:setPositionX(offsetx + csize.width)
	sp:setPositionX(offsetx + csize.width + asize.width)
	return sp
end

local function addSquareArea(parent, pos, title, content, size, color, rbuy, abuy, borderw)
	rbuy = tonumber(rbuy) or 0
	abuy = tonumber(abuy) or 0
	borderw = borderw or 1
	color = color or cc.c3b(255, 255, 255)
	local node = display.newNode():addTo(parent):move(pos.x, pos.y)
	local leftborder = display.newLayer(cc.c3b(11, 59, 123), borderw, size.height):addTo(node)
	local rightborder = display.newLayer(cc.c3b(11, 59, 123), borderw, size.height):addTo(node):move(size.width - borderw, 0)
	local bottomborder = display.newLayer(cc.c3b(11, 59, 123), size.width, borderw):addTo(node)
	if not isClubNoSettleAccount() then
		print("top!!!!")
		local topborder = display.newLayer(cc.c3b(11, 59, 123), size.width, borderw):addTo(node):move(0, size.height)
	end
	
	local tf_title = UIUtil.addLabelArial(title, 24, cc.p(size.width / 2, size.height - 25), cc.p(0.5, 0.5), node, ResLib.COLOR_GREY1)
	local tf_content = UIUtil.addLabelBold(content, 28, cc.p(size.width / 2, size.height - 68), cc.p(0.5, 0.5), node, color)
	tf_content:setName("text_content")
	if abuy and abuy > 0 then
		addAddBuy(abuy, tf_content, cc.p(size.width / 2, size.height - 68), node)
	else
		-- tf_abuy:setVisible(false)
		-- sp:setVisible(false)
	end
	-- node.content = tf_content
	-- node.abuy = tf_abuy 
	-- node.sp = sp
	return node
end

--添加标准 数据
local function addStandSectionCell(table, sCell, csize, pos, section)
	local tdata = _mergeData[section + 1]
	local ssize = sCell:getContentSize()
	local posx =(ssize.width - csize.width) / 2
	local offsetw = csize.width / 4
	--总人数
	local tf_people = addSquareArea(sCell, cc.p(posx, ssize.height - pos.y), "总人数", tdata['total_people'], cc.size(offsetw, 100))
	tf_people:setName("people")	
	--总带入
	local tf_takein = addSquareArea(sCell, cc.p(posx + offsetw, ssize.height - pos.y), "总带入量", tdata['total_takein'], cc.size(offsetw, 100), nil, 0, tdata['add_buy'])
	tf_takein:setName('total_takein')
	--总保险
	str, color = StringUtils.getSymbolNumColor(tdata['total_insure'], display.COLOR_WHITE)
	local tf_insure = addSquareArea(sCell, cc.p(posx + offsetw * 2, ssize.height - pos.y), "总保险盈利", str, cc.size(offsetw, 100), color)
	tf_insure:setName("total_insure")
	--总盈利
	str, color = StringUtils.getSymbolNumColor(tdata['total_profit'], display.COLOR_WHITE)
	local tf_profit = addSquareArea(sCell, cc.p(posx + offsetw * 3, ssize.height - pos.y), "总盈利", str, cc.size(offsetw, 100), color)
	tf_profit:setName("total_profit")
end
--添加sng 数据
local function addSngSectionCell(table, sCell, csize, pos, section)
	local tdata = _mergeData[section + 1]
	local ssize = sCell:getContentSize()
	local posx =(ssize.width - csize.width) / 2
	local offsetw = csize.width / 3
	
	--总人数
	local tf_people = addSquareArea(sCell, cc.p(posx, ssize.height - pos.y), "总人数", tdata['total_people'], cc.size(offsetw, 100))
	tf_people:setName("people")	
	--总报名费
	local tf_signin = addSquareArea(sCell, cc.p(posx + offsetw, ssize.height - pos.y), "总报名费", tdata['total_signin'], cc.size(offsetw, 100))
	tf_signin:setName("signin")
	--总奖励
	local str, color = StringUtils.getSymbolNumColor(tdata['total_award'], display.COLOR_WHITE)
	local tf_award = addSquareArea(sCell, cc.p(posx + offsetw * 2, ssize.height - pos.y), "总奖励", str, cc.size(offsetw, 100), color)
	tf_award:setName("award")
end

--添加MTT 数据
local function addMttSectionCell(table, sCell, csize, pos, section)
	local tdata = _mergeData[section + 1]
	local ssize = sCell:getContentSize()
	local posx =(ssize.width - csize.width) / 2
	local offsetw = csize.width / 4
	print("posx" .. posx, "posy" .. offsetw)
	--总人数
	local tf_people = addSquareArea(sCell, cc.p(posx, ssize.height - pos.y), "总人数", tdata['total_people'], cc.size(offsetw, 100))
	tf_people:setName("people")	
	--总人次
	local tf_people_count = addSquareArea(sCell, cc.p(posx + offsetw, ssize.height - pos.y), "总人次", tdata['count_people'], cc.size(offsetw, 100), nil, 0, tdata['add_buy'])
	tf_people_count:setName('people_count')
	--总报名费
	local tf_signin = addSquareArea(sCell, cc.p(posx + offsetw * 2, ssize.height - pos.y), "总报名费", tdata['total_signin'], cc.size(offsetw, 100))
	tf_signin:setName("signin")
	--总奖励
	local str, color = StringUtils.getSymbolNumColor(tdata['total_award'], display.COLOR_WHITE)
	local tf_award = addSquareArea(sCell, cc.p(posx + offsetw * 3, ssize.height - pos.y), "总奖励", str, cc.size(offsetw, 100), color)
	tf_award:setName("award")
end

local sectionCellHandle = {
	[41] = addStandSectionCell,
	[42] = addSngSectionCell,
	[43] = addMttSectionCell,
}

local rowCellHandle = {
	[41] = addStandSectionCellAtRow,
	[42] = addSngSectionCellAtRow,
	[43] = addMttSectionCellAtRow,
}
--俱乐部访问-查看战绩-俱乐部本身的信息
local function addClubCell(table, sCell, size, section)
	sCell:setLocalZOrder(100)
	sCell:setGlobalZOrder(100)
	local tdata = _mergeData[section + 1]
	-- dump(tdata, "addClubCell")
	local stencil, clubIcon, mark = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(size.width / 2, size.height - 63), parent = sCell, nor = ResLib.CLUB_HEAD_GENERAL, sel = tdata["club_avatar"], listener = function() end})
	clubIcon:setTouchEnabled(false)
	-- 	stencil:setScale(40/clubIcon:getContentSize().width)
	-- clubIcon:setScale(40/clubIcon:getContentSize().width)
	sCell.clubIcon = clubIcon
	mark:setVisible(false)
	if tdata['club_avatar'] ~= nil and tdata['club_avatar'] ~= "" then
		local function callback(respath)
			clubIcon:loadTextureNormal(respath)
			clubIcon:loadTexturePressed(respath)
			clubIcon:loadTextureDisabled(respath)
		end
		CppPlat.downResFile(tdata['club_avatar'], callback, callback, ResLib.CLUB_HEAD_GENERAL, 100)
	end
	UIUtil.addLabelArial(tdata["club_name"], 34, cc.p(size.width / 2, size.height - 124), cc.p(0.5, 1), sCell, cc.c3b(51, 102, 204))
	UIUtil.addLabelArial("名片ID:" .. tdata['club_no'], 22, cc.p(size.width / 2, size.height - 173), cc.p(0.5, 1), sCell, ResLib.COLOR_GREY1)
	--审核按钮
	local btn_normal, btn_select, btn_disable = "common/com_btn_blue.png", "common/com_btn_blue_height.png", "Default/Button_Disable.png"
	local label = cc.Label:createWithSystemFont("审核记录", "Marker Felt", 22)
	local btn = UIUtil.controlBtn(btn_normal, btn_select, btn_disable, label, cc.p(size.width / 2, size.height - 242), cc.size(140, 50), clickAuthHandle, sCell)
	btn:setEnabled(tdata.is_auth)
	btn.section = section
	
	local gameStr = UnionCtrol.game[tostring(gameData.gmod)]
	local timeStr = os.date("%m/%d/%H:%M", times.gtime)
	local timeTf = UIUtil.addLabelArial(timeStr, 24, cc.p(size.width - 20, size.height - 18), cc.p(1, 1), sCell)
	UIUtil.addLabelArial(gameStr, 24, cc.p(size.width - 20, timeTf:getPositionY() - timeTf:getContentSize().height - 10), cc.p(1, 1), sCell)
	return sCell
end

local function addMoreHeader(sCell, csize, data, section)
	local btn_normal, btn_select = ResLib.COM_OPACITY0, ResLib.COM_OPACITY0
	label = cc.Label:createWithSystemFont("查看更多", "Arial", 35)
	btn = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.width / 2, csize.height / 2), csize, loadMoreDetailHandle, sCell)
	btn.section = section
	
	local borderw, borderh, offsety, ch = sizeOfBorder(nil, section)
	if data.curHave and data.curHave > 0 then
		local border = UIUtil.addImageView({image = ResLib.U_RECORD_CELL_BORDER, size = cc.size(borderw, borderh + ch), ah = cc.p(0.5, 0), scale = true, touch = false, pos = cc.p(csize.width / 2, 0), parent = sCell})
		border:setName("border")
		border:setLocalZOrder(101)
		-- border:setGlobalZOrder(100)
		sCell:setLocalZOrder(101)
	end
end

local function addCellDetail(sCell, csize, data, section)
	sCell:setLocalZOrder(99)
	local poss = nil
	if isTimemode then
		poss = subcellPosArr[1] [gameData.gmod].poss
	else
		poss = subcellPosArr[2] [gameData.gmod].poss
	end
	local cy = csize.height / 2
	local bgcx =(csize.width - 731) / 2
	local bgColor = display.newLayer(cc.c3b(1, 7, 23), 731, csize.height):addTo(sCell):move(bgcx, 0)
	local line = display.newLayer(cc.c3b(11, 59, 123), 731, 1):addTo(sCell):move(bgcx, 0)
	--向上绘制boder
	local borderw, borderh, offsety, ch = sizeOfBorder(nil, section)
	if data.curHave and data.curHave > 0 then
		local border = UIUtil.addImageView({image = ResLib.U_RECORD_CELL_BORDER, size = cc.size(borderw, borderh + ch), ah = cc.p(0.5, 0), scale = true, touch = false, pos = cc.p(csize.width / 2, 0), parent = sCell})
		border:setName("border")
		border:setLocalZOrder(101)
		border:setGlobalZOrder(100)
		sCell:setLocalZOrder(101)
	end
	
	if gameData.gmod == UnionCtrol.game.stand then --标准
		local color, dWidth = display.COLOR_WHITE, 170
		if isTimemode then
			color, dWidth = cc.c3b(67, 94, 188), 210
		end
		local tfname = UIUtil.addLabelArial(data.match_name or data.username, 28, cc.p(11, cy), cc.p(0, 0.5), sCell, color)
		tfname:setDimensions(dWidth, csize.height)
		tfname:setMaxLineWidth(dWidth)
		tfname:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER)
		
		UIUtil.addLabelArial(data.hand_num, 28, cc.p(poss[2], cy), cc.p(0.5, 0.5), sCell)
		UIUtil.addLabelArial(data.total_takein or data.takein, 30, cc.p(poss[3], cy), cc.p(0.5, 0.5), sCell)
		local str, color = StringUtils.getSymbolNumColor(data.total_insure, display.COLOR_WHITE)
		UIUtil.addLabelArial(str, 28, cc.p(poss[4], cy), cc.p(0.5, 0.5), sCell, color)
		local str, color = StringUtils.getSymbolNumColor(data.total_profit, display.COLOR_WHITE)
		UIUtil.addLabelArial(str, 28, cc.p(poss[5], cy), cc.p(0.5, 0.5), sCell, color)
		
	elseif gameData.gmod == UnionCtrol.game.sng then
		local tfname = UIUtil.addLabelArial(data.match_name or tostring(data.ranking), 28, cc.p(poss[1], cy), cc.p(0.5, 0.5), sCell, display.COLOR_WHITE)
		if isTimemode then
			tfname:setAnchorPoint(cc.p(0, 0.5))
			tfname:setPositionX(11)
			tfname:setTextColor(cc.c3b(201, 98, 25))
			tfname:setDimensions(228, csize.height)
			tfname:setMaxLineWidth(228)
			tfname:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER)
		end
		UIUtil.addLabelArial(data.people_num or data.username, 28, cc.p(poss[2] + 2, cy), cc.p(0.5, 0.5), sCell)
		UIUtil.addLabelArial(data.total_signin or data.signin_cost, 28, cc.p(poss[3], cy), cc.p(0.5, 0.5), sCell)
		local str, color = StringUtils.getSymbolNumColor(data.total_award or data.award, display.COLOR_WHITE)
		UIUtil.addLabelArial(str, 28, cc.p(poss[4], cy), cc.p(0.5, 0.5), sCell, color)
		
	elseif gameData.gmod == UnionCtrol.game.mtt then
		local str, color = StringUtils.getSymbolNumColor(data.total_award or data.award, display.COLOR_WHITE)
		
		if isTimemode then
			local tfname = UIUtil.addLabelArial(data.match_name, 28, cc.p(11, cy), cc.p(0, 0.5), sCell, cc.c3b(132, 103, 213))
			tfname:setDimensions(210, csize.height)
			tfname:setMaxLineWidth(210)
			tfname:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.TEXT_ALIGNMENT_CENTER)
			
			UIUtil.addLabelArial(data.people_num, 28, cc.p(poss[2], cy), cc.p(0.5, 0.5), sCell)
			UIUtil.addLabelArial(data.total_signin or data.total_singin, 28, cc.p(poss[4], cy), cc.p(0.5, 0.5), sCell)
			UIUtil.addLabelArial(str, 28, cc.p(poss[5], cy), cc.p(0.5, 0.5), sCell, color)
			local tf_pc = UIUtil.addLabelArial(data.people_count, 28, cc.p(poss[3], cy), cc.p(0.5, 0.5), sCell)
			if data.add_buy and data.add_buy > 0 then
				-- UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(poss[3] + tf_pc:getContentSize().width/2, cy), sCell, cc.p(0, .5))
				addAddBuy(data.add_buy, tf_pc, cc.p(poss[3] + tf_pc:getContentSize().width / 2 + 3, cy), sCell)
			end
		else
			UIUtil.addLabelArial(data.ranking, 28, cc.p(poss[1], cy), cc.p(0.5, 0.5), sCell)
			UIUtil.addLabelArial(data.signin_cost, 28, cc.p(poss[3], cy), cc.p(0.5, 0.5), sCell)
			UIUtil.addLabelArial(str, 28, cc.p(poss[4], cy), cc.p(0.5, 0.5), sCell, color)
			local tf_u = UIUtil.addLabelArial(data.username, 28, cc.p(poss[2], cy), cc.p(0.5, 0.5), sCell)
			local r_num, a_num, offsetx = tonumber(data['re_buy']), tonumber(data['add_buy']), poss[2] + tf_u:getContentSize().width / 2
			if a_num and a_num > 0 then
				offsetx = UIUtil.addPosSprite("common/card_mtt_bind_addbuy_icon.png", cc.p(offsetx + 3, cy), sCell, cc.p(0, 0.5)):getContentSize().width + offsetx
				-- offsetx = addAddBuy(a_num, tf_u, cc.p(poss[2], cy), sCell):getContentSize().width + offsetx
			end
			if r_num and r_num > 0 then
				local image = createSmallFlag("R", r_num, "result/r_s9.png", cc.c3b(252, 215, 54))
				sCell:addChild(image)
				image:setAnchorPoint(cc.p(0, 0.5))
				image:setPosition(cc.p(offsetx + 6, cy))
			end
		end
	end
end

--俱乐部的战绩统计
local function addClubHeader(sCell, csize, tdata, section)
	local borderw, borderh, offsety, ch = sizeOfBorder(nil, section)
	sCell:setLocalZOrder(100)
	--背景
	-- local img = UIUtil.addImageView({image = ResLib.U_RECORD_CELL_BG, size = cc.size(borderw, borderh), ah = cc.p(.5,0), scale = true, touch = false, pos = cc.p(csize.width/2,0), parent = sCell})
	display.newLayer(cc.c3b(26, 32, 46), borderw, borderh):addTo(sCell):align(cc.p(0.5, 0), csize.width / 2, 0):ignoreAnchorPointForPosition(false)
	--根据game_mod添加数据
	local stateHandle = sectionCellHandle[gameData.gmod]
	if stateHandle then
		stateHandle(table, sCell, cc.size(borderw, borderh), cc.p(0, offsety), section)
	end
	
	local border = UIUtil.addImageView({image = ResLib.U_RECORD_CELL_BORDER, size = cc.size(borderw, borderh + ch), ah = cc.p(0.5, 0), scale = true, touch = false, pos = cc.p(csize.width / 2, - ch), parent = sCell})
	border:setName("border")
	border:setLocalZOrder(100)
	border:setGlobalZOrder(101)
	--添加详情button
	local btn_normal, btn_select = ResLib.U_RECORD_BTN_DOWN, ResLib.U_RECORD_BTN_UP
	local btn_detail = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, nil, cc.p(display.width / 2, csize.height - offsety), cc.size(724, 61), clubdetailHandle, sCell)
	btn_detail:setAnchorPoint(cc.p(0.5, 1))
	btn_detail:setSelected(tdata.reveal)
	btn_detail:setHighlighted(tdata.reveal)
	btn_detail:setName("detail")
	btn_detail.section = section
	
	--点击详情 展开后需要 展示的内容
	-- if tdata.reveal then 
	local titleAndPos, iconTag = nil, nil
	if isTimemode then
		titleAndPos = subcellPosArr[1] [gameData.gmod]
		iconTag = getGameIconTag(gameData.gmod)
	else
		titleAndPos = subcellPosArr[2] [gameData.gmod]
		iconTag = nil
	end
	--黑横线
	local title_node = display.newLayer(cc.c3b(26, 32, 46), borderw - 4, 64):align(cc.p(0.5, 0), csize.width / 2, 0):addTo(sCell):ignoreAnchorPointForPosition(false)
	-- local title_node = UIUtil.addImageView({image = ResLib.U_RECORD_CELL_BG, size = cc.size(borderw, 70), ah = cc.p(.5,0), scale = true, touch = false, pos = cc.p(csize.width/2,0), parent = sCell})
	title_node:setName("title_node")
	title_node:setVisible(tdata.reveal)
	
	for i = 1, #titleAndPos.texts do
		local label = UIUtil.addLabelArial(titleAndPos.texts[i], 28, cc.p(titleAndPos.poss[i] - 10.5, 33), cc.p(0.5, 0.5), title_node)
	end
	
	display.newLayer(cc.c3b(1, 7, 23), borderw, 1):align(cc.p(0.5, 0), borderw / 2 - 2, 63):addTo(title_node):ignoreAnchorPointForPosition(false)
	if iconTag then UIUtil.addPosSprite(iconTag, cc.p(27, 35), title_node) end
	-- end
	--根据访问来源和结算状态判断是否显示俱乐部名称
	if not isClubNoSettleAccount() then
		local stencil, clubIcon, mark = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(42, csize.height - 55), parent = sCell, nor = ResLib.CLUB_HEAD_GENERAL, sel = tdata["club_avatar"], listener = function() end})
		stencil:setScale(40 / clubIcon:getContentSize().width)
		clubIcon:setScale(40 / clubIcon:getContentSize().width)
		sCell.clubIcon = clubIcon
		mark:setVisible(false)
		if tdata['club_avatar'] ~= nil and tdata['club_avatar'] ~= "" then
			local function callback(respath)
				clubIcon:loadTextureNormal(respath)
				clubIcon:loadTexturePressed(respath)
				clubIcon:loadTextureDisabled(respath)
			end
			CppPlat.downResFile(tdata['club_avatar'], callback, callback, ResLib.CLUB_HEAD_GENERAL, 100)
		end
		--名字
		local tf_name = UIUtil.addLabelArial(tdata["club_name"] or "俱乐部", 31, cc.p(70, csize.height - 55), cc.p(0, 0.5), sCell, cc.c3b(68, 94, 184))
		tf_name:setName("clubName")
		tf_name:setLocalZOrder(100)
		--审核
		local btn_auth = UIUtil.addUITextButton({size = cc.size(128, 54), ah = cc.p(1, 0.5), igAsize = true, pos = cc.p(csize.width - 22, csize.height - 55), text = "审核记录", tcolor = cc.c3b(63, 89, 170), fsize = 34, funcBack = function() end, parent = sCell})
		btn_auth:touchEnded(clickAuthHandle)
		btn_auth:setName("btn_auth")
		btn_auth.section = section
		btn_auth:setVisible(tdata['is_auth'] or false)
	end
end

local function createSectionHeader(table, sCell, csize, section)
	local tdata = _mergeData[section + 1]
	if tdata.flag == "header" then  --俱乐部头
		addClubHeader(sCell, csize, tdata, section)
	elseif tdata.flag == "children" then --俱乐部详情
		addCellDetail(sCell, csize, tdata, section)
	elseif tdata.flag == "more" then  --更多的按钮
		addMoreHeader(sCell, csize, tdata, section)
	end
end
--调用父类节点
local function addSectionHeader(table, section)
	if section == 0 and isClubNoSettleAccount() then --
		local sCell = table:dequeueCell()
		if sCell then
			sCell:removeAllChildren()
		else
			sCell = cc.TableViewCell:new()
		end
		local w, h = sizeOfSection(table, section)
		return addClubCell(talbe, sCell, cc.size(w, h), section)
	end
	
	local w, h = sizeOfSection(table, section)
	local csize = cc.size(w, h)
	local sCell = table:dequeueCell()
	if sCell == nil then
		sCell = cc.TableViewCell:new()
	end
	sCell:removeAllChildren()
	sCell:setContentSize(csize)
	createSectionHeader(table, sCell, csize, section)
	-- sCell:setContentSize(csize)
	--    updateSectionCell(table, sCell, csize, section)
	return sCell
end

local function addSectionFooter(table, section)
end

local function tableCellRowOfSection(table, section, row)
end

------------------------------------------------------------------------------------------
------------------------------------------------------------------
local refreshState = {
	load_idel = 0,
	load_prepare = 1,
	load_start = 2,
	load_ing = 3,
	load_exit = 4,
	load_end = 5
}
local _loadState = refreshState.load_idel
local function refreshFooterForIdel(target, table)
	if table:isDragging() and table:isTouchMoved() then
		_loadState = refreshState.load_prepare
		_uiFooterView:getChildByName("action"):setOpacity(10)
	end
end

local function refreshFooterForPrepare(target, table)
	local isDragging, isMove = table:isDragging(), table:isTouchMoved()
	local originy = math.max(table:getViewSize().height - table:getContentSize().height, 0)
	local up_offsety = table:getContentOffset().y - originy
	local opacity = math.max(0,(up_offsety - 10) / 120)
	opacity = math.min(1, opacity)
	_uiFooterView:getChildByName("action"):setOpacity(255 * opacity)
	if up_offsety > 120 and not isDragging and not isMove then
		_loadState = refreshState.load_start
	elseif up_offsety < 10 then
		_loadState = refreshState.load_end
		-- _uiFooterView:setVisible(false)
	end
end

local function refreshFooterForStart(target, table)
	local cHeight = table:getContentSize().height
	local vHeight = table:getViewSize().height
	local waitPosy = math.max(vHeight - cHeight, 0) + 100
	table.OldHeight = cHeight
	print("table.OldHeight:" .. table.OldHeight)
	_loadState = refreshState.load_ing
	table:stopAnimatedContentOffset()
	table:setTouchEnabled(false)
	local d = table:getContentOffset().y - waitPosy
	local k1, k2, k3 = 1, 0.01, 0.9
	local t = 0.5 /(0.5 + d * k2 + d * d * k3)
	
	local moveTo = cc.MoveTo:create(t, cc.p(0, waitPosy))
	local callback = cc.CallFunc:create(function()
		_uiFooterView:getChildByName("action"):setOpacity(255)
		table:stopAnimatedContentOffset()
		
		loadMoreHandle(function(data)
			if #data > 0 then
				_uiTableView:reloadData()
			end
		end)
	end)
	table:getContainer():runAction(cc.Sequence:create(moveTo, callback))
	_uiFooterAct:play('load', true)
end

local function refreshFooterForLoading(target, table)
	print("loading")
end

local function refreshFooterForExit(target, table)
	
	_loadState = refreshState.load_end
	local basey = table.OldHeight - table:getContentSize().height
	local vHeight = table:getViewSize().height
	if table.OldHeight < table:getViewSize().height then
		basey = table:getViewSize().height - table:getContentSize().height
	end
	local footPosy = - 70
	if table:getContentSize().height < table:getViewSize().height then
		local tempy = table:getViewSize().height - table:getContentSize().height
		footPosy = 0 - tempy - 70
	end
	
	table:getContainer():setPositionY(basey)
	table:setTouchEnabled(true)
	_uiFooterView:setPositionY(footPosy)
	_uiFooterAct:play("stop", true)
	_uiFooterView:getChildByName("action"):setOpacity(0)
end

local function refreshFooterForEnd(target, table)
	_loadState = refreshState.load_idel
	-- _uiFooterView:setVisible(false)
end
local function setRefreshEnd()
	if _loadState == refreshState.load_ing then
		_loadState = refreshState.load_exit
		print("结束啦")
	end
end

local stateHandler = {
	[0] = refreshFooterForIdel,
	[1] = refreshFooterForPrepare,
	[2] = refreshFooterForStart,
	[3] = refreshFooterForLoading,
	[4] = refreshFooterForExit,
	[5] = refreshFooterForEnd
}


local function checkRefreshView(target)
	if not _uiTableView then
		do return end
	end
	local stateFunc = stateHandler[_loadState]
	stateFunc(target, _uiTableView)
end

local function checkFooterPos()
	if not _uiFooterView or not _uiFooterAct then
		return
	end
	local basey = math.max(_uiTableView:getViewSize().height - _uiTableView:getContentSize().height, 0)
	basey = 0 - basey - 70
	print("basey:", basey, "offsety:", _uiTableView:getViewSize().height - _uiTableView:getContentSize().height)
	_uiFooterView:setPosition(display.cx, basey)
end
_refrehFooterPos = checkFooterPos

local function addFooterForTableView()
	_uiFooterView = cc.CSLoader:createNode("action/loadingAction.csb")
	_uiFooterAct = cc.CSLoader:createTimeline("action/loadingAction.csb")
	_uiFooterView:runAction(_uiFooterAct)
	-- _uiFooterView:setVisible(false)
	if _uiTableView then
		_uiTableView:addChild(_uiFooterView)
	end
	checkFooterPos()
end
-- ui tableview delegate
local function scrollViewDidScroll(view)
	checkRefreshView(view:getParent())
end
------------------------------------------------------------------------------------------------------------------------------------
local function addTableView(container, vsize, pos)
	local tableDir = cc.SCROLLVIEW_DIRECTION_VERTICAL
	local table = UIUtil.addTableView(vsize, pos, tableDir, container)
	table:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	table:registerScriptHandler(clickedTableViewCell, cc.TABLECELL_TOUCHED)
	table:registerScriptHandler(tableCellNumOfSection, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	table:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
	table:registerScriptHandler(sizeOfSection, cc.TABLECELL_SIZE_FOR_INDEX)
	table:registerScriptHandler(addSectionHeader, cc.TABLECELL_SIZE_AT_INDEX)
	table:setLocalZOrder(9)
	table:setBounceable(true)
	_uiTableView = table
	table:reloadData()
	addFooterForTableView()
end

---添加公共UI
local function addTopTitle(parent, title, time)
	UIUtil.addLabelArial(title or "xxx", 20, cc.p(20, _size.height - 31), cc.p(0, 0.5), parent):setLocalZOrder(100)
	UIUtil.addLabelArial(time or "xxx", 20, cc.p(display.width - 20, _size.height - 31), cc.p(1, 0.5), parent):setLocalZOrder(100)
end

--添加结算按钮
local function addSettleBtn(parent)
	local layer, btn = nil, nil
	local function settleHandler(sender, event)
		local function response()
			ViewCtrol.showTick({content = "结算成功!"})
			layer:removeSelf()
			btn:removeSelf()
			if callbackFuc then
				callbackFuc(gameData.gmod, gameData.gId)
			end
			local posy, tSize = _uiTableView:getPositionY(), _uiTableView:getViewSize()
			_uiTableView:setPositionY(posy - 124)
			_uiTableView:setViewSize(cc.size(tSize.width, tSize.height + 124))
			_uiTableView:reloadData()
			_refrehFooterPos()
		end
		
		-- dump(gameData, "游戏类型")
		local visitFrom = UnionCtrol.getVisitFrom()
		if visitFrom == UnionCtrol.mine_union then
			UnionCtrol.requrestSettleAccountForUnion(gameData.gId, gameData.gmod, response)
		elseif visitFrom == UnionCtrol.club_union then
			local clubid = _data[1] ['club_id']
			local function clubSureHandle()
				UnionCtrol.requrestSettleAccountForClub(gameData.gId, clubid, gameData.gmod, response)
			end
			ViewCtrol.popHint({content = "是否结算本局?", sureFunBack = clubSureHandle, bgSize = cc.size(display.width - 100, 300)})
		end
	end
	
	layer = display.newLayer(cc.c4b(0, 0, 0, 0), display.width, 121):addTo(parent):move(0, 0)
	layer:setLocalZOrder(10)
	local btn_normal, btn_select = "common/com_btn_blue.png", "common/com_btn_blue_height.png"
	label = cc.Label:createWithSystemFont("全部结算", "Marker Felt", 36)
	label:setColor(cc.c3b(255, 255, 255))
	btn = UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.width / 2, 60), cc.size(710, 80), settleHandler, parent)
	btn:setLocalZOrder(10)
end
------------------------------------------------------------------------------------------------------------------------------------
function UnionClubResult:ctor(params)
	self:enableNodeEvents()
	self:initData()
	self:initUI(params)
end

function UnionClubResult:onEnter()
end

function UnionClubResult:onExit()
	self:unscheduleUpdate()
	_data = nil
	_detail = nil
	_uiTableView = nil
	gameData = nil
	times = nil
	_isClubVisit = nil
	_uiFooterView = nil
	_uiFooterAct = nil
	callbackFuc = nil
	_pageIndex = 1
end

function UnionClubResult:initData()
	self.lastTime = 0
end

function UnionClubResult:initUI()
	local layer = display.newLayer(cc.c3b(1, 7, 23), display.size):addTo(self)
	layer._isSwallowImg = true
	TouchBack.registerImg(layer)
	
	local game_title, vsize = "", cc.size(_size.width, _size.height - 47)
	
	if isTimemode then
		game_title = os.date("%m/%d", times.stime) .. "-" .. os.date("%m/%d", times.etime)
		vsize = cc.size(_size.width, _size.height)
	else
		if isClubNoSettleAccount() then
			vsize = cc.size(_size.width, _size.height)
		end
		game_title = gameData.title
	end
	--添加topbar
	local function backHandler()
		self:removeSelf()
	end
	local topBar = UIUtil.addTopBar({["backFunc"] = backHandler, title = game_title, parent = self})
	topBar:setLocalZOrder(100)
	
	--是否添加小标题
	if not isTimemode and not isClubNoSettleAccount() then
		local gameStr = UnionCtrol.game[tostring(gameData.gmod)]
		addTopTitle(self, gameStr, os.date("%m/%d/%H:%M", times.gtime))
	end
	
	--添加结算按钮
	local tablePos = cc.p(0, 0)
	local hasSettleAuth = UnionCtrol.isHasAuth(UnionCtrol.Auth_Club_Settle) or UnionCtrol.isHasAuth(UnionCtrol.Auth_SETTLE)
	if hasSettleAuth and isSettledState(UnionClubResult.Settled.No) then
		addSettleBtn(self)
		vsize.height = vsize.height - 124
		tablePos.y = 124
	end
	--添加tableView
	addTableView(self, vsize, tablePos)
	self:onUpdate(handler(self, self.update))
end

function UnionClubResult:update(dt)
	-- self.lastTime = self.lastTime + dt
	-- if self.lastTime > 1/30 then 
	checkRefreshView(self)
	-- self.lastTime = 0
	-- end
end

--加工detailData
local function processDetailData(data, clubid)
	local detailData = _detail[clubid]
	if not detailData then
		detailData = {}
		_detail[clubid] = detailData
	end
	table.insertto(detailData, data, #detailData + 1)
	_detail[clubid] = detailData
	-- dump(_detail, "自cell")
end

local function sendGetClubRecordDetailByGid(page, clubId, section, fucback)
	local function response(data)
		processDetailData(data, clubId)
		reMergeData()
		fucback(data)
		checkFooterPos()
	end
	local sendData = {}
	sendData['select_type'] = gameData.select_type
	sendData['game_mod'] = gameData.gmod
	sendData['clubid'] = clubId
	sendData['gameid'] = gameData.gId
	sendData['gameId'] = gameData.gId
	sendData['page'] = page
	sendData['ever_page'] = 15
	UnionCtrol.getUnionClubRecordDetailByGID(sendData, response)
end

local function sendGetClubRecordByGid(page, fucback)
	
	local function response(data)
		fucback(data)
		
		if #data > 0 then
			_pageIndex = _pageIndex + 1
		end
	end
	local sendData = {}
	sendData['select_type'] = gameData.select_type
	sendData['game_mod'] = gameData.gmod
	sendData['gameId'] = gameData.gId
	sendData['from'] = UnionCtrol.getVisitFrom()
	sendData['page'] = page
	sendData['ever_page'] = 15
	
	UnionCtrol.getUnionClubRecordByGID(sendData, response)
end

local function sendGetClubRecordDetailByTime(page, clubid, section, fucback)
	local function response(data)
		processDetailData(data.games, data.clubid)
		reMergeData()
		fucback(data)
		checkFooterPos()
	end
	
	local sendData = {}
	sendData['select_type'] = gameData.select_type
	sendData['game_mod'] = gameData.gmod
	sendData['startTime'] = times.stime
	sendData['endTime'] = times.etime
	sendData['page'] = page
	sendData['ever_page'] = ever_page
	sendData['clubid'] = clubid
	UnionCtrol.getUnionClubRecordDetailByTime(sendData, response)
end

local function sendGetClubRecordByTime(page, fucback)
	
	local function response(data)
		fucback(data)
		if #data > 0 then
			_pageIndex = _pageIndex + 1
		end
	end
	local sendData = {}
	sendData['page'] = page
	sendData['ever_page'] = 15
	sendData['startTime'] = times.stime
	sendData['endTime'] = times.etime
	sendData['game_mod'] = gameData.gmod
	sendData['select_type'] = gameData.select_type
	sendData['from'] = UnionCtrol.getVisitFrom()
	UnionCtrol.getUnionClubRecordByTime(sendData, response)
end

local function loadMoreData(func)
	local function response(data)
		if isClubNoSettleAccount() then
			if #data > 0 then  --
				local clubInfo = data[1]
				local clubdata = {}
				clubdata.club_id = clubInfo.club_id
				clubdata.club_name = clubInfo.club_name
				clubdata.club_avatar = clubInfo.club_avatar
				clubdata.is_auth = clubInfo.is_auth
				local tmpData = UnionCtrol.getUnionCMember() [1]
				if tmpData then
					clubdata.club_no = tmpData.club_no
				end
				_data = data
				table.insert(_data, 1, clubdata)
			end
		else
			table.insertto(_data, data, #_data)
		end
		reMergeData()
		func(data)
		checkFooterPos()
		setRefreshEnd()
	end
	-- print("_pageIndex" .. tostring(_pageIndex))
	if isTimemode then
		sendGetClubRecordByTime(_pageIndex, response)
	else
		sendGetClubRecordByGid(_pageIndex, response)
	end
end

function UnionClubResult.show(parent, params)
	isTimemode = params.isTimemode
	settled = params.settled
	times = params.times
	gameData = params.gamedata
	resetData()
	
	local function showView(data)
		-- isTimemode = true
		parent = parent or cc.Director:getInstance():getRunningScene()
		local view = UnionClubResult.new(params)
		parent:addChild(view, StringUtils.getMaxZOrder(parent))
	end
	
	loadMoreData(showView)
end


function UnionClubResult.setCallbackFunc(callback)
	callbackFuc = callback
end

loadMoreByGidFunc = sendGetClubRecordByGid
loadMoreDetailByGidFunc = sendGetClubRecordDetailByGid
loadMoreByTimeFunc = sendGetClubRecordByTime
loadMoreDetailByTimeFunc = sendGetClubRecordDetailByTime
loadMoreHandle = loadMoreData
return UnionClubResult 