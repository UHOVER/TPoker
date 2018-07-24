local UIUtil = {}

-- function(tag, sender)
function UIUtil.addMenuBtn(img1, img2, funcBack, pos, parent)
	local spriteNormal = cc.Sprite:create(img1)
    local spriteSelected = cc.Sprite:create(img2)
    local spriteDisabled = cc.Sprite:create(img2)
    local item = cc.MenuItemSprite:create(spriteNormal, spriteSelected, spriteDisabled)
    item:setPosition(pos)
    item:registerScriptTapHandler(funcBack)
    local menu = cc.Menu:create()
    menu:addChild(item)
    menu:setPosition(0,0)
    parent:addChild(menu)

    return item
end

-- (tag, sender)
function UIUtil.addMenuFont(tab, btnText, pos, funcBack, parent)
    if not tab then
        tab = {}
        tab['font'] = 'Arial'
        tab['size'] = 30
    end
    cc.MenuItemFont:setFontName(tab['font'])
    cc.MenuItemFont:setFontSize(tab['size'])
    local item = cc.MenuItemFont:create(btnText)
    item:setPosition(pos)
    item:registerScriptTapHandler(funcBack)

    local menu = cc.Menu:create()
    menu:setPosition(0, 0)
    menu:addChild(item)
    parent:addChild(menu)
    return item
end

function UIUtil.controlBtn(img1, img2, img3, ttfcfg, pos, psize, back, parent)
    local img91 = ccui.Scale9Sprite:create(img1)
    local img92 = ccui.Scale9Sprite:create(img2)
    local img93 = ccui.Scale9Sprite:create(img3)
    if ttfcfg == nil then
        ttfcfg = cc.Label:createWithSystemFont("", "Marker Felt", 25)
    end

    local function controlBack(obj, event)
        back(obj, event)
    end
    
    local ctlbtn = cc.ControlButton:create(ttfcfg, img91)
    ctlbtn:setZoomOnTouchDown(false)
    ctlbtn:setBackgroundSpriteForState(img92, cc.CONTROL_STATE_HIGH_LIGHTED)
    ctlbtn:setBackgroundSpriteForState(img93, cc.CONTROL_STATE_DISABLED)
    ctlbtn:setPosition(pos)
    ctlbtn:setAnchorPoint(0.5,0.5)
    ctlbtn:setPreferredSize(psize)
    ctlbtn:registerControlEventHandler(controlBack,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
    parent:addChild(ctlbtn)

    return ctlbtn
end

function UIUtil.setControlBtnLabel(ctlbtn, colors, fsize, text)
    local labels = {}
    local normal = ctlbtn:getTitleLabelForState(cc.CONTROL_STATE_NORMAL)
    normal:setSystemFontSize(fsize)
    normal:setString(text)
    -- normal:setColor(colors[1])
    ctlbtn:setTitleColorForState(colors[1], cc.CONTROL_STATE_NORMAL)

    local lighted = ctlbtn:getTitleLabelForState(cc.CONTROL_STATE_HIGH_LIGHTED)
    lighted:setSystemFontSize(fsize)
    lighted:setString(text)
    -- lighted:setColor(colors[2])
    ctlbtn:setTitleColorForState(colors[2], cc.CONTROL_STATE_HIGH_LIGHTED)

    local disable = ctlbtn:getTitleLabelForState(cc.CONTROL_STATE_DISABLED)
    disable:setSystemFontSize(fsize)
    disable:setString(text)
    -- disable:setColor(colors[3])
    ctlbtn:setTitleColorForState(colors[3], cc.CONTROL_STATE_DISABLED)

    table.insert(labels, normal)
    table.insert(labels, lighted)
    table.insert(labels, disable)
    return labels
end

function UIUtil.addImageBtn( params )
    local btn = ccui.Button:create()
    btn:setAnchorPoint(params.ah or cc.p(0.5, 0.5))
    if params.pos then
        btn:setPosition(params.pos)
    end
    if params.parent then
        params.parent:addChild(btn)
    end
    
    btn:setPressedActionEnabled(false)
    if params.text then
        btn:setTitleText(params.text or '')
        btn:setTitleFontSize(30)
        btn:setTitleFontName("Arial")
    end
    if params.touch == nil then
        btn:setTouchEnabled(true)
    else
        btn:setTouchEnabled(params.touch)
    end
    if params.swalTouch then
        btn:setSwallowTouches(params.swalTouch)
    else
        btn:setSwallowTouches(false)
    end
    if params.scale9 then
        btn:setScale9Enabled(params.scale9)
        btn:setContentSize(params.size or btn:getContentSize())
    end
    if params.norImg then
        btn:loadTextureNormal(params.norImg)
    end
    if params.selImg then
        btn:loadTexturePressed(params.selImg)
    end
    if params.disImg then
        btn:loadTextureDisabled(params.disImg)
    end
    if params.listener then
        btn:addClickEventListener(params.listener)
    end
    
    return btn
end

function UIUtil.addEditBox(img, size, pos, holderText, parent)
    if not img then img = ResLib.COM_OPACITY0 end

    -- local back = ccui.Scale9Sprite:create(res)
    local edit = cc.EditBox:create(size, img)
    edit:setPosition(pos)
    edit:setPlaceHolder( holderText or "click to input text")
    edit:setPlaceholderFontSize(30)
    edit:setFontSize(30)
    edit:setFontColor(display.COLOR_WHITE)
    edit:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    edit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    parent:addChild(edit)
    return edit
end

function UIUtil.addPlatEdit(htext, pos, size, parent, editBack)
    local platEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("common/com_editbg1.png"))
    platEdit:setPosition(pos)
    platEdit:setFontName("Paint Boy")
    platEdit:setFontSize(30)
    platEdit:setPlaceholderFontSize(40)
    platEdit:setFontColor(cc.c3b(255,0,0))
    platEdit:setPlaceHolder(htext)
    platEdit:setPlaceholderFontColor(cc.c3b(255,255,255))
    platEdit:setMaxLength(8)
    platEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    parent:addChild(platEdit)

    platEdit:registerScriptEditBoxHandler( editBack )

    return platEdit
end

function UIUtil.addTextField(parent)
    local textField = ccui.TextField:create("Input a URL here", "Arial", 20)
    textField:setPlaceHolderColor(cc.c4b(255, 0, 0,  255))
    textField:setPosition(300, 500)
    textField:setMaxLength(5)
    textField:setTextAreaSize(cc.size(200, 300))
    parent:addChild(textField)
    return textField
end

function UIUtil.createTextField(hoderText, fontSize, size, pos, parent)
    local textField = ccui.TextField:create(hoderText, "Arial", fontSize)
    textField:setPlaceHolderColor(cc.c4b(165, 157, 157,  255))
    textField:setTextColor(display.COLOR_WHITE)
    textField:setAnchorPoint(cc.p(0,0))
    textField:setPosition(pos)
    textField:setMaxLengthEnabled(true)
    textField:setMaxLength(60)
    textField:ignoreContentAdaptWithSize(false) -- 一定是要设置 false
    textField:setSize(size)
    textField:setTouchEnabled(true)
    parent:addChild(textField)
    return textField
end

-- Arial、Marker Felt、Arial-BoldMT、Helvetica-Bold
function UIUtil.addLabelArial(text, fontSize, pos, anch, parent, color, ftype)
    if not color then
        color = cc.c3b(255,255,255)
    end
    if not ftype then
        ftype = 'Arial'
    end
    if not anch then
        anch = cc.p(0.5,0.5)
    end

	local label = cc.Label:createWithSystemFont(text, ftype, fontSize)
    label:setPosition(pos)
    label:setAnchorPoint(anch)
    label:setColor(color)
    if parent then
        parent:addChild(label)
    end
    return label
end

function UIUtil.addLabelBold(text, fontSize, pos, anch, parent, color)
    local ftype = 'Helvetica-Bold'
    return UIUtil.addLabelArial(text, fontSize, pos, anch, parent, color, ftype)
end


function UIUtil.addLabelImg(text, pos, anch, parent, fpath)
    local tw = 32
    local th = 56

    local labelImg = cc.LabelAtlas:_create(text, fpath, tw, th,  string.byte("0"))
    parent:addChild(labelImg)
    labelImg:setPosition(pos)
    labelImg:setAnchorPoint(anch)

    return labelImg
end


function UIUtil.addFont(text, fontSize, pos, anch, parent, color, ftype)
    if not color then
        color = cc.c3b(255,255,255)
    end
    if not anch then
        anch = cc.p(0.5,0.5)
    end
    if not ftype then
        ftype = "Arial"
    end

    local label = cc.Label:createWithSystemFont(str, ftype, fontSize)
    label:setPosition(pos)
    label:setAnchorPoint(anch)
    label:setColor(color)
    if parent then
        parent:addChild(label)
    end
    return label
end


function UIUtil.scale9Sprite(rect, img, psize, pos, parent)
    local ssprite = ccui.Scale9Sprite:create(img)
    ssprite:setPreferredSize(psize)
    ssprite:setAnchorPoint(cc.p(0.5,0.5))
    ssprite:setPosition(pos)
    ssprite:setInsetLeft(rect.x)
    ssprite:setInsetTop(rect.y)
    ssprite:setInsetRight(rect.width)
    ssprite:setInsetBottom(rect.height)
    parent:addChild(ssprite)

    return ssprite
end

-- percent:0~100
function UIUtil.scale9Slider(scale9, psize, percent, minVal)
    if percent == 0 then
        scale9:setOpacity(0)
        return
    end

    local nwidth = percent / 100 * psize.width
    if minVal > nwidth then
        nwidth = minVal
    end

    local nsize = cc.size(nwidth, psize.height)
    scale9:setPreferredSize(nsize)
end

function UIUtil.addImageView( params )
    local imageView = ccui.ImageView:create()
    imageView:setTouchEnabled( params.touch )
    imageView:setScale9Enabled( params.scale )
    imageView:setContentSize( params.size or cc.size(100,100) )
    imageView:loadTexture( params.image or ResLib.TABLEVIEW_BG )
    imageView:setPosition( params.pos or cc.p(0, 0) )
    imageView:setAnchorPoint( params.ah or cc.p(0, 0) )
    params.parent:addChild(imageView)
    return imageView
end

function UIUtil.addPosSprite(img, pos, parent, anch)
    if anch == nil then
        anch = cc.p(0.5, 0.5)
    end
    local isSuccess = true
    local sprite = cc.Sprite:create(img)
    -- assert(sprite, 'addPosSprite is nil 出错')
    if sprite then 
        sprite:setPosition(pos)
        sprite:setAnchorPoint(anch)
    else 
        sprite = cc.Sprite:create()
        isSuccess = false
    end
    if parent then
        parent:addChild(sprite)
    end
    return sprite, isSuccess
end

function UIUtil.addSprite(img, percent, parent, anch)
     local pos = StringUtils.getPercentPos(percent.x, percent.y)
    return UIUtil.addPosSprite(img, pos, parent, anch)
end

function UIUtil.addSizeSprite(img, percent, parent, anch, size)
    local tsize = size
    if not tsize then
        tsize = parent:getContentSize()
    end
    local pos = StringUtils.getPercentSize(percent.x, percent.y, tsize)
    return UIUtil.addPosSprite(img, pos, parent, anch)
end

local scaleH = display.width / G_DESIGN_RATIO
local bgScaleY = display.height / scaleH
local bgDownY = (scaleH - display.height) / 2
function UIUtil.setBgScale(imgbg, pos, parent)
    -- local bg = UIUtil.addPosSprite(imgbg, pos, parent)
    local bg = UIUtil.addImageView({image = imgbg, pos = pos, ah = cc.p(0.5, 0.5), touch = false, scale = true, size = cc.size(display.width, display.height), parent = parent})

    -- if G_DESIGN_RATIO > G_DEVICE_RATIO then
    --     bg:setScaleY(bgScaleY)
    -- elseif G_DESIGN_RATIO < G_RATION then
    --     bg:setPositionY(bg:getPositionY()-bgDownY)
    -- end
    return bg
end


--plist动画
--UIUtil.plistAni('item9_anims', cc.p(s.width * 0.5, s.height * 0.5), scene, 0.5, 'item9_', 14, true)
function UIUtil.plistAni(plistName, pos, parent, interval, prefix, num, isRepeat, callBack)
    if not callBack then
        callBack = function() end
    end

    local cache = cc.SpriteFrameCache:getInstance()
    cache:addSpriteFrames(plistName..".plist", plistName..".png")

    local sprite = cc.Sprite:createWithSpriteFrameName(prefix.."1.png")
    sprite:setPosition(pos)
    parent:addChild(sprite)

    local animFrames = {}
    for i = 1,num do
        local imgPng = string.format(prefix.."%d", i)..'.png'
        local frame = cache:getSpriteFrame(imgPng)
        animFrames[ i ] = frame
    end
    local animation = cc.Animation:createWithSpriteFrames(animFrames, interval)
    local ani = cc.Animate:create(animation)
    if isRepeat then
        ani = cc.RepeatForever:create(ani)
    else
        local callfunc = cc.CallFunc:create(callBack)
        ani = cc.Sequence:create(ani, callfunc)
    end

    sprite:runAction(ani)
    return sprite
end

function UIUtil.addScrollView( params )
    local scrollView = ccui.ScrollView:create()
    scrollView:setTouchEnabled(true)
    scrollView:setScrollBarEnabled(false)

    if params.showSize then
        scrollView:setContentSize(params.showSize)   -- 显示框大小
    end
    if params.innerSize then
         scrollView:setInnerContainerSize(params.innerSize)    -- 滚动区域
    end
    if params.dir then
        scrollView:setDirection(params.dir)       -- 设置滚动方向
    end
    if params.colorType then
        scrollView:setBackGroundColorType(params.colorType)
    end
    if params.color then
        scrollView:setBackGroundColor(params.color)
    end
    if params.pos then
        scrollView:setPosition(params.pos)
    end
    if params.bounce then
        scrollView:setBounceEnabled(params.bounce)   -- 设置反弹
    end
    if params.parent then
        params.parent:addChild(scrollView)
    end
    return scrollView
end

function UIUtil.addTableView(size, pos, dir, parent)
    local tableView = cc.TableView:create(size)
    tableView:initWithViewSize(size)
    tableView:setDirection(dir)
    tableView:setPosition(pos)
    tableView:setDelegate()
    parent:addChild(tableView)
    return tableView
end


function UIUtil.addPageView(size, pos, dir, parent)
    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setContentSize(size)
    pageView:setPosition(pos)
    pageView:setDirection(dir)
    parent:addChild(pageView)
    return pageView
end

-- shape pos parent
-- btn sender
function UIUtil.addCircleHead( params )
    if params.shape == nil then
        params.shape = ResLib.GAME_NULL
    end

    local headClipNode = cc.ClippingNode:create()
    params.parent:addChild(headClipNode)
    headClipNode:setPosition(params.pos)

    local stencil = cc.Sprite:create(params.shape)
    headClipNode:addChild(stencil)
    headClipNode:setStencil(stencil)
    stencil:setOpacity(0)

    local head_btn = UIUtil.addImageBtn({norImg = params.nor, selImg = params.sel, touch = true, parent = headClipNode, listener = params.listener })
    headClipNode:setAlphaThreshold(0.1)

    if not params.scale then
        stencil:setScale(0.5)
        head_btn:setScale(0.5)
    else
        stencil:setScale(params.scale)
        head_btn:setScale(params.scale)
    end

    local mask_icon = nil
    if params.mask then
        if params.mask == "" then
            return stencil, head_btn
        else
            mask_icon = params.mask
        end
    else
        mask_icon = ResLib.MASK_RING_GREY
    end
    -- local circleMask = UIUtil.addPosSprite(mask_icon, cc.p(head_btn:getContentSize().width/2, head_btn:getContentSize().height/2), head_btn, cc.p(0.5, 0.5))
    local circleMask = UIUtil.addPosSprite(mask_icon, params.pos, params.parent, cc.p(0.5, 0.5))

    if not params.scale then
        circleMask:setScale(0.5)
    else
        circleMask:setScale(params.scale)
    end

    return stencil, head_btn, circleMask
end

function UIUtil.createCircle(img, pos, parent, shapePngName, scale, mask)
    if shapePngName == nil then
        shapePngName = ResLib.GAME_NULL
        -- shapePngName = ResLib.CLUB_HEAD_STENCIL_200
    end
    if not img then
        img = ResLib.USER_HEAD
    end

    local headClipNode = cc.ClippingNode:create()
    parent:addChild(headClipNode)
    headClipNode:setPosition(pos)
    
    local stencil = cc.Sprite:create(shapePngName)

    headClipNode:addChild(stencil)
    headClipNode:setStencil(stencil)
    stencil:setOpacity(0)

    -- local sprite = cc.Sprite:create(img)
    local sprite = cc.ShaderSprite:create(img)
    if not sprite then
        -- sprite = cc.Sprite:create(ResLib.USER_HEAD)
        sprite = cc.ShaderSprite:create(ResLib.USER_HEAD)
    end
    headClipNode:addChild(sprite)
    headClipNode:setAlphaThreshold(0.1)

    local mask_icon = nil
    if not mask then
        mask_icon = ResLib.MASK_RING_GREY
    else
        mask_icon = mask
    end

    local circleMask = UIUtil.addPosSprite(mask_icon, cc.p(sprite:getContentSize().width/2, sprite:getContentSize().height/2), sprite, cc.p(0.5, 0.5))
    if not scale then
        headClipNode:setScale(0.5)
    else
        headClipNode:setScale(scale)
    end

    return stencil,sprite
end

function UIUtil.progressReverse(img, pos, parent)
    local progress = cc.ProgressTimer:create(cc.Sprite:create(img))
    progress:setPercentage(0)
    progress:setReverseDirection(true)
    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    progress:setPosition(pos)
    parent:addChild(progress)
    return progress
end

function UIUtil.shieldLayer(cLayer, callBack)
    local function onTouchBegan(touch, event)
        return true                                                            
    end  
    local function onTouchMoved(touch, event)  end
    local function onTouchEnded(touch, event)  
        if callBack ~= nil then
            callBack()
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()  
    listener:setSwallowTouches(true)                                            
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)  
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)  
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = cLayer:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, cLayer) 
end

--:getValue()
function UIUtil.addSwitch( params )
    local dirCom = "common/"
    local tswitch = cc.ControlSwitch:create(
        cc.Sprite:create(dirCom.."switch-mask.png"),
        cc.Sprite:create(dirCom.."switch-on.png"),
        cc.Sprite:create(dirCom.."switch-off.png"),
        cc.Sprite:create(dirCom.."switch-thumb.png"),
        cc.Label:createWithSystemFont("", "Arial-BoldMT", 16),
        cc.Label:createWithSystemFont("", "Arial-BoldMT", 16)
        )
    tswitch:setPosition(params.pos)
    tswitch:registerControlEventHandler(params.listener, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    params.parent:addChild(tswitch)

    return tswitch
end

-- togMenu
-- imgTab1, imgTab2, pos, callBack, parent
-- getSelectedIndex()
function UIUtil.addTogMenu( params )
    
    local imgTab1 = {}
    local imgTab2 = {}
    if not params.imgTab1 then
        for i=1,3 do
            imgTab1[i] = ResLib.COM_SWITCH4
        end
    else
        imgTab1 = params.imgTab1
    end

    if not params.imgTab2 then
        for i=1,3 do
            imgTab2[i] = ResLib.COM_SWITCH3
        end
    else
        imgTab2 = params.imgTab2
    end

    local sprite1Nor = cc.Sprite:create(imgTab1[1])
    local sprite1Sel = cc.Sprite:create(imgTab1[2])
    local sprite1Dis = cc.Sprite:create(imgTab1[3])

    local sprite2Nor = cc.Sprite:create(imgTab2[1])
    local sprite2Sel = cc.Sprite:create(imgTab2[2])
    local sprite2Dis = cc.Sprite:create(imgTab2[3])
    local Menu1 = cc.MenuItemSprite:create(sprite1Nor, sprite1Sel, sprite1Dis)
    local Menu2 = cc.MenuItemSprite:create(sprite2Nor, sprite2Sel, sprite2Dis)

    local item = cc.MenuItemToggle:create(Menu1)
    item:addSubItem(Menu2)
    item:registerScriptTapHandler(params.listener)
    local menu = cc.Menu:create()
    menu:addChild(item)
    menu:setPosition(params.pos)
    params.parent:addChild(menu)
    return item
end

function UIUtil.addTogMenuFont( params )
    local label1 = params.label1 or cc.Label:createWithSystemFont("off", "Arial", 25)
    local label2 = params.label2 or cc.Label:createWithSystemFont("on", "Arial", 25)
    local ah = params.ah or cc.p(0.5, 0.5)
    local pos = params.pos or cc.p(0,0)
    local callBack = params.callBack or assert(params.callBack, "toggle callBck can't be a null value")
    local parent = params.parent or assert(params.parent, "toggle parent can't be a null value")

    local switchItem1 = cc.MenuItemLabel:create(label1)
    local switchItem2 = cc.MenuItemLabel:create(label2)

    local item = cc.MenuItemToggle:create(switchItem1)
    item:addSubItem(switchItem2)
    item:registerScriptTapHandler(callBack)

    local menu = cc.Menu:create()
    menu:addChild(item)
    menu:setAnchorPoint(ah)
    menu:setPosition(pos)
    parent:addChild(menu)

    return item
end

function UIUtil.addCheckBox( params )

    local check_bg = params.checkBg or "common/s_xzBtn.png"
    local check_btn = params.checkBtn or "common/s_xzsBtn.png"
    
    local checkBox = ccui.CheckBox:create()
    checkBox:loadTextures(check_bg, check_bg, check_btn, check_bg, check_btn)
    checkBox:setAnchorPoint(cc.p(params.ah or cc.p(0.5, 0.5)))
    checkBox:setPosition(params.pos)
    params.parent:addChild(checkBox)
    checkBox:addEventListener( params.checkboxFunc )

    if params.touchSize then 
        checkBox:getRendererBackground():setContentSize(params.touchSize)
        checkBox:getRendererBackgroundSelected():setContentSize(params.touchSize)
        checkBox:getRendererFrontCross():setContentSize(params.touchSize)
        checkBox:getRendererBackgroundDisabled():setContentSize(params.touchSize)
        checkBox:getRendererFrontCrossDisabled():setContentSize(params.touchSize)
    end
    return checkBox
end

--:isOn()getValue
function UIUtil.addSlider(imgs, pos, parent, changeBack, minNum, maxNum)
    local tslider = cc.ControlSlider:create(imgs[1], imgs[2], imgs[3])
    tslider:setAnchorPoint(cc.p(0, 0))
    tslider:setMinimumValue(minNum) 
    tslider:setMaximumValue(maxNum) 
    tslider:setPosition(pos)
    if changeBack then
        tslider:registerControlEventHandler(changeBack, cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
    end
    parent:addChild(tslider)

    return tslider
end


function UIUtil.addUserHead(pos, curl, parent, noBg)
    if not noBg then
        UIUtil.addPosSprite(ResLib.GAME_NULL, pos, parent, nil)
    end

    local stencil = nil
    local sprite = nil

    local function addHead(cname)
        if stencil then
            stencil:removeFromParent()
            stencil = nil
        end
        if sprite then
            sprite:removeFromParent()
            sprite = nil
        end

        stencil, sprite = UIUtil.createCircle(cname, pos, parent, ResLib.CLUB_HEAD_STENCIL_200)
        stencil:setScale(0.8)
        sprite:setScale(0.8)
    end

    local isHaveParent = true
    --net head
    -- curl = 'http://101.201.48.107:9988/storage/uploads/0.760616001471701214213722.jpg'
    local imgName = CppPlat.downHead(curl, function(cpath)
        -- local sx1 = stencil:getScale()
        -- local sx2 = sprite:getScale()

        DZAction.delateTime(nil, 0.1, function()
            if not isHaveParent then return end
            if cpath then
                addHead(cpath)

                -- stencil:setScale(sx1)
                -- sprite:setScale(sx2)
                stencil:setScale(0.8)
                sprite:setScale(0.8)
            end
        end)
    end)

    local function onEvent(event)
        if event == "enter" then
        elseif event == "exit" then
            isHaveParent = false
        end
    end
    local tnode = cc.Node:create()
    tnode:registerScriptHandler(onEvent)
    parent:addChild(tnode)


    addHead(imgName)

    return stencil,sprite
end

function UIUtil.addShaderHead(pos, curl, parent, downBack)
    local thead = nil

    local function clipCircle(img)
        local scal = 1
        if thead then
            scal = thead:getScale()
            thead:removeFromParent()
            thead = nil
        end

        local circle = cc.ShaderSprite:create(img)
        if not circle then
            circle = cc.ShaderSprite:create(ResLib.USER_HEAD)
        end
        circle:setPosition(pos)
        parent:addChild(circle)
        circle:setScale(scal)
        
        local effect = cc.ShaderEffectClip:create()
        effect:setClipCenter(100,100)
        effect:setClipRadius(99)
        circle:setEffect(effect)

        thead = circle
        downBack(thead)
    end

    

    -- curl = '0.760616001471701214213722.jpg'
    local imgName = CppPlat.downHead(curl, function(cpath)
        DZAction.delateTime(nil, 0.1, function()
            clipCircle(cpath)
            end)
    end)

    if imgName == ResLib.USER_HEAD then
        local circle = cc.Sprite:create(ResLib.USER_HEAD)
        circle:setPosition(pos)
        parent:addChild(circle)

        thead = circle
    else
        clipCircle(imgName)
    end

    local function onEvent(event)
        if event == "exit" then
            thead = nil
        end
    end
    local tnode = cc.Node:create()
    tnode:registerScriptHandler(onEvent)
    thead:addChild(tnode)


    return thead
end


-- YDWX_DZ_ZHANGMENG_BUG _20160630_001【UE Integrity】BUG
-- @@@ addTopBar
-- backFunc     返回函数回调
-- title        标题
-- menuFont     右侧按钮菜单
-- menuFunc     右侧按钮回调
function UIUtil.addTopBar( params )
    if type(params) ~= "table" then
        return
    end

    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 30
    local topBar = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch = true, scale = true, size = cc.size(display.width, 129), pos = cc.p(0,display.height-130), parent = params.parent})
    local width = topBar:getContentSize().width
    local height = topBar:getContentSize().height

    local leftMenuNode, titleNode, menuNode, rightBtnNode = nil, nil, nil, nil
    -- back
    if params.backFunc then
        local backBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(100, 80), ah = cc.p(0,0.5), pos = cc.p(0, height/2-20), touch = true, swalTouch = false, listener = params.backFunc, parent = topBar})
        UIUtil.addPosSprite(ResLib.BTN_BACK, cc.p(20, backBtn:getContentSize().height/2), backBtn, cc.p(0, 0.5))
    end

    -- leftMenu
    if params.leftMenu and params.leftMenuFunc then
        local label = cc.Label:createWithSystemFont(params.leftMenu, "Marker Felt", 34):setColor(ResLib.COLOR_YELLOW1)
        UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, label, cc.p(5, height/2-22), cc.size(label:getContentSize().width+40,80), params.leftMenuFunc, topBar):setAnchorPoint(cc.p(0,0.5))
    end
    
    -- title
    if params.title then
        print(params.title)
        local imgDic = {["俱乐部"] = "main/club_title.png",["牌局"] = "main/match_title.png", ["消息"] = "main/msg_title.png"}
        local resPath = imgDic[params.title]
        if resPath then 
            UIUtil.addPosSprite(resPath, cc.p(width/2, 22),topBar, cc.p(0.5,0))
        else 
            local label = UIUtil.addLabelArial(params.title, 36, cc.p(width/2, 22), cc.p(0.5, 0), topBar):setColor(ResLib.COLOR_YELLOW1)
        end
    end

    -- menu
    if params.menuFont and params.menuFunc then
        local label = cc.Label:createWithSystemFont(params.menuFont, "Marker Felt", 34):setColor(ResLib.COLOR_YELLOW1)
        UIUtil.controlBtn(ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, ResLib.COM_OPACITY0, label, cc.p(width-5, height/2-22), cc.size(label:getContentSize().width+40,80), params.menuFunc, topBar):setAnchorPoint(cc.p(1,0.5))
    end

    -- btn
    if params.rightBtnFunc then
        local addBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(100, 80), ah = cc.p(1,0.5), pos = cc.p(width-5, height/2-22), touch = true, swalTouch = false, listener = params.rightBtnFunc, parent = topBar})
        UIUtil.addPosSprite(params.rightSpName or "club/club_btn_add.png", cc.p(addBtn:getContentSize().width/2, addBtn:getContentSize().height/2), addBtn, cc.p(0.5, 0.5))
    end
    return topBar
end
-- YDWX_DZ_ZHANGMENG_BUG _20160630_001【UE Integrity】BUG

function UIUtil.addTouchMoved( move_node, touch_node, touch_btn )

    local startPos = nil
    local isTouch = false

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( touch, event )
        -- print("began")
        local target = event:getCurrentTarget()
        startPos = target:convertToNodeSpace(touch:getStartLocation())
        -- dump(startPos)
        local rect = touch_node:getBoundingBox()

        if cc.rectContainsPoint(rect, startPos) then
            if isTouch then
                
                move_node:setPositionX(0)
                isTouch = false

                touch_btn:setVisible(false)
                return false
            else
                return true
            end
        else
            return false
        end
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    listener:registerScriptHandler(function ( touch, event )
        -- print("moved")
        local pos = touch:getLocation()
        -- dump(pos)
        local distance = startPos.x - pos.x
        -- print("distance: " .. distance)

        if distance > 30 then
            print("left")
            touch_btn:setVisible(true)
            move_node:setPositionX(-160)
            isTouch = true
        end
    end, cc.Handler.EVENT_TOUCH_MOVED)

    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, touch_node)
end

function UIUtil.clearChatMsg( params )

    local layer = cc.LayerColor:create(cc.c4b(10, 10, 10,100))
    params.parent:addChild(layer)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( touch, event )
        listener:setSwallowTouches(true)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local bgSp = UIUtil.addImageView({image = ResLib.COM_OPACITY0, scale = true, size = cc.size(display.width, 210), ah = cc.p(0,1), pos = cc.p(0, 0), parent = layer})

    local label2 = cc.Label:createWithSystemFont("清空聊天记录", "Marker Felt", 30)
    label2:setColor(display.COLOR_RED)
    local PhotoBtn2 = UIUtil.controlBtn(ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, label2, cc.p(display.width/2, 160), cc.size(700,100), params.sureFunc, bgSp)
    
    local function callFunc(  )
        layer:removeFromParent()
    end
    local label3 = cc.Label:createWithSystemFont("取消", "Marker Felt", 30)
    label3:setColor(display.COLOR_BLUE)
    local PhotoBtn3 = UIUtil.controlBtn(ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, label3, cc.p(display.width/2, 50), cc.size(700,100), callFunc, bgSp)

    local move = cc.MoveTo:create(0.2, cc.p(0, 210))
    bgSp:runAction(move)
    
    return layer
end

function UIUtil.deleteList( params )
    local layer = cc.LayerColor:create(cc.c4b(10, 10, 10,100))
    params.parent:addChild(layer)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function ( touch, event )
        listener:setSwallowTouches(true)
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

    local bgSp = UIUtil.addImageView({image = ResLib.COM_OPACITY0, scale = true, size = cc.size(display.width, 281), ah = cc.p(0,1), pos = cc.p(0, 0), parent = layer})

    local bg = UIUtil.addImageView({image=ResLib.BTN_PHOTO_TOP, touch=false, scale=true, size=cc.size(700, 80), pos = cc.p(display.cx, 241), ah = cc.p(0.5,0.5), parent=bgSp})
    local label1 = cc.Label:createWithSystemFont(params.content, "Arial", 30):addTo(bg)
    label1:setPosition(cc.p(350, 40))
    label1:setColor(display.COLOR_BLACK)

    local label2 = cc.Label:createWithSystemFont("确认删除", "Arial", 30)
    label2:setColor(display.COLOR_RED)
    local btn1 = UIUtil.controlBtn(ResLib.BTN_PHOTO_MIDDLE, ResLib.BTN_PHOTO_MIDDLE, ResLib.BTN_PHOTO_MIDDLE, label2, cc.p(display.cx, 151), cc.size(700,100), params.sureFunc, bgSp)
    
    local function callFunc(  )
        layer:removeFromParent()
    end
    local label3 = cc.Label:createWithSystemFont("取消", "Arial", 30)
    label3:setColor(display.COLOR_BLUE)
    local btn2 = UIUtil.controlBtn(ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, label3, cc.p(display.cx, 50), cc.size(700,100), callFunc, bgSp)

    local move = cc.MoveTo:create(0.2, cc.p(0, 281))
    bgSp:runAction(move)
    
    return layer
end

--[[
    strType
        1   club
        2   origin_club
        3   union
        4   circle
        5   team
        6   club white
--]]
function UIUtil.addNameByType( params )
    -- 名称
    local nameSp = UIUtil.addLabelArial(params.nameStr, params.fontSize, params.pos, cc.p(0, 0.5), params.parent)

    -- 后缀
    local iconSp = UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL, cc.p(nameSp:getPositionX()+nameSp:getContentSize().width+10, nameSp:getPositionY()), params.parent, cc.p(0, 0.5))

    UIUtil.updateNameByType( params.nameType, nameSp, iconSp )
    return nameSp, iconSp
end

function UIUtil.updateNameByType( nameType, nameSp, iconSp )

    local name_type = nameType or 0
    local color = nil
    local icon_small = nil

    if name_type == 1 then
        color = ResLib.COLOR_BLUE
        icon_small = ResLib.CLUB_HEAD_GENERAL_SMALL
    elseif name_type == 2 then
        -- color = ResLib.COLOR_YELLOW
        color = ResLib.COLOR_BLUE
        icon_small = ResLib.CLUB_HEAD_ORIGIN_SMALL
    elseif name_type == 3 then
        color = ResLib.COLOR_ORANGE
        icon_small = ResLib.UNION_HEAD_SMALL
    elseif name_type == 4 then
        color = ResLib.COLOR_GREEN
        icon_small = ResLib.CIRCLE_HEAD_SMALL
    elseif name_type == 5 then
        color = cc.c3b(9, 183, 66)
        icon_small = "club/team_flag.png"
    elseif name_type == 6 then
        color = display.COLOR_WHITE
        icon_small = ResLib.CLUB_HEAD_GENERAL_SMALL
    else
        return
    end
    nameSp:setColor(color)
    iconSp:setTexture(icon_small)
    iconSp:setPositionX(nameSp:getPositionX()+nameSp:getContentSize().width+10)
end

function UIUtil.cloneNode(node)
    local tx,ty = node:getPosition()
    local anc = node:getAnchorPoint()
    local newNode = cc.Sprite:createWithTexture(node:getTexture())
    node:getParent():addChild(newNode)

    newNode:setPosition(tx, ty)
    newNode:setAnchorPoint(anc)
    newNode:setScale(node:getScale())

    return newNode
end

function UIUtil.falseShield(back, waitTime)
    if not back then
        back = function() end
    end
    if not waitTime then
        waitTime = 1
    end

    local WaitServer = require('ui.WaitServer')
    WaitServer.showForeverWait()
    DZAction.delateTime(nil, waitTime, function()
        WaitServer.removeForeverWait()
        back()
    end)
end

-- sender, eventType：ccui.TouchEventType.ended
--began、moved、ended、canceled
function UIUtil.addUIButton(imgs, pos, parent, funcBack)
    local btn = ccui.Button:create()
    btn:loadTextures(imgs[1], imgs[2], imgs[3])
    btn:setTitleText("")
    btn:setPosition(pos)
    btn:setTouchEnabled(true)
    btn:addTouchEventListener(funcBack)
    parent:addChild(btn)
    return btn
end

--添加文字button
function UIUtil.addUITextButton(params)
    local btn = ccui.Button:create()
    if params.imgs then 
        btn:loadTextures(params.imgs[1], params.imgs[2], params.imgs[3])
    end
    btn:setScale9Enabled(params.scale or false)
    btn:setContentSize(params.size or cc.size(100,20))
    btn:setAnchorPoint(params.ah or cc.p(0.5,0.5))
    btn:ignoreContentAdaptWithSize(params.igAsize or true)
    btn:setTouchEnabled(true)
    btn:setPosition(params.pos or cc.p(0,0))
    btn:setTitleText(params.text or "")
    btn:setTitleColor(params.tcolor or cc.c3b(0,0,0))
    btn:addTouchEventListener(params.funcBack or function(sender, evt) end)
    btn:setTitleFontSize(params.fsize)
    params.parent:addChild(btn)
    return btn
end


function UIUtil.clipScreenShare(size, nodes)
    local runScene = cc.Director:getInstance():getRunningScene()
    local target = cc.RenderTexture:create(size.width, size.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    target:setAnchorPoint(0,0)
    target:setPosition(0,0)
    runScene:addChild(target)

    target:begin()
    for i=1,#nodes do
        nodes[ i ]:visit()
    end
    target:endToLua()

    local sharePng = DZConfig.getShareImgName()
    target:saveToFile(sharePng, cc.IMAGE_FORMAT_PNG)
    target:removeFromParent()

    local imgPath = cc.FileUtils:getInstance():getWritablePath()..sharePng
    local tab = {}
    tab['imgPath'] = imgPath
    DZWindow.shareDialog(DZWindow.SHARE_IMG, tab)
end

-- 检测editBox输入字符
function UIUtil.checkEditText( eventType, sender, params, isCards )
    if eventType == "began" then
        
    elseif eventType == "changed" then
        -- print(sender:getText())
        -- print(string.len(sender:getText()))
        -- if string.len(sender:getText()) > params.modLen then
        --     sender:closeKeyboard()
        --     ViewCtrol.showTip({content = params.content})
        -- end
    elseif eventType == "return" then
        local str = StringUtils.trim(sender:getText())
        local lenStr = nil
        if string.len(str) > params.modLen then
            ViewCtrol.showTip({content = params.content})
            lenStr = StringUtils.checkStrLength( str, params.modLen )
        else
            lenStr = str
        end
        sender:setText(lenStr)
        if isCards then
            params.funcBack(lenStr)
        else
            if lenStr ~= "" then
                params.funcBack(lenStr)
            end
        end 
    end
end

--添加一个预加载动画
function UIUtil.addUICirclePreLoad(parent, pt, contentSize, radius, dotColor, isNoText, textColor, textSize)
      local params = {}
       params.color = cc.c4f(1.0, 1.0, 1.0, 0)
       params.size  = contentSize or cc.size(60, 90)
       params.dotColor = dotColor or cc.c4f(1.0, 1.0, 1.0, 1.0)
       params.r = radius or 30
       params.isTextVisible = isNoText or false
       params.textColor = textColor or cc.c3b(0,0,0)
       params.textSize = textSize or 30
       local CircleIndicator = require("ui.CircleIndicator")
       local indicator = CircleIndicator.new(params)
       indicator:setPosition(pt)
       parent:addChild(indicator)
       return indicator
end
-- 绘制圆角矩形
function UIUtil.drawNodeRoundRect(drawNode, rect, borderWidth, radius, color, fillColor)
  if not drawNode then  drawNode = cc.DrawNode:create() end
    --segments 
    -- segments表示圆角的精细度，值越大越精细
  local segments    = 100
  local origin      = cc.p(rect.x, rect.y)
  local destination = cc.p(rect.x + rect.width, rect.y - rect.height)
  local points      = {}

  -- 算出1/4圆
  local coef     = math.pi / 2 / segments
  local vertices = {}

  for i=0, segments do
    local rads = (segments - i) * coef
    local x    = radius * math.sin(rads)
    local y    = radius * math.cos(rads)
    table.insert(vertices, cc.p(x, y))
  end

  local tagCenter      = cc.p(0, 0)
  local minX           = math.min(origin.x, destination.x)
  local maxX           = math.max(origin.x, destination.x)
  local minY           = math.min(origin.y, destination.y)
  local maxY           = math.max(origin.y, destination.y)
  local dwPolygonPtMax = (segments + 1) * 4
  local pPolygonPtArr  = {}

  -- 左上角
  tagCenter.x = minX + radius;
  tagCenter.y = maxY - radius;

  for i=0, segments do
    local x = tagCenter.x - vertices[i + 1].x
    local y = tagCenter.y + vertices[i + 1].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  -- 右上角
  tagCenter.x = maxX - radius;
  tagCenter.y = maxY - radius;

  for i=0, segments do
    local x = tagCenter.x + vertices[#vertices - i].x
    local y = tagCenter.y + vertices[#vertices - i].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  -- 右下角
  tagCenter.x = maxX - radius;
  tagCenter.y = minY + radius;

  for i=0, segments do
    local x = tagCenter.x + vertices[i + 1].x
    local y = tagCenter.y - vertices[i + 1].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  -- 左下角
  tagCenter.x = minX + radius;
  tagCenter.y = minY + radius;

  for i=0, segments do
    local x = tagCenter.x - vertices[#vertices - i].x
    local y = tagCenter.y - vertices[#vertices - i].y

    table.insert(pPolygonPtArr, cc.p(x, y))
  end

  if fillColor == nil then
    fillColor = cc.c4f(0, 0, 0, 0)
  end

  drawNode:drawPolygon(pPolygonPtArr, #pPolygonPtArr, fillColor, borderWidth, color)
end

-- 多行label 模拟,文字数组,适用于文字并不多的情况
function UIUtil.addMutiLabel(params)
   local texts = params.texts or {"没有传入参数", "请传入参数"}
   local fontSize = params.fontSize or 24
   local fontColor = params.fontColor or cc.c3b(255,255,255) 
   local dimensions = params.dimensions or cc.rect(100, 50)
   local lineSpace = params.lineSpace or 14
   local pt = params.pt or cc.p(0,0)
   local parent = params.parent
   local anchor = params.anchor or cc.p(0,0)

   local bgLayer = cc.LayerColor:create(cc.c4b(0,255,0,0))
   bgLayer:ignoreAnchorPointForPosition(false)
   bgLayer:setAnchorPoint(anchor)
   bgLayer:setPosition(pt)
   parent:addChild(bgLayer)
   local len,x,y,h = #texts,0,lineSpace,0
   local label = nil
   for i = len, 1, -1 do
       label = UIUtil.addLabelArial(texts[i], fontSize,cc.p(x,y),cc.p(0,0),bgLayer,fontColor)
        y =  label:getPositionY() + label:getContentSize().height + lineSpace  
        h = h + label:getContentSize().height+lineSpace
   end
   bgLayer:setContentSize(cc.size(label:getContentSize().width, h+lineSpace))
end

-- CCGLProgram
function UIUtil.getGLProgram(glName)
    if not glName then 
        glName = "ShaderPositionTextureColor_noMVP"
    end
    local glCache = cc.GLProgramCache:getInstance()
    local pProgram = glCache:getGLProgram(glName)
    return pProgram
end

function UIUtil.setGLProgramStateToNode(sp, glName)
    if not sp then 
        do return end
    end
    local gProgram = UIUtil.getGLProgram(glName)
    -- print("gProgram:"..tostring(gProgram))
    -- print("sp:getGLProgram()"..tostring(sp:getGLProgram()))
    if gProgram and sp:getGLProgram() ~= gProgram then 
        -- sp:setGLProgramState(gProgram)
        -- print("执行   变灰："..tostring(glName))
        sp:setGLProgram(gProgram)
    end
end

-- 检测是否游客登录
function UIUtil.checkIsVisitor(  ) 
    ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = VISITOR_SHOW_MSG, sureFunBack = function()
        local LoginCtrol = require("login.LoginCtrol")
        LoginCtrol.changeUser()
        DZChat.breakRYConnect()
            
        NoticeCtrol.removeNoticeNode()
        local loginScene = require("login.LoginScene")
        loginScene.startScene()
    end})
end

--添加ListView
function UIUtil.addListView(params)
    local listView = ccui.ListView:create()
    listView:setDirection(params.dir or ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(params.bounce or true)
    listView:setScrollBarEnabled(params.scrollBar or false)
    listView:setContentSize(params.size or cc.size(100,100))
    listView:setPosition(params.pos or cc.p(0,0))
    if params.parent then 
        params.parent:addChild(listView)
    end
    if params.margin then 
        listView:setItemsMargin(params.margin)
    end
    if params.magnetic then 
        listView:setMagneticType(params.magnetic)
    end
    if params.gv then 
        listView:setGravity(params.gv)
    end
    if params.onscroll then 
        listView:onScroll(params.onscroll)
    end
    if params.bcolorType and params.bcolor then 
        listView:setBackGroundColorType(params.bcolorType)
        listView:setBackGroundColor(params.bcolor)
    end
    return listView
end

--添加分段层
function UIUtil.addSection(params)
    local bgColorLayer = cc.LayerColor:create(params.bcolor or cc.c3b(27,32,46))
    bgColorLayer:setContentSize(params.size or cc.size(display.width, 42))
    bgColorLayer:setPosition(params.pos or cc.p(0, 0))
    if params.parent then 
        params.parent:addChild(bgColorLayer)
    end
    local text = params.text or ""
    local tColor = params.tcolor or cc.c3b(255,255,255)
    local tPos = params.tPos or cc.p(20, bgColorLayer:getContentSize().height/2)
    local fontSize = params.fsize or 26
    local tAnchor = params.tach or cc.p(0, .5)
    local label = UIUtil.addLabelArial(text, fontSize, tPos, tAnchor, bgColorLayer, tColor)
    return bgColorLayer, label
end


return UIUtil