local SetModel = {}

local setClass = nil

local pondTab = {}

local pondCount = 1

local pondNode = nil

local pondBg = nil

local managerList = {}

local function touchListen( topLayer, bgLayer, funback )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function ( touch, event )
		local target = event:getCurrentTarget()
		local pos = target:convertToNodeSpace(touch:getLocation())
		local rect = topLayer:getBoundingBox()
		if cc.rectContainsPoint(rect, pos) then
			listener:setSwallowTouches(true)
			return false
		end
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch, event )
		funback()
	end, cc.Handler.EVENT_TOUCH_ENDED)
	local dispatcher = cc.Director:getInstance():getEventDispatcher()
	dispatcher:addEventListenerWithSceneGraphPriority(listener, bgLayer)
end

local function addCenterLayer( opacity)
    if not opacity then
        opacity = 150
    end
    local layer = cc.LayerColor:create(cc.c4b(10, 10, 10, opacity))
    layer:setPosition(cc.p(0,0))
    local runScene = cc.Director:getInstance():getRunningScene()
    runScene:addChild(layer, StringUtils.getMaxZOrder(runScene))
    return layer
end

function SetModel.buildPond( params )
	setClass = params._class

	-- local image = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=true, scale=true, size=cc.size(display.width, display.height), pos=cc.p(0,0), parent=params.parent})
	local image = addCenterLayer(100)

	local count = SetModel.getPondCount()

	-- pondBg = UIUtil.addImageView({image = "common/set_card_MTT_pond_bg.png", scale=true, size=cc.size(500, 10*70+70+200), touch=true, ah=cc.p(0, 0), pos=cc.p(display.width, 150), parent=image})
	local bgWidth, bgHeight = 598, display.height
	pondBg = UIUtil.addImageView({image = "common/set_card_MTT_pond_bg.png", scale=true, size=cc.size(bgWidth, bgHeight), touch=true, ah=cc.p(0, 0), pos=cc.p(display.width, 0), parent=image})


	local function callback(  )
		print("关闭")
		-- image:removeFromParent()
		-- pondNode = nil
		local seq = cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(bgWidth,0)), cc.CallFunc:create(function()
			image:removeFromParent()
			pondNode = nil
		end))
		pondBg:runAction(seq)
	end

	-- 触摸监听
	touchListen(pondBg, image, callback)

	local rightBtn = UIUtil.addImageBtn({norImg = "common/set_card_MTT_pond_edit.png", selImg = "common/set_card_MTT_pond_edit.png", disImg = "common/set_card_MTT_pond_edit.png", ah = cc.p(0,1), pos = cc.p(0, pondBg:getContentSize().height-40), touch = true, swalTouch = false, scale9 = true, size = cc.size(pondBg:getContentSize().width, 90), listener = callback, parent = pondBg})
	UIUtil.addPosSprite(ResLib.BTN_BACK_RIGHT, cc.p(24, rightBtn:getContentSize().height/2), rightBtn, cc.p(0, 0.5))

	UIUtil.addLabelArial('奖励金额', 36, cc.p(rightBtn:getContentSize().width-20, rightBtn:getContentSize().height/2), cc.p(1, 0.5), rightBtn)

	-- 奖池金额
	pondNode = nil
	local delFlag = 0
	SetModel.addPondUI( pondBg, 0 )

	local btnBg = UIUtil.addImageView({image = "common/mtt_award_img.png", scale=true, size=cc.size(pondBg:getContentSize().width, 180), touch=false, ah=cc.p(0, 0), pos=cc.p(0, 0), parent=pondBg})

	local function addCountFunc(  )
		if SetModel.getPondCount() == 10 then
			return
		end
		SetModel.addPondTab( function (  )
			SetModel.addPondUI( pondBg, 0 )
			setClass.updateKeepCount(  )
		end )
		delFlag = 0
		print("添加奖励分配")
	end
	local addBtn = UIUtil.addImageBtn({norImg = "common/set_card_MTT_pond_add.png", selImg = "common/set_card_MTT_pond_add_height.png", disImg = "common/set_card_MTT_pond_add_height.png", ah = cc.p(1,0), pos = cc.p(btnBg:getContentSize().width/2-80, 20), touch = true, swalTouch = false, listener = addCountFunc, parent = btnBg})

	local function delCountFunc(  )
		print("删除奖励分配")
		if SetModel.getPondCount() == 0 then
			return
		end
		if delFlag == 0 then
			delFlag = 1
			SetModel.addPondUI( pondBg, 1 )
		else
			delFlag = 0
			SetModel.addPondUI( pondBg, 0 )
		end
	end
	local delBtn = UIUtil.addImageBtn({norImg = "common/set_card_MTT_pond_delete.png", selImg = "common/set_card_MTT_pond_delete_height.png", disImg = "common/set_card_MTT_pond_delete_height.png", ah = cc.p(0,0), pos = cc.p(pondBg:getContentSize().width/2+80, 20), touch = true, swalTouch = false, listener = delCountFunc, parent = btnBg})

	local spa = cc.Spawn:create(cc.FadeIn:create(0.2), cc.MoveBy:create(0.2, cc.p(-bgWidth, 0)))
	pondBg:runAction(spa)

	return image
end

function SetModel.addPondUI( pondBg, del )

	local pond_tab = SetModel.getPondTab()
	dump(pond_tab)

	if pondNode then
		pondNode:removeFromParent()
		pondNode = nil
	end
	pondNode = UIUtil.addImageView({image = ResLib.COM_OPACITY0, touch=false, scale=true, size=pondBg:getContentSize(), ah = cc.p(0.5, 0.5), pos=cc.p(pondBg:getContentSize().width/2, pondBg:getContentSize().height/2), parent=pondBg})

	local posX = nil
	if del == 0 then
		posX = pondBg:getContentSize().width/2
	else
		posX = pondBg:getContentSize().width/2-30
	end

	local pondEdit = {}
	local function pondEditFunc( eventType, sender )
		local tag = sender:getTag()
		if eventType == "changed" then
		elseif eventType == "return" then
			local str = StringUtils.trim(sender:getText())
			if str ~= "" then
				local tab = {ranking = tag, award = tonumber(str)}
				if not SetModel.judgePond( tab ) then
					ViewCtrol.showMsg('奖励分配金额要小于或等于前一名且大于0')
					str = ""
					sender:setText(str)
				else
					sender:setText(str)
					local tab = {ranking = tag, award = tonumber(str)}
					SetModel.updatePondTab( tab )
				end
			end
		end
	end
	
	for i,v in ipairs(pond_tab) do
		local bg = UIUtil.addImageView({image = "common/set_card_MTT_pond_edit.png", touch=false, scale=true, size=cc.size(394, 60), ah=cc.p(0.5,0), pos=cc.p(posX, pondBg:getContentSize().height-258-(i-1)*90), parent=pondNode})

		UIUtil.addLabelArial('第'..v.ranking..'名:', 30, cc.p(bg:getContentSize().width/2-20, bg:getContentSize().height/2), cc.p(1, 0.5), bg)

		local holderText = (v.award ~= 0) and v.award or "奖励金额"
		pondEdit[i] = UIUtil.addEditBox(nil, cc.size(bg:getContentSize().width/2-20, 60), cc.p( bg:getContentSize().width/2, bg:getContentSize().height/2), holderText, bg )
		pondEdit[i]:setAnchorPoint(cc.p(0,0.5))
		pondEdit[i]:setFontColor(display.COLOR_WHITE)
		pondEdit[i]:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
		pondEdit[i]:setTag(v.ranking)
		pondEdit[i]:registerScriptEditBoxHandler(pondEditFunc)
		if (v.award ~= 0) then
			pondEdit[i]:setText(v.award)
		end

		if del == 1 and i == #pond_tab then
			local function delCountFunc(  )
				SetModel.deletePondTab( function (  )
					SetModel.addPondUI( pondBg, 1 )
					setClass.updateKeepCount(  )
				end )
			end
			local delBtn = UIUtil.addImageBtn({norImg = "common/set_card_MTT_pond_del.png", selImg = "common/set_card_MTT_pond_del.png", disImg = "common/set_card_MTT_pond_del.png", ah = cc.p(0,0), pos = cc.p(posX+bg:getContentSize().width/2+20, pondBg:getContentSize().height-253-(i-1)*90), touch = true, swalTouch = false, listener = delCountFunc, parent = pondNode})
		end

	end
end

function SetModel.setPondCount( count )
	pondCount = count
end

function SetModel.getPondCount(  )
	return pondCount
end

function SetModel.initPondTab(  )
	local pond_tab = {}

	local count = #pond_tab + SetModel.getPondCount(  )
	for i=1,count do
		local tmpTab = {}
		tmpTab["ranking"] = i
		tmpTab["award"] = 0
		table.insert(pond_tab, tmpTab)
	end

	SetModel.setPondTab( pond_tab )
end

function SetModel.setPondTab( tab )
	pondTab = {}
	pondTab = tab
end

function SetModel.getPondTab(  )
	return pondTab
end

function SetModel.addPondTab( funback )
	local count = SetModel.getPondCount()+1
	SetModel.setPondCount( count )

	local pond_tab = SetModel.getPondTab()

	local tmpTab = {ranking = count, award = 0}
	pond_tab[count] = tmpTab
	SetModel.setPondTab( pond_tab )
	if funback then
		funback()
	end
end

function SetModel.deletePondTab( funback )
	local pond_tab = SetModel.getPondTab()
	table.remove(pond_tab, #pond_tab)
	SetModel.setPondCount( #pond_tab )
	
	SetModel.setPondTab( pond_tab )
	if funback then
		funback()
	end
end

function SetModel.updatePondTab( tab )
	local pond_tab = SetModel.getPondTab()
	for k,v in pairs(pond_tab) do
		if v.ranking == tab.ranking then
			v.award = tab.award
		end
	end
end

---判断设置的奖励是否小于前一名的奖励
function SetModel.judgePond( tab )
	local rank = tonumber(tab.ranking)
	local award = tonumber(tab.award)
	if award <= 0 then
		return false
	end
	
	local pond_tab = SetModel.getPondTab()
	if rank == 1 then
		return true
	else
		if pond_tab[rank-1]["award"] >= award then
			return true
		else
			return false
		end
	end
end

function SetModel.judegAward( pond_tab )
	for k,v in pairs(pond_tab) do
		if v.award <= 0 then
			return false
		end
	end
	return true
end


function SetModel.dropDownList( params )

	local listBg = UIUtil.addImageView({image = ResLib.BTN_BLUE_BORDER_SMALL, touch=true, scale=true, size=cc.size(116,500), ah = cc.p(0.5, 1), pos=params.pos, parent=params.parent})

	-- touchListen( listBg, params.parent, function()end )

	local btnList = {}
	local function listFunc( sender )
		local tag = sender:getTag()
		for k,v in pairs(btnList) do
			if tag ~= v:getTag() then
				v:setTouchEnabled(true)
				v:setBright(true)
			end
		end
		sender:setTouchEnabled(false)
		sender:setBright(false)
		
		SetModel.setPondCount( tag )
		if params.tag == 3 then
			SetModel.initPondTab()
		end

		params.callback()
	end
	local img1, img2 = nil, nil
	local text = {}
	if params.tag == 1 then
		for i=1,10 do
			if i == 10 then
				text[i] = 12
			else
				text[i] = i
			end	
		end
	else
		for i=1,10 do
			text[i] = i
		end
	end
	for i=1,#text do
		if i == 1 then
			img1 = "common/set_card_MTT_drop_1.png"
			img2 = "common/set_card_MTT_drop_1_1.png"
		elseif i == 10 then
			img1 = "common/set_card_MTT_drop_3.png"
			img2 = "common/set_card_MTT_drop_3_1.png"
		else
			img1 = "common/set_card_MTT_drop_2.png"
			img2 = "common/set_card_MTT_drop_2_1.png"
		end
		btnList[i] = UIUtil.addImageBtn({norImg = img1, selImg = img2, disImg = img2, text = tostring(text[i]), ah = cc.p(0,1), pos = cc.p(0, listBg:getContentSize().height-(i-1)*50), touch = true, swalTouch = false, scale9 = true, size = cc.size(116, 50), listener = listFunc, parent = listBg})
		btnList[i]:setTag(text[i])
	end

	return listBg
end

-- 管理员
function SetModel.setManager( manager )
	-- dump(manager)
	managerList = {}
	for k,v in pairs(manager) do
		table.insert(managerList, v.id)
	end
	-- dump(managerList)
end

function SetModel.getManager(  )
	return managerList
end

function SetModel.getMttValue(  )
	local value = {}
	-- 人数限制
	-- value[1] = {6, 9, 10, 20, 30, 50, 100, 200, 300, 400, 500, 1000, 2000, 3000}
	-- 截止报名
	value[1] = DZConfig.stopLevel()
	-- 重购次数
	value[2] = DZConfig.getRebuyNum()
	-- 增购倍数
	value[3] = {0, 1, 2, 3}
	-- 中场休息
	value[4] = {0, 1, 2, 3, 5, 10, 20, 30, 60, 90, 120}
	-- 奖励范围
	-- value[6] = SetModel.getMttAward(6)
	return value
end

function SetModel.getMttAward( playerNum )
	local str = "award_"..tostring(playerNum)
	-- local award = {
	-- 	award_6 = {1},
	-- 	award_9 = {1, 2, 3},
	-- 	award_10 = {1, 2, 3},
	-- 	award_20 = {1, 2, 3, 4, 5, 6},
	-- 	award_30 = {1, 2, 3, 4, 5, 6, 7, 8, 9},
	-- 	award_40 = {1, 2, 4, 6, 8, 9, 12},
	-- 	award_50 = {1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 15},
	-- 	award_100 = {1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 15, 18, 21, 24, 27, 30},
	-- 	award_200 = {2, 4, 6, 8, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 45, 54},
	-- 	award_300 = {3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 45, 54, 63, 72, 81, 90},
	-- 	award_400 = {4, 8, 12, 15, 18, 24, 27, 30, 36, 45, 54, 63, 72, 81, 90, 99, 108, 117},
	-- 	award_500 = {5, 9, 15, 18, 24, 30, 33, 36, 45, 54, 63, 72, 81, 90, 99, 108, 117, 135},
	-- 	award_1000 = {9, 18, 30, 36, 45, 54, 63, 72, 90, 99, 108, 117, 135, 153, 171, 189, 207, 225, 252, 279, 297},
	-- 	award_2000 = {18, 36, 54, 72, 99, 117, 135, 153, 171, 189, 207, 225, 252, 279, 297},
	-- 	award_3000 = {30, 54, 90, 117, 135, 171, 207, 225, 252, 297}
	-- }
	local award = require("common.awardData")
	return award[str]
end

function SetModel.getAwardTab( playerNum )
	local str = "award_"..tostring(playerNum)
	
	local awardTab = require("common.awardTab")
	return awardTab[str]
end

return SetModel