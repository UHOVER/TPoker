local ViewBase = require("ui.ViewBase")
local MineTeam = class("MineTeam", ViewBase)
local MineCtrol = require('mine.MineCtrol')

local _mineTeam = nil

local curTarget = nil

local teamData = {}

local imageView = nil

local teamInfo = nil

local function callBack(  )
	Notice.deleteMessage( 10 )
	_mineTeam:removeFromParent()
end

local function editCallback(  )
	local TeamNew = require("club.TeamNew")
	local layer = TeamNew:create()
	_mineTeam:addChild(layer)
	layer:createLayer("edit")
end

function MineTeam:buildLayer(  )

	if imageView then
		imageView:removeFromParent()
		imageView = nil
	end
	imageView = UIUtil.addImageView({image=ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height), pos=cc.p(0,0), parent=self})

	local menuStr = nil
	if curTarget == 2 then
		if teamData.team_leader == 1 then
			menuStr = "编辑"
		end
	end
	UIUtil.addTopBar({backFunc = callBack, title = "我的战队", menuFont = menuStr, menuFunc = editCallback, parent = imageView})

	if curTarget == 0 then 	-- 无战队
		UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.height*0.65), imageView, cc.p(0.5, 0.5))
		local str = "您尚未创建和加入任何战队\n\n请到俱乐部详情页面创建或加入战队!"
		local label = cc.Label:createWithSystemFont(str, "Arial", 35, cc.size(600, 500), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setTextColor(cc.c4b(153, 156, 158, 255))
		label:setPosition(cc.p(display.cx, display.cy-100))
		imageView:addChild(label)
	-- 加入别的战队
	elseif curTarget == 1 then
		dump(teamData)
		local data = teamData[1]
		UIUtil.addPosSprite("club/card_icon_face.png", cc.p(display.cx, display.height*0.65), imageView, cc.p(0.5, 0.5))
		local str = "您已经加入来自“"..data.club_name.."俱乐部”\n\n".."的“"..data.team_name.."战队”\n\n".."请先退出,再创建战队"
		local label = cc.Label:createWithSystemFont(str, "Arial", 35, cc.size(600, 500), cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		label:setTextColor(cc.c4b(153, 156, 158, 255))
		label:setPosition(cc.p(display.cx, display.cy-100))
		imageView:addChild(label)
	else 	-- 有的战队
		Notice.deleteMessage( 10 )
		if teamInfo then
			teamInfo:removeFromParent()
			teamInfo = nil
		end
		teamInfo = require('main.ZhanDui'):create(teamData)
		imageView:addChild(teamInfo)
	end
end

-- 修改战队
function MineTeam.updateTeam(  )
	if not _mineTeam then
		return
	end
	if teamInfo then
		teamInfo:removeFromParent()
		teamInfo = nil
		teamData = {}
	end
	teamData = MineCtrol.getTeamData()
	teamInfo = require('main.ZhanDui'):create(teamData)
	imageView:addChild(teamInfo)
end

-- 退出战队
function MineTeam.exitTeam(  )
	if not _mineTeam then
		return
	end
	curTarget = 0
	teamData = {}
	teamInfo = nil
	_mineTeam:buildLayer()
end

function MineTeam:createLayer( teamTag, data )
	_mineTeam = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	teamData = {}
	imageView = nil

	-- 0 为没有战队，不为0 战队详情
	curTarget = teamTag

	if data then
		teamData = data
	end

	teamInfo = nil

	self:buildLayer()
end

return MineTeam