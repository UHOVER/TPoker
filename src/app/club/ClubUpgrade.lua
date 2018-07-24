local ViewBase = require("ui.ViewBase")
local ClubUpgrade = class("ClubUpgrade", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _clubUpgrade = nil
local curLv = nil
local dayValue = nil
local curLvCost = nil
local clubCount = nil

local function Callback(  )
	_clubUpgrade:removeTransitAction()
end

local function upgradeFun(  )
	print("升级俱乐部")
	local diamond = Single:playerModel():getPDiaNum()
	if tonumber(curLvCost) > tonumber(diamond) then
		ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "钻石数量不足,请先充值！"})
		return
	end
	local clubInfo = ClubCtrol.getClubInfo()
	local function response( data )
		if data.code == 0 then
			ClubCtrol.editClubInfo({club_id = clubInfo.id, level = curLv, users_limit = clubCount})
			local dia = tonumber(diamond) - tonumber(curLvCost)
			Single:playerModel():setPDiaNum(tostring(dia))
			ViewCtrol.showTick({content = "升级成功!"})

			local myEvent = cc.EventCustom:new("C_Event_update_ClubInfo")
			local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
			customEventDispatch:dispatchEvent(myEvent)
			Callback()
		end
	end
	local tab = {}
	tab['club_id'] = clubInfo.id
	tab['level'] = curLv
	tab['level_time'] = dayValue
	tab['diamond_sum'] = curLvCost
	ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = string.format("本次升级将花费%d钻石,继续请确认！", curLvCost), sureFunBack =function (  )
		XMLHttp.requestHttp("clubUpgrade", tab, response, PHP_POST)
	end})
end

function ClubUpgrade:buildLayer(  )
	local color = cc.c3b(165, 157, 157)

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "俱乐部升级", parent = self})
	-- 俱乐部信息
	local clubInfo = ClubCtrol.getClubInfo()

	-- bg
	local imageView = UIUtil.addImageView({image="club/club_layer_bg.png", touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})

	local levelInfo = {
					{level=1, clubNum=100, manaNum=2, agentNum=5, cost={0, 0, 0, 0}},
					{level=2, clubNum=150, manaNum=3, agentNum=8, cost={1200, 3600, 7200, 14400}},
					{level=3, clubNum=200, manaNum=4, agentNum=10, cost={2400, 7200, 14400, 28800}},
					{level=4, clubNum=250, manaNum=5, agentNum=12, cost={3600, 10800, 21600, 43200}},
					{level=5, clubNum=300, manaNum=6, agentNum=14, cost={4800, 14400, 28800, 57600}},
					{level=6, clubNum=500, manaNum=7, agentNum=16, cost={12800, 38400, 76800, 153600}},
					{level=7, clubNum=800, manaNum=8, agentNum=18, cost={16800, 50400, 100800, 201600}},
					{level=8, clubNum=1000, manaNum=9, agentNum=20, cost={18800, 56400, 112800, 225600}}
				}

	local levelBg1 = UIUtil.addPosSprite("club/club_level_bg1.png", cc.p(display.width/2, imageView:getContentSize().height-30), imageView, cc.p(0.5, 1))
	-- local title = {'等级', '俱乐部人数', '管理人数', '推广员数'}
	local title = {'等级', '俱乐部人数', '管理人数'}
	-- local _size = {0, 176, 185, 180}
	for i=1,9 do
		for j=1,3 do
			local posX = 237/2+(j-1)*237
			local posY = (levelBg1:getContentSize().height-33)-(i-1)*61
			local str = ''
			if i == 1 then
				str = title[j]
			else
				if j == 1 then
					str = 'Lv.'..levelInfo[i-1].level
				elseif j == 2 then
					str = levelInfo[i-1].clubNum
				elseif j == 3 then
					str = levelInfo[i-1].manaNum
				-- elseif j == 4 then
				-- 	str = levelInfo[i-1].agentNum
				end
			end
			UIUtil.addLabelArial(str, 30, cc.p(posX, posY), cc.p(0.5, 0.5), levelBg1)
		end
	end

	local levelBg2 = UIUtil.addPosSprite("club/club_level_bg2.png", cc.p(display.width/2, levelBg1:getPositionY()-levelBg1:getContentSize().height-30), imageView, cc.p(0.5, 1))
	local width2 = levelBg2:getContentSize().width
	local height2 = levelBg2:getContentSize().height
	local t1 = UIUtil.addLabelArial('提升等级', 30, cc.p(35, height2-35), cc.p(0, 0.5), levelBg2)
	local t2 = UIUtil.addLabelArial(clubInfo.users_limit..'人', 25, cc.p(t1:getPositionX()+t1:getContentSize().width+10, height2-35), cc.p(0, 0.5), levelBg2):setColor(ResLib.COLOR_GREY)
	local t3 = UIUtil.addLabelArial('剩余'..clubInfo.surplus..'天', 25, cc.p(t2:getPositionX()+t2:getContentSize().width+10, height2-35), cc.p(0, 0.5), levelBg2):setColor(ResLib.COLOR_GREY)

	local bgSpW = 260
	local bgSpH = 44
	local bgSp = UIUtil.addImageView({image = "club/team_edit_name_bg.png", touch=false, scale=true, size=cc.size(bgSpW, bgSpH), pos=cc.p(width2-35, height2-35), ah =cc.p(1, 0.5), parent=levelBg2})

	local level = tonumber(clubInfo.level) or 2		-- 当前等级
	if tonumber(clubInfo.level) <= 1 then
		level = 2
	end
	curLv = level
	local levelStr = UIUtil.addLabelArial('Lv.'..tostring(level), 30, cc.p(bgSpW/2, bgSpH/2), cc.p(0.5, 0.5), bgSp)

	local minusBtn = nil 	-- 加
	local plusBtn = nil 	-- 减
	local value1 = nil 		-- 升级费用label
	curLvCost = 0 	-- 升级费用
	dayValue = 30 	-- 当前升级天数
	local dayStr = {30, 90, 180, 360}  -- 升级天数表

	local function checkLevelCost( _lv, _day )
		-- print(string.format("lv: %d, day: %d", _lv, _day))
		local tab = levelInfo[tonumber(_lv)].cost
		clubCount = levelInfo[tonumber(_lv)].clubNum
		local cost = 0
		for i=1,#dayStr do
			if _day == dayStr[i] then
				cost = tab[i]
				break
			end
		end
		-- print("cost: "..cost)
		return cost
	end
	local function btnCallBack( sender )
		local tag = sender:getTag()
		print("tag: "..tag)
		if tag == 1 then
			if level > 2 then
				level = level-1
			end
		elseif tag == 2 then
			if level < 8 then
				level = level+1
			end
		end
		if level > 2 then
			minusBtn:setEnabled(true)
		else
			minusBtn:setEnabled(false)
		end
		if level < 8 then
			plusBtn:setEnabled(true)
		else
			plusBtn:setEnabled(false)
		end
		-- 修改等级
		levelStr:setString('Lv.'..tostring(level))
		curLv = level
		-- 修改对应费用
		curLvCost = checkLevelCost( level, dayValue )
		value1:setString(curLvCost)
	end

	minusBtn = UIUtil.addImageBtn({norImg = 'club/btn_minus1.png', selImg = 'club/btn_minus1.png', disImg = 'club/btn_minus2.png', ah = cc.p(0,0.5), pos = cc.p(5, bgSpH/2), touch = true, swalTouch = false, listener = btnCallBack, parent = bgSp}):setTag(1)

	plusBtn = UIUtil.addImageBtn({norImg = 'club/btn_plus1.png', selImg = 'club/btn_plus1.png', disImg = 'club/btn_plus2.png', ah = cc.p(1,0.5), pos = cc.p(bgSpW-5, bgSpH/2), touch = true, swalTouch = false, listener = btnCallBack, parent = bgSp}):setTag(2)
	if level > 2 then
		minusBtn:setEnabled(true)
	else
		minusBtn:setEnabled(false)
	end
	if level < 8 then
		plusBtn:setEnabled(true)
	else
		plusBtn:setEnabled(false)
	end

	UIUtil.addLabelArial('选择有效期', 30, cc.p(20, height2-120), cc.p(0, 0.5), levelBg2)

	local dayBtn = {}
	local function dayFunc( sender )
		local tag = sender:getTag()
		dayValue = tonumber(dayStr[tag])
		sender:setEnabled(false)
		for k,v in pairs(dayBtn) do
			if tag ~= v:getTag() then
				v:setEnabled(true)
			end
		end
		curLvCost = checkLevelCost( level, dayValue )
		value1:setString(curLvCost)
	end
	for i=1,4 do
		local label = cc.Label:createWithSystemFont(dayStr[i].."天", "Arial", 30)
		dayBtn[i] = UIUtil.controlBtn("bg/e_sBtnUn.png", "bg/e_sBtn.png", "bg/e_sBtn.png", label, cc.p(95+(i-1)*170, height2-200), cc.size(130,50), dayFunc, levelBg2)
		dayBtn[i]:setTitleColorForState(ResLib.COLOR_GREY, cc.CONTROL_STATE_NORMAL)
		dayBtn[i]:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_DISABLED)
		dayBtn[i]:setTag(i)
		if dayValue == dayStr[i] then
			dayBtn[i]:setEnabled(false)
		end
	end

	valStr1 = UIUtil.addLabelArial('升级费用', 36, cc.p(width2/2-150, height2/2-80), cc.p(0, 0.5), levelBg2):setColor(ResLib.COLOR_GREY)
	local diaSp1 = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(valStr1:getPositionX()+valStr1:getContentSize().width+58, valStr1:getPositionY()), levelBg2, cc.p(0, 0.5))

	curLvCost = checkLevelCost( level, dayValue )
	value1 = UIUtil.addLabelArial(curLvCost, 36, cc.p(diaSp1:getPositionX()+diaSp1:getContentSize().width+10, valStr1:getPositionY()), cc.p(0, 0.5), levelBg2)
	

	local valStr2 = UIUtil.addLabelArial('钻石余额', 36, cc.p(valStr1:getPositionX(), height2/2-140), cc.p(0, 0.5), levelBg2):setColor(ResLib.COLOR_GREY)
	local diaSp2 = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(valStr2:getPositionX()+valStr2:getContentSize().width+58, valStr2:getPositionY()), levelBg2, cc.p(0, 0.5))
	local diamond = Single:playerModel():getPDiaNum()
	local value2 = UIUtil.addLabelArial(diamond, 36, cc.p(diaSp2:getPositionX()+diaSp2:getContentSize().width+10, valStr2:getPositionY()), cc.p(0, 0.5), levelBg2)

	-- 升级
	local label = cc.Label:createWithSystemFont("升级", "Marker Felt", 30)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 50), cc.size(700,80), upgradeFun, self)
end

function ClubUpgrade:createLayer(  )
	_clubUpgrade = self
	_clubUpgrade:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	curLv = nil
	dayValue = nil
	curLvCost = nil
	clubCount = nil

	self:buildLayer()
end

return ClubUpgrade