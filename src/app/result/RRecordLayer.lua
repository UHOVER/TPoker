-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001
local ViewBase = require("ui.ViewBase")
local RRecordLayer = class("RRecordLayer", ViewBase)
local _csize = cc.size(display.width, 200)
local clolr1 = cc.c3b(245,218,157)
local clolr2 = cc.c3b(145,145,145)
local clolr3 = cc.c3b(218,218,218)
local clolr4 = cc.c3b(255,255,255)
local _data = {}
local _refresh = nil
local _tOldData = {}
local g_parent = {}--存储parent
local g_listener = nil--触屏事件

local actionLDNode = nil--加载节点
local actionLD = nil--加载动画 
local isCanUpdate = true--是否进行滚动更新
local currTouchState = 0--当前手势状态0-抬起，1-按下，2-移动
local isInWaiting = false--是否是等待状态
local ViewPreHight = 0--tbaleView增加新叶前容器高度
local posTY = 0--纪录出事tableView y的位置
local pageNum = 1--分页页数
local currRetDataNum = 0--返回数据数量
local isShowDate = false -- 是否显示日期
local _tableh = 0

function RRecordLayer:touchCell(table,cell)
	if cell:getIdx() == 0 then return end
	
	local function response(data)
		local ResultMsg = require 'result.ResultMsg'
		local rm = ResultMsg:create()
		rm:startResultMsg(g_parent, _tOldData, data, _tOldData['pid'])	
	end

	--1已经有数据了，所以＋1才是点击的数据
	_tOldData = {}
	_tOldData = _data[cell:getIdx()+1]

	-- print("asdsadfk334489fs")
	-- dump(_tOldData)

	if _tOldData['pokerType'] == 'general' or _tOldData['pokerType'] == 'sng'  then
		if(_tOldData['pokerType'] == 'general' and _tOldData['from'] == '赛场' ) then
			
		else
			ResultCtrol.recordStatisticsMsg(response, _tOldData['pid'])
		end
	elseif(_tOldData['pokerType'] == 'mtt') then
		ResultCtrol.recordStatisticsMsgMtt(response, _tOldData['pid'])
	end
end

local function addCellLayer(idx, layer)
	
	local tdata = _data[idx]
	local prevData = _data[idx - 1]

	local colorM1 = cc.c3b(38,75,161)
	local colorL1 = cc.c3b(255,0,0)
	--local colorM2 = cc.c3b(252,96,1)

	--print("mod==="..tostring(tdata['typeMod']))

	local img = 'result/result_black1.png'
	if idx == 1 then
		img = 'result/result_black2.png'
	end
 
	if(tdata['typeMod'] == 1) then
		colorM1 = cc.c3b(38,75,161)
	elseif(tdata['typeMod'] == 2) then
		colorM1 = cc.c3b(252,96,1)
	elseif(tdata['typeMod'] == 4) then
		colorM1 = cc.c3b(160,110,248)
	end
--[[
	if data.histories[i].mod == "general" then
		ctype = 1
	elseif data.histories[i].mod == "sng" then
		ctype = 2
	elseif data.histories[i].mod == "headup" then
		ctype = 3
	end

	tab['typeMod'] = ctype
]]


	--local bg = UIUtil.scale9Sprite(cc.rect(0,0,0,0), img, _csize, cc.p(0,0), layer)
	--bg:setAnchorPoint(0,0)

	local th = _csize.height
	local tw = _csize.width
	local topy = th - 12
	
	if idx == 1 then
		local colorT = cc.c3b(255,255,255)
		--tdata['allBet'] 只有在idx＝1的情况下才有值
		if(tonumber(tdata['allBet']) < 0) then
			colorT = cc.c3b(0,133,60)
		elseif(tonumber(tdata['allBet']) > 0) then
			colorT = cc.c3b(204,0,1)
		end

		UIUtil.addLabelArial('生涯合计', 30, cc.p(52,th-73), cc.p(0,1), layer, cc.c3b(170,170,170))	
		UIUtil.addLabelArial(tdata['allBet'], 49, cc.p(tw/2,th-63), cc.p(0.5,1), layer, colorT)	
		UIUtil.addLabelArial('总记分牌', 26, cc.p(600,15), cc.p(0,0), layer, cc.c3b(170,170,170))	
		UIUtil.addPosSprite("result/rline.png", cc.p(0,0), layer, cc.p(0,0))
		return
	end

	--区别是否是游戏大厅的单挑（临时解决方案，判断name值的第一个汉字是否是‘单’）
	--print("~===="..tdata['name'])
	local danTiaoStr = ""
	local isDan = 0

	if(string.len(tdata['name']) >= 3) then
		danTiaoStr = string.sub(tdata['name'], 1, 3)
	end
	
	if(danTiaoStr == '单') then
		colorM1 = cc.c3b(255,104,104)
		isDan = 1
	end

	--竖线旁边的日期年月日
	local day, month, year = tdata['dayText'],tdata['monthText'],tdata['yearText']
	if prevData then 
		local prevDay,prevMonth,prevYear = prevData['dayText'],prevData['monthText'],prevData['yearText']
		if prevDay == day and prevMonth == month and prevYear == year then 
			day, month, year = "", "",""
		end
	end
	UIUtil.addLabelArial(day, 32, cc.p(85,th-42), cc.p(1,1), layer, cc.c3b(153,154,156), 'Arial-BoldMT')
	UIUtil.addLabelArial(month, 26, cc.p(85,th-80), cc.p(1,1), layer, cc.c3b(153,154,156), 'Arial-BoldMT')
	UIUtil.addLabelArial(year, 20, cc.p(85,th-108), cc.p(1,1), layer, cc.c3b(153,154,156), 'Arial-BoldMT')
	

	--竖线
	local linex = 112
	local vertical = UIUtil.scale9Sprite(cc.rect(0,0,0,0), 'result/result_line1.png', cc.size(2,th), cc.p(linex,0), layer)
	vertical:setAnchorPoint(0.5,0)
	--竖线穿过的闹钟图标
	UIUtil.addPosSprite('result/result_time.png', cc.p(linex,th - 40), layer, cc.p(0.5,1))
	
	--mtt图标
	if(isDan == 1) then
		UIUtil.addPosSprite("result/result_tag5.png", cc.p(linex,th/2 - 30), layer, nil)
	else
		UIUtil.addPosSprite(tdata['typeImg'], cc.p(linex,th/2- 30), layer, nil)
	end
	--UIUtil.addLabelArial(tdata['typeText'], 19, cc.p(linex,th/2-11.5), cc.p(0.5,0.5), layer, clolr4)


	--时间 + 来自XXXX
	local txtTitle = UIUtil.addLabelArial(tdata['title'], 28, cc.p(145.5,th - 41), cc.p(0,1), layer, cc.c3b(136,136,136))
	--玩家名称
	UIUtil.addLabelArial(tdata['name'], 35, cc.p(270,th/2 + 8), cc.p(0,1), layer, colorM1)
	--头像
	local stencil,head = UIUtil.addUserHead(cc.p(141.5 +55,th/2+15 - 50), tdata['headUrl'], layer, true)
	stencil:setScale(0.85)
	head:setScale(0.85)

	--增加一条来自
	--UIUtil.addLabelArial(tdata['fromWhere'], 18, cc.p(150,th/2 - 43), cc.p(0,1), layer, clolr2)

	-- 标示:人、bet
	local ty = 24
	local sx = 200
	UIUtil.addPosSprite(tdata['imgTag1'], cc.p(sx + 70,ty + 10), layer, cc.p(0,0.5))
	UIUtil.addLabelArial(tdata['textTag1'], 30, cc.p(sx+105,ty + 10), cc.p(0,0.5), layer, cc.c3b(170,170,170))
	local tag2x = sx+165 + 20

	--闹钟和钱币的图片
	if tdata['imgTag2'] ~= '' then
		--tag2x = sx+145
		UIUtil.addPosSprite(tdata['imgTag2'], cc.p(sx+190 + 20,ty+ 10), layer, cc.p(0,0.5))
	else
		UIUtil.addPosSprite("result/rmoney.png", cc.p(sx+190 + 20,ty+ 10), layer, cc.p(0,0.5))
	end

	--后面跟着的数据
	UIUtil.addLabelArial(tdata['textTag2'], 30, cc.p(tag2x + 70,ty+ 10), cc.p(0,0.5), layer, cc.c3b(170,170,170))


	--num bet
	local label = cc.Label:createWithSystemFont(tdata['numbet'], 'Arial', 25)
	local ttw = label:getContentSize().width + 20
	if ttw < 60 then
		ttw = 60
	end
	local numbg = UIUtil.scale9Sprite(cc.rect(30,0,30,0), tdata['numbetImg'], cc.size(ttw,48), cc.p(717,20), layer)
	numbg:setAnchorPoint(1,0)
	numbg:setOpacity(0)
	
	if(tdata['numbetImg'] == "result/result_numbg3.png") then
		colorL1 = cc.c3b(204,0,1)
	elseif (tdata['numbetImg'] == "result/result_numbg2.png")then
		colorL1 = cc.c3b(0,133,60)
	else
		colorL1 = cc.c3b(170,170,170)
	end

	--红色或者绿色的积分
	UIUtil.addLabelArial(tdata['numbet'], 30, cc.p(ttw/2,122), cc.p(0.5,0.5), numbg, colorL1)

	--添加保险标志
	if(tdata['secure'] == 1) then
	 	UIUtil.addPosSprite('result/r_baoxianju.png', cc.p(141.5 + txtTitle:getContentSize().width + 10,topy-25), layer, cc.p(0,1))
	end
--[[
	local th = _csize.height
	local topy = th - 12
	UIUtil.addLabelArial("testidx="..idx, 28, cc.p(51,topy-40), cc.p(0.5,1), layer, clolr1, 'Arial-BoldMT')
]]
end


local function numberOfCellsInTableView(table)
    return #_data
end

local function addNewData(olddata, newdata)
    local datas = ResultCtrol.getRecordResult2(newdata)
    local currNum = #olddata

    currRetDataNum = #datas

    for i=1,#datas do
        olddata[currNum + i] = datas[i]
    end

    --对分页按时间排序
    table.sort(olddata, function ( a, b )
    		if(a.start_time ~= nil and b.start_time ~= nil) then
    			return a.start_time > b.start_time
    		end
    	end)
end

local function scrollViewDidScroll(view)
	
	local tmpY = view:getContentOffset().y
	tmpY = tmpY - 30

	if(tmpY <= 0) then
		tmpY = 0
	end

	tmpY = tmpY/120

	if(tmpY > 1) then
		tmpY = 1
	end

	actionLDNode:getChildByName("action"):setOpacity(255*tmpY)

	if(isInWaiting == true) then
		if(view:getContentOffset().y < 120) then
			view:setContentOffset(cc.p(0, 120), false)
			actionLD:play("load", true)
		end
	end

    if(isCanUpdate == false) then
        return
    end
--[[
    print("-------scrollViewDidScroll--------")

    print("maxContainerOffsety="..view:maxContainerOffset().y)
    print("minContainerOffsety="..view:minContainerOffset().y)
    print("getContentOffsety="..view:getContentOffset().y)
    print("ContentSizeH="..view:getContentSize().height)
    print("viewSizeH="..view:getViewSize().height)
    print("ContainerSizeH="..view:getContainer():getContentSize().height)
]]
    ViewPreHight = view:getContainer():getContentSize().height

    if view:getContainer():getContentSize().height < view:getViewSize().height then
		actionLDNode:setVisible(false)
	else
		actionLDNode:setVisible(true)
	end

    if(view:getContentOffset().y > 120 and view:getContainer():getContentSize().height >= view:getViewSize().height and currTouchState == 0) then 
        isCanUpdate = false
        isInWaiting = true
        print("hhh0-----")
        --actionLDNode:stopAllActions()
        view:setTouchEnabled(false)
		view:getContainer():stopAllActions()
        view:getContainer():runAction(cc.Sequence:create(
        	cc.DelayTime:create(1),
            cc.MoveTo:create(0.1, cc.p(view:getContainer():getPositionX(), 0)),
            --cc.MoveTo:create(0.38, cc.p(view:getPositionX(), 120--[[posTY + 120]])),
            --[[cc.CallFunc:create( 
                function(sender)
                	--view:setTouchEnabled(false)
                	isInWaiting = true
                	print("hhh1-----")
                end),
    		]]
            --cc.DelayTime:create(0.6),
            cc.CallFunc:create( 
                function(sender)
                	print("hhh1-----")
                	--actionLD:play("load", true)
					print("hhh2-----")
                    local function response(data)
                    	
                    	isInWaiting = false
                    	--sender:getContainer():runAction(cc.MoveTo:create(0.38, cc.p(sender:getContainer():getPositionX(), 0)))

                        actionLD:play("stop", true)
						print("hhh4-----")
                        --view:getContainer():stopAllActions()
                       -- view:runAction(cc.Sequence:create(
                        	--cc.DelayTime:create(0.5),
                            --cc.MoveTo:create(0.1, cc.p(view:getContainer():getPositionX(), 0)),
                            --cc.DelayTime:create(0.38),
                           -- cc.CallFunc:create( 
                                --function(sender)
                                	print("hhh5-----")

                                	addNewData(_data, data)
                                	--如果下一页有数据分页＋1
                                	if(currRetDataNum > 0) then
                                		pageNum = pageNum + 1
                                	end

			                        view:reloadData()

			                        --移动层高度没变化，证明没加载数据，把移动层设置y为0就可以了
			                        if(ViewPreHight == view:getContainer():getContentSize().height) then
			                            view:setContentOffset(cc.p(0, 0), false)
			                        --移动层高度有变化，证明有加载数据，把移动层设置y为 旧的高度 － 当前新的高度，保持位置不变化
			                        else
			                            view:setContentOffset(cc.p(0, ViewPreHight - view:getContainer():getContentSize().height), false)
			                        end

                                    isCanUpdate = true
                                    view:setTouchEnabled(true)
                               --	end)
                        --))
                    end

                    local tab = {}
                    print("hhh3----send httpURL-----")
				    --分页处理
				    tab['page'] = pageNum + 1 --是int页数(从1开始)
				    tab['every_page'] = 15 -- 是	int	每页多少条
				    MainCtrol.filterNet(PHP_PERSON_RECORD, tab, response, PHP_POST, nil, true)

                end)
            )) 
    end
end

function RRecordLayer:upPull()
	DZAction.delateTime(_refresh, 6, function()
		_refresh:upFinished()
	end)
end

function RRecordLayer:downPull(idx)
	 --test
    -- local function addData()
    -- 	local tdata = ResultCtrol.getRecordResult()
    -- 	for i=1,#tdata do
    -- 		table.insert(_data, tdata[ i ])
    -- 	end
    -- end

--[[
	DZAction.delateTime(_refresh, 6, function()
		_refresh:downFinished()
	end)
]]
end


local function onTouchBegin(touch, event)
	--print("ttttttbbbbb")
	currTouchState = 1
    return true
end

local function onTouchMoved(touch, event)
	--print("ttttttmmmmmm")
	currTouchState = 2
end

local function onTouchEnded(touch, event)
    --print("tttttteeeeee")
    currTouchState = 0
end


function RRecordLayer:createLayer()
	local function tableCellTouched(table,cell)
		self:touchCell(table, cell)
	end
	
	actionLDNode = nil--加载节点
	actionLD = nil--加载动画 
	currTouchState = 0
	isCanUpdate = true--是否进行滚动更新
	isInWaiting = false
	ViewPreHight = 0--tbaleView增加新叶前容器高度
	posTY = 0--纪录出事tableView y的位置
	pageNum = 1--分页页数
	currRetDataNum = 0

	actionLDNode = cc.CSLoader:createNode("action/loadingAction.csb")
    actionLD = cc.CSLoader:createTimeline("action/loadingAction.csb")
    actionLDNode:runAction(actionLD)
    --actionLD:gotoFrameAndPlay(0, true)

    -- local sH = 1210 - G_SURPLUS_H
    local sH = _tableh+20
	local tsize = cc.size(_csize.width, sH)
    --local RefreshTable = require 'ui.RefreshTable'
    local rt = UIUtil.addTableView(tsize, cc.p(0, 0), cc.SCROLLVIEW_DIRECTION_VERTICAL, self)--RefreshTable:create(tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, self)
    local tablev = rt
    tablev:addChild(actionLDNode)
    actionLDNode:setPosition(cc.p(_csize.width/2, -70))
    --_refresh = rt
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tablev:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tablev:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tablev:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tablev)
    g_listener = listener


    -- local colorLayer = cc.LayerColor:create(cc.c4b(255,255,0, 170))
    -- colorLayer:setContentSize(cc.size(display.width, sH))
    -- self:addChild(colorLayer, 100)

	--eventDispatcher:addEventListenerWithFixedPriority(listener, 0)
    -- local tmpSize = cc.size(_csize.width, posy)
    DZUi.addTableView(tablev, _csize, nil, addCellLayer, true, nil)
	tablev:setBounceable(true)
	tablev:setTouchEnabled(true)

	posTY = tablev:getPositionY()

	 --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "exit" then
            if(g_listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(g_listener)
                print("llll---removeR")
            end
        end
    end
    
    self:registerScriptHandler(onNodeEvent)

--[[
    rt:init(1, function()
    	self:upPull()
    end, function(idx)
    	self:downPull(idx)
    end)
]]
   self:setContentSize(tsize)
end

function RRecordLayer:startRecord(parent, data, posy)
	_tableh = posy
	_data = ResultCtrol.getRecordResult(data)
	g_parent = parent
	parent:addChild(self)
	self:createLayer()
	if posy then 
		posy = posy - self:getContentSize().height +20
	end
	self:setPositionY(posy or 0)
end

return RRecordLayer
-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001