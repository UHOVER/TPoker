local ViewBase = require("ui.ViewBase")
local SetCards = class("SetCards", ViewBase)
local SetModel = require("common.SetModel")
local SelectCtrol = require("common.SelectCtrol")
local SelectClub = require("common.SelectClub")
local _setCards = nil

local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 35

local STANDARD_NAME = nil
local SNG_NAME 		= nil
local MTT_NAME 		= nil

local imageView = nil

local norBtn = nil
local sngBtn = nil
local CARD_TARGET = nil

local curNode = nil

-- 创建者id
local org_id = nil
-- 牌局创建类型
	-- general 个人标准、 sng 个人sng
	-- 21 俱乐部标准、22 俱乐部sng
	-- 31 圈子标准 32 圈子sng
	-- 41 联盟标准 42 联盟sng
local CARD_TYPE = {
			person 	= {NOR = GAME_TYPE_STANDARD,	SNG = GAME_TYPE_SNG, 	MTT = GAME_TYPE_MTT		},
			club 	= {NOR = GAME_CLUB_STABDARD,	SNG = GAME_CLUB_SNG, 	MTT = GAME_CLUB_MTT		},
			circle 	= {NOR = GAME_CIRCLE_STABDARD,	SNG = GAME_CIRCLE_SNG, 	MTT = GAME_CIRCLE_MTT	},
			union 	= {NOR = GAME_UNION_STABDARD,	SNG = GAME_UNION_SNG, 	MTT = GAME_UNION_MTT	}
		}


--[[   创建普通牌局   ]]

-- 牌局名称
local card_name = nil

local name_str = nil

-- 授权报名（0表示不授权，1表示授权）
local is_access = nil

-- 牌局时间
local cTime = nil

-- 牌局人数
local peopleNum = nil

-- ante
local anteNum = nil

local gameModel = nil

-- 大盲
local big_blind = nil

-- 带入记分牌
local scores_num = nil

-- 记录费
local record_num = nil

-- straddle限制
local openStraddle = nil

-- ip限制
local openIP = nil

-- gps限制
local openGPS = nil

-- 联盟分享的俱乐部
local shareClubs = {}

-- 消耗钻石
local diamonds = nil

--[[   创建SNG牌局   ]]

-- 报名费
local entry_fee = nil
local _entryFee = nil

-- 起始记分牌
local inital_score = nil

-- 升盲时间
local increase_time = nil

-- 参赛人数
local limit_players = nil

local _retData = nil

-- [[	创建MTT		]]
-- UI
local scrollView_MTT = nil
local layer_MTT = nil
local popStopLevel = nil

local keepLabel = nil
local keepSlider = nil

-- 起始盲注
local orgBlindStr = nil
local orgBlindSlider = nil
local blindBox = {}
local blindLabel = {}

-- DATA
-- MTT牌局模式
local mtt_type = nil

-- 总奖池金额
local awards_count = nil

-- 保底人数
local keep_count = nil

-- 开赛时间
local play_time = nil

local publicGame = nil

-- 终止报名级别
local entry_stop = nil

-- 0表示关闭
-- 重构次数
local buy_count = nil

-- 增购次数
local add_count = nil

-- 中场休息时间
local half_time = nil

-- 赛事简介
local mttDes = nil

-- 起始盲注级别
local orgBlind = nil

-- 盲注表类型
local blindType = nil

-- 人数上限
local limitPlayer = nil

-- 奖励范围
local awardScale = nil

-- 开启战队PK
local isTeam = nil

local function showGroup()
	local mod = nil
	if CARD_TARGET == "club" then
		mod = StatusCode.CHAT_CLUB
	elseif CARD_TARGET == "circle" then
		mod = StatusCode.CHAT_CIRCLE
	end
	DZChat.checkChat(org_id, mod)
end


local function Callback(  )
	-- _setCards:clearData()
	_setCards:removeFromParent()

	SelectCtrol.setSelectClub({})

	if CARD_TARGET == "club" or CARD_TARGET == "circle" then
		showGroup()
	elseif CARD_TARGET == "person" then
		local MainLayer = require 'main.MainLayer'
		MainLayer:switchBuild(org_id, MainLayer:getSpPanel())
	end
end

function SetCards:buildLayer(  )
	-- topBar
	UIUtil.addTopBar({backFunc = Callback, title = "建立牌局", parent = self})

	local pId = Single:playerModel():getId()
	print("---------------------: "..pId)
	print(string.format("STANDARD_NAME: %s, SNG_NAME: %s, MTT_NAME: %s", STANDARD_NAME, SNG_NAME, MTT_NAME))

	imageView = UIUtil.addImageView({touch=false, scale=true, size=cc.size(display.width, display.height-130), parent=self})
	local width = imageView:getContentSize().width
	local height = imageView:getContentSize().height

	local buildCard_icon = {}
	buildCard_icon = {
					{normal = "set_card_normal.png", height = "set_card_normal_height.png"},
					{normal = "set_card_SNG.png", height = "set_card_SNG_height.png"},
					{normal = "set_card_MTT.png", height = "set_card_MTT_height.png"}
				}
	local buildCard_btn = {}
	local function buildCardFunc( sender )
		local tag = sender:getTag()
		for k,v in pairs(buildCard_btn) do
			if tag ~= v:getTag() then
				v:setTouchEnabled(true)
				v:setBright(true)
			end
		end
		sender:setTouchEnabled(false)
		sender:setBright(false)
		
		self:clearData()

		if tag == 1 then
			self:buildNormalCards(imageView)
		elseif tag == 2 then
			self:buildSNGCards(imageView)
		else
			self:buildMTTCards(imageView)
		end
	end

	for i=1,3 do
		buildCard_btn[i] = UIUtil.addImageBtn({norImg = "common/"..buildCard_icon[i].normal, selImg = "common/"..buildCard_icon[i].height, disImg = "common/"..buildCard_icon[i].height, ah = cc.p(0, 1), pos = cc.p((i-1)*250, height), scale9 = true, size = cc.size(250,91), touch = true, listener = buildCardFunc, parent = imageView})
		buildCard_btn[i]:setTag(i)
		buildCard_btn[i]:setLocalZOrder(5)
	end
	

	if CARD_TARGET == "person" then
		buildCard_btn[org_id]:setTouchEnabled(false)
		buildCard_btn[org_id]:setBright(false)
		if org_id == 1 then
			self:buildNormalCards(imageView)
		elseif org_id == 2 then
			self:buildSNGCards(imageView)
		else
			self:buildMTTCards(imageView)
		end
	else
		buildCard_btn[1]:setTouchEnabled(false)
		buildCard_btn[1]:setBright(false)

		self:buildNormalCards(imageView)
	end	
end

-- [[@@@@@@@@@@@@@@@ 标准牌局 @@@@@@@@@@@@@@@@@@]]

function SetCards:buildNormalCards( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local posH = display.height-230
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	local sizeH = {700, 104, 104, 104, 104, 104}
	if CARD_TARGET == "union" then
		-- sizeH = {700, 104, 104, 104, 104, 104, 104}
		sizeH[3] = 0
	end
	local viewH = 0
	for i=1,#sizeH do
		viewH = viewH + sizeH[i]
	end
	viewH = viewH+30
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, posH-100), innerSize=cc.size(display.width, viewH), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,100), parent=curNode} )
	scrollView:setScrollBarEnabled(false)

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, viewH), pos=cc.p(0,0), parent=scrollView})

	local infoW = 20
	local infoBg = {}
	local infoBgH = 0
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		-- TABLEVIEW_CELL_BG
		-- BTN_GREEN_NOR
		-- COM_OPACITY0
		infoBg[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, viewH-infoBgH), ah=cc.p(0,0), parent=layer})
		if sizeH[i] == 0 then
			infoBg[i]:setVisible(false)
		end
	end

	diamonds = 30

	card_name = Storage.getStringForKey(STANDARD_NAME) or ""
	if card_name == nil or card_name == "" then
		name_str = "牌局名称("..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字)"
	end

	local editBg = UIUtil.addImageView({image = "common/com_name_edit.png", touch=false, scale=true, size=cc.size(display.width-50, 98), pos=cc.p(display.width/2, sizeH[1]-110 ), ah=cc.p(0.5,0), parent=infoBg[1]})
	local cardName = UIUtil.addEditBox(nil, cc.size(display.width-70, 98), cc.p(editBg:getContentSize().width/2, editBg:getContentSize().height/2), name_str, editBg )
	-- cardName:setFontColor(cc.c3b(100, 125, 165))
	cardName:setPlaceholderFontColor(cc.c3b(91, 146, 255))
	cardName:setFontSize(36)
	cardName:setMaxLength(LEN_CARD)
	if card_name ~= "" then
		cardName:setText(card_name)
	end
	
	local function editFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_CARD, content ="牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！", funcBack = function(str)
			card_name = str
			Storage.setStringForKey(STANDARD_NAME, card_name, true)
		end }, true )
	end
	cardName:registerScriptEditBoxHandler(editFunc)

	local color_yellow = cc.c3b(204, 204, 204)
	
	-- local spBg = UIUtil.addImageView({image="common/com_grey_block.png", touch=false, scale=true, size=cc.size(display.width, 500), pos=cc.p(0, posH - 580 ), parent=curNode})

	local spBg = infoBg[1]
	-- 大盲、小盲
	local bind_str = UIUtil.addLabelArial('盲注:', 30, cc.p(infoW, editBg:getPositionY()-66), cc.p(0, 0.5), spBg)
	bind_str:setColor(ResLib.COLOR_GREY)
	-- 大盲值
	if CARD_TARGET == "person" then
		big_blind = MainCtrol.getBuildBigBlind()
	else
		big_blind = 2
	end
	local binds = UIUtil.addLabelArial('1/2', 30, cc.p(bind_str:getPositionX()+bind_str:getContentSize().width+10, editBg:getPositionY()-66), cc.p(0, 0.5), spBg)
	binds:setColor(color_yellow)

	-- 带入记分牌
	local scores_str = UIUtil.addLabelArial('带入记分牌:', 30, cc.p(display.width-170, editBg:getPositionY()-66), cc.p(1, 0.5), spBg)
	scores_str:setColor(ResLib.COLOR_GREY)
	scores_num = 200
	local scores = UIUtil.addLabelArial(scores_num, 30, cc.p(display.width-75, editBg:getPositionY()-66), cc.p(1, 0.5), spBg)
	scores:setColor(color_yellow)

	-- 记录费
	local record_str = UIUtil.addLabelArial('记录费:', 30, cc.p(display.width-160, bind_str:getPositionY()-86), cc.p(1, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local record = UIUtil.addLabelArial("20", 30, cc.p(display.width-75, bind_str:getPositionY()-86), cc.p(1, 0.5), spBg):setColor(color_yellow)

	local arr = MainCtrol.getSliderArray(StatusCode.BUILD_STANDARD)
	-- ante
	local anteArr = DZConfig.getAnte()
	local anteData = {}
	for i,v in ipairs(anteArr) do
		if v <= (big_blind/2) then
			anteData[#anteData+1] = v
		end
	end
	local tsliderAnte = nil
	local anteSp = nil

	-- 联盟
	local btnStr1 = nil
	local btnSp = nil
	local btnStr2 = nil

	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
        local cdata = arr[ idx ]
        
        -- 大盲
        local d_cdata = cdata
        if d_cdata >= 10000 then
        	d_cdata = tostring( d_cdata/1000 ).."K"
        end
        local s_binds = cdata/2
        if s_binds >= 10000 then
        	s_binds = tostring(s_binds/1000).."K"
        end
        local str = s_binds .. "/" .. d_cdata
        binds:setString(str)

        -- 联盟
        if CARD_TARGET == "union" then
        	diamonds = 30
        	if (cdata/2) == 1 then
        		btnStr1:setString("现在开局（"..tostring(30))
        		diamonds = 30
        	elseif (cdata/2) == 2 then
        		btnStr1:setString("现在开局（"..tostring(60))
        		diamonds = 60
        	elseif (cdata/2) == 5 then
        		btnStr1:setString("现在开局（"..tostring(120))
        		diamonds = 120
        	elseif (cdata/2) >= 10 then
        		btnStr1:setString("现在开局（"..tostring(200))
        		diamonds = 200
        	end
        	-- diamonds = tonumber(btnStr1:getString())
        	btnStr1:setPositionX(700/2-36)
        	btnSp:setPositionX(btnStr1:getPositionX()+btnStr1:getContentSize().width/2)
        	btnStr2:setPositionX(btnSp:getPositionX()+btnSp:getContentSize().width)
        end

        -- 带入记分牌
        local bindStr = cdata * 100
        scores_num = bindStr
        if bindStr >= 10000 then
        	bindStr = tostring(bindStr/1000).."K"
        end
        scores:setString(bindStr)

		record_num = scores_num * 10/100
		if record_num >= 10000 then
        	record_num = tostring(record_num/1000).."K"
        end

		record:setString(record_num)

        -- 大盲
        big_blind = cdata
        MainCtrol.setBuildBigBlind(big_blind)

        -- 前注
  --       if big_blind <= 2 then
		-- 	tsliderAnte:setEnabled(false)
		-- 	anteSp:setVisible(true)
		-- else
		-- 	tsliderAnte:setEnabled(true)
		-- 	anteSp:setVisible(false)
		-- end
		anteData = {}
		for i,v in ipairs(anteArr) do
			if v <= (big_blind/2) then
				anteData[#anteData+1] = v
			end
		end
		-- dump(anteData)
		tsliderAnte:setMaximumValue(#anteData+0.9)
		tsliderAnte:setValue(1.1)
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #arr + 0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2,bind_str:getPositionY()-48), spBg, sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)

	-- 人数设置
	peopleNum = 9
	local peopleLabel = UIUtil.addLabelArial("人数设置:", 30, cc.p(infoW, tslider:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local peopleStr = UIUtil.addLabelArial(peopleNum, 30, cc.p(peopleLabel:getPositionX()+peopleLabel:getContentSize().width+10, tslider:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(color_yellow)
	local layer1, ttime1, tslider  = DZUi.addUISlider(spBg, DZUi.SLIDER_CARD_EIGHT, cc.p(display.width/2,peopleLabel:getPositionY()-48), function(val)
			peopleNum = val
			print(val)
			peopleStr:setString(peopleNum)
		end, peopleNum)
	tslider:setValue(100)

	-- Ante
	anteNum = 0
	local anteLabel = UIUtil.addLabelArial("Ante:", 30, cc.p(infoW, layer1:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local anteStr = UIUtil.addLabelArial("0", 30, cc.p(anteLabel:getPositionX()+anteLabel:getContentSize().width+10, layer1:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(color_yellow)
	
	local function sliderAnte( sender )
		if #anteData == 0 then
			return
		end
		local idx = math.floor(sender:getValue())
		-- print("idx: "..idx)
		-- dump(anteData)
        local cdata = anteData[idx]
		anteNum = cdata
		anteStr:setString(anteNum)
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #anteData+0.9
	tsliderAnte = UIUtil.addSlider(imgs, cc.p(display.width/2,anteLabel:getPositionY()-48), spBg, sliderAnte, 1.1, maxLen)
	tsliderAnte:setAnchorPoint(0.5,0.5)
	-- anteSp = UIUtil.addPosSprite("main/main_thumb_grey.png", cc.p(0,tsliderAnte:getContentSize().height/2), tsliderAnte, cc.p(0.5, 0.5))
	-- if big_blind <= 2 then
	-- 	tsliderAnte:setEnabled(false)
	-- 	anteSp:setVisible(true)
	-- else
	-- 	anteSp:setVisible(false)
	-- end
	
	-- 牌局时长
	local timeLabel = UIUtil.addLabelArial("牌局时长:", 30, cc.p(infoW, tsliderAnte:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local timeStr = UIUtil.addLabelArial("0.5h", 30, cc.p(timeLabel:getPositionX()+timeLabel:getContentSize().width+10, tsliderAnte:getPositionY()-92), cc.p(0, 0.5), spBg):setColor(color_yellow)
	local layer1, ttime1 = DZUi.addUISlider(spBg, DZUi.SLIDER_CARD_TEN, cc.p(display.width/2,timeLabel:getPositionY()-48), function(val)
			cTime = val
			print(val)
			timeStr:setString(cTime.."h")
		end, cTime)

	-- 游戏模式
	local gameMod_str = UIUtil.addLabelArial('游戏模式:', 30, cc.p(infoW, sizeH[2]/2), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
	local gameModStr = {"标准", "保险"}
	local gameModBtn = {}
	local function gameModFunc( sender )
		local tag = sender:getTag()
		sender:setEnabled(false)
		gameModel = tonumber(tag-1)
		for k,v in pairs(gameModBtn) do
			if tag ~= v:getTag() then
				v:setEnabled(true)	
			end
		end
	end
	for i=1,2 do
		local label = cc.Label:createWithSystemFont(gameModStr[i], "Marker Felt", 30)
		local btn_str = ResLib.BTN_BLUE_BORDER
		gameModBtn[i] = UIUtil.controlBtn("bg/e_sBtnUn.png", "bg/e_sBtn.png", "bg/e_sBtn.png", label, cc.p(display.width/2+50+(i-1)*150, sizeH[2]/2), cc.size(100,50), gameModFunc, infoBg[2])
		gameModBtn[i]:setTitleColorForState(ResLib.COLOR_GREY, cc.CONTROL_STATE_NORMAL)
		gameModBtn[i]:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_DISABLED)
		gameModBtn[i]:setTag(i)
	end
	gameModel = 0
	gameModBtn[1]:setEnabled(false)

	-- 盲注结构
	local function bindsStru(  )
		local dlg = require("main/HelpDlg"):create(5)
		self:addChild(dlg)
	end
	UIUtil.addImageBtn({norImg = "common/set_card_MTT_ask.png", selImg = "common/set_card_MTT_ask.png", disImg = "common/set_card_MTT_ask.png", ah =cc.p(1, 0.5), pos = cc.p(display.width-20, sizeH[2]/2), touch = true, listener = bindsStru, parent = infoBg[2]})

	-- 授权带入
	is_access = 0
	local label = UIUtil.addLabelArial('授权参赛:', 30, cc.p(infoW, sizeH[3]/2), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	local function togMenuFunc( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			is_access = 1
		else
			print("off")
			is_access = 0
		end
	end
	local switch = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[3]/2), listener = togMenuFunc, parent = infoBg[3]})
	switch:setSelectedIndex(1)
	switch:setAnchorPoint(cc.p(1, 0.5))

	--	Straddle
	local straddle_str = UIUtil.addLabelArial('Straddle:', 30, cc.p(infoW, sizeH[4]-20), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)
	local straBox = {}
	local straLabel = {}
	local function straBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			straLabel[tag]:setColor(ResLib.COLOR_BLUE)
			if tag == 1 then
				openStraddle = 1
				if straBox[2]:isSelected() then
					straBox[2]:setSelectedState(false)
					straLabel[2]:setColor(ResLib.COLOR_GREY)
				end
			elseif tag == 2 then
				openStraddle = 2
				if straBox[1]:isSelected() then
					straBox[1]:setSelectedState(false)
					straLabel[1]:setColor(ResLib.COLOR_GREY)
				end
			end
		else
			straLabel[tag]:setColor(ResLib.COLOR_GREY)
			openStraddle = 0
		end
	end
	local straddleStr = {"强制Straddle", "自由Straddle"}
	for i=1,2 do
		straBox[i] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_1.png", checkBtn = "common/com_checkBox_1_1.png", ah = cc.p(0, 0.5), pos = cc.p(infoW+(i-1)*400, sizeH[4]/2-20), checkboxFunc = straBoxFunc, parent = infoBg[4]}):setTag(i)
		straLabel[i] = UIUtil.addLabelArial(straddleStr[i], 30, cc.p(70+(i-1)*400, sizeH[4]/2-20), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)
	end

	-- IP/GPS限制
	local ipgpsLabel = {}
	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			ipgpsLabel[tag]:setColor(ResLib.COLOR_BLUE)
			if tag == 1 then
				openIP = 1
			elseif tag == 2 then
				openGPS = 1
			end
		else
			ipgpsLabel[tag]:setColor(ResLib.COLOR_GREY)
			if tag == 1 then
				openIP = 0
			elseif tag == 2 then
				openGPS = 0
			end
		end
	end
	local str = {"IP限制", "GPS限制"}
	for i=1,2 do
		UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(infoW+(i-1)*400, sizeH[5]/2), checkboxFunc = checkBoxFunc, parent = infoBg[5]}):setTag(i)
		ipgpsLabel[i] = UIUtil.addLabelArial(str[i], 30, cc.p(70+(i-1)*400, sizeH[5]/2), cc.p(0, 0.5), infoBg[5]):setColor(ResLib.COLOR_GREY)
	end

	-- 赛事分享
	--[[
	if CARD_TARGET == "union" then
		SelectCtrol.setSelectClub({})
		local balance_str = UIUtil.addLabelArial('赛事分享:', 30, cc.p(infoW, sizeH[6]/2), cc.p(0, 0.5), infoBg[6]):setColor(ResLib.COLOR_GREY)
		local selectNum = nil
		local selectTile = nil
		local iconClub = nil

		local function updateSelectNum(  )
			local tab = SelectCtrol.getSelectClub()
			selectNum:setString("("..tostring(#tab)..")")
			selectTile:setPositionX(selectNum:getPositionX()-selectNum:getContentSize().width)
			iconClub:setPositionX(selectTile:getPositionX()-selectTile:getContentSize().width)
		end

		local function selectClub(  )
			SelectCtrol.dataStatUnionMember(function(  )
				local SelectClub = require("common.SelectClub")
				local layer = SelectClub:create()
				_setCards:addChild(layer, 10)
				layer:createLayer(updateSelectNum)
			end)
		end
		local selectBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah =cc.p(1, 0.5), pos = cc.p(display.width-20, sizeH[6]/2), touch = true, scale9=true, size = cc.size(display.width/2, sizeH[6]), listener = selectClub, parent = infoBg[6]})

		local iconR = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(selectBtn:getContentSize().width, sizeH[6]/2), selectBtn, cc.p(1, 0.5))
		selectNum = UIUtil.addLabelArial('（0）', 26, cc.p(iconR:getPositionX()-iconR:getContentSize().width, sizeH[6]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_GREY)
		selectTile = UIUtil.addLabelArial('选择俱乐部', 30, cc.p(selectNum:getPositionX()-selectNum:getContentSize().width, sizeH[6]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_BLUE)
		iconClub = UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL, cc.p(selectTile:getPositionX()-selectTile:getContentSize().width, sizeH[6]/2), selectBtn, cc.p(1, 0.5))
	end
	--]]

	-- 记分牌余额
	local balanceH = sizeH[6]
	local balanceBg = infoBg[6]
	if sizeH[7] then
		balanceH = sizeH[7]
		balanceBg = infoBg[7]
	end
	local balance_str = UIUtil.addLabelArial('记分牌余额:', 30, cc.p(infoW, balanceH/2), cc.p(0, 0.5), balanceBg):setColor(ResLib.COLOR_GREY)

	local text1 = Single:playerModel():getPBetNum()
	local balance = UIUtil.addLabelArial(text1, 30, cc.p(balance_str:getPositionX()+balance_str:getContentSize().width+10, balanceH/2), cc.p(0, 0.5), balanceBg):setColor(color_yellow)

	local function beginCards(  )
		if not is_access then
			is_access = 1
		end
		if not cTime then
			cTime = 0.5
		end
		if not big_blind then
			big_blind = 2
		end

		self:beginNormalCards()
	end
	-- ]]
	
	local label = cc.Label:createWithSystemFont("", "Arial", 38)
	-- local btn_str = ResLib.BTN_BLUE_GREY_BORDER
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 60), cc.size(700,80), beginCards, curNode)

	if CARD_TARGET == "union" then
		btnStr1 = UIUtil.addLabelArial("现在开局（"..tostring(diamonds), 38, cc.p(btn:getContentSize().width/2-36, btn:getContentSize().height/2), cc.p(0.5, 0.5), btn)
		btnSp = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(btnStr1:getPositionX()+btnStr1:getContentSize().width/2,btnStr1:getPositionY()), btn, cc.p(0, 0.5))
		btnStr2 = UIUtil.addLabelArial("）", 38, cc.p(btnSp:getPositionX()+btnSp:getContentSize().width, btnStr1:getPositionY()), cc.p(0, 0.5), btn)
	else
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_NORMAL)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_HIGH_LIGHTED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_DISABLED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_SELECTED)
	end
end

-- [[@@@@@@@@@@@@@@@  SNG牌局  @@@@@@@@@@@@@@]]

function SetCards:buildSNGCards( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local posH = display.height-230
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	local infoW = 20
	local infoBg = {}
	local sizeH = {600, 100, 100, 100, 100}
	if CARD_TARGET == "union" then
		sizeH = {600, 100, 100, 100, 100, 100}
	end

	local viewH = 0
	for i=1,#sizeH do
		viewH = viewH + sizeH[i]
	end
	viewH = viewH+30
	print("viewH: "..viewH)
	print("posH: "..posH)
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, posH-100), innerSize=cc.size(display.width, viewH), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 0), bounce=true, pos=cc.p(0,100), parent=curNode} )
	scrollView:setScrollBarEnabled(false)
	if CARD_TARGET ~= "union" then
		scrollView:setTouchEnabled(false)
	end

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, viewH), pos=cc.p(0,0), parent=scrollView})

	local infoBgH = 0
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		-- TABLEVIEW_CELL_BG
		-- BTN_GREEN_NOR
		infoBg[i] = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width, sizeH[i]), pos=cc.p(0, viewH-infoBgH), parent=layer})
	end

	diamonds = 10
	card_name = Storage.getStringForKey(SNG_NAME) or ""
	if card_name == nil or card_name == "" then
		name_str = "牌局名称("..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字)"
	end

	local editBg = UIUtil.addImageView({image = "common/com_name_edit.png", touch=false, scale=true, size=cc.size(display.width-50, 98), pos=cc.p(display.width/2, sizeH[1]-15 ), ah=cc.p(0.5,1), parent=infoBg[1]})

	local cardName = UIUtil.addEditBox(nil, cc.size(display.width-70, 98), cc.p(editBg:getContentSize().width/2, editBg:getContentSize().height/2), name_str, editBg )
	-- cardName:setFontColor(cc.c3b(100, 125, 165))
	cardName:setPlaceholderFontColor(cc.c3b(91, 146, 255))
	cardName:setFontSize(36)
	cardName:setMaxLength(LEN_CARD)
	if card_name ~= "" then
		cardName:setText(card_name)
	end
	
	local function editFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_CARD, content ="牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！", funcBack = function(str)
			card_name = str
			Storage.setStringForKey(SNG_NAME, card_name, true)
		end }, true )
	end
	cardName:registerScriptEditBoxHandler(editFunc)

	-- 人数限制
	-- self:addLimitBtn("sng", editBg)

	-- com_buybg com_grey_block
	-- local spBg = UIUtil.addImageView({image="common/com_grey_block.png", touch=false, scale=true, size=cc.size(display.width, 400), pos=cc.p(0, posH - 470 ), parent=curNode})

	local color_yellow = cc.c3b(204, 204, 204)

	local spBg = infoBg[1]
	local spBgH = 500

	-- 报名费
	local fee = DZConfig.buildSng()
	local str_1 = 0
	if CARD_TARGET == "person" then
		str_1 = MainCtrol.getBuildSngFee()
	else
		str_1 = fee[1]
	end
	local str_2 = str_1 * 10/100
	entry_fee = str_1 + str_2
	_entryFee = str_1
	local bind_str = UIUtil.addLabelArial("报名费:", 30, cc.p(infoW, spBgH - 50), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local bind_label = UIUtil.addLabelArial(str_1 .. "+" .. str_2, 30, cc.p(bind_str:getPositionX()+bind_str:getContentSize().width+10, spBgH - 50), cc.p(0, 0.5), spBg):setColor(color_yellow)
	
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		local fee_1 = fee[idx]
		local fee_2 = fee_1 * 10/100

		bind_label:setString(fee_1.."+"..fee_2)

		entry_fee = fee_1 + fee_2
		_entryFee = fee_1
		MainCtrol.setBuildSngFee(_entryFee)
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #fee + 0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2, spBgH - 110), spBg, sliderChange, 1.1, maxLen)
	-- tslider:setScale(0.95)
	tslider:setAnchorPoint(0.5,0.5)

	local sngUpTime = DZConfig.getSngUpTimes()
	increase_time = sngUpTime[1]
	local bind_timeStr = UIUtil.addLabelArial("升盲时间:", 30, cc.p(infoW, 300), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local bind_time = UIUtil.addLabelArial(increase_time.."分钟", 30, cc.p(bind_timeStr:getPositionX()+bind_timeStr:getContentSize().width+10, 300), cc.p(0, 0.5), spBg):setColor(color_yellow)
	-- 升盲时间
	local layer1, ttime1 = DZUi.addUISlider(spBg, DZUi.SLIDER_CARD_FIVE, cc.p(display.width/2,240), function(val)
			increase_time = val
			print(val)
			bind_time:setString(increase_time .. "分钟")
		end, increase_time)

	inital_score = 30
	local start_scoresStr = UIUtil.addLabelArial("起始记分牌:", 30, cc.p(infoW, 140), cc.p(0, 0.5), spBg):setColor(ResLib.COLOR_GREY)
	local start_scores = UIUtil.addLabelArial(tostring(inital_score*20), 30, cc.p(start_scoresStr:getPositionX()+start_scoresStr:getContentSize().width+10, 140), cc.p(0, 0.5), spBg):setColor(color_yellow)
	-- 起始记分牌
	local layer1, ttime1 = DZUi.addUISlider(spBg, DZUi.SLIDER_CARD_SEVEN, cc.p(display.width/2,80), function(val)
			inital_score = val
			print(val)
			start_scores:setString(tostring(inital_score*20))
		end, inital_score)

	-- 盲注结构
	local function bindsStru(  )
		local bindsLayer = require("common.bindsLayer").new("sng")
		self:addChild(bindsLayer, 10)
	end
	UIUtil.addImageBtn({norImg = "common/com_icon_ask.png", selImg = "common/com_icon_ask.png", disImg = "common/com_icon_ask.png", ah =cc.p(1, 0.5), pos = cc.p(display.width-20, 300), touch = true, listener = bindsStru, parent = infoBg[1]})

	-- 参赛人数
	local player_str = UIUtil.addLabelArial('参赛人数:', 30, cc.p(infoW, sizeH[2]/2), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
	local playerStr = {2, 6, 9}
	local playerBtn = {}
	local function playerFunc( sender )
		local tag = sender:getTag()
		sender:setEnabled(false)
		limit_players = playerStr[tag]
		MainCtrol.setBuildSngNum(limit_players)
		for k,v in pairs(playerBtn) do
			if tag ~= v:getTag() then
				v:setEnabled(true)
			end
		end
	end
	for i=1,3 do
		local label = cc.Label:createWithSystemFont(playerStr[i], "Arial", 30)
		local btn_str = ResLib.BTN_BLUE_BORDER
		playerBtn[i] = UIUtil.controlBtn("bg/e_sBtnUn.png", "bg/e_sBtn.png", "bg/e_sBtn.png", label, cc.p(display.width/2+(i-1)*150, sizeH[2]/2), cc.size(100,50), playerFunc, infoBg[2])
		playerBtn[i]:setTitleColorForState(ResLib.COLOR_GREY, cc.CONTROL_STATE_NORMAL)
		playerBtn[i]:setTitleColorForState(display.COLOR_WHITE, cc.CONTROL_STATE_DISABLED)
		playerBtn[i]:setTag(i)
	end
	if CARD_TARGET == "person" then
		limit_players = MainCtrol.getBuildSngNum()
	else
		limit_players = playerStr[1]
	end
	for i,v in ipairs(playerStr) do
		if limit_players == v then
			playerBtn[i]:setEnabled(false)
			break
		end
	end

	-- 授权带入
	is_access = 0
	local label = UIUtil.addLabelArial('授权参赛:', 30, cc.p(infoW, sizeH[3]/2), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	local function togMenuFunc( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			is_access = 1
		else
			print("off")
			is_access = 0
		end
	end
	local switch = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[3]/2), listener = togMenuFunc, parent = infoBg[3]})
	switch:setSelectedIndex(1)
	switch:setAnchorPoint(cc.p(1, 0.5))

	-- IP/GPS限制
	local ipgpsLabel = {}
	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			ipgpsLabel[tag]:setColor(ResLib.COLOR_BLUE)
			if tag == 1 then
				openIP = 1
			elseif tag == 2 then
				openGPS = 1
			end
		else
			ipgpsLabel[tag]:setColor(ResLib.COLOR_GREY)
			if tag == 1 then
				openIP = 0
			elseif tag == 2 then
				openGPS = 0
			end
		end
	end
	local str = {"IP限制", "GPS限制"}
	for i=1,2 do
		UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(infoW+(i-1)*400, sizeH[4]/2), checkboxFunc = checkBoxFunc, parent = infoBg[4]}):setTag(i)
		ipgpsLabel[i] = UIUtil.addLabelArial(str[i], 30, cc.p(70+(i-1)*400, sizeH[4]/2), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)
	end

	-- 赛事分享
	if CARD_TARGET == "union" then
		SelectCtrol.setSelectClub({})
		local balance_str = UIUtil.addLabelArial('赛事分享:', 30, cc.p(infoW, sizeH[5]/2), cc.p(0, 0.5), infoBg[5]):setColor(ResLib.COLOR_GREY)

		local selectNum = nil
		local selectTile = nil
		local iconClub = nil

		local function updateSelectNum(  )
			local tab = SelectCtrol.getSelectClub()
			selectNum:setString("("..tostring(#tab)..")")
			selectTile:setPositionX(selectNum:getPositionX()-selectNum:getContentSize().width)
			iconClub:setPositionX(selectTile:getPositionX()-selectTile:getContentSize().width)
		end
		local function selectClub(  )
			SelectCtrol.dataStatUnionMember(function(  )
				local SelectClub = require("common.SelectClub")
				local layer = SelectClub:create()
				_setCards:addChild(layer, 10)
				layer:createLayer(updateSelectNum)
			end)
		end
		local selectBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah =cc.p(1, 0.5), pos = cc.p(display.width-20, sizeH[5]/2), touch = true, scale9=true, size = cc.size(display.width/2, sizeH[5]), listener = selectClub, parent = infoBg[5]})

		local iconR = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(selectBtn:getContentSize().width, sizeH[5]/2), selectBtn, cc.p(1, 0.5))
		selectNum = UIUtil.addLabelArial('（0）', 30, cc.p(iconR:getPositionX()-iconR:getContentSize().width, sizeH[5]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_GREY)
		selectTile = UIUtil.addLabelArial('选择俱乐部', 30, cc.p(selectNum:getPositionX()-selectNum:getContentSize().width, sizeH[5]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_BLUE)
		iconClub = UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL, cc.p(selectTile:getPositionX()-selectTile:getContentSize().width, sizeH[5]/2), selectBtn, cc.p(1, 0.5))
	end

	-- 记分牌余额
	local balanceH = sizeH[5]
	local balanceBg = infoBg[5]
	if sizeH[6] then
		balanceH = sizeH[6]
		balanceBg = infoBg[6]
	end

	-- 记分牌余额
	local balance_str = UIUtil.addLabelArial('记分牌余额:', 30, cc.p(infoW, balanceH/2), cc.p(0, 0.5), balanceBg):setColor(ResLib.COLOR_GREY)

	local text1 = Single:playerModel():getPBetNum()
	local balance = UIUtil.addLabelArial(text1, 30, cc.p(balance_str:getPositionX()+balance_str:getContentSize().width+10, balanceH/2), cc.p(0, 0.5), balanceBg):setColor(color_yellow)

	local function beginCards(  )

		if not limit_players then
			limit_players = 2
		end
		self:beginSNGCards()
	end
	local label = cc.Label:createWithSystemFont("", "Arial", 38)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 60), cc.size(700,80), beginCards, curNode)

	if CARD_TARGET == "union" then
		local str1 = UIUtil.addLabelArial("现在开局（"..tostring(diamonds), 38, cc.p(btn:getContentSize().width/2-36, btn:getContentSize().height/2), cc.p(0.5, 0.5), btn)
		local sp = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(str1:getPositionX()+str1:getContentSize().width/2,str1:getPositionY()), btn, cc.p(0, 0.5))
		local str2 = UIUtil.addLabelArial("）", 38, cc.p(sp:getPositionX()+sp:getContentSize().width, str1:getPositionY()), cc.p(0, 0.5), btn)
	else
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_NORMAL)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_HIGH_LIGHTED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_DISABLED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_SELECTED)
	end
end

function SetCards:addLimitBtn( cardMode, parent, pos, btn_text, callback )
	local pos = pos
	local btn_text = btn_text
	local callback = callback
	local size_btn = {}
	if cardMode == "sng" then
		size_btn = {w = 75, h = 75}
	elseif cardMode == "mtt" then
		size_btn = {w = 82, h = 60}
	end
	if not pos then
		pos = cc.p(display.width-50, 2.5)
	end
	-- dump(pos)
	if not btn_text then
		btn_text = {2, 6, 9}
	end
	-- dump(btn_text)

	local bg = UIUtil.addImageView({image = "common/set_card_MTT_limit_bg.png", touch=false, scale=true, size=cc.size(#btn_text*size_btn.w, size_btn.h), ah = cc.p(1, 0), pos=pos, parent=parent})

	local btn = {}
	local function btnFunc( sender )
		local tag = sender:getTag()
		for k,v in pairs(btn) do
			if k == tag then
				v:setTouchEnabled(false)
				v:setBright(false)
			else
				v:setTouchEnabled(true)
				v:setBright(true)
			end
		end
		if  not callback then
			limit_players = btn_text[tag]
			print("《《《《《《《《《《《《《 "..limit_players)
		else
			callback(tag)
		end
	end
	
	for i=1,#btn_text do
		local norIcon, selIcon = nil,nil
		norIcon = "common/com_limit_btn_"..btn_text[i].."_1.png"
		selIcon = "common/com_limit_btn_"..btn_text[i].."_2.png"

		btn[i] = UIUtil.addImageBtn({norImg = norIcon, selImg = selIcon, disImg = selIcon, pos = cc.p((#btn_text*size_btn.w)*(2*i-1)/(#btn_text*2), size_btn.h/2), touch = true, scale9 = true, size = cc.size(size_btn.w, size_btn.h), listener = btnFunc, parent = bg})
		btn[i]:setTag(i)
	end
	btn[1]:setTouchEnabled(false)
	btn[1]:setBright(false)--]]

end

function SetCards:buildMTTCards( layer )
	if curNode then
		curNode:removeFromParent()
		curNode = nil
	end
	curNode = cc.Node:create()
	local posH = display.height-230
	curNode:setContentSize(cc.size(display.width, posH))
	curNode:setPosition(cc.p(0,0))
	layer:addChild(curNode)

	self:clearData()
	self:initMTTdata()

	local MTT_icon = {}
	MTT_icon = {
					{normal = "set_card_MTT_fixed.png", height = "set_card_MTT_fixed_height.png"},
					{normal = "set_card_MTT_float.png", height = "set_card_MTT_float_height.png"},
					{normal = "set_card_MTT_fixed_float.png", height = "set_card_MTT_fixed_float_height.png"}
				}
	local MTT_btn = {}

	diamonds = 0
	local updateCallBack = nil
	local btnStr1 = nil
	local btnSp = nil
	local btnStr2 = nil
	if CARD_TARGET == "union" then
		updateCallBack = function(  )
			local tab = SelectCtrol.getSelectClub()
			btnStr1:setString("现在开局（"..tostring(#tab*10))
			btnStr1:setPositionX(700/2-36)
			btnSp:setPositionX(btnStr1:getPositionX()+btnStr1:getContentSize().width/2)
			btnStr2:setPositionX(btnSp:getPositionX()+btnSp:getContentSize().width)
		end
	end

	local function MTTCardFunc( sender )
		local tag = sender:getTag()
		for k,v in pairs(MTT_btn) do
			if tag ~= v:getTag() then
				v:setTouchEnabled(true)
				v:setBright(true)
			end
		end
		sender:setTouchEnabled(false)
		sender:setBright(false)
		if tag == 1 then
			SetModel.setPondCount( 1 )
		elseif tag == 3 then
			SetModel.setPondCount( 0 )
		end
		self:clearData()
		self:initMTTdata()
		card_name = Storage.getStringForKey(MTT_NAME) or ""
		if card_name == nil or card_name == "" then
			name_str = "牌局名称("..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字)"
		end
		
		self:setMTTCard(tag, updateCallBack)
	end
	for i=1,3 do
		MTT_btn[i] = UIUtil.addImageBtn({norImg = "common/"..MTT_icon[i].normal, selImg = "common/"..MTT_icon[i].height, disImg = "common/"..MTT_icon[i].height, ah = cc.p(0, 1), pos = cc.p((i-1)*250+(display.width-750)/3, posH-10), scale9 = true, size = cc.size(250,85), swalTouch=true, touch = true, listener = MTTCardFunc, parent = curNode})
		MTT_btn[i]:setTag(i)
		MTT_btn[i]:setLocalZOrder(5)
	end
	MTT_btn[2]:setTouchEnabled(false)
	MTT_btn[2]:setBright(false)

	scrollView_MTT = UIUtil.addScrollView( {showSize=cc.size(display.width, posH-200), innerSize=cc.size(display.width, display.height+100), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,100), parent=curNode} )
	scrollView_MTT:setScrollBarEnabled(false)

	card_name = Storage.getStringForKey(MTT_NAME) or ""
	if card_name == nil or card_name == "" then
		name_str = "牌局名称("..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字)"
	end

	self:setMTTCard(2, updateCallBack)

	-- 开始MTT
	local function beginMTTCards(  )
		print("开始1")
		self:beginMTTCards()
	end
	local label = cc.Label:createWithSystemFont("", "Arial", 38)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 60), cc.size(700,80), beginMTTCards, curNode)
	
	if CARD_TARGET == "union" then
		btnStr1 = UIUtil.addLabelArial("现在开局（0", 38, cc.p(btn:getContentSize().width/2-36, btn:getContentSize().height/2), cc.p(0.5, 0.5), btn)
		btnSp = UIUtil.addPosSprite("user/icon_zhuanshi.png", cc.p(btnStr1:getPositionX()+btnStr1:getContentSize().width/2,btnStr1:getPositionY()), btn, cc.p(0, 0.5))
		btnStr2 = UIUtil.addLabelArial("）", 38, cc.p(btnSp:getPositionX()+btnSp:getContentSize().width, btnStr1:getPositionY()), cc.p(0, 0.5), btn)
	else
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_NORMAL)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_HIGH_LIGHTED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_DISABLED)
		btn:setTitleForState("现在开局", cc.CONTROL_STATE_SELECTED)
	end
end

function SetCards:setMTTCard( tag, updateCallFunc )
	scrollView_MTT:removeAllChildren()
	layer_MTT = nil
	-- local sizeH = nil
	local scrollH = 0

	mtt_type = tag

	local sizeH = {}
	if mtt_type == 1 then
		sizeH = {0, 450, 540, 150, 100, 100, 100, 100, 100, 100, 100, 0, 100, 0}
	elseif mtt_type == 2 then
		sizeH = {0, 150, 540, 150, 100, 100, 100, 100, 100, 100, 100, 0, 100, 0}
	elseif mtt_type == 3 then
		sizeH = {0, 300, 540, 150, 100, 100, 100, 100, 100, 100, 100, 0, 100, 0}
	end
	if CARD_TARGET == "union" then
		sizeH[6] = 100
		sizeH[13] = 100
		sizeH[14] = 0
	else
		sizeH[6] = 0
		sizeH[13] = 0
		sizeH[14] = 0
	end
	if CARD_TARGET == "circle" or CARD_TARGET == "union" or CARD_TARGET == "club" then
		sizeH[8] = 0
	else
		sizeH[8] = 100
	end

	for i=1,#sizeH do
		scrollH = scrollH+sizeH[i]
	end
	-- scrollH = sizeH[1]+sizeH[2]+sizeH[3]+sizeH[4] + 80
	scrollView_MTT:setInnerContainerSize(cc.size(display.width, scrollH))

	local layer = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, scrollH), pos=cc.p(0,0), parent=scrollView_MTT})
	local layer_w = layer:getContentSize().width
	local layer_h = layer:getContentSize().height
	local spBg_pos = nil

	local infoW = 20
	local infoBg = {}
	local infoBgH = 0
	for i=1,#sizeH do
		infoBgH = sizeH[i] + infoBgH
		-- TABLEVIEW_CELL_BG
		-- COM_OPACITY0
		-- BTN_GREEN_NOR
		local img = ResLib.COM_OPACITY0
		if i == 2 then
			img = "common/card_mtt_build_bg2.png"
			-- if mtt_type == 2 then
			-- 	img = "common/card_mtt_build_bg2.png"
			-- else
			-- 	img = "common/card_mtt_build_bg.png"
			-- end
		end
		infoBg[i] = UIUtil.addImageView({image = img, touch=false, scale=true, size=cc.size(display.width, sizeH[i]), ah=cc.p(0,0), pos=cc.p(0, scrollH-infoBgH), parent=layer})
		if sizeH[i] == 0 then
			infoBg[i]:setVisible(false)
		end
	end

	if mtt_type == 1 then
		UIUtil.addLabelArial('总奖池', 30, cc.p(infoW, sizeH[2]-50), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)

		local editBg = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(display.width-140, 60), ah=cc.p(0.5,0), pos=cc.p(display.width/2, sizeH[2]-140), parent=infoBg[2]})
		UIUtil.addPosSprite("user/icon_spades.png", cc.p(0, editBg:getContentSize().height/2), editBg, cc.p(0, 0.5))
		local line = UIUtil.addImageView({image = "common/mtt_edit_line.png", touch=false, scale=true, size=cc.size(display.width-140, 1), ah=cc.p(0,0), pos=cc.p(0, 0), parent=editBg})

		local edit1 = UIUtil.addEditBox(ResLib.COM_OPACITY0, cc.size(400, 55), cc.p(60, editBg:getContentSize().height/2), awards_count, editBg)
		edit1:setAnchorPoint(cc.p(0,0.5))
		edit1:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
		edit1:setFontColor(display.COLOR_WHITE)
		local function textFunc( eventType, sender )
			if eventType == "changed" then
			elseif eventType == "return" then
				local str = StringUtils.trim(sender:getText())
				if str ~= "" then
					awards_count = tonumber(str)
				end
			end
		end
		edit1:registerScriptEditBoxHandler(textFunc)
		local label1 = UIUtil.addLabelArial('保底人数:', 30, cc.p(infoW, editBg:getPositionY()-60), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
		keep_count = 1
		local label2 = UIUtil.addLabelArial(keep_count, 30, cc.p(label1:getPositionX()+label1:getContentSize().width+10, label1:getPositionY()), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
		-- 保底人数
		local personNum = {}
		for i=1,10 do
			if i == 10 then
				personNum[i] = 12
			else
				personNum[i] = i
			end	
		end
		local function sliderKeep( sender )
			local idx = math.floor(sender:getValue())
			keep_count = personNum[idx]
			label2:setString(keep_count)
			SetModel.setPondCount( keep_count )
		end
		local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
		local maxLen = #personNum + 0.9
		local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2, label1:getPositionY()-70), infoBg[2], sliderKeep, 1.1, maxLen)
		tslider:setAnchorPoint(0.5,0.5)
	elseif mtt_type == 2 then

	elseif mtt_type == 3 then
		local label1 = UIUtil.addLabelArial('保底人数:', 30, cc.p(infoW, sizeH[2]-50), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
		keep_count = 1
		keepLabel = UIUtil.addLabelArial(keep_count, 30, cc.p(label1:getPositionX()+label1:getContentSize().width+10, sizeH[2]-50), cc.p(0, 0.5), infoBg[2]):setColor(ResLib.COLOR_GREY)
		-- 保底人数
		local personNum = {}
		for i=1,10 do
			personNum[i] = i
		end
		local function sliderKeep( sender )
			local idx = math.floor(sender:getValue())
			keep_count = personNum[idx]	
			keepLabel:setString(keep_count)

			SetModel.setPondCount( keep_count )
			SetModel.initPondTab()
		end
		local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
		local maxLen = #personNum + 0.9
		keepSlider = UIUtil.addSlider(imgs, cc.p(display.width/2, label1:getPositionY()-70), infoBg[2], sliderKeep, 1.1, maxLen)
		keepSlider:setAnchorPoint(0.5,0.5)

		local function callback(  )
			SetModel.buildPond( {parent = layer, _class = _setCards} )
		end
		local pondBtn = UIUtil.addImageBtn({norImg = "common/mtt_pond_btn.png", selImg = "common/mtt_pond_btn.png", disImg = "common/mtt_pond_btn.png", ah = cc.p(1,0.5), pos = cc.p(display.width-20, sizeH[2]-50), touch = true, swalTouch = false, listener = callback, parent = infoBg[2]})
	end
	
	local color_yellow = cc.c3b(204, 204, 204)

	-- 牌局名称
	local editBg = UIUtil.addImageView({image = "common/com_name_edit.png", touch=false, scale=true, size=cc.size(display.width-50, 98), pos=cc.p(display.width/2, 75), ah=cc.p(0.5,0.5), parent=infoBg[2]})

	local cardName = UIUtil.addEditBox(nil, cc.size(display.width-70, 98), cc.p(editBg:getContentSize().width/2, editBg:getContentSize().height/2), name_str, editBg )
	-- cardName:setFontColor(cc.c3b(100, 125, 165))
	cardName:setPlaceholderFontColor(cc.c3b(91, 146, 255))
	cardName:setFontSize(36)
	cardName:setMaxLength(LEN_CARD)
	if card_name ~= "" then
		cardName:setText(card_name)
	end
	local function editFunc( eventType, sender )
		UIUtil.checkEditText( eventType, sender, {modLen = LEN_CARD, content ="牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！", funcBack = function(str)
			card_name = str
			Storage.setStringForKey(MTT_NAME, card_name, true)
		end }, true )
	end
	cardName:registerScriptEditBoxHandler(editFunc)

	-- 报名费
	local fee = DZConfig.getMttFee()
	local str_1 = fee[1]
	local str_2 = str_1 * 10/100
	entry_fee = str_1 + str_2
	_entryFee = str_1
	local mttLabel1 = UIUtil.addLabelArial("报名费:", 30, cc.p(infoW, sizeH[3]-40), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	local mttStr1 = UIUtil.addLabelArial(str_1 .. "+" .. str_2, 30, cc.p(mttLabel1:getPositionX()+mttLabel1:getContentSize().width+10, sizeH[3]-40), cc.p(0, 0.5), infoBg[3]):setColor(color_yellow)
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		local fee_1 = fee[idx]
		local fee_2 = fee_1 * 10/100

		mttStr1:setString(fee_1.."+"..fee_2)

		entry_fee = fee_1 + fee_2
		_entryFee = fee_1
		MainCtrol.setBuildMttFee( _entryFee )
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #fee + 0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2, sizeH[3]-100), infoBg[3], sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)

	-- 起始记分牌
	local startScore = DZConfig.getStartScores()
	inital_score = startScore[1]
	local mttLabel2 = UIUtil.addLabelArial("起始记分牌:", 30, cc.p(infoW, sizeH[3]-170), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	local mttStr2 = UIUtil.addLabelArial(inital_score.."倍大盲", 30, cc.p(mttLabel2:getPositionX()+mttLabel2:getContentSize().width+10, sizeH[3]-170), cc.p(0, 0.5), infoBg[3]):setColor(color_yellow)
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		print(startScore[idx])
		inital_score = startScore[idx]
		mttStr2:setString(inital_score.."倍大盲")
		MainCtrol.setBuildMttScore( inital_score )
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #startScore + 0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2, sizeH[3]-230), infoBg[3], sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)

	-- 升盲时间
	local upTime = DZConfig.getUpTimes()
	increase_time = upTime[1]
	local mttLabel3 = UIUtil.addLabelArial("升盲时间:", 30, cc.p(infoW, sizeH[3]-300), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	local mttStr3 = UIUtil.addLabelArial(increase_time.."分钟", 30, cc.p(mttLabel3:getPositionX()+mttLabel3:getContentSize().width+10, sizeH[3]-300), cc.p(0, 0.5), infoBg[3]):setColor(color_yellow)
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		print(upTime[idx])
		increase_time = upTime[idx]
		mttStr3:setString(increase_time .. "分钟")
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #upTime + 0.9
	local tslider = UIUtil.addSlider(imgs, cc.p(display.width/2, sizeH[3]-360), infoBg[3], sliderChange, 1.1, maxLen)
	tslider:setAnchorPoint(0.5,0.5)

	-- 起始盲注级别
	local blindLevel =  DZConfig.getBlindLevel()
	orgBlind = blindLevel[1]/2
	local mttLabel4 = UIUtil.addLabelArial("起始盲注级别:", 30, cc.p(infoW, sizeH[3]-430), cc.p(0, 0.5), infoBg[3]):setColor(ResLib.COLOR_GREY)
	orgBlindStr = UIUtil.addLabelArial(tostring(orgBlind).."/"..tostring(orgBlind*2), 30, cc.p(mttLabel4:getPositionX()+mttLabel4:getContentSize().width+10, sizeH[3]-430), cc.p(0, 0.5), infoBg[3]):setColor(color_yellow)
	local function sliderChange( sender )
		local idx = math.floor(sender:getValue())
		print(blindLevel[idx])
		orgBlind = blindLevel[idx]/2
		orgBlindStr:setString(tostring(orgBlind).."/"..tostring(orgBlind*2))
	end
	local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
	local maxLen = #blindLevel + 0.9
	orgBlindSlider = UIUtil.addSlider(imgs, cc.p(display.width/2, sizeH[3]-500), infoBg[3], sliderChange, 1.1, maxLen)
	orgBlindSlider:setAnchorPoint(0.5,0.5)

	--	盲注表类型
	local mttLabel5 = UIUtil.addLabelArial('盲注表类型:', 30, cc.p(infoW, sizeH[4]-20), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)
	
	local function blindBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			blindBox[tag]:setTouchEnabled(false)
			blindLabel[tag]:setColor(ResLib.COLOR_BLUE)
			if tag == 1 then
				blindType = 1
				if blindBox[2]:isSelected() then
					blindBox[2]:setSelectedState(false)
					blindBox[2]:setTouchEnabled(true)
					blindLabel[2]:setColor(ResLib.COLOR_GREY)
				end
			elseif tag == 2 then
				blindType = 2
				if blindBox[1]:isSelected() then
					blindBox[1]:setSelectedState(false)
					blindBox[1]:setTouchEnabled(true)
					blindLabel[1]:setColor(ResLib.COLOR_GREY)
				end
			end
		else
			if sender:isSelected() then
				return
			end
			blindLabel[tag]:setColor(ResLib.COLOR_GREY)
			blindType = 0
		end
	end
	blindType = 1
	local straddleStr = {"盲注表(普通)", "盲注表(快速)"}
	for i=1,2 do
		blindBox[i] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_1.png", checkBtn = "common/com_checkBox_1_1.png", ah = cc.p(0, 0.5), pos = cc.p(infoW+(i-1)*400, sizeH[4]/2-20), checkboxFunc = blindBoxFunc, parent = infoBg[4]}):setTag(i)
		blindLabel[i] = UIUtil.addLabelArial(straddleStr[i], 30, cc.p(70+(i-1)*400, sizeH[4]/2-20), cc.p(0, 0.5), infoBg[4]):setColor(ResLib.COLOR_GREY)
	end
	blindBox[1]:setSelectedState(true)
	blindBox[1]:setTouchEnabled(false)
	blindLabel[1]:setColor(ResLib.COLOR_BLUE)

	-- 盲注结构
	local function bindsStru(  )
		local blindLevel = orgBlind
		local blind_type = {"general", "quick"}
		
		local mttBlinds = require("common.mttBlinds").new(blindLevel, blind_type[blindType], 0)
		self:addChild(mttBlinds, 10)
	end
	UIUtil.addImageBtn({norImg = "common/card_mtt_blue_btn.png", selImg = "common/card_mtt_blue_btn.png", disImg = "common/com_icon_ask.png", text="盲注级别", ah=cc.p(1, 0.5), pos = cc.p(display.width-20, sizeH[3]-430), scale9=true, size=cc.size(150, 50), touch = true, listener = bindsStru, parent = infoBg[3]})

	-- 开赛时间
	local playTimeStr = nil
	local function playTimeFunc(  )
		local UIDatePicker = require('ui.UIDatePicker')   
		local dPicker = UIDatePicker.new({minimumDate = os.time(),
                                            maxDate = os.time() + 60 * 24 * 60 * 7,
                                            datePickerMode = 3})
		dPicker:addValueEventListener(function ( time )
                                            	print("--------- "..os.date("%Y年%m月%d日 %H:%M:%S",time))
                                            	play_time = time
                                            	playTimeStr:setString(os.date("%Y/%m/%d %H:%M:%S",play_time))
                                            	playTimeStr:setColor(display.COLOR_WHITE)
                                            	dPicker:removeFromParent()
                                            end)
		dPicker:setPosition(cc.p(0, 0))
		curNode:addChild(dPicker, 100)
	end
	local playBg = UIUtil.addImageBtn({norImg = "common/com_mttTime_bg.png", selImg = "common/com_mttTime_bg.png", disImg = "common/com_mttTime_bg.png", ah =cc.p(0.5, 0.5), pos = cc.p(display.width/2, sizeH[5]/2 ), listener = playTimeFunc, parent = infoBg[5]})
	playTimeStr = UIUtil.addLabelArial("开赛时间", 30, cc.p(20, playBg:getContentSize().height/2), cc.p(0, 0.5), playBg):setColor(ResLib.COLOR_GREY)
	local sp_down = UIUtil.addPosSprite("common/set_card_MTT_play_icon.png", cc.p(playBg:getContentSize().width-20, playBg:getContentSize().height/2), playBg, cc.p(1, 0.5))
	UIUtil.addLabelArial("请设置开赛时间", 30, cc.p(sp_down:getPositionX()-sp_down:getContentSize().width-10, playBg:getContentSize().height/2), cc.p(1, 0.5), playBg)

	-- 赛事分享
	SelectCtrol.setSelectClub({})
	local openLabel = UIUtil.addLabelArial('赛事分享', 30, cc.p(infoW, sizeH[6]/2), cc.p(0, 0.5), infoBg[6]):setColor(ResLib.COLOR_GREY)
	local selectNum = nil
	local selectTile = nil
	local iconClub = nil

	local function updateSelectNum(  )
		if updateCallFunc then
			updateCallFunc()
		end
		local tab = SelectCtrol.getSelectClub()
		diamonds = #tab*10
		selectNum:setString("("..tostring(#tab)..")")
		selectTile:setPositionX(selectNum:getPositionX()-selectNum:getContentSize().width)
		iconClub:setPositionX(selectTile:getPositionX()-selectTile:getContentSize().width)
	end
	local function selectClub(  )
		SelectCtrol.dataStatUnionMember(function(  )
			local SelectClub = require("common.SelectClub")
			local layer = SelectClub:create()
			_setCards:addChild(layer, 10)
			layer:createLayer(updateSelectNum)
		end)
	end
	local selectBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, disImg = ResLib.COM_OPACITY0, ah =cc.p(1, 0.5), pos = cc.p(display.width-20, sizeH[6]/2), touch = true, scale9=true, size = cc.size(display.width/2, sizeH[6]), listener = selectClub, parent = infoBg[6]})

	local iconR = UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(selectBtn:getContentSize().width, sizeH[6]/2), selectBtn, cc.p(1, 0.5))
	selectNum = UIUtil.addLabelArial('（0）', 30, cc.p(iconR:getPositionX()-iconR:getContentSize().width, sizeH[6]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_GREY)
	selectTile = UIUtil.addLabelArial('选择俱乐部', 30, cc.p(selectNum:getPositionX()-selectNum:getContentSize().width, sizeH[6]/2), cc.p(1, 0.5), selectBtn):setColor(ResLib.COLOR_BLUE)
	iconClub = UIUtil.addPosSprite(ResLib.CLUB_HEAD_GENERAL_SMALL, cc.p(selectTile:getPositionX()-selectTile:getContentSize().width, sizeH[6]/2), selectBtn, cc.p(1, 0.5))

	-- 授权带入
	local manageBtn = nil
	local manageSp = nil
	is_access = 0
	local mttLabel6 = UIUtil.addLabelArial('授权参赛', 30, cc.p(infoW, sizeH[7]/2), cc.p(0, 0.5), infoBg[7]):setColor(ResLib.COLOR_GREY)
	local function togMenuFunc( tag, sender )
		if sender:getSelectedIndex() == 0 then
			print("on")
			is_access = 1
			manageBtn:setVisible(true)
			manageSp:setVisible(false)
		else
			print("off")
			is_access = 0
			manageBtn:setVisible(false)
			manageSp:setVisible(true)
		end
	end
	local switch_access = UIUtil.addTogMenu({pos = cc.p(display.width-20, sizeH[7]/2), listener = togMenuFunc, parent = infoBg[7]})
	switch_access:setSelectedIndex(1)
	switch_access:setAnchorPoint(cc.p(1, 0.5))

	-- 赛事管理
	local mttLabel7 = UIUtil.addLabelArial('赛事管理', 30, cc.p(infoW, sizeH[8]/2), cc.p(0, 0.5), infoBg[8]):setColor(ResLib.COLOR_GREY)
	local function manageFunc(  )
		print("管理")
		local target = CARD_TARGET
		if CARD_TARGET == "union" then
			target = target..tostring(publicGame)
		end
		local testly = require('main.SearchManagerLayer'):create(target, org_id)
		_setCards:addChild(testly, 10)
	end
	manageBtn = UIUtil.addImageBtn({norImg = "common/mtt_manage_btn.png", selImg = "common/mtt_manage_btn.png", disImg = "common/mtt_manage_btn.png", ah = cc.p(1,0.5), pos = cc.p(display.width-20, sizeH[8]/2), touch = true, swalTouch = false, listener = manageFunc, parent = infoBg[8]})
	manageSp = UIUtil.addPosSprite("common/set_card_Mtt_sp.png", cc.p(display.width-20, sizeH[8]/2), infoBg[8], cc.p(1, 0.5))
	if is_access == 0 then
		manageBtn:setVisible(false)
		manageSp:setVisible(true)
	else
		manageBtn:setVisible(true)
		manageSp:setVisible(false)
	end


	-- 赛事简介
	local mttLabel8 = UIUtil.addLabelArial('赛事简介', 30, cc.p(infoW, sizeH[9]/2), cc.p(0, 0.5), infoBg[9]):setColor(ResLib.COLOR_GREY)
	local function desFunc(  )
		print("编辑")
		local mttInfroBack = function(msg, msg2) 
			print("msg"..msg, "msg2"..tostring(msg2))
			if (msg) then 
				mttDes = msg
			else
				mttDes = ""
			end
		end
		local EditorMttIntro = require("common.MttIntroEditLayer")
		local edt = EditorMttIntro.new({callback = mttInfroBack, isPublish = true, description = mttDes})
		_setCards:addChild(edt)
	end
	local editBtn = UIUtil.addImageBtn({norImg = "common/mtt_editDes_btn.png", selImg = "common/mtt_editDes_btn.png", disImg = "common/mtt_editDes_btn.png", ah = cc.p(1,0.5), pos = cc.p(display.width-20, sizeH[9]/2), touch = true, swalTouch = false, listener = desFunc, parent = infoBg[9]})

	-- IP/GPS限制
	local ipgpsLabel = {}
	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		print("tag: "..tag)
		print("eventType: "..eventType)
		if eventType == 0 then
			ipgpsLabel[tag]:setColor(ResLib.COLOR_BLUE)
			if tag == 1 then
				openIP = 1
			elseif tag == 2 then
				openGPS = 1
			end
		else
			ipgpsLabel[tag]:setColor(ResLib.COLOR_GREY)
			if tag == 1 then
				openIP = 0
			elseif tag == 2 then
				openGPS = 0
			end
		end
	end
	local str = {"IP限制", "GPS限制"}
	for i=1,2 do
		UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(infoW+(i-1)*400, sizeH[10]/2), checkboxFunc = checkBoxFunc, parent = infoBg[10]}):setTag(i)
		ipgpsLabel[i] = UIUtil.addLabelArial(str[i], 30, cc.p(70+(i-1)*400, sizeH[10]/2), cc.p(0, 0.5), infoBg[10]):setColor(ResLib.COLOR_GREY)
	end

	-- 高级设置
	-- 初始默认值
	-- limitPlayer = 3000
	entry_stop = 1
	buy_count = 0
	add_count = 0
	half_time = 0
	-- awardScale = 1

	local togImg1, togImg2 = {}, {}
	local togMenu = nil
	for i=1,3 do
		togImg1[i] = "common/set_card_MTT_toggle_up.png"
		togImg2[i] = "common/set_card_MTT_toggle_down.png"
	end
	local function upOrdownFunc( tag, sender )
		local selected = false
		local addHeight = 0
		if togMenu:getSelectedIndex() == 0 then
			print("on")

			-- sizeH[12] = 650
			sizeH[12] = 550
			addHeight = 550
			selected = true
		else
			print("off")
			sizeH[12] = 0

			addHeight = -550
			selected = false
		end
		scrollH = scrollH+addHeight
		scrollView_MTT:setInnerContainerSize(cc.size(display.width, scrollH))
		local infoBgH = 0
		for i=1,#sizeH do
			infoBgH = sizeH[i] + infoBgH
			if i == 12 then
				infoBg[12]:setContentSize(cc.size(display.width, sizeH[12]))
			end
			if sizeH[i] > 0 then
				infoBg[i]:setVisible(true)
			else
				infoBg[i]:setVisible(false)
			end
			infoBg[i]:setPositionY(scrollH-infoBgH)
		end
		infoBg[12]:removeAllChildren()
		self:addCardSet(infoBg[12], selected)
		scrollView_MTT:scrollToBottom(0, false)
	end
	togMenu = UIUtil.addTogMenu({imgTab1 = togImg1, imgTab2 = togImg2, pos = cc.p(display.width/2, sizeH[11]/2), listener = upOrdownFunc, parent = infoBg[11]})
	togMenu:setSelectedIndex(1)
	UIUtil.addLabelArial('高级设置', 30, cc.p(display.width/2, sizeH[11]/2+15), cc.p(0.5, 0.5), infoBg[11])

	-- 战队PK
	local teamTogMenu = nil
	local function teamUpOrdownFunc(  )
		local selected = false
		local addHeight = 0
		if teamTogMenu:getSelectedIndex() == 0 then
			print("on")

			sizeH[14] = 100
			addHeight = 100
			selected = true
		else
			print("off")
			sizeH[14] = 0
			addHeight = -100
			selected = false
		end
		scrollH = scrollH+addHeight
		scrollView_MTT:setInnerContainerSize(cc.size(display.width, scrollH))
		local infoBgH = 0
		for i=1,#sizeH do
			infoBgH = sizeH[i] + infoBgH
			if i == 14 then
				infoBg[14]:setContentSize(cc.size(display.width, sizeH[14]))
			end
			if sizeH[i] > 0 then
				infoBg[i]:setVisible(true)
			else
				infoBg[i]:setVisible(false)
			end
			infoBg[i]:setPositionY(scrollH-infoBgH)
		end
		infoBg[14]:removeAllChildren()
		self:addTeamSet(infoBg[14], selected)
		scrollView_MTT:scrollToBottom(0, false)
	end
	teamTogMenu = UIUtil.addTogMenu({imgTab1 = togImg1, imgTab2 = togImg2, pos = cc.p(display.width/2, sizeH[13]/2), listener = teamUpOrdownFunc, parent = infoBg[13]})
	teamTogMenu:setSelectedIndex(1)
	UIUtil.addLabelArial('战队PK', 30, cc.p(display.width/2, sizeH[13]/2+15), cc.p(0.5, 0.5), infoBg[13])

end

-- 高级设置
function SetCards:addCardSet( node, flag )
	if not flag then
		return
	end

	-- -- 初始默认值

	local nodeH = node:getContentSize().height
	local color_yellow = cc.c3b(204, 204, 204)
	local setText = {}
	local desText = {}
	-- if mtt_type == 2 then
	-- 	setText = {"参赛人数上限", "终止报名级别", "重购次数", "Add-on", "中场休息", "奖励范围"}
	-- 	desText = {"", "", "(购买1倍记分牌)", "", "(每隔10个盲注级别后休息一次)", ""}
	-- else
	-- 	setText = {"参赛人数上限", "终止报名级别", "重购次数", "Add-on", "中场休息"}
	-- 	desText = {"", "", "(购买1倍记分牌)", "", "(每隔10个盲注级别后休息一次)"}
	-- end
	setText = {"终止报名级别", "重购次数", "Add-on", "中场休息"}
	desText = {"", "(购买1倍记分牌)", "", "(每隔10个盲注级别后休息一次)"}

	-- 数据值
	local mttValue = SetModel.getMttValue()
	local valueTab = {entry_stop, buy_count, add_count, half_time}
	local progressValue = {}
	for i,v in ipairs(mttValue) do
		for j,val in ipairs(v) do
			if val == valueTab[i] then
				local value = j
				if value == 1 then
					value = 0
				end
				progressValue[#progressValue+1] = value
				break
			end
		end
	end
	
	local tslider = {}

	local setLabel = {}
	local setStr = {}
	local function sliderChange( sender )
		local tag = sender:getTag()
		local idx = math.floor(sender:getValue())
		-- print("tag: "..tag)
		-- print("idx: "..idx)
		local value = mttValue[tag][idx]
		-- print("value: "..value)
		-- if tag == 1 then
		-- 	limitPlayer = value
		-- else
		if tag == 1 then
			entry_stop = value
		elseif tag == 2 then
			buy_count = value
		elseif tag == 3 then
			add_count = value
		elseif tag == 4 then
			half_time = value
		-- elseif tag == 6 then
		-- 	awardScale = value.num
		end

		local str = ""
		str = value
		if value == 0 then
			if tag == 3 then
				str = "未开启"
			elseif tag == 4 then
				str = "中场不休息"
			end
			setStr[tag]:setString(str)
		else
			if tag == 1 then
				-- if mtt_type == 2 then
				-- 	mttValue[6] = SetModel.getMttAward( value )
				-- 	-- dump(mttValue[6])
				-- 	tslider[6]:setMaximumValue(#mttValue[6]+0.9)
				-- 	tslider[6]:setValue(1.1)
				-- 	awardScale = mttValue[6][1]["num"]
				-- 	local str1 = tostring(mttValue[6][1]["num"])..'('..tostring(mttValue[6][1]["scaleNum"])..'%)'
				-- 	setStr[6]:setString(str1)
				-- end
			elseif tag == 3 then
				str = value.."倍带入"
			elseif tag == 4 then
				str = value.."分钟"
			-- elseif tag == 6 then
			-- 	str = tostring(value.num)..'('..tostring(value.scaleNum)..'%)'
			end
		end
		setStr[tag]:setString(str)
	end
	for i=1,#setText do
		setLabel[i] = UIUtil.addLabelArial(setText[i]..":", 30, cc.p(20, nodeH-40-(i-1)*130), cc.p(0, 0.5), node):setColor(ResLib.COLOR_GREY)
		local str = ""
		str = valueTab[i]
		if str == 0 then
			if i == 3 then
				str = "未开启"
			elseif i == 4 then
				str = "中场不休息"
			end
		else
			-- if i == 6 then
			-- 	str = tostring(str.num)..'('..tostring(str.scaleNum)..'%)'
			-- end
		end
		setStr[i] = UIUtil.addLabelArial(str, 30, cc.p(setLabel[i]:getPositionX()+setLabel[i]:getContentSize().width+10, nodeH-40-(i-1)*130), cc.p(0, 0.5), node):setColor(color_yellow)

		UIUtil.addLabelArial(desText[i], 18, cc.p(display.width-38, nodeH-40-(i-1)*130), cc.p(1, 0.5), node):setColor(ResLib.COLOR_GREY)

		local imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}
		local maxLen = #mttValue[i] + 0.9
		tslider[i] = UIUtil.addSlider(imgs, cc.p(display.width/2, nodeH-100-(i-1)*130), node, sliderChange, 1.1, maxLen):setTag(i)
		tslider[i]:setAnchorPoint(0.5,0.5)
		tslider[i]:setValue(progressValue[i])
	end

	--[[if mtt_type == 2 then
		-- 奖励表
		local function awardfunc(  )
			local mttAward = require("common.mttAward").new( limitPlayer, awardScale, _entryFee, function ( data )
				-- dump(data)
				local str1 = tostring(data["num"])..'('..tostring(data["scaleNum"])..'%)'
				setStr[6]:setString(str1)
				for i,v in ipairs(mttValue[6]) do
					if v.num == data.num then
						local value = i+0.9
						tslider[6]:setValue(value)
						break
					end
				end
				awardScale = data.num
			end )
			self:addChild(mttAward, 10)
		end
		UIUtil.addImageBtn({norImg = "common/card_mtt_blue_btn.png", selImg = "common/card_mtt_blue_btn.png", disImg = "common/com_icon_ask.png", text="奖励表", ah=cc.p(1, 0.5), pos = cc.p(display.width-38, nodeH-40-(6-1)*130), scale9=true, size=cc.size(150, 50), touch = true, listener = awardfunc, parent = node})
	end--]]
	
end

-- 战队PK
function SetCards:addTeamSet( node, flag )
	if not flag then
		return
	end

	local nodeH = node:getContentSize().height

	local teamLabel = nil
	local function checkBoxFunc( sender, eventType )
		if eventType == 0 then
			teamLabel:setColor(ResLib.COLOR_BLUE)
			isTeam = 1
		else
			teamLabel:setColor(ResLib.COLOR_GREY)
			isTeam = 0
		end
	end
	local teamBox = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(20, nodeH/2), checkboxFunc = checkBoxFunc, parent = node})
	if isTeam == 1 then
		teamBox:setSelectedState(true)
	else
		teamBox:setSelectedState(false)
	end
	teamLabel = UIUtil.addLabelArial("战队PK", 30, cc.p(70, nodeH/2), cc.p(0, 0.5), node):setColor(ResLib.COLOR_GREY)

	UIUtil.addLabelArial("只有加入战队的玩家可参加比赛", 26, cc.p(display.width-20, nodeH/2), cc.p(1, 0.5), node):setColor(ResLib.COLOR_GREY)
end

function SetCards.updateKeepCount(  )
	-- MTT 固定+浮动更新奖池分配 保底人数
	local count = SetModel.getPondCount()
	print(">>>>>>>>>>当前保底人数"..count)
	keepLabel:setString(count)
	keepSlider:setValue(count)
end

function SetCards.updateOrgBlind( params )
	-- dump(params)
	orgBlindStr:setString(tostring(params.blindLevel).."/"..tostring(params.blindLevel*2))
	local blind = DZConfig.getBlindLevel()
	local value = 1.1
	for i,v in ipairs(blind) do
		if v == params.blindLevel*2 then
			value = i+0.9
			break
		end
	end
	orgBlindSlider:setValue(value)

	blindBox[params.blindType]:setSelectedState(true)
	blindBox[params.blindType]:setTouchEnabled(false)
	blindLabel[params.blindType]:setColor(ResLib.COLOR_BLUE)
	if params.blindType == 1 then
		if blindBox[2]:isSelected() then
			blindBox[2]:setSelectedState(false)
			blindBox[2]:setTouchEnabled(true)
			blindLabel[2]:setColor(ResLib.COLOR_GREY)
		end
	else
		if blindBox[1]:isSelected() then
			blindBox[1]:setSelectedState(false)
			blindBox[1]:setTouchEnabled(true)
			blindLabel[1]:setColor(ResLib.COLOR_GREY)
		end
	end
	
	orgBlind = params.blindLevel
	blindType = params.blindType
end

function SetCards:popStopLevel( parent, pos )
	-- 截止盲注级别介绍
	if popStopLevel then
		popStopLevel:removeFromParent()
		popStopLevel = nil
		return
	end
	popStopLevel = UIUtil.addImageView({image="common/set_card_MTT_ask_bg.png", touch=false, ah = cc.p(0.5,1), pos=pos, parent=parent})
	UIUtil.addLabelArial('盲注涨至此级别后终止报名参赛', 30, cc.p(10, popStopLevel:getContentSize().height-50), cc.p(0, 0.5), popStopLevel)
	UIUtil.addLabelArial('盲注涨至此级别时可增购1次，此级别前可重构...', 30, cc.p(10, popStopLevel:getContentSize().height-100), cc.p(0, 0.5), popStopLevel)
end


-- 开始普通牌局
function SetCards:beginNormalCards(  )
	if card_name == nil or card_name == "" then
		ViewCtrol.showTip({content = "请输入牌局名称"})
		return
	else
		if not cc.LuaHelp:IsGameName(card_name) or string.len(card_name) > LEN_CARD then
			ViewCtrol.showTip({content = "牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！"})
			return
		end
	end
	local gName = card_name

	--[[if CARD_TARGET == "union" then
		shareClubs = SelectCtrol.getSelectClub()
		if next(shareClubs) == nil then
			ViewCtrol.showTip({content = "请选择牌局分享俱乐部否则无法创建牌局"})
			return
		end
	end--]]

	if CARD_TARGET == "person" then
		local function funcBack(  )
			Callback()
		end
		local tab = {}
		tab["tag"] = StatusCode.BUILD_STANDARD
		tab["gameName"] = gName
		tab["gameTime"] = cTime
		tab["numOne"] = big_blind
		tab["isSAuthorize"] = is_access
		tab["playerNum"] = peopleNum
		tab["gameMod"] = gameModel
		tab["anteNum"] = anteNum
		tab["openStraddle"] = openStraddle
		tab["openIP"] = openIP
		tab["openGPS"] = openGPS
		MainCtrol.startGameFilterType(tab, funcBack)
		return
	end

	local function response(data)
		-- dump(data)
		if data.code == 0 then
			if CARD_TARGET == "union" then
				NoticeCtrol.removeNoticeById(20003)
				NoticeCtrol.removeNoticeById(20004)
				NoticeCtrol.removeNoticeById(30003)
				--[[local MessageCtorl = require("message.MessageCtorl")
				local ClubCtrol = require("club.ClubCtrol")
				local tdata = ClubCtrol.getClubInfo(  )
				for i,v in ipairs(shareClubs) do
					if tonumber(v) == tonumber(tdata["id"]) then
						MessageCtorl.setChatData(tdata["id"])
						MessageCtorl.setChatType(MessageCtorl.CHAT_CLUB)

						local Message = require('message.MessageScene')
						Message.startScene()
						break
					else
						if i == #shareClubs then
							local CardScene = require("cards.CardScene")
							CardScene:startScene()
						end
					end
				end--]]
				self:removeFromParent()
			else
				self:removeFromParent()
				showGroup()
			end
		end
	end
	local tabData = {}
	tabData["is_access"] 	= is_access
	tabData["name"] 		= gName
	tabData["life_time"]	= cTime * 60 * 60
	tabData["big_blind"]	= big_blind
	tabData["game_mod"]		= CARD_TYPE[CARD_TARGET].NOR
	tabData["org_id"] 		= org_id
	tabData["limit_players"] 	= peopleNum
	tabData["secure"] 		= gameModel
	tabData["ante"] 		= anteNum
	tabData["open_straddle"] = openStraddle
	tabData["open_ip"] = openIP
	tabData["open_gps"] = openGPS
	if CARD_TARGET == "union" then
		-- tabData["share_clubs"] = shareClubs
		tabData["diamonds"] = diamonds
	end
	dump(tabData)
	XMLHttp.requestHttp("createGame", tabData, response, PHP_POST)
end

-- 开始SNG牌局
function SetCards:beginSNGCards(  )
	-- local name_str = Single:playerModel():getPName() .. "的牌局"
	if card_name == nil or card_name == "" then
		ViewCtrol.showTip({content = "请输入牌局名称"})
		return
	else
		if not cc.LuaHelp:IsGameName(card_name) or string.len(card_name) > LEN_CARD then
			ViewCtrol.showTip({content = "牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！"})
			return
		end
	end
	local gName = card_name

	if CARD_TARGET == "union" then
		shareClubs = {}
		shareClubs = SelectCtrol.getSelectClub()
		if next(shareClubs) == nil then
			ViewCtrol.showTip({content = "请选择牌局分享俱乐部否则无法创建牌局"})
			return
		end
	end

	if CARD_TARGET == "person" then
		local function funcBack(  )
			Callback()
		end
		local tab = {}
		tab["tag"] = StatusCode.BUILD_SNG
		tab["gameName"] = gName
		tab["numOne"] = _entryFee
		tab["beginScores"] = inital_score
		tab["upTime"] = increase_time
		tab["playerNum"] = limit_players
		tab["isSAuthorize"] = is_access
		tab["openIP"] = openIP
		tab["openGPS"] = openGPS
		MainCtrol.startGameFilterType(tab, funcBack)
		return
	end

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			if CARD_TARGET == "union" then
				NoticeCtrol.removeNoticeById(20003)
				NoticeCtrol.removeNoticeById(20004)
				NoticeCtrol.removeNoticeById(30003)
				self:removeFromParent()
			else
				self:removeFromParent()
				showGroup()
			end
		end
	end
	local tabData = {}
	tabData["is_access"] 	= is_access
	tabData["name"] 		= gName
	tabData["game_mod"]		= CARD_TYPE[CARD_TARGET].SNG
	tabData["org_id"] 		= org_id
	tabData["entry_fee"] 	= _entryFee
	tabData["inital_score"] = inital_score
	tabData["increase_time"]= increase_time * 60
	tabData["limit_players"]= limit_players
	tabData["open_ip"] = openIP
	tabData["open_gps"] = openGPS
	if CARD_TARGET == "union" then
		tabData["share_clubs"] = shareClubs
		tabData["diamonds"] = diamonds
	end
	dump(tabData)
	XMLHttp.requestHttp("createGame", tabData, response, PHP_POST)
end

function SetCards:beginMTTCards(  )
	if card_name == nil or card_name == "" then
		ViewCtrol.showTip({content = "请输入牌局名称"})
		return
	else
		if not cc.LuaHelp:IsGameName(card_name) or string.len(card_name) > LEN_CARD then
			ViewCtrol.showTip({content = "牌局名称不能超过"..(LEN_CARD/3).."个汉字或"..LEN_CARD.."个字母、数字！"})
			return
		end
	end
	local gName = card_name
	if play_time == 0 then
		ViewCtrol.showTip({content = "请设置开赛时间"})
		return
	end
	if mtt_type == 1 then

		keep_count = SetModel.getPondCount()
		if keep_count == 0 then
			keep_count = 1
		end
		if awards_count == 0 then
			ViewCtrol.showTip({content = "请设置总奖池金额"})
			return
		end
	end

	if mtt_type == 3 then
		keep_count = SetModel.getPondCount()
		awards_count = SetModel.getPondTab()
		if keep_count == 0 then
			ViewCtrol.showTip({content = "请设置保底人数"})
			return
		end
		if #awards_count == 0 then
			ViewCtrol.showTip({content = "请设置奖励分配"})
			return
		else
			if not SetModel.judegAward(awards_count) then
				ViewCtrol.showTip({content = "奖励分配的奖金不能为0"})
				return
			end
		end
	end

	if CARD_TARGET == "union" then
		shareClubs = {}
		shareClubs = SelectCtrol.getSelectClub()
		if next(shareClubs) == nil then
			ViewCtrol.showTip({content = "请选择牌局分享俱乐部否则无法创建牌局"})
			return
		end
	end

	local tabData = {}
	tabData["game_mod"] = CARD_TYPE[CARD_TARGET].MTT
	tabData["mtt_type"] = mtt_type
	if mtt_type == 1 or mtt_type == 3 then
		tabData["awards_count"] = awards_count
		tabData["keep_count"] = keep_count
	end
	tabData["mtt_name"] = gName
	tabData["entry_fee"] = _entryFee
	tabData["inital_score"] = inital_score
	tabData["increase_time"] = increase_time*60
	tabData["play_time"] = play_time
	tabData["is_access"] = is_access
	tabData["entry_stop"] = entry_stop
	tabData["buy_count"] = buy_count
	tabData["add_mult"] = add_count
	if add_count > 0 then
		tabData["add_count"] = 1
	else
		tabData["add_count"] = 0
	end
	tabData["half_time"] = half_time*60
	tabData["is_open"] = publicGame
	tabData["mtt_description"] = mttDes
	if blindType==1 then
		--普通
		tabData["blind_type"] = 1
	else
		tabData["blind_type"] = 0
	end
	tabData["open_ip"] = openIP
	tabData["open_gps"] = openGPS
	tabData["small_blind"] = orgBlind
	tabData["players_limited_num"] = limitPlayer
	
	local managers = {}
	if is_access == 1 then
		managers = SetModel.getManager()
	end
	tabData["mtt_managers"] = managers

	-- create_fee, mtt_managers 存放分享俱乐部ID，is_team
	if CARD_TARGET == "union" then
		tabData["mtt_managers"] = shareClubs
		tabData["create_fee"] = diamonds
		tabData["is_team"] = isTeam
	end
	if CARD_TARGET == "club" or CARD_TARGET == "circle" or CARD_TARGET == "union" then
		tabData["fid"] = org_id
	end
	
	if CARD_TARGET == "person" then
		local function funcBack( )
			Callback()
		end
		local tab = {}
		tab = tabData
		tab["tag"] = StatusCode.BUILD_MTT
		MainCtrol.startGameFilterType(tab, funcBack)
		return
	end

	local function response( data )
		-- dump(data)
		if data.code == 0 then
			require ('main.SearchManagerLayer'):clearManagerData()
			if CARD_TARGET == "union" then
				NoticeCtrol.removeNoticeById(20003)
				NoticeCtrol.removeNoticeById(20004)
				NoticeCtrol.removeNoticeById(30003)
				self:removeFromParent()

			else
				self:removeFromParent()
				showGroup()
			end
		end
	end
	dump(tabData)
	XMLHttp.requestHttp("createMtt", tabData, response, PHP_POST)
end

function SetCards:clearData(  )
	-- 牌局名称
	card_name = nil
	name_str = ""
	
	-- 授权报名（0表示不授权，1表示授权）
	is_access = nil

	-- 牌局时间
	cTime = nil

	-- 牌局人数
	peopleNum = nil

	-- ante
	anteNum = nil

	-- 游戏模式
	gameModel = nil

	-- 大盲
	big_blind = nil

	-- 带入记分牌
	scores_num = nil

	-- 记录费
	record_num = nil
	--[[   创建SNG牌局   ]]
	-- 报名费
	entry_fee = nil
	_entryFee = nil

	-- 起始记分牌
	inital_score = nil

	-- 升盲时间
	increase_time = nil

	-- 参赛人数
	limit_players = nil

	-- layer_MTT = nil

	openStraddle = 0

	openIP = 0

	openGPS = 0

	shareClubs = {}

	diamonds = nil
end

function SetCards:initMTTdata(  )
	-- [[	创建MTT		]]
	-- UI

	-- layer_MTT = nil
	popStopLevel = nil
	keepLabel = nil
	keepSlider = nil
	
	orgBlindStr = nil
	orgBlindSlider = nil
	blindBox = {}
	blindLabel = {}

	-- DATA
	-- MTT牌局模式
	mtt_type = 1

	-- 总奖池金额
	awards_count = 0

	-- 保底人数
	keep_count = 0

	-- 开赛时间
	play_time = 0

	publicGame = 0

	-- 终止报名级别
	entry_stop = 1

	-- 0表示关闭
	-- 重构次数
	buy_count = 0

	-- 增购次数
	add_count = 0

	-- 中场休息时间
	half_time = 0

	-- 赛事简介
	mttDes = ""

	-- 起始盲注级别
	orgBlind = 0

	-- 盲注表类型
	blindType = 1

	-- 人数上限
	limitPlayer = 6

	-- 奖励范围
	awardScale = 1

	-- 是否开启战队pk
	isTeam = 0
end

-- target club 俱乐部、 circle 圈子 union 联盟
function SetCards:createLayer( orgid, target )
	_setCards = self
	_setCards:setSwallowTouches()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)

	local pId = Single:playerModel():getId()
	STANDARD_NAME 	= 'STANDARD_NAME'..pId
	SNG_NAME 		= 'SNG_NAME'..pId
	MTT_NAME 		= 'MTT_NAME'..pId

	imageView = nil
	curNode = nil
	norBtn = nil
	sngBtn = nil
	org_id = nil

	_retData = nil

	scrollView_MTT = nil

	org_id = orgid

	CARD_TARGET = target

	self:clearData()
	self:initMTTdata()

	self:buildLayer()
end

return SetCards