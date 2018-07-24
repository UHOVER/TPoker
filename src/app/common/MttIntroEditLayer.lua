--
-- Author: Taylor
-- Date: 2017-03-07 18:35:58

local ViewBase = require("ui.ViewBase")
local MttIntroEditLayer = class("MttIntroEditLayer", ViewBase)
local CHAR_LEN = 500*3

local glView = cc.Director:getInstance():getOpenGLView()
local originPt = glView:getVisibleOrigin()
local originSize = glView:getVisibleSize()
local ratio  = 1
if display.height < 1334 then 
	ratio = display.height/1500
end

function MttIntroEditLayer:ctor(params)
	if params == nil then 
		do return end
	end
	self:ignoreAnchorPointForPosition(false)
	self:setAnchorPoint(cc.p(0,0))
	self:setContentSize(display.width, display.height)
	self:setPosition(cc.p(0,0))
	self.isPublish = params.isPublish or false
	self.description = params.description or ""
	self.callbackHandle = params.callback
	-- print("self.callbackHandler："..tostring(self.callbackHandle))
	self:setSwallowTouches()
	self:initView()

	local backCtrUI = function() 
						 print("self.callbackHandler："..tostring(self.callbackHandle), self.description)
						 self.callbackHandle(self.description, self.isPublish)	
						 self:removeFromParent() -- 看看是否在这里移除
					  end
	local rightCtrUI = function()
						 --显示弹出框
						 local bg =  self:alertContent()
					  end
	UIUtil.addTopBar({backFunc = backCtrUI, rightSpName = "common/set_card_MTT_ask.png", rightBtnFunc = rightCtrUI, title = "赛事简介", parent = self})
end

function MttIntroEditLayer:initView()

	UIUtil.addImageView({ResLib.MTT_BG, touch = false, scale = true, size = cc.size(display.width, display.height), pos=cc.p(0, 0), parent = self});
	local blackbg = cc.LayerColor:create(cc.c3b(0, 0,0))
	blackbg:ignoreAnchorPointForPosition(false)
	blackbg:setAnchorPoint(cc.p(.5, 0))
	blackbg:setPosition(cc.p(display.cx, 879*ratio))
	blackbg:setContentSize(cc.size(710, 300))
	self:addChild(blackbg)

	local editbox = UIUtil.addEditBox(nil, cc.size(675, 277), cc.p(display.cx, 1029*ratio), "请输入简介",self)
	editbox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
	editbox:setMaxLength(CHAR_LEN + 1)
	-- print("self.description:"..self.description, "self.isPublish"..tostring(self.isPublish))
	if self.description  and self.description ~= "" then
		editbox:setText(self.description)
	end
	editbox:registerScriptEditBoxHandler(handler(self, self.editCallback))
	-- editbox:addChild(colorbg)
	local labelPlaceholder = editbox:getChildByTag(1998)
	local labelInbox = editbox:getChildByTag(1999)
	if labelInbox then 
		-- print("我获取到了文字的坐标啦")
		labelInbox:setDimensions(editbox:getContentSize().width-10, editbox:getContentSize().height) --35
		labelPlaceholder:setDimensions(editbox:getContentSize().width-10, editbox:getContentSize().height)
		-- labelInbox:setPositionY(labelInbox:getPositionY() - 100)
		-- labelPlaceholder:setPositionY(labelPlaceholder:getPositionY() - 100)
	end
	local function clearFunc(sender, eventType)
		if eventType == ccui.TouchEventType.ended then 
			self.description = ""
			editbox:setText("")
			
		end
	end
	local btnres = {"common/com_btn_delete_img.png","common/com_btn_delete_img.png","common/com_btn_delete_img.png"}
	local clearBtn = UIUtil.addUIButton(btnres, cc.p(display.width - 21, 862 * ratio), self, clearFunc)
	clearBtn:setScale9Enabled(true)
	clearBtn:setContentSize(cc.size(102, 50))
	clearBtn:setAnchorPoint(cc.p(1, 1))
	clearBtn:setTitleText("清除")
	clearBtn:setTitleFontSize(30)
	clearBtn:setTitleColor(cc.c3b(255,255,255))
end

function MttIntroEditLayer:editCallback(eventType,sender)
	if eventType == "began" then 

	elseif eventType == "changed" then 
		local text = sender:getText()
		print("string.len(text) :" ..string.len(text))
		if string.len(text) > CHAR_LEN then 
			sender:closeKeyboard()
			ViewCtrol.showTip({content = "不能超过"..(CHAR_LEN/3).."个汉字或"..CHAR_LEN.."个字符！"})
		end
	elseif eventType == "return"  then
		local text = sender:getText()
		if string.len(text) > CHAR_LEN then 
			self.description = StringUtils.checkStrLength( text, CHAR_LEN)
		else 
			self.description = text 
		end
		sender:setText(self.description)
	end
end

function MttIntroEditLayer:alertContent()
	   local bg = cc.LayerColor:create(cc.c4b(255,0,0,0))
	   bg:ignoreAnchorPointForPosition(false)
	   bg:setContentSize(cc.size(683, 201))
	   bg:setAnchorPoint(cc.p(0, 1))
	   bg:setPosition(cc.p(73, (display.height-100)))
	   self:addChild(bg,1000)
	   local textArray = {
	   						"例如可输入，赛事获奖类型：记分牌+实物奖励，领取方式：",
	   						"请添加微信\"***\"客服领取。实物奖励名次，第一名：线下门",
	   						"票一张；第二名：线下门票一张；第三名：20元话费券一张；",
	   						"第四名：10元话费券一张；第五名：5元话费券一张"
						 }
	   local sp = UIUtil.scale9Sprite(cc.rect(30,60,60,30),"common/set_card_MTT_ask_bg.png",cc.size(672,192),cc.p(0, 0), bg)
	   sp:setAnchorPoint(cc.p(0,0))
	
	   UIUtil.addMutiLabel({texts = textArray, fontSize = 24, dimensions = cc.size(641, 24), lineSpace = 14, parent = bg, pt = cc.p(19,0)})
	   bg.noEndedBack = true
	   bg.noEndedBack = function()
	   						bg:removeFromParent()
	   					 end
	   bg._isSwallowImg = true
	   TouchBack.registerImg(bg)
	   return bg
  
end

return MttIntroEditLayer