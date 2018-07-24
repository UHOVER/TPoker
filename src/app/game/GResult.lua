local GResult = {}
local _meData = {}
local _rewards = {}
local _players = {}
local _insureData = {}

local _layer = nil
local _cs = nil
local _csize = cc.size(display.width, 60)
local _conLayer = nil
local _tablev = nil
local _titles = {}
local _titlepox = {}
local _isInsure = false
local INSURE_TAG = 0
local PLAYER_TAG = 1

local SNG = 'sng'
local GENERAL = 'general'
local _gtype = SNG

local function handleClose()
	DZAction.hideWindow(_layer, function()
        _layer:removeFromParent()
        local MainScene = require 'main.MainScene'
    	MainScene:startScene()
    end)
end

local function handleShare()
	-- local nodes = {_layer, _tablev:getContainer()}
	-- UIUtil.clipScreenShare(cc.size(display.width, display.height), nodes)
	--Fixed change by tanhaiting 
	local function response(data) 
		local tab = {}
		tab['content'] = ""
		tab['weburl'] = XMLHttp.getHttpUrl()..data['data']['filename']
		if _gtype == SNG then 
			tab['title'] = "SNG战局详情"
		elseif _gtype == GENERAL then 
		    tab['title'] = "标准战局详情"
		end
		
		tab['desc'] = "分享自我的战绩 -- 战绩统计 -- \""..tostring(fromText).."\"战局详细"
		print("WEBURL"..tostring(tab['weburl']))
		DZWindow.shareDialog(DZWindow.SHARE_MTTURL, tab)
	end
	local token = XMLHttp.getGameToken()
	local _pid  = GData.getGamePId()
	--这里不存在mtt
	local url = "shareNotMtt?token="..token.."&p_id=".._pid
	print("url:"..url.."    isMtt:"..tostring(isMtt))
	XMLHttp.requestHttp(url, {}, response, PHP_POST)
end

local function handleInsureMsg()
	require("result.ShowBXListLayer"):create(_insureData)
end


local function getColor(num)
	if num < 0 then
		return cc.c3b(23,116,55), num
	elseif num > 0 then 
		return cc.c3b(159,7,7), '+'..num
	else
		return cc.c3b(170,170,170), num
	end
end

local function addCellLayer(idx, layer)
	local cy = _csize.height / 2
	local color = cc.c3b(184,181,191)
	local cdata = _players[ idx ]
	local tscore = cdata['score']

	if cdata['isMe'] then
		color = cc.c3b(38,174,217)
	end

	local color0,tscore = getColor(tscore)

	--保险池
	if cdata['typeTag'] == INSURE_TAG then
		local ttfScore = UIUtil.addLabelBold(tscore, 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color0)
		ttfScore:setPositionX(_titlepox[ #_titlepox ])

		local smallbg = UIUtil.addPosSprite('common/com_smallbg1.png', cc.p(_titlepox[1],cy), layer, cc.p(0.5,0.5))
		UIUtil.addPosSprite('icon/icon_insure.png', cc.p(40,18), smallbg, cc.p(1,0.5))
		UIUtil.addLabelBold('保险池', 28, cc.p(46,18), cc.p(0,0.5), smallbg, cc.c3b(142,199,223))

		local timg = 'bg/r_ann.png'
		local ttfcfg = cc.Label:createWithSystemFont("", "Marker Felt", 30)
		local tpos = cc.p(_titlepox[ #_titlepox ]+60,cy)
		UIUtil.controlBtn(timg, timg, timg, ttfcfg, tpos, cc.size(64,64), handleInsureMsg, layer)
		return
	end
	

	local cols = {}
	if _isInsure then
		-- local color1,insure = getColor(cdata['insure'])
		-- local color2,insureResult = getColor(cdata['insureResult'])

		local ttfName = UIUtil.addLabelBold(cdata['name'], 30, cc.p(0,cy), cc.p(0.5,0.5), layer, color)
		local ttfBet = UIUtil.addLabelBold(cdata['intoBet'], 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color)
		-- local tinsure = UIUtil.addLabelBold(insure, 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color1)
		-- local tresult = UIUtil.addLabelBold(cdata['insureResult'], 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color2)
		local ttfScore = UIUtil.addLabelBold(tscore, 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color0)
		-- cols = {ttfName, ttfBet, tinsure, tresult, ttfScore}
		cols = {ttfName, ttfBet, ttfScore}
	else
		local ttfName = UIUtil.addLabelBold(cdata['name'], 30, cc.p(0,cy), cc.p(0.5,0.5), layer, color)
		local ttfBet = UIUtil.addLabelBold(cdata['intoBet'], 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color)
		local ttfScore = UIUtil.addLabelBold(tscore, 34, cc.p(0,cy), cc.p(0.5,0.5), layer, color0)
		cols = {ttfName, ttfBet, ttfScore}
	end

	for i=1,#cols do
		cols[i]:setPositionX(_titlepox[i])
	end
end

local function addTableLayer(idx, layer)
	layer:addChild(_conLayer)
end


local function rewardLayer(cs)
	local imgFirst = cs:getChildByName('imgFirst')
	local imgSecond = cs:getChildByName('imgSecond')
	local imgThird = cs:getChildByName('imgThird')

	--没有奖励
	if #_rewards == 0 then
		imgFirst:setPositionX(1200)
		imgSecond:setPositionX(1200)
		imgThird:setPositionX(1200)
		return 
	end

	if #_rewards > 3 or #_rewards < 1 then
		assert(nil, 'rewardLayer  _rewards')
		return
	end

	local posarr = {}
	posarr[1] = {cc.p(375,585),  cc.p(1000,5000), cc.p(1000,5000)}
	posarr[2] = {cc.p(260,585), cc.p(490,600),  cc.p(1000,5000)}
	posarr[3] = {cc.p(375,585), cc.p(150,600), cc.p(600,600)}

	--设置位置
	local arr = posarr[ #_rewards ]
	local objs = {imgFirst, imgSecond, imgThird}
	for i=1,#objs do
		objs[ i ]:setPosition( arr[ i ] )
	end

	--设置数据
	local ttfs = {'ttfNameFirst', 'ttfNameSecond', 'ttfNameThird'}
	local imgTags = {'imgTopTag', 'imgLeftTag', 'imgRightTag'}
	for i=1,#_rewards do
		local reward = _rewards[ i ]

		objs[i]:getChildByName( ttfs[i] ):setString(reward['name'])
		objs[i]:getChildByName( imgTags[i] ):setTexture(reward['rewardImg'])

		local thead = UIUtil.addShaderHead(arr[ i ], reward['headUrl'], cs, function()end)
		if i == 1 then
			thead:setScale(0.4)
		else
			thead:setScale(0.36)
		end
	end
end


local function createLayer()
	local runScene = cc.Director:getInstance():getRunningScene()
    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    _layer = glayer
    runScene:addChild(glayer, StringUtils.getMaxZOrder(runScene))
    UIUtil.shieldLayer(glayer, nil)
    DZAction.showWindow(_layer, nil)

    --table view layer
    --cd table title bg y变化调整(940 + cellH) 和 (cellH-395) 一个加另一个减
    local cellH = #_players * 50
    local scrollH = 940 + cellH
    _conLayer = cc.LayerColor:create(cc.c4b(0,0,0,0), display.width, scrollH)

    --csb
    local cs = cc.CSLoader:createNodeWithVisibleSize(ResLib.GRESULT_CSB)
    cs:setPositionY(cellH-395)
    _conLayer:addChild(cs)
    _cs = cs


    local titleBg = cs:getChildByName('titleBg')
    local closeBtn= titleBg:getChildByName('btnReturn')
    closeBtn:touchEnded(handleClose)
    titleBg:getChildByName('btnShare'):touchEnded(handleShare)
    local ox,oy = closeBtn:getPositionX(), closeBtn:getPositionY()
 	UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, 
 					size = cc.size(100, 80), ah = cc.p(0.5,0.5), pos = cc.p(ox, oy), touch = true, 
    							swalTouch = false, listener = handleClose , parent = titleBg})

    --保险局
    if not _isInsure then
    	titleBg:getChildByName('imgInsure'):setVisible(false)
    end

	local meBg = cs:getChildByName('upImgBg')
	local ttfBet = meBg:getChildByName('ttfMeBet')
	ttfBet:setString(_meData['meBet'])
	meBg:getChildByName('ttfMeNum'):setString(_meData['allNum'])
	meBg:getChildByName('ttfMaxPot'):setString(_meData['maxPot'])
	meBg:getChildByName('ttfAllBet'):setString(_meData['allBet'])

	meBg:getChildByName('ttfFrom'):setString(_meData['from'])
	meBg:getChildByName('ttfEndTime'):setString(_meData['endTime'])
	meBg:getChildByName('ttfName'):setString(_meData['meName'])

	if _meData['meBet'] > 0 then
		ttfBet:setColor(cc.c3b(159,7,7))
	else
		ttfBet:setColor(cc.c3b(23,116,55))
	end


	local thead = UIUtil.addShaderHead(cc.p(108,245), _meData['headUrl'], meBg, function()end)
	thead:setScale(0.4)

	--获奖者
	rewardLayer(cs)


	-- cell
	local cellLayer = cc.LayerColor:create(cc.c4b(250,0,250,0), display.width, cellH)
	cellLayer:setPositionY(5)
	_conLayer:addChild(cellLayer)
	local celly = 0
	for i=1,#_players do
		local cell = cc.LayerColor:create(cc.c4b(250,0,250,0), display.width, _csize.height)
		addCellLayer(i, cell)
		cell:setPositionY(celly)

		celly = celly + 50
		cellLayer:addChild(cell)
	end


	--table title
	local img = 'game/game_result_line.png'
    local fightbg = UIUtil.scale9Sprite(cc.rect(0,0,0,0), img, cc.size(750,60), cc.p(0,440), _cs)
    fightbg:setAnchorPoint(0,0.5)
    local color1 = cc.c3b(181,184,191)
    for i=1,#_titles do
    	UIUtil.addLabelBold(_titles[i], 33, cc.p(_titlepox[i],30), cc.p(0.5,0.5), fightbg, color1)
    end


	local tsize = cc.size(_csize.width, 1330-G_SURPLUS_H)
	local tablev = UIUtil.addTableView(tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_VERTICAL, _layer)
    tablev:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev, cc.size(_csize.width,scrollH), 1, addTableLayer, nil)

    _tablev = tablev

    local function setFont(obj, name)
    	local tfont = obj:getChildByName( name )
    	tfont:setFontName('Helvetica-Bold')
    	return 
    end

    --font
    setFont(titleBg,'ttfTitle')
    setFont(meBg,'ttfTitle2')
    setFont(meBg,'ttfMeBet')
    setFont(meBg,'ttfMeNum')
    setFont(meBg,'ttfAllBet')
    setFont(meBg,'ttfMaxPot')
end


--奖励
local function handleReward(players)
	local pnum = #players
	_rewards = {}

	if pnum == 0 then return end

	local function addReward(rewImgs, one, two, three)
		one['rewardImg'] = rewImgs[ 1 ]
		two['rewardImg'] = rewImgs[ 2 ]
		three['rewardImg'] = rewImgs[ 3 ]
		table.insert(_rewards, one)
		table.insert(_rewards, two)
		table.insert(_rewards, three)
	end

	local function setSngReward(num)
		if #players < 1 then return end

		local rewImg1s = {}
		local one = players[1]
		local two = nil
		local three = nil

		if num == 2 then
			rewImg1s = {'result/result_champion.png', 'result/result_tong.png', 'result/result_look.png'}
			two = players[2]
			three = players[2]
		elseif num == 6 then
			rewImg1s = {'result/result_champion.png', 'result/result_second.png', 'result/result_tong.png'}
			two = players[2]
			three = players[6]
		elseif num == 9 then
			rewImg1s = {'result/result_champion.png', 'result/result_second.png', 'result/result_third.png'}
			two = players[2]
			three = players[3]
		else
			return
		end

		addReward(rewImg1s, one, two, three)
	end


	local function setGeneralReward()
		if #players < 1 then return end
		local function firstNum()
			return players[ 1 ]
		end

		local function lastNum()
			return players[ #players ]
		end

		local function intoBigBet()
			local pl = players[1]
			local maxbet = pl['intoBet']

			for i=1,#players do
				if players[ i ]['intoBet'] > maxbet then
					pl = players[ i ]
					maxbet = pl['intoBet']
				end
			end

			return StringUtils.copyTable(pl)
		end

		local one = firstNum()
		local two = lastNum()
		local three = intoBigBet()

		local rewImg2s = {'result/result_mvp.png', 'result/result_fish.png', 'result/result_money.png'}
		addReward(rewImg2s, one, two, three)
	end


	if _gtype == SNG then
		setSngReward(pnum)
	elseif _gtype == GENERAL then
		setGeneralReward()
	end
end


local function handleData(data)
	-- print_f(data)
	_meData = {}
	_players = {}
	_rewards = {}
	_insureData = {}
	_isInsure = false

	local function convert(num)
		if tonumber(num) < 10 then
			return '0'..num
		end
		return num
	end

	_gtype = data['gameType']
	_meData['allNum'] = data['gameCount']
	_meData['maxPot'] = data['maxPot']
	_meData['allBet'] = data['totalBuyin']
	_meData['from'] = '来自'..data['roomName']
	_meData['meBet'] = 0
	_meData['headUrl'] = Single:playerModel():getPHeadUrl()
	_meData['meName'] = Single:playerModel():getPName()

	
	--转换结束时间
	local date = os.date("*t", data['endTime'])
	local month = date['month']
	local day = date['day']
	local hour = date['hour']
	local min = date['min']
	_meData['endTime'] = convert(month)..'/'..convert(day)..'/'..convert(hour)..':'..convert(min)

	local players = data['players']
	local meId = Single:playerModel():getId()

	--玩家
	for i=1,#players do
		local player = players[ i ]
		
		--保险模拟字段保持一致
		local tab = {}
		tab['headUrl'] = player['headUrl']
		tab['userId'] = player['pid']
		tab['name'] = player['userName']
		tab['intoBet'] = player['spends']		--带入或报名费
		tab['score'] = player['score']
		tab['typeTag'] = PLAYER_TAG

		--保险才有此字段
		-- tab['insure'] = player['insure'] or 0
		-- tab['insureNum'] = player['insureNum'] or 0

		if _gtype == SNG then
			tab['score'] = player['getBack']
		end

		tab['isMe'] = false

		if meId == player['pid'] then
			_meData['meBet'] = player['score']
			_meData['headUrl'] = player['headUrl']
			tab['isMe'] = true

			Single:playerModel():setPBetNum(player['chips'])
		end

		table.insert(_players, tab)
	end

	handleReward(_players)

	DZSort.sortTables(_players, StatusCode.SORT, 'score')

	--handle title	
	_titles = {'昵称', '带入量', '记分牌'}
	_titlepox = {122, 380, 645}
	if _gtype == SNG then
		_titles = {'昵称', '带入量', '积分合计'}
	elseif _gtype == GENERAL then
		_titles = {'昵称', '带入量', '记分牌'}
	end

	--保险
	if data['insurancePool'] then
		_isInsure = true
		-- _titles = {'昵称', '带入量', '保险', '输赢', '积分牌合计'}
		-- _titlepox = {88, 235, 377, 500, 652}
		_titles = {'昵称', '带入量', '记分牌'}

		local tab = {}
		tab['score'] = data['insurancePool']
		tab['typeTag'] = INSURE_TAG
		table.insert(_players, #_players + 1, tab)

		_insureData['from'] = data['roomName']..'的标准牌局'
		_insureData['name'] = Single:playerModel():getPName()

		local list = {}
		for i=1,#players do
			local tab = {}
			tab['name'] = players[i]['userName']
			tab['poolNum'] = players[i]['insureNum'] or 0
			tab['url'] = players[i]['headUrl']
			tab['playerID'] = players[i]['pid']
			tab['pid'] = players[i]['tid']
			table.insert(list, tab)
		end
		_insureData['dataList'] = list
	end
end

function GResult.showResult(data)
	-- local data = GResult.getTestData()
	handleData(data)
	createLayer()
end


function GResult.getTestData()
	local ret = {}
	ret['gameType'] = 'general'
	-- ret['gameType'] = 'sng'
	ret['gameCount'] = 123
	ret['maxPot'] = 12
	ret['totalBuyin'] = 100
	ret['roomName'] = 'test'
	ret['endTime'] = os.time()
	ret['insurancePool'] = 900

	local tab = {}
	for i=1,9 do
		local player = {}
		player['userName'] = 'user'..i
		player['headUrl'] = ''
		player['chips'] = 123
		player['pid'] = i
		player['tid'] = '123'
		player['getBack'] = 123
		player['score'] = -100 - i
		player['spends'] = 100 - i
		player['joinTime'] = 12323

		player['insureNum'] = 1000 + i
		-- player['insureResult'] = -100

		table.insert(tab, player)
	end

	ret['players'] = tab

	-- Single:playerModel():setId('1')

	return ret
end


return GResult