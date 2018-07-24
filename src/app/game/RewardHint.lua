--
-- Author: Taylor
-- Date: 2016-12-27 19:40:05
--
local textureCache = cc.Director:getInstance():getTextureCache()
local spFrameCache = cc.SpriteFrameCache:getInstance()
local basePt = cc.p(display.cx, display.cy)
local function turnToTable(num, tb) 
     if tb == nil then 
        tb = {}
    end
    local str = tostring(num)
    local count = #str
    for i = 1, count do 
        local charNum = string.sub(str, i, i)
        table.insert(tb, i, charNum)

    end
end

local screenFactorPt = cc.p(display.width/750, display.height/1334)
local function setAlertPosition(target, posx, posy)
    local px, py = posx or 0, posy or 0
    local pt = cc.p(px * screenFactorPt.x, py * screenFactorPt.y)
    if (target == nil) then 
        do return end
    end
    target:setPosition(pt)
end


local RewardHint = class("RewardHint", function() 
			return cc.Layer:create()
	end)

function RewardHint:ctor(number)
	self:initView(number)
end

function RewardHint:initView(amount)
    print("----RewardHint----")
	self._isSwallowImg = true
    TouchBack.registerImg(self)
    local node = cc.Node:create()
    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(cc.p(0.5, 0))
    node:setContentSize(cc.size(display.width, display.height))
    self:addChild(node)
    setAlertPosition(node, display.cx, -1334)
    self.container = node
    local board = display.newSprite(ResLib.REWARD_BOARD)
    node:addChild(board)
    setAlertPosition(board, 376, 835)
    board:setPositionX(display.cx)
    basePt = cc.p(board:getPosition())
    local closeBtn = ccui.Button:create()
    closeBtn:loadTextures(ResLib.CLOSE_NORMAL, ResLib.CLOSE_PRESS, nil)
    closeBtn:setTitleText("")
    closeBtn:setTouchEnabled(true)
    closeBtn:addTouchEventListener(function(sender, eventType) 
                  if eventType == ccui.TouchEventType.ended then 
                        -- node:removeFromParent()
                        self:removeFromParent()
                        for i = 0, 9 do 
                            spFrameCache:removeSpriteFrameByName("reward_"..i)
                        end
                        textureCache:removeTextureForKey(ResLib.REWARD_NUMBER)
                        -- funcBack()
                  end
            end)
    node:addChild(closeBtn)
    closeBtn:setPosition(cc.pAdd(basePt, cc.p(294, 190)))
  

    local title = cc.Label:createWithSystemFont("领取路径", "Helvetica", 38)
    title:setAnchorPoint(cc.p(.5, .5))
    title:setTextColor(cc.c3b(255, 235, 147))
    node:addChild(title)
    title:enableBold()
    title:setPosition(cc.pSub(basePt, cc.p(0, 603)))
    

    local textDescript = cc.Label:createWithSystemFont("“我的”-“我的奖励”查收奖品验证码", "Helvetica", 32)
    textDescript:setAnchorPoint(cc.p(.5, .5))
    textDescript:setTextColor(cc.c3b(255, 235, 147))
    node:addChild(textDescript)
    textDescript:setPosition(cc.pSub(basePt, cc.p(0, 655)))
     
    local indicator = UIUtil.addUICirclePreLoad(self.container, cc.pSub(basePt, cc.p(0, 222)), cc.size(60, 90), 30, cc.c4f(1.0,1.0,1.0,1.0), false, cc.c3b(0,0,0),30)
    indicator:setLocalZOrder(100)
    self.indicator = indicator
end

function RewardHint:setInfoImage(path)
    if not path then 
        return
    end
    dump(path, "图片居然不存在")
    local spText = display.newSprite(path)
    self.container:addChild(spText)
    spText:setPosition(cc.pSub(basePt, cc.p(0, 222)))
    -- -- setAlertPosition(spText, 376, 625)

    self.indicator:removeFromParent()
end

function RewardHint:show()

    local moveTo = cc.MoveTo:create(0.4, cc.p(display.cx, 0))
    local scaleTo = cc.ScaleTo:create(0.3, 1.5, 0.5, 1)
    local scaleBig = cc.ScaleTo:create(0.4, 1.2, 1.2, 1)
    local scaleTo2 = cc.ScaleTo:create(0.2, 1, 1, 1)
    local scaleNormal = cc.ScaleTo:create(0.1, 1, 1, 1)
    local seq = cc.Sequence:create(moveTo, scaleBig, scaleTo, scaleTo2,  scaleNormal)

    self.container:runAction(seq)
end

return RewardHint