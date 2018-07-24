local ViewBase = require("ui.ViewBase")
local CManaLook = class("CManaLook", ViewBase)

local _cManaLook = nil
local curPermit = {}

local function Callback(  )
	_cManaLook:removeFromParent()
end

function CManaLook:buildLayer(  )
	UIUtil.addTopBar({backFunc = Callback, title = "设置管理员权限", parent = self})
	-- 111：发起牌局；112：审核带入；113查看战绩；114查看活跃统计；
	-- 121：删除成员；122：修改俱乐部资料；123审核俱乐部；124：添加推广员；
	-- 212：审核带入；211：历史牌局；213：结算牌局；221查看联盟
	local permitInfo = {
						{tag=1, value=111, text='发起牌局'}, {tag=2, value=121, text='删除成员'},
						{tag=3, value=112, text='审核带入'}, {tag=4, value=124, text='添加推广员'},
						{tag=5, value=122, text='修改俱乐部资料'}, {tag=6, value=114, text='查看活跃统计'},
						{tag=7, value=123, text='审核加入俱乐部'}, {tag=8, value=113, text='查看战绩统计'},
						{tag=9, value=212, text='审核带入'}, {tag=10, value=211, text='查看联盟'},
						{tag=11, value=213, text='历史牌局'}, {tag=12, value=221, text='结算牌局'},
					}

	local showPer = {}
	-- dump(curPermit)
	if next(curPermit) == nil then
		return
	end
	for i=1,#curPermit do
		for j=1,#permitInfo do
			if tostring(curPermit[i]) == tostring(permitInfo[j].value) then
				showPer[#showPer+1] = permitInfo[j]
				break
			end
		end
	end

	-- dump(showPer)

	local clubNode = UIUtil.addImageView({image = ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(display.width, display.height-130), pos=cc.p(0,0), parent=self})
	local function checkBoxFunc(  )
		
	end
	local checkBox = {}
	local checkText = {}
	local line = math.ceil(#showPer/2)
	local count = #showPer
	local row = 2
	for i=1,line do
		if count/i < 2 then
			row = count % 2
		end
		for j=1,row do
			local idx = ( i - 1 ) * 2 + j
			local posX1 = 40+(j-1)*(display.width/2)
			local posX2 = 100+(j-1)*(display.width/2)
			local posY = (clubNode:getContentSize().height-30)-(i-1)*90
			checkBox[idx] = UIUtil.addCheckBox({checkBg = "common/com_checkBox_2.png", checkBtn = "common/com_checkBox_2_1.png", ah = cc.p(0, 0.5), pos = cc.p(posX1, posY), checkboxFunc = checkBoxFunc, parent = clubNode})

			checkText[idx] = UIUtil.addLabelArial(showPer[idx].text, 30, cc.p(posX2, posY), cc.p(0, 0.5), clubNode)
			
			checkBox[idx]:setSelected(true)
			checkBox[idx]:setTouchEnabled(false)
			checkText[idx]:setColor(ResLib.COLOR_BLUE)
		end
	end
end

function CManaLook:createLayer( data )
	self:setSwallowTouches()
	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	_cManaLook = self
	curPermit = data

	self:buildLayer()
end

return CManaLook