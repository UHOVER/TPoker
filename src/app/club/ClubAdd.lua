local ViewBase = require('ui.ViewBase')
local ClubAdd = class('ClubAdd', ViewBase)


local ClubCtrol = require('club.ClubCtrol')
local AreaCode = require('club.AreaCode')

local _clubAdd = nil
local ADD_TARGET = nil
local SEARCH_TEXT 	= nil

-- ui
local searchEdit	= nil
local user_id = nil

local btn = nil
local function backFunc( tag, sender )
	if ADD_TARGET == "union_club" then
		_clubAdd:removeFromParent()
	else
		_clubAdd:removeTransitAction()
	end
end

local function searchCallback( tag, sender )
	print('搜索俱乐部')
	if SEARCH_TEXT == nil or SEARCH_TEXT == "" then
		return
	else
		if not cc.LuaHelp:IsGameName(SEARCH_TEXT) or string.len(SEARCH_TEXT) > LEN_NAME then
			ViewCtrol.showTip({content = "俱乐部名称不能超过"..(LEN_NAME/3).."个汉字或"..LEN_NAME.."个字母、数字！"})
			return
		end
	end
	if ADD_TARGET == "club" or ADD_TARGET == "union_club" then
		_clubAdd:searchArea( "key", SEARCH_TEXT)
	elseif ADD_TARGET == "union" then
		_clubAdd:searchUnion( "key", SEARCH_TEXT )
	end
end

function ClubAdd:buildLayer(  )
	local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

	local str = nil 	-- title
	local tips = nil 	-- 提示文字
	if ADD_TARGET == "club" then
		str = "搜索俱乐部"
		tips = "俱乐部名称/名片ID"
	elseif ADD_TARGET == "union" then
		str = "搜索联盟"
		tips = "联盟名称/名片ID"
	elseif ADD_TARGET == "union_club" or ADD_TARGET == "new" then
		str = "邀请加入联盟"
		tips = "俱乐部名称/名片ID"
	end

	-- addTopBar
	UIUtil.addTopBar({backFunc = backFunc, title = str, parent = self})

	local imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	-- YDWX_DZ_ZHANGMENG_BUG _20160608 _010【UE Integrity】Page error 
	-- 搜索框
	searchEdit = UIUtil.addEditBox( ResLib.COM_EDIT_WHITE, cc.size(display.width-60, 60), cc.p(display.cx, display.height-150), tips, self )
	searchEdit:setMaxLength(18)
	searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
	searchEdit:setAnchorPoint(cc.p(0.5, 1))
	local function callback( eventType, sender )
		if eventType == "began" then
			-- btn:setVisible(false)
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			sender:setText(str)
			SEARCH_TEXT = str
			if SEARCH_TEXT ~= "" then
				searchCallback()
			end
			-- btn:setVisible(true)
		end
	end
	searchEdit:registerScriptEditBoxHandler( callback )

	-- 搜索按钮
	btn = UIUtil.addPosSprite(ResLib.SEARCH_BTN, cc.p(display.width-90, 30), searchEdit, cc.p(0.5, 0.5))
	btn:setScale(1.5)

	-- 地区列表
	local function funcBack( addressID, addressText )
		print(addressID..'   ' ..addressText )
		if ADD_TARGET == "club" or ADD_TARGET == "union_club" then
			self:searchArea( "city", addressID)
		elseif ADD_TARGET == "union" then
			self:searchUnion("city", addressID )
		end
	end
	AreaCode.buildArea( funcBack, self, false )
end

-- 搜索俱乐部
function ClubAdd:searchArea( searchType, searchValue )

	local function response( data )
		if data.code == 0 then
			if data.msg == "ok" then
				local searchList = require('club.SearchList')
				local layer = searchList:create()
				self:addChild(layer)
				layer:createLayer(data.data, ADD_TARGET)
			elseif data.msg == "failed" then
				local contentStr = nil
				if ADD_TARGET == "club" or ADD_TARGET == "union_club" then
					contentStr = "俱乐部"
				elseif ADD_TARGET == "union" then
					contentStr = "联盟"
				end
				ViewCtrol.showTip({title = contentStr.."不存在", content = "没有找到相关"..contentStr.."，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["category"] = searchType
	tabData["user_id"] = user_id
	tabData["search_key"] = searchValue
	XMLHttp.requestHttp( PHP_CLUB_FIND, tabData, response, PHP_POST )
end

-- 搜索联盟
function ClubAdd:searchUnion( searchType, searchValue )
	print("搜索联盟")
	local function response( data )
		dump(data)
		if data.code == 0 then
			if data.msg == "success" then
				local searchList = require('club.SearchList')
				local layer = searchList:create()
				self:addChild(layer)
				layer:createLayer(data.data, "union")
			elseif data.msg == "failed" then
				ViewCtrol.showTip({title = "联盟不存在", content = "没有找到相关联盟，请更换搜索条件再试。"})
			end
		end
	end
	local tabData = {}
	tabData["category"] = searchType
	tabData["club_id"] = ClubCtrol.getClubInfo().id
	tabData["search_key"] = searchValue
	XMLHttp.requestHttp("search_union", tabData, response, PHP_POST)
end

function ClubAdd:createLayer( target )
	_clubAdd = self
	_clubAdd:setSwallowTouches()
	

	ADD_TARGET = target
	if ADD_TARGET ~= "union_club" then
		_clubAdd:addTransitAction()
	end
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	user_id = Single:playerModel():getId()
	self:buildLayer()
	
end

return ClubAdd