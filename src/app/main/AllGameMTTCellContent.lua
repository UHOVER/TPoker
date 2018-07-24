--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--查看MTT 详细内容弹框
--
local g_self = nil

--切换panel
local function showPanel(sender )
	print("tg==="..sender:getTag())

	if(g_self.m_SELECT_STATUS == sender:getTag()) then
		return
	end

	g_self.m_SELECT_STATUS = sender:getTag()

    for i = 1, 4 do
    	g_self.m_panelArrs[i]:setVisible(false)
    	g_self.m_btnArrs[i]:loadTexture("bg/all_mttDetailBtn"..i..".png")
    end

--[[
    for i = 2, 4 do
    	g_self.m_tableArrs[i]:reloadData()
    end
]]
	g_self.m_panelArrs[sender:getTag()]:setVisible(true)
    g_self.m_btnArrs[sender:getTag()]:loadTexture("bg/all_mttDetailBtnUn"..sender:getTag()..".png")

    if(sender:getTag() == 1) then
        --发送消息
        local function response(data)
            g_self.retData = data
            g_self:initData()
            g_self:initPanel1()
        end

        local tab = {}
        tab['mtt_id'] = g_self.m_idx
        MainCtrol.filterNet("MttOverview", tab, response, PHP_POST)

    elseif(sender:getTag() == 2) then
        --发送消息
        local function response(data)
            if(data ~= nil) then
                --print("asadau9889234sj")
                --dump(data)
                local playersData = data.mtt_players.players_data
                --print("asadau9889234sj---")
                --dump(playersData)

                if(playersData ~= nil) then
                    g_self.m_tableArrs[2].data = playersData
                    g_self.m_tableArrs[2]:reloadData()
                end
            end
        end
        
        local tab = {}
        tab['mtt_id'] = g_self.m_idx
        MainCtrol.filterNet("mttPlayers", tab, response, PHP_POST)

    elseif(sender:getTag() == 3) then
        g_self.m_tableArrs[3]:reloadData()
    elseif(sender:getTag() == 4) then
        --发送消息
        local function response(data)
            g_self.m_tableArrs[4].data = data["reward"]
            g_self.m_tableArrs[4]:reloadData()
        end

        local tab = {}
        tab['mtt_id'] = g_self.m_idx
        MainCtrol.filterNet("game_hall/MttReward", tab, response, PHP_POST)
    end
end

--退出
local function handleReturn(sender)
	g_self:removeFromParent()
	g_self = nil
end

--处理万以上数字
local function mWanNumber(num)
    local ret = tonumber(num)
    
    if(ret >= 10000) then
        ret = math.floor(ret/10000)
        ret = tostring(ret).."万"
    end

    return ret
end

--处理时间数字
local function mNumber(num)
	local ret = num

	if(ret < 10) then
		ret = "0"..tostring(ret) 
	end
	
	return ret
end

------tableView-----------
local function updateCellContent2(idx, layer)


    if(g_self.m_tableArrs[2].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[2].data[idx]
    --print("hhh~~~~~")
    --dump(cdata)

	local tCell = layer:getChildByName("Panel_root")
         
    local img = ccui.Helper:seekWidgetByName(tCell, "Image_rFlag")
    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_rNum")

    if(idx <= 3) then
    	img:loadTexture("bg/all_mttDetailR"..idx..".png")
    	txt:setVisible(false)
    else
    	img:loadTexture("bg/all_mttDetailCircle.png")
    	txt:setVisible(true)
    	txt:setString(idx)
    end

    local txtName = ccui.Helper:seekWidgetByName(tCell, "Text_name")
    txtName:setString(cdata["user_name"])

    local txtScore = ccui.Helper:seekWidgetByName(tCell, "Text_feeScore")
    txtScore:setString(mWanNumber(tonumber(cdata["get_back"])))

    --print("uuuu2")
end

local function updateCellContent3(idx, layer)


    if(g_self.m_tableArrs[3].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[3].data[idx]
    --print("hhh~~~~~")
    --dump(cdata)

	local tCell = layer:getChildByName("Panel_root")
         
    
    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_level")
    txt:setString(cdata["level"])

    txt = ccui.Helper:seekWidgetByName(tCell, "Text_blind")
    local BBNum = tonumber(cdata["big_blind"])
    local lBNum = BBNum/2
    txt:setString(lBNum.."/"..BBNum)

    txt = ccui.Helper:seekWidgetByName(tCell, "Text_beforeBlind")
    txt:setString(cdata["ante"])


    --print("uuuu3")
end

local function updateCellContent4(idx, layer)

	if(g_self.m_tableArrs[4].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[4].data[idx]
    --print("hhh~~~~~")
    --dump(cdata)

	local tCell = layer:getChildByName("Panel_root")       
    
    local img = ccui.Helper:seekWidgetByName(tCell, "Image_rankF")
    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_level")
    
    if(idx <= 3) then
    	img:loadTexture("bg/all_mttDetailRwd"..idx..".png")
    	txt:setVisible(false)
    else
    	img:loadTexture("bg/all_mttDetailCircle.png")
    	txt:setVisible(true)
    	txt:setString(idx)
    end

    txt = ccui.Helper:seekWidgetByName(tCell, "Text_bp")
    txt:setString(tostring(tonumber(cdata)*100).."%")
	--print("uuuu4")
    
end

local function numberOfCellsInTableView(table)
--[[
	do
		return 20
	end
]]
    if(table.data == nil) then 
        return 0
    end
    
    return #table.data
end

local function cellSizeForTable(table,idx)
    return table.cellSize.width, table.cellSize.height
end

local function tableCellAtIndex(table, idx)
    idx = idx + 1--默认从0开始，lua里没0所以+1
    local cell = table:dequeueCell() 
    
    --如果table 队列里取出的cell为空，重新创建一个
    if nil == cell then
        cell = cc.TableViewCell:new()
        local layer = cc.CSLoader:createNodeWithVisibleSize("scene/AllGameCellS"..table.tIdx..".csb")
        layer:setContentSize(table.cellSize)
        layer:setTag(123)
        cell:addChild(layer)
    end

    --根据idx，重新更新cell内容
    table.callBack(idx, cell:getChildByTag(123))

    return cell
end

-------------------------------------end---------------------------------------
--------------------------------------------------------------------------------

--类
local AllGameMTTCellContent = class("AllGameMTTCellContent", function ()
    return cc.Node:create()
end)

--创建处理时间的逻辑节点
--labelMin-显示分钟的文本控件
--labelSec-显示秒的文本控件
--min-分钟值
--sec-秒值
function AllGameMTTCellContent:ctor(data)
	self.retData = data
    self.m_idx = data.idx--mtt ID
    self.m_data = nil

	self:initData()

	self.m_root = nil
	self.m_SELECT_STATUS = 1--当前选择的状态1概述 2排名 3盲注 4奖励
	self.m_panelArrs = {}--存储显示的4个层
	self.m_btnArrs = {}--存储4个按钮
	self.m_tableArrs = {}--存储3个tableView
	self.m_callBackArrs = {[2] = updateCellContent2, [3] = updateCellContent3, [4] = updateCellContent4}
	--self.m_dataArrs = {[2] = self.m_data["ranking"], [3] = self.m_data["blind"], [4] = self.m_data["reward"]}
    self.m_dataArrs = {[2] = {}, [3] = {}, [4] = {}}
    self:init()
end


function AllGameMTTCellContent:init()
	--print("hhh2222~~~~~")
	--dump(self.m_data)

	g_self = nil
	g_self = self

    --初始化data3数据 盲注数据 
    self.m_dataArrs[3] = require("main.MainLayer"):getBlindData()

	--初始化层
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(self, StringUtils.getMaxZOrder(runScene))

    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/AllGameMTTCellContent.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")
     
	local cBtn = ccui.Helper:seekWidgetByName(self.m_root, "Button_close")
	cBtn:touchEnded(handleReturn)
    
    --初始化按钮和显示层
    for i = 1, 4 do
    	self.m_panelArrs[i] = ccui.Helper:seekWidgetByName(self.m_root, "Panel_show"..i)
    	self.m_panelArrs[i]:setVisible(false)
    	self.m_btnArrs[i] = ccui.Helper:seekWidgetByName(self.m_root, "Image_btn"..i)
    	self.m_btnArrs[i]:touchEnded(showPanel)
    	self.m_btnArrs[i]:setTag(i)
    end

    self.m_panelArrs[1]:setVisible(true)

    --初始化tableView
    --创建列表
    --为了保证一致性，从2开始
    for i = 2, 4 do
	    local modelP = ccui.Helper:seekWidgetByName(self.m_panelArrs[i], "Panel_t")
	    local tLayer = cc.CSLoader:createNodeWithVisibleSize("scene/AllGameCellS"..i..".csb")
	    local tCell = tLayer:getChildByName("Panel_root")
	    --print('cccccsssssss=='.._gcsize.width..",".._gcsize.height)
	    --print('mmmssss=='..modelP:getContentSize().width..","..modelP:getContentSize().height)
	    local tableView = cc.TableView:create(modelP:getContentSize())
	    tableView.cellSize = tCell:getContentSize()
	    tableView.tIdx = i
	    tableView.callBack = self.m_callBackArrs[i]
	    tableView.data = self.m_dataArrs[i]
	    tableView:initWithViewSize(modelP:getContentSize())
	    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	    tableView:setPosition(cc.p(0, 0))
	    tableView:setDelegate()
	    modelP:addChild(tableView)
	    self.m_tableArrs[i] = tableView
	    --注册列表相关事件
	    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)   
	    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
	    tableView:setBounceable(true)
	    tableView:reloadData()
	end

	--初始化panel1
	self:initPanel1()

    --适配处理
    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("rrrrrr="..ratio)
    -- if ratio >= 1.5 then
    --     print("iiiiiihhhhhh")
    --     local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    --     local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    --     local width = framesize.width / scaleY
    --     local height = framesize.height / scaleY
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    --     local realx = (framesize.width / scaleY - 750)*0.5
    --     self:setPosition(cc.p(realx, 0))
    -- else
        -- 
    -- end
    local realx = StringUtils.setKCAdapter()
    if realx then
        self:setPosition(cc.p(realx, 0))
    end
    
end

----初始化panel1显示的数据
function AllGameMTTCellContent:initPanel1()

    --如果计时器已经存在，移除计时器
    if(g_self:getChildByTag(3315) ~= nil) then
        g_self:getChildByTag(3315):removeFromParent()
    end

	local txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_fee")
	local qNum = tonumber(self.m_data["summary"].matchFee)
	local hNum = tonumber(self.m_data["summary"].matchFeeCost)
	txt:setString(mWanNumber(qNum).."+"..mWanNumber(hNum))

	txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_pNum")
	txt:setString(self.m_data["summary"].matchPeopleNum)

	txt = ccui.Helper:seekWidgetByName(self.m_root, "Text_firstFee")
	txt:setString(self.m_data["summary"].matchFiretChip)

	local txtTime = ccui.Helper:seekWidgetByName(self.m_root, "Text_time")
	local panelTime = ccui.Helper:seekWidgetByName(self.m_root, "Panel_time")
	txtTime:setVisible(false)
	panelTime:setVisible(false)
	--明天
	if(self.m_data["summary"].matchDayStatus == "1") then
		txtTime:setVisible(true)
		txtTime:setString("明天"..mNumber(tonumber(self.m_data["summary"].matchTimeHours))..":"..mNumber(tonumber(self.m_data["summary"].matchTimeMin)))
	--今天
	elseif(self.m_data["summary"].matchDayStatus == "2") then
		txtTime:setVisible(true)
		txtTime:setString("今天"..mNumber(tonumber(self.m_data["summary"].matchTimeHours))..":"..mNumber(tonumber(self.m_data["summary"].matchTimeMin)))
	--倒计时
	elseif(self.m_data["summary"].matchDayStatus == "3") then
		panelTime:setVisible(true)
		local txtMin = ccui.Helper:seekWidgetByName(self.m_root, "Text_timeDJSMin")
		local txtSec = ccui.Helper:seekWidgetByName(self.m_root, "Text_timeDJSSec")
		local minNum = tonumber(self.m_data["summary"].matchTimeMin)
		local secNum = tonumber(self.m_data["summary"].matchTimeSec)
		txtMin:setString(mNumber(minNum))
		txtSec:setString(mNumber(secNum))
		local logicNode = require('main.AllGameTimeLogicNode'):create(txtMin, txtSec, tonumber(self.m_data["summary"].matchTimeMin), tonumber(self.m_data["summary"].matchTimeSec))
	   	logicNode:setTag(3315)
        g_self:addChild(logicNode)
    --正在进行
	elseif(self.m_data["summary"].matchDayStatus == "4") then
        txtTime:setVisible(true)
        txtTime:setString("正在进行中...")
    end

	
	--初始化R和A
	local pR = ccui.Helper:seekWidgetByName(self.m_root, "Panel_R")
	local pA = ccui.Helper:seekWidgetByName(self.m_root, "Panel_A")
	pR:setVisible(false)
	pA:setVisible(false)

	if(self.m_data["summary"].rebuy ~= "") then
		pR:setVisible(true)
		ccui.Helper:seekWidgetByName(self.m_root, "Text_RContent"):setString(self.m_data["summary"].rebuy)
	end	

	if(self.m_data["summary"].addon ~= "") then
		pA:setVisible(true)
		ccui.Helper:seekWidgetByName(self.m_root, "Text_AContent"):setString(self.m_data["summary"].addon)
	end	
end

----初始化数据，测试
function AllGameMTTCellContent:initData()

--收到的协议类型
--[[
    {
        "addon"        = 1
        "cost"         = 20
        "count"        = 0
        "current_time" = 1481798576
        "entry_fee"    = 200
        "entry_stop"   = 8
        "inital_score" = 2000
        "rebuy_num"    = 3
        "start_time"   = 1480932945
    }
]]

    self.m_data = {}
    self.m_data.summary = {}
    --print("iniiiinnndata")
    --dump(self.retData)

    self.m_data["summary"]["matchFee"] = self.retData["entry_fee"]
    self.m_data["summary"]["matchFeeCost"] = self.retData["cost"]
    self.m_data["summary"]["matchFiretChip"] = self.retData["inital_score"]
    self.m_data["summary"]["matchPeopleNum"] = self.retData["count"]

    --比赛时间协议处理
    --根据current_time和start_time，判断显示哪种时间类型
    --"matchDayStatus" 1明天 2今天 3倒计时
    local cTime = tonumber(self.retData.current_time)
    local sTime = tonumber(self.retData.start_time)
    --print("iiiiii===="..i)
    --print("init---- c="..cTime.." s="..sTime)
    --d = {year=2005, month=11, day=6, hour=22,min=18,sec=30,isdst=false}

    local tTime = os.date("*t", cTime);
    local cday = tTime['day']
    local chour = tTime['hour']
    local cmin = tTime['min']
    local csec = tTime['sec']
    --print("init----cd="..cday.." ch="..chour.." cm="..cmin.." csec="..csec)

    tTime = os.date("*t", sTime);
    local sday = tTime['day']
    local shour = tTime['hour']
    local smin = tTime['min']
    local ssec = tTime['sec']
    --print("init---- sd="..sday.." sh="..shour.." sm="..smin.." ssec="..ssec)
    --print(" ")

    --如果当前时间 大于 开赛时间，证明比赛已经开始了，显示时间这块不知如何
    --
    if(cTime > sTime) then
        self.m_data["summary"].matchDayStatus = 4
    --比赛还没开始
    else
        --根据日数判断是今天还是明天
        --如果是明天的比赛，判断距离明天的日期
        if(sday - cday >= 1) then
            --判断是否需要倒计时
            --小时数相差1，需要计算分钟数来判断是否需要倒计时
            if(shour + 24  - chour <= 1) then
                --如果分钟小于60证明开始读秒
                if(smin + 60 - cmin < 60) then
                    self.m_data["summary"].matchDayStatus = 3
                --大于60，还是属于明天的
                else
                    self.m_data["summary"].matchDayStatus = 1
                end
            
            --小时数相差大于等于2，证明是明天的比赛
            else
                self.m_data["summary"].matchDayStatus = 1
            end 

        --今天的比赛
        else
            --小时数相差1，需要计算分钟数来判断是否需要倒计时
            if(shour - chour == 1) then
                --如果分钟小于60证明开始读秒
                if(smin + 60 - cmin < 60) then
                    self.m_data["summary"].matchDayStatus = 3
                --大于60，还是属于今天的
                else
                    self.m_data["summary"].matchDayStatus = 2
                end
            --如果等于0，证明不足一小时，进入倒计时
            elseif(shour - chour == 0) then
                self.m_data["summary"].matchDayStatus = 3
            --小时数相差大于等于2，证明是今天的比赛
            else
                self.m_data["summary"].matchDayStatus = 2
            end
        end
    end

    --如果是倒计时，现实当前时间
    if(self.m_data["summary"].matchDayStatus == 3) then
        self.m_data["summary"].matchTimeHours = tostring(shour)
        --self.m_data["summary"].matchTimeMin = tostring(smin + 60 - cmin)
        --self.m_data["summary"].matchTimeSec = tostring(sTime - cTime)
        self.m_data["summary"].matchTimeMin = tostring(math.floor((sTime - cTime)/60))
        self.m_data["summary"].matchTimeSec = tostring((sTime - cTime) - math.floor((sTime - cTime)/60)*60)

    --如果是明天或者今天，现实开始时间
    elseif(self.m_data["summary"].matchDayStatus == 1 or self.m_data["summary"].matchDayStatus == 2) then
        self.m_data["summary"].matchTimeHours = tostring(shour)
        self.m_data["summary"].matchTimeMin = tostring(smin)
        self.m_data["summary"].matchTimeSec = tostring(ssec)
    end

    self.m_data["summary"].matchDayStatus = tostring(self.m_data["summary"].matchDayStatus)

    --重定义增购，重购协议
    --["rebuy"] = "Rebuy: 可重购比赛，次数：2次第1-6级别前",
    --["addon"] = "addon: 可增购比赛，次数：1次第7个盲注级别可用",
    --处理重购
    if(self.retData["rebuy_num"] == 0) then
        self.m_data["summary"].rebuy = ""
    else
        local str = "Rebuy: 可重购比赛，次数："..self.retData["rebuy_num"].."次第1-"..(self.retData["entry_stop"] - 1).."级别前"
        self.m_data["summary"].rebuy = str
    end

    --处理增购
    if(self.retData["addon"] == 0) then
        self.m_data["summary"].addon = ""
    else
        local str = "addon: 可增购比赛，次数："..self.retData["addon"].."次第"..self.retData["entry_stop"].."个盲注级别可用"
        self.m_data["summary"].addon = str
    end


    --print("iniiiinnndata2222")
    --dump(self.m_data)
--[[  
	self.m_data = {

		["summary"] = {
			--["rebuy"] = "",
			--["addon"] = "",
        	["rebuy"] = "Rebuy: 可重购比赛，次数：2次第1-6级别前",
			["addon"] = "addon: 可增购比赛，次数：1次第7个盲注级别可用",
			["matchFee"] = "60",--报名费
            ["matchFeeCost"] = 6--花费费用 系统收的一部分费用
			["matchFiretChip"] = "12",--初始筹码
			["matchPeopleNum"] = "6",--报名人数
			["matchDayStatus"] = "3",
			["matchTimeHours"] = "21",
			["matchTimeMin"] = "33",
			["matchTimeSec"] = "50",
        },

        ["ranking"] = {
        	[1] = {
	            ["rank"] = "1",
	            ["name"] = "xiaoxiao名3",
	            ["score"] = "62",
            },

            [2] = {
            	["rank"] = "1",
            	["name"] = "xiaoxiao名222",
            	["score"] = "322",
            },

            [3] = {
            	["rank"] = "1",
            	["name"] = "223123123名",
            	["score"] = "322222",
            },

            [4] = {
            	["rank"] = "1",
            	["name"] = "xiaoxia",
            	["score"] = "1111113",
            }
        },

        ["blind"] = {
			[1] = {
            	["level"] = "1",
            	["blind"] = "32310",
            	["preBlind"] = "10000",
            },

            [2] = {
	            ["level"] = "2",
	            ["blind"] = "200000",
	            ["preBlind"] = "1000",
            },

            [3] = {
	            ["level"] = "3",
	            ["blind"] = "44320",
	            ["preBlind"] = "0",
            },

            [4] = {
	            ["level"] = "4",
	            ["blind"] = "320",
	            ["preBlind"] = "110",
            },

            [5] = {
	            ["level"] = "5",
	            ["blind"] = "20",
	            ["preBlind"] = "10",
            }
        },

        ["reward"] = {
        	[1] = {
            	["rank"] = "1",
            	["scale"] = "21.5",
            },

            [2] = {
            	["rank"] = "2",
            	["scale"] = "221.5",
            },

            [3] = {
            	["rank"] = "3",
            	["scale"] = "121.5",
            },

            [4] = {
            	["rank"] = "4",
            	["scale"] = "1.5",
            },

            [5] = {
            	["rank"] = "5",
            	["scale"] = "0.5",
            },

            [6] = {
            	["rank"] = "6",
            	["scale"] = "77.5",
            }
      	}
	}
]]
end

function AllGameMTTCellContent:create(data)
    return AllGameMTTCellContent.new(data)
end

return AllGameMTTCellContent
