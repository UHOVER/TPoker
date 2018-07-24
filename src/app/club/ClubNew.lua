local ViewBase = require('ui.ViewBase')
local ClubNew = class('ClubNew', ViewBase)


local ClubCtrol = require("club.ClubCtrol")
local UnionCtrol = require("union.UnionCtrol")
local AreaCode = require('club.AreaCode')

local _clubNew = nil
local NEW_TARGET = nil

local _create_auth = false --是否有创建的权限
-- 建立俱乐部所需信息
local ADDRESS_ID 	= nil 		-- 地区
local club_Name 	= nil 		-- 俱乐部名称
local club_Area 	= nil
local club_Avatar 	= nil 		-- 俱乐部头像

-- 俱乐部UI信息
local clubName 		= nil
local clubArea 		= nil
local clubIcon 		= nil
local stencil 		= nil

local tab = {}

local function backCallback( tag, sender )
	if NEW_TARGET == "club" then
		_clubNew:removeTransitAction()
	else
		_clubNew:removeFromParent()
	end
end

-- 设置地区回调
local function areaCallback( tag, sender )
	print("打开地区")
	local function funcBack( data )
		dump(data)
		ADDRESS_ID = data.code
		_clubNew:buildArea( data.name )
	end
	-- AreaCode.buildArea( funcBack, _clubNew, true )
	local _cityLayer = require("main.CityLayer"):create("new", funcBack)
	-- _cityLayer:initData("北京市")
	_clubNew:addChild(_cityLayer)
end

-- 设置头像回调
local function iconCallback( tag, sender )
	local function funcBack( iconName, iconPath )
		club_Avatar = iconName
		-- print(club_Avatar)
		_clubNew:buildIcon(iconPath)
	end
	local OP_TYPE = 2
	if NEW_TARGET == "club" then
		OP_TYPE = 2
	elseif NEW_TARGET == "union" or NEW_TARGET == "new" then
		OP_TYPE = 3
	end
	ClubModel.buildPhoto( 0, funcBack, {op_type = OP_TYPE, photo_type = 2} )
end

local function newBtnCallBack( tag, sender )
	if NEW_TARGET == "club" then
		_clubNew:newClub()
	elseif NEW_TARGET == "union" or NEW_TARGET == "new" then
		_clubNew:newUnion()
	end
end

function ClubNew:buildLayer(  )
	local color = cc.c3b(165, 157, 157)
	-- bg
	local imageView = UIUtil.addImageView({image="club/club_layer_bg.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local title = nil 			-- title
	local iocn_label = nil
	local name_label = nil
	local area_label = nil
	local head_icon = nil
	local create_des = nil
	local btn_title = nil
	if NEW_TARGET == "club" then
		title = "建立俱乐部"
		iocn_label = "俱乐部头像"
		name_label = "俱乐部名称"
		head_icon = ResLib.CLUB_HEAD_GENERAL
		create_des = "已创建俱乐部数量：0/1"
		btn_title = "完成"
		_create_auth = true -- 如果是创建俱乐部，默认是true
	elseif NEW_TARGET == "union" or NEW_TARGET == "new" then
		title = "我的联盟"
		iocn_label = "联盟头像"
		name_label = "联盟名称"
		head_icon = ResLib.UNION_HEAD
		-- create_des = "已创建联盟数量：0/1"
		create_des = ""
		btn_title = "创建联盟"
		_create_auth = UnionCtrol.isMatchAccess(UnionCtrol.access_mine_create)
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = backCallback, title = title, parent = self})
	print("_create_auth"..tostring(_create_auth))
	if not _create_auth then
		UIUtil.addPosSprite(head_icon, cc.p(display.cx, 928), self, cc.p(.5,.5))
		UIUtil.addLabelArial("您还未获得创建联盟资格,请联系", 38, cc.p(display.cx, 741), cc.p(.5,0),self):setColor(cc.c3b(177,177,177))
		UIUtil.addLabelArial("客服了解情况", 38, cc.p(display.cx, 741-49), cc.p(.5, 0), self):setColor(cc.c3b(177,177,177))
		return
	end
	UIUtil.addLabelArial('寻找志同道合的朋友', 25, cc.p(display.cx, display.top-200), cc.p(0.5, 0.5), self):setColor(color)

	--俱乐部头像
	UIUtil.addLabelArial(iocn_label, 30, cc.p(display.left+20, display.top-188), cc.p(0, 0), self)

	stencil, clubIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.8, pos = cc.p(display.cx, display.height*0.742), parent = self, nor = head_icon, sel = head_icon, listener = iconCallback})

	
	UIUtil.addPosSprite("club/club_icon_camera.png", cc.p(display.cx+10, display.height*0.69), self, cc.p(0, 0.5))
	UIUtil.addLabelArial(create_des, 20, cc.p(display.cx, display.height*0.64), cc.p(0.5, 0.5), self):setColor(color)

	--俱乐部名称
	UIUtil.addLabelArial(name_label, 30, cc.p(display.left+20, display.height*0.54), cc.p(0, 0), self)
	-- local clubNameBg = UIUtil.addImageView({image=ResLib.CLUB_BTN_BG, touch=false, scale=true, size=cc.size(600, 80), ah=cc.p(0.5, 0.5), pos=cc.p(display.cx, display.height*0.5), parent=self})
	-- local clubNameBg = UIUtil.addImageView({image=ResLib.BTN_BLUE_BORDER, touch=false, scale=true, size=cc.size(display.width-80, 80), ah=cc.p(0.5, 0.5), pos=cc.p(display.cx, display.height*0.5), parent=self})
	local clubNameBg = UIUtil.addImageView({image="club/club_task_content_bg.png", touch=false, scale=true, size=cc.size(display.width-40, 94), ah=cc.p(0.5, 0.5), pos=cc.p(display.cx, display.height*0.49), parent=self})
	clubNameBg:setColor(cc.c3b(54,55,56))
	local width = clubNameBg:getContentSize().width
	local height = clubNameBg:getContentSize().height
	--YDWX_DZ_CHENTAO_BUG _20160627_002
	clubName = UIUtil.addEditBox( ResLib.COM_OPACITY0, cc.size(display.width-60, 94), cc.p(width/2, height/2), '请输入俱乐部名称', clubNameBg ):setFontColor(cc.c3b(100, 125, 165))
	clubName:setPlaceholderFontColor(cc.c3b(100, 125, 165))
	clubName:setMaxLength(LEN_NAME)
	--[[local function nameFunc( eventType, sender )
		if eventType == "began" then
			print("began")
		elseif eventType == "changed" then
			
		elseif eventType == "ended" then
			
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			club_Name = str
			if str ~= "" then
				if not cc.LuaHelp:IsGameName(club_Name) or string.len(club_Name) > LEN_NAME then
					ViewCtrol.showTip({content = "名称为"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
				end
			end
		end
	end--]]
	local function nameFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_NAME, content ="俱乐部名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！", funcBack = function(str)
			club_Name = str
		end })
	end
	clubName:registerScriptEditBoxHandler(nameFunc)
	
	--所在地区
	UIUtil.addLabelArial('所在地区', 30, cc.p(display.left+20, display.height*0.3883), cc.p(0, 0), self)
	local label1 = cc.Label:createWithSystemFont("", "Marker Felt", 30)
	-- local areaBtn1 = UIUtil.controlBtn(ResLib.BTN_WHITE_NOR, ResLib.BTN_WHITE_NOR, ResLib.BTN_WHITE_NOR, label1, cc.p(display.cx, display.height*0.3), cc.size(600,80), areaCallback, self)
	
	local areaBtn1 = UIUtil.controlBtn("club/club_task_content_bg.png", "club/club_task_content_bg.png", "club/club_task_content_bg.png", label1, cc.p(display.cx, display.height*0.336), cc.size(display.width-40, 94), areaCallback, self)
	areaBtn1:setColor(cc.c3b(54,55,56))
	-- YDWX_DZ_ZHANGMENG_BUG _201606289_004【UE Integrity】BUG

	clubArea = UIUtil.addLabelArial('', 30, cc.p(20, height/2), cc.p(0, 0.5), areaBtn1)	
	clubArea:setColor(cc.c3b(100, 125, 165))
	-- YDWX_DZ_ZHANGMENG_BUG _201606289_004【UE Integrity】BUG
	
	-- 建立Btn
	local btn_normal, btn_select = "common/com_btn_blue.png",  "common/com_btn_blue_height.png"
	--ResLib.BTN_BLUE_NOR, ResLib.BTN_BLUE_DIS, ResLib.BTN_BLUE_DIS
	local label = cc.Label:createWithSystemFont(btn_title, "Marker Felt", 36):setColor(display.COLOR_WHITE)
	UIUtil.controlBtn(btn_normal, btn_select, btn_normal, label, cc.p(display.cx, display.height*0.045), cc.size(710,80), newBtnCallBack, self)

end

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_007   、 YDWX_DZ_ZHANGMENG_BUG _20160713_005
* DESCRIPTION OF THE BUG :【UE Integrity】 YDWX_DZ_ZHANGMENG_BUG _20160713_012【UE Integrity】Do not display prompt 
* MODIFIED BY : 王礼宁
* DATE :2016-7-11、8-17
*************************************************************************/
]]


function ClubNew:newClub(  )
	if club_Name == nil or club_Name == "" then
		ViewCtrol.showTip({content = "俱乐部名称不能为空！"})
		return
	else
		if not cc.LuaHelp:IsGameName(club_Name) or string.len(club_Name) > LEN_NAME then
			ViewCtrol.showTip({content = "俱乐部名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end

	if ADDRESS_ID == nil then
		ViewCtrol.showTip({content = "请选择俱乐部所在地区！"})
		return
	end

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			
			local ClubScene = require("club.ClubScene")
			ClubScene.startScene()
		end
	end
	local tabData = {}
	tabData['address'] 	= ADDRESS_ID
	tabData['name'] 	= club_Name
	tabData['avatar'] 	= club_Avatar or ""
	XMLHttp.requestHttp( PHP_CLUB_INDEX, tabData, response, PHP_POST )
end

function ClubNew:newUnion(  )
	
	if club_Name == nil or club_Name == "" then
		ViewCtrol.showTip({content = "联盟名称不能为空！"})
		return
	else
		if not cc.LuaHelp:IsGameName(club_Name) or string.len(club_Name) > LEN_NAME then
			ViewCtrol.showTip({content = "俱乐部名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end

	local function response( data )
		dump(data)
		if data.code == 0 then
			_clubNew:removeFromParent()
		
 			local entryUnionHanlder = function()
 				 local DashBoardLayer = require("union.DashBoardLayer")
           		 DashBoardLayer.show(nil, { from = UnionCtrol.mine_union})
 			end
			UnionCtrol.requestDetailUnion(entryUnionHanlder)
		end
	end
	local tabData = {}
	-- tabData["club_id"] 		= ClubCtrol.getClubInfo().id or ClubCtrol.getClubInfo().club_id
	tabData['city'] 		= ADDRESS_ID
	tabData['unionName'] 	= club_Name
	tabData['avatar'] 		= club_Avatar or ""
	XMLHttp.requestHttp( "create_union", tabData, response, PHP_POST )
end

	--[[
**************************************************************************
* NAME OF THE BUG : YDWX_DZ_ZHANGMENG_BUG _20160713_007 、 YDWX_DZ_ZHANGMENG_BUG _20160713_005
* DESCRIPTION OF THE BUG :【UE Integrity】 
* MODIFIED BY : 王礼宁
* DATE :2016-7-11
*************************************************************************/
]]


-- 地区处理
function ClubNew:buildArea( address )
	club_Area = address
	clubArea:setString( club_Area )
end
-- 头像处理
function ClubNew:buildIcon( iconPath )
	clubIcon:loadTextureNormal(iconPath)
	clubIcon:loadTexturePressed(iconPath)
	clubIcon:loadTextureDisabled(iconPath)

	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	clubIcon:setScale(scaleX, scaleY)
end

function ClubNew:createLayer( target )
	_clubNew = self
	_clubNew:setSwallowTouches()
	NEW_TARGET = target

	if NEW_TARGET == "club" then
		_clubNew:addTransitAction()
	end

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	self:init()
	self:buildLayer()
end

function ClubNew:init(  )
-- 建立俱乐部所需信息
	ADDRESS_ID 	= nil 		-- 地区
	club_Name 	= nil 		-- 俱乐部名称
	club_Area 	= nil
	club_Avatar = nil 		-- 俱乐部头像

-- 俱乐部UI信息
	clubName 		= nil
	clubArea 		= nil
	clubIcon 		= nil
	tab['font'] = 'Arial'
	tab['size'] = 30
end

return ClubNew
