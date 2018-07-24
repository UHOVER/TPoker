local ViewBase = require("ui.ViewBase")
local TeamAdd = class("TeamAdd", ViewBase)
local ClubCtrol = require("club.ClubCtrol")


local _teamAdd = nil

local function callBack(  )
	_teamAdd:removeFromParent()
end

function TeamAdd:buildLayer(  )
	UIUtil.addTopBar({backFunc = callBack, title = "创建成功", parent = self})

	local tmpTab = ClubCtrol.getClubInfo()

	local sizeH = {140, 100}

	local infoBg = {}
	local infoNode = {}
	local infoBgH = 0
	local infoW = 20 -- 左边距
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		infoNode[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, (display.height-130)- infoBgH), parent=self})

		local imageBg = ResLib.TABLEVIEW_CELL_BG
		local infoH = 0
		if sizeH[i] == 140 then
			infoH = sizeH[i]-40
			sizeH[i] = infoH
			local line = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(0, 100), ah=cc.p(0,0), parent=infoNode[i]})
			UIUtil.addLabelArial("添加队员", 28, cc.p(infoW, 20), cc.p(0, 0.5), line):setColor(ResLib.COLOR_GREY)
			UIUtil.addLabelArial("1人", 28, cc.p(display.width-20, 20), cc.p(1, 0.5), line):setColor(ResLib.COLOR_GREY)
		else
			infoH = sizeH[i]
		end
		infoBg[i] = UIUtil.addImageView({image = imageBg, touch=true, scale=true, size=cc.size(display.width, infoH), pos=cc.p(0, 0), parent=infoNode[i]})
		infoBg[i]:setSwallowTouches(true)
	end

	-- 队长
	local stencil, Icon = UIUtil.createCircle(ResLib.USER_HEAD, cc.p(60,sizeH[1]/2), infoBg[1], ResLib.CLUB_HEAD_STENCIL_200, 0.4)
	local url = tmpTab.creator_imgs
	local function funcBack( path )
		local rect = Icon:getContentSize()
		Icon:setTexture(path)
		Icon:setTextureRect(rect)
	end
	ClubModel.downloadPhoto(funcBack, url, true)

	local name = tmpTab.creator_info
	local teamName, team_icon = UIUtil.addNameByType({nameType = 5, nameStr = name, fontSize = 36, pos = cc.p(130, sizeH[1]/2), parent = infoBg[1]})
	teamName:setColor(display.COLOR_WHITE)
	UIUtil.addPosSprite("bg/zd_dz.png", cc.p(display.width-20, sizeH[1]/2), infoBg[1], cc.p(1, 0.5))

	-- 添加
	local function addCallBack(  )
		local tab = {team_id = tmpTab.exist_team, club_id = tmpTab.id}
		require('main.ZhanDuiG').showZhanDui(1, tab)
		_teamAdd:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah = cc.p(0,0.5), pos = cc.p(0, sizeH[2]/2), touch = true, swalTouch = false, scale9 = true, size = cc.size(display.width, sizeH[2]), listener = addCallBack, parent = infoBg[2]})
	
	local add = UIUtil.addPosSprite("club/team_add_icon.png", cc.p(22, sizeH[2]/2), infoBg[2], cc.p(0, 0.5))
	UIUtil.addLabelArial("添加战队队员", 30, cc.p(add:getPositionX()+add:getContentSize().width+20, sizeH[2]/2), cc.p(0, 0.5), infoBg[2])
end

function TeamAdd:createLayer(  )
	_teamAdd = self
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	self:buildLayer()
end

return TeamAdd