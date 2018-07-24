local GFighting = {}
local _data = {}
local _lookUsers = {}

local titleSize = cc.size(0,0)
local _csize1 = cc.size(0,0)
local _csize2 = cc.size(0,0)
local titles = {}
local _titlex = {}
local _middleNode = nil

local _color1 = cc.c3b(142,199,223)
local _color0 = cc.c3b(255,255,255)
local _pokerTag = -1

local INSURE_TAG = 0
local PLAYER_TAG = 1

local function headCell(idx, layer)
	local start = (idx - 1) * 4
	local cy = _csize2.height / 2
	local addx = 90
	for i=1,4 do
		local ti = i + start
		if ti <= #_lookUsers then
			local um = _lookUsers[ ti ]
			local color = cc.c3b(255,255,255)
			-- local head1,head2 = UIUtil.addUserHead(cc.p(addx,cy+12), um:getHeadUrl(), layer, nil)
			-- UIUtil.addLabelBold(um:getUserName(), 22, cc.p(addx,8), cc.p(0.5,0), layer, color)
			
			local tpos = cc.p(addx,cy+12)
			if um['isInTrace'] then
				UIUtil.addPosSprite('game/game_null_grey.png', tpos, layer, nil)
			else
				UIUtil.addPosSprite(ResLib.GAME_NULL, tpos, layer, nil)
			end

			local head1,head2 = UIUtil.addUserHead(tpos, um['headUrl'], layer, true)
			local tname = UIUtil.addLabelBold(um['playerName'], 22, cc.p(addx,8), cc.p(0.5,0), layer, color)

			addx = addx + 140

			if um['isInTrace'] then
				local effect = cc.ShaderEffectGrey:create()
		        head2:setEffect(effect)
		        tname:setColor(cc.c3b(180,180,180))
			end
		end
	end
end

local function scoresCell(idx, layer)
	local tdata = _data[ idx ]
	local cy = _csize1.height / 2
	local color = cc.c3b(255,255,255)
	local color2 = cc.c3b(255,255,255)
	local fs = 30
	local score = tdata['score']

	--保险池显示
	if tdata['typeTag'] == INSURE_TAG then
		local smallbg = UIUtil.addPosSprite('common/com_smallbg1.png', cc.p(_titlex[1],cy), layer, cc.p(0.5,0.5))
		UIUtil.addPosSprite('icon/icon_insure.png', cc.p(40,18), smallbg, cc.p(1,0.5))
		UIUtil.addLabelBold('保险池', 28, cc.p(46,18), cc.p(0,0.5), smallbg, cc.c3b(142,199,223))
		UIUtil.addLabelBold(score, fs, cc.p(_titlex[3],cy), cc.p(0.5,0.5), layer, color2)
		return
	end

	if score < 0 then
		-- color2 = cc.c3b(14,84,49)
	end

	if Single:playerModel():getId() == tdata['playerId'] then
		color = cc.c3b(142,199,223)
		color2 = cc.c3b(142,199,223)
	-- elseif not UserCtrol.getSeatUserById(tdata['playerId']) then
	elseif not tdata['isInSeat'] then
		color = cc.c3b(115,118,119)
		color2 = cc.c3b(115,118,119)
	end

	UIUtil.addLabelBold(tdata['playerName'], 26, cc.p(_titlex[1],cy), cc.p(0.5,0.5), layer, color)
	UIUtil.addLabelBold(tdata['buyin'], 26, cc.p(_titlex[2],cy), cc.p(0.5,0.5), layer, color)
	UIUtil.addLabelBold(score, 26, cc.p(_titlex[3],cy), cc.p(0.5,0.5), layer, color2)
end


local function addMiddleLayer()
	_middleNode:removeAllChildren()

	local titleY = display.top - 145
	local rect = cc.rect(0,0,0,0)

	--中上
	local titlebg1 = UIUtil.scale9Sprite(rect, 'game/game_fight3.png', titleSize, cc.p(0,titleY), _middleNode)
    titlebg1:setAnchorPoint(0,1)
    UIUtil.addLabelBold(titles[1], 30, cc.p(_titlex[1],32), cc.p(0.5,0.5), titlebg1, _color1)
    UIUtil.addLabelBold(titles[2], 30, cc.p(_titlex[2],32), cc.p(0.5,0.5), titlebg1, _color1)
    UIUtil.addLabelBold(titles[3], 30, cc.p(_titlex[3],32), cc.p(0.5,0.5), titlebg1, _color1)


    local tsizeh1 = 635 - G_SURPLUS_H
    local tsize1 = cc.size(_csize1.width,tsizeh1)
    local tablev1 = UIUtil.addTableView(tsize1, cc.p(0,488), cc.SCROLLVIEW_DIRECTION_VERTICAL, _middleNode)
    tablev1:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev1, _csize1, #_data, scoresCell)


    --中下
    local titlebg2 = UIUtil.scale9Sprite(rect, 'game/game_fight3.png', titleSize, cc.p(0,420), _middleNode)
    titlebg2:setAnchorPoint(0,0)
    UIUtil.addLabelBold('看客', 33, cc.p(295,32), cc.p(0.5,0.5), titlebg2, _color1)

    local num2 = math.ceil(#_lookUsers / 4)
    local tsize2 = cc.size(_csize2.width,320)
    local tablev2 = UIUtil.addTableView(tsize2, cc.p(0,90), cc.SCROLLVIEW_DIRECTION_VERTICAL, _middleNode)
    tablev2:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    DZUi.addTableView(tablev2, _csize2, num2, headCell)
end


local function createLayer()
    local runScene = cc.Director:getInstance():getRunningScene()
    if runScene:getChildByName('SHOW_FIGHT') then
    	return
    end

    local glayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
    glayer:setName('SHOW_FIGHT')
    runScene:addChild(glayer, StringUtils.getMaxZOrder(runScene))
    UIUtil.shieldLayer(glayer, nil)

    local bgw = 600
    titleSize = cc.size(bgw,64)
    local rect = cc.rect(0,0,0,0)
    _csize1 = cc.size(bgw,60)
    _csize2 = cc.size(bgw,150)

    --bg
    local bgsize = cc.size(608,display.height)
    local fightbg = UIUtil.scale9Sprite(rect, 'game/game_fight0.png', bgsize, cc.p(0,0), glayer)
    fightbg:setAnchorPoint(0,0)

  	local fsize = fightbg:getContentSize()
    local function removeLayer()
		glayer:initWithColor(cc.c4b(0,0,0,0))
    	DZAction.easeInMove(glayer, cc.p(-fsize.width,0), 0.25, DZAction.MOVE_TO, function()
	    	glayer:removeFromParent()
		end)
    end
    fightbg.noEndedBack = removeLayer
  	TouchBack.registerImg(fightbg)
  	glayer:setPositionX(-fsize.width)
	DZAction.easeInMove(glayer, cc.p(0,0), 0.25, DZAction.MOVE_TO, function()
		glayer:initWithColor(cc.c4b(0,0,0,100))
	end)


	--上
	local size1 = cc.size(bgw,84)
    local bg1 = UIUtil.scale9Sprite(rect, 'game/game_fight1.png', size1, cc.p(0,display.height-40), glayer)
    bg1:setAnchorPoint(0,1)
    UIUtil.addLabelBold('实时战况', 36, cc.p(20,size1.height/2), cc.p(0,0.5), bg1, cc.c3b(255,255,255))
    local img = 'game/game_return.png'
    local item = UIUtil.addMenuBtn(img, img, removeLayer, cc.p(550,size1.height/2), bg1)
    item:setScale(1.2)

    --下
    local bg2 = UIUtil.scale9Sprite(rect, 'game/game_fight3.png', titleSize, cc.p(0,20), glayer)
    bg2:setAnchorPoint(0,0)
    UIUtil.addLabelBold('静音', 33, cc.p(30,32), cc.p(0,0.5), bg2, cc.c3b(255,255,255))

    --静音按钮
    local switch1 = 'ui/ui_switch1.png'
    local switch2 = 'ui/ui_switch2.png'
    local isClose = Storage.getIsCloseVoice()
    local topen = UIUtil.addPosSprite(switch2, cc.p(560,32), bg2, cc.p(1,0.5))
    local tclose = UIUtil.addPosSprite(switch1, cc.p(560,32), bg2, cc.p(1,0.5))
	topen:setVisible(not isClose)
	tclose:setVisible(isClose)
	topen:setScale(0.8)
	tclose:setScale(0.8)

	local mitem = UIUtil.addMenuBtn(switch1, switch2, function()
        DZPlaySound.playGear()
		
		isClose = not isClose
		topen:setVisible(not isClose)
		tclose:setVisible(isClose)

		Storage.setIsCloseVoice(isClose)

		local GameLayer = require 'game.GameLayer'
		GameLayer:getInstance():updateVoiceStatus()
	end, cc.p(560,32), bg2)
	mitem:setOpacity(0)
	mitem:setAnchorPoint(1,0.5)
	mitem:setScale(1.5)


	_middleNode = cc.Node:create()
	glayer:addChild(_middleNode)
end


local function handleData(data)
	local tdatas = data['players']
	titles = {'昵称', '带入', '记分牌'}
	_titlex = {95, 300, 500}
      
	--看客
	_lookUsers = {}
	for i=1,#tdatas do    
		local lu = tdatas[ i ]

		--站着在房间观看、站在不在房间
		if not lu['isInSeat'] and lu['isInRoom'] then
			lu['sortLook'] = 1
			table.insert(_lookUsers, lu)
		elseif not lu['isInSeat'] and lu['isInTrace'] then
			lu['sortLook'] = 0
			table.insert(_lookUsers, lu)
		end
	end
	DZSort.sortTables(_lookUsers, StatusCode.UN_SORT, 'sortLook')


	--去掉一次也没有加入此牌局的看客
	_data = {}
	for i=1,#tdatas do
		local seatu = tdatas[ i ]
		if seatu['score'] ~= 0 or seatu['buyin'] ~= 0 or seatu['isInSeat'] then
			table.insert(_data, seatu)
		end
	end

	local  function handleStandard()
		local maxScore = 0
		for i=1,#_data do
			local score = _data[i]['score']
			_data[i]['sortTag'] = score
			_data[i]['typeTag'] = PLAYER_TAG

			if score > maxScore then
				maxScore = score
			end
		end

		--有保险池才会用到
		if data['insurancePool'] then
			local tab = {}
			tab['typeTag'] = INSURE_TAG
			tab['sortTag'] = maxScore + 10
			tab['score'] = data['insurancePool']
			tab['playerName'] = ''
			tab['headUrl'] = ''
			tab['buyin'] = ''

			table.insert(_data, tab)
		end
	end

	--sng
	if _pokerTag == GAME_BIG_TYPE_SNG then
		for i=1,#_data do
			_data[i]['buyin'] = ''
		end
		titles = {'昵称', '', '积分'}
		_titlex = {120, 0, 460}

		DZSort.sortTables(_data, StatusCode.UN_SORT, 'score')
	elseif _pokerTag == GAME_BIG_TYPE_STANDARD then
		handleStandard()
		DZSort.sortTables(_data, StatusCode.UN_SORT, 'sortTag')
	end
end

local _isEnter = true
function GFighting.shwoFight()
	if not _isEnter then return end
	_isEnter = false
	DZSchedule.schedulerOnce(2, function()
		_isEnter = true
	end)

	_pokerTag = Single:gameModel():getGameBigType()

	local function funcBack(data)
		-- _lookUsers = UserCtrol.getAllStandUsers()
		handleData(data)

		createLayer()
		_isEnter = true
		addMiddleLayer(_middleNode)
	end
	local function mttBack(data)
		createLayer()
		_isEnter = true
		local GMttFighting= require 'game.GMttFighting'
		GMttFighting.showMttFighting(_middleNode, 600, data)
	end

	--mtt、标准 sng
	if _pokerTag == GAME_BIG_TYPE_MTT then
		SocketCtrol.mttMatchData(mttBack)
	else
		SocketCtrol.getRealTimeData(funcBack)
	end
end



return GFighting