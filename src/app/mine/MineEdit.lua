local ViewBase = require("ui.ViewBase")
local MineEdit = class("MineEdit", ViewBase)
local MineCtrol = require('mine.MineCtrol')

local _mineEdit = nil
local viewSize = nil
local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

local userIcon = nil
local stencil = nil
local iconMask = nil
local cameraIcon = nil

-- data
local headimg 	= nil
local sexValue 		= nil
local personsign 	= nil
local countryid 	= nil

-- ui
local imgTab1,imgTab2 = {}, {}
local photoBg = nil
local photo_count = nil
local photo_node = {}
local userName = nil

local mineMsg = {}

local function Callback(  )
	_mineEdit:removeFromParent()

	local myEvent = cc.EventCustom:new("C_Event_update_MineInfo")
	local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
	customEventDispatch:dispatchEvent(myEvent)
end

local function saveCallback(  )
	if personsign ~= "" then
		if string.len(personsign) > LEN_DES then
			ViewCtrol.showTip({content = "不能超过"..(LEN_DES/3).."个汉字或"..LEN_DES.."个字母、数字！"})
			return
		end 
	end

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			MineCtrol.editInfo( {personsign = personsign, sex = sexValue, headimg = headimg, countryid = countryid} )
			ViewCtrol.showTick({content = "保存成功!"})

			Callback()
		end
	end
	local tabData = {}
	tabData["headimg"] 	= headimg
	tabData["sex"] 		= sexValue
	tabData["personsign"] = personsign
	tabData["countryid"] = countryid
	tabData["id"] = Single:playerModel():getId()
	XMLHttp.requestHttp("user/update", tabData, response, PHP_POST)
end

local function iconCallback(  )
	local function funcback( iconName, iconPath )
		headimg = iconName
		_mineEdit:buildIcon(iconPath)
	end
	ClubModel.buildPhoto( 0, funcback, {op_type = 1, photo_type = 2} )
end

local function editNameFunc(  )
	local modify = require("mine.ModifyName")
	local layer = modify:create()
	_mineEdit:addChild(layer)
	layer:createLayer()
	if cameraIcon then 
		cameraIcon:setVisible(true)
	end
end

local function countryFunc( ... )
	local items = {}
	items = DZConfig.getCountryTab()
	local function confirmFuc( index )
		countryStr:setString(items[index].name)
		countryid = items[index].id
	end
	local function createCellFunc( data, idx, size )
		-- dump(data)
		local name = data.name
		local item = ccui.Layout:create()
		item:setTouchEnabled(true)
		item:setContentSize(cc.size(size.width, size.height+10))
		item:setTag(idx)

		local img = "0"..tostring(data.id)..".png"
		local sp = cc.Sprite:createWithSpriteFrameName(img)
		sp:setAnchorPoint(cc.p(1, 0.5))
		sp:setPosition(cc.p(item:getContentSize().width/2-10, item:getContentSize().height/2))
		sp:setName("country")
		item:addChild(sp)

		local label = cc.LabelTTF:create(name, "Arial", 38)
		label:setAnchorPoint(cc.p(0,0.5))
		label:setPosition(cc.p(item:getContentSize().width/2+10, item:getContentSize().height/2))
		label:setName("Text")
		label:setFontFillColor(cc.c3b(108, 125, 150))
		item:addChild(label)
		return item 
	end
	local obj = {
	                ['title'] = "选择国家/地区", 
	                ['items'] = items, 
	                ['confirmFuc'] = confirmFuc,
	                ['createCellFunc'] = createCellFunc
	            }
	require("ui.UITextPicker").show(_mineEdit, obj)
end

function MineEdit:buildLayer(  )

	-- grey up
	imgTab1.imgNormal = 'user/user_icon_female.png'
	imgTab1.imgSelected = 'user/user_icon_female.png'
	imgTab1.imgDisabled = 'user/user_icon_female.png'
	-- grey down
	imgTab2.imgNormal = 'user/user_icon_male.png'
	imgTab2.imgSelected = 'user/user_icon_male.png'
	imgTab2.imgDisabled = 'user/user_icon_male.png'

	local uiTab = {
                {text="头像和昵称", sizeH=390, tag=1, stype=1}, 
                {text="国家/地区", sizeH=116, tag=2, stype=1}, 
                {text="性别", sizeH=116, tag=3, stype=2}, 
                {text="个性签名", sizeH=400, tag=4, stype=2},
            }
    local viewH = 0
    local photoShow_H = 377
    for i=1,#uiTab do
        viewH = uiTab[i].sizeH + viewH
    end
    viewSize = {width = display.width, height = viewH+photoShow_H}
    if viewSize.height < display.height-130 then
        viewSize.height = display.height-130
    end

	mineMsg =  MineCtrol.getMineInfo(  )
	dump(mineMsg)

	-- 大背景scrollView
    local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )

    local layer = UIUtil.addImageView({image=ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})

    -- topBar
    UIUtil.addTopBar({backFunc = Callback, title = "编辑资料", menuFont = "保存", menuFunc = saveCallback, parent = self})

	-- 相册
	local rect = cc.rect(10,10,10,10)
	photoBg = UIUtil.scale9Sprite(rect, ResLib.CLUB_EDIT_BG, cc.size(display.width, photoShow_H), cc.p(display.cx,viewSize.height-188), layer)
	photo_node = self:BgArray( mineMsg.players_imgs, photoBg )

	local sizeH = {}
	local infoBg = {}
	local infoBgH = 0

	for i=1,#uiTab do
		sizeH[i] = uiTab[i].sizeH
		infoBgH = sizeH[i] + infoBgH
		infoBg[i] = UIUtil.addImageView({image = "common/com_opacity0.png", touch=false, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, viewSize.height - photoShow_H - infoBgH), parent=layer})

		if i < 4 then
			local drawNode = cc.DrawNode:create()
			infoBg[i]:addChild(drawNode)
			drawNode:drawSegment(cc.p(0, 1), cc.p(display.width, 1), 1, cc.c4f(39/255, 39/255, 39/255, 0.5))
		end
		
		local posY = sizeH[i]/2
		if uiTab[i].tag == 1 then
			posY = sizeH[i]-46
		elseif uiTab[i].tag == 4 then
			posY = sizeH[i]-66
		end
		UIUtil.addLabelArial(uiTab[i].text, 32, cc.p(30, posY), cc.p(0, 0.5), infoBg[i])
	end

	-- 头像、昵称
	stencil, userIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.6, pos = cc.p(display.cx, sizeH[1]/2+15), parent = infoBg[1], nor = ResLib.USER_HEAD, sel =ResLib.USER_HEAD, listener = iconCallback})
	headimg = mineMsg.headimg
	local url = mineMsg.headimg
	local function funcBack( iconPath )
		userIcon:loadTextureNormal(iconPath)
		userIcon:loadTexturePressed(iconPath)
		userIcon:loadTextureDisabled(iconPath)
	end
	local ferror = function()
		userIcon:loadTextureNormal("user/takephoto.png")
		userIcon:loadTexturePressed("user/takephoto.png")
		userIcon:loadTextureDisabled("user/takephoto.png")
		userIcon:setScale(1)
	end
	if mineMsg.headimg ~= "" then
		if url == "default_avatars.png" then 
			url = ""
		end
		ClubModel.downloadPhoto(funcBack, url, true, ferror)
	end
	cameraIcon = UIUtil.addPosSprite("club/club_icon_camera.png", cc.p(display.cx+20, sizeH[1]/2-50+25), infoBg[1], cc.p(0, 0.5))
	if url == "" then 
		cameraIcon:setVisible(false)
	end

	userName = UIUtil.addLabelArial(mineMsg.username, 32, cc.p(display.cx, sizeH[1]/2-100), cc.p(0.5, 0.5), infoBg[1]):setColor(ResLib.COLOR_YELLOW1)
	UIUtil.addImageBtn({norImg = "user/user_edit_name.png", selImg = "user/user_edit_name.png", pos = cc.p(userName:getPositionX()+userName:getContentSize().width/2+35, userName:getPositionY()), listener = editNameFunc, parent = infoBg[1]})

	-- 国家
	countryid = mineMsg.countryid or 2
	local country = DZConfig.getCountryById(countryid)
	local countryBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, pos = cc.p(0, 0), ah = cc.p(0, 0), touch = true, scale9 = true, size = cc.size(display.width, sizeH[2]), listener = countryFunc, parent = infoBg[2]})
	
	local downSp = UIUtil.addPosSprite("user/icon_down.png", cc.p(display.width-20, countryBtn:getContentSize().height/2), countryBtn, cc.p(1, 0.5))
	countryStr = UIUtil.addLabelArial(country.name, 30, cc.p(downSp:getPositionX()-downSp:getContentSize().width-50, countryBtn:getContentSize().height/2), cc.p(1, 0.5), countryBtn)

	-- 性别
	local sex = UIUtil.addLabelArial("女", 32, cc.p(display.width-150, sizeH[3]/2), cc.p(0, 0.5), infoBg[3])
	local function sexFunc( tag, sender )
		if sender:getSelectedIndex() == 0 then
			sex:setString("女")
			sexValue = 2
		else
			sex:setString("男")
			sexValue = 1
		end
	end
	local togItem = self:addTogMenu(imgTab1, imgTab2, cc.p(display.width-20, sizeH[3]/2), sexFunc, infoBg[3])
	togItem:setAnchorPoint(cc.p(1,0.5))
	sexValue = mineMsg.sex
	if tonumber(sexValue) == 2 then
		sex:setString("女")
		togItem:setSelectedIndex(0)
	else
		sex:setString("男")
		togItem:setSelectedIndex(1)
	end

	-- 简介
	local str = '个性签名'

	-- UIUtil.addImageView({scale = true, size = cc.size(display.width - 40, 192), pos = cc.p(display.cx, sizeH[4]-116),image = ResLib.CLUB_EDIT_BG, ah = cc.p(.5,1),parent=infoBg[4]} )
	local text = UIUtil.addEditBox(ResLib.CLUB_EDIT_BG, cc.size(display.width-50, 192), cc.p(display.cx+5, sizeH[4]-116), '', infoBg[4] )
	text:setAnchorPoint(cc.p(0.5, 1))
	text:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
	text:setFontColor(ResLib.COLOR_YELLOW1)
	text:setPlaceholderFontColor(ResLib.COLOR_YELLOW1)

	local label = text:getChildByTag(1999)
	if label and label.setPositionY then 
		label:setDimensions(text:getContentSize().width-10, text:getContentSize().height )
	end

	local placeholder = UIUtil.addLabelArial('请输入简介', 30, cc.p(33, 268), cc.p(0, 1), infoBg[4],ResLib.COLOR_YELLOW1)
	personsign = mineMsg.personsign
	if mineMsg.personsign ~= '' then
		text:setText(personsign)
		placeholder:setVisible(false)
	else 
		placeholder:setVisible(true)
	end
	text:setMaxLength(LEN_DES+1)

	local function textFunc( eventType, sender )
		if eventType == "began" then
			placeholder:setVisible(false)
		elseif eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			str = string.gsub(str, "\n", "")
			local charLen = string.len(str)
			if  charLen > LEN_DES then
				personsign = StringUtils.checkStrLength( str, LEN_DES )
			elseif charLen <= 0 then
				placeholder:setVisible(true)
				personsign = str
	        else 
				personsign = str
			end
			sender:setText(personsign)
		end
	end
	text:registerScriptEditBoxHandler(textFunc)
end

-- 修改名字
function MineEdit:setUserName( name )
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
	print(name)
	userName:setString(name)
end

function MineEdit:addTogMenu( imgTab1, imgTab2, pos, callBack, parent )
	local sprite1Nor = cc.Sprite:create(imgTab1.imgNormal)
	local sprite1Sel = cc.Sprite:create(imgTab1.imgSelected)
	local sprite1Dis = cc.Sprite:create(imgTab1.imgDisabled)

	local sprite2Nor = cc.Sprite:create(imgTab2.imgNormal)
	local sprite2Sel = cc.Sprite:create(imgTab2.imgSelected)
	local sprite2Dis = cc.Sprite:create(imgTab2.imgDisabled)
	local Menu1 = cc.MenuItemSprite:create(sprite1Nor, sprite1Sel, sprite1Dis)
	local Menu2 = cc.MenuItemSprite:create(sprite2Nor, sprite2Sel, sprite2Dis)

	local item = cc.MenuItemToggle:create(Menu1)
	item:addSubItem(Menu2)
	item:registerScriptTapHandler(callBack)
	local menu = cc.Menu:create()
	menu:addChild(item)
	menu:setPosition(pos)
	parent:addChild(menu)
	return item
end

local function smallCallback( sender )
	print("相册")
	local flag = nil
	local oldImg = nil
	local tag = sender:getTag()
	print("tag: "..tag)
	local imgUrl = MineCtrol.getMineInfo().players_imgs[tag]
	-- print(imgUrl)
	local sendTab = {img = imgUrl}
	local function deleteImgs(  )
		MineCtrol.editInfo({imgs_d = imgUrl})
		local bgArray = MineCtrol.getMineInfo().players_imgs
		photo_node = _mineEdit:BgArray( bgArray, photoBg )
	end

	local function funcBack( iconName, iconPath )
		_mineEdit:buildBg(iconName, flag, oldImg)
	end
	if tag <= photo_count then
		flag = 1
		oldImg = imgUrl
		ClubModel.buildPhoto( 1, funcBack, {op_type = 1, photo_type = 1, sendData = sendTab, deleteBack = deleteImgs} )
	else
		flag = 0
		ClubModel.buildPhoto( 0, funcBack, {op_type = 1, photo_type = 1} )
	end
end

-- YDWX_DZ_ZHANGMENG_BUG _20160628 _004
function MineEdit:BgArray( bgArray, node )
	dump(bgArray)
	-- 相册数量
	photo_count = #bgArray

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

	local function loadImage(  )
		local sizeW, sizeH = 160, 150
		dump(imageName)
		for i=1, #bgArray do
			local sprite = cc.Sprite:create(imageName[i])
			local scaleX = sizeW/sprite:getContentSize().width
			local scaleY = sizeH/sprite:getContentSize().height
			smallBg[i]:setScale(scaleX, scaleY)

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
			stencilS[idx], smallBg[idx] = UIUtil.addCircleHead({shape = ResLib.PHOTO_ADD, scale = 1, pos = cc.p(display.width*(2*j-1)/8, 280-(i-1)*190), parent = node, nor = photoImg, sel = photoImg, listener = smallCallback, mask = ""})
			smallBg[idx]:setTag(idx)
			
			local function funcBack( path )
				imageName[idx] = path
				imageIdx = imageIdx + 1
				if imageIdx == #bgArray then
					loadImage()
				end
			end
			if idx <= (#bgArray) then
				local url = bgArray[idx].background
				ClubModel.downloadPhoto(funcBack, url, true)
			end
		end
	end
	return smallBg
end

function MineEdit:buildBg( iconName, flag, oldImg )
	
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			if flag == 1 then
				MineCtrol.replaceImg(iconName, oldImg)
			else
				MineCtrol.editInfo({imgs = iconName, id = data.data.id})
			end
			
			local bgArray = MineCtrol.getMineInfo().players_imgs
			photo_node = self:BgArray( bgArray, photoBg )
		end
	end
	local tabData = {}
	local http = ""
	local tabData = {}
	-- 替换
	if flag == 1 then
		tabData["img_url"] = iconName
		tabData["id"] = oldImg.id
		http = "user/background/update"
	else
		tabData["img_url"] = iconName
		tabData["user"] = Single:playerModel():getId()
		http = "user/background"
	end
	XMLHttp.requestHttp(http, tabData, response, PHP_POST)
end

-- 下载头像
function MineEdit:buildIcon( iconPath )
	if not iconPath then
		return
	end
	if cameraIcon then 
		cameraIcon:setVisible(true)
	end
	userIcon:loadTextureNormal(iconPath)
	userIcon:loadTexturePressed(iconPath)
	userIcon:loadTextureDisabled(iconPath)
	
	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	userIcon:setScale(scaleX, scaleY)
end

function MineEdit:createLayer(  )
	_mineEdit = self
	_mineEdit:setSwallowTouches()
	_mineEdit:addTransitAction()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	mineMsg = {}
	cameraIcon = nil
	self:buildLayer()
end

return MineEdit