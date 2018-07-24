--table改位置请搜索 在这改tableView
-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001
local ViewBase = require("ui.ViewBase")
local ResultMsg = class("ResultMsg", ViewBase)
local _csize = cc.size(display.width, 133)
local _data = {}
local _tablev = nil
local _tableLayer = nil
local _img9 = nil
local _pid = nil--当前牌局id

local cs  = nil --ccs界面索引
local bg1 = nil --
local bg2 = nil 

local _manager_type = nil--管理员类型
local _is_access = nil   -- 审核
local _create_way = nil  -- 来源
local _is_manager = nil  --管理员
local _is_insurance = nil -- 是否保险
local _mod = nil --游戏模式

 --FIXED TO完全与服务器相同的game_mod，服务器有时传的数字，有时是字符串，其定义应该与mod相同
local _game_mod = nil

local _pokerTitle = nil
local vtScheduler = cc.Director:getInstance():getScheduler()

function ResultMsg:shareImgByUrl(fromText, gamemode)
	-- 1. general 2. sng  3. headup  4. mtat
	local function response(data) 
		dump(data)
		local tab = {}
		tab['content'] = ""
		tab['weburl'] = XMLHttp.getHttpUrl()..data['data']['filename']
		if gamemode == 4 then 
			tab['title'] = "MTT战局详情"
		elseif gamemode == 2 then 
			tab['title'] = "SNG战绩详情"
		elseif gamemode == 1 then 
			tab['title'] = "标准战绩详情"
		end 
		tab['desc'] = "分享自我的战绩 -- 战绩统计 -- \""..tostring(fromText).."\"战局详细"
		print("WEBURL"..tostring(tab['weburl']))
		DZWindow.shareDialog(DZWindow.SHARE_MTTURL, tab)
	end

	local token = XMLHttp.getGameToken()
	local url = nil
	if gamemode == 4 then 
		url = "share?token="..token.."&mtt_id=".._pid
	else 
		url = "shareNotMtt?token="..token.."&p_id=".._pid
	end
	print("url:"..url.."    isMtt:"..tostring(isMtt))
	XMLHttp.requestHttp(url, {}, response, PHP_POST)
end

function ResultMsg:shareImg()
		-- os.rmdir(cc.FileUtils:getInstance():getWritablePath(), FileType.IMAGE, true)
		-- do return end
		local target = cc.RenderTexture:create(display.width, display.height-134, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	    target:setAnchorPoint(0,0)
	    target:setPosition(0,0)
	    self:addChild(target)

	    target:begin()
	    _img9:visit()
	    _tablev:getContainer():visit()
	    target:endToLua()

		local sharePng = DZConfig.getShareImgName()
		target:saveToFile(sharePng, cc.IMAGE_FORMAT_PNG)
	    target:removeFromParent()

		local imgPath = cc.FileUtils:getInstance():getWritablePath()..sharePng
		print("imgPath:"..tostring(imgPath))
		local tab = {}
		tab['imgPath'] = imgPath
		DZWindow.shareDialog(DZWindow.SHARE_IMG, tab)
end

--加工俱乐部数据
local function processesClubData(data,ctlsrc)
	local supplyData = {
					['adminType'] = _manager_type,
					['createWay'] = _create_way,
					['isInsure'] = _is_insurance,
					['mod'] = _mod,
					['ctlsrc'] = ctlsrc,
					['clubdata'] = data,
					['pid']  = _pid,
					['game_mod'] = _game_mod,
		    	 	['pokerTitle'] = _pokerTitle
		    	 }
    return supplyData
end

--查看审核
local function lookAuthorizeHandler(event)
	-- local isMtt = ResultCtrol.isMtt(_mod)
	--如何是联盟
	local isUnion = ResultCtrol.isUnionCreate(_create_way)
	local isClub = ResultCtrol.isClubCreate(_create_way)
	print("isUnion"..tostring(isUnion), _create_way)
	print("isCLub"..tostring(isClub))
	if (isUnion or isClub) then --or ResultCtrol.isMtt(_mod) 
		
		local callback = function(data)
			print("俱乐部审核")
			--test
			-- local TestCase = require('utils.TestCaseMessage')
			-- local data = TestCase.getStatsitic()
			local clubData = processesClubData(data['data'], 2)
			require('result.ClubsListView').show(nil, clubData)
		end
		
		ResultCtrol.sendRequireClubList(_pid,_game_mod, _manager_type, 2, callback)
	else 
		 local testly = require('main.CheckAllManagerLayer'):create(_pid)
  		 cc.Director:getInstance():getRunningScene():addChild(testly)
	end
end

--查看俱乐部统计
local function lookStatsiticHandler(event)
	print("haha")
	print("_create_way:".._create_way)
	if ResultCtrol.isUnionCreate(_create_way) then 
		
		local callback = function(data)
			-- local TestCase = require('utils.TestCaseMessage')
			-- local data = TestCase.getStatsitic()
			local clubData = processesClubData(data['data'], 1)
			require('result.ClubsListView').show(nil, clubData)	
		end
		ResultCtrol.sendRequireClubList(_pid,_game_mod, _manager_type, 1, callback)
	end
end

--旧的保险详情
local function presentLocalInsurance(data1)
	local bxData = {}
	bxData.name = data1['myName']
	bxData.from = data1['pokerFrom']
	bxData["dataList"] = {}

	for i = 1, #_data do
		local tdata = _data[ i ]
		bxData["dataList"][i] = {}
		bxData["dataList"][i].url = tdata['pheadUrls']
		bxData["dataList"][i].name = tdata['name']
		bxData["dataList"][i].poolNum = tdata['insurance_pool']
		bxData["dataList"][i].playerID = tdata['playerID']
		bxData["dataList"][i].pid = _pid
    end
	print("show List")
	--dump(bxData["dataList"])
	dump(bxData["dataList"][1])
	--dump(bxData["dataList"][1].insurance_detail)
	require("result.ShowBXListLayer"):create(bxData)
end
--查看保险
local function lookInsuranceInfoHandler(event, data1)
	local isClub = ResultCtrol.isClubCreate(_create_way)
	local isUnion = ResultCtrol.isUnionCreate(_create_way)
	if (isClub or isUnion) and _is_manager then 
		local callback = function(data)
			dump('', '俱乐部保险')
			-- local TestCase = require('utils.TestCaseMessage')
			-- local data = TestCase.getStatsitic()
			local clubData = processesClubData(data['data'], 3)
			require('result.ClubsListView').show(nil, clubData)
		end
		ResultCtrol.sendRequireClubList(_pid,_game_mod, _manager_type, 3, callback)
	else 
		presentLocalInsurance(data1)
	end
end

----------------------------------------------------------------------------------------
------------------------------------------------------------------
--- 初始化Init View
----------------------------------------------------------------------------------------
local function addCellLayer(idx, layer)
	local tdata = _data[ idx ]
	local ch = _csize.height / 2
	local th = _csize.height
	--dump(tdata)
	--如果是自己，就高亮显示
	local cImg = "result/result_tagbg.png" 
	local meId = Single:playerModel():getId()
	print("tData:",tdata['playerID'], meId)
	if(tonumber(tdata["playerID"]) == tonumber(meId)) then
		local bg = UIUtil.scale9Sprite(cc.rect(5,5,5,5), 'result/result_cellbg.png', _csize, cc.p(0,0), layer)
		bg:setAnchorPoint(0,0)
		cImg = "result/result_tagbg1.png"
	end
	
	--竖线
	local offsetX = 34
	local img = 'result/result_line1.png'
	local vertical = UIUtil.scale9Sprite(cc.rect(0,0,0,0), img, cc.size(2,th), cc.p(60+offsetX,0), layer)
	vertical:setAnchorPoint(0,0)

	--名次小图标，圆形
	local numbg = UIUtil.addPosSprite(cImg, cc.p(60+offsetX,ch), layer, cc.p(0.5,0.5))
	numbg:setScale(0.6)

	--圈上的文字
	UIUtil.addLabelArial(idx, 23, cc.p(60 + offsetX, ch), cc.p(0.5,0.5), layer, cc.c3b(0,0,0))

	--头像
	local thead = UIUtil.addShaderHead(cc.p(140 + offsetX,ch), tdata['pheadUrls'], layer, function(thead)end)
	thead:setScale(0.4)

	--from
	local offsetY = 24
	if tdata['from'] then 
		UIUtil.addLabelArial(tdata['from'], 26, cc.p(191 + offsetX,ch), cc.p(0,0.5), layer, cc.c3b(170,170,170))
	end
	--名字
	local tNameL = UIUtil.addLabelArial(tdata['name'], 28, cc.p(191 + offsetX,ch + offsetY), cc.p(0,0.5), layer, cc.c3b(255,255,255))
	
	--带入量显示
	UIUtil.addLabelArial(tdata['betText'], 26, cc.p(191 + offsetX,ch - offsetY), cc.p(0,0.5), layer, cc.c3b(170,170,170))
	

	--输赢分数
	local color = cc.c3b(0,133,60)
	local text = tdata['scoring']
	if text > 0 then
		color = cc.c3b(204,0,1)
		text = '+'..text
	elseif text == 0 then 
		color = cc.c3b(177,177,177)
	end
	UIUtil.addLabelArial(text, 32, cc.p(_csize.width-58,th-20), cc.p(1,1), layer, color)

	--先判断有几种情况0-都不存在，1-两个都存在，2-存在增购，3-存在重购
	--["add_on"]
 	--["rebuy_num"]
	local tCase = 0
	if(tdata['add_on'] > 0 and tdata['rebuy_num'] > 0) then
		tCase = 1
	elseif(tdata['add_on'] > 0 and tdata['rebuy_num'] == 0) then
		tCase = 2
	elseif(tdata['add_on'] == 0 and tdata['rebuy_num'] > 0) then
		tCase = 3
	end

	--R,A 1-两个都存在
	if(tCase == 1) then
        local imageViewA = ccui.ImageView:create()
        --imageViewA:setScale9Enabled(true)
        imageViewA:loadTexture("result/r_s9.png")
        --imageViewA:setContentSize(cc.size(200, 85))
        imageViewA:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
        imageViewA:setColor(cc.c3b(26,255,150))
        UIUtil.addLabelArial("A", 30, cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25,25,25))
        layer:addChild(imageViewA)

        local imageViewR = ccui.ImageView:create()
        local tLen = string.len(tostring(tdata['rebuy_num']))
        imageViewR:setScale9Enabled(true)
        imageViewR:loadTexture("result/r_s9.png")
        imageViewR:setContentSize(cc.size(imageViewA:getContentSize().width + tLen*8, imageViewA:getContentSize().height))
        imageViewR:setPosition(cc.p(imageViewA:getPositionX() + imageViewA:getContentSize().width/2 + imageViewR:getContentSize().width/2 + 10, tNameL:getPositionY()))
        imageViewR:setColor(cc.c3b(252,215,54))
        UIUtil.addLabelArial("R", 30, cc.p(imageViewA:getContentSize().width/2, imageViewR:getContentSize().height/2), cc.p(0.5, 0.5), imageViewR, cc.c3b(25,25,25))
        UIUtil.addLabelArial(tdata['rebuy_num'], 15, cc.p(imageViewA:getContentSize().width/2 + 10, imageViewR:getContentSize().height/2 - 10), cc.p(0.0, 0.5), imageViewR, cc.c3b(25,25,25))
        layer:addChild(imageViewR)
    --2-存在增购A
	elseif(tCase == 2) then
		local imageViewA = ccui.ImageView:create()
        --imageViewA:setScale9Enabled(true)
        imageViewA:loadTexture("result/r_s9.png")
        --imageViewA:setContentSize(cc.size(200, 85))
        imageViewA:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewA:getContentSize().width/2 + 10, tNameL:getPositionY()))
        imageViewA:setColor(cc.c3b(26,255,150))
        UIUtil.addLabelArial("A", 30, cc.p(imageViewA:getContentSize().width/2, imageViewA:getContentSize().height/2), cc.p(0.5, 0.5), imageViewA, cc.c3b(25,25,25))
        layer:addChild(imageViewA)
	--3-存在重购R
	elseif(tCase == 3) then
		local imageViewR = ccui.ImageView:create()
        local tLen = string.len(tostring(tdata['rebuy_num']))
        imageViewR:setScale9Enabled(true)
        imageViewR:loadTexture("result/r_s9.png")
        local tW = imageViewR:getContentSize().width
        imageViewR:setContentSize(cc.size(imageViewR:getContentSize().width + tLen*8, imageViewR:getContentSize().height))
        imageViewR:setPosition(cc.p(tNameL:getPositionX() + tNameL:getContentSize().width + imageViewR:getContentSize().width/2 + 10, tNameL:getPositionY()))
        imageViewR:setColor(cc.c3b(252,215,54))
        UIUtil.addLabelArial("R", 30, cc.p(tW/2, imageViewR:getContentSize().height/2), cc.p(0.5, 0.5), imageViewR, cc.c3b(25,25,25))
        UIUtil.addLabelArial(tdata['rebuy_num'], 15, cc.p(tW/2 + 10, imageViewR:getContentSize().height/2 - 10), cc.p(0.0, 0.5), imageViewR, cc.c3b(25,25,25))
        layer:addChild(imageViewR)
	end
end

local function addTableLayer(idx, layer)
	layer:addChild(_tableLayer)
end
--初始化界面Navigation bar标题
function ResultMsg:initTitleView(title,mod)
	local titleY = 1250
	local tnode = cc.Node:create()
	self:addChild(tnode)

	--添加标题头
    local titSp = UIUtil.addPosSprite('result/rdi.png', cc.p(0,titleY - 50), tnode, nil)
	titSp:setAnchorPoint(cc.p(0,0))
	titSp:setLocalZOrder(0)

    tnode:setPositionY(-G_SURPLUS_H)
	local img = ResLib.COM_OPACITY0

	local ttfcfg1 = cc.Label:createWithSystemFont("分享", "Marker Felt", 32)
	UIUtil.controlBtn(img, img, img, ttfcfg1, cc.p(690,titleY), cc.size(56,56), function()
   			-- if data1['mod'] == 4 then  
	   			self:shareImgByUrl(title, mod)
	   		-- else
		   	-- 	self:shareImg() 
	   		-- end
		end, tnode)

    UIUtil.addLabelArial(title, 35, cc.p(display.cx,titleY), cc.p(0.5,0.5), tnode, cc.c3b(255,255,255))

	local ttfcfg2 = cc.Label:createWithSystemFont("", "Marker Felt", 32)
    UIUtil.controlBtn(img, img, img, ttfcfg2, cc.p(30,titleY), cc.size(56,56), function()
    	require ('result.ResultScene'):showT()
    	self:removeFromParent()
		end, tnode)
    UIUtil.addPosSprite(ResLib.BTN_BACK, cc.p(30,titleY), tnode, nil)
end

function ResultMsg:createLayer(data1)
	--是否开启授权，创建来源，管理员类型
	dump(data1, "瓦塔西瓦")
    _is_access, _create_way  = data1['is_access'], data1['create_way']
    _is_manager, _is_insurance = data1['is_manager'], data1['secure']
    _manager_type =  data1['manager_type']
    _mod = data1['mod']
    _game_mod = data1['game_mod']
    _pokerTitle = data1['title']
   	
   	local isLookAuthorize,isGroupManager,isMttManager = ResultCtrol.isPresentAuthorize(_create_way, _mod, _is_access, _is_manager)
	local isLookClubs = ResultCtrol.isPresentClubStatistic(_create_way, _is_manager, manager_type)
	
	require ('result.ResultScene'):hideT()
	local black = cc.LayerColor:create(cc.c3b(0,0,0))
	self:addChild(black)
	--title
	self:initTitleView(data1['title'], data1['mod'])
    --TableView Bg
    local size9 = cc.size(display.width, 600)
    local img9 = UIUtil.scale9Sprite(cc.rect(0,0,0,0), 'result/result_black5.png', size9, cc.p(0,0), black)
    img9:setAnchorPoint(0,0)
    img9:setColor(cc.c3b(0,0,0))
    _img9 = img9

    --处理scroll容器坐标偏移  以及 初始化
    local csH, lineH = 649, 36 --csh:ccs界面高， lineH 头向下的单行的详细面板偏移
	--在这改tableView
	local tableH = #_data * _csize.height + 133 + 85 + 33-- + 60是有保险情况 85=头向下详细面板高 33=将table上移
	--没保险情况
	if(_is_insurance ~= 1) then
		tableH = #_data * _csize.height + 85+33
		--mtt --220
		if ResultCtrol.isMtt(_mod) then
			tableH = #_data * _csize.height + 182+33 -- 220 头像下双行的面板高
		end	
	end
	local scrollH = csH + lineH + tableH
	local scrollLayer = cc.LayerColor:create(cc.c4b(0,0,0,0), display.width, scrollH)
	_tableLayer = scrollLayer
	--cs
    cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.RMSG_LAYER_CSB)
    scrollLayer:addChild(cs, 999)
    cs:setPositionY(lineH + tableH)
  
    bg1 = cs:getChildByName('imgbg1')
	local csbg2 = cs:getChildByName('imgBgTwo')
	bg2 = csbg2:getChildByName('imgBg2')
	local blue = bg2:getChildByName('blueBg')
	local red = bg2:getChildByName('redBg')
	local green = bg2:getChildByName('greenBg')

	local ttfst = bg1:getChildByName('ttfStartTime')
	local ttfn = bg1:getChildByName('ttfName')
	local ttfb = bg1:getChildByName('ttfBet')--盲注
	local ttpNum = bg1:getChildByName('ttfPeopleNum')
	local rsbgbg = bg2:getChildByName('Image_rsbgbg')
	ttfst:setString(data1['time'])
	if data1['myName'] then
		ttfn:setString(data1['myName'])
	else
		Single:appLogsJson('ResultMsg:createLayer  ', data1)
	end
	ttfb:setString(data1['betNum'])
	-- ttfst:setPositionY(ttfst:getPositionY() - 90)--头像边上的时间
	-- ttfst:setPositionX(ttfst:getPositionX() + 35)
	-- ttfn:setPositionY(ttfn:getPositionY() - 30)--头像边上的名称
	-- ttfn:setPositionX(ttfn:getPositionX() - 115)
	-- ttfb:setPositionY(ttfb:getPositionY() - 45)
	
	

	--Mtt显示参赛人数
	if(ResultCtrol.isMtt(_mod)) then
		--del
		ttpNum:setString("参赛人数: "..#_data)
		ttpNum:setVisible(true)
		ttpNum:setPositionX(ttfb:getPositionX())
	else
		-- ttfb:setPositionX(ttfb:getPositionX() + 60)
	end

	bg1:getChildByName('ttfPokerName'):setString(data1['pokerText']) --del
	-- local fx = bg1:getChildByName('ttfCode'):getPositionX()
	-- bg1:getChildByName('ttfCode'):setPositionX(fx + 114)--头像边上的来自XXX
	-- bg1:getChildByName('ttfCode'):setPositionY(bg1:getChildByName('ttfCode'):getPositionY() + 15)
	bg1:getChildByName('ttfCode'):setString(data1['pokerFrom'])
	--有保险情况
	if(data1['secure'] == 1) then
		local ttfCodePanel = bg1:getChildByName('ttfCode')
		bg1:getChildByName("Image_bx"):setPositionX(ttfCodePanel:getPositionX() + ttfCodePanel:getContentSize().width/2+2)
		bg1:getChildByName("Image_bx"):setVisible(true)
		bg2:getChildByName('Panel_bxc'):setVisible(true)
	--没保险情况
	else
		bg1:getChildByName("Image_bx"):setVisible(false)
		bg2:getChildByName('Panel_bxc'):setVisible(false)
	end
	--头像
	local headIcon = bg1:getChildByName('headIcon')
	local thead = UIUtil.addShaderHead(cc.p(headIcon:getPositionX(),headIcon:getPositionY()), data1['headUrl'], bg1, function(thead)end)
	thead:setScale(0.5)

	bg2:getChildByName('ttfTimeVal'):setString(data1['pokerTime'])
	bg2:getChildByName('ttfNumVal'):setString(data1['allNum'])
	bg2:getChildByName('ttfBetVal'):setString(data1['allBet'])

	--初始化保险池相关内容
	local tpbx = bg2:getChildByName('Panel_bxc')
	tpbx:touchEnded(function ( event )
		lookInsuranceInfoHandler(event, data1)
	end)

	--保险池
	local tnumber = tonumber(data1['insurance_pool_all'])
	local tcolor = cc.c3b(255,255,255)
	if(tnumber > 0) then
		tcolor = cc.c3b(204,0,1)
	elseif(tnumber < 0) then
		tcolor = cc.c3b(0,133,60)
	end

	local  strNum = tostring(data1['insurance_pool_all'])
	if(tnumber > 0) then
		strNum = '+'..tostring(data1['insurance_pool_all'])
	end
	
	ccui.Helper:seekWidgetByName(tpbx, "Text_tpool"):setString(strNum)
	ccui.Helper:seekWidgetByName(tpbx, "Text_tpool"):setColor(tcolor)

	--获胜奖励部分
	--文字
	local redLabel = red:getChildByName('redTagBg'):getChildByName('Text_38')
	local greenLabel = green:getChildByName('greenTagBg'):getChildByName('Text_39')
	local blueLabel = blue:getChildByName('blueTagBg'):getChildByName('Text_37')
	
	--图片标签
	local redImg = red:getChildByName('redTagBg'):getChildByName('result_mvp_18')
	local greenImg = green:getChildByName('greenTagBg'):getChildByName('result_money_19')
	local blueImg = blue:getChildByName('blueTagBg'):getChildByName('result_fish_17')

	red:setVisible(false)
	green:setVisible(false)
	blue:setVisible(false)

	local posTable = {red:getPosition(), green:getPosition(), blue:getPosition()}
	--sng比赛显示 或者mtt
	local names = data1['resultArr']
	local urls = data1['urls']
	-- print("asdasdas33333=="..data1['mod']..' '..data1['showPNum'])
	if (data1['mod'] == 2 or data1['mod'] == 4) then
		bg2:getChildByName('ttfBetText'):setString("总奖池")
		redImg:setTexture("result/result_champion.png")
		greenImg:setTexture("result/result_look.png")
		blueImg:setTexture("result/result_tong.png")

		if data1['showPNum'] == 2 then
			red:getChildByName('redName'):setString(names[1])
			green:getChildByName('greenName'):setString(names[3])
			blue:getChildByName('blueName'):setString(names[2])
			red:setVisible(true)
			blue:setVisible(true)
			green:setVisible(true)

			local thead = UIUtil.addShaderHead(cc.p(53,109 - 58), urls[1], red, function(thead)end)
			thead:setScale(0.45)
			local thead = UIUtil.addShaderHead(cc.p(41,79 - 39), urls[3], green, function(thead)end)
			thead:setScale(0.35)
			local thead = UIUtil.addShaderHead(cc.p(41,81 - 39), urls[2], blue, function(thead)end)
			thead:setScale(0.35)
		elseif data1['showPNum'] > 2 and data1['showPNum'] <= 6 then
		
			if(data1['mod'] == 4) then
				greenImg:setTexture("result/result_third.png")
			else
				greenImg:setTexture("result/result_tong.png")
			end

			blueImg:setTexture("result/result_second.png")

			red:getChildByName('redName'):setString(names[1])
			green:getChildByName('greenName'):setString(names[3])
			blue:getChildByName('blueName'):setString(names[2])
			red:setVisible(true)
			blue:setVisible(true)
			green:setVisible(true)

			local thead = UIUtil.addShaderHead(cc.p(53,109 - 58), urls[1], red, function(thead)end)
			thead:setScale(0.45)
			local thead = UIUtil.addShaderHead(cc.p(41,79 - 39), urls[3], green, function(thead)end)
			thead:setScale(0.35)
			local thead = UIUtil.addShaderHead(cc.p(41,81 - 39), urls[2], blue, function(thead)end)
			thead:setScale(0.35)

		--elseif data1['showPNum'] == 9 then
		elseif data1['showPNum'] > 6  then
			greenImg:setTexture("result/result_third.png")
			blueImg:setTexture("result/result_second.png")

			red:getChildByName('redName'):setString(names[1])
			green:getChildByName('greenName'):setString(names[3])
			blue:getChildByName('blueName'):setString(names[2])
			red:setVisible(true)
			blue:setVisible(true)
			green:setVisible(true)

			local thead = UIUtil.addShaderHead(cc.p(53,109 - 58), urls[1], red, function(thead)end)
			thead:setScale(0.45)
			local thead = UIUtil.addShaderHead(cc.p(41,79 - 39), urls[3], green, function(thead)end)
			thead:setScale(0.35)
			local thead = UIUtil.addShaderHead(cc.p(41,81 - 39), urls[2], blue, function(thead)end)
			thead:setScale(0.35)
		end

	--标准比赛
	else
		bg2:getChildByName('ttfBetText'):setString("总带入")
		if data1['showPNum'] == 1 then
			red:getChildByName('redName'):setString(names[1])
			red:setPositionX(display.width / 2)
			red:setVisible(true)

			local thead = UIUtil.addShaderHead(cc.p(53,109 - 58), urls[1], red, function(thead)end)
			thead:setScale(0.45)
		
		elseif data1['showPNum'] >= 2 then
			red:getChildByName('redName'):setString(names[1])
			green:getChildByName('greenName'):setString(names[2])
			blue:getChildByName('blueName'):setString(names[3])
			red:setVisible(true)
			blue:setVisible(true)
			green:setVisible(true)

			local thead = UIUtil.addShaderHead(cc.p(53,109 - 58), urls[1], red, function(thead)end)
			thead:setScale(0.45)
			local thead = UIUtil.addShaderHead(cc.p(41,79 - 39), urls[2], green, function(thead)end)
			thead:setScale(0.35)
			local thead = UIUtil.addShaderHead(cc.p(41,81 - 39), urls[3], blue, function(thead)end)
			thead:setScale(0.35)
		end
	end
    
	--line
    local ttfbgImg = 'result/result_black5.png'
	local linepos = cc.p(0,lineH + tableH)
    local linebg = UIUtil.scale9Sprite(cc.rect(0,0,0,0), ttfbgImg, cc.size(display.width,lineH), linepos, scrollLayer)
    linebg:setAnchorPoint(0,1)
	--UIUtil.addLabelArial('玩家', 22, cc.p(185,lineH/2), cc.p(0.5,0.5), linebg, cc.c3b(223,223,125), 'Arial-BoldMT')
	--UIUtil.addLabelArial('计分', 22, cc.p(420,lineH/2), cc.p(0.5,0.5), linebg, cc.c3b(223,223,125), 'Arial-BoldMT')


	--table
	--在这改tableView
    local ty = tableH - _csize.height - 133 - 69 + 33-- -60是有保险情况
    --没保险情况
	if(_is_insurance ~= 1) then
		ty = tableH - _csize.height - 69 + 33 --33
		--mtt -220
		if ResultCtrol.isMtt(_mod) then
			ty = tableH - _csize.height - 182 + 33
		end
	end
	
    local tlayer = cc.LayerColor:create(cc.c4b(0,0,0,0), _csize.width, tableH)
    local tablebg = UIUtil.scale9Sprite(cc.rect(0,0,0,0), ttfbgImg, cc.size(_csize.width,tableH), cc.p(0,0), tlayer)
    tablebg:setAnchorPoint(0,0)
    scrollLayer:addChild(tlayer)
    for i=1,#_data do
    	local clayer = cc.LayerColor:create(cc.c4b(0,0,0,0), _csize.width, _csize.height)
    	addCellLayer(i, clayer)
    	clayer:setPositionY(ty)
    	tlayer:addChild(clayer)
    	ty = ty - _csize.height
    end


    local tsize = cc.size(_csize.width, 1200-G_SURPLUS_H)
	local tablev = UIUtil.addTableView(tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, self)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, cc.size(_csize.width,scrollH), 1, addTableLayer, nil, nil)
    _tablev = tablev
    --_tablev:getContainer():setContentSize(cc.size(_csize.width, scrollH + 120))
    -- _tablev:setInnerContainerSize(cc.size(_csize.width, scrollH + 1160))

	local msgBg = bg2:getChildByName('Image_showMsg')
	msgBg:setVisible(false)

    --Mtt战绩统计界面单独处理
	if(data1['mod'] == 4) then
		ttfb:setVisible(false)
		ttpNum:setVisible(false)
		bg2:getChildByName('ttfTimeVal'):setVisible(false)
		bg2:getChildByName('ttfNumVal'):setVisible(false)
		bg2:getChildByName('ttfBetVal'):setVisible(false)
		bg2:getChildByName('ttfTimeText'):setVisible(false)
		bg2:getChildByName('ttfTNumText'):setVisible(false)
		bg2:getChildByName('ttfBetText'):setVisible(false)
		rsbgbg:setVisible(false)
		bg2:setPositionY(bg2:getPositionY() - 182)
		
		msgBg:setVisible(true)
		msgBg:getChildByName('Text_bmfee'):setString(tostring(data1['bmfee']).."+"..tostring(data1['bmfee']/10))--报名费
		msgBg:getChildByName('Text_bmfeeZJ'):setString(tostring(data1['entry_fee_sum']))--报名费总计
		msgBg:getChildByName('Text_zjc'):setString(data1['allBet'])--总奖池
		msgBg:getChildByName('Text_csrs'):setString(tostring(#_data))--参赛人数
		local tSum = data1['rebuy_num'] + #_data
		local addSum = ""

		if(data1['add_on'] > 0) then
			addSum = "+A"..tostring(data1['add_on'])
		end
		
		msgBg:getChildByName('Text_csrccc'):setString(tostring(tSum)..addSum)--参赛人次
		msgBg:getChildByName('Text_bssc'):setString(data1['pokerTime'])--比赛时长
		msgBg:getChildByName('Text_zss'):setString(tostring(data1['allNum']))--总手数

		local tBet = 20--组建牌局 自定义的初始级别大忙是20
		--游戏大厅 本地化的初始级别大忙是50
		print("asidoasdj=="..data1['from'])
		if(data1['from'] == "本地化" or data1['from'] == "赛场") then
			tBet = 50
		end
		
		msgBg:getChildByName('Text_csjfp'):setString(tostring(data1['inital_score_sum']))--初始记分牌
		msgBg:getChildByName('Text_csjfpBBS'):setString("("..tostring(data1['inital_score_sum']/tBet).." BBS)")--初始记分牌bbs
	else
		bg2:setPositionY(bg2:getPositionY() - 69)
	end

	--是否该显示管理员授权查看按钮和俱乐部统计按钮
	
	local verifyBtn = bg1:getChildByName('verifyBtn')
	local clubsBtn = bg1:getChildByName('clubStatistics')
	local lineVertical = cc.LayerColor:create(cc.c3b(125,126,127))
	lineVertical:setContentSize(cc.size(3,30))
	lineVertical:setAnchorPoint(cc.c3b(.5,0))
	lineVertical:setPosition(cc.p(bg1:getContentSize().width/2, verifyBtn:getPositionY()))
	bg1:addChild(lineVertical, 111)

	clubsBtn:setTouchEnabled(isLookClubs)
	clubsBtn:setVisible(isLookClubs)

	clubsBtn:touchEnded(lookStatsiticHandler) 
	verifyBtn:touchEnded(lookAuthorizeHandler)

	if isGroupManager and not _is_access then --非授权联盟
		verifyBtn:setVisible(true)
		verifyBtn:setTitleColor(cc.c3b(127,127,127))
		verifyBtn:setTouchEnabled(false)
	elseif isLookAuthorize then --正常显示
		verifyBtn:setVisible(true)
	else 
		verifyBtn:setVisible(false)
		verifyBtn:setTouchEnabled(false)
	end

	--两个按钮为nil 向上移动挡住按钮
	lineVertical:setVisible(verifyBtn:isVisible() and clubsBtn:isVisible())
	if not verifyBtn:isVisible() and not clubsBtn:isVisible() then 
		bg2:setPositionY(bg2:getPositionY() + 78)
		tlayer:setPositionY(tlayer:getPositionY() + 78)
	elseif verifyBtn:isVisible() and not clubsBtn:isVisible() then 
		verifyBtn:setPositionX(bg1:getContentSize().width/2)
	elseif not verifyBtn:isVisible() and clubsBtn:isVisible() then 
		verifyBtn:setPositionX(bg1:getContentSize().height/2)
	end
end


function ResultMsg:startResultMsg(parent, oldData, data, pid)
	_pid = pid
	--变更数据结构
	local data1, data2 = ResultCtrol.getResultMsgData(oldData, data)
	_data = data2

	UIUtil.shieldLayer(self, nil)
	parent:addChild(self)
	self:createLayer(data1)
end

return ResultMsg
-- YDWX_DZ_WUJIANCHAO_ FEATURE _20160708 _001