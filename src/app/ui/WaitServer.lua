local WaitServer = {}
local _phpCount = 0
local _socCount = 0
local SOCKET_WAIT_TAG = 'SOCKET_WAIT_TAG'
local PHP_WAIT_TAG = 'PHP_WAIT_TAG'
local FOREVER_WAIT_TAG = 'FOREVER_WAIT_TAG'


local function createLayer()
    local layer = cc.LayerColor:create(cc.c4b(0,0,0,150))

    local function onTouchBegan(touch, event)
        return true
    end

--[[
    local sprite = UIUtil.addPosSprite('common/loading_card.png', display.center, layer, cc.p(0.5,0.5))
    sprite:setAnchorPoint(cc.p(0.5,0.5))
    sprite:runAction(cc.RepeatForever:create( cc.RotateBy:create(1.8, cc.Vertex3F(0,360,0),1,1) ))

    UIUtil.addPosSprite('common/loading_text.png', cc.p(display.cx,display.cy-24), layer, cc.p(0.5,0.5))
    local textbg = UIUtil.addPosSprite('common/loading_textbg.png', cc.p(display.cx,display.cy-24), layer, cc.p(0.5,0.5))
    local fadeIn = cc.FadeIn:create(1)
    local fadeOut = cc.FadeOut:create(1)
    local seq = cc.Sequence:create(fadeIn, fadeOut)
    textbg:runAction(cc.RepeatForever:create(seq))
]]
    -- local eventDispatcher = layer:getEventDispatcher()
    -- local listener = cc.EventListenerTouchOneByOne:create()
    -- listener:setSwallowTouches(true)
    -- listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    -- eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layer)


    -- local to1 = cc.ProgressTo:create(0.5, 100)
    -- local to2 = cc.ProgressTo:create(0.5, 0)
    -- local left = cc.ProgressTimer:create(cc.Sprite:create("common/processCircle.png"))
    -- left:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    -- left:setPosition(display.center)
    -- left:runAction(cc.RepeatForever:create(
    --     cc.Sequence:create(
    --     to1,
    --     cc.CallFunc:create( 
    --         function(sender)
    --             sender:setReverseDirection(true)
    --         end),
    --     to2,
    --     cc.CallFunc:create( 
    --         function(sender)
    --             sender:setReverseDirection(false)
    --         end)
    -- )))
    
    -- left:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
    -- layer:addChild(left)
    -- local sprite = cc.Sprite:create("common/processCenter.png")
    -- sprite:setPosition(display.center)
    -- layer:addChild(sprite)

    WaitServer.loadingImg(layer, display.center)

    UIUtil.shieldLayer(layer)

    return layer
end



local function getWait(waitName)
    local scene = cc.Director:getInstance():getRunningScene()
    return scene:getChildByName(waitName)
end
local function disWait(waitName)
    local scene = cc.Director:getInstance():getRunningScene()
    local wlayer = createLayer()
    wlayer:setName(waitName)
    scene:addChild(wlayer, StringUtils.getMaxZOrder(scene))
end


--php
function WaitServer.showPHPWait()
    if not getWait(PHP_WAIT_TAG) then
        _phpCount = 0
    end

    _phpCount = _phpCount + 1
    if getWait(PHP_WAIT_TAG) then
        return
    end

    disWait(PHP_WAIT_TAG)
end

function WaitServer.hidePHPWait()
    _phpCount = math.max(0, _phpCount - 1)

    local wait = getWait(PHP_WAIT_TAG)
    if _phpCount == 0 and wait then
        wait:removeFromParent()
    end
end

function WaitServer.removePHPWaitServer()
	_phpCount = 0
    WaitServer.hidePHPWait()
end


--socket
function WaitServer.showWait()
    if not getWait(SOCKET_WAIT_TAG) then
        _socCount = 0
    end

    _socCount = _socCount + 1
    if getWait(SOCKET_WAIT_TAG) then
        return
    end

    disWait(SOCKET_WAIT_TAG)
end

function WaitServer.hideWait()
    _socCount = math.max(0, _socCount - 1)

    local wait = getWait(SOCKET_WAIT_TAG)
    if _socCount == 0 and wait then
        wait:removeFromParent()
    end
end

function WaitServer.removeWaitServer()
    _socCount = 0
    WaitServer.hideWait()
end


function WaitServer.showForeverWait()
    if getWait(FOREVER_WAIT_TAG) then return end
    disWait(FOREVER_WAIT_TAG)
end
function WaitServer.removeForeverWait()
    local wait = getWait(FOREVER_WAIT_TAG)
    if wait then
        wait:removeFromParent()
    end
end


function WaitServer.loadingImg(parent, pos)
    local tnode = cc.Node:create()
    tnode:setPosition(pos)
    parent:addChild(tnode)

    local to1 = cc.ProgressTo:create(0.5, 100)
    local to2 = cc.ProgressTo:create(0.5, 0)
    local left = cc.ProgressTimer:create(cc.Sprite:create("common/processCircle.png"))
    left:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    -- left:setPosition(pos)
    left:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
        to1,
        cc.CallFunc:create( 
            function(sender)
                sender:setReverseDirection(true)
            end),
        to2,
        cc.CallFunc:create( 
            function(sender)
                sender:setReverseDirection(false)
            end)
    )))
    
    left:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
    tnode:addChild(left)
    local sprite = cc.Sprite:create("common/processCenter.png")
    -- sprite:setPosition(display.center)
    tnode:addChild(sprite)

    return tnode
end


return WaitServer