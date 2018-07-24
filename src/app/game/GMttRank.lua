local GMttRank = {}
local _data = {}
local _csize = cc.size(0,0)
local IMGS = {'ui/ui_reward1.png', 'ui/ui_reward2.png', 'ui/ui_reward3.png'}
local NOW_RANK = 1			--实时排名
local ALL_RANK = 2			--所有排名
local _node = nil
local _loadpos = cc.p(0,0)
local _tableH = 0

local function ranksCell(idx, layer)
	local tdata = _data[ idx ]
	local cy = _csize.height / 2
	local color1 = cc.c3b(255,255,255)
	local meId = Single:playerModel():getId()

	if meId == tdata['playerId'] then
		color1 = cc.c3b(142,199,223)

		GameCtrol.handlePlayerRank(idx)
		local GMttFighting= require 'game.GMttFighting'
		GMttFighting.updatePlayerRank(idx)
	end

	local tname = UIUtil.addLabelBold(tdata['playerName'], 30, cc.p(220,cy), cc.p(0.5,0.5), layer, color1)
	UIUtil.addLabelBold(tdata['score'], 30, cc.p(480,cy), cc.p(0.5,0.5), layer, color1)

	if idx < 4 then
		UIUtil.addPosSprite(IMGS[idx], cc.p(85,cy), layer, cc.p(0.5,0.5))
	else
		UIUtil.addLabelBold(idx, 30, cc.p(85,cy), cc.p(0.5,0.5), layer, color1)
	end

	local rightx = tname:getContentSize().width/2 + tname:getPositionX() + 8
	if tdata['R_num'] > 0 then
		UIUtil.addPosSprite('mtt/mtt_R_bg.png', cc.p(rightx,cy), layer, cc.p(0,0.5))
		UIUtil.addLabelArial('R', 28, cc.p(rightx+3,cy), cc.p(0,0.5), layer, cc.c3b(0,0,0))
		UIUtil.addLabelArial(tdata['R_num'], 16, cc.p(rightx+24,cy-5), cc.p(0,0.5), layer, cc.c3b(0,0,0))

		rightx = rightx + 45
	end

	if tdata['A_num'] > 0 then
		UIUtil.addPosSprite('mtt/mtt_A.png', cc.p(rightx,cy), layer, cc.p(0,0.5))
	end
end

local function numberOfCellsInTableView(table)
    return #_data
end


local function getPageData(pageNum)
	-- local endNum = 10
	-- if pageNum == 3 then
	-- 	endNum = 5
	-- elseif pageNum > 3 then
	-- 	endNum = 0
	-- end
	local rets = {}

	-- for i=1,endNum do
	-- 	local tab = {}
	-- 	tab['playerName'] = '玩家名'..i
	-- 	tab['score'] = i * 10
	-- 	tab['playerId'] = i
	-- 	tab['R_num'] = i
	-- 	tab['A_num'] = 1
	-- 	table.insert(rets, tab)
	-- end

	return rets
end

local function createLayer(tag)
    local RefreshTable = require 'ui.RefreshTable'
    local tsize = cc.size(_csize.width,_tableH)
    local rft = RefreshTable:create(tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, _node)

    local isExit = false
    local function onEvent(event)
		if event == "exit" then
			isExit = true
		end
	end
	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	rft:addChild(tnode)

    local function refreshBack(pageData)
    	if isExit then return end
    	rft:downFinished(pageData)
    end
    local function refreshDown(pageNum)
    	DZAction.delateTime(nil, 2, function()
    		local tdata = getPageData(pageNum)
    		StringUtils.linkArray(_data, tdata)
    		refreshBack(tdata)
    	end)
    	-- SocketCtrol.mttRankData(function(data)
    	-- 	StringUtils.linkArray(_data, data['ranks'])
    	-- 	refreshBack(data['ranks'])
    	-- end, tag, pageNum)
    end

	rft:init(1, function()end, refreshDown)
	rft:setRefreshH(50)

    local tablev = rft:getTableView()
    -- local tablev = UIUtil.addTableView(tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, _node)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tablev:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    DZUi.addTableView(tablev, _csize, #_data, ranksCell, true)
end


local function handleData(data)
	_data = data['ranks']
	--====test
	-- _data = {}
	-- for i=1,10 do
	-- 	local tab = {}
	-- 	tab['playerName'] = '玩家名'..i
	-- 	tab['score'] = i * 10
	-- 	tab['playerId'] = i
	-- 	tab['R_num'] = i
	-- 	tab['A_num'] = 1
	-- 	table.insert(_data, tab)
	-- end
end


local function netRequest(tag)
	_node:removeAllChildren()

	local tnode = ViewCtrol.setWaitServerAni(_node, _loadpos)
	local function onEvent(event)
		if event == "exit" then
			_node = nil
		end
	end
	_node:registerScriptHandler(onEvent)
	
	local function netBack(data)
		if _node then
			_node:removeAllChildren()
			handleData(data)
			createLayer(tag)
		end
	end

	SocketCtrol.mttRankData(netBack, tag, 1)
end


function GMttRank.showMttRank(parent, bsw)
	_csize = cc.size(bsw,60)

	_tableH = 530 - G_SURPLUS_H
	local layerH = _tableH + 86
	_loadpos = cc.p(bsw/2,_tableH/2)

	local layer = cc.LayerColor:create(cc.c4b(4,200,100,0), _csize.width, layerH)
    layer:setPosition(0,86)
    parent:addChild(layer)

    _node = cc.Node:create()
    layer:addChild(_node)

    local texts = {'实时排名', '查看全部'}
    local img1 = 'ui/ui_btn2.png'
	local img2 = 'ui/ui_btn2_c.png'
	local colors = {cc.c3b(142,199,223), cc.c3b(255,255,255), cc.c3b(255,255,255)}
	local btns = {}
	local function handleDown(obj, event)
		for i=1,#btns do
			btns[i]:setEnabled(true)
		end
		obj:setEnabled(false)

		if obj:getTag() == 1 then
			netRequest(NOW_RANK)
		elseif obj:getTag() == 2 then
			netRequest(ALL_RANK)
		end
	end

	local menux = 0
	for i=1,#texts do
		local ctlbtn = UIUtil.controlBtn(img1,img2,img2, nil, cc.p(menux,layerH), cc.size(299,85), handleDown, layer)
		ctlbtn:setAnchorPoint(0,1)
		ctlbtn:setTag(i)
		if i == 1 then
			ctlbtn:setEnabled(false)
		end
		UIUtil.setControlBtnLabel(ctlbtn, colors, 37, texts[i])

		menux = menux + 300
		table.insert(btns, ctlbtn)
	end

	DZAction.delateTime(layer, 1, function()
		netRequest(NOW_RANK)
	end)
end


return GMttRank