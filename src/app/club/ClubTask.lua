local ViewBase = require("ui.ViewBase")
local ClubTask = class("ClubTask", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _clubTask = nil
local imgTab1, imgTab2, imgTab3, imgTab4 = {},{},{},{}
local listItem = {}

local taskData = {}
local curTaskData = {}
local curListView = nil
local club_ID = nil

local getBtnTab = {}

local function Callback(  )
	_clubTask:removeTransitAction()
end

function ClubTask:buildLayer(  )

	-- addTopBar
	UIUtil.addTopBar({backFunc = Callback, title = "俱乐部任务", parent = self})

	-- grey up
	imgTab1.imgNormal = 'club/club_task_btn_up.png'
	imgTab1.imgSelected = 'club/club_task_btn_up.png'
	imgTab1.imgDisabled = 'club/club_task_btn_up.png'
	-- grey down
	imgTab2.imgNormal = 'club/club_task_btn_down.png'
	imgTab2.imgSelected = 'club/club_task_btn_down.png'
	imgTab2.imgDisabled = 'club/club_task_btn_down.png'

	-- green down
	imgTab3.imgNormal = 'club/club_task_btn_up_green.png'
	imgTab3.imgSelected = 'club/club_task_btn_up_green.png'
	imgTab3.imgDisabled = 'club/club_task_btn_up_green.png'
	-- green down
	imgTab4.imgNormal = 'club/club_task_btn_down.png'
	imgTab4.imgSelected = 'club/club_task_btn_down.png'
	imgTab4.imgDisabled = 'club/club_task_btn_down.png'

	taskData = {}
	taskData = ClubCtrol.getTaskData()
	self:buildData()
end

function ClubTask:buildData(  )
	local function response( data )
		dump(data)
		self:createData(data.data)
	end
	local tabData = {}
	tabData["club_id"] = club_ID
	XMLHttp.requestHttp("get_task_list", tabData, response, PHP_POST)
end

function ClubTask:createData( data )

	for k,v in pairs(taskData) do
		for k1,v1 in pairs(data) do
			if v.taskId == v1.id then
				local tmpTab = {}
				tmpTab = v1
				tmpTab["level"] 			= v.level
				tmpTab["nextLevel"] 		= v.nextLevel
				if data[k1+1] then
					tmpTab["nextPerson_total"] 	= data[k1+1].users_toal
				else
					tmpTab["nextPerson_total"] = 0
				end
				
				table.insert(curTaskData, tmpTab)
			end
		end
	end
	dump(curTaskData)
	curListView = nil
	curListView = self:createListView()

end

function ClubTask:getScores( idx )
	local function response( data )
		dump(data)
		if data.code == 0 then
			local MineCtrol = require("mine.MineCtrol")
			local curScores = MineCtrol.getMineInfo().scores
			curTaskData[idx].status = 3
			local reward = tonumber(curScores) + tonumber(curTaskData[idx].sorces_reward)
			print(">>>>>>>>>>>>>>>>>: " .. reward)
			
			getBtnTab[idx]:setTouchEnabled(false)
			getBtnTab[idx]:setTitleText("已领取")
			Single:playerModel():setPBetNum(reward)
		end
	end
	local tabData = {}
	tabData["scores"] = curTaskData[idx].sorces_reward
	tabData["club_id"] = club_ID
	tabData["level"] = curTaskData[idx].id
	XMLHttp.requestHttp("get_club_money", tabData, response, PHP_POST)
end

function ClubTask:createListView(  )
	local listview = ccui.ListView:create()
	listview:setBounceEnabled(true)
	listview:setDirection(1)
	listview:setTouchEnabled(true)
	listview:setContentSize(cc.size(display.width, display.height-130))
	listview:setBackGroundImage(ResLib.TABLEVIEW_BG)
  	listview:setBackGroundImageScale9Enabled(true)
	listview:setAnchorPoint(0,0)
	listview:setPosition(cc.p(0, 0))
	self:addChild( listview )

	for idx=1,#curTaskData do
		listItem[idx] = self:buildItem(idx)
		listview:pushBackCustomItem(listItem[idx])
	end

	return listview
end

function ClubTask:buildItem( idx )
	local data = curTaskData[idx]
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(display.width, 150))
	layout:setPosition(cc.p(0,0))

	local cellBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_CELL_BG, touch=false, scale=true, size=cc.size(display.width, 140), ah = cc.p(0,0), pos=cc.p(0, 5), parent=layout})
	local width = cellBg:getContentSize().width
	local height = cellBg:getContentSize().height

	-- 任务级别
	local clubName = UIUtil.addLabelArial("俱乐部"..data.level.."级", 30, cc.p(40, height/2), cc.p(0, 0.5), cellBg)

	-- 领取
	local function getCallFunc( sender )
		print("领取")
		local tag = sender:getTag()
		self:getScores( tag )
	end
	local getBtnText = nil
	if data.status == 0 then
		getBtnText = "领取"
	elseif data.status == 1 then
		getBtnText = "可领取"
	elseif data.status == 2 then
		getBtnText = "已领取"
	end
	local getBtn = UIUtil.addImageBtn({norImg = "club/club_task_btn_get_can.png", selImg = "club/club_task_btn_get_can.png", disImg = "club/club_task_btn_get_no.png", text = getBtnText, pos = cc.p(width-200, height/2), ah = cc.p(0.5, 0.5), swalTouch = true, touch = true, scale9 = true, size = cc.size(200, 120), listener = getCallFunc, parent = cellBg})
	getBtn:setTag(idx)
	getBtnTab[idx] = getBtn

	local scoreIcon = UIUtil.addPosSprite("user/icon_spades.png", cc.p(40,30), getBtn, cc.p(0.5,0.5))
    local scores = data.sorces_reward
    UIUtil.addLabelArial(scores, 25, cc.p(100, 30), cc.p(0, 0.5), getBtn)

    if data.status == 0 or data.status == 3 then
    	cellBg:loadTexture( ResLib.TABLEVIEW_CELL_BG )
    	getBtn:setEnabled(false)
    else
    	cellBg:loadTexture( ResLib.BTN_GREEN_NOR )
    	getBtn:setEnabled(true)
    end


    -- YDWX_DZ_ZHANGXINMIN_BUG _20160627 _005
	-- 下拉菜单
	local index = nil
	local function pullCallFunc( tag, sender )
		print(tag)
		index = curListView:getIndex(listItem[tag])
		print(index)
		-- dump(pos)
		if sender:getSelectedIndex() == 1 then
			local task = self:buildTask(tag)
			curListView:insertCustomItem(task, index+1)

			if index +1 >= 5 then
				curListView:scrollToItem(index, cc.p(0, 0), cc.p(0.5,0.5))
			end
		else
			curListView:removeItem(index+1)
		end
	end
	local pullBtn = nil
	-- YDWX_DZ_ZHANGXINMIN_BUG _20160627 _005 Button error
	pullBtn = self:addTogMenu(imgTab2, imgTab3, cc.p(width-50, height/2), pullCallFunc, cellBg)
	-- YDWX_DZ_ZHANGXINMIN_BUG _20160627 _005 Button error
	pullBtn:setTag(idx)

	return layout
end

function ClubTask:buildTask( idx )
	local data = curTaskData[idx]
	local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(display.width, 500))
	layout:setPosition(cc.p(0,0))

	local imageView = UIUtil.addImageView({image=ResLib.CLUB_EDIT_BG, touch=false, scale=true, size=cc.size(display.width-40, 490), ah=cc.p(0,0), pos=cc.p(20,10), parent=layout})
	UIUtil.addLabelArial('您的任务：', 30, cc.p(40, 470), cc.p(0, 0.5), imageView)

	UIUtil.addLabelArial('俱乐部人数达到'..data.users_toal..'人', 20, cc.p(40, 410), cc.p(0, 0.5), imageView)
	UIUtil.addPosSprite("club/icon_user_blue.png", cc.p(40, 350), imageView, cc.p(0, 0.5))
	-- local personValue = 20/data.person_total
	self:buildProgress(data.club_now_users, data.users_toal, imageView, cc.p(80, 350))

	UIUtil.addLabelArial('俱乐部内所有成员记分牌带入量合计达到'..data.club_scores_count, 20, cc.p(40, 290), cc.p(0, 0.5), imageView)
	UIUtil.addPosSprite("user/icon_spades.png", cc.p(40,230), imageView, cc.p(0,0.5))
	-- local scoreboardValue = 678000/data.scoreboard_total
	self:buildProgress(data.club_now_scores, data.club_scores_count, imageView, cc.p(80, 230))

	local width = display.width-100
	local str1,str2,str3 = nil,nil,nil
	if idx == 10 then
		str1 = "恭喜您的俱乐部已升至满级。"
		str2 = "完成此任务，您的俱乐部将升至"..data.level.."级"
		str3 = "并获得"..data.sorces_reward.."记分牌的奖励"
	else
		str1 = "完成此任务，您的俱乐部将升至"..data.nextLevel.."级"
		str2 = "并获得"..data.sorces_reward.."记分牌的奖励"
		str3 = "及俱乐部人数上限升至"..data.nextPerson_total.."人"
	end
	UIUtil.addLabelArial(str1, 30, cc.p(width/2, 150), cc.p(0.5, 0.5), imageView)
		:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	UIUtil.addLabelArial(str2, 30, cc.p(width/2, 100), cc.p(0.5, 0.5), imageView)
		:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	UIUtil.addLabelArial(str3, 30, cc.p(width/2, 50), cc.p(0.5, 0.5), imageView)
		:setAlignment(cc.TEXT_ALIGNMENT_CENTER, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)

	return layout
end

function ClubTask:addTogMenu( imgTab1, imgTab2, pos, callBack, parent )
	local sprite1Nor = cc.Sprite:create(imgTab1.imgNormal)
	local sprite1Sel = cc.Sprite:create(imgTab1.imgSelected)
	local sprite1Dis = cc.Sprite:create(imgTab1.imgDisabled)

	local sprite2Nor = cc.Sprite:create(imgTab2.imgNormal)
	local sprite2Sel = cc.Sprite:create(imgTab2.imgSelected)
	local sprite2Dis = cc.Sprite:create(imgTab2.imgDisabled)
	local Menu1 = cc.MenuItemSprite:create(sprite1Nor, sprite1Sel, sprite1Dis)
	local Menu2 = cc.MenuItemSprite:create(sprite2Nor, sprite2Sel, sprite2Dis)

	local item = cc.MenuItemToggle:create(Menu1)
	item:addSubItem(Menu2)
	item:registerScriptTapHandler(callBack)
	local menu = cc.Menu:create()
	menu:addChild(item)
	menu:setPosition(pos)
	parent:addChild(menu)
	return item
end

function ClubTask:buildProgress( value1, value2, parent, pos )
	local bg = cc.Scale9Sprite:create("common/com_progress_bg_blue_big.png")
	-- bg:setContentSize(cc.size(600, 37))
	bg:setAnchorPoint(cc.p(0,0.5))
	bg:setPosition(pos)
	parent:addChild(bg)

	local sprite = cc.Sprite:create("common/com_progress_blue_big.png")

	local progress = cc.ProgressTimer:create(sprite)
	progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress:setMidpoint(cc.p(0,0))
	progress:setBarChangeRate(cc.p(1,0))
	progress:setAnchorPoint(cc.p(0,0.5))
	progress:setPosition(cc.p(0,bg:getContentSize().height/2))
	local value1 = value1 or 0
	local value2 = value2 or 0
	local value = (value1/value2)*100
	progress:setPercentage(value)
	bg:addChild(progress)
	UIUtil.addLabelArial(value1 .."/"..value2, 20, cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2), cc.p(0.5, 0.5), progress)
	return progress
end

function ClubTask:createLayer( club_id )
	_clubTask = self
	_clubTask:setSwallowTouches()
	_clubTask:addTransitAction()

	club_ID = club_id
	curTaskData = {}
	getBtnTab = {}
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	self:buildLayer()
end

return ClubTask