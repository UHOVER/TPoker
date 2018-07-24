local ViewBase = require('ui.ViewBase')
local ClubTest = class('ClubTest', ViewBase)
local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")
local _clubTest = nil

local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local clubMsg = nil
local infoData = {}
local curTarget = nil
local CLUB_TAG = nil
local FRIEND_TAG = nil
local callfunc = nil

local function Callback(  )
	_clubTest:removeTransitAction()
end

local function clubSendFunc( tag, sender )
	local function response( data )
		dump(data)
		if tonumber( data.code ) == 0 then
			ViewCtrol.showTick({content = "发送验证信息成功!"})
			_clubTest:removeTransitAction()
		end
	end
	local tabData = {}
	tabData['club_uid'] = infoData.user_id
	tabData['club_id'] 	= infoData.id
	tabData['content'] 	= clubMsg
	XMLHttp.requestHttp( PHP_CLUB_MESSAGE, tabData, response, PHP_POST )
end

-- 申请加入联盟
local function unionSendFunc(  )
	local function response( data )
		dump(data)
		if tonumber( data.code ) == 0 then
			ViewCtrol.showTick({content = "发送验证信息成功!"})
			_clubTest:removeTransitAction()
		end
	end
	local tabData = {}
	tabData['club_id'] 	= ClubCtrol.getClubInfo()["id"]
	tabData['union_id'] = infoData.id
	tabData['content'] 	= clubMsg
	XMLHttp.requestHttp( "club_send_request", tabData, response, PHP_POST )
end

-- 邀请俱乐部加入联盟
local function union_clubSendFunc(  )
	local function response( data )
		dump(data)
		if data.code == 0 then
			ViewCtrol.showTick({content = "发送验证信息成功!"})
			_clubTest:removeTransitAction()
		end
	end
	local tabData = {}
	tabData["cid"] = infoData.id
	tabData["union_id"] = UnionCtrol.getUnionInfo(  ).union_id
	tabData["content"] = clubMsg
	XMLHttp.requestHttp("send_request", tabData, response, PHP_POST)
end

local function friendSendFunc(  )
	local function response( data )
		dump(data)
		if tonumber( data.code ) == 0 then
			ViewCtrol.showTick({content = "好友申请已发送!"})
			_clubTest:removeTransitAction()
		end
	end
	local tabData = {}
	tabData["to_id"] = infoData.id
	tabData["contents"] = clubMsg
	XMLHttp.requestHttp(PHP_FRIEND_TEST, tabData, response, PHP_POST)
end

function ClubTest:buildLayer(  )

	local title = nil
	local editStr = nil

	if curTarget == CLUB_TAG then
		callfunc = clubSendFunc
		title = "俱乐部验证"
		editStr = "我是".. Single:playerModel():getPName()
	elseif curTarget == "union" then
		editStr = "我是" .. ClubCtrol.getClubInfo().name .. "俱乐部"
		callfunc = unionSendFunc
		title = "联盟验证"
	elseif curTarget == "union_club" then
		editStr = "欢迎加入" .. UnionCtrol.getUnionInfo().union_name .. "联盟"
		title = "邀请俱乐部验证"
		callfunc = union_clubSendFunc
	elseif curTarget == FRIEND_TAG then
		editStr = "我是".. Single:playerModel():getPName()
		callfunc = friendSendFunc
		title = "好友验证"
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = title, menuFont = "发送", menuFunc = callfunc, parent = self})

	UIUtil.addImageView({image=ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height - 130), parent=self})
	
	-- 验证
	local string = '您需要发送验证申请,等待对方通过。'
	UIUtil.addLabelArial(string, 28, cc.p(25, display.top-164), cc.p(0, 0.5), self)
	

	clubMsg = editStr
	local testBox = UIUtil.addEditBox( ResLib.COM_EDIT_WHITE, cc.size(display.width-40, 74), cc.p(display.width/2, display.height-238), editStr, self )
	testBox:setText(editStr)
	local function testMsgFunc( eventType, sender)
	 	clubMsg = sender:getText()
	 	print(clubMsg)
	end
	testBox:registerScriptEditBoxHandler(testMsgFunc)

end

function ClubTest:createLayer( data, target )
	
	_clubTest = self
	_clubTest:setSwallowTouches()
	_clubTest:addTransitAction()

	self:init()
	curTarget = target

	infoData = data
	dump(infoData)
	
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:buildLayer()
end

function ClubTest:init(  )
	clubMsg 	= nil
	infoData 	= {}
	curTarget 	= nil
	CLUB_TAG 	= "club"
	FRIEND_TAG 	= "friend"
	callfunc 	= nil 		-- 发送回调
end

return ClubTest