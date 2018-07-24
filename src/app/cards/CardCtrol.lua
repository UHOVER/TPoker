local CardCtrol = {}

local cardScene = false

local cardList = {}

local clubInfo = {}

-- 请求牌局信息、俱乐部详情
function CardCtrol.dataStatClubInfo( funback )
	local function response( data )
		if data.code == 0 then

			CardCtrol.setClubInfo( data.data )
			funback()
		end
	end
	XMLHttp.requestHttp("club/tables", "", response, PHP_GET)
end

function CardCtrol.setClubInfo( data )
	clubInfo = data

	-- 分离出牌局
	local tmpTab = {}
	if data.tables then
		tmpTab = data.tables
	end
	CardCtrol.buildCardList( tmpTab )
end

function CardCtrol.getClubInfo(  )
	return clubInfo
end

-- 请求牌局列表
-- function CardCtrol.dataStatCard( funback )
-- 	local function response( data )
-- 		if data.code == 0 then
-- 			local tmpTab = {}
-- 			if data.data.tables then
-- 				tmpTab = data.data.tables
-- 			end
-- 			CardCtrol.buildCardList( tmpTab )
-- 			funback()
-- 		end
-- 	end
-- 	XMLHttp.requestHttp("club/tables", "", response, PHP_GET)
-- end

function CardCtrol.buildCardList( data )
	-- dump(data)
	cardList = {}
	if next(data) == nil then
		return cardList
	end
	for k,v in pairs(data) do
		-- print(k.."--------"..v.table_name.."---------" .. v.status)
		if v.status ~= 3 then
			table.insert(cardList, v)
		end
	end
end

function CardCtrol.getCardList(  )
	return cardList
end

function CardCtrol.setCardScene( isScene )
	cardScene = isScene
end

function CardCtrol.isCardScene(  )
	return cardScene
end

-- 更新本地牌局数据
function CardCtrol.updateCardList( gid )
	local CardList = require("cards.CardList")
	CardList.updateCardList( gid )
end

-- 获取弹出数据
function CardCtrol.popData( cardData, club_id )
	local function response( data )
		dump(data)
		if cardData.table_type == GAME_CLUB_SNG or cardData.table_type == GAME_CIRCLE_SNG or cardData.table_type == GAME_UNION_SNG then
			CardCtrol.popSureLayer( cardData.gid, data.data, club_id )
		end
	end
	local tabData = {}
	tabData["gid"] = cardData.gid
	XMLHttp.requestHttp("getSngInfo", tabData, response, PHP_POST)
end

-- 牌局授权带入确认
function CardCtrol.popSureLayer( gid, popInfo, club_id )
	local currScene = cc.Director:getInstance():getRunningScene()

	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 100))
	-- local layer = cc.Layer:create()
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=cc.size(display.width-100, 520), pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=layer})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	-- local bgSp2 = UIUtil.addImageView({image = "common/common_notify_bg1.png", touch=false, scale=true, size=cc.size(display.width-100, 400), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)

	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	UIUtil.addLabelArial("确认报名该SNG比赛", 36, cc.p(sp_w/2, sp_h-25), cc.p(0.5, 1), bgSp3):setColor(display.COLOR_WHITE)

	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(display.width-150, 320), pos=cc.p(sp_w/2, sp_h-80), ah =cc.p(0.5, 1), parent=bgSp3})

	-- 关闭
	local function closeLayer(  )
		layer:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/sng_cancel_normal.png", selImg = "common/sng_cancel_highlight.png", ah = cc.p(0, 0), pos = cc.p(40, 25), touch = true, listener = closeLayer, parent = bgSp3})

	-- 确认
	local function sureFunc(  )
		CardCtrol.entyrSNG( gid, club_id, popInfo )
		layer:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/sng_confirm_normal.png", selImg = "common/sng_confirm_highlight.png", ah = cc.p(1, 0), pos = cc.p(sp_w-40, 25), touch = true, listener = sureFunc, parent = bgSp3})

	-- 奖金
	local rewardSp = {}
	local rewardStr = {}
	-- local iconStr = {"first", "second", "third"}
	local rewardValue = {}
	for k,v in pairs(popInfo.Couple) do
		if v ~= "" then
			rewardValue[#rewardValue+1] = v
		end
	end

	local bg_sp = UIUtil.addImageView({image="common/com_opacity0.png", touch=false, scale=true, size=cc.size(#rewardValue*200,100), pos=cc.p(bgSp:getContentSize().width/2, bgSp:getContentSize().height-115), ah=cc.p(0.5,0), parent=bgSp})
	print(bg_sp:getContentSize().width)
	for j=1,#rewardValue do 
		local posX = (2*j-1)/(#rewardValue*2)
		rewardSp[j] = UIUtil.addPosSprite("common/h_" ..tostring(j)..".png", cc.p(bg_sp:getContentSize().width*posX, 50), bg_sp, cc.p(0.5, 0.5))
		rewardStr[j] = UIUtil.addLabelArial(rewardValue[j], 34, cc.p(bg_sp:getContentSize().width*posX, 9), cc.p(0.5, 1), bg_sp):setColor(font_color[j])
	end

	local titleStr = {"涨盲时间", "初始筹码", "报名费", "记录费"}
	local valueStr = {}
	for i=1,2 do
		for j=1,2 do
			local idx = (i-1)*2 +j
			UIUtil.addLabelArial(titleStr[idx]..":", 30, cc.p(30+(j-1)*300, bgSp:getContentSize().height/2-80-(i-1)*55), cc.p(0, 0), bgSp):setColor(display.COLOR_WHITE)
			valueStr[idx] = UIUtil.addLabelArial("10", 30, cc.p(160+(i-1)*300, bgSp:getContentSize().height/2-80-(j-1)*55), cc.p(0, 0), bgSp):setColor(display.COLOR_WHITE)
		end
	end
	local time = tostring(popInfo.increase_time/60).."分"
	valueStr[1]:setString(time)
	valueStr[2]:setString(popInfo.inital_score)
	valueStr[3]:setString(popInfo.entry_fee)
	valueStr[4]:setString(popInfo.cost)
	bgSp1:setScale(1.1)

	-- local seq = cc.Sequence:create(cc.FadeIn:create(0.1), cc.ScaleTo:create(0.2, 1))
	local spa = cc.Spawn:create(cc.FadeIn:create(0.1), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(spa)

	return layer
end

function CardCtrol.entyrSNG( gid, club_id, applyTab )
	
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			if data.data.is_enter == 1 then
				local GameScene = require 'game.GameScene'
				GameScene.startScene(gid)
			elseif data.data.is_enter == 0 then
				CardCtrol.showLayer( 1 )
			end
		end
	end
	local tabData = {}
	tabData["gid"] = gid
	if club_id then
		tabData["club_id"] = club_id
	end
	local isGPSPoker = false
	if tonumber(applyTab.open_gps) == 1 then
		isGPSPoker = true
	else
		isGPSPoker = false
	end
	Single:paltform():getLatitudeAndLongitude(function( j, w )
		tabData['longitude'] = j
		tabData['latitude'] = w
		XMLHttp.requestHttp("sngApply", tabData, response, PHP_POST)
	end, isGPSPoker)
	
end

function CardCtrol.showLayer( delay )
	if not delay then delay = 1 end

	local currScene = cc.Director:getInstance():getRunningScene()

	local tsize = cc.size(428,299)
	local bg = UIUtil.scale9Sprite(cc.rect(60,50,60,50), 'common/signup_tips.png', tsize, cc.p(display.cx, 0), currScene)
	bg:setLocalZOrder(StringUtils.getMaxZOrder(currScene))

   	local msgWin = UIUtil.addLabelArial("申请成功等待房主同意", 27, cc.p(tsize.width/2, tsize.height/2-70), cc.p(0.5,0.5), nil, cc.c3b(255,255,255))
   	bg:addChild(msgWin)

   	local move = cc.MoveTo:create(0.5, cc.p(display.cx, display.cy))
   	local delay = cc.DelayTime:create(delay)
   	local scale = cc.ScaleTo:create(0.5,0)
	local callfunc = cc.CallFunc:create(function()
		bg:removeFromParent()
		end)
   	local seq = cc.Sequence:create(move, delay, scale, callfunc)
   	bg:runAction(seq)
end

function CardCtrol.transTime( time )
	local T_second = nil
	local T_minute = nil
	local T_hour = nil
	local T_str = nil

	local time = tonumber(time)

	if time >= 60 then
		T_minute = time/60
		if T_minute >= 60 then
			T_hour = T_minute/60
			local n1, n2 = math.modf(T_hour)
			-- print(string.format("%2d,----------, %2f", n1, n2))

			local n3, n4 = math.modf(n2*60)
			T_str = string.format("%02d", n1)..":" .. string.format("%02d", n3)
		else
			local n1, n2 = math.modf(T_minute)
			-- print(string.format("%d, %f", n1, n2))
			T_str = "00:"..string.format("%02d", n1)
		end
	else
		T_str = "00:01"
	end
	return T_str

	--[[if time >= 60 then
		T_minute = time/60
		if T_minute >= 60 then
			T_hour = T_minute/60
			local n1, n2 = math.modf(T_hour)
			print(string.format("%2d,----------, %2f", n1, n2))

			local n3, n4 = math.modf(n2*60)
			T_str = string.format("%02d", n1).."小时" .. string.format("%02d", n3).."分钟"
			 -- .. ":"..string.format("%02d", n4*60)
		else
			local n1, n2 = math.modf(T_minute)
			print(string.format("%d, %f", n1, n2))
			T_str = "00小时"..string.format("%02d", n1).."分钟"
			 -- .. ":"..string.format("%02d", n2*60)
		end
	else
		T_str = "00小时01分钟"
		-- ..string.format("%02d", time)
	end
	
	return T_str--]]
end

function CardCtrol.transNum( num )
	local _num = tonumber(num)
	local str = ""
	if _num >= 10000 then
		str = tostring(_num/1000).."K"
	else
		str = tostring(_num)
	end
	return str
end

function CardCtrol.enterNOR( gid, club_id )
	-- 报名联盟标准局时选择一个俱乐部
	local GameScene = require 'game.GameScene'
	GData.setUclubId(club_id)
	GameScene.startScene(gid)
end

function CardCtrol.addSNGApply( cardData, funback )

	local currScene = cc.Director:getInstance():getRunningScene()

	local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, 100))
	layer:setPosition(cc.p(0,0))
	currScene:addChild(layer, StringUtils.getMaxZOrder(currScene))

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function ( touch, event )
		listener:setSwallowTouches(true)
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, layer)

	local bgSp1 = UIUtil.addImageView({image = "common/common_notify_bg.png", touch=false, scale=true, size=cc.size(display.width-100, display.height-340), pos=cc.p(display.cx, display.cy), ah =cc.p(0.5, 0.5), parent=layer})
	local sp_w = bgSp1:getContentSize().width
	local sp_h = bgSp1:getContentSize().height
	local bgSp3 = UIUtil.addImageView({image = "common/common_notify_bg2.png", touch=false, scale=true, size=cc.size(sp_w, sp_h), pos=cc.p(sp_w/2, sp_h/2), ah =cc.p(0.5, 0.5), parent=bgSp1})
	bgSp3:setLocalZOrder(10)
	local font_color = {cc.c3b(208, 193, 104), cc.c3b(202, 203, 205), cc.c3b(184, 117, 88)}

	UIUtil.addLabelArial("请选择进入比赛路径", 35, cc.p(sp_w/2, sp_h-20), cc.p(0.5, 1), bgSp3):setColor(display.COLOR_WHITE)

	local bgSp = UIUtil.addImageView({image = "common/common_sngpop_little_bg.png", touch=false, scale=true, size=cc.size(display.width-150, sp_h-100), pos=cc.p(sp_w/2, 25), ah =cc.p(0.5, 0), parent=bgSp3})

		-- 关闭
	local function closeLayer(  )
		layer:removeFromParent()
	end
	UIUtil.addImageBtn({norImg = "common/set_card_MTT_close.png", selImg = "common/set_card_MTT_close_height.png", ah = cc.p(0.5, 0.5), pos = cc.p(sp_w-20, sp_h-20), touch = true, listener = closeLayer, parent = bgSp3})

	local curData = {}
	curData = cardData.choose_clubs
	dump(curData)

	local function listViewEvent(sender, eventType)
		local tag = sender:getTag()
		local data = curData[tag]
		if cardData.table_type == GAME_UNION_STABDARD then
			CardCtrol.enterNOR( cardData.gid, data["club_id"] )
		elseif cardData.table_type == GAME_UNION_SNG then
			CardCtrol.popData( cardData, data["club_id"] )
		elseif cardData.table_type == GAME_UNION_MTT then
			local tab = {pokerId = cardData.gid, groupID = data["club_id"]}
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus( function (  )
				MttShowCtorl.MttSignUp(tab)
			end, tab )
		end
		layer:removeFromParent()
	end
	local listview = ccui.ListView:create()
	listview:setBounceEnabled(true)
	listview:setScrollBarEnabled(false)
	listview:setDirection(1)
	listview:setTouchEnabled(true)
	listview:setContentSize(cc.size(bgSp:getContentSize().width-20, bgSp:getContentSize().height-30))
	listview:setBackGroundImage(ResLib.COM_OPACITY0)
  	listview:setBackGroundImageScale9Enabled(true)
	listview:setAnchorPoint(0,0)
	listview:setPosition(cc.p(10, 15))
	bgSp:addChild(listview)
	
	for idx=1,#curData do
		local data = curData[idx]
		-- dump(data)
		local layout = ccui.Layout:create()
		local layoutH = 150
		layout:setContentSize(cc.size(bgSp:getContentSize().width-20, layoutH))
		layout:setPosition(cc.p(0,0))
		listview:pushBackCustomItem(layout)

		UIUtil.addImageView({image = "bg/bg_cell_line.png", touch=false, scale=true, size=cc.size(bgSp:getContentSize().width-20, layoutH),pos=cc.p(0,0), ah=cc.p(0,0), parent=layout})
		UIUtil.addImageBtn({norImg = "club/club_jinru_1.png", selImg = "club/club_jinru_2.png", disImg = "club/club_jinru_2.png", pos = cc.p(bgSp:getContentSize().width-40, layoutH/2), ah = cc.p(1, 0.5), swalTouch = true, touch = true,  listener = listViewEvent, parent = layout}):setTag(idx)

		local stencil, clubIcon = UIUtil.createCircle(ResLib.CLUB_HEAD_GENERAL, cc.p(70,  layoutH/2), layout, ResLib.CLUB_HEAD_STENCIL_200, 0.5)
		local url = data.club_avatar or ''
		local function funcBack( path )
			clubIcon:setTexture(path)
		end
		if url ~= "" then
			ClubModel.downloadPhoto(funcBack, url, true)
		end
		UIUtil.addNameByType({nameType = 1, nameStr = data.club_name, fontSize = 35, pos = cc.p(140, layoutH/2), parent = layout})
	end
	
	local seq = cc.Sequence:create(cc.ScaleTo:create(0.2, 0.7), cc.ScaleTo:create(0.2, 1))
	bgSp1:runAction(seq)

	return layer
end

-- MTT倒计时弹出点击进入
function CardCtrol.enterMtt( gid, groupId )
	local isCardList = CardCtrol.isCardScene()
	local CardScene = require("cards.CardScene")
	local tab = {}
	tab["pokerId"] = gid
	if groupId then
		tab["groupID"] = groupId
	end
	if isCardList then
		local MttShowCtorl = require("common.MttShowCtorl")
		MttShowCtorl.dataStatStatus( function (  )
			MttShowCtorl.MttSignUp(tab)
		end, tab )
	else
		CardScene:startScene(function (  )
			local MttShowCtorl = require("common.MttShowCtorl")
			MttShowCtorl.dataStatStatus( function (  )
				MttShowCtorl.MttSignUp(tab)
			end, tab )
		end)
	end
end

return CardCtrol