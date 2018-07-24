local DZWindow = class('DZWindow')
local PROMPT_TAG = 1

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

local function addCenterLayer(tag, opacity)
    if not opacity then
        opacity = 150
    end
    local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, opacity))
    layer:setPosition(cc.p(0,0))
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(layer, StringUtils.getMaxZOrder(runScene))
    return layer
end


function DZWindow.prompt(title, context, sureText, sureCall, cancelText, cancelCall)
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('PROMPT_WINDOW_ONE') then
        runScene:getChildByName('PROMPT_WINDOW_ONE'):removeFromParent()
    end

    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,150), display.width, display.height)
    glayer:setName('PROMPT_WINDOW_ONE')

    local bcs = addCenterCSB(ResLib.DZ_WINDOW1, glayer)
    bcs:setAnchorPoint(0.5,0.5)
    local bg = bcs:getChildByName('windowBg')
    bg:getChildByName('ttfTitleWindow'):setFontName('Helvetica-Bold')
    DZAction.showWindow(bcs, nil)

    local text1 = '确定'
    local text2 = '取消'
    if sureText then
        text1 = sureText
    end
    if cancelText then
        text2 = cancelText
    end


    local function handleClose()
        DZAction.hideWindow(bcs, function()
            glayer:removeFromParent()
        end)
    end
    local function cancelBack()
        glayer:removeFromParent()
        if cancelCall ~= nil then
            cancelCall()
        end
    end
    local function sureBack()
        glayer:removeFromParent()
        if sureCall ~= nil then
            sureCall()
        end
    end

    local btnSure = bg:getChildByName('btnSure')
    local btnCancel = bg:getChildByName('btnCancel')
    local btnClose = bg:getChildByName('btnClose')
    btnClose:touchEnded(handleClose)
    btnSure:touchEnded(sureBack)
    btnCancel:touchEnded(cancelBack)

    btnSure:setTitleText(text1)
    btnCancel:setTitleText(text2)

    bg:getChildByName('ttfTitleWindow'):setString(title)

    local imgSmall = bg:getChildByName('imgSmall')
    local color = cc.c3b(255,255,255)
    local label = UIUtil.addLabelBold(context, 40, cc.p(302.5,115), cc.p(0.5,0.5), imgSmall, color)
    label:setDimensions(500,200)
    label:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)


    --只有确定
    btnClose:setPositionX(1200)
    if cancelText == nil or cancelCall == nil then
        btnCancel:setPositionX(1200)
        btnSure:setPositionX(327.50)
    else
        btnCancel:setPositionX(471.60)
        btnSure:setPositionX(183.40)
    end

    shieldLayer(glayer)

    return bg
end


DZWindow.SHARE_IMG = 1
DZWindow.SHARE_URL = 2
DZWindow.SHARE_TEXT = 3
DZWindow.SHARE_CODE = 4
DZWindow.SHARE_MTTURL = 5
function DZWindow.shareDialog(stype, shareContent)

    dump(shareContent)
    local wlayer = addCenterLayer(PROMPT_TAG, 10)
    shieldLayer(wlayer)
    local color = cc.c3b(119, 119, 119)

    local imgTab = {pos=cc.p(display.cx, 0), ah=cc.p(0.5, 0), parent=wlayer}
    imgTab['image'] = "common/com_bg_share.png"
    imgTab['touch'] = true
    imgTab['scale'] = true
    imgTab['size'] = cc.size(750, 345)
    local shareBg = UIUtil.addImageView(imgTab)
    shareBg:setAnchorPoint(0,0)
    shareBg:setPosition(0,-345)

    -- 取消
    local function cancleFunc()
        if not wlayer then return end

        local function runOver()
            wlayer:removeFromParent()
            wlayer = nil
        end

        DZAction.easeInMove(shareBg, cc.p(0,-345), 0.22, DZAction.MOVE_TO, runOver)
    end

    
    shareBg.noEndedBack = cancleFunc
    TouchBack.registerImg(shareBg)

    local slabel = UIUtil.addLabelArial('分享到 ', 35, cc.p(display.cx, 290), cc.p(0.5, 0.5), shareBg)
    slabel:setColor(color)


    local btnPng = {"common/com_icon_chat.png", "common/com_icon_circle.png", "common/com_icon_weibo.png"}
    local btnPngSel = {"common/com_icon_chat2.png", "common/com_icon_circle2.png", "common/com_icon_weibo.png"}
    local btnTitle = {"微信好友", "微信朋友圈", "新浪微博"}
    local function shareCallback( sender )
        local tag = sender:getTag()
        if  stype == DZWindow.SHARE_IMG or stype == DZWindow.SHARE_TEXT then
            Single:paltform():shareWeiXin(tostring(tag), tostring(stype), shareContent)
        elseif stype == DZWindow.SHARE_URL then     -- url分享
            Single:paltform():shareWeiXin(tostring(tag), tostring(stype), shareContent)
        elseif stype == DZWindow.SHARE_MTTURL then  -- MTT战绩
            Single:paltform():shareWeiXinRich(tostring(tag), tostring(stype), shareContent.content, shareContent.weburl, shareContent.title, shareContent.desc)
        elseif stype == DZWindow.SHARE_CODE then
            Single:paltform():shareWeiXinCode(tostring(tag), shareContent.pokerId, shareContent.inviteCode )
        end
        cancleFunc()
    end

    local imgBtn = {touch=true, listener=shareCallback, parent=shareBg, ah=cc.p(0.5,0.5)}
    for i=1,2 do
        local tx = 200 + (i - 1) * 300
        imgBtn['norImg'] = btnPng[i]
        imgBtn['selImg'] = btnPngSel[i]
        imgBtn['pos'] = cc.p(tx, 200)
        local tbtn = UIUtil.addImageBtn(imgBtn)
        tbtn:setTag(i)

        local btnText = UIUtil.addLabelArial(btnTitle[i], 30, cc.p(tx, 120), cc.p(0.5, 0.5), shareBg)
        btnText:setColor(color)
    end

    -- line
    local line = UIUtil.addPosSprite("common/com_grey_line.png", cc.p(display.cx, 88), shareBg, cc.p(0.5, 0.5))

    
    local btnTab = {ah=cc.p(0.5,0.5), pos=cc.p(display.cx, 40), touch=true, swalTouch=false, scale9=true, size=cc.size(750, 80)}
    btnTab['norImg'] = "common/com_bg_share.png"
    btnTab['selImg'] = "common/com_bg_share.png"
    btnTab['text'] = "取消"
    btnTab['listener'] = cancleFunc
    btnTab['parent'] = shareBg
    local cancleBtn = UIUtil.addImageBtn(btnTab)
    cancleBtn:setTitleColor(color)


    DZAction.easeInMove(shareBg, cc.p(0,0), 0.22, DZAction.MOVE_TO, nil)
end


--gps提示
function DZWindow.showGPSPrompt()
    local tipTab = {}
    tipTab['content'] = DZConfig.getTextGPS()
    tipTab['listener'] = function() end
    ViewCtrol.showTip(tipTab)
end

return DZWindow