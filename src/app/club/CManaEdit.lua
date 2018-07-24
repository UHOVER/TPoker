local ViewBase = require("ui.ViewBase")
local CManaEdit = class("CManaEdit", ViewBase)
local ClubCtrol = require("club.ClubCtrol")

local _cManaEdit = nil
local imageView = nil
local pInfo = {}
local permitInfo = {} 	-- 权限信息
local permit = {} 		-- 管理员权限
local curPermit = {} 	-- 当前已有权限

local function Callback(  )
	_cManaEdit:removeFromParent()
end

local function saveCallback(  )
	permit = {}
	local tmpPer = ClubCtrol.PERMIT
	for i=1,#permitInfo do
		if permitInfo[i].value == 1 then
			permit[#permit+1] = tmpPer[i]
		end
	end
	local clubData = ClubCtrol.getClubInfo()
	local function response( data )
		-- dump(data)
		if data.code == 0 then
			ClubCtrol.dataStatMana(function (  )
				ViewCtrol.showTick({content = "管理员权限设置成功!"})
				Callback()
				local clubMana = require("club.ClubManage")
				clubMana:updateMana()
			end)
		end
	end
	local tabData = {}
	if next(permit) == nil then
		permit[1] = ""
	end
	tabData['club_id'] = clubData.id
	tabData['permis_arr'] = permit
	tabData['user_id'] = pInfo.id
	XMLHttp.requestHttp('clubManagerPermisEdit', tabData, response, PHP_POST)
end

function CManaEdit:buildLayer(  )
	UIUtil.addTopBar({backFunc = Callback, title = "设置管理员权限", parent = self})

	local tmpPer = ClubCtrol.PERMIT
	permitInfo = {
						{tag=1, value=0, text='发起牌局'}, {tag=2, value=0, text='删除成员'},
						{tag=3, value=0, text='审核带入'}, {tag=4, value=0, text='添加推广员'},
						{tag=5, value=0, text='修改俱乐部资料'}, {tag=6, value=0, text='查看活跃统计'},
						{tag=7, value=0, text='审核加入俱乐部'}, {tag=8, value=0, text='查看战绩统计'},
						{tag=9, value=0, text='审核带入'}, {tag=10, value=0, text='查看联盟'},
						{tag=11, value=0, text='历史牌局'}, {tag=12, value=0, text='结算牌局'},
					}

	curPermit = pInfo.permis
	for i=1,#curPermit do
		for j=1,#tmpPer do
			if curPermit[i] == tostring(tmpPer[j]) then
				permitInfo[j].value = 1
				break
			end
		end
	end

	local clubNode = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height/2-130), pos=cc.p(0,display.height/2), parent=self})
	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(display.width/2, display.height/2-130), ah=cc.p(0.5,1), parent=clubNode})
	local site = UIUtil.addLabelArial('俱乐部权限', 26, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)

	local checkBox = {}
	local checkText = {}
	local function checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		for i=1,#checkBox do
			if tag == checkBox[i]:getTag() then
				if eventType == 0 then
					checkText[i]:setColor(ResLib.COLOR_BLUE)
					permitInfo[i].value = 1
				else
					checkText[i]:setColor(display.COLOR_WHITE)
					permitInfo[i].value = 0
				end
				-- dump(permitInfo)
				break
			end
		end
	end

	local line = 4
	local row = 2
	for i=1,line do
		for j=1,row do
			local idx = ( i - 1 ) * 2 + j
			local posX1 = 40+(j-1)*(display.width/2)
			local posX2 = 100+(j-1)*(display.width/2)
			local posY = (clubNode:getContentSize().height-130)-(i-1)*90
			checkBox[idx] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(posX1, posY), checkboxFunc = checkBoxFunc, parent = clubNode}):setTag(permitInfo[idx].tag)

			checkText[idx] = UIUtil.addLabelArial(permitInfo[idx].text, 30, cc.p(posX2, posY), cc.p(0, 0.5), clubNode)
			checkText[idx]:setTag(permitInfo[idx].tag)

			if permitInfo[idx].value == 0 then
				checkBox[idx]:setSelected(false)
				checkText[idx]:setColor(display.COLOR_WHITE)
			else
				checkBox[idx]:setSelected(true)
				checkText[idx]:setColor(ResLib.COLOR_BLUE)
			end
		end
	end
	checkBox[4]:setTouchEnabled(false)
	checkText[4]:setColor(ResLib.COLOR_GREY)
	checkBox[8]:setTouchEnabled(false)
	checkText[8]:setColor(ResLib.COLOR_GREY)

	local unionNode = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height/2), pos=cc.p(0,0), parent=self})
	local siteBg = UIUtil.addImageView({image = ResLib.TABLEVIEW_TEXT_LINE, touch=false, scale=true, size=cc.size(display.width, 40),pos=cc.p(display.width/2, display.height/2), ah=cc.p(0.5,1), parent=unionNode})
	local site = UIUtil.addLabelArial('联盟权限', 26, cc.p(20, siteBg:getContentSize().height/2), cc.p(0, 0.5), siteBg):setColor(ResLib.COLOR_GREY1)

	local _checkBox = {}
	local _checkText = {}
	local function updateStat(  )
		if next(_checkBox) == nil then
			return
		end
		if _checkBox[2]:isSelected() then
			_checkBox[3]:setTouchEnabled(true)
			_checkText[3]:setColor(display.COLOR_WHITE)
			_checkBox[4]:setTouchEnabled(true)
			_checkText[4]:setColor(display.COLOR_WHITE)
		else
			if _checkBox[3]:isSelected() then
				_checkBox[3]:setSelected(false)
				permitInfo[3+8].value = 0
			end
			if _checkBox[4]:isSelected() then
				_checkBox[4]:setSelected(false)
				permitInfo[4+8].value = 0
			end
			_checkBox[3]:setTouchEnabled(false)
			_checkText[3]:setColor(ResLib.COLOR_GREY)
			_checkBox[4]:setTouchEnabled(false)
			_checkText[4]:setColor(ResLib.COLOR_GREY)
		end
	end
	local function _checkBoxFunc( sender, eventType )
		local tag = sender:getTag()
		for i=1,#_checkBox do
			if tag == _checkBox[i]:getTag() then
				if eventType == 0 then
					_checkText[i]:setColor(ResLib.COLOR_BLUE)
					permitInfo[tag].value = 1
				else
					_checkText[i]:setColor(display.COLOR_WHITE)
					permitInfo[tag].value = 0
				end
				if tag == (2+8) then
					updateStat()
				end
				-- dump(permitInfo)
				break
			end
		end
	end

	local line = 2
	local row = 2
	for i=1,line do
		for j=1,row do
			local idx = ( i - 1 ) * 2 + j
			local posX1 = 40+(j-1)*(display.width/2)
			local posX2 = 100+(j-1)*(display.width/2)
			local posY = (unionNode:getContentSize().height-130)-(i-1)*90
			_checkBox[idx] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(posX1, posY), checkboxFunc = _checkBoxFunc, parent = unionNode}):setTag(permitInfo[idx+8].tag)

			_checkText[idx] = UIUtil.addLabelArial(permitInfo[idx+8].text, 30, cc.p(posX2, posY), cc.p(0, 0.5), unionNode)
			_checkText[idx]:setTag(permitInfo[idx+8].tag)

			if permitInfo[idx+8].value == 0 then
				_checkBox[idx]:setSelected(false)
				_checkText[idx]:setColor(display.COLOR_WHITE)
			else
				_checkBox[idx]:setSelected(true)
				_checkText[idx]:setColor(ResLib.COLOR_BLUE)
			end
		end
	end
	-- 更新联盟 结算牌局、历史牌局权限（查看联盟未勾选时该两项不可操作）
	updateStat()
	
	-- 保存
	local label = cc.Label:createWithSystemFont("保存", "Marker Felt", 30)
	local btn_str = "common/com_btn_blue.png"
	local btn_str1 = "common/com_btn_blue_height.png"
	local btn = UIUtil.controlBtn(btn_str, btn_str, btn_str1, label, cc.p(display.width/2, 50), cc.size(700,80), saveCallback, self)
end


function CManaEdit:createLayer( data )
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	_cManaEdit = self
	imageView = nil
	permitInfo = {}
	pInfo = {}
	permit = {}
	curPermit = {}

	pInfo = data

	self:buildLayer()
end

return CManaEdit