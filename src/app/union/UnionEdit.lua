--
-- Author: Taylor
-- Date: 2017-08-02 13:57:02
--
local ViewBase = require("ui.ViewBase")
local UnionEdit = class("UnionEdit", ViewBase)
local UnionCtrol = require("union.UnionCtrol")

local unionMsg = UnionCtrol.getUnionDetail()


local _uEditLayer = nil
local unionAvatar = ""
--保存回调
local function saveHandler()
	local info = {}
	local function response( data )
		if data.code == 0 then
			ViewCtrol.showTick({content = "保存成功!"})
			UnionCtrol.editUnionInfo(info)
			_uEditLayer:removeFromParent()
		end
	end
	local tabData = {}
	tabData['unionName'] 	= _uEditLayer.unionName:getString()
	tabData['avatar'] 		= unionAvatar
	info = tabData
	XMLHttp.requestHttp( "modify", tabData, response, PHP_POST )
end


local function editNameFunc(  )
	local sureEditResult = function(text)
								_uEditLayer.unionName:setString(text)
							end
	local modify = require("union.LineInputLayer")
	modify.show(_uEditLayer, {
				text = unionMsg.union_name, 
				func = sureEditResult, 
				title = "修改联盟名称"
				})
end



function UnionEdit:ctor()
	_uEditLayer = self
	-- self:enableNodeEvents()
	self:initData()
	self:initUI()
	 --放弃保存
	local function backHandler()
		self:removeFromParent()
	end
    UIUtil.addTopBar({backFunc = backHandler, title = "编辑资料", menuFont = "保存", menuFunc = saveHandler, parent = self})
end
function UnionEdit:initData()
	self.photo_count = 0
	self.photo_node = {}
	self.photo_bg = nil
	self.unionName = nil

	self.stencil = nil
	self.unionIcon = nil

	unionAvatar = unionMsg.union_avatar
end
function UnionEdit:initUI()
	display.newLayer(cc.c3b(3,7,31),display.size):addTo(self):onTouch(function()end, false, true)

	local viewSize = {width = display.width, height = display.height-130}
	local scrollView = UIUtil.addScrollView( {showSize=cc.size(display.width, display.height-130), innerSize=cc.size(viewSize.width, viewSize.height), dir=cc.SCROLLVIEW_DIRECTION_VERTICAL, colorType=ccui.LayoutBackGroundColorType.none, color=cc.c3b(0, 0, 10), bounce=true, pos=cc.p(0,0), parent=self} )
	local layer = UIUtil.addImageView({image=ResLib.TABLEVIEW_BG, touch=false, scale=true, size=cc.size(viewSize.width, viewSize.height), pos=cc.p(0,0), parent=scrollView})
	--相册
	local rect = cc.rect(10,10,10,10)
	self.photo_bg = UIUtil.scale9Sprite(rect, ResLib.CLUB_EDIT_BG, cc.size(display.width, 377), cc.p(display.cx,viewSize.height-188), layer)
	local bSize = self.photo_bg:getContentSize()
	display.newLayer(cc.c3b(52,52,52),bSize.width,bSize.height):addTo(self.photo_bg)
	self.photo_node = self:BgArray( unionMsg.union_background_img or {}, self.photo_bg )
	-- 头像
	UIUtil.addLabelArial('头像和昵称', 30, cc.p(20, display.height-130-380-30), cc.p(0, 1), scrollView, ResLib.COLOR_WHITE)
	self.stencil, self.unionIcon = UIUtil.addCircleHead({shape = ResLib.CLUB_HEAD_STENCIL_200, scale = 0.7, pos = cc.p(display.cx, viewSize.height-380-80-71), parent = layer, nor = ResLib.UNION_HEAD, sel =ResLib.UNION_HEAD, listener = handler(self,self.iconCallback)})
	
	local url = unionMsg.union_avatar
	local function funcBack( iconPath )
		self.unionIcon:loadTextureNormal(iconPath)
		self.unionIcon:loadTexturePressed(iconPath)
		self.unionIcon:loadTextureDisabled(iconPath)
	end
	CppPlat.downResFile(url, funcBack, funcBack, ResLib.UNION_HEAD, "downloadUnion")
	
	self.cameraIcon = UIUtil.addPosSprite("club/club_icon_camera.png", cc.p(display.cx+20, viewSize.height-424-105-50+25), layer, cc.p(0, 0.5))
	if url == "" or true then 
		self.cameraIcon:setVisible(false)
	end
	--联盟名字
	print("unionMsg", unionMsg.union_name )
	self.unionName = UIUtil.addLabelArial(unionMsg.union_name, 30, cc.p(display.cx, self.cameraIcon:getPositionY()-71-16), cc.p(0.5, 1), layer, display.COLOR_WHITE)
	UIUtil.addImageBtn({norImg = "user/user_edit_name.png", selImg = "user/user_edit_name.png", pos = cc.p(self.unionName:getPositionX()+self.unionName:getContentSize().width/2+13, self.cameraIcon:getPositionY()-71-16-self.unionName:getContentSize().height/2), listener = editNameFunc, parent = layer}):setAnchorPoint(cc.p(0,.5))
end
 
function UnionEdit:buildIcon(iconPath)
	if not iconPath then
		return
	end
	if self.cameraIcon then 
		-- self.cameraIcon:setVisible(true)
	end
	self.unionIcon:loadTextureNormal(iconPath)
	self.unionIcon:loadTexturePressed(iconPath)
	self.unionIcon:loadTextureDisabled(iconPath)
	
	local sp = cc.Sprite:create(iconPath)
	local scaleX = 200/sp:getContentSize().width
	local scaleY = 200/sp:getContentSize().height
	self.unionIcon:setScale(scaleX, scaleY)
end

function UnionEdit:iconCallback(  )
	local function funcback( iconName, iconPath )
		unionAvatar = iconName
		_uEditLayer:buildIcon(iconPath)
	end
	ClubModel.buildPhoto( 0, funcback, {op_type = 3, photo_type = 2} )
end

function UnionEdit:buildBg( iconName, flag, oldImgs )
	local function response( data )
		dump(data)
		if data.code == 0 then
			if flag == 1 then
				UnionCtrol.replaceImgs( iconName, oldImgs )
			else
				UnionCtrol.editUnionInfo({imgs = iconName})
			end
			local bgArray = UnionCtrol.getUnionInfo().union_background_img
			self.photo_node = self:BgArray(bgArray, self.photo_bg)
		end
	end
	local tabData = {}
	tabData["new_imgs"] = iconName
	if flag == 1 then
		tabData["old_imgs"] = oldImgs
		tabData["mod"] = "update"
	else
		tabData["mod"] = "new"
	end
	XMLHttp.requestHttp("unionUpBgImg", tabData, response, PHP_POST)
end

local function smallCallback( tag, sender )
	local flag = nil
	local oldImgs = unionMsg.union_background_img[tag:getTag()]
	-- local c_id = ClubCtrol.getClubInfo()["id"] 
	local sendTab = {img = oldImgs }
	OP_TYPE = 3
	local function deleteImgs(  )
		local bgArray = {}
		UnionCtrol.editUnionInfo({imgs_d = oldImgs})
		bgArray = unionMsg.union_background_img
		_uEditLayer.photo_node = _uEditLayer:BgArray( bgArray, _uEditLayer.photo_bg )
	end

	local function funcBack( iconName, iconPath )
		_uEditLayer:buildBg(iconName, flag, oldImgs)
	end
	-- print(type(tag), type(_uEditLayer), type(_uEditLayer.photo_count))
	if tag:getTag() <= _uEditLayer.photo_count then
		flag = 1
		ClubModel.buildPhoto( 1, funcBack, {op_type = OP_TYPE, photo_type = 1, sendData = sendTab, deleteBack = deleteImgs} )
	else
		flag = 0
		ClubModel.buildPhoto( 0, funcBack, {op_type = 3, photo_type = 1} )
	end
end

function UnionEdit:BgArray( bgArray, node )
	-- 相册数量
	self.photo_count = #bgArray

	if #self.photo_node ~= 0 then
		node:removeAllChildren()
		self.photo_node = {}
	end

	local smallBg = {}
	local stencilS = {}
	local count = nil
	local photoImg = nil
	local imageIdx = 0
	local imageName = {}

	local function loadImage(  )
		local sizeW, sizeH = 162, 162
		for i=1, #bgArray do
			local sprite = cc.Sprite:create(imageName[i])
			local scaleX = sizeW/sprite:getContentSize().width
			local scaleY = sizeH/sprite:getContentSize().height
			-- smallBg[i]:setScale(scaleX, scaleY)

			smallBg[i]:loadTextureNormal(imageName[i])
			smallBg[i]:loadTexturePressed(imageName[i])
			smallBg[i]:loadTextureDisabled(imageName[i])
		end
	end

	if #bgArray < 8 then
		count = #bgArray+1
	else
		count = #bgArray
	end
	local line = math.ceil( count/4 )
	for i=1,line do
		local row = 4
		if count/i < 4 then
			row = count % 4
		end
		for j=1,row do
			local idx = (i-1)*4 + j
			if idx == count then
				photoImg = ResLib.PHOTO_ADD_1
			else
				photoImg = "common/com_photo_image.png"
			end
			stencilS[idx], smallBg[idx] = UIUtil.addCircleHead({shape = ResLib.PHOTO_ADD, scale = 1, pos = cc.p((display.width-20*5)*(2*j-1)/8 + 20*j, 282-(i-1)*188), parent = node, nor = photoImg, sel = photoImg, listener = smallCallback, mask = ""})
			-- smallBg[idx] = UIUtil.addImageBtn({norImg = photoImg, selImg = photoImg, disImg = photoImg, ah = cc.p(0.5, 1), pos = cc.p(display.width*(2*j-1)/8, 340-(i-1)*175), touch = true, listener = smallCallback, parent = node})
			smallBg[idx]:setTag(idx)
			
			local function funcBack( path )
				imageName[idx] = path
				imageIdx = imageIdx + 1
				if imageIdx == #bgArray then
					loadImage()
				end
			end
			if idx <= (#bgArray) then
				local url = bgArray[idx]
				ClubModel.downloadPhoto(funcBack, url, true)
			end
		end
	end
	return smallBg
end

------------------------------------------------
function UnionEdit.show(parent)
	parent = parent or cc.Director:getInstance():getRunningScene()
	local unionEdit = UnionEdit:create()
	parent:addChild(unionEdit,StringUtils.getMaxZOrder(parent))
	return unionEdit
end
------------------------------------------------

return UnionEdit