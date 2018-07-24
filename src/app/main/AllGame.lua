local AllGame = {}
local _csize = cc.size(display.width,116)
local _cs = nil
local _topBar = nil
local _sortBg = nil
local _sortDot = nil
local _layer = nil
local _tablev = nil
local _tag = 0--1标准快速游戏  2sng 3单挑
local _title = ''
local _data = nil
local _allData = {}
local _title2 = {}
local _title3 = {}
local _gcsize = nil

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

--按什么排序
--mod = 1 (big_blind,current_players) 
--mod = 2(entry_fee,limit_players)
--mod = 3(big_blind,current_players)
local a_sort_key = 'big_blind'
--游戏模式mod
--1－StatusCode.HALL_START
--2-StatusCode.HALL_SNG
--3-StatusCode.HALL_HUPS
local a_game_mod = 1
local a_sort_type2 = 'asc'--第二个标签，正序反序逻辑'asc'为正序，'desc'为倒序
local a_sort_type3 = 'asc'--第三个标签，正序反序逻辑'asc'为正序，'desc'为倒序
local s_sortT = 2--默认选第二个标签的排序目前就2和3两种
--新数据1-自由单桌； 2-sng； 3-单挑
local g_loadLayer = {'scene/AllGameNew.csb', 'scene/AllGameNew4SNG.csb', 'scene/AllGameNew.csb'}
local g_loadCell = {'scene/AllGameCellBiaoZ.csb', 'scene/AllGameCellSNG.csb', 'scene/AllGameCellDanT.csb'}
local GameScene = require 'game.GameScene'

local g_ShowDlg = nil--显示对话框
local g_cs = nil

---适配回复
local function rebackScreen( )
    -- local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    -- local width, height = framesize.width, framesize.height

    -- width = framesize.width / scaleX-----
    -- height = framesize.height / scaleX----

    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("exit----rrrr=="..ratio)
    -- if ratio >= 1.5 then
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    -- else
        
    -- end
    StringUtils.setDZAdapter()
end

AllGame.rebackScreen = rebackScreen

--btn
--牌桌人数，相关排序文字按钮，相关事件
local function sortText2Btn(sender)
    print('t22222')
    s_sortT = 2

    if(a_sort_type2 == 'asc') then
        a_sort_type2 = 'desc'
        _cs:getChildByName('Image_2'):loadTexture("main/main_fupdown.png")
    else
        a_sort_type2 = 'asc'
        _cs:getChildByName('Image_2'):loadTexture("main/main_fup.png")
    end
          
    --初始化默认参赛
    if StatusCode.HALL_START == _tag then
        a_sort_key = 'current_players'
    elseif StatusCode.HALL_SNG == _tag then
        a_sort_key = 'limit_players'
    elseif StatusCode.HALL_HUPS == _tag then
        a_sort_key = 'current_players'
    else
        assert(nil, 'AllGame  '.._tag)
    end

    pageNum = 1

    --发送消息
    local function response(data)
        local datas,data2 = MainModel:getAllGames(data, _tag)
        _data = datas
        _tablev:reloadData()
    end

    local tab = {}
    tab['sort_key'] = a_sort_key
    tab['game_mod'] = a_game_mod
    tab['sort_type'] = a_sort_type2
    tab['page'] = pageNum
    tab['every_page'] = 15
    MainCtrol.filterNet(PHP_GAME_LIST, tab, response, PHP_POST)

end

--金额不足弹框
local function showDlg(num)
    if(g_ShowDlg == nil) then
        g_ShowDlg = cc.CSLoader:createNodeWithVisibleSize("scene/AllGame4Dlg.csb")
        g_cs:addChild(g_ShowDlg, 999999)
        local root = g_ShowDlg:getChildByName("Panel_root")
        
        local function endDlg(sender)
            sender:setTouchEnabled(false)
            g_ShowDlg:removeFromParent()
            g_ShowDlg = nil
        end

        local function buySome(sender)
            print("buySome~~~~~")
            sender:setTouchEnabled(false)
            g_ShowDlg:removeFromParent()
            g_ShowDlg = nil

            
            local MineCtrol = require('mine.MineCtrol')

            MineCtrol.dataStatShop( function ( data )
                local shop = require("shop.ShopLayer")
                local layer = shop:create()
                g_cs:addChild(layer, 1)
                layer:createLayer(data)
             end )
        end

        --取消按钮
        local btn = ccui.Helper:seekWidgetByName(root, "Button_exit")
        btn:touchEnded(endDlg)
        
        --购买按钮
        btn = ccui.Helper:seekWidgetByName(root, "Button_buy")
        btn:touchEnded(buySome)

        --提示内容
        local txt = ccui.Helper:seekWidgetByName(root, "Text_show")
        txt:setString('您的记分牌余额低于'..num..'，请补充记分牌。')
    end
end

--盲注，相关排序文字按钮，相关事件
local function sortText3Btn(sender)
    print('t33333')
    s_sortT = 3

    if(a_sort_type3 == 'asc') then
        a_sort_type3 = 'desc'
        _cs:getChildByName('Image_3'):loadTexture("main/main_fupdown.png")
    else
        a_sort_type3 = 'asc'
        _cs:getChildByName('Image_3'):loadTexture("main/main_fup.png")
    end

    --初始化默认参赛
    if StatusCode.HALL_START == _tag then
        a_sort_key = 'big_blind'
    elseif StatusCode.HALL_SNG == _tag then
        a_sort_key = 'entry_fee'
    elseif StatusCode.HALL_HUPS == _tag then
        a_sort_key = 'big_blind'
    else
        assert(nil, 'AllGame  '.._tag)
    end

    pageNum = 1

    --发送消息
    local function response(data)
        local datas,data2 = MainModel:getAllGames(data, _tag)
        _data = datas
        _tablev:reloadData()
    end

    local tab = {}
    tab['sort_key'] = a_sort_key
    tab['game_mod'] = a_game_mod
    tab['sort_type'] = a_sort_type3
    tab['page'] = pageNum
    tab['every_page'] = 15
    MainCtrol.filterNet(PHP_GAME_LIST, tab, response, PHP_POST)
end

local function handleReturn(sender)
	_layer:removeFromParent()

    --sng 恢复原有的背景
    if(_tag == 2) then
        rebackScreen( )
    end
end

local function addNewData(olddata, newdata)
--[[
    local datas,data2 = MainModel:getAllGames(newdata, _tag)

    local currNum = #olddata
    for i=1,#datas do
        olddata[currNum + i] = datas[i]
    end
]]

    local datas = MainModel:getAllGames(newdata, _tag)
    local currNum = #olddata

    currRetDataNum = #datas

    for i=1,#datas do
        olddata[currNum + i] = datas[i]
    end
end

-------------------------tableView 回调相关------------------------
--处理万以上数字
local function mWanNumber(num)
    local ret = tonumber(num)
    
    if(ret >= 10000) then
        ret = math.floor(ret/10000)
        ret = tostring(ret).."万"
    end

    return ret
end


--单挑，单桌点击进入按钮
local function inGame(sender)
    
    print("tcchhh="..sender:getTag())
--[[
    local target = sender
    local itemData = {}

    itemData.gameModel = "标准"--无用
    itemData.isDisHigh = false--无用
    itemData.lookBtn =  "查看全部游戏"--无用
    itemData.numOne = sender.tData["useNum"]--大盲
    itemData.playerNum = sender.tData["allPersonNum"]--多少人的牌桌
    itemData.tag = _tag--1-大厅单桌 2-大厅sng 3-大厅单挑

    local idata = itemData

    local function response(data)
    end

    MainCtrol.startGameFilterType(idata, response)
]]
    print("sadasdas333"..sender.tData["gid"])
    --dump(sender.tData)

    GameScene.startScene(sender.tData["gid"], StatusCode.INTO_MAIN)
end

--sng点击报名按钮
local function inSNGGame(sender)

    --如果金额不足弹框
    if( tonumber(Single:playerModel():getPBetNum()) < (tonumber(sender.tData["entry_fee"]) + tonumber(sender.tData['entry_cost'])) ) then
        showDlg( sender.tData["entry_fee"] + sender.tData['entry_cost'] )
    else
        local tobj = {}
        tobj['type'] = sender.tData["type"]
        tobj['entry_fee'] = sender.tData["entry_fee"]
        tobj['limit_players'] = 6
        
        tobj['first_prize'] = sender.tData["first_prize"]
        tobj['second_prize'] = sender.tData["second_prize"]
        tobj['entry_cost'] = sender.tData["entry_cost"]
        tobj['entry_fee'] = sender.tData["entry_fee"]


        --弹出提示框
        local dlg = require("main/HelpDlg"):create(8, tobj)
        g_cs:addChild(dlg)

--[[
        local function response(data)
            -- GameScene.startScene(data['gid'], StatusCode.INTO_MAIN)
            GameScene.startScene(data['gid'])
        end
        
        local tab = {}
        tab['type'] = sender.tData["type"]
        tab['entry_fee'] = sender.tData["entry_fee"]
        tab['limit_players'] = 6
        MainCtrol.filterNet("sng/quick_join", tab, response, PHP_POST)
]]
    end
end

local function updateCellContent(idx, layer)
    if(_data[idx] == nil) then
        return
    end

    local cdata = _data[ idx ]

    if(_tag == 1) then--自由单桌cell 
        local tCell = layer:getChildByName("Panel_root")
         
        --初始化进入按钮
        local btn = ccui.Helper:seekWidgetByName(tCell, "Button_inGame")
        btn:setTag(idx)
        btn:touchEnded(inGame)
        btn:setSwallowTouches(false)
        btn.tData = cdata

        --初始化数字标签
        local AtlasLabel_1 = ccui.Helper:seekWidgetByName(tCell, "AtlasLabel_1")
        if (idx >= 0 and idx <= 9) then
            AtlasLabel_1:setString("00"..tostring(idx))
        elseif (idx >= 10 and idx <= 99) then
            AtlasLabel_1:setString("0"..tostring(idx))
        elseif (idx >= 100 and idx <= 999) then
            AtlasLabel_1:setString(tostring(idx))
        end

        --初始化牌桌人数
        local txt = ccui.Helper:seekWidgetByName(tCell, "Text_pNum")
        txt:setString(tostring(cdata["nowPersonNum"])..'/'..tostring(cdata["allPersonNum"]))

        --初始化盲注
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_blind")
        --print("hhhttt==="..cdata["big_blind"])
        local bNum = tonumber(cdata["big_blind"])
        local sNum = bNum/2
        print("ddd="..bNum)
        print("sNum="..sNum)
        txt:setString(mWanNumber(sNum)..'/'..mWanNumber(bNum))

        --带入量
        local getInNum = cdata["entry_fee"]       
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_getinNum")
        txt:setString(mWanNumber(getInNum))

        --保险标志
        if(cdata["secure"] == 1) then
            local tsp = ccui.Helper:seekWidgetByName(tCell, "Image_bx")
            tsp:setVisible(true)
        end

    elseif(_tag == 2) then--大厅sng
        local tCell = layer:getChildByName("Panel_root")
         
        --初始化进入按钮
        local btn = ccui.Helper:seekWidgetByName(tCell, "Button_inGame")
        btn:setTag(idx)
        btn:touchEnded(inSNGGame)
        btn:setSwallowTouches(false)
        btn.tData = cdata

        --什么场
        local flagImg = ccui.Helper:seekWidgetByName(tCell, "Image_flag")
        flagImg:loadTexture("bg/all_sngF"..cdata['type']..".png")

        --人数
        local txt = ccui.Helper:seekWidgetByName(tCell, "Text_pNum")
        txt:setString(cdata["players_count"])

        --第一奖励
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_firstR")
        txt:setString(mWanNumber(cdata["first_prize"]))

        --第二奖励
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_secondR")
        txt:setString(mWanNumber(cdata["second_prize"]))

        --报名费用
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_fee")
        txt:setString(mWanNumber(cdata["entry_fee"]).."+"..mWanNumber(cdata['entry_cost']))
    elseif(_tag == 3) then--单挑  
        --print("ttthhhhhere11111")
        --dump(_data[ idx ])
        local tCell = layer:getChildByName("Panel_root")
        
        --初始化进入按钮
        local btn = ccui.Helper:seekWidgetByName(tCell, "Button_inGame")
        btn:setTag(idx)
        btn:touchEnded(inGame)
        btn:setSwallowTouches(false)
        btn.tData = cdata

        --初始化数字标签
        local AtlasLabel_1 = ccui.Helper:seekWidgetByName(tCell, "AtlasLabel_1")
        if (idx >= 0 and idx <= 9) then
            AtlasLabel_1:setString("00"..tostring(idx))
        elseif (idx >= 10 and idx <= 99) then
            AtlasLabel_1:setString("0"..tostring(idx))
        elseif (idx >= 100 and idx <= 999) then
            AtlasLabel_1:setString(tostring(idx))
        end

        --初始化牌桌人数
        local txt = ccui.Helper:seekWidgetByName(tCell, "Text_pNum")
        txt:setString(tostring(cdata["nowPersonNum"])..'/'..tostring(cdata["allPersonNum"]))

        --初始化盲注
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_blind")
        --print("hhhttt==="..cdata["big_blind"])
        local bNum = tonumber(cdata["big_blind"])
        local sNum = bNum/2
        txt:setString(mWanNumber(sNum)..'/'..mWanNumber(bNum))

        --带入量
        local getInNum = cdata["entry_fee"]
        txt = ccui.Helper:seekWidgetByName(tCell, "Text_getinNum")
        txt:setString(mWanNumber(getInNum))

        --保险标志
        if(cdata["secure"] == 1) then
            local tsp = ccui.Helper:seekWidgetByName(tCell, "Image_bx")
            tsp:setVisible(true)
        end
    end
end

local function numberOfCellsInTableView(table)
    if(_data == nil) then 
        return 0
    end
    
    return #_data
end

local function cellSizeForTable(table,idx)
    return _gcsize.width, _gcsize.height
end

local function scrollViewDidScroll(view)
    --sng不用下拉刷新
    if(_tag == 2) then
        actionLDNode:setVisible(false)
        return
    end
    
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
                               --   end)
                        --))
                    end

                    local tab = {}
                    local sort_type = a_sort_type2
                    
                    if(s_sortT == 2) then 
                        sort_type = a_sort_type2
                    else
                        sort_type = a_sort_type3
                    end

                    tab['sort_key'] = a_sort_key
                    tab['game_mod'] = a_game_mod
                    tab['sort_type'] = sort_type
                    tab['page'] = pageNum + 1
                    tab['every_page'] = 15
                    MainCtrol.filterNet(PHP_GAME_LIST, tab, response, PHP_POST)

                end)
            )) 
    end
end

local function tableCellAtIndex(table, idx)
    idx = idx + 1--默认从0开始，lua里没0所以+1
    local cell = table:dequeueCell() 
    
    --如果table 队列里取出的cell为空，重新创建一个
    if nil == cell then
        cell = cc.TableViewCell:new()
        local layer = cc.CSLoader:createNodeWithVisibleSize(g_loadCell[_tag])
        layer:setContentSize(_gcsize)
        layer:setTag(123)
        cell:addChild(layer)
    end

    --根据idx，重新更新cell内容
    updateCellContent(idx, cell:getChildByTag(123))

    return cell
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

-----------------------------------------------------------------------------------------end

---------------------new Layer---------------------------------
local function createLayerNew(data2)
    --初始化一些数据
    a_sort_key = 'big_blind'
    a_game_mod = 1
    s_sortT = 2
    a_sort_type2 = 'asc'--正序反序逻辑'asc'为正序，'desc'为倒序
    a_sort_type3 = 'asc'
                    
    --初始化默认参赛
    if StatusCode.HALL_START == _tag then
        a_game_mod = 1
        a_sort_key = 'big_blind'
    elseif StatusCode.HALL_SNG == _tag then
        a_game_mod = 2
        a_sort_key = 'limit_players'
    elseif StatusCode.HALL_HUPS == _tag then
        a_game_mod = 3
        a_sort_key = 'big_blind'
    else
        assert(nil, 'AllGame  '.._tag)
    end

    --初始化下拉刷新数据
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



   
    --初始化层
    _layer = cc.Layer:create()
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(_layer, StringUtils.getMaxZOrder(runScene))
    local cs = cc.CSLoader:createNodeWithVisibleSize(g_loadLayer[_tag])
    g_cs = cs
    _layer:addChild(cs)
    local root = cs:getChildByName("Panel_root")

    --如果是sng，注册帮助事件
    if(_tag == 2) then
        local btnHelp = ccui.Helper:seekWidgetByName(root, "Button_wenHao")
        btnHelp:touchEnded(
            function( event ) 
                print("帮助")
                local dlg = require("main/HelpDlg"):create(1)
                g_cs:addChild(dlg)
            end)
    end
    
    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(root, "Button_back")
    btn:touchEnded(handleReturn)

    if(_tag == 1 or _tag == 3) then
        local titleStr = {"自由单桌", "无标题", "单挑"}
        local titleDownStr = {"场标准游戏", "无标题", "场单挑"}
        --标题
        local txt = ccui.Helper:seekWidgetByName(root, "Text_title")
        txt:setString(titleStr[_tag])
        txt = ccui.Helper:seekWidgetByName(root, "Text_mNum")
        --print("tttccc==="..data2["count"])
        txt:setString(tostring(data2["count"])..titleDownStr[_tag])
    end


    --创建列表
    local modelP = ccui.Helper:seekWidgetByName(root, "Panel_t")
    local tLayer = cc.CSLoader:createNodeWithVisibleSize(g_loadCell[_tag])
    local tCell = tLayer:getChildByName("Panel_root")
    _gcsize = tCell:getContentSize()
    --print('cccccsssssss=='.._gcsize.width..",".._gcsize.height)
    --print('mmmssss=='..modelP:getContentSize().width..","..modelP:getContentSize().height)
    local tableView = cc.TableView:create(modelP:getContentSize())
    tableView:initWithViewSize(modelP:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    modelP:addChild(tableView)
    --注册列表相关事件
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)   
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:setBounceable(true)
    tableView:reloadData()
    --注册触摸事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tableView)
    tableView:setTouchEnabled(true)
    tableView:addChild(actionLDNode)
    actionLDNode:setPosition(cc.p(_csize.width/2, -70))
    posTY = tableView:getPositionY()

    g_listener = listener

    --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "exit" then
            if(g_listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(g_listener)
                print("llll---remove")
            end
        end
    end
    
    _layer:registerScriptHandler(onNodeEvent)


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
    --     _layer:setPosition(cc.p(realx, 0))
    -- else
        
    -- end
    local realx = StringUtils.setKCAdapter()
    if realx then
        _layer:setPosition(cc.p(realx, 0))
    end

end


function AllGame.lookGame(tag, cdata)
    g_ShowDlg = nil
    g_cs = nil 
    _data = nil
    _gcsize = nil
	_tag = tag
    print("tttsssssdddd1231231==="..tag)--1 自由单桌;2-sng; 3-单挑
	local datas, data2 = MainModel:getAllGames(cdata, tag)
	_allData = datas
	_data = datas
    --print('-------222-----')
    --dunmp(data2)
	--createLayer(data2)
    createLayerNew(data2)
end

return AllGame