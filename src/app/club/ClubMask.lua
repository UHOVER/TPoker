local ClubMask = class("ClubMask", function (  )
	return cc.LayerColor:create(cc.c4b(10, 10, 10, 0), display.width, display.height-130)
end)

local _clubMask = nil
local _clubList = nil

local function newClubFun(  )
	_clubMask:removeFromParent()
	local function response( data )
		dump(data)
		--print(data)
		if data.code == 0 then
			local newClub = require('club.ClubNew')
			local layer = newClub:create()
			_clubList:addChild(layer)
			layer:createLayer("club")
		end
	end
	local tabData = {}
	XMLHttp.requestHttp( PHP_CHECK_CLUB, tabData, response, PHP_POST )
end

local function addClubFun(  )
	_clubMask:removeFromParent()

	AddCtrol.setAddTarget( AddCtrol.CLUB )
	local _cityLayer = require("main.CityLayer"):create("add")
	_clubList:addChild(_cityLayer)
end

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_010
* DESCRIPTION OF THE BUG : 【UE Integrity】Page does not match
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]

function ClubMask:ctor( parent )
	_clubMask = self
	_clubList = parent

	local color = cc.c3b(165, 157, 157)

	local markSp = UIUtil.addPosSprite("common/com_club_mask_bg.png", cc.p(display.right-25, display.top-115), self, cc.p(1, 1))
	UIUtil.addImageBtn({norImg = "common/com_newclub_btn_1.png", selImg = "common/com_newclub_btn_2.png", ah = cc.p(0.5,1), pos = cc.p(markSp:getContentSize().width/2, markSp:getContentSize().height-17), touch = true, swalTouch = true, listener = newClubFun, parent = markSp})

	UIUtil.addImageBtn({norImg = "common/com_addclub_btn_1.png", selImg = "common/com_addclub_btn_2.png", ah = cc.p(0.5,0), pos = cc.p(markSp:getContentSize().width/2, 0), touch = true, swalTouch = true, listener = addClubFun, parent = markSp})

	self:touchFun()
end

--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_010
* DESCRIPTION OF THE BUG : 【UE Integrity】Page does not match
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]

function ClubMask:touchFun(  )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		-- print('触摸屏蔽')
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch, event )
		self:removeFromParent()
	end, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

return ClubMask