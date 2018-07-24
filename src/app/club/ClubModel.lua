local ClubModel = {}

local moveTime = 0.1

local tab = {}
	tab['font'] = 'Arial'
	tab['size'] = 30

-- 添加、删除 相册、头像节点
local PicNode = nil

-- 背景层
local bg = nil

-- 按钮层
local BgLayer = nil

-- 添加相册回调（从相册选择、相机拍照）
local open_funcBack = nil

-- 按钮层移动距离
local moveDistance = nil

-- 打开相册图片时存入缓存
local iconName = nil

-- 删除相册
-- 当前操作模块 mine / club / union
ClubModel.MINE_TYPE = 1
ClubModel.CLUB_TYPE = 2
ClubModel.UNION_TYPE = 3

ClubModel.PHOTO_BG = 1
ClubModel.PHOTO_HEAD = 2

-- 操作模块
local CUR_OP_TYPE = nil

-- bg or head
local PHOTO_TYPE = nil

local mineTab = {}

local clubTab = {}

local unionTab = {}

local sendData = {}

local delete_funcBack = nil

local imageView = {} 	-- 相册
local imageViewName = {} -- 相册图片名称


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   移除layer
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function removePic(  )
	if PicNode and PicNode:getParent() then 
		PicNode:removeFromParent()
	end
end


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   打开相册
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local function openPhoto(  )
	print('从手机相册选择')
	--error:出错 cancel:取消 success:选择成功 
	removePic()
	Single:paltform():openPhotos(iconName, function(result, path, data)
		if result == 'success' then 	--选择了图片
			cc.Director:getInstance():getTextureCache():removeTextureForKey(path) --清理之前图片的缓存

			print(path) 	-- 图片路径
			dump(data)
			local icon_name = nil
			if data.code == 0 then
				icon_name = data.data.filename
			end
			
			-- 打开相册上传完成回调
			open_funcBack( icon_name, path )
		elseif result == 'error' then
			print('打开相册出错！')
		elseif result == 'cancel' then 	--选择了取消
			print('取消');

		end
	end)
end

-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   打开相机
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local function openCamera(  )
	removePic() 	-- 把当前层删除
	
	Single:paltform():openCamera(iconName, function ( result, path, data )
		if result == "success" then
			cc.Director:getInstance():getTextureCache():removeTextureForKey(path) --清理之前图片的缓存
			print(path) 	-- 图片路径
			dump(data)
			local icon_name = nil
			if data.code == 0 then
				icon_name = data.data.imgname
			end
			open_funcBack( icon_name, path )	--把当前场景的头像换掉
		elseif result == "error" then
			-- removePic()
		elseif result == "cancel" then
			-- removePic()
		end
	end)
end



-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   删除背景图片
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function deletePhoto(  )

	mineTab = {}

	clubTab = {}

	unionTab = {}

	local tabData = {}

	local path = nil
	local big_path = nil
	local php_api = nil

	if CUR_OP_TYPE == ClubModel.MINE_TYPE then
		php_api = "user/background/del"
		tabData["id"] = sendData["img"].id

		local img_name = sendData["img"].background
		path = device.writablePath .. img_name

	elseif CUR_OP_TYPE == ClubModel.CLUB_TYPE then
		php_api = "delete_bgimg"
		local img_name = sendData["img"]
		local club_id = sendData["club_id"]
		clubTab["img_name"] = img_name
		clubTab["club_id"] = club_id
		tabData = clubTab
		path = device.writablePath .. img_name
		big_path = device.writablePath .. "big_" .. img_name

	elseif CUR_OP_TYPE == ClubModel.UNION_TYPE then
		php_api = "delBgImg"
		local img_name = sendData["img"]
		unionTab["img_name"] = img_name
		-- unionTab["club_id"] = sendData["club_id"]
		tabData = unionTab
		path = device.writablePath .. img_name
		big_path = device.writablePath .. "big_" .. img_name
	end
	
	local function response( data )
		dump(data)
		if data.code == 0 then
			-- 删除资源
			if cc.FileUtils:getInstance():isFileExist(path) then
				cc.FileUtils:getInstance():removeFile(path)
				-- cc.FileUtils:getInstance():removeFile(big_path)
				-- 删除相册回调
				delete_funcBack()
				removePic()
			end
		end
	end
	XMLHttp.requestHttp(php_api, tabData, response, PHP_POST)
end

-- 查看原图
local function viewOriginImg(  )
	local img_name = "big_" .. sendData["img"]
	
	removePic()

	ClubModel.viewBigImage( img_name )
end


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   添加图片回调函数
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function callFunc( sender )
	local tag = sender:getTag()
	if tag == 201 or tag == 402 then 		-- 拍照
		print("拍照")
		openCamera()
	elseif tag == 202 or tag == 403 then 	-- 打开相册
		print("打开相册")
		openPhoto()
	elseif tag == 401 then 					-- 删除
		print("删除")
		deletePhoto()
	elseif tag == 404 then 					-- 查看原图
		print("查看原图")
		viewOriginImg()
	elseif tag == 100 then 					-- 取消
		print("取消")
		removePic()
	end
end


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---   添加相册、头像UI
-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function addShowUI( flag )
	local uiTab1 = {"拍照", "从手机相册选择" }
	local uiTab2 = {"删除", "拍照", "从手机相册选择", "查看原图"}
	local uiTab = {}

	local currScene = cc.Director:getInstance():getRunningScene()
	-- UI
	PicNode = cc.Node:create()
    PicNode:setPosition(cc.p(0,0))
    currScene:addChild(PicNode, StringUtils.getMaxZOrder(currScene))

    -- 大背景
	local bg = cc.LayerColor:create(cc.c4b(10, 10, 10, 100))
	bg:setPosition(0, 0)
	PicNode:addChild(bg)
	bg:setTouchEnabled(true)
	bg:setTag(1000)

	-- 选择按钮 小背景
	local BgLayer = cc.Layer:create()
	BgLayer:setTouchEnabled(true)
	BgLayer:ignoreAnchorPointForPosition(false)
	BgLayer:setAnchorPoint(cc.p(0,1))
	BgLayer:setPosition(cc.p(0, 0))
	PicNode:addChild(BgLayer,10)
	BgLayer:setTag(2000)
	if flag == 0 then
		BgLayer:setContentSize(display.width, 320)
		uiTab = uiTab1
		moveDistance = 320
	else
		BgLayer:setContentSize(display.width, 550)
		uiTab = uiTab2
		moveDistance = 550
	end

	----------------------- 触摸 --------------------------

	-- 注册单点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listenner = cc.EventListenerTouchOneByOne:create()
	-- 触摸开始
    local function onTouchBegan(touch, event)
        print("Touch Began")
        listenner:setSwallowTouches(true)
        return true
    end
    -- 触摸结束
    local function onTouchEnded(touch, event)
        print("Touch Ended")
        local move = cc.MoveTo:create(moveTime, cc.p(0, 0))
		local seq = cc.Sequence:create(move, cc.CallFunc:create(function (  )
				PicNode:removeFromParent()
		end))
		BgLayer:runAction(seq)
    end
    listenner:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listenner, PicNode)

     -- 注册单点触摸
    local dispatcher_layer = cc.Director:getInstance():getEventDispatcher()
    local listenner_layer = cc.EventListenerTouchOneByOne:create()
    listenner_layer:registerScriptHandler(function ( touch, event )

    	local target = event:getCurrentTarget()
    	local pos = target:convertToNodeSpace(touch:getLocation())
    	local targetWidth = target:getContentSize().width
    	local targetHeight = target:getContentSize().height
    	local rect = cc.rect(0, 0, targetWidth, targetHeight)
    	if cc.rectContainsPoint(rect, pos) then
    		listenner_layer:setSwallowTouches(true)
    		return true
    	end
    	return false
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    dispatcher_layer:addEventListenerWithSceneGraphPriority(listenner_layer, BgLayer)--]]
	

	-------------------- UI ---------------------

	local color = cc.c3b(0, 119, 255)
	local height = BgLayer:getContentSize().height

	for k,v in pairs(uiTab) do
		if k == 1 then
			local label1 = cc.Label:createWithSystemFont(v, "Marker Felt", 30)
			if flag == 0 then
				label1:setColor(color)
			else
				label1:setColor(display.COLOR_RED)
			end

			local PhotoBtn1 = UIUtil.controlBtn(ResLib.BTN_PHOTO_TOP, ResLib.BTN_PHOTO_TOP, ResLib.BTN_PHOTO_TOP, label1, cc.p(display.cx, height-(k-1)*101-50 ), cc.size(700,100), callFunc, BgLayer)
			PhotoBtn1:setTag(#uiTab*100+k)
		elseif k == #uiTab then
			local label2 = cc.Label:createWithSystemFont(v, "Marker Felt", 30)
			label2:setColor(color)
			local PhotoBtn2 = UIUtil.controlBtn(ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, ResLib.BTN_PHOTO_BOTTOM, label2, cc.p(display.cx, height-(k-1)*101-50), cc.size(700,100), callFunc, BgLayer)
			PhotoBtn2:setTag(#uiTab*100+k)
		else
			local label2 = cc.Label:createWithSystemFont(v, "Marker Felt", 30)
			label2:setColor(color)
			local PhotoBtn2 = UIUtil.controlBtn(ResLib.BTN_PHOTO_MIDDLE, ResLib.BTN_PHOTO_MIDDLE, ResLib.BTN_PHOTO_MIDDLE, label2, cc.p(display.cx, height-(k-1)*101-50), cc.size(700,99), callFunc, BgLayer)
			PhotoBtn2:setTag(#uiTab*100+k)
		end
	end
	
	-- 取消
	local label3 = cc.Label:createWithSystemFont("取消", "Marker Felt", 30)
	label3:setColor(color)
	local PhotoBtn3 = UIUtil.controlBtn(ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, ResLib.BTN_PHOTO, label3, cc.p(display.cx, 60), cc.size(700,100), callFunc, BgLayer)
	PhotoBtn3:setTag(100)

	local move = cc.MoveTo:create(moveTime, cc.p(0, moveDistance))
	BgLayer:runAction(move)
end

--返回当前操作模块
function ClubModel.getOpType(  )
	local opType = ''
	if CUR_OP_TYPE == ClubModel.MINE_TYPE then
		opType = 'user'
	elseif CUR_OP_TYPE == ClubModel.CLUB_TYPE then
		opType = 'club'
	elseif CUR_OP_TYPE == ClubModel.UNION_TYPE then
		opType = 'union'
	end
	return opType
end

-- 返回当前修改的位头像还是背景
function ClubModel.getPhotoType(  )
	local opType = ''
	if PHOTO_TYPE == ClubModel.PHOTO_BG then
		opType = 'background'
	elseif PHOTO_TYPE == ClubModel.PHOTO_HEAD then
		opType = 'avatar'
	end
	return opType
end

-------------------------------------
--------------- 下载图片
-- 添加头像、相册
-------------------------------------

function ClubModel.buildPhoto( is_flag, funcBack, params )

	bg = nil
	BgLayer = nil
	moveDistance = nil
	open_funcBack = nil
	delete_funcBack = nil
	sendData = {}

	-- 缓存图片名称
	iconName = 'image.png'

	-- 添加图片
	open_funcBack = funcBack

	-- params 必传
	if params and type(params) == "table" then
		-- 操作区域（个人、俱乐部、联盟）
		if params.op_type then
			CUR_OP_TYPE = params.op_type
		end

		-- 区分头像或相册
		if params.photo_type then
			PHOTO_TYPE = params.photo_type
		end

		-- 替换、删除图片所传数据
		if params.sendData then
			sendData = params.sendData
		end

		-- 删除相册回调
		if params.deleteBack then
			delete_funcBack = params.deleteBack
		end

	end
	
	addShowUI( is_flag )
end


-------------------------------------
--------------- 下载图片
-- 回调函数 图片地址 是否缩放 parent
-------------------------------------
function ClubModel.replayDownloadPhoto(funcBack, icon_url, isScale, sprite, isRemoveExist)
	local isRemoveNode = false
	if not sprite then return end

	if isRemoveExist then
		local imgPath = device.writablePath..icon_url
		local isHaveImg = cc.FileUtils:getInstance():isFileExist(imgPath)
		if isHaveImg then
			cc.FileUtils:getInstance():removeFile(imgPath)
		end
	end

	local function onEvent(event)
		if event == "exit" then
			isRemoveNode = true
		end
	end
	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	sprite:addChild(tnode)

	local function successBack(cpath)
		if isRemoveNode then return end

		if funcBack then
			funcBack(cpath)
		end
	end

	local function errBack()
		DZAction.delateTime(tnode, 1.5, function ()
			ClubModel.downloadPhoto(successBack, icon_url, isScale, errBack)		
		end)
	end

	-- DZSchedule.schedulerOnce(5, function()
	-- 	ClubModel.downloadPhoto(successBack, icon_url, isScale, errBack)
	-- end)
	ClubModel.downloadPhoto(successBack, icon_url, isScale, errBack)
end


function ClubModel.downloadPhoto( funack, icon_url, isScale, ferror )

	local function funcBack( cpath, result )
		print(' cpath: '..cpath)
		print('result: '..result)
		if result == 'file_success' then
			funack(cpath)
		elseif result == 'task_error' then
			print('failed')
			if ferror then
				if ferror ~= "download" then
					ferror()
				end
			end
		end
	end

	-- print(IMG_PREFIX_URL)
	local httpUrl = IMG_PREFIX_URL
	local iconUrl = icon_url

	if iconUrl == "" then
		if ferror then 
			if ferror ~= "download" then
				ferror()
			end
		end
		return
	end

	local turl 	= nil
	local tpath = nil
	turl = httpUrl..iconUrl
	print('iconUrl: '..iconUrl)
	tpath = device.writablePath..iconUrl
	
	-- if isScale then
	-- 	turl = small_str
	-- 	tpath = device.writablePath..iconUrl
	-- else
	-- 	turl = big_str
	-- 	tpath = device.writablePath.."big_"..iconUrl
	-- end
	print('=== img url  '..turl)
	print("tpath: " ..tpath)

	-- 缩略图每次都下载
	if ferror and ferror == "download" then
		-- print('   === img url  '..turl)
		local handle = cc.HandleData:createHandleData()
		handle:registerHandlerBack(funcBack)
		handle:fileTask(turl, tpath, "identifier")
	else
		local isHave = cc.FileUtils:getInstance():isFileExist(tpath) -- 是否已经存在
		if isHave then
			return funack(tpath)
		else
			-- print('   === img url  '..turl)
			local handle = cc.HandleData:createHandleData()
			handle:registerHandlerBack(funcBack)
			handle:fileTask(turl, tpath, "identifier")
		end
	end
	
end


-------------------------------------
----------------- 相册
-------------------------------------

function ClubModel.buildPageView( params )
	local bgArray = params.bgArray or {}
	local pos = params.pos
	local parent = params.parent
	local tag = params.tag
	local scrollView = params.view
	local rangeHeight = params.rangeH or 200
	local viewHeight = params.viewH or display.height
	local pointPar = scrollView:getParent()

	imageView = {}
	local imageBtn = {}
	imageViewName = {}
	local point = {}
	local point_sp = nil

	local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(true)
    pageView:setContentSize(cc.size(display.width, display.width))
    pageView:setPosition(pos)
    parent:addChild(pageView)

 	pageView:addEventListener(function ( sender, eventType )
 		local pageIndex = nil
 		if eventType == ccui.PageViewEventType.turning then
 			pageIndex = pageView:getCurrentPageIndex()
			print(pageIndex)
			for k,v in pairs(point) do
				if k == pageIndex+1 then
					v:setTexture("bg/circle_point_show.png")
				else
					v:setTexture("bg/circle_point_bg.png")
				end
			end
		end
	end)

 	-- scrollView
 	scrollView:setTouchEnabled(true)
    local scrollPos = scrollView:getInnerContainerPosition()
    -- dump(scrollPos)
    scrollView:addEventListener(function (  )

    end)

	local function callback( sender )
		local tag = sender:getTag()
		ClubModel.viewBigImage( imageViewName[tag])
	end
	local function loadImage(  )
		for i=1,#bgArray do
	    	-- print("---------------@@@@@@@@@@@@@@@: " .. imageViewName[i])
			imageView[i]:loadTexture(imageViewName[i], 0)
		end
	end
	
	local imageIdx = 0
	local img_bg = ResLib.COM_DEFUALT_PHOTO
	if tag then
		img_bg = "common/com_defualt_photo1.png"
	end
 	if next(bgArray) ~= nil then
 		local count = #bgArray
 		for i=1,count do
	    	local layout = ccui.Layout:create()
	    	layout:setClippingEnabled(true)
	    	layout:setContentSize(pageView:getContentSize())
	    	
	    	imageView[i] = UIUtil.addImageView({image=img_bg, touch=true, scale=true, size=cc.size(display.width, pageView:getContentSize().height), pos=cc.p(pageView:getContentSize().width/2, 0), ah=cc.p(0.5,0), parent=layout})

	    	imageBtn[i] = UIUtil.addImageBtn({norImg = "common/com_opacity0.png", pos=cc.p(pageView:getContentSize().width/2, 0), ah = cc.p(0.5, 0), touch = true, swalTouch = true, scale9 = true, size = cc.size(display.width, 600), listener = callback, parent = imageView[i]})
	    	imageBtn[i]:setTag(i)
	    	
	    	-- 图片下载 ResLib.COM_DEFUALT_PHOTO
	  		local url = bgArray[i].background
			local function funcBack( path )
				imageViewName[i] = path
				-- print("--------------->>>>>>>>>>: " .. imageViewName[i])
				imageIdx = imageIdx + 1
				if imageIdx == count then
					loadImage()
				end
			end
			ClubModel.downloadPhoto(funcBack, url, false)

			pageView:addPage(layout)
	    end

	    local pointBg = UIUtil.addImageView({image="bg/point_bg.png", touch=false, scale=true, size=cc.size(pageView:getContentSize().width,48), pos=pos, ah=cc.p(0,0), parent=parent})

	    point_sp = UIUtil.addImageView({image=ResLib.COM_OPACITY0, touch=false, scale=true, size=cc.size(count*20,48), pos=cc.p(pointBg:getContentSize().width/2, pointBg:getContentSize().height/2), ah=cc.p(0.5,0.5), parent=pointBg})

	    print(point_sp:getContentSize().width)
	    for j=1,count do 
			local posX = (2*j-1)/(count*2)
			point[j] = UIUtil.addPosSprite("bg/circle_point_bg.png", cc.p(point_sp:getContentSize().width*posX, 48/2), point_sp, cc.p(0.5, 0.5))
		end
		point[1]:setTexture("bg/circle_point_show.png")
 	else
 		local layout = ccui.Layout:create()
		layout:setClippingEnabled(true)
		layout:setContentSize(pageView:getContentSize())
		pageView:addPage(layout)

		local image = UIUtil.addImageView({image=img_bg, touch=false, pos=cc.p(pageView:getContentSize().width/2, 0), ah=cc.p(0.5,0), parent=layout})

	    point_sp = UIUtil.addImageView({image="bg/point_bg.png", touch=false, scale=true, size=cc.size(pageView:getContentSize().width,48), pos=pos, ah=cc.p(0,0), parent=parent})
		UIUtil.addPosSprite("bg/circle_point_show.png", cc.p(point_sp:getContentSize().width/2, 48/2), point_sp, cc.p(0.5, 0.5))
 	end
    return pageView
end


-------------------------------------
-------------- 查看 相册 大图
-------------------------------------

function ClubModel.viewBigImage( imageName )
	-- local layer = UIUtil.setBgScale(ResLib.MAIN_BG, display.center, parent)

	local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
	layer:setPosition(cc.p(0,0))
	local parent = display.getRunningScene()
	parent:addChild(layer,1000)

	layer:runAction(cc.FadeIn:create(0.2))

	local image_name = imageName or ResLib.COM_DEFUALT_PHOTO

	local image = UIUtil.addImageView({image=image_name, touch=false, pos=cc.p(display.cx, display.cy), ah=cc.p(0.5,0.5), scale = true, size = cc.size(display.width, display.width), parent=layer})

	dump(image:getContentSize())
	-- 注册单点触摸
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    local listenner = cc.EventListenerTouchOneByOne:create()
	-- 触摸开始
    local function onTouchBegan(touch, event)
        print("Touch Began")
        listenner:setSwallowTouches(true)
        return true
    end
    -- 触摸结束
    local function onTouchEnded(touch, event)
        print("Touch Ended")
        layer:runAction(cc.FadeOut:create(0.2))
        layer:removeFromParent()
    end
    listenner:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    dispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)

end

function ClubModel.simpleDownload(params)
	--[[
	ClubModel.simpleDownload({
		url = url,
		callback = function(path)
	    	print("path: "..path)
		end,
		isSmall = false
	})--]]

	local url = params.url 				-- 图片名称
    local callback = params.callback 	-- 回掉函数
    local httpUrl = IMG_PREFIX_URL 		-- 图片存储服务器地址

	local saveUrl = "" 	-- 保存地址
	local downUrl = "" 	-- 下载地址
	local wPath = "" 	-- 本地可写路径地址

	downUrl = httpUrl..url
	saveUrl = url
	wPath = device.writablePath..saveUrl

	print("发送开始 - writablePath: ", wPath)
	local isHave = cc.FileUtils:getInstance():isFileExist(wPath) -- 是否已经存在此图片
	if isHave then
		print("已经存在的图片")
		if callback then callback(wPath) end
		return
	end

	local function file_createDic(_path)
	    os.execute("mkdir -p \"" .. _path .. "\"")
	end

	local request = cc.XMLHttpRequest:new()
    request.timeout = 10

    -- request.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
    -- request.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    -- request.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    request.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    -- request.responseType = cc.XMLHTTPREQUEST_RESPONSE_DOCUMENT

    request:open("GET", downUrl)

    print("发送开始 - downloadFunc", downUrl)

    local function onReadyStateChanged(  )
        if request.readyState == 4 and (request.status >= 200 and request.status < 207) then
            print("发送结束 - downloadFunc", url)
            -- path = saveUrl
            -- file_createDic(path)

            local response = request.response
           	print("response",response)

           	local tpath = wPath
           	-- 写入本地文件
            io.writefile(tpath, response)

            -- 下载完成返回
            if callback then callback(tpath) end
        end

        request:unregisterScriptHandler()
    end

    request:registerScriptHandler(onReadyStateChanged)
    request:send()
end

return ClubModel