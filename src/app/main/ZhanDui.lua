--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--战队，队员队长
--

local g_self = nil

--注册刷新事件
local function CustomCallBackUpdateZhanDui(event)  
    print("eeeemmmmmzzzz")

    local function response(data)
        print("dds32333")
        dump(data)
        g_self.m_data = data

        --更新界面
        if(g_self ~= nil) then
            g_self:updateView()
        end  
    end

    --发送消息，获取最新战队成员消息
    local tab = {}
    tab['team_id'] = g_self.m_data.team_id
    MainCtrol.filterNet("get_team_detail", tab, response, PHP_POST)

    dump(g_self.m_data)   
end  

------------------------btn-------------------------------
--选择用户
local function selectUsr(sender)
    print("ajdhajksdh~~~")
    dump(sender.tData)
    
    local personInfo = require("friend.PersonInfo")
    local layer = personInfo:create()
    g_self:getParent():addChild(layer, 100)
    layer:createLayer( {id = sender.tData.player_id} )
end

--解散战队
local function jieSan(sender)
    print("解散")
    --先判断成员是否移除
    if(#g_self.m_data.playerInfo > 1) then
        ViewCtrol.showTip({content = "解散战队前请先移除队员。"})
    else

        local function response(data)
            print("jss")
            dump(data)
            --解散成功
            if(data == 1) then
                g_self:removeFromParent()
                g_self = nil
                ViewCtrol.showTick({content = "解散成功"})
                local MineCtrol = require('mine.MineCtrol')
                MineCtrol.editInfo({exist_team = 0})
                local curScene = cc.Director:getInstance():getRunningScene()
                if curScene:getChildByName("mine") then
                    print("mine")
                    local MineTeam = require("mine.MineTeam"):create()
                    MineTeam.exitTeam()
                elseif curScene:getChildByName("message") then
                    print("clubInfoPlus")
                    local message = curScene:getChildByName("message")
                    local clubInfoPlus = message:getChildByName("clubInfoPlus")
                    if clubInfoPlus:getChildByName("MineTeam") then
                        print("MineTeam")
                        clubInfoPlus:removeChildByName("MineTeam")
                    end
                    local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
                    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                    customEventDispatch:dispatchEvent(myEvent)
                end
            --解散失败
            else
                ViewCtrol.showTick({content = "解散失败"})
            end
        end

        local tab = {}
        tab['team_id'] = g_self.m_data.team_id
        tab['club_id'] = g_self.m_data.club_id
        MainCtrol.filterNet("dismissTeam", tab, response, PHP_POST)
    end
    
end

--退出战队
local function tuiChuZD(sender)
    print("退出")

    local function response(data)
        print("jss")
        dump(data)
        g_self:removeFromParent()
        g_self = nil
        ViewCtrol.showTick({content = "退出成功"})
        
        local MineCtrol = require('mine.MineCtrol')
        MineCtrol.editInfo({exist_team = 0})
        local curScene = cc.Director:getInstance():getRunningScene()
        if curScene:getChildByName("mine") then
            print("mine")
            local MineTeam = require("mine.MineTeam"):create()
            MineTeam.exitTeam()
        elseif curScene:getChildByName("message") then
            print("clubInfoPlus")
            local message = curScene:getChildByName("message")
            local clubInfoPlus = message:getChildByName("clubInfoPlus")
            if clubInfoPlus:getChildByName("MineTeam") then
                print("MineTeam")
                clubInfoPlus:removeChildByName("MineTeam")
            end
            local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
            local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
            customEventDispatch:dispatchEvent(myEvent)
        end
    end

    local tab = {}
    tab['team_id'] = g_self.m_data.team_id
    MainCtrol.filterNet("quitTeam", tab, response, PHP_POST)
end

--增加战队成员
local function addZD(sender)
--[[
    local function response(tData)
        print("addddd")
        dump(tData)
        if(tData == nil) then
            return
        end
        
        local mDataArr = {}
        --处理data
        local idx = 1
        for k, v in pairs(tData) do  
            print("kk="..k)
            local cellDataG = {}
            cellDataG.idx = idx
            cellDataG.type = "g"
            cellDataG.name = string.upper(k)
            mDataArr[idx] = cellDataG

            idx = idx + 1

            for i = 1, #v do 
                print("----")
                dump(v)
                local cellDataC = {}
                cellDataC.idx = idx--cell索引
                cellDataC.type = "c"--显示模式
                cellDataC.name = v[i].user_name
                cellDataC.head_img = v[i].headimg
                cellDataC.id = v[i].uid--用户玩家id
                cellDataC.no = v[i].u_no--用户玩家编号
                cellDataC.isS = 0--是否被选中0没选中 1选中
            
                mDataArr[idx] = cellDataC
                idx = idx + 1
            end 
        end 

        
        print("wccccccc---")
        dump(mDataArr)

        print("增加战队成员")
        local testly = require('main.ZhanDuiAS'):create(mDataArr, 1, g_self.m_data)
        cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
    end

    local tab = {}
    tab['team_id'] = g_self.m_data.team_id
    tab['club_id'] = g_self.m_data.club_id
    MainCtrol.filterNet("clubUserteamList", tab, response, PHP_POST)
]]
    print("add222")
    require('main.ZhanDuiG').showZhanDui(1, g_self.m_data)
end

--减少战队成员
local function subZD(sender)
--[[
    local function response(tData)
        print("assssss")
        dump(tData)
        if(tData == nil) then
            return
        end
        
        local mDataArr = {}
        --处理data
        local idx = 1
        for k, v in pairs(tData) do  
            print("kk="..k)
            local cellDataG = {}
            cellDataG.idx = idx
            cellDataG.type = "g"
            cellDataG.name = string.upper(k)
            mDataArr[idx] = cellDataG

            idx = idx + 1

            for i = 1, #v do
                print("----")
                dump(v)
                local cellDataC = {}
                cellDataC.idx = idx--cell索引
                cellDataC.type = "c"--显示模式
                cellDataC.name = v[i].user_name
                cellDataC.head_img = v[i].headimg
                cellDataC.id = v[i].uid--用户玩家id
                cellDataC.no = v[i].u_no--用户玩家编号
                cellDataC.team_leader = v[i].team_leader--是否是队长
                cellDataC.isS = 0--是否被选中0没选中 1选中
            
                mDataArr[idx] = cellDataC
                idx = idx + 1
            end 
        end 

        
        print("wccccccc---")
        dump(mDataArr)

        print("减少战队成员")
        local testly = require('main.ZhanDuiAS'):create(mDataArr, 2, g_self.m_data)
        cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
    end

    local tab = {}
    tab['team_id'] = g_self.m_data.team_id
    MainCtrol.filterNet("clubteamList", tab, response, PHP_POST)
]]
    print("suuu")
    require('main.ZhanDuiG').showZhanDui(2, g_self.m_data)
end


--类
local ZhanDui = class("ZhanDui", function ()
    return cc.Node:create()
end)

function ZhanDui:ctor(cData)
    self.m_root = nil
    self.m_panel = nil
    self.m_panelNum = 2
    self.m_listView = nil--管理员审核过的玩家列表
    self.m_data = cData--存储透传的标
    self.m_listener = nil

    self:init()
end

function ZhanDui:init()
    g_self = nil
    g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/ZhanDui.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    --隐藏无用层
    for i = 1, self.m_panelNum do
        ccui.Helper:seekWidgetByName(self.m_root, "Panel_"..i):setVisible(false)
    end 

    --注册监听事件
    local listenerCustom = cc.EventListenerCustom:create("C_Event_Update_List_ZhanDui", CustomCallBackUpdateZhanDui)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    self.m_listener = listenerCustom

    --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "exit" then
            if(self.m_listener ~= nil) then
                --移除监听事件
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(self.m_listener)
            end
        elseif event == "enterTransitionFinish" then
            
        end
    end
    
    --注册退出事件
    self:registerScriptHandler(onNodeEvent)
    
    --初始化界面
    self:updateView()
    --发送事件
    --[[
    print("jjjjjjj")
    local myEvent = cc.EventCustom:new("C_Event_Update_List_ZhanDui")
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:dispatchEvent(myEvent) 
    ]]

    --适配处理
    --如果遇到宽屏的 
    if( (display.width/(display.height - 220)) > 0.673249) then
        print("in hhhhhh")
        local rw = (display.height - 220)*0.673249
        local r = (display.height - 220)/1114
        self:setScale(r)
        local posx = (display.width - rw)*0.5
        self:setPositionX(posx)
    end

end

--传入要给服务端的数据
function ZhanDui:updateList()

    self.m_listView:removeAllItems()

    local tData = self.m_data.playerInfo

    --排序，把队长排在最上面
    table.sort(tData,function ( a, b )
            return a.team_leader < b.team_leader
        end)

    for i = 1, #tData do
        local cell = cc.CSLoader:createNodeWithVisibleSize("scene/ZhanDuiCell.csb")
        local tRoot = cell:getChildByName("Panel_root")

        --名字
        local Text_name = ccui.Helper:seekWidgetByName(tRoot, "Text_name")
        Text_name:setString(tData[i].player_name)

        --战队标志位置
        local Image_flag = ccui.Helper:seekWidgetByName(tRoot, "Image_flag")
        Image_flag:setPositionX(Text_name:getPositionX() + Text_name:getContentSize().width + 6)

        --添加头像
        local iconZD_URL = tData[i].player_avatar
        local iconZD = ccui.Helper:seekWidgetByName(tRoot, "Image_head")
        local hx, hy = iconZD:getPosition()
        iconZD:setVisible(false)
        local thead = UIUtil.addShaderHead(cc.p(hx, hy), iconZD_URL, tRoot, function(thead)end)
        thead:setScale(0.35)

        --队长图标
        ccui.Helper:seekWidgetByName(tRoot, "Image_dz"):setVisible(false)

        tRoot.tData = tData[i]    
        tRoot:touchEnded(selectUsr)
        
        -------------
        tRoot:removeFromParent()
        self.m_listView:pushBackCustomItem(tRoot)
    end

    if(#tData >= 1) then
        self.m_listView:getItem(0):getChildByName("Image_dz"):setVisible(true)
    end
end

--更新界面
function ZhanDui:updateView()

    print("~~~~kljljkl~~~~")
    dump(self.m_data)

    --根据数据判断显示哪个界面
    --1显示队长 2显示队员
    local showWhichP = self.m_data.team_leader

    self.m_panel = ccui.Helper:seekWidgetByName(self.m_root, "Panel_"..showWhichP)
    self.m_panel:setVisible(true)


    --添加战队图标
    local iconZD_URL = self.m_data.team_logo
    local iconZD = ccui.Helper:seekWidgetByName(self.m_panel, "Image_icon")
    local hx, hy = iconZD:getPosition()
    iconZD:setVisible(false)
    local thead = UIUtil.addShaderHead(cc.p(hx, hy), iconZD_URL, self.m_panel, function(thead)end)
    thead:setScale(0.5)

    --战队名称
    local txtZD_name = self.m_data.team_name
    local Text_zd = ccui.Helper:seekWidgetByName(self.m_panel, "Text_zd")
    Text_zd:setString(txtZD_name)

    --战队图标
    local Image_flag = ccui.Helper:seekWidgetByName(self.m_panel, "Image_flag")
    Image_flag:setPositionX(Text_zd:getPositionX() + Text_zd:getContentSize().width + 6)

    --俱乐部名称
    local txtClub_name = "来自"..self.m_data.club_name.."俱乐部"
    ccui.Helper:seekWidgetByName(self.m_panel, "Text_jlb"):setString(txtClub_name)

    --战队成员人数
    local txtZD_num = #self.m_data.playerInfo
    ccui.Helper:seekWidgetByName(self.m_panel, "Text_dynum"):setString(txtZD_num)

    --根据不同界面显示不同内容
    if(showWhichP == 1) then
        --解散按钮    
        local btn = ccui.Helper:seekWidgetByName(self.m_panel, "Button_jies")
        btn:touchEnded(jieSan)

        btn = ccui.Helper:seekWidgetByName(self.m_panel, "Button_add")
        btn:touchEnded(addZD)

        btn = ccui.Helper:seekWidgetByName(self.m_panel, "Button_sub")
        btn:touchEnded(subZD)
        btn:setEnabled(true)
     
        --如果战队成员为1，证明就是自己，删除按钮不可用
        if(#self.m_data.playerInfo == 1) then
            btn:setEnabled(false)
        end

    elseif(showWhichP == 2) then
        --退出按钮
        local btn = ccui.Helper:seekWidgetByName(self.m_panel, "Button_tc")
        btn:touchEnded(tuiChuZD)
    end

    --listView
    self.m_listView = ccui.Helper:seekWidgetByName(self.m_panel, "ListView_1")
    self.m_listView:setBounceEnabled(true)
    self.m_listView:setScrollBarEnabled(false)

    --更新列表
    self:updateList()
end

function ZhanDui:create(cData)
    return ZhanDui.new(cData)
end

return ZhanDui