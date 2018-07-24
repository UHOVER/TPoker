local GWindow = class('GWindow')

local function shieldLayer(cLayer)
    local function onTouchBegan(touch, event)
        return true
    end
    local function onTouchMoved(touch, event)  end
    local function onTouchEnded(touch, event)  end 

    local listener = cc.EventListenerTouchOneByOne:create()  
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)  
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)  
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = cLayer:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, cLayer)
end

local function addCenterCSB(nameCSB, cLayer, pos, isNode)
    if pos == nil then
        pos = display.center
    end

    local runScene = cc.Director:getInstance():getRunningScene()
    local csLayer = cc.CSLoader:createNodeWithVisibleSize(nameCSB)
    if isNode then
        csLayer = cc.CSLoader:createNode(nameCSB)
    end

    csLayer:setPosition(pos)
    cLayer:addChild(csLayer)
    runScene:addChild(cLayer, StringUtils.getMaxZOrder(runScene))

    return csLayer
end

local function windowMiddleAni(cs)
    cs:ignoreAnchorPointForPosition(false)
    cs:setAnchorPoint(cc.p(0.5,0.5))
    cs:setPosition(display.center)
    DZAction.showWindow(cs, nil)
end

local function getWindowBg(winw, winh)
    local alpha = 150
    if Single:gameModel():isPause() then
        alpha = 0
    end
    return cc.LayerColor:create(cc.c4b(0,0,0,alpha), winw, winh)
end



function GWindow.showEmoji(touchBack)
    local glayer = getWindowBg(display.width, display.height + 400)
    glayer:setPositionY(-194)
    DZAction.easeInMove(glayer, cc.p(0,0), 0.25, DZAction.MOVE_TO, nil)

    local function touchEmojiBg()
        DZAction.easeInMove(glayer, cc.p(0,-194), 0.25, DZAction.MOVE_TO, function()
            glayer:removeFromParent()
        end)
    end
    local function touchEmoji(touch, event)
        local rnum = 6
        local target = event:getCurrentTarget()
        local tpos = target:convertToNodeSpace(touch:getLocation())
        local ty = tpos.y
        local tw = display.width / rnum
        local idx = math.floor(tpos.x / tw) + 1

        if ty > 100 and ty < 190 then
        elseif ty > 0 and ty < 100 then
            idx = rnum + idx
        end

        glayer:removeFromParent()

        local changes = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
        SocketCtrol.sendEmoji(changes[ idx ], function()
            local imgName = DZConfig.emojiImg(changes[ idx ])
            touchBack(idx, imgName)
        end)
    end

    local ecs = addCenterCSB(ResLib.GEMOJI_CSB, glayer, cc.p(0,0))

    local emojibg = ecs:getChildByName('game_emoji_bg_1')
    emojibg.noEndedBack = touchEmojiBg
    emojibg.endedBack = touchEmoji
    TouchBack.registerImg(emojibg)

    shieldLayer(glayer)
end


function GWindow.showMenu()
    local glh = display.height + 654
    local glayer = getWindowBg(display.width, glh)

    DZAction.easeInMove(glayer, cc.p(0,-654), 0.25, DZAction.MOVE_TO, nil)

  
    local function touchClose()
        DZAction.easeInMove(glayer, cc.p(0,0), 0.25, DZAction.MOVE_TO, function()
            glayer:removeFromParent()
        end)
    end

    local function scaleAni()
        glayer:removeFromParent()
    end

    local function handleStand()
        scaleAni()
        SocketCtrol.leaveGame(function() 
        end)
    end
    local function handleHome()
        scaleAni()
        GWindow.showHome()
    end
    local function handleType()
        scaleAni()
        GWindow.showPokerType()
    end
    local function handleAddBet()
        scaleAni()
        GWindow.showBuy(function()end, GWindow.NO_STAND)
    end
    --保险说明
    local function handleInsureDes()
        print("handleInsureDes")
        scaleAni()
        GWindow.showInsureHelp()
    end
    --换桌面颜色
    local function handleDeskColor()
        scaleAni()
        GWindow.setDesk()
    end

        
    local function handleExit()
        scaleAni()
        local model = GSelfData.getSelfModel()
        if GData:isInsureBuying() then 
           ViewCtrol.showMsg("您正在保险模式中，无法退出牌局", 3)
        elseif model and GJust.isGamingByStatus(model:getStatus()) then 
             ViewCtrol.popHint({popType=2, bgSize = cc.size(display.width-100, 300), 
                            content = "如果现在退出，将损失所有已经下注的记分牌！", sureFunBack = function() 
                                DiffType.userExitGame()
                            end})
        else 
            DiffType.userExitGame()
        end
    end

    local mcs = addCenterCSB(ResLib.GMENU_CSB, glayer, cc.p(0,0), true)
    mcs:ignoreAnchorPointForPosition(false)
    mcs:setAnchorPoint(0,1)
    mcs:setPositionY(glh)
    local menubg = mcs:getChildByName('bg')
    menubg.noEndedBack = touchClose
    TouchBack.registerImg(menubg)

    local btnBase = mcs:getChildByName('menuBase')
    local btnHEye = btnBase:getChildByName('btnHEye')
    local btnHSet = btnBase:getChildByName('btnHSet')
    local btnHType = btnBase:getChildByName('btnHType')
    local btnHAddBet = btnBase:getChildByName('btnHAddBet')
    local btnHExit = btnBase:getChildByName('btnHExit')
    local btnHInsure = btnBase:getChildByName('btnHInsure') --保险按钮
    local btnHColor = btnBase:getChildByName('btnHColor')
    btnHColor:setTouchEnabled(true)
    btnHColor:setVisible(true)

    local btns = {btnHEye, btnHSet, btnHInsure, btnHType, btnHAddBet, btnHExit, btnHColor}
    local funcs = {handleStand, handleHome,handleInsureDes, handleType, handleAddBet, handleExit, handleDeskColor}
    for i=1,#btns do
        btns[ i ]:touchEnded(funcs[ i ])
        GUI.setStudioFontBold({btns[ i ]:getChildByName('ttfBtnText')})
        btns[ i ]:setTouchEnabled(false)
        btns[ i ]:setVisible(false)
    end


    local posys = {614.0, 510.0, 94.0, 406.0, 302.0, 198.0, -10}

    local sortPosys = {614.0, 510.0, 406.0, 302.0, 198.0, 94.0, -10}
    local isManager = Single:gameModel():isManager()
    local isInsure = Single:gameModel():isInsuranceGame()

    --有房主和保险、有房主和无保险、无房主和有保险、无房主和无保险
    if isManager and isInsure then
        btns = {btnHEye, btnHSet, btnHColor, btnHInsure, btnHType, btnHAddBet, btnHExit}
        menubg:setScaleY(1.7)
    elseif isManager and not isInsure then
        btns = {btnHEye, btnHSet, btnHType, btnHAddBet, btnHColor, btnHExit}
        menubg:setScaleY(1.47)
    elseif not isManager and isInsure then
        btns = {btnHEye, btnHInsure, btnHType, btnHAddBet, btnHColor, btnHExit}
        menubg:setScaleY(1.47)
    elseif not isManager and not isInsure then
        btns = {btnHEye, btnHType, btnHAddBet, btnHColor, btnHExit}
        menubg:setScaleY(1.25)
    end


    for i=1,#btns do
        btns[ i ]:setPositionY(sortPosys[ i ])
        btns[ i ]:setTouchEnabled(true)
        btns[ i ]:setVisible(true)
    end


    --不可用变灰
    local function btnFalse(btnName)
        local tbtn = btnName
        tbtn:setEnabled(false)
        tbtn:getChildByName('ttfBtnText'):setColor(cc.c3b(94 ,122 ,131))
        tbtn:getChildByName('btnTag'):setVisible(false)
        tbtn:getChildByName('btnDisable'):setVisible(true)
    end

    --保险并且在保险中,退出按钮不能用
    if isInsure and GData:isInsureBuying() then 
        btnFalse(btnHExit)
    end
    --站起
    if not GJust.isMeSeat() then
        btnFalse(btnHEye)
        btnFalse(btnHAddBet)
    end
    --暂停游戏
    if Single:gameModel():isPause() then
        btnFalse(btnHEye)
        btnFalse(btnHAddBet)
        btnFalse(btnHSet)
        btnFalse(btnHExit)
    end

    shieldLayer(glayer)
end


local function getMenus(menuBase)
    local btnHEye = menuBase:getChildByName('btnHEye')
    local btnHSet = menuBase:getChildByName('btnHSet')
    local btnHType = menuBase:getChildByName('btnHType')
    local btnHAddBet = menuBase:getChildByName('btnHAddBet')
    local btnHExit = menuBase:getChildByName('btnHExit')
    return {btnHEye, btnHSet, btnHType, btnHAddBet, btnHExit}
end

function GWindow.showSNGMenu()
    print("sng menu")
    local glh = display.height + 654
    local glayer = getWindowBg(display.width, glh)

    DZAction.easeInMove(glayer, cc.p(0,-654), 0.25, DZAction.MOVE_TO, nil)
    local function touchClose()
        DZAction.easeInMove(glayer, cc.p(0,0), 0.25, DZAction.MOVE_TO, function()
            glayer:removeFromParent()
        end)
    end
    local function scaleAni()
        glayer:removeFromParent()
    end

    local function handleType()
        scaleAni()
        GWindow.showPokerType()
    end
    local function handleReward()
        scaleAni()
        GWindow.showSNGRule()
    end
    local function handleExit()
        DiffType.userExitGame()
    end
    local function handleDeskColor()
        scaleAni()
        GWindow.setDesk()
    end

    local mcs = addCenterCSB(ResLib.GMENU_CSB, glayer, cc.p(0,0), true)
    mcs:ignoreAnchorPointForPosition(false)
    mcs:setAnchorPoint(0,1)
    mcs:setPositionY(glh)

    local menubg = mcs:getChildByName('bg')
    menubg:setScaleY(1)
    menubg.noEndedBack = touchClose
    TouchBack.registerImg(menubg)

    local btnBase = mcs:getChildByName('menuBase')
    local btns = getMenus(btnBase)

    local funcs = {handleType, handleReward, handleDeskColor, handleExit}
    local imgs = {'game_htype.png', 'game_rule.png', 'game_hcolor.png', 'game_hexit.png'}
    local texts = {'牌型提示', '规则奖励', '桌面设置', '离开比赛'}
    local enables = {true, true, true, true, false}
    if GSelfData.isHavedSeat() then 
        texts[4] = '托管并离开'
    end
    for i=1,#btns do
        if #funcs >= i then
            btns[ i ]:touchEnded(funcs[i])
        else
            btns[ i ]:touchEnded(function()end)
        end
        if #imgs >= i then
            btns[ i ]:getChildByName('btnTag'):setTexture('game/'..imgs[i])
        end
        if #texts >= i then
            btns[ i ]:getChildByName('ttfBtnText'):setString(texts[i])
        end

        if #enables >= i then
            btns[ i ]:setVisible(enables[i])
        end

        GUI.setStudioFontBold({btns[ i ]:getChildByName('ttfBtnText')})
    end

    shieldLayer(glayer)
end

function GWindow.showMTTMenu()
    print("showMttMenu")
    local glh = display.height + 654
    local glayer = getWindowBg(display.width, glh)
    local nowBlindLevel = GData.getNowBlindLevel()
    local overBlindLevel = GData.getOverBlindLevel()

    DZAction.easeInMove(glayer, cc.p(0,-654), 0.25, DZAction.MOVE_TO, nil)

    local function touchClose()
        DZAction.easeInMove(glayer, cc.p(0,0), 0.25, DZAction.MOVE_TO, function()
            glayer:removeFromParent()
        end)
    end
    local function scaleAni()
        glayer:removeFromParent()
    end

    local function handleType()
        scaleAni()
        GWindow.showPokerType()
    end
    local function handleRevive()
        scaleAni()
        --增购、重购
        if nowBlindLevel == overBlindLevel then
            GMttBuy.showAddBuy()
        else
            GMttBuy.showAgainBuy()
        end
    end
    local function handleReward()
        scaleAni()
        GWindow.requestMTTRule()
    end
    local function handleExit()
        DiffType.userExitGame()
    end
    local function handleDeskColor()
        scaleAni()
        GWindow.setDesk()
    end

    local mcs = addCenterCSB(ResLib.GMENU_CSB, glayer, cc.p(0,0), true)
    mcs:ignoreAnchorPointForPosition(false)
    mcs:setAnchorPoint(0,1)
    mcs:setPositionY(glh)

    local menubg = mcs:getChildByName('bg')
    menubg:setScaleY(1.5)
    menubg:setPositionY(menubg:getPositionY() + 104)
    menubg.noEndedBack = touchClose
    TouchBack.registerImg(menubg)

    local btnBase = mcs:getChildByName('menuBase')
    local btns = getMenus(btnBase)

    local funcs = {handleType, handleRevive, handleReward, handleDeskColor, handleExit}
    local imgs = {'game_htype.png', 'game_hrevive1.png', 'game_rule.png', 'game_hcolor.png', 'game_hexit.png'}
    local texts = {'牌型提示', '重购', '规则奖励', '桌面设置', '离开比赛'}
    if GSelfData.isHavedSeat() then 
        texts[5] = '托管并离开'
    end
   
    local enables = {true, true, true, true, true}
    
    for i=1,#btns do
        if #funcs >= i then
            btns[ i ]:touchEnded(funcs[i])
        else
            btns[ i ]:touchEnded(function()end)
        end
        if #imgs >= i then
            btns[ i ]:getChildByName('btnTag'):setTexture('game/'..imgs[i])
        end
        if #texts >= i then
            btns[ i ]:getChildByName('ttfBtnText'):setString(texts[i])
        end

        if #enables >= i then
            btns[ i ]:setVisible(enables[i])
        end

        GUI.setStudioFontBold({btns[ i ]:getChildByName('ttfBtnText')})
    end

    local btnHSet = btnBase:getChildByName('btnHSet')
    
    --重购、增购不可用
    local function reviveBtnFalse()
        btnHSet:setEnabled(false)
        btnHSet:getChildByName('btnTag'):setTexture('game/game_hrevive2.png')
    end
    --重购边增购
    local function reviveChangeAdd()
        btnHSet:getChildByName('ttfBtnText'):setString('增购')
    end

    --我站起、剩余记分牌大于等于初始记分牌、当前盲注级别大于增购级别
    --、重购次数用完
    local meMod = GSelfData.getSelfModel()
    local initScore = GData.getMttInitScore()

    --没有弃牌 积分=剩余的+底池
    --弃牌了   积分=剩余的
    local compareScore = 0
    if meMod then
        compareScore = meMod:getAllSurplusNum()
        if meMod:getStatus() == StatusCode.GAME_GIVEUP then
            compareScore = meMod:getSurplusNum()
        end
    end

    --我是站起、剩余记分大于初始积分
    if not meMod then
        reviveBtnFalse()
    elseif initScore <= compareScore then
        --并且当前不可以增购
        if overBlindLevel ~= nowBlindLevel then
            reviveBtnFalse()
        end
    end

    --可以报名、不可以报名、不可以报名但可以增购 =
    if overBlindLevel > nowBlindLevel then
        if GData.getSurplusAgainTimes() == 0 then
            reviveBtnFalse()
        end
    elseif overBlindLevel < nowBlindLevel then
        reviveBtnFalse()
    else
        reviveChangeAdd()
        -- 增购次数用完
        if GData.getSurplusAddTimes() == 0 then
            reviveBtnFalse()
        end
    end

    shieldLayer(glayer)
end

--显示保险帮助页
function GWindow.showInsureHelp()
    local runScene = cc.Director:getInstance():getRunningScene()
    local bgLayer = runScene:getChildByName("INSURE_HELP_DIALOG")
    if bgLayer then 
        bgLayer:removeFromParent()
    end
    
    
    bgLayer = require("main/HelpDlg"):create(5)
    bgLayer:setName("INSURE_HELP_DIALOG")
    runScene:addChild(bgLayer, StringUtils.getMaxZOrder(runScene))
    bgLayer:ignoreAnchorPointForPosition(false)
    bgLayer:setContentSize(display.size)
    windowMiddleAni(bgLayer)
    local bgColor = getWindowBg(display.width, display.height)
    bgLayer:addChild(bgColor, -1)
end
--1：加入牌局
--2：购买记分牌
GWindow.STAND = 1
GWindow.NO_STAND = 2
function GWindow.showBuy(buyBack, ctype)
    GWindow.removeBuy()
    
    local glayer = getWindowBg(display.width, display.height)
    glayer:setName('SHOW_BUY_BET')
    local bcs = addCenterCSB(ResLib.GBUY_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)

    local nodeOne = bcs:getChildByName('nodeOne')
    local nodeTwo = bcs:getChildByName('nodeTwo')

    local myBet = Single:playerModel():getPBetNum()
    bcs:getChildByName('ttfWealthNum'):setString(myBet)

    local isEnter = true
    local function onEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            isEnter = false
        end
    end
    local tnode = cc.Node:create()
    tnode:registerScriptHandler(onEvent)
    glayer:addChild(tnode)

    local function removeLayer()
        if not isEnter then return end
        if glayer then
            glayer:removeFromParent()
            glayer = nil
        end
    end
    local function handleClose()
        if ctype == GWindow.STAND then
            SocketCtrol.leaveGame(function()
                removeLayer()
            end, function()
                removeLayer()
            end)
        else
            removeLayer()
        end
    end
    local function requestNet(val)
        SocketCtrol.supplementScores(val, function()
            removeLayer()
        end, function()
            removeLayer()
        end)
    end

    local sblind = Single:gameModel():getSmallBlind()
    local bigBlind = sblind * 2 
    local buyVal = bigBlind * 100
    local function handleBuy()
        requestNet(buyVal)
    end

    local nodeRecord = bcs:getChildByName('nodeRecord')
    local gtype = Single:gameModel():getGameType()

    local maxNum = 4 * 10 - 1
    local function valueChanged(sender)
        local nowVal = math.floor(sender:getValue() / 10) + 1
        local nowBlind = nowVal * bigBlind
        buyVal = nowBlind * 100
        nodeTwo:getChildByName('ttfIntoBet'):setString(buyVal)

        if not DZConfig.isHallGame(gtype) then
            local rfee = DiffType.getRecordFee(buyVal / 100)
            nodeRecord:getChildByName('ttfRecordFee'):setString(rfee)
        end
    end
    nodeTwo:getChildByName('ttfIntoBet'):setString(buyVal)
    
    if DZConfig.isHallGame(gtype) then
        nodeRecord:setPositionX(1000)
    else
        local rfee = DiffType.getRecordFee(buyVal / 100)
        nodeRecord:getChildByName('ttfRecordFee'):setString(rfee)
    end

    bcs:getChildByName('btnSure'):touchEnded(handleBuy)
    bcs:getChildByName('btnClose'):touchEnded(handleClose)

    local tx = bcs:getContentSize().width / 2
    local imgs = {"game/game_progress_bet.png", "game/game_progress_bet_bg.png", 'icon/thumbnail_btn.png'}
    local tslider = UIUtil.addSlider(imgs, cc.p(tx,325), bcs, valueChanged, 0, maxNum)
    tslider:setAnchorPoint(0.5,0.5)
    -- tslider:getSelectedThumbSprite():setAnchorPoint(0, 0.5)
    -- tslider:getThumbSprite():setAnchorPoint(0, 0.5)
    local slidersize = tslider:getContentSize()
    UIUtil.addLabelArial("min",22,cc.p(tx - slidersize.width/2, 325-50), cc.p(0,1),bcs,cc.c3b(170,170,170))
    UIUtil.addLabelArial("max",22,cc.p(tx + slidersize.width/2, 325-50), cc.p(1,1),bcs,cc.c3b(170,170,170))
    shieldLayer(glayer)

    --1：加入牌局
    --2：购买记分牌
    if ctype == 1 then
        local gname = Single:gameModel():getGameName()
        bcs:getChildByName('Text_1'):setString(gname)
        bcs:getChildByName('Text_2'):setVisible(false)
        -- nodeOne:setPositionX(225)
        -- nodeTwo:setPositionX(488)
        nodeOne:getChildByName('ttfBlind'):setString(sblind..'/'..bigBlind)
        local btn = bcs:getChildByName('btnSure')
        btn:setTitleText('加入牌局')
    elseif ctype == 2 then
        bcs:getChildByName('line1'):setVisible(false)
        nodeTwo:setPositionX(tx)
        local text_2_0  = nodeTwo:getChildByName("Text_2_0")
        local ttfIntoBet = nodeTwo:getChildByName("ttfIntoBet")
        local icon_blue_bet2_2 = nodeTwo:getChildByName("icon_blue_bet2_2")
        -- text_2_0:setPositionY(451)
        ttfIntoBet:setFontSize(46)
        ttfIntoBet:setPositionY(444)
        ttfIntoBet:setAnchorPoint(cc.p(.5, 1))
        icon_blue_bet2_2:setPositionY(444)
        bcs:getChildByName('Text_2'):setAnchorPoint(cc.p(0.5,1))
        bcs:getChildByName('Text_2'):setPositionY(400)
        nodeOne:setPositionX(-display.width)
    end

    return glayer
end

function GWindow.removeBuy()
    local runScene = cc.Director:getInstance():getRunningScene() 
    local tbuy = runScene:getChildByName('SHOW_BUY_BET')
    if tbuy then
        tbuy:removeFromParent()
    end
end


function GWindow.showPrompt(giveupBack, lookBack, closeBack)
    local glayer = getWindowBg(display.width, display.height)
    local bcs = addCenterCSB(ResLib.GPROMPT_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)

    local isNoPrompt = Storage.getIsNoPrompt()
    local function setPrompt()
        if isNoPrompt then
            bcs:getChildByName('promptDot'):setColor(cc.c3b(0,255,0))
        else
            bcs:getChildByName('promptDot'):setColor(cc.c3b(255,255,255))
        end
    end

    local function handleLook()
        lookBack()
        glayer:removeFromParent()
    end
    local function handleGiveup()
        giveupBack()
        glayer:removeFromParent()
    end
    local function handlePrompt()
        isNoPrompt = not isNoPrompt
        Storage.setIsNoPrompt(isNoPrompt)
        setPrompt()
    end
    local function handleClose()
        closeBack()
        glayer:removeFromParent()
    end

    bcs:getChildByName('btnLook'):touchEnded(handleLook)
    bcs:getChildByName('btnGiveup'):touchEnded(handleGiveup)
    bcs:getChildByName('btnPrompt'):touchEnded(handlePrompt)
    bcs:getChildByName('closebtn'):touchEnded(handleClose)
    local index = 1
    if isNoPrompt then 
        index = 0
    else 
        index = 1
    end
    local switch = UIUtil.addTogMenu({pos = cc.p(519, 76), listener = handlePrompt, parent = bcs})
    switch:setSelectedIndex(index)
    shieldLayer(glayer)

    --没有提示
    setPrompt()
    if isNoPrompt then
        handleGiveup()
    end
end


function GWindow.showHome()
    local glayer = getWindowBg(display.width, display.height)
    local hcs = addCenterCSB(ResLib.GHOME_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(hcs)

    local function setSwitch(enabledBtn)
        hcs:getChildByName('btnSwitch2'):setVisible(false)
        hcs:getChildByName('btnSwitch1'):setVisible(false)

        hcs:getChildByName(enabledBtn):setVisible(true)
        hcs:getChildByName('btnSave'):setEnabled(true)
    end

    local function valueChanged(pSender)
        -- print(pSender:getValue())
    end

    local function handleClose()
        DZAction.hideWindow(hcs, function()
            if glayer and glayer:getParent() then 
                glayer:removeFromParent()
            end
        end)
    end
    local function handleSave(sender)
        -- sender:setEnabled(false)
    end
    local function handleSwitch1(sender)
        SocketCtrol.changeAuthorize(true, function()
            setSwitch('btnSwitch2')
        end) 
    end
    local function handleSwitch2(sender)
    SocketCtrol.changeAuthorize(false, function()
            setSwitch('btnSwitch1')
        end) 
    end
    local function handlePause(sender)
        SocketCtrol.stopGame(function()
                if glayer and glayer:getParent() then 
                    glayer:removeFromParent()
                end
            end)
    end
    local fixdStraddleCK, freeStraddleCK= nil,nil
  
    local function handleFixedStraddle(sender) -- 强制
        freeStraddleCK:setSelected(false)
        if not fixdStraddleCK:isSelected() then --如过没有选中
            print("模式 --- 2")
            fixdStraddleCK:setSelected(true)
            SocketCtrol.sendStraddleMode(MUST_STRADDLE,GData.getGamePId(), Single:playerModel():getId(),function() end)
        else --如果本身是选中的
            print("模式 --- 1")
            fixdStraddleCK:setSelected(false)
            SocketCtrol.sendStraddleMode(NO_STRADDLE,GData.getGamePId(), Single:playerModel():getId(),function() end)
        end
    end
    local function handleFreeStraddle(sender) --自由
        fixdStraddleCK:setSelected(false)
        if not freeStraddleCK:isSelected()  then --如过没有选中
            freeStraddleCK:setSelected(true)
            SocketCtrol.sendStraddleMode(FREE_STRADDLE,GData.getGamePId(), Single:playerModel():getId(),function() end)
        else --如果本身是选中的
            freeStraddleCK:setSelected(false)
            SocketCtrol.sendStraddleMode(NO_STRADDLE,GData.getGamePId(), Single:playerModel():getId(),function() end)
        end
    end

    hcs:getChildByName('btnClose'):touchEnded(handleClose)
    hcs:getChildByName('btnSave'):touchEnded(handleSave)
    hcs:getChildByName('btnSwitch2'):touchEnded(handleSwitch2)
    hcs:getChildByName('btnSwitch1'):touchEnded(handleSwitch1)
    hcs:getChildByName('btnPauseStart'):touchEnded(handlePause)
    
    hcs:getChildByName('btnSwitch1'):setVisible(true)
    hcs:getChildByName('btnSwitch2'):setVisible(false)
    if Single:gameModel():isOpenApplay() then
        hcs:getChildByName('btnSwitch1'):setVisible(false)
        hcs:getChildByName('btnSwitch2'):setVisible(true)
    end
    --处理straddle按钮的显示
    local mustStraddleBtn = hcs:getChildByName('mustStraddlebtn')
    local freeStraddleBtn = hcs:getChildByName('freeStraddlebtn')
    mustStraddleBtn:touchEnded(handleFixedStraddle) 
    freeStraddleBtn:touchEnded(handleFreeStraddle)

    fixdStraddleCK = hcs:getChildByName('forceStraddle')--forceStraddle
    freeStraddleCK = hcs:getChildByName('freeStraddle')--
    local function setStraddleSelect(fixed, free)
        fixdStraddleCK:setSelected(fixed)
        freeStraddleCK:setSelected(free)
    end
    local straddleTag = Single:gameModel():getStraddle()
    print("mode:"..tostring(straddleTag))
    if straddleTag == NO_STRADDLE then 
        setStraddleSelect(false, false)
    elseif straddleTag == FREE_STRADDLE then 
        setStraddleSelect(false, true)
    elseif straddleTag == MUST_STRADDLE then 
        setStraddleSelect(true, false)
    end

    local tx = hcs:getContentSize().width / 2
    local imgs = {"common/com_progress2.png", "common/com_progress1.png", 'icon/icon_thumb_bet.png'}
    local tslider = UIUtil.addSlider(imgs, cc.p(tx,303), hcs, valueChanged, 1, 8)
    tslider:setAnchorPoint(0.5,0.5)


    --固定
    local tab = {}
    tab['fontSize'] = 40
    local ttfOne = hcs:getChildByName('ttfOne')
    local ttfFour = hcs:getChildByName('ttfFour')
    ttfOne:setTextColor(cc.c4b(249,221,154,255))
    ttfFour:setTextColor(cc.c4b(249,221,154,255))
    ttfOne:setFontSize(35)
    ttfFour:setFontSize(35)
    ttfOne:setPositionY(355)
    ttfFour:setPositionY(355)


    UIUtil.addPosSprite('icon/icon_thumb_bet.png', cc.p(210,0), tslider, cc.p(0.5,0))
    local img = "common/com_progress2.png"
    local obg = UIUtil.controlBtn(img, img, img, nil, cc.p(tx,303), cc.size(700,80), function()end, hcs)
    obg:setOpacity(0)

    shieldLayer(glayer)
    return glayer
end


function GWindow.showPokerType()
    local glayer = getWindowBg(display.width, display.height)
    glayer:ignoreAnchorPointForPosition(false)
    glayer:setAnchorPoint(0,1)
    glayer:setPosition(0,display.height)

    local runScene = cc.Director:getInstance():getRunningScene()


    local po = UIUtil.addSprite('game/game_poker_type.png', cc.p(0,display.height), glayer, cc.p(0,1))
    po:setScale(0.9)
    local poh = po:getContentSize().height
    po:setPosition(0,display.height + poh)
    DZAction.easeInMove(po, cc.p(0,display.height), 0.3, DZAction.MOVE_TO, nil)

    local function touchOut()
        DZAction.easeInMove(po, cc.p(0,display.height + poh), 0.3, DZAction.MOVE_TO, function()
            glayer:removeFromParent()
        end)
    end

    po.noEndedBack = touchOut
    TouchBack.registerImg(po)

    shieldLayer(glayer)
    runScene:addChild(glayer, StringUtils.getMaxZOrder(parent))
end


function GWindow.showPause(parent, time, zorder)
    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    parent:addChild(glayer, zorder)
    shieldLayer(glayer)

    local function handelPause()
        print("8******** handelPause *****8")
        SocketCtrol.goonGame(function()
                -- if glayer and glayer:getParent() then 
                --      glayer:removeFromParent()
                -- end
            end)
    end

    local bg = UIUtil.addPosSprite('common/com_time_bg1.png', cc.p(display.cx,display.cy+80), glayer, nil)
    local ttime = time
    local tlabel = UIUtil.addLabelArial('牌局暂停中请等待:', 30, cc.p(display.cx,display.cy+80), cc.p(0.5,0.5), glayer, cc.c3b(255,255,255))
    --
    -- local tlabel = UIUtil.addLabelArial('', 30, cc.p(202,60), cc.p(0.5,1), bg, cc.c3b(255,255,255))

    local function scheduleBack()
        if ttime == 0 then
            glayer:removeFromParent()
            return
        end

        local text = DZTime.secondsMinFormat(ttime)
        tlabel:setString('牌局暂停中请等待:'..text)
        ttime = ttime - 1
    end
    DZSchedule.runSchedule(scheduleBack, 1, tlabel)
    scheduleBack()

    if Single:gameModel():isManager() then
        local img, imgPress = 'game/game_btn_start3.png', 'game/game_btn_start4.png'
        UIUtil.addMenuBtn(img, imgPress, handelPause, cc.p(display.cx-110, 205+63), bg)
    end

    return glayer
end

local function showMTTRule(data)
    local glayer = getWindowBg(display.width, display.height)
    local bcs = addCenterCSB(ResLib.GREWARD_RULE_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)
    local small1 = bcs:getChildByName('imgSmall1')
    local small2 = bcs:getChildByName('imgSmall2')

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()
        end)
    end
    bcs:getChildByName('btnClose'):touchEnded(handleClose)

    small1:getChildByName('ttfPoolVal'):setString(data['allPool'])
    small1:getChildByName('ttfNumVal'):setString(data['surpPerson']..'/'..data['allPerson'])
    small1:getChildByName('ttfRewardVal'):setString(data['rewardNum']..'人')

    local fsize = 32

    local rewards = data['rewards']
    local tsize1 = cc.size(605,155)
    local csize1 = cc.size(605,55)
    local hy1 = csize1.height/2
    local function cellBack1(idx, layer)
        local val = rewards[idx]
        UIUtil.addLabelArial(idx, fsize, cc.p(95,hy1), cc.p(0.5,0.5), layer, cc.c3b(255,255,255))
        UIUtil.addLabelArial(val, fsize, cc.p(439,hy1), cc.p(0.5,0.5), layer, cc.c3b(255,255,255))
    end
    local tablev = UIUtil.addTableView(tsize1, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, small1)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, csize1, #rewards, cellBack1)


    local tsize2 = cc.size(605,440)
    local csize2 = cc.size(605,55)
    local hy2 = csize2.height/2

    -- local bigs = DZConfig.getMTTBuildBigBlind()
    -- local smalls = DZConfig.getMTTBuildSmallBlind()
    -- local antes = DZConfig.getMTTBuildANTE()
    
    -- local smallType = Single:gameModel():getGameType()
    -- if DZConfig.isHallMTT(smallType) then
    --     bigs = DZConfig.getMTTHallBigBlind()
    --     smalls = DZConfig.getMTTHallSmallBlind()
    --     antes = DZConfig.getMTTHallANTE()
    -- end

    local smallType = Single:gameModel():getGameType()
    local blinds = {}
    if DZConfig.isHallMTT(smallType) then
        blinds = DZConfig.getMTTHallBlinds()
    else
        blinds = GData.getMttBlinds()
    end
    local function cellBack2(idx, layer)
        local blindData = blinds[ idx ]
        local blindLevel = blindData['blindLevel']

        local blind = blindData['blindSmall']..'/'..blindData['blindBig']
        local ante = blindData['ante']
        UIUtil.addLabelArial(blindLevel, fsize, cc.p(98,hy2), cc.p(1,0.5), layer, cc.c3b(255,255,255))
        UIUtil.addLabelArial(blind, fsize, cc.p(290,hy2), cc.p(0.5,0.5), layer, cc.c3b(255,255,255))
        UIUtil.addLabelArial(ante, fsize, cc.p(508,hy2), cc.p(0.5,0.5), layer, cc.c3b(255,255,255))

        if blindLevel < data['addLevel'] then
            UIUtil.addPosSprite('mtt/mtt_R.png', cc.p(114,hy2), layer, cc.p(0,0.5))
        elseif blindLevel == data['addLevel'] then
            UIUtil.addPosSprite('mtt/mtt_A.png', cc.p(114,hy2), layer, cc.p(0,0.5))
            UIUtil.addPosSprite('mtt/mtt_X.png', cc.p(59,hy2), layer, cc.p(1,0.5))
        end
    end
    local tablev = UIUtil.addTableView(tsize2, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, small2)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    -- DZUi.addTableView(tablev, csize2, #bigs, cellBack2)
    DZUi.addTableView(tablev, csize2, #blinds, cellBack2)


    small1:getChildByName('imgMask1'):setLocalZOrder(2)
    small2:getChildByName('imgMask2'):setLocalZOrder(2)

    shieldLayer(glayer)

    --设置字体
    local title = bcs:getChildByName('rulebg'):getChildByName('ttfTitle')
    local text1 = small1:getChildByName('ttfPoolText')
    local text2 = small1:getChildByName('ttfNumText')
    local text3 = small1:getChildByName('ttfRewardText')
    local val1 = small1:getChildByName('ttfPoolVal')
    local val2 = small1:getChildByName('ttfNumVal')
    local val3 = small1:getChildByName('ttfRewardVal')
    local title1 = small1:getChildByName('imgLine1'):getChildByName('ttfText1')
    local title2 = small1:getChildByName('imgLine1'):getChildByName('ttfText2')
    local title3 = small2:getChildByName('imgLine2'):getChildByName('ttfText1')
    local title4 = small2:getChildByName('imgLine2'):getChildByName('ttfText2')
    local title5 = small2:getChildByName('imgLine2'):getChildByName('ttfText3')
    local ttfs1 = {title,text1, text2, text3, val1, val2, val3}
    local ttfs2 = {title1,title2, title3, title4, title5}
    GUI.setStudioFontBold(ttfs1)
    GUI.setStudioFontBold(ttfs2)
end

function GWindow.requestMTTRule()
    SocketCtrol.mttRewardRule(function(data)
        showMTTRule(data)
    end)
end


function GWindow.showSNGRule()
    local glayer = getWindowBg(display.width, display.height)
    local bcs = addCenterCSB(ResLib.GSNG_RULE_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()
        end)
    end

    bcs:getChildByName('btnClose'):touchEnded(handleClose)

    local gm = Single:gameModel()
    local minute = GData.getUPBlindMinute()
    local personNum = gm:getGameNum()..'人桌'
    local title = '升盲时间:'..minute..'分钟'
    local sm = GSelfData.getSelfModel()
    local times = '玩家名次'
    if sm and sm:isSeat() then
        times = '您当前：第'..sm:getRank()..'名'
    end
    bcs:getChildByName('ttfPersonNum'):setString(personNum)
    bcs:getChildByName('ttfPokerName'):setString(gm:getGameName())
    bcs:getChildByName('ttfRuleTitle'):setString(title)
    bcs:getChildByName('ttfNowRank'):setString(times)

    local tfirst = bcs:getChildByName('firstReward')
    local tsecond = bcs:getChildByName('secondReward')
    local tthird = bcs:getChildByName('thirdReward')
    tfirst:setVisible(false)
    tsecond:setVisible(false)
    tthird:setVisible(false)

    local nump = gm:getGameNum()
    local rets = DZConfig.getRewardMoney(nump, GData.getSngEntryFee())
    if not rets or #rets == 0 then
        return
    end

    -- local tw = display.width
    local tw = 652
    local arrs = {}
    local one = {tw / 2}
    local two = {208, 444}
    local three = {120, 324, 528}

    if #rets == 1 then
        arrs = one
    elseif #rets == 2 then
        arrs = two
    elseif #rets == 3 then
        arrs = three
    end

    local imgs = {tfirst, tsecond, tthird}
    local names = {'ttfFirst', 'ttfSecond', 'ttfThird'}
    for i=1,#arrs do
        imgs[i]:setPositionX(arrs[i])
        imgs[i]:getChildByName(names[ i ]):setString(rets[i])
        imgs[i]:setVisible(true)
    end

    local listView = bcs:getChildByName('snglvlist')
    local listSize = listView:getContentSize()
    local levels = DZConfig.sngBlindLevel()
    for i = 1, #levels do 
        local item = ccui.Layout:create()
        item:setContentSize(cc.size(listSize.width, 60))
        local level, blind = i, levels[i]
        if type(blind) ~= "number" then
            level ,blind = "", ""
        else 
           blind = levels[i].."/"..levels[i]*2
        end
        UIUtil.addLabelArial(level, 30, cc.p(75,0), cc.p(0.5, 0), item, cc.c3b(255,255,255))
        UIUtil.addLabelArial(blind, 30, cc.p(494,0), cc.p(0.5, 0), item, cc.c3b(255,255,255))
        listView:pushBackCustomItem(item)
    end
    
    shieldLayer(glayer)

    return glayer
end


function GWindow.getWindowOne(closeBack)
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('GET_WINDOW_ONE') then
        runScene:getChildByName('GET_WINDOW_ONE'):removeFromParent()
    end

    local glayer = getWindowBg(display.width, display.height)
    glayer:setName('GET_WINDOW_ONE')
    local bcs = addCenterCSB(ResLib.GWINDOW1_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)
    local bg = bcs:getChildByName('windowBg')

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()

            if closeBack then
                closeBack()
            end
        end)
    end
    bg:getChildByName('btnClose'):touchEnded(handleClose)

    bg._removeWindow = function()
        handleClose()
    end

    local ttfs = {bg:getChildByName('ttfTitleWindow')}
    GUI.setStudioFontBold(ttfs)

    shieldLayer(glayer)
    
    return bg
end

function GWindow.removeWindowOne()
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('GET_WINDOW_ONE') then
        runScene:getChildByName('GET_WINDOW_ONE'):removeFromParent()
    end
end


function GWindow.isShowGetWindowTwo()
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('GET_WINDOW_TWO') then
        return true
    end
    return false
end
function GWindow.getWindowTwo(conText1, conText2, closeBack)
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('GET_WINDOW_TWO') then
        runScene:getChildByName('GET_WINDOW_TWO'):removeFromParent()
    end

    local glayer = getWindowBg(display.width, display.height)
    glayer:setName('GET_WINDOW_TWO')
    local bcs = addCenterCSB(ResLib.GWINDOW2_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)
    local bg = bcs:getChildByName('windowBg')

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()

            if closeBack then
                closeBack()
            end
        end)
    end
    bg:getChildByName('btnClose'):touchEnded(handleClose)

    local titleCon1 = bg:getChildByName('ttfTitleCon1')
    local titleCon2 = bg:getChildByName('ttfTitleCon2')

    local ttfs = {titleCon1, titleCon2}
    GUI.setStudioFontBold(ttfs)

    titleCon1:setString(conText1)
    titleCon2:setString(conText2)

    shieldLayer(glayer)
    
    return bg
end


function GWindow.isShowMTTOver()
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('SHOW_MTT_OVER') then
        return true
    end
    return false
end
function GWindow.showMTTOver(data, cnum, closeBack)
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('SHOW_MTT_OVER') then
        runScene:getChildByName('SHOW_MTT_OVER'):removeFromParent()
    end

    local glayer = getWindowBg(display.width, display.height)
    glayer:setName('SHOW_MTT_OVER')
    local bcs = addCenterCSB(ResLib.MTT_OVER_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)
    local bg = bcs:getChildByName('windowBg')

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()

            if closeBack then
                closeBack()
            end
        end)
    end
    bg:getChildByName('btnClose'):touchEnded(handleClose)

    local imgSmall1 = bg:getChildByName('imgSmall1')
    local imgSmall2 = bg:getChildByName('imgSmall2')

    local title = bg:getChildByName('ttfTitleWindow')
    local ttfRank = imgSmall1:getChildByName('ttfRank')
    local ttfReward = imgSmall1:getChildByName('ttfReward')

    local ttfs = {title, ttfRank, ttfReward}
    GUI.setStudioFontBold(ttfs)

    ttfRank:setString(data['numText'])
    ttfReward:setString(data['rewardText'])

    local gName = Single:gameModel():getGameName()
    local ttfMttName = imgSmall2:getChildByName('ttfMttName')
    local ttfPersonal = imgSmall2:getChildByName('ttfPersonal')
    local ttfPoolReward = imgSmall2:getChildByName('ttfPoolReward')

    local ttfTime = imgSmall2:getChildByName('ttfTime')
    local ttfBlindLevel = imgSmall2:getChildByName('ttfBlindLevel')
    local ttfRewardNum = imgSmall2:getChildByName('ttfRewardNum')
    local ttfPersonTran = imgSmall2:getChildByName('ttfPersonTran')

    ttfMttName:setString(gName)
    ttfMttName:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)

    ttfPersonal:setString(data['joinNum'])--参赛人数：
    ttfPersonal:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)
    ttfPoolReward:setString(data['allNum'])--总奖池：
    ttfPoolReward:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)
    local ttime = DZTime.secondsHourFormat(data['pokerTime'])
    ttfTime:setString(ttime)--牌局时间：
    ttfTime:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)
    ttfBlindLevel:setString(data['blindLevel'])--盲注级别
    ttfBlindLevel:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)
    ttfRewardNum:setString(data['rewardNum'])--奖励圈：
    ttfRewardNum:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)

    local addTotalTimes = data['addNum']
    local transPersonStr = data['participatedNum'] + data["rebyNum"]
    if addTotalTimes > 0 then 
        transPersonStr = tostring(transPersonStr).."+"..tostring(addTotalTimes)
    end
    ttfPersonTran:setString(transPersonStr)--参赛人次：
    ttfPersonTran:enableShadow(cc.c3b(255,255,255), cc.size(0.9,0), 0)

    if addTotalTimes > 0 then 
        local posx,posy = ttfPersonTran:getPositionX() + ttfPersonTran:getContentSize().width/2,ttfPersonTran:getPositionY()-3
        UIUtil.addPosSprite("common/a.png", cc.p(posx, posy), imgSmall2, cc.p(0, 1))
    end

    local csize = cc.size(605, 63)
    local tcolor = cc.c3b(255,255,255)
    local ranks = data['ranks']
    DZSort.sortTables(ranks, StatusCode.UN_SORT, 'scores')

    local function addCell(idx, layer)
        local cy = csize.height / 2 
        local trank = ranks[ idx ]

        UIUtil.addLabelArial(trank['name'], 32, cc.p(97,cy), cc.p(0,0.5), layer, tcolor)
        local label = UIUtil.addLabelArial(trank['scores'], 32, cc.p(390,cy), cc.p(0,0.5), layer, tcolor)
        label:setAlignment(cc.TEXT_ALIGNMENT_LEFT, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        if idx < 4 then
            local imgs = {'ui/ui_reward1.png', 'ui/ui_reward2.png', 'ui/ui_reward3.png'}
            UIUtil.addPosSprite(imgs[idx], cc.p(60,cy), layer, cc.p(0.5,0.5))
        else
            UIUtil.addLabelArial(idx, 30, cc.p(60,cy), cc.p(0.5,0.5), layer, tcolor)
        end
    end

    local tsize = cc.size(csize.width, csize.height*2)
    local tablev = UIUtil.addTableView(tsize, cc.p(30,35), cc.SCROLLVIEW_DIRECTION_VERTICAL, bg)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, csize, #ranks, addCell)

    shieldLayer(glayer)
    
    return bg
end



function GWindow.setDesk()
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('GET_WINDOW_ONE') then
        runScene:getChildByName('GET_WINDOW_ONE'):removeFromParent()
    end

    local glayer = getWindowBg(display.width, display.height)
    glayer:setName('GET_WINDOW_ONE')
    local bcs = addCenterCSB(ResLib.GSETCOLOR_CSB, glayer, cc.p(0,0), true)
    windowMiddleAni(bcs)
    local bg = bcs:getChildByName('bg')

    local selColor = ''

    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()
        end)
    end
    local function handleSure()
        Storage.setDeskColor(selColor)
        DZAction.hideWindow(bcs, function()
            GData.initGameDeskConf()
            BroAnimation.changeDeskColor(selColor)

            glayer:removeFromParent()
        end)
    end

    bg:getChildByName('btnClose'):touchEnded(handleClose)
    bg:getChildByName('btnSure'):touchEnded(handleSure)
    local innerBg = bg:getChildByName('innerBg')
    local imgDesk = innerBg:getChildByName('imgDesk')
    local img1 = innerBg:getChildByName('Image1')
    local img2 = innerBg:getChildByName('Image2')
    local img3 = innerBg:getChildByName('Image3')

    local function clearSelect()
        img1:getChildByName('imgTag'):setTexture('game/game_scolor0.png')
        img2:getChildByName('imgTag'):setTexture('game/game_scolor0.png')
        img3:getChildByName('imgTag'):setTexture('game/game_scolor0.png')
    end
    local function selectBlue()
        selColor = StatusCode.DESK_BLUE
        clearSelect()
        imgDesk:setTexture('game/game_desk1.png')
        img1:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
    end
    local function selectGreen()
        selColor = StatusCode.DESK_GREEN
        clearSelect()
        imgDesk:setTexture('game/game_desk2.png')
        img2:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
    end
    local function selectRed()
        selColor = StatusCode.DESK_RED
        clearSelect()
        imgDesk:setTexture('game/game_desk3.png')
        img3:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
    end
    
    
    img1:getChildByName('imgBtn1'):touchEnded(selectBlue)
    img2:getChildByName('imgBtn2'):touchEnded(selectGreen)
    img3:getChildByName('imgBtn3'):touchEnded(selectRed)


    local ttfs = {bg:getChildByName('ttfTitle')}
    GUI.setStudioFontBold(ttfs)

    shieldLayer(glayer)

    clearSelect()
    local color = Storage.getDeskColor()
    if color == StatusCode.DESK_GREEN then
        img2:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
        imgDesk:setTexture('game/game_desk2.png')
    elseif color == StatusCode.DESK_RED then
        img3:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
        imgDesk:setTexture('game/game_desk3.png')
    elseif color == StatusCode.DESK_BLUE then
        img1:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
        imgDesk:setTexture('game/game_desk1.png')
    else
        img1:getChildByName('imgTag'):setTexture('game/game_scolor1.png')
        imgDesk:setTexture('game/game_desk1.png')
    end
    
    return bg
end

return GWindow