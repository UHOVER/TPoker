--
-- Author: Your Name
-- Date: 2016-09-18 16:07:12
--滑动卡牌逻辑节点
local SuperPageTable = class("SuperPageTable", function ()
    return cc.Node:create()
end)

local g_self = nil

--spPanel--编辑器中的哪个panel层，一共有三个，就是显示的卡牌
--addCellLayer--添加元素方法，负责填充panel中的内容
--setIdx--设置ID，每个添加的元素有自己的id。 
--getMyNeed--是1组建牌局 2大厅，区别是哪个界面的卡牌
function SuperPageTable:ctor(spPanel, addCellLayer, setIdx, getMyNeed)
	self.m_spPanel = spPanel--编辑器中的哪个panel层，一共有三个
	self.m_beginPosX = 0
	self.m_endPosX = 0
	self.m_canDist = 5
    self.m_tableCell = {}
    self.m_tablePos = {}
    self.m_isCanMove = true
    self.m_callBackFun = addCellLayer--添加元素方法
    self.m_setIdxCallFun = setIdx--设置ID
    self.m_tag = getMyNeed--是1组建牌局 2大厅
    self.m_maxCell = 3--默认最大元素是3个
    self.m_isZXInLeft = true--初始状态 默认在左边，左旋的时候
    self.m_isYXInLeft = false--初始状态 默认在右边，右旋的时候
    self.m_actionNode = nil--动画节点
    self.m_s1 = nil--星星1
    self.m_s2 = nil--星星2
    self.m_s3 = nil--星星3
    self.m_isCanClick = true--是否可以点击按钮
    self.m_listener = nil--监听事件
    self.m_pNum = 0--消息数量
    self:init()

end

--注册刷新事件
local function CustomCallBackUpdateMttCard(event)  
    printf("Test Custom Eventmmmmm")
    --请求刷新数字

    --发送消息
    local function response(data)
        --dump(data)
        print("hhhhh2222dsfsa00000")
        if(data == nil) then
            return
        end
        
        g_self.m_pNum = data
        print("sadsss==="..tostring(data))
        
        if(g_self.m_tag == nil) then
            return
        end

        if(g_self.m_tag() == nil) then
            return
        end
        
        print("sadsss1111===="..g_self.m_tag())
        

        print("sadsss1111")
        --修改数字

        for i = 1, 3 do
            print("sadsssi=="..i)
            if(g_self.m_tableCell[i]:getChildByTag(16):getChildByTag(666) ~= nil) then
                print("sadsssiiiii=="..i)
                local actionLDNode = g_self.m_tableCell[i]:getChildByTag(16):getChildByTag(666)
                local txt = actionLDNode:getChildByName("actionPoint"):getChildByName("Text_num")
                txt:setString(tostring(data))
                actionLDNode:setVisible(true)

                if(tostring(data) == "0") then
                    print("sadsssiiiiiffff")
                    actionLDNode:setVisible(false)
                end
            end
        end
    end

    --是1组建牌局 2大厅
    local tab = {}
    --print("ds34445dd==="..g_self.m_tag() )
    if(g_self.m_tag == nil) then
        return
    end

    if(g_self.m_tag() == 1) then
        local MainLayer = require 'main.MainLayer'
        tab['city_code'] = MainLayer:getCityCode()
    else
    end

    MainCtrol.filterNet("getMttNum", tab, response, PHP_POST)
end

function SuperPageTable:init()
	self.m_spPanel:setVisible(true)

    --1,2cell正常顺序
    for i = 1, 2 do
        self.m_tableCell[i] = ccui.Helper:seekWidgetByName(self.m_spPanel, "Panel_cell"..i)
        self.m_tableCell[i]:setTag(i)
        --self.m_tableCell[i]:setVisible(false)
        self.m_tablePos[i] = self.m_tableCell[i]:getPositionX()
        --print("xy="..tostring(self.m_tablePos[i]))

        self.m_callBackFun(i, self.m_tableCell[i])
    end

    self.m_maxCell = require('main.HallTable'):getCellNum()

    --3cell存放最后一个
    self.m_tableCell[3] = ccui.Helper:seekWidgetByName(self.m_spPanel, "Panel_cell"..3)
    self.m_tableCell[3]:setTag(3)
    --self.m_tableCell[i]:setVisible(false)
    self.m_tablePos[3] = self.m_tableCell[3]:getPositionX()
    --print("xy="..tostring(self.m_tablePos[i]))
    self.m_callBackFun(self.m_maxCell, self.m_tableCell[3])

	local function onTouchBegan(touch, event)
        --print("ttt-sprite bbb..")
        --self.m_isCanClick = false

        if(self.m_isCanMove ~= true) then
            return false
        end

        print('touch:getLocation().y'..touch:getLocation().y)
        if(touch:getLocation().y < 310 or touch:getLocation().y > 1090) then 
            return false
        end

        self.m_beginPosX = touch:getLocation().x
        return true
--[[
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(0, 0, s.width, s.height)
        print("size w="..s.width..",".."h="..s.height)
        print("locationInNode=("..locationInNode.x..","..locationInNode.y..")")
        print("touch:getLocation()=("..touch:getLocation().x..","..touch:getLocation().y..")")
        if cc.rectContainsPoint(rect, locationInNode) then
            print(string.format("sprite began... x = %f, y = %f", locationInNode.x, locationInNode.y))
            target:setOpacity(180)
            return true
        end
        return false
]]
    end

    local function onTouchMoved(touch, event)
    	--print("ttt-sprite mm..")
--[[
        local target = event:getCurrentTarget()
        local posX,posY = target:getPosition()
        local delta = touch:getDelta()
        target:setPosition(cc.p(posX + delta.x, posY + delta.y))
]]
        if(self.m_beginPosX == nil) then
            return
        end
        
        local offsetX = touch:getLocation().x - self.m_beginPosX
        if(math.abs(offsetX) >= self.m_canDist) then
            self.m_isCanClick = false
        end

        --print("offX="..offsetX)
        --开始向左滑
        if(offsetX < 0) then
            --cell1
            local per = math.abs(offsetX/750)
            local everyMoveX = self.m_tablePos[1] - self.m_tablePos[3]
            local realPosX = everyMoveX*per
            self.m_tableCell[1]:setPositionX(self.m_tablePos[3] + everyMoveX - realPosX)
            self.m_tableCell[1]:setScale(0.8 + 0.2*(1 - per))
            --cell2
            self.m_tableCell[2]:setPositionX(self.m_tablePos[2] - realPosX)
            self.m_tableCell[2]:setScale(1 - 0.2*(1 - per))

            if((1 - 0.2*(1 - per)) > (0.8 + 0.2*(1 - per))) then
                self.m_tableCell[1]:setLocalZOrder(0)
                self.m_tableCell[2]:setLocalZOrder(2)
                self.m_tableCell[3]:setLocalZOrder(0)
            else
                self.m_tableCell[1]:setLocalZOrder(2)
                self.m_tableCell[2]:setLocalZOrder(1)
                self.m_tableCell[3]:setLocalZOrder(0)
            end

            --cell3
            local dist = self.m_tablePos[2] - self.m_tablePos[3]
            self.m_tableCell[3]:setPositionX(self.m_tablePos[3] + dist*per)

            --替换卡牌逻辑
            if(self.m_tableCell[3]:getPositionX() > 510 and self.m_isZXInLeft == true) then
                self.m_isZXInLeft = false

                self.m_tableCell[3]:removeAllChildren()
                local tIdx = self.m_tableCell[2]:getChildByTag(16).idx + 1
                if(tIdx > self.m_maxCell) then 
                    tIdx = 1
                end
                self.m_callBackFun(tIdx, self.m_tableCell[3])
                self.m_tableCell[3]:getChildByTag(18):setVisible(false)
                self.m_tableCell[3]:getChildByName("e"):setVisible(false)
                self.m_tableCell[3]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))

            elseif(self.m_tableCell[3]:getPositionX() <= 510 and self.m_isZXInLeft == false) then
                self.m_isZXInLeft = true

                self.m_tableCell[3]:removeAllChildren()
                local tIdx = self.m_tableCell[1]:getChildByTag(16).idx - 1
                if(tIdx <= 0) then 
                    tIdx = self.m_maxCell
                end
                self.m_callBackFun(tIdx, self.m_tableCell[3])
                self.m_tableCell[3]:getChildByTag(18):setVisible(false)
                self.m_tableCell[3]:getChildByName("e"):setVisible(false)
                self.m_tableCell[3]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))
            end

            --改变颜色
            local vc = 75 + 180*(1 - per)
            local tc1 = cc.c3b(vc, vc, vc)
            vc = 75 + 180*per
            local tc2 = cc.c3b(vc, vc, vc)
            self.m_tableCell[1]:getChildByTag(16):setColor(tc1)
            self.m_tableCell[2]:getChildByTag(16):setColor(tc2)

            --print("ttt="..everyMoveX..'-'..realPosX..'='..everyMoveX - realPosX)
        --开始向右滑
        elseif(offsetX > 0) then
            --cell1
            local per = math.abs(offsetX/750)
            local everyMoveX = self.m_tablePos[2] - self.m_tablePos[1]
            local realPosX = everyMoveX*per
            self.m_tableCell[1]:setPositionX(self.m_tablePos[1] + realPosX)
        
            self.m_tableCell[1]:setScale(0.8 + 0.2*(1 - per))
            --cell3

            self.m_tableCell[3]:setPositionX(self.m_tablePos[3] + realPosX)
            self.m_tableCell[3]:setScale(1 - 0.2*(1 - per))

            if((1 - 0.2*(1 - per)) > (0.8 + 0.2*(1 - per))) then
                self.m_tableCell[1]:setLocalZOrder(0)
                self.m_tableCell[2]:setLocalZOrder(0)
                self.m_tableCell[3]:setLocalZOrder(2)
            else
                self.m_tableCell[1]:setLocalZOrder(2)
                self.m_tableCell[2]:setLocalZOrder(0)
                self.m_tableCell[3]:setLocalZOrder(1)
            end

            --cell2
            local dist = self.m_tablePos[2] - self.m_tablePos[3]
            self.m_tableCell[2]:setPositionX(self.m_tablePos[2] - dist*per)

            --替换卡牌逻辑
            if(self.m_tableCell[2]:getPositionX() > 510 and self.m_isYXInLeft == true) then
                self.m_isYXInLeft = false
                --print("ccc0")

                self.m_tableCell[2]:removeAllChildren()
                local tIdx = self.m_tableCell[1]:getChildByTag(16).idx + 1
                if(tIdx > self.m_maxCell) then 
                    tIdx = 1
                end
                self.m_callBackFun(tIdx, self.m_tableCell[2])
                self.m_tableCell[2]:getChildByTag(18):setVisible(false)
                self.m_tableCell[2]:getChildByName("e"):setVisible(false)
                self.m_tableCell[2]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))

            elseif(self.m_tableCell[2]:getPositionX() <= 510 and self.m_isYXInLeft == false) then
                self.m_isYXInLeft = true
                --print("ccc1")

                self.m_tableCell[2]:removeAllChildren()
                local tIdx = self.m_tableCell[3]:getChildByTag(16).idx - 1
                if(tIdx <= 0) then 
                    tIdx = self.m_maxCell
                end
                self.m_callBackFun(tIdx, self.m_tableCell[2])
                self.m_tableCell[2]:getChildByTag(18):setVisible(false)
                self.m_tableCell[2]:getChildByName("e"):setVisible(false)
                self.m_tableCell[2]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))
            end

            --改变颜色
            local vc = 75 + 180*(1 - per)
            local tc1 = cc.c3b(vc, vc, vc)
            vc = 75 + 180*per
            local tc3 = cc.c3b(vc, vc, vc)
            self.m_tableCell[1]:getChildByTag(16):setColor(tc1)
            self.m_tableCell[3]:getChildByTag(16):setColor(tc3)

        end
    end

    local function onTouchEnded(touch, event)
        print("ttt-sprite onTouchesEnded..")
        self.m_endPosX = touch:getLocation().x
        
        if(self.m_beginPosX == nil) then
            return
        end

        local offsetX = self.m_beginPosX - self.m_endPosX
        if(math.abs(offsetX) >= self.m_canDist) then
            --left
            if(offsetX > 0) then
                self:leftLogic()
                --DZPlaySound.playSound("sound/mainSence/move.wav", false)
            --right
            elseif(offsetX < 0) then
                self:rightLogic()
                --DZPlaySound.playSound("sound/mainSence/move.wav", false)
            end
        else
            self.m_isCanClick = true
        end

--[[
        local target = event:getCurrentTarget()
        target:setOpacity(255)
        if target == sprite2 then
            sprite1:setLocalZOrder(100)
        elseif target == sprite1 then
            sprite1:setLocalZOrder(0)
        end
]]
    end


    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    self.m_spPanel:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = self.m_spPanel:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_spPanel)

--[[
    local function touchEvent(sender,eventType)
	    if eventType == ccui.TouchEventType.began then
	    	self.m_beginPosX = 0
			self.m_endPosX = 0
			
	        print("Touch Down"..sender:getLocation().x..","..sender:getLocation().y)
	    elseif eventType == ccui.TouchEventType.moved then
	        print("Touch Move")
	    elseif eventType == ccui.TouchEventType.ended then
	        print("Touch Up")
	    elseif eventType == ccui.TouchEventType.canceled then
	        print("Touch Cancelled")
    	end
    end

	local p1 = ccui.Helper:seekWidgetByName(self.m_spPanel, "Panel_cell1")
	p1:setSwallowTouches(false)
    
    self.m_spPanel:addTouchEventListener(touchEvent)
]]

    local function onEvent(event)
        --重置
        if event == "exit" then
            for i = 1, 3 do
                self.m_tableCell[i]:removeAllChildren()
                self.m_tableCell[i]:setLocalZOrder(0)
                self.m_tableCell[i]:setScale(0.8)
                self.m_tableCell[i]:stopAllActions()
                self.m_tableCell[i]:setPositionX(self.m_tablePos[self.m_tableCell[i]:getTag()])           
            
                if(self.m_tableCell[i]:getTag() == 1) then
                    self.m_tableCell[i]:setLocalZOrder(1)
                    self.m_tableCell[i]:setScale(1)
                end
            end
            
            require('main.HallTable'):clearCellArr()

            if(self.m_actionNode ~= nil) then
                self.m_actionNode:release()
                self.m_actionNode = nil
            end 

            if(self.m_listener ~= nil) then
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:removeEventListener(self.m_listener)
                print("llll---removeM")
            end 

        elseif event == "enterTransitionFinish" then
            --增加星动画
            if(self.m_actionNode:getParent() ~= nil) then
                self.m_actionNode:removeFromParent()
            end
            self.m_tableCell[1]:getChildByTag(16).tbg:addChild(self.m_actionNode)
            self:openStarAction()

            --重置颜色
            self:resetColor()
        end
    end
    
    self:registerScriptHandler(onEvent)

    --创建动画节点
    self.m_actionNode = cc.Node:create()
    local s1 = cc.Sprite:create("main/main_star.png")
    s1:setPosition(cc.p(255, 484))
    local s2 = cc.Sprite:create("main/main_star.png")
    s2:setPosition(cc.p(153, 24))
    local s3 = cc.Sprite:create("main/main_star.png")
    s3:setPosition(cc.p(240, 300))
    self.m_actionNode:addChild(s1)
    self.m_actionNode:addChild(s2)
    self.m_actionNode:addChild(s3)

    self.m_actionNode:setPosition(cc.p(0, 0))
    self.m_actionNode:retain()

    self.m_s1 = s1
    self.m_s2 = s2
    self.m_s3 = s3

    g_self = self

    --[[--注册刷新事件
    local listenerCustom = cc.EventListenerCustom:create("C_Event_Update_MTT_CARD_NUM", CustomCallBackUpdateMttCard)  
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:addEventListenerWithFixedPriority(listenerCustom, 1)
    self.m_listener = listenerCustom

    CustomCallBackUpdateMttCard()

    --发送事件
    local myEvent = cc.EventCustom:new("C_Event_Update_MTT_CARD_NUM")
    local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
    customEventDispatch:dispatchEvent(myEvent) 
--]]
    print("ssssddhhh777")
    
end

function SuperPageTable:create(spPanel, addCellLayer, setIdx, getMyNeed)
    return SuperPageTable.new(spPanel, addCellLayer, setIdx, getMyNeed)
end

--左旋逻辑
function SuperPageTable:leftLogic()
    for i = 1, 3 do
        self.m_tableCell[i]:stopAllActions()
        self.m_tableCell[i]:getChildByTag(18):setVisible(false)
        self.m_tableCell[i]:getChildByName("e"):setVisible(false)
    end

    self.m_isCanMove = false
    local runTime = 0.1
    --self.m_tableCell[1]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[2], self.m_tableCell[2]:getPositionY())))
    self.m_tableCell[1]:runAction(cc.Sequence:create(
            cc.MoveTo:create(runTime, cc.p(self.m_tablePos[3], self.m_tableCell[3]:getPositionY())),
            cc.CallFunc:create( 
                function(sender)
                    self.m_isCanMove = true
                    self.m_isCanClick = true
                end)
            ))
    self.m_tableCell[1]:runAction(cc.ScaleTo:create(runTime, 0.8, 0.8))
    self.m_tableCell[3]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[2], self.m_tableCell[2]:getPositionY())))
    self.m_tableCell[3]:runAction(cc.ScaleTo:create(runTime, 0.8, 0.8))
    self.m_tableCell[2]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[1], self.m_tableCell[1]:getPositionY())))
    self.m_tableCell[2]:runAction(cc.ScaleTo:create(runTime, 1, 1))
    self.m_tableCell[1]:setLocalZOrder(0)
    self.m_tableCell[2]:setLocalZOrder(1)
    self.m_tableCell[3]:setLocalZOrder(0)
    self.m_setIdxCallFun(self.m_tableCell[2]:getChildByTag(16).idx)
    self.m_tableCell[2]:getChildByTag(18):setVisible(true)
    self.m_tableCell[2]:getChildByName("e"):setVisible(true)

    --换卡牌
    self.m_tableCell[3]:removeAllChildren()
    local tIdx = self.m_tableCell[2]:getChildByTag(16).idx + 1
    if(tIdx > self.m_maxCell) then 
        tIdx = 1
    end
    self.m_callBackFun(tIdx, self.m_tableCell[3])
    self.m_tableCell[3]:getChildByTag(18):setVisible(false)
    self.m_tableCell[3]:getChildByName("e"):setVisible(false)
    
    --敬请期待逻辑判断
    --if(self.m_tag() == 1 and self.m_tableCell[2]:getTag() == 3) then
    self.m_tableCell[2]:getChildByTag(18):setVisible(self.m_tableCell[2]:getChildByTag(16).isShowInBtn)
    self.m_tableCell[2]:getChildByName("e"):setVisible(self.m_tableCell[2]:getChildByTag(16).isShowEditBtn)
    --end

    local tmpCell = self.m_tableCell[1];
    self.m_tableCell[1] = self.m_tableCell[2]
    self.m_tableCell[2] = self.m_tableCell[3]
    self.m_tableCell[3] = tmpCell

    --增加星动画
    if(self.m_actionNode:getParent() ~= nil) then
        self.m_actionNode:removeFromParent()
    end
    self.m_tableCell[1]:getChildByTag(16).tbg:addChild(self.m_actionNode)
    self:openStarAction()

    --重置颜色
    self:resetColor()

end

--右旋逻辑
function SuperPageTable:rightLogic()
    for i = 1, 3 do
        self.m_tableCell[i]:stopAllActions()
        self.m_tableCell[i]:getChildByTag(18):setVisible(false)
        self.m_tableCell[i]:getChildByName("e"):setVisible(false)
    end

    self.m_isCanMove = false
    local runTime = 0.1
    --self.m_tableCell[1]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[3], self.m_tableCell[3]:getPositionY())))
    self.m_tableCell[1]:runAction(cc.Sequence:create(
            cc.MoveTo:create(runTime, cc.p(self.m_tablePos[2], self.m_tableCell[2]:getPositionY())),
            cc.CallFunc:create( 
                function(sender)
                    self.m_isCanMove = true
                    self.m_isCanClick = true
                end)
            ))
    self.m_tableCell[1]:runAction(cc.ScaleTo:create(runTime, 0.8, 0.8))
    self.m_tableCell[3]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[1], self.m_tableCell[1]:getPositionY())))
    self.m_tableCell[3]:runAction(cc.ScaleTo:create(runTime, 1, 1))
    self.m_tableCell[2]:runAction(cc.MoveTo:create(runTime, cc.p(self.m_tablePos[3], self.m_tableCell[3]:getPositionY())))
    self.m_tableCell[2]:runAction(cc.ScaleTo:create(runTime, 0.8, 0.8))
    self.m_tableCell[1]:setLocalZOrder(0)
    self.m_tableCell[2]:setLocalZOrder(0)
    self.m_tableCell[3]:setLocalZOrder(1)
    self.m_setIdxCallFun(self.m_tableCell[3]:getChildByTag(16).idx)
    self.m_tableCell[3]:getChildByTag(18):setVisible(true)
    self.m_tableCell[3]:getChildByName("e"):setVisible(true)

    --换卡牌
    self.m_tableCell[2]:removeAllChildren()
    local tIdx = self.m_tableCell[3]:getChildByTag(16).idx - 1
    if(tIdx <= 0) then 
        tIdx = self.m_maxCell
    end
    self.m_callBackFun(tIdx, self.m_tableCell[2])
    self.m_tableCell[2]:getChildByTag(18):setVisible(false)
    self.m_tableCell[2]:getChildByName("e"):setVisible(false)

    --敬请期待逻辑判断
    --if(self.m_tag() == 1 and self.m_tableCell[3]:getTag() == 3) then
    --getChildByTag(16)属性节点
    self.m_tableCell[3]:getChildByTag(18):setVisible(self.m_tableCell[3]:getChildByTag(16).isShowInBtn)
    self.m_tableCell[3]:getChildByName("e"):setVisible(self.m_tableCell[3]:getChildByTag(16).isShowEditBtn)
    --end

    local tmpCell = self.m_tableCell[1];
    self.m_tableCell[1] = self.m_tableCell[3]
    self.m_tableCell[3] = self.m_tableCell[2]
    self.m_tableCell[2] = tmpCell

    --增加星动画
    if(self.m_actionNode:getParent() ~= nil) then
        self.m_actionNode:removeFromParent()
    end
    self.m_tableCell[1]:getChildByTag(16).tbg:addChild(self.m_actionNode)
    self:openStarAction()

    --重置颜色
    self:resetColor()

end

--根据idx重置牌型位置
function SuperPageTable:resetPos(idx)

    self.m_tableCell[1]:removeAllChildren()
    self.m_callBackFun(idx, self.m_tableCell[1])
    self.m_tableCell[1]:getChildByTag(18):setVisible(self.m_tableCell[1]:getChildByTag(16).isShowInBtn)
    self.m_tableCell[1]:getChildByName("e"):setVisible(self.m_tableCell[1]:getChildByTag(16).isShowEditBtn)
   

    self.m_tableCell[2]:removeAllChildren()
    local tIdx = idx + 1
    if(tIdx > self.m_maxCell) then 
        tIdx = 1
    end
    self.m_callBackFun(tIdx, self.m_tableCell[2])
    self.m_tableCell[2]:getChildByTag(18):setVisible(false)
    self.m_tableCell[2]:getChildByName("e"):setVisible(false)

    self.m_tableCell[3]:removeAllChildren()
    tIdx = idx - 1
    if(tIdx <= 0) then 
        tIdx = self.m_maxCell
    end
    self.m_callBackFun(tIdx, self.m_tableCell[3])
    self.m_tableCell[3]:getChildByTag(18):setVisible(false)
    self.m_tableCell[3]:getChildByName("e"):setVisible(false)


    --增加星动画
    if(self.m_actionNode:getParent() ~= nil) then
        self.m_actionNode:removeFromParent()
    end
    self.m_tableCell[1]:getChildByTag(16).tbg:addChild(self.m_actionNode)
    self:openStarAction()

    --重置颜色
    self:resetColor()
--[[

    local posidx = {}
    for i = 1, 3 do
        if(idx == self.m_tableCell[i]:getTag()) then
            posidx[1] = self.m_tableCell[i]
            break
        end
    end
-------------
    local leftTag = posidx[1]:getTag() - 1
    if(leftTag <= 0) then 
        leftTag = 3
    end

    for i = 1, 3 do
        if(leftTag == self.m_tableCell[i]:getTag()) then
            posidx[3] = self.m_tableCell[i]
            break
        end
    end
-------------
    local rightTag = posidx[1]:getTag() + 1
    if(rightTag >= 4) then 
        rightTag = 1
    end

    for i = 1, 3 do
        if(rightTag == self.m_tableCell[i]:getTag()) then
            posidx[2] = self.m_tableCell[i]
            break
        end
    end

    for i = 1, 3 do
        self.m_tableCell[i] = posidx[i]
        self.m_tableCell[i]:getChildByTag(18):setVisible(false)
        self.m_tableCell[i]:getChildByName("e"):setVisible(false)
        self.m_tableCell[i]:setLocalZOrder(0)
        self.m_tableCell[i]:setScale(0.8)
        self.m_tableCell[i]:stopAllActions()
        self.m_tableCell[i]:setPositionX(self.m_tablePos[i])           
    end

    self.m_tableCell[1]:setLocalZOrder(1)
    self.m_tableCell[1]:setScale(1)
    self.m_tableCell[1]:getChildByTag(18):setVisible(true)
    self.m_tableCell[1]:getChildByName("e"):setVisible(true)
]]
end

--开启星星动画
function SuperPageTable:openStarAction()

    local s1 = self.m_s1
    local s2 = self.m_s2 
    local s3 = self.m_s3
    s1:stopAllActions()
    s2:stopAllActions()
    s3:stopAllActions()

    s1:setScale(0)
    s2:setScale(0)
    s3:setScale(0)

    local showTime = 1
    local offsetTime = 0.33

    s1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
    s2:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))
    s3:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 360)))

    self.m_actionNode:stopAllActions()
    self.m_actionNode:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create( 
                function(sender)
                    s1:runAction(cc.ScaleTo:create(showTime/2, 1, 1))
                end),
            cc.DelayTime:create(showTime/2),
            cc.CallFunc:create( 
                function(sender)
                    s1:runAction(cc.ScaleTo:create(showTime/2, 0, 0))
                end),
            cc.DelayTime:create(offsetTime),
            cc.CallFunc:create( 
                function(sender)
                    s2:runAction(cc.ScaleTo:create(showTime/2, 1, 1))
                end),
            cc.DelayTime:create(showTime/2),
            cc.CallFunc:create( 
                function(sender)
                    s2:runAction(cc.ScaleTo:create(showTime/2, 0, 0))
                end),
            cc.DelayTime:create(offsetTime),
            cc.CallFunc:create( 
                function(sender)
                    s3:runAction(cc.ScaleTo:create(showTime/2, 1, 1))
                end),
            cc.DelayTime:create(showTime/2),
            cc.CallFunc:create( 
                function(sender)
                    s3:runAction(cc.ScaleTo:create(showTime/2, 0, 0))
                end),
            cc.DelayTime:create(offsetTime)
            )))

    --播放大红圈
    if((self.m_tag() == 2 and self.m_tableCell[1]:getChildByTag(16).idx == 5) or (self.m_tag() == 1 and self.m_tableCell[1]:getChildByTag(16).idx == 4)) then
        local actionLD = cc.CSLoader:createTimeline("action/showStarPoint.csb")
        local actionLDNode = self.m_tableCell[1]:getChildByTag(16):getChildByTag(666)
        actionLDNode:runAction(actionLD)
        actionLD:play("action", true)
        print("asdasdasd2222")
    else
        for i = 1, 3 do
            if(self.m_tableCell[i]:getChildByTag(16):getChildByTag(666) ~= nil) then
                local actionLD = cc.CSLoader:createTimeline("action/showStarPoint.csb")
                local actionLDNode = self.m_tableCell[i]:getChildByTag(16):getChildByTag(666)
                actionLDNode:runAction(actionLD)
                actionLD:play("stop", true)
                print("asdasdasd1111")

                local txt = actionLDNode:getChildByName("actionPoint"):getChildByName("Text_num")
                txt:setString(tostring(self.m_pNum))
                actionLDNode:setVisible(true)

                if(tostring(self.m_pNum) == "0") then
                    actionLDNode:setVisible(false)
                end
            end
        end
    end
end

--重置颜色
function SuperPageTable:resetColor()
    --重置颜色
    self.m_tableCell[1]:getChildByTag(16):setColor(cc.c3b(255, 255, 255))
    self.m_tableCell[2]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))
    self.m_tableCell[3]:getChildByTag(16):setColor(cc.c3b(75, 75, 75))
end



return SuperPageTable