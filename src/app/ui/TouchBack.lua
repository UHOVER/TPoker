local TouchBack = {}

local function isTouchImg(touch, event)
    local target = event:getCurrentTarget()
    local beginpos = target:convertToNodeSpace(touch:getLocation())
    local targetWidth = target:getContentSize().width
    local targetHeight = target:getContentSize().height
    local rect = cc.rect(0, 0, targetWidth, targetHeight)
    if cc.rectContainsPoint(rect, beginpos) then 
        return true
    end

    return false
end


local isMove = false
local function onTouchBegin(touch, event)
	isMove = false

    local target = event:getCurrentTarget()
    -- target._isBegin = false
    target._beginPos = target:convertToNodeSpace(touch:getLocation())

    if target._isBegin then
        return false
    end
    
    target._isBegin = true

    if target.beginBack and isTouchImg(touch, event) then
        target.beginBack(touch, event)
    end
    return true
end

local function onTouchMoved(touch, event)
    local target = event:getCurrentTarget()
    local mpos = target:convertToNodeSpace(touch:getLocation())
    local disx = math.abs(target._beginPos.x - mpos.x)
    local disy = math.abs(target._beginPos.y - mpos.y)

    if disx > 10 or disy > 10 then
        isMove = true
    end

    if target.movedBack and isTouchImg(touch, event) then
        target.movedBack(touch, event)
    elseif target.moveOutBack then
        target.moveOutBack(touch, event)
    end
end

local function onTouchEnded(touch, event)
    local target = event:getCurrentTarget()

    if target.endedBack and isTouchImg(touch, event) then
    	target.endedBack(touch, event)
    end
    if target.notMoveBack and isTouchImg(touch, event) and isMove == false then
    	target.notMoveBack(touch, event)
    end

    if target.noEndedBack and not isTouchImg(touch, event) then
        target.noEndedBack(touch, event)
    end

    if target.anyEndBack and target._isBegin then
        target.anyEndBack(touch, event)
    end


    target._isBegin = false
end

local function onTouchCanceled(touch, event)
    local target = event:getCurrentTarget()
    if target.touchCancel then 
        target.touchCancel(touch, event)
    end
end

local function create(imgSprite)
    -- local isSwallow = imgSprite.isSwallowTouches --是否添加吞噬
    local isSwallow = imgSprite._isSwallowImg --是否添加吞噬
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCanceled,cc.Handler.EVENT_TOUCH_CANCELLED)
    if isSwallow then 
        listener:setSwallowTouches(isSwallow)
    end
    local eventDispatcher = imgSprite:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, imgSprite)
end

function TouchBack.registerImg(imgSprite)
	create(imgSprite)
end

return TouchBack