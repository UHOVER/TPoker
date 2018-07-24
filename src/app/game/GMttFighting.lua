local GMttFighting = {}
local _data = {}
local _players = {}
local _desks = {}

local _middleNode = nil
local _csize1 = cc.size(0,0)
local _titleSize = cc.size(0,0)

--黄、浅蓝、白
local _color2 = cc.c3b(251,238,160)
local _color1 = cc.c3b(142,199,223)
local _color0 = cc.c3b(255,255,255)

local _rect = cc.rect(0,0,0,0)
local _titleOneY = 0
local _bws = 600

local _rankLabel = nil


local function addTitleOne(titles, posxs, titleY)
	local titlebg = UIUtil.scale9Sprite(_rect, 'game/game_fight3.png', _titleSize, cc.p(0,titleY), _middleNode)
    titlebg:setAnchorPoint(0,1)
    UIUtil.addLabelBold(titles[1], 33, cc.p(posxs[1],32), cc.p(0.5,0.5), titlebg, _color1)
    UIUtil.addLabelBold(titles[2], 33, cc.p(posxs[2],32), cc.p(0.5,0.5), titlebg, _color1)
    UIUtil.addLabelBold(titles[3], 33, cc.p(posxs[3],32), cc.p(0.5,0.5), titlebg, _color1)
end

local function clickHandler(sender)
	do return end --暂时让他无效
	local index = sender.tag 
	local table_id = _desks[index]['desk_id']
	if table_id == Single:gameModel():getGamePRYId() then
		print("选择的是当前桌 不能跳转")
		return 
	end

	if not GSelfData.isHavedSeat() and table_id then 
		local function response()
			local GameScene = require 'game.GameScene'
			GameScene.mttChangeDesk(table_id)
		end
		SocketCtrol.exitGame(response)
	end
end

local function desksCell(idx, layer)
	local tdata = _desks[ idx ]
	local cy, cx = _csize1.height / 2, _csize1.width/2

	UIUtil.addLabelBold('牌桌'..tdata['desk_num'], 30, cc.p(120,cy), cc.p(0.5,0.5), layer, _color0)
	UIUtil.addLabelBold(tdata['person_num'], 30, cc.p(460,cy), cc.p(0.5,0.5), layer, _color0)
	local btn = UIUtil.addUIButton({ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0}, cc.p(cx, cy), layer,clickHandler)
	btn:setScale9Enabled(true)
	btn:setContentSize(cc.size(_csize1.width - 10, _csize1.height -10))
	btn.tag = idx
end

local function playersCell(idx, layer)
	local tdata = _players[ idx ]
	local cy = _csize1.height / 2
	UIUtil.addLabelBold(tdata['playerName'], 30, cc.p(120,cy), cc.p(0.5,0.5), layer, _color0)
	UIUtil.addLabelBold(tdata['score'], 30, cc.p(460,cy), cc.p(0.5,0.5), layer, _color0)
end


local function addMatchLayer()
	local tlayer = cc.LayerColor:create(cc.c4b(4,32,43,0),_bws,500)
    tlayer:setPosition(0,display.height-630)
    _middleNode:addChild(tlayer)

    UIUtil.addPosSprite('mtt/mtt_font.png', cc.p(20,360), tlayer, cc.p(0,0))

    local noLevel = GData.getOverBlindLevel()
    local tclock = UIUtil.addPosSprite('mtt/mtt_clock.png', cc.p(295,175), tlayer, cc.p(0,0))
    local timePrompt = UIUtil.addLabelBold('升盲时间', 24, cc.p(116,160), cc.p(0.5,0.5), tclock, _color0)
    local ttime = UIUtil.addLabelBold('00:00:05', 32, cc.p(116,124), cc.p(0.5,0.5), tclock, _color2)
    UIUtil.addLabelBold('禁止参赛级别', 24, cc.p(116,81), cc.p(0.5,0.5), tclock, _color0)
    UIUtil.addLabelBold(noLevel, 32, cc.p(116,45), cc.p(0.5,0.5), tclock, _color2)

    local function scheduleFunc()
    	local seconds = DiffType.getUPBlindSeconds()
    	local ttext = DZTime.secondsHourFormat(seconds)
    	ttime:setString(ttext)

    	if Single:gameModel():isResting() then
    		timePrompt:setString('休息时间')
    	end
    end
    DZSchedule.runSchedule(scheduleFunc, 1, tlayer)
    scheduleFunc()

    local tx1 = 27
    local fs1 = 26
    local fs2 = 30
    local ty1 = 242
    local ty2 = ty1-36
    local ty3 = ty1-72

    UIUtil.addLabelBold('总奖池:', fs1, cc.p(tx1,300), cc.p(0,0), tlayer, _color0)
    UIUtil.addLabelBold(_data['all_bet'], fs2, cc.p(125,300), cc.p(0,0), tlayer, _color2)

    local allPeople = _data['all_person'] + _data['R_num']
    local ANum = _data['A_num']
    if ANum ~= 0 then
	    allPeople = allPeople..'+'..ANum
	end
    UIUtil.addLabelBold('参赛人次:', fs1, cc.p(tx1,ty1), cc.p(0,0), tlayer, _color0)
    local tlabel1 = UIUtil.addLabelBold(allPeople, fs2, cc.p(147,ty1), cc.p(0,0), tlayer, _color2)
    local tlabel1X = tlabel1:getPositionX()
    local tlabel1W = tlabel1:getContentSize().width
    if ANum ~= 0 then
	    local tAX = tlabel1X + tlabel1W + 4
	    UIUtil.addPosSprite('mtt/mtt_A.png', cc.p(tAX,ty1), tlayer, cc.p(0,0))
	end

	local nowLevel = GData.getNowBlindLevel()
	local minus = GData.getUPBlindMinute()..'mins'
	UIUtil.addLabelBold('当前盲注级别:', fs1, cc.p(tx1,ty2), cc.p(0,0), tlayer, _color0)
	UIUtil.addLabelBold(nowLevel, fs2, cc.p(198,ty2), cc.p(0,0), tlayer, _color2)
	UIUtil.addLabelBold('升盲时间:', fs1, cc.p(tx1,ty3), cc.p(0,0), tlayer, _color0)
	UIUtil.addLabelBold(minus, fs2, cc.p(146,ty3), cc.p(0,0), tlayer, _color2)

	local tbg = UIUtil.scale9Sprite(_rect, 'ui/ui_scale9_1.png', cc.size(_bws,90), cc.p(0,70), tlayer)
    tbg:setAnchorPoint(0,0)

    local maxRevive = GData.getMaxAgainTimesText()
    local reviveTimes = _data['revive_num']..'/'..maxRevive

    local function onEvent(event)
		if event == "exit" then
			_rankLabel = nil
		end
	end

    local texts = {'我的排名', '当前参数人数', '复活次数'}
    local tpersonal = _data['now_person']..'/'.._data['all_person']
    local texts2 = {_data['me_rank'], tpersonal, reviveTimes}
    local tposx = {82, 289, 500}
    for i=1,#texts do
    	UIUtil.addLabelBold(texts[i], 26, cc.p(tposx[i],48), cc.p(0.5,0), tbg, _color0)
    	local tlabel = UIUtil.addLabelBold(texts2[i], 32, cc.p(tposx[i],42), cc.p(0.5,1), tbg, _color2)
    	if i == 1 then
    		_rankLabel = tlabel
    		_rankLabel:registerScriptHandler(onEvent)
    	end
    end

	UIUtil.addLabelBold('平均筹码量:', 30, cc.p(189,16), cc.p(1,0), tlayer, _color0)
	UIUtil.addLabelBold(_data['average_bet'], 34, cc.p(191,16), cc.p(0,0), tlayer, _color2)

	local GMttRank = require 'game.GMttRank'
	GMttRank.showMttRank(_middleNode, _bws)
end

local function addListPlayer(title1, title2, tag, data)
	local posxs = {120, 0, 460}
	addTitleOne({'昵称', '', '积分'}, posxs, _titleOneY)

    local tsizeh = 940 - G_SURPLUS_H
    local tsize = cc.size(_csize1.width,tsizeh)
    local tablev = UIUtil.addTableView(tsize, cc.p(0,90), cc.SCROLLVIEW_DIRECTION_VERTICAL, _middleNode)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, _csize1, #_players, playersCell)
end

local function addListDesk()
	local posxs = {120, 0, 460}
	addTitleOne({'牌桌', '', '玩家人数'}, posxs, _titleOneY-60)

	local ty = _titleOneY - 20
    UIUtil.addLabelBold('牌桌数：'..#_desks, 34, cc.p(285,ty), cc.p(0.5,0.5), _middleNode, _color1)

	local tsizeh = 882 - G_SURPLUS_H
    local tsize = cc.size(_csize1.width,tsizeh)
    local tablev = UIUtil.addTableView(tsize, cc.p(0,90), cc.SCROLLVIEW_DIRECTION_VERTICAL, _middleNode)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, _csize1, #_desks, desksCell)
end


local function addListMenu(parent)
	local menuy = display.top - 130
	local menux = 0
	local img1 = 'ui/ui_btn2.png'
	local img2 = 'ui/ui_btn2_c.png'
	local texts = {'赛事', '当前桌玩家', '牌桌列表'}
	local colors = {cc.c3b(142,199,223), cc.c3b(255,255,255), cc.c3b(255,255,255)}
	local btns = {}
	local function handleTop(obj, event)
		local tag = obj:getTag()
		_middleNode:removeAllChildren()

		for i=1,#btns do
			btns[i]:setEnabled(true)
		end
		obj:setEnabled(false)

		if tag == 1 then
			addMatchLayer()
		elseif tag == 2 then
			addListPlayer()
		elseif tag == 3 then
			addListDesk()
		end
	end

	for i=1,#texts do
		local ctlbtn = UIUtil.controlBtn(img1,img2,img2, nil, cc.p(menux,menuy), cc.size(199,85), handleTop, parent)
		ctlbtn:setAnchorPoint(0,1)
		ctlbtn:setTag(i)
		if i == 1 then
			ctlbtn:setEnabled(false)
		end
		UIUtil.setControlBtnLabel(ctlbtn, colors, 32, texts[i])

		menux = menux + 201
		table.insert(btns, ctlbtn)
	end
end


local function createLayer(parent, windowWidth)
	_rankLabel = nil
    _titleOneY = display.top - 235
    _bws = windowWidth
    _titleSize = cc.size(_bws,64)
    _csize1 = cc.size(_bws,60)

    local mttLayer = parent:getChildByName('G_MTT_FIGHTING_LAYER')
    if mttLayer then
    	mttLayer:removeFromParent()
    end

    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    glayer:setName('G_MTT_FIGHTING_LAYER')
    parent:addChild(glayer)
    
	_middleNode = cc.Node:create()
	glayer:addChild(_middleNode)
	addMatchLayer(_middleNode)

    addListMenu(glayer)
end


local function handleData(data)
	_data = data
	_players = data['players']
	_desks = data['desks']

	GameCtrol.handlePlayerRank(data['me_rank'])

	if #_desks > 0 then
		DZSort.sortTables(_desks, StatusCode.SORT, 'desk_num')
	end

	--====test
	-- _data = {}
	-- _players = {}
	-- _desks = {}
	-- _data['all_bet'] = 10992
	-- _data['R_num'] = 2
	-- _data['A_num'] = 1
	-- _data['me_rank'] = 31
	-- _data['all_person'] = 222
	-- _data['now_person'] = 102
	-- _data['revive_num'] = 3
	-- _data['average_bet'] = 12324
	-- for i=1,20 do
	-- 	local desk = {}
	-- 	desk['deskName'] = '牌桌名'..i
	-- 	desk['personNum'] = i * 10
	-- 	desk['personNum'] = desk['personNum']..'人'
	-- 	table.insert(_desks, desk)
	-- end
	-- for i=1,20 do
	-- 	local tab = {}
	-- 	tab['playerName'] = '玩家那么'..i
	-- 	tab['score'] = i * 10
	-- 	table.insert(_players, tab)
	-- end
end

function GMttFighting.showMttFighting(parent, windowWidth, data)
	handleData(data)
	createLayer(parent, windowWidth)
end


--更新玩家排名
function GMttFighting.updatePlayerRank(rankNum)
	if _rankLabel then
		_rankLabel:setString(rankNum)
	end
end


return GMttFighting