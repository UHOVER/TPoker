local ViewBase = require('ui.ViewBase')
local ClubEditInfo = class('ClubEditInfo', ViewBase)

local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")

local _clubEditInfo = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local clubIcon = nil
local stencil = nil

local message = {}
local viewSize = nil

local info = {}
local club_Name = nil
local club_Summary = nil
local club_Avatar = nil

-- bg
local photoBg = nil
local photo_count = nil
local photo_node = {}
local club_photo = nil

local function Callback( tag, sender )
	_clubEditInfo:removeFromParent()
	local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
	local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	customEventDispatch:dispatchEvent(myEvent)
end

local function saveCallback( tag, sender )
	
	if club_Name == "" then
		print("<<<<<<<<<<<<< club_name " .. club_Name .. "hahah")
		ViewCtrol.showTip({content = "请输入俱乐部名称！"})
		return
	else
		print("<<<<<<<<<<<<< club_name " .. club_Name .. "hahah")
		if not cc.LuaHelp:IsGameName(club_Name) or string.len(club_Name) > LEN_NAME then
			ViewCtrol.showTip({content = "名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end

	if club_Summary ~= "" then
		if string.len(club_Summary) > LEN_DES then
			ViewCtrol.showTip({content = "不能超过"..(LEN_DES/3).."个汉字或"..LEN_DES.."字符！"})
			return
		end
	end
	
	info = {}
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			ClubCtrol.editClubInfo( info )
			ViewCtrol.showTick({content = "保存成功!"})
			Callback()
		end
	end
	local tabData = {}
	tabData['club_id'] 	= message.id
	tabData['name'] 	= club_Name
	tabData['summary'] 	= club_Summary
	tabData['avatar'] 	= club_Avatar
	-- dump(tabData)
	info = tabData
	XMLHttp.requestHttp( PHP_CLUB_UPDATE, tabData, response, PHP_POST )
end

local function iconCallback( tag, sender )
	local function funcback( iconName, iconPath )
		club_Avatar = iconName
		_clubEditInfo:buildIcon(iconPath)
	end
	ClubModel.buildPhoto( 0, funcback, {op_type = 2, photo_type = 2} )
end

function ClubEditInfo:buildLayer(  )

	viewSize = {width = display.width, height = display.height-100}
	local head_label = nil
	local name_label = nil
	local summary_label = nil
	local infoData = {}

	head_label = "俱乐部头像"
	name_label = "俱乐部名称"
	summary_label = "俱乐部简介"
	message = ClubCtrol.getClubInfo()
	club_Avatar = message.avatar
	infoData["name"] = message.name
	infoData["summary"] = message.summary
	infoData["bg"] = message.club_bg

	-- 大背景scrollView
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )
	scrollView:setScrollBarEnabled(false)
	
	--addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "编辑资料", menuFont = "保存", menuFunc = saveCallback, parent = self})

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})

	-- 背景
	local rect = cc.rect(10,10,10,10)
	photoBg = UIUtil.scale9Sprite(rect, ResLib.CLUB_EDIT_BG, cc.size(display.width, 350), cc.p(display.cx,viewSize.height-175), layer)
	photo_node = self:BgArray( infoData.bg, photoBg )
	
	local sizeH = {260, 160, 200}
	local infoBg = {}
	local infoBgH = 0

	for i=1,3 do
		infoBgH = sizeH[i] + infoBgH
		infoBg[i] = UIUtil.addImageView({image = "common/com_opacity0.png", touch=false, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (viewSize.height-400) - infoBgH), parent=layer})
	end

	-- 头像
	UIUtil.addLabelArial(head_label, 30, cc.p(50, sizeH[1]-30), cc.p(0, 0.5), infoBg[1])

	local head_icon = nil
	if tonumber(message.union) == 0 then
		head_icon = ResLib.CLUB_HEAD_GENERAL
	-- else
	-- 	head_icon = ResLib.CLUB_HEAD_ORIGIN
	end

	stencil, clubIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, pos = cc.p(display.cx, sizeH[1]/2), parent = infoBg[1], scale = 0.7, nor = head_icon, sel = head_icon, listener = iconCallback})
	local url = club_Avatar
	local function funcBack( iconPath )
		clubIcon:loadTextureNormal(iconPath)
		clubIcon:loadTexturePressed(iconPath)
		clubIcon:loadTextureDisabled(iconPath)
	end
	ClubModel.downloadPhoto(funcBack, url, true)
	
	-- 俱乐部名称
	UIUtil.addLabelArial(name_label, 30, cc.p(50, sizeH[2]-30), cc.p(0, 0.5), infoBg[2])

	local clubName = UIUtil.addEditBox( ResLib.CLUB_EDIT_BG, cc.size(display.width-100, 70), cc.p(display.cx, sizeH[2]/2-20), '名称', infoBg[2] )
	clubName:setFontColor(display.COLOR_WHITE)
	clubName:setText(infoData.name)
	club_Name = infoData.name
	clubName:setMaxLength(LEN_NAME)
	--[[local function nameFunc( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			local str = sender:getText()
			print("________________ : " .. str)
			local len = string.len(str)
			print("________________ : " .. len)
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			print(">>>>>>>>>>>>> " .. str)
			sender:setText(str)
			club_Name = str
			if str ~= "" then
				if string.len(club_Name) > LEN_NAME or (not cc.LuaHelp:IsGameName(club_Name)) then
					ViewCtrol.showTip({content = "名称为"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
				end
			end
		end
	end--]]
	local function nameFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			club_Name = str
		end })
	end
	clubName:registerScriptEditBoxHandler(nameFunc)

	-- 简介
	UIUtil.addLabelArial(summary_label, 30, cc.p(50, sizeH[3]-30), cc.p(0, 0.5), infoBg[3])

	local text = UIUtil.addEditBox( ResLib.CLUB_EDIT_BG, cc.size(display.width-100, 120), cc.p(display.cx, sizeH[3]/2-20), '请输入简介', infoBg[3] )
	text:setFontColor(display.COLOR_WHITE)
	if message.summary ~= '' then
		text:setText(infoData.summary)
	end
	club_Summary = infoData.summary
	-- YDWX_DZ_ZHANGMENG_BUG _20160628 _011【UE Integrity】
	text:setMaxLength(LEN_DES)
	local function textFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_DES, content ="简介不能超过"..(LEN_DES/3).."个汉字或"..LEN_DES.."个字母、数字！", funcBack = function(str)
			club_Summary = str
		end })
	end
	text:registerScriptEditBoxHandler(textFunc)

	--[[local function textFunc( eventType, sender )
		if eventType == "began" then
		elseif eventType == "changed" then
			if string.len(sender:getText()) > LEN_DES then
				sender:closeKeyboard()
				ViewCtrol.showTip({content = "不能超过"..(LEN_DES/3).."个汉字或"..LEN_DES.."个字符！"})
			end
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			if string.len(str) > LEN_DES then
				club_Summary = StringUtils.checkStrLength( str, LEN_DES )
	        else
				club_Summary = str
			end
			sender:setText(club_Summary)
		end
	end
	text:registerScriptEditBoxHandler(textFunc)--]]

end

local function smallCallback( tag, sender )
	
	local flag = nil
	local oldImgs = nil
	local sendTab = {}
	local OP_TYPE = nil

	local tag = tag:getTag()
	local imgs = ClubCtrol.getClubInfo().club_bg[tag]
	oldImgs = imgs
	sendTab = {img = imgs, club_id = message.id}
	OP_TYPE = 2
	
	local function deleteImgs(  )
		local bgArray = {}
		ClubCtrol.deleteClubPhotos( oldImgs )
		bgArray = ClubCtrol.getClubInfo().club_bg
		photo_node = _clubEditInfo:BgArray(bgArray, photoBg)
	end

	local function funcBack( iconName, iconPath )
		_clubEditInfo:buildBg(iconName, flag, oldImgs)
	end
	if tag <= photo_count then
		flag = 1
		ClubModel.buildPhoto( 1, funcBack, {op_type = OP_TYPE, photo_type = 1, sendData = sendTab, deleteBack = deleteImgs} )
	else
		flag = 0
		ClubModel.buildPhoto( 0, funcBack, {op_type = OP_TYPE, photo_type = 1} )
	end
end

function ClubEditInfo:BgArray( bgArray, node )

	if #photo_node ~= 0 then
		node:removeAllChildren()
		photo_node = {}
	end

	local smallBg = {}
	local stencilS = {}
	local count = nil
	local photoImg = nil
	local imageIdx = 0
	local imageName = {}
	photo_count = #bgArray

	local function loadImage(  )
		local sizeW, sizeH = 160, 150
		for i=1, photo_count do
			local sprite = cc.Sprite:create(imageName[i])
			local scaleX = sizeW/sprite:getContentSize().width
			local scaleY = sizeH/sprite:getContentSize().height
			-- smallBg[i]:setScale(scaleX, scaleY)

			smallBg[i]:loadTextureNormal(imageName[i])
			smallBg[i]:loadTexturePressed(imageName[i])
			smallBg[i]:loadTextureDisabled(imageName[i])
		end
	end
	
	if #bgArray < 8 then
		count = #bgArray+1
	else
		count = #bgArray
	end
	local line = math.ceil( count/4 )
	for i=1,line do
		local row = 4
		if count/i < 4 then
			row = count % 4
		end
		for j=1,row do
			local idx = (i-1)*4 + j
			if idx == count then
				photoImg = ResLib.PHOTO_ADD
			else
				photoImg = "common/com_photo_image.png"
			end
			stencilS[idx], smallBg[idx] = UIUtil.addCircleHead({shape = ResLib.PHOTO_ADD, scale = 1, pos = cc.p(display.width*(2*j-1)/8, 260-(i-1)*170), parent = node, nor = photoImg, sel = photoImg, listener = smallCallback, mask = ""})
			smallBg[idx]:setTag(idx)
			
			local function funcBack( path )
				imageName[idx] = path
				imageIdx = imageIdx + 1
				if imageIdx == #bgArray then
					loadImage()
				end
			end
			if idx <= (#bgArray) then
				local url = bgArray[idx]
				ClubModel.downloadPhoto(funcBack, url, true)
			end
		end
	end
	return smallBg
end

-- 相册
function ClubEditInfo:buildBg( iconName, flag, oldImgs )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if flag == 1 then
				ClubCtrol.replaceClubPhotos(iconName, oldImgs)
			else
				ClubCtrol.addClubPhotos( iconName )
			end
			local bgArray = ClubCtrol.getClubInfo().club_bg
			photo_node = self:BgArray(bgArray, photoBg)
		end
	end
	local tabData = {}
	tabData['club_id'] = message.id
	tabData['new_img'] = iconName
	if flag == 1 then
		tabData["old_img"] = oldImgs
		tabData["mod"] = "update"
	else
		tabData["mod"] = "new"
	end
	XMLHttp.requestHttp('insert_bgimg', tabData, response, PHP_POST)
end

-- 下载头像
function ClubEditInfo:buildIcon( iconPath )
	clubIcon:loadTextureNormal(iconPath)
	clubIcon:loadTexturePressed(iconPath)
	clubIcon:loadTextureDisabled(iconPath)
	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	clubIcon:setScale(scaleX, scaleY)
end

function ClubEditInfo:createLayer()

	_clubEditInfo = self
	_clubEditInfo:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self:buildLayer(  )
end

return ClubEditInfo