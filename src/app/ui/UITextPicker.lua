--
-- Author: Taylor
-- Date: 2017-05-10 15:37:37
-- 文字 Picker


local UITextPicker = class("UITextPicker", function()
                return cc.LayerColor:create(cc.c4b(255, 255, 255, 0))
    end)

local _title = nil
local _confirmFunc = nil
local _items = nil
local _basePicker = nil
local _createCellFunc = nil

function UITextPicker:ctor(params)
    _title = params.title or "请选择管理员ID"
    _confirmFunc = params.confirmFuc 
    _items = params.items or nil
    _createCellFunc = params.createCellFunc

    self:initView(params)

    self._isSwallowImg = true 
    TouchBack.registerImg(self)
end

function UITextPicker:initView()
    self:enableNodeEvents()
    local bg = UIUtil.addPosSprite("mtt/timeBg.png", cc.p(0,0),self,cc.p(0,0)) 
    local w, h = bg:getContentSize().width, bg:getContentSize().height

    local bg_bottom = UIUtil.addPosSprite("mtt/shadow_bottom.png", cc.p(0, 0), self,cc.p(0,0))
    local bg_top = UIUtil.addPosSprite("mtt/shadow_top.png", cc.p(0, h-26), self, cc.p(0,1))
    bg_top:setLocalZOrder(10)
    bg_bottom:setLocalZOrder(10) 
    bg_top:setScaleY(160/185)
    local fontsize  = 32
    local title = cc.LabelTTF:create(_title, "Helvetica-Bold", fontsize)
        :move(display.cx, h - 48)
        :addTo(self)
     title:setAnchorPoint(cc.p(0.5, 1))
     title:setLocalZOrder(11);

   local function touchEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local index = _basePicker:getSelectIndex()
            print("index")
            if _confirmFunc then 
                _confirmFunc(index)
                self:removeFromParent()
            end
        end
    end
    local button = ccui.Button:create()
    button:setScale9Enabled(true)
    button:setTouchEnabled(true)
    button:setAnchorPoint(cc.p(1, 1))
    button:setPosition(cc.p(w-32, h-20-22))
    button:addTouchEventListener(touchEvent)
    button:ignoreContentAdaptWithSize(false)
    button:setTitleText("确定")
    button:setTitleFontSize(30)
    button:setTitleColor(cc.c3b(255, 255, 255))
    button:setContentSize(cc.size(100, 50))
    self:addChild(button,100)

    local obj = {
                  ['items'] = _items,
                  ['callback'] = function(index) 
                                        -- if _confirmFunc then 
                                        --     _confirmFunc(index)
                                        -- end
                                 end,
                  ['circle'] = false,
                  ['size'] = cc.size(450,312),
                  ['margin'] = 29,
                  ['createCellFunc'] = _createCellFunc
                }
    local UIBasePickerClass = require("ui.UIBasePicker")
    _basePicker = UIBasePickerClass.new(obj)
    self:addChild(_basePicker)
    _basePicker:setPosition(cc.p(w/2 - 225, 210 - 119.5))
end

function UITextPicker.noEndedBack(touch, event)
    local target = event:getCurrentTarget()
    target:removeFromParent()
end

function UITextPicker:onEnter()
end
function UITextPicker:onExit()
    _items = nil
    _title = nil
    _confirmFunc = nil
    _basePicker = nil
    _createCellFunc = nil
end

--------------------------------------
-- parent 父容器
-- params = {
---    ["title"] = "请选择管理员ID"
---    ["confirmFuc"] =  xx --点击确定的回调 
---    ['items'] = nil --listView显示的资源
---
---      items = {name = "", id = "",}
--------------------------------------
function UITextPicker.show(parent, params)
    local textPicker = UITextPicker.new(params)
    textPicker:setPosition(cc.p(0,0))
    parent:addChild(textPicker)
end


return UITextPicker
