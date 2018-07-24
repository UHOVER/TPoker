local EditTable = {}
local _line = nil
local _topLayer = nil
local _data = {}
local _resData = {}
local _cellData = {}
local _csize = cc.size(670,1080 + 35)
local _arrpos = {}
local _btnTexts      = {}
local _btnLocks      = {}

local BUILD_TAG = 1
local HALL_TAG = 2
local _tag = HALL_TAG
local _pageIdx = 0
local g_bzBtn = nil
local g_bxBtn = nil
local _layer = nil--记录当前层
local _root = nil--记录 cocostudio的root layer
local g_inPai = 0--带入记分牌
local g_ShowDlg = nil--提示余额不足对话框
local g_listener = nil--自定义事件
local g_layer = nil --层

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
    -- body
end

--金额不足弹框
local function showDlg(num)
    if(g_ShowDlg == nil) then
        g_ShowDlg = cc.CSLoader:createNodeWithVisibleSize("scene/AllGame4Dlg.csb")
        _root:addChild(g_ShowDlg, 999999)
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
            rebackScreen()


            local MineCtrol = require('mine.MineCtrol')

            MineCtrol.dataStatShop( function ( data )
                local shop = require("shop.ShopLayer")
                local layer = shop:create()
                --_layer:addChild(layer, 1)
                layer:createLayer(data)

                cc.Director:getInstance():getRunningScene():addChild(layer,99999)
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

--btn
--local function startBtn(tag, sender)
local function startBtn(sender)
    local function response(data)
        rebackScreen()
        _layer:setVisible(false)
    end

    --记分牌余额小于带入量弹出提示框
    --print("tonumber(Single:playerModel():getPBetNum())=="..tonumber(Single:playerModel():getPBetNum())..", g====="..g_inPai)
    if(tonumber(Single:playerModel():getPBetNum()) < g_inPai) then
        showDlg(g_inPai)
    else
        print("sdfjksdhfsd-----")
        dump(sender._btnData)
        MainCtrol.startGameFilterType(sender._btnData, response)
        MainModel:updateData() 
    end
end

--local function allGameBtn(tag, sender)
local function allGameBtn(sender)
    MainCtrol.lookAllGame(sender:getTag(), function(cdata)
        
        rebackScreen()
        local AllGame = require 'main.AllGame'
        AllGame.lookGame(sender:getTag(), cdata)

    end)
end



--问号按钮
local function showHelp( sender )
    print("显示帮助")
    if(_pageIdx == 3) then--id=3 单挑； id=1 自由单桌
        print("单挑界面的帮助")
        local dlg = require("main/HelpDlg"):create(3)
        _root:addChild(dlg)
    elseif(_pageIdx == 1) then
        print("自由单桌的帮助")
        local dlg = require("main/HelpDlg"):create(4)
        _root:addChild(dlg)
    end
end

--保险说明小问号按钮
local function  bxHelpBtn(sender)
    local dlg = require("main/HelpDlg"):create(5)
    _root:addChild(dlg)
end

local function finishBtn()

    MainModel:setEditStatus(false)

    DZAction.delateTime(nil, 0.2, function()
        rebackScreen()
        local MainLayer = require 'main.MainLayer'

        if _tag == HALL_TAG then
            MainLayer:switchHall(_pageIdx, MainLayer:getSpPanel())
        elseif _tag == BUILD_TAG then
            MainLayer:switchBuild(_pageIdx, MainLayer:getSpPanel())
        end
    end)

    MainModel:updateData() 
    --DZAction.easeInMove(_topLayer, cc.p(0,display.height), 0.2, DZAction.MOVE_TO, nil)
end




local function addSplitLine(pos, parent)
    local cellline = UIUtil.addPosSprite('main/maing_grayLine.png', pos, parent, cc.p(0.5,0.5))
    cellline:setScaleX(0.95)
    -- cellline:setScaleY(3.5)
    return cellline
end


local function getNewIdx(idx)
    return idx % #_data + 1
end

--scroll
local function setScrollIdx()
    _line:setPositionX(_arrpos[ _pageIdx ])
end
local function scrollBack(parent, idx)
    idx = getNewIdx(idx)
    _pageIdx = idx
    setScrollIdx()
end


--授权
local function addAuthorize(cdata, parent)
    local authorize = cc.Node:create()
    local function authorizeBtn(sender, event)
        cdata['isSAuthorize'] = not cdata['isSAuthorize']
        sender:setHighlighted(cdata['isSAuthorize'])
    end

    if cdata['isHAuthorize'] then
        UIUtil.addLabelArial(cdata['authorizeText'], 32, cc.p(40,285), cc.p(0,0.5), authorize, cc.c3b(0,0,0))
        local authimg1 = 'common/com_switch4.png'
        local authimg2 = 'common/com_switch3.png'
        local ctl = UIUtil.controlBtn(authimg2, authimg1, authimg1, nil, cc.p(570,285), cc.size(110,38), authorizeBtn, authorize)
        ctl:setHighlighted(cdata['isSAuthorize'])
    end

    parent:addChild(authorize)
    return authorize
end


--slider
local function setSlider(sy, ttf1, ttf2, ttf3, parent, cdata, rdata)
    local tTag = cdata['tag']
    local arr = MainCtrol.getSliderArray(cdata['tag'])

    local function sliderChange(sender)
        local idx = math.floor(sender:getValue())
        print("sender:getValue()="..sender:getValue())
        cdata['numOne'] = arr[ idx ]

        local tone,ttwo,three = MainCtrol.getEditText(cdata, rdata)
        ttf1:setString(tone)
        ttf2:setString(ttwo)
        ttf3:setString(three)
    end
    local imgs = {"main/main_progress1.png", "main/main_progress2.png", 'main/main_thumb.png'}
    local maxLen = #arr + 0.9
    local tslider = UIUtil.addSlider(imgs, cc.p(_csize.width/2, sy), parent, sliderChange, 1.1, maxLen)
    tslider:setScale(0.9)
    tslider:setAnchorPoint(0.5,0.5)


    local val = 1.1
    for i=1,#arr do
        if cdata['numOne'] == arr[ i ] then
            val = i + 0.1
            break
        end
    end

    tslider:setValue(val)
    sliderChange(tslider)

    MainHelp.mainAdaptSlider({ttf1, ttf2, ttf3, tslider})
end


local function setHightLayer(idx, ttfText, cdata, rdata, ttf2)
    local tnode = cc.Node:create()

    local btnTexts = _btnTexts[idx]
    local btnLocks = _btnLocks[idx]
    if #btnTexts == 0 or #btnLocks == 0 then 
        return tnode
    end

    local node2 = cc.Node:create()
    tnode:addChild(node2)

    --授权
    local node1 = addAuthorize(cdata, tnode)
    UIUtil.addLabelArial(ttfText, 32, cc.p(40,360), cc.p(0,0.5), node2, cc.c3b(0,0,0))

    local btnx = _csize.width - 328
    local lockx = -273
    local img1 = 'main/main_btn3.png'
    local img2 = 'main/main_btn4_0.png'
    local img3 = 'main/main_btn4.png'
    local img4 = 'main/main_btn4_1.png'
    local btns = {}

    local function modeBtn(sender)
        for i=1,#btns do
            if not btns[i]._isLock then
                btns[i]:setEnabled(true)
                btns[i]:setHighlighted(false)
            end
        end
        sender:setEnabled(false)
        sender:setHighlighted(true)

        local idx = sender:getTag()
        cdata['gameModel'] = btnTexts[ idx ]
        cdata['playerNum'] = btnTexts[ idx ]

        local _,ttwo,_ = MainCtrol.getEditText(cdata, rdata)
        ttf2:setString(ttwo)
    end

    --四个按钮
    if #btnTexts >= 4 then
        btnx = btnx - 104
        lockx = lockx - 104
    end

    for i=1,#btnTexts do
        local ttfcfg = cc.Label:createWithSystemFont(btnTexts[i], "Arial", 25)
        ttfcfg:setColor(cc.c3b(78,92,160))

        --锁按钮图片跟不可用按钮不同
        local disImg = img2
        local disColor = cc.c3b(255,255,255)
        if btnLocks[i] then
            disImg = img4
            disColor = cc.c3b(128,128,128)
        end

        local btn = UIUtil.controlBtn(img2, img3, disImg, ttfcfg, cc.p(btnx,365), cc.size(100,48), modeBtn, node2)
        btn:setScale(0.95)
        btn:setTitleColorForState(cc.c3b(255,255,255), cc.CONTROL_STATE_HIGH_LIGHTED)
        btn:setTitleColorForState(disColor, cc.CONTROL_STATE_DISABLED)
        btn:setTag(i)
        btn._isLock = false

        if btnLocks[i] then
            btn._isLock = true
            btn:setEnabled(false)
            UIUtil.addPosSprite('main/main_lock.png', cc.p(_csize.width+lockx,361), node2, cc.p(1,0))
        end
        if btnTexts[i] == cdata['gameModel'] or btnTexts[i] == cdata['playerNum'] then
            btn:setEnabled(false)
            btn:setHighlighted(true)
        end

        lockx = lockx + 114
        btnx = btnx + 114
        table.insert(btns, btn)
    end


    return {tnode, node1, node2}
end

local function commonCell(idx, parent, highBack)
    local cy = _csize.height / 2 
    local cx = _csize.width / 2
    local th = _csize.height
    local tw = _csize.width
    local leftx = 40
    local color = cc.c3b(0,0,0)

    local cdata = _data[ idx ]
    local rdata = _resData[ idx ]
    local posObjs = {}
    local tTag = cdata['tag']


    --y坐标设置：ttf1、ttf2、ttf3、tslider1
    local yObjs = {665, 665, 550, 610 + 200}
    local highNodeY = -10
    if tTag == StatusCode.BUILD_SNG then
        yObjs = {665, 665, 550, 610 + 200}
        -- highNodeY = -45
        highNodeY = -10
    end
    if tTag == StatusCode.HALL_START 
        or  tTag == StatusCode.HALL_SNG 
        or  tTag == StatusCode.HALL_HUPS then
        yObjs = {665 + 80, 665+ 80, 550+ 50, 610 + 280}
        -- highNodeY = -45
        highNodeY = -10
    end


    local function msgBtn(tag, sender)
        local prompt = nil
        local function touchEnd()
            prompt:removeFromParent()
        end

        local ps = cc.size(632,137)
        prompt = UIUtil.scale9Sprite(cc.rect(0,0,0,0), 'main/main_prompt.png', ps, cc.p(30,th-115), parent)
        prompt:setAnchorPoint(0,1)
        prompt.noEndedBack = touchEnd
        TouchBack.registerImg(prompt)

        local text = MainCtrol.getStatusText(tTag)
        local ttf = UIUtil.addLabelArial(text, 23, cc.p(ps.width/2,ps.height/2), cc.p(0.5,0.5), prompt, cc.c3b(0,0,0))
    end

    --三角
    local triangleX = 540
    if tTag == StatusCode.BUILD_SNG or tTag == StatusCode.BUILD_STANDARD then
        triangleX = 140
    end
    local triangle = UIUtil.addPosSprite('main/main_sanJiao.png', cc.p(triangleX,1150 - 48), parent, cc.p(0.5,0.5))
    

    local rect = cc.rect(50,50,50,50)
    local bgh = MainHelp.getCellBgH()
    local cellbg = UIUtil.scale9Sprite(rect, 'main/main_editbg.png', cc.size(640,bgh), cc.p(cx, 40), parent)
    cellbg:setAnchorPoint(0.5,0)

    local titleNode = cc.Node:create()
    parent:addChild(titleNode)
    --标题
    UIUtil.addLabelArial(rdata['title'], 37, cc.p(cx,th-80), cc.p(0.5,0.5), titleNode, cc.c3b(0,0,0))
    UIUtil.addMenuBtn('main/main_msg.png', 'main/main_msg.png', msgBtn, cc.p(tw-80, th-80), titleNode)
    local titleLine = UIUtil.addPosSprite('main/main_line.png', cc.p(335,1000), titleNode, cc.p(0.5,0.5))
    titleLine:setScaleX(0.95)
    -- titleLine:setScaleY(3)

    local sliderNode = cc.Node:create()
    parent:addChild(sliderNode)
    --文字
    local ttf1 = UIUtil.addLabelArial('', 32, cc.p(leftx + 6,yObjs[1] + 200), cc.p(0,0.5), sliderNode, color)
    local ttf2 = UIUtil.addLabelArial('', 32, cc.p(tw-50,yObjs[2] + 200), cc.p(1,0.5), sliderNode, color)
    local ttf3 = UIUtil.addLabelArial('', 32, cc.p(tw-50,yObjs[3] + 200 - 20), cc.p(1,0.5), sliderNode, color)

    --slider
    setSlider(yObjs[4], ttf1, ttf2, ttf3, sliderNode, cdata, rdata)

    --开始
    local mimg = rdata['btnImg']
    local item  = UIUtil.addMenuBtn(mimg, mimg, startBtn, cc.p(cx, 115), parent)
    item:setTag(tTag)
    item._btnData = cdata


    --最后一条线
    local lastLine = addSplitLine(cc.p(335,200), parent)
    
    --高级内容
    local highNode = cc.Node:create()
    parent:addChild(highNode)

    --高级按钮
    local highBtnNode = cc.Node:create()
    parent:addChild(highBtnNode)


    --开始按钮、最后一条线
    local arrs = {item, lastLine, highNode, triangle, sliderNode, titleNode}
    MainHelp.mainCommonAdapt(arrs)

    --高级
    if string.len(rdata['seniorText']) == 0 then
        return
    end

    local nodes = setHightLayer(idx, rdata['seniorText'], cdata, rdata,ttf2)
    local node = nodes[ 1 ]
    highNode:addChild(node) 


    local highH = 240 - 50
    local highTag = UIUtil.addPosSprite('main/main_donw_tag.png', cc.p(tw-54,highH + 250), highBtnNode, cc.p(0.5,0.5))
    local function disHigh(sender)
        if cdata['isDisHigh'] then
            sender:setString('收起')
            highTag:setRotation(180)
            node:setPositionY(highNodeY)
            highBack(true)
        else
            highTag:setRotation(0)
            sender:setString('高级设置')
            node:setPositionY(display.height)
            highBack(false)
        end
    end
    local function changeBtn(tag, sender)
        cdata['isDisHigh'] = not cdata['isDisHigh']
        disHigh(sender)
    end
    
    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 33
    local setItem = UIUtil.addMenuFont(tab, '收起', cc.p(tw-80,highH + 250), changeBtn, highBtnNode)
    setItem:setAnchorPoint(1,0.5)
    color = cc.c3b(23,86,169)
    setItem:setColor(color)
    disHigh(setItem)

    if tTag== StatusCode.BUILD_STANDARD then
        setItem:setPositionY(highH + 250)
        highTag:setPositionY(highH + 250)
    elseif tTag == StatusCode.BUILD_SNG then
        setItem:setPositionY(highH + 210)
        highTag:setPositionY(highH + 210)
    end

    MainHelp.mainAdaptSenior({nodes[2], nodes[3], highBtnNode}, tTag)
end



local function addHallCell(idx, parent)
    idx = getNewIdx(idx)
    local cdata = _data[ idx ]
    
    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 33
    local item = UIUtil.addMenuFont(tab, cdata['lookBtn'], cc.p(40,233), allGameBtn, parent)
    item:getParent():setLocalZOrder(2)
    item:setAnchorPoint(0,0.5)
    item:setColor(cc.c3b(23,86,169))
    item:setTag(cdata['tag'])

    commonCell(idx, parent, function(isDis)
        item:setVisible(isDis)
    end)

    local hallNode = cc.Node:create()
    parent:addChild(hallNode)

    local text1 = Single:playerModel():getPBetNum()
    local text2 = Single:playerModel():getOnlinePerson()
    UIUtil.addLabelArial('记分牌余额:'..text1, 32, cc.p(50,550), cc.p(0,0.5), hallNode, cc.c3b(0,0,0))
    UIUtil.addLabelArial('在线人数:'..text2, 32, cc.p(50,650), cc.p(0,0.5), hallNode, cc.c3b(0,0,0))
    

    addSplitLine(cc.p(335,839), hallNode)
    addSplitLine(cc.p(335,721), hallNode)
    addSplitLine(cc.p(335,600), hallNode)
    addSplitLine(cc.p(335,500), hallNode)

    --三角、查看全部游戏
    local arrs = {item, hallNode}
    MainHelp.mainEditHall(arrs)
end


local function addBuildCell(idx, parent)
    idx = getNewIdx(idx)
    local cdata = _data[ idx ]
    local tTag = cdata['tag']

    commonCell(idx, parent, function()end)

    local buildNode = cc.Node:create()
    parent:addChild(buildNode)

    --edit
    local function editChange(ctype, sender)
        if ctype == 'began' then
            tedit:setPlaceHolder('')
        end
        cdata['gameName'] = sender:getText()
    end

    local holder = cdata['gameName']
    local input = UIUtil.addPosSprite('main/main_input2.png', cc.p(_csize.width/2 ,750+ 200), buildNode, nil)
    input:setScale(0.95)
    local tedit = UIUtil.addEditBox(nil, cc.size(540,83), cc.p(_csize.width/2,750 + 200), '', buildNode)
    tedit:registerScriptEditBoxHandler(editChange)
    tedit:setText(holder)
    tedit:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    tedit:setFontColor(cc.c3b(255, 255, 255))

    --标准牌局、sng、heads-up
    local text = Single:playerModel():getPBetNum()
    local account = '记分牌余额:'..text
   
    if tTag== StatusCode.BUILD_STANDARD then
        local ttf4 = UIUtil.addLabelArial('', 32, cc.p(50,550 + 200 - 20), cc.p(0,0.5), buildNode, cc.c3b(0, 0, 0))
        UIUtil.addLabelArial(account, 32, cc.p(40,550), cc.p(0,0.5), buildNode, cc.c3b(0,0,0))
        local layer1, ttime1 = DZUi.addUISlider(buildNode, DZUi.SLIDER_TEN, cc.p(_csize.width/2,500 + 200 - 20), function(val)
            cdata['gameTime'] = val
            ttf4:setString("牌局时长:"..val.."h")
        end, cdata['gameTime'])

        ttf4:setString("牌局时长:"..cdata['gameTime'].."h")

        addSplitLine(cc.p(335,899), buildNode)
        addSplitLine(cc.p(335,781), buildNode)
        addSplitLine(cc.p(335,600), buildNode)
        addSplitLine(cc.p(335,500), buildNode)

        local arrs = {buildNode}
        MainHelp.mainEditBuildStandard(arrs)
    elseif tTag == StatusCode.BUILD_SNG then
        local upttfTime = UIUtil.addLabelArial('', 32, cc.p(40,740), cc.p(0,0.5), buildNode, cc.c3b(0,0,0))
        local ttfScores = UIUtil.addLabelArial('', 32, cc.p(40,605), cc.p(0,0.5), buildNode, cc.c3b(0,0,0))
        UIUtil.addLabelArial(account, 32, cc.p(40,460), cc.p(0,0.5), buildNode, cc.c3b(0,0,0))

        local layer2, ttime2 = DZUi.addUISlider(buildNode, DZUi.SLIDER_FOUR, cc.p(_csize.width/2,695), function(val)
            cdata['upTime'] = val
            upttfTime:setString('升盲时间:'..val..'分钟')
        end, cdata['upTime'])
        local layer3, ttime3 = DZUi.addUISlider(buildNode, DZUi.SLIDER_SIX, cc.p(_csize.width/2,560), function(val)
            cdata['beginScores'] = val
            ttfScores:setString('起始记分牌:'..val..'BBS')
        end, cdata['beginScores'])

        upttfTime:setString('升盲时间:'..ttime2..'分钟')
        ttfScores:setString('起始记分牌:'..ttime3..'BBS')

        local line1 = addSplitLine(cc.p(335,899), buildNode)
        local line2 = addSplitLine(cc.p(335,781), buildNode)
        addSplitLine(cc.p(335,639), buildNode)
        addSplitLine(cc.p(335,498), buildNode)
        addSplitLine(cc.p(335,432), buildNode)

        local arrs = {buildNode, line1, line2, tedit, input}
        MainHelp.mainEditBuildSNG(arrs)
    end
end


local function createLayer(parent)
    local tlayer = cc.LayerColor:create(cc.c4b(255,255,255,0), display.width, 960)
    parent:addChild(tlayer)

    -- local toplH = MainHelp.getTopEditHeight()/2 - 10
    local toplH = 120
    local topl = cc.LayerColor:create(cc.c4b(255,255,255,255), display.width, toplH)
    topl:setPositionY(display.height)
    parent:addChild(topl)
    _topLayer = topl

    if not MainModel:isEditStatus() then
        DZAction.easeInMove(topl, cc.p(0,display.height-toplH), 0.2, DZAction.MOVE_TO, nil)
    else
        topl:setPositionY(display.height-toplH)
    end
    MainModel:setEditStatus(true)

    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 40
    local setItem = UIUtil.addMenuFont(tab, '完成', cc.p(display.width-70,8), finishBtn, topl)
    setItem:setColor(cc.c3b(23,86,169))
    setItem:setAnchorPoint(0.5,0)
    UIUtil.addLabelArial('选择游戏', 40, cc.p(display.width/2,8), cc.p(0.5,0), topl, cc.c3b(0,0,0))

    
    local backCell = addHallCell
    if _tag == BUILD_TAG then
        backCell = addBuildCell
    end

    local pageNums = {98, 100, 102}
    local PageTable = require 'main.PageTable'
    local page = PageTable:create(cc.size(display.width, _csize.height), cc.p(0,25), tlayer, scrollBack)
    page:createPage(_csize, pageNums[_pageIdx], backCell, 45)
    page:addTouch(100, tlayer)


    local tx = display.width / 2 - 40
    if #_data == 2 then
        tx = display.width / 2 - 20
    end

    local adaps = {}
    _arrpos = {}
    for i=1,#_data do
        local dot = UIUtil.addPosSprite('main/main_dot1.png', cc.p(tx,25), tlayer, cc.p(0.5,0.5))

        if i == 1 then
            _line = UIUtil.addPosSprite('main/main_dot2.png', cc.p(tx,25), tlayer, cc.p(0.5,0.5))
        end

        table.insert(_arrpos, tx)        
        table.insert(adaps, dot)        
        tx = tx + 40
    end

    setScrollIdx()

    local arrs = {page, _line, adaps}
    MainHelp.mainAdaptationEdit(arrs)

    return tlayer
end


local function clearData(tag)
    _tag = tag
    _data = {}
    _btnTexts = {}
    _btnLocks = {}
end

--重新适配
local function ResetScreen()
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
    --     if(g_layer ~= nil) then
    --         g_layer:setPosition(cc.p(realx, 0))
    --     end
    -- else
        
    -- end
    local realx = StringUtils.setKCAdapter()
    if realx then
        if(g_layer ~= nil) then
            g_layer:setPosition(cc.p(realx, 0))
        end
    end
end

--新版编辑界面
local function createLayerNew(parent)
    g_listener = nil
    g_layer = nil
    --DZChat.clickShowTimeDlg("你的比赛60秒后开始", "60秒", "23221")
    local titleTxt = {'自由单桌', '无', '单挑'}
    local cdata = _data[ _pageIdx ]
    local rdata = _resData[ _pageIdx ]

    --大厅：标准、heads-up、 0 是标准、1 保险
    local tgmode = 0
    cdata['game_mode'] = tgmode

    ---标准按钮----
    local function bzBtn(sender)
        cdata['game_mode'] = 0
        if tgmode == 0 then return end
        tgmode = 0

        sender:loadTextureNormal("bg/e_sBtn.png")
        sender:setTitleColor(cc.c3b(255, 255, 255))
        g_bxBtn:loadTextureNormal("bg/e_sBtnUn.png")
        g_bxBtn:setTitleColor(cc.c3b(77, 77, 77))
    end

    ---保险按钮---
    local function bxBtn( sender )
        cdata['game_mode'] = 1
        if tgmode == 1 then return end
        tgmode = 1

        sender:loadTextureNormal("bg/e_sBtn.png")
        sender:setTitleColor(cc.c3b(255, 255, 255))
        g_bzBtn:loadTextureNormal("bg/e_sBtnUn.png")
        g_bzBtn:setTitleColor(cc.c3b(77, 77, 77))
    end

    local tlayer = cc.LayerColor:create(cc.c4b(255,255,255,0), display.width, 960)
    parent:addChild(tlayer)
    _layer = tlayer
    local cs = cc.CSLoader:createNodeWithVisibleSize('scene/MainEditHall.csb')
    tlayer:addChild(cs)
    _root = nil
    local root = cs:getChildByName("Panel_root")
    _root = root

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(root, "Button_back")
    btn:touchEnded(finishBtn)
    --快速开始
    local sBtn = ccui.Helper:seekWidgetByName(root, "Button_start")
    sBtn:touchEnded(startBtn)
    sBtn:setTag(cdata['tag'])
    sBtn._btnData = cdata
    --全部游戏
    local agBtn = ccui.Helper:seekWidgetByName(root, "Button_lookAll")
    agBtn:touchEnded(allGameBtn)
    agBtn:setTag(cdata['tag'])
    
    
    --标准，保险按钮
    local button_bz = ccui.Helper:seekWidgetByName(root, "Button_bz")
    button_bz:touchEnded(bzBtn)
    g_bzBtn = button_bz
    local button_bx = ccui.Helper:seekWidgetByName(root, "Button_bx")
    button_bx:touchEnded(bxBtn)
    g_bxBtn = button_bx

    --保险说明小问号
    local button_hp = ccui.Helper:seekWidgetByName(root, "Button_showBXhelp")
    button_hp:touchEnded(bxHelpBtn)
    

    --帮助按钮
    local button_how = ccui.Helper:seekWidgetByName(root, "Button_how")
    button_how:touchEnded(showHelp)

    --滑动条相关
    --与滑动条连动的文字
    --盲注
    local ttf1 = ccui.Helper:seekWidgetByName(root, "Text_mangzhu")
    --带入记分牌
    local ttf2 = ccui.Helper:seekWidgetByName(root, "Text_jfp")
    local arr = MainCtrol.getSliderArray(cdata['tag'])

    local function sliderEvent(sender,eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local idx = math.floor(sender:getPercent())

            if(idx <= 0) then
                idx = 1
            end
            
            print("sender:getPercent()="..sender:getPercent())
            cdata['numOne'] = arr[ idx ]
            g_inPai = tonumber(cdata['numOne'])*100

            local tone,ttwo = MainCtrol.getEditText(cdata, rdata)
            ttf1:setString(tone)
            ttf2:setString(ttwo)
        end
    end

    local slider = ccui.Helper:seekWidgetByName(root, "Slider_process")
    slider:addEventListener(sliderEvent)

    --id=3 单挑； id=1 自由单桌
    if(_pageIdx == 1) then
        slider:setMaxPercent(11)
    else
        slider:setMaxPercent(13)
    end

    --初始化记忆进度
    local val = 1.1
    for i=1,#arr do
        if cdata['numOne'] == arr[ i ] then
            val = i + 0.1
            break
        end
    end

    slider:setPercent(val)
    sliderEvent(slider, ccui.SliderEventType.percentChanged)


    --记分牌余额
    local text1 = Single:playerModel():getPBetNum()
    --在线人数
    local text2 = Single:playerModel():getOnlinePerson()
    --标题
    local text3 = titleTxt[_pageIdx]
    
    local txt = ccui.Helper:seekWidgetByName(root, "Text_yuE")
    txt:setString(text1)
    txt = ccui.Helper:seekWidgetByName(root, "Text_peopleOLNum")
    txt:setString(text2)
    txt = ccui.Helper:seekWidgetByName(root, "Text_title")
    txt:setString(text3)


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
    --     tlayer:setPosition(cc.p(realx, 0))
    -- else
        
    -- end
    local realx = StringUtils.setKCAdapter()
    if realx then
        tlayer:setPosition(cc.p(realx, 0))
    end


    --注册刷新事件
    local listenerCustom = cc.EventListenerCustom:create("C_Event_reset_Screen", ResetScreen)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    g_listener = listenerCustom

    --退出后移除注册的事件
    local function onNodeEvent(event)
        if event == "exit" then
            if(g_listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(g_listener)
            end
        end
    end
    
    tlayer:registerScriptHandler(onNodeEvent)
    g_layer = tlayer
    return tlayer

end

function EditTable.createEditHall(parent, pidx)
    clearData(HALL_TAG)
    _pageIdx = pidx
    _resData = MainModel:getEditResData(false)
    _data = MainModel:getEditHallData(_btnTexts, _btnLocks)
    print("_pageIdx=".._pageIdx)--id=3 单挑； id=1 自由单桌
    --return createLayer(parent)
    return createLayerNew(parent)
end

function EditTable.createEditBuild(parent, pidx)
    clearData(BUILD_TAG)
    _pageIdx = pidx
    _resData = MainModel:getEditResData(true)
    _data = MainModel:getEditBuildData(_btnTexts, _btnLocks)
    return createLayer(parent)
end

return EditTable
