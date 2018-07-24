local ViewBase = require("ui.ViewBase")
local UserInfo = class("UserInfo", ViewBase)


local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30
local _userInfo = nil

local userInfo = {}

local function Callback(  )
	_userInfo:removeFromParent()

	DZChat.showChatChangeData(userInfo)
end

local function msgFunc( isOk )

	local myId = Single:playerModel():getId()
	local key = myId .. userInfo.ryid
	local value = isOk

	print("------------------------")
	print("key : " .. key)
	print("value : " .. value)
	Storage.setStringForKey(key, value)
end

local function deleteMsg(  )

	local layer = nil
	local function clearMsg(  )
		DZChat.clickClearRecord(userInfo["ryid"], userInfo["chatType"])
		layer:removeFromParent()
	end
	layer = UIUtil.clearChatMsg( {sureFunc = clearMsg, parent = _userInfo} )
end

function UserInfo:buildLayer(  )
	
	UIUtil.addTopBar({backFunc = Callback, title = '聊天详情', parent = self})

	local sizeH = {200, 100, 100}
	local infoBg = {}
	local infoBgH = 0
	local infoW = 20
	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	for i=1,3 do
		infoBgH = sizeH[i] + infoBgH
		infoBg[i] = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (display.height-130) - infoBgH), parent=layer})
	end

	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(70, sizeH[1]/2), infoBg[1], ResLib.CLUB_HEAD_STENCIL_200)
	local url = userInfo["usersMsg"][1]["headUrl"]
	local function funcBack( path )
		local rect = stencil:getContentSize()
		Icon:setTexture(path)
		Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	-- 俱乐部名称
	local name = userInfo["usersMsg"][1]["name"]
	local Name = UIUtil.addLabelArial(name, 36, cc.p(140, sizeH[1]/2), cc.p(0, 0.5), infoBg[1])

	-- 新消息通知
	local msgLabel = UIUtil.addLabelArial('新消息通知', 30, cc.p(infoW, sizeH[2]/2), cc.p(0, 0.5), infoBg[2])

	local function valueChanged( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			msgFunc( 1 )
		else
			print("off")
			msgFunc( 0 )
		end
	end
	local newsTog = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[2]/2), listener = valueChanged, parent = infoBg[2]})
	newsTog:setAnchorPoint(cc.p(1, 0.5))

	local myId = Single:playerModel():getId()
	local key = myId .. userInfo.ryid

	local isOk = Storage.getStringForKey(key) or 1
	if tonumber(isOk) == 0 then
		newsTog:setSelectedIndex(1)
	else
		newsTog:setSelectedIndex(0)
	end

	-- 聊天记录
	local clubDel = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(display.width, sizeH[3]), ah = cc.p(0,0.5), pos = cc.p(0, sizeH[3]/2), touch = true, swalTouch = false, listener = deleteMsg, parent = infoBg[3]})
	UIUtil.addLabelArial("清空聊天记录", 30, cc.p(infoW, sizeH[3]/2), cc.p(0,0.5), infoBg[3])

end

function UserInfo:createLayer( msg )
	_userInfo = self
	_userInfo:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	userInfo = {}
	userInfo = msg
	dump(userInfo)
	self:buildLayer()
end

return UserInfo
