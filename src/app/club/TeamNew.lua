local ViewBase = require("ui.ViewBase")
local TeamNew = class("TeamNew", ViewBase)
local ClubCtrol = require("club.ClubCtrol")
local MineCtrol = require('mine.MineCtrol')

local _teamNew = nil

local TAG_NEW = "new"
local TAG_EDIT = "edit"
local curTarget = nil

local teamData = {}
	
local stencil, teamIcon = nil, nil
local team_logo = nil

local teamName = nil
local team_name = nil

local function callBack(  )
	_teamNew:removeFromParent()
end

local function okCallback(  )
	print("完成")
	if team_logo == nil or team_logo == "" then
		ViewCtrol.showTip({content = "请您上传战队logo！"})
		return
	end
	if team_name == nil or team_name == "" then
		ViewCtrol.showTip({content = "请您输入战队名称！"})
		return
	end
	if curTarget == TAG_NEW then
		local function response( data )
			-- dump(data)
			if data.code == 0 then
				MineCtrol.editInfo({exist_team = data.data})
				_teamNew:removeFromParent()

				local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
				local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
				customEventDispatch:dispatchEvent(myEvent)
				
				local curScene = cc.Director:getInstance():getRunningScene()
				local message = curScene:getChildByName("message")
				local clubInfoPlus = message:getChildByName("clubInfoPlus")
				if clubInfoPlus then
					local teamAdd = require("club.TeamAdd"):create()
					clubInfoPlus:addChild(teamAdd)
					teamAdd:createLayer()
				end			
			end
		end
		local tabData = {}
		tabData["club_id"] = ClubCtrol.getClubInfo().id
		tabData["team_logo"] = team_logo
		tabData["team_name"] = team_name
		XMLHttp.requestHttp("create_team", tabData, response, PHP_POST)
	elseif curTarget == TAG_EDIT then
		local function response( data )
			dump(data)
			if data.code == 0 then
				ViewCtrol.showTick({content = "修改成功!"})
				
				MineCtrol.editTeamData( {team_logo = team_logo, team_name = team_name} )

				_teamNew:removeFromParent()
				local MineTeam = require("mine.MineTeam"):create()
				MineTeam.updateTeam()
			end
		end
		local tabData = {}
		tabData["team_id"] = teamData.team_id
		tabData["team_logo"] = team_logo
		tabData["team_name"] = team_name
		XMLHttp.requestHttp("update_team", tabData, response, PHP_POST)
	end
end

local function iconCallback(  )
	local function funcBack( iconName, iconPath )
		team_logo = iconName
		print(team_logo)
		_teamNew:buildIcon(iconPath)
	end
	ClubModel.buildPhoto( 0, funcBack, _teamNew )
end

function TeamNew:buildLayer(  )
	-- addTopBar
	UIUtil.addTopBar({backFunc = callBack, title = "创建战队", menuFont = "完成", menuFunc = okCallback, parent = self})

	local spHeight = display.height-130

	if curTarget == TAG_EDIT then
		teamData = MineCtrol.getTeamData()
		-- dump(teamData)
		team_logo = teamData.team_logo
		team_name = teamData.team_name
	end

	--俱乐部头像
	UIUtil.addLabelArial("战队logo", 30, cc.p(20, spHeight-36), cc.p(0, 1), self)

	stencil, teamIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.8, pos = cc.p(display.cx, spHeight-210), parent = self, nor = "club/team_add_logo.png", sel = "club/team_add_logo.png", listener = iconCallback})
	local function funcBack( iconPath )
		teamIcon:loadTextureNormal(iconPath)
		teamIcon:loadTexturePressed(iconPath)
		teamIcon:loadTextureDisabled(iconPath)
	end
	if team_logo ~= "" then
		ClubModel.downloadPhoto(funcBack, team_logo, true)
	end

	UIUtil.addLabelArial("战队标识", 30, cc.p(20, spHeight-400), cc.p(0, 1), self)
	UIUtil.addPosSprite("club/team_flag.png", cc.p(display.cx, spHeight-400), self, cc.p(0.5, 1))

	--战队名称
	UIUtil.addLabelArial("战队名称", 30, cc.p(20, spHeight-530), cc.p(0, 1), self)
	
	local nameBg = UIUtil.addImageView({image="club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(display.width-40, 90), ah=cc.p(0.5, 1), pos=cc.p(display.cx, spHeight-590), parent=self})
	local width = nameBg:getContentSize().width
	local height = nameBg:getContentSize().height

	teamName = UIUtil.addEditBox( nil, cc.size(display.width-80, 90), cc.p(width/2, height/2), '请输入战队名称(1-4个字)', nameBg ):setFontColor(display.COLOR_WHITE)
	teamName:setPlaceholderFontColor(ResLib.COLOR_GREY)
	teamName:setMaxLength(12)
	if team_name ~= "" then
		teamName:setText(team_name.."战队")
	end

	local function searchChildren(father)
		local children = father:getChildren()
		for i=1,#children do
			local child = children[ i ]
			child:setVisible(false)
			if child:getChildren() then
				searchChildren(child)
			end
		end
	end
	local function nameFunc( eventType, sender )
		if eventType == "began" then
			print("began")
			if team_name ~= "" then
				sender:setText(team_name)
				local editLabel = sender:getChildByTag(1999)
				if editLabel then
					editLabel:setVisible(false)
				end
				searchChildren(sender)
			end
		elseif eventType == "changed" then
			print("changed: "..sender:getText())
			-- if string.len(team_name) > 12 then
			--     sender:closeKeyboard()
			--     ViewCtrol.showTip({content = "战队名称不能超过"..tostring(12/3).."个汉字或12个字母、数字！"})
			-- end
		elseif eventType == "return" then
			print("return")
			local str = StringUtils.trim(sender:getText())
			if str ~= "" then
				if not cc.LuaHelp:IsGameName(str) or string.len(str) > 12 then
					ViewCtrol.showTip({content = "战队名称不能超过"..tostring(12/3).."个汉字或12个字母、数字！"})
				end
			end
			
			local lenStr = ""
			if string.len(str) > 12 then
			    lenStr = StringUtils.checkStrLength( str, 12 )
			else
			    lenStr = str
			end
			team_name = lenStr
			print("team_name: "..team_name)
			if team_name ~= "" then
				sender:setText(team_name.."战队")
			end
		end
	end
	teamName:registerScriptEditBoxHandler(nameFunc)--]]
	--[[local function nameFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = 12, content ="战队名称不能超过"..tostring(12/3).."个汉字或12个字母、数字！", funcBack = function(str)
			team_name = str
		end })
	end
	teamName:registerScriptEditBoxHandler(nameFunc)--]]

	--[[local text = UIUtil.createTextField("请输入战队名称(1-4个字)", 30, cc.size(display.width-80, 90), cc.p(20, 0), nameBg)
	text:setMaxLength(12)
	text:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	if team_name ~= "" then
		teamName:setString(team_name)
	end
	text:addEventListener(function ( sender, eventType )
		if eventType == ccui.TextFiledEventType.attach_with_ime then
			print("attach")
			if team_name ~= "" then
				text:setString(team_name)
			end
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
			print("detach")
			local str = StringUtils.trim(sender:getString())
			local lenStr = ""
			if string.len(str) > 12 then
			    lenStr = StringUtils.checkStrLength( str, 12 )
			else
			    lenStr = str
			end
			team_name = lenStr
			print("team_name: "..team_name)
			if team_name ~= "" then
				sender:setString(team_name.."战队")
				if not cc.LuaHelp:IsGameName(team_name) or string.len(team_name) > 12 then
					ViewCtrol.showTip({content = "战队名称不能超过"..tostring(12/3).."个汉字或12个字母、数字！"})
				end
			end
        elseif eventType == ccui.TextFiledEventType.insert_text then
			print("insert")
        elseif eventType == ccui.TextFiledEventType.delete_backward then
			print("delete")
        end
	end)--]]
end

function TeamNew:buildIcon( iconPath )
	teamIcon:loadTextureNormal(iconPath)
	teamIcon:loadTexturePressed(iconPath)
	teamIcon:loadTextureDisabled(iconPath)

	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	teamIcon:setScale(scaleX, scaleY)
end

function TeamNew:createLayer( target )
	_teamNew = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	TAG_NEW = "new"
	TAG_EDIT = "edit"
	curTarget = target
	teamData = {}

	stencil, teamIcon = nil, nil
	team_logo = ""
	teamName = nil
	team_name = ""

	self:buildLayer()
end

return TeamNew