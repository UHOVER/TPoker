local MoveDirection = {}
MoveDirection.LEFT          = 'left'
MoveDirection.RIGHT         = 'right'
MoveDirection.UP            = 'up'
MoveDirection.DOWN          = 'down'
MoveDirection.LEFT_RIGHT    = 'LEFT_RIGHT'
MoveDirection.UP_DOWN       = 'UP_DOWN'

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


local function onTouchBegin(touch, event)
    if not isTouchImg(touch, event) then
        return false
    end

    print('onTouchBegin begin')
    local target = event:getCurrentTarget()
    if target._isBegin then
        return false
    end

    if target.beginDirection and isTouchImg(touch, event) then
        target.beginDirection(touch, event)
    end

    target._beginPos = target:convertToNodeSpace(touch:getLocation())
    
    -- target._isMove = false
    target._isBegin = true
    target._isOnce = true

    return true
end

local function onTouchMoved(touch, event)
    local target = event:getCurrentTarget()
    local mpos = target:convertToNodeSpace(touch:getLocation())
    local disx = target._beginPos.x - mpos.x
    local disy = target._beginPos.y - mpos.y
    local absx = math.abs(disx)
    local absy = math.abs(disy)

    if not target._isOnce then
        return
    end

    --移动
    local mdirection1 = ''
    local mdirection2 = ''
    if absx > 10 or absy > 10 then
        -- target._isMove = true

        --左右、上下
        if absx > absy then
            if disx > 0 then
                mdirection1 = MoveDirection.LEFT
            else
                mdirection1 = MoveDirection.RIGHT
            end
            mdirection2 = MoveDirection.LEFT_RIGHT
        else
            if disy > 0 then
                mdirection1 = MoveDirection.DOWN
            else
                mdirection1 = MoveDirection.UP
            end
            mdirection2 = MoveDirection.UP_DOWN
        end

        if target.movedDirection and isTouchImg(touch, event) then
            target.movedDirection(touch, event, mdirection1, mdirection2)
        end
        target._isOnce = false
    end
end

local function onTouchEnded(touch, event)
    local target = event:getCurrentTarget()

    if target.endDirection and isTouchImg(touch, event) then
    	target.endDirection(touch, event)
    end

    print('onTouchEnded end')

    target._isOnce = false
    target._isBegin = false
end

local function create(imgSprite)
    imgSprite._isBegin = false

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = imgSprite:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, imgSprite)
end

function MoveDirection.registerImg(imgSprite)
	create(imgSprite)
end

return MoveDirection