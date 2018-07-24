--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--创建之前设置管理员
--

local g_dataTable = {}--缓存添加的管理员
local g_dataTableUnion = {}--缓存添加的联盟管理
local g_self = nil

---适配回复
local function rebackScreen( )
    -- local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    -- local width, height = framesize.width, framesize.height

    -- width = framesize.width / scaleX-----
    -- height = framesize.height / scaleX----

    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("exit----rrrr=="..ratio)
    -- if ratio >= 1.5 then
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    -- else
        
    -- end
    -- StringUtils.setDZAdapter()
    -- body
end

------------------------btn-------------------------------
--返回按钮
local function handleReturn(sender)
	local SetModel = require("common.SetModel")
	SetModel.setManager(g_self.m_dataTable)
	g_dataTable = g_self.m_dataTable


    g_dataTableUnion = g_self.m_dataTableUnion
	
	g_self:removeFromParent()
	g_self = nil
	rebackScreen()
end

--查找按钮
local function searchID(sender)
	g_self.m_addBtn:setVisible(false)
    g_self.m_showYTJ:setVisible(false)
    g_self.m_Panel_searchResault:setVisible(false)
    g_self.m_Text_sr:setVisible(false)

	if(g_self.m_Ed:getText() == '') then
		return 
	end

	local function response(data)
        print("dds32333")
        dump(data)
		g_self.m_rdata = data

        if(data["id"] ~= "") then
        	g_self.m_Panel_searchResault:setVisible(true)
        	g_self.m_Panel_searchResault:getChildByName("Text_name"):setString(data["username"])
        	--g_self.m_Panel_searchResault:getChildByName("Text_ID"):setString("ID  "..data["id"])
        	g_self.m_Panel_searchResault:getChildByName("Text_ID"):setString("ID  "..data["u_no"])


        	--贴图回调
			local function funcBack( path )
				g_self.m_Panel_searchResault.img.clubIcon:setTexture(path)
			end
			
			if data["headimg"] ~= "" then
				ClubModel.downloadPhoto(funcBack, data["headimg"], true)
			else
				g_self.m_Panel_searchResault.img.clubIcon:setTexture("common/defualt_icon_user.png")
			end

--[[
        	if(g_self.m_Panel_searchResault.head ~= nil) then
        		--g_self.m_Panel_searchResault.head:removeFromParentAndCleanup(true)
        	end
        	
        	--local hx, hy = ccui.Helper:seekWidgetByName(g_self.m_root, "Image_head"):getPosition()
    		--local thead = UIUtil.addShaderHead(cc.p(hx, hy), data["headimg"], g_self.m_Panel_searchResault, function(thead)end)
			--thead:setScale(0.5)
			--g_self.m_Panel_searchResault.head = thead
]]
			--如果已经存在了，就返回
			for i = #g_self.m_dataTable, 1, -1 do 
		        if g_self.m_dataTable[i].id == g_self.m_rdata["id"] then
		        	g_self.m_showYTJ:setVisible(true)
		            return
		        end 
		    end
		   	
		   	g_self.m_addBtn:setVisible(true)
        else
        	g_self.m_Text_sr:setVisible(true)
        end
	end

    local tab = {}
    tab['manager_id'] = g_self.m_Ed:getText()
    tab['game_mod'] = g_self.m_game_mod --赛事类型
    tab['fid'] = tostring(g_self.m_fid) --俱乐部id
    MainCtrol.filterNet("searchManagerInfo", tab, response, PHP_POST)
end

--搜索俱乐部按钮
local function sClub(sender)
    local testly = require('main.SelectClubLayer'):create(g_self.m_clubDataArr, sender.data, 0, g_self)
    cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
end 

--添加按钮
local function addID(sender)
--[[
	g_self.m_Panel_searchResault:setVisible(false)
    g_self.m_Text_sr:setVisible(false)

    if(g_self.m_rdata == nil or g_self.m_rdata["id"] == "") then
		return
	end

	local function response(data)
        print("23334444")
        dump(data)

        --刷新列表
        g_self:updateList()
	end

    local tab = {}
    tab['manager_id'] = g_self.m_rdata["id"]
    MainCtrol.filterNet("addHostManager", tab, response, PHP_POST)
]]

	g_self.m_addBtn:setVisible(false)
    g_self.m_showYTJ:setVisible(false)
 	g_self.m_Panel_searchResault:setVisible(false)
    g_self.m_Text_sr:setVisible(false)


    table.insert(g_self.m_dataTable, g_self.m_rdata)
    g_self:updateList()
end

--删除按钮
local function delID(sender)
--[[
	local function response(data)
        print("23334444")
        dump(data)

        --刷新列表
        g_self:updateList()
	end

    local tab = {}
    tab['manager_id'] = sender.data["id"]
    MainCtrol.filterNet("removeHostManager", tab, response, PHP_POST)
]]

	for i = #g_self.m_dataTable, 1, -1 do 
        if g_self.m_dataTable[i].id == sender.data["id"] then 
            table.remove(g_self.m_dataTable, i) 
        end 
    end

    for i = #g_self.m_dataTableUnion, 1, -1 do
        if tostring(g_self.m_dataTableUnion[i].id) == tostring(sender.data["id"]) then 
            table.remove(g_self.m_dataTableUnion, i) 
        end 
    end

    g_self:m_funcUpdateList()
end

--类
local SearchManagerLayer = class("SearchManagerLayer", function ()
    return cc.Node:create()
end)

--stype是那种类型的界面1-组件牌局 2-俱乐部 31-联盟非公开赛 32-联盟公开赛
--fid俱乐部id 联盟的话就是联盟id
function SearchManagerLayer:ctor(stype, fid)
	self.m_root = nil
	self.m_Panel_searchResault = nil--搜索结果层
	self.m_Text_sr = nil--提示没找到
	self.m_Ed = nil--输入框
	self.m_rdata = nil--搜索结果
	self.m_listView = nil--管理员列表

	self.m_dataTable = {}--存储列表
    self.m_dataTableUnion = {}--存储列表,联盟里的数据
    
    self.m_clubDataArr = {}--俱乐部列表

	self.m_addBtn = nil--添加按钮
    self.m_showYTJ = nil--已添加
    self.m_stype = stype--是那种类型的界面1-组件牌局 2-俱乐部 31-联盟非公开赛 32-联盟公开赛
    self.m_fid = fid--俱乐部id 联盟的话就是联盟id
    self.m_game_mod = nil--赛事类型
    self.m_funcUpdateList = nil--更新函数
    
    self:init()
end

function SearchManagerLayer:init()
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerLayer.csb")
    self:addChild(cs)
    
    cs:getChildByName("Panel_root1"):setVisible(false)
    cs:getChildByName("Panel_root2"):setVisible(false)

    --转化一下
    if(self.m_stype == "person") then
        self.m_stype = 1
    elseif(self.m_stype == "club") then
        self.m_stype = 2
    elseif(self.m_stype == "union0") then
        self.m_stype = 31
    elseif(self.m_stype == "union1") then
        self.m_stype = 32
    end

    --1-组件牌局
    if(self.m_stype == 1) then
        cs:getChildByName("Panel_root1"):setVisible(true)
        self.m_root = cs:getChildByName("Panel_root1")
        self.m_funcUpdateList = self.updateList
        self.m_fid = 0--俱乐部id
        self.m_game_mod = "mtt_general"--赛事类型
    --2-俱乐部
    elseif(self.m_stype == 2) then
        cs:getChildByName("Panel_root1"):setVisible(true)
        self.m_root = cs:getChildByName("Panel_root1")
        self.m_funcUpdateList = self.updateList
        self.m_game_mod = "23"--赛事类型
    --31-联盟非公开赛
    elseif(self.m_stype == 31) then
        cs:getChildByName("Panel_root1"):setVisible(true)
        self.m_root = cs:getChildByName("Panel_root1")
        self.m_funcUpdateList = self.updateListUnion
        self.m_game_mod = "43"--赛事类型
        self:initClubList()--初始化俱乐部数据
    --32-联盟公开赛
    elseif(self.m_stype == 32) then
        cs:getChildByName("Panel_root2"):setVisible(true)
        self.m_root = cs:getChildByName("Panel_root2")
        self.m_game_mod = "43"--赛事类型
    end

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)
    --搜索按钮
	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_search")
    btn:touchEnded(searchID)
    --添加按钮
    btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_add")
    btn:touchEnded(addID)

    self.m_addBtn = ccui.Helper:seekWidgetByName(self.m_root, "Button_add")--添加按钮
    self.m_showYTJ = ccui.Helper:seekWidgetByName(self.m_root, "Text_ytj")--已添加
    self.m_addBtn:setVisible(false)
    self.m_showYTJ:setVisible(false)

    --搜索结果层
    self.m_Panel_searchResault = ccui.Helper:seekWidgetByName(self.m_root, "Panel_searchResault")
    self.m_Panel_searchResault:setVisible(false)
    --添加头像
    
--[[
    local hx, hy = ccui.Helper:seekWidgetByName(self.m_root, "Image_head"):getPosition()
    ccui.Helper:seekWidgetByName(self.m_root, "Image_head"):setVisible(false)
    local thead = UIUtil.addShaderHead(cc.p(hx, hy), "", self.m_Panel_searchResault, function(thead)end)
	thead:setScale(0.5)
	self.m_Panel_searchResault.head = thead
]]

	local img = ccui.Helper:seekWidgetByName(self.m_root, "Image_head")
	local stencil, clubIcon = UIUtil.createCircle("common/defualt_icon_user.png", cc.p(img:getPositionX(), img:getPositionY()), self.m_Panel_searchResault, ResLib.CLUB_HEAD_STENCIL_200)
	img.stencil = stencil
	img.clubIcon = clubIcon
	stencil:setAnchorPoint(cc.p(0.5, 0.5))
	clubIcon:setAnchorPoint(cc.p(0.5, 0.5))
	self.m_Panel_searchResault.img = img		
	--img:loadTexture("common/com_opacity0.png")



    --没找到文字
    self.m_Text_sr = ccui.Helper:seekWidgetByName(self.m_root, "Text_sr")
    self.m_Text_sr:setVisible(false)

    --用户文本框
    local ts = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getContentSize()
    local tsw = 580
    local cityEd = ccui.EditBox:create(cc.size(tsw, ts.height), "common/com_opacity0.png");
    cityEd:setAnchorPoint(cc.p(0.5, 0.5))
    local tpx, tpy = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getPosition()
    cityEd:setPosition(cc.p(tpx - ts.width/2 + tsw/2, tpy))
    cityEd:setFontSize(34);
    cityEd:setFontColor(cc.c3b(255, 255, 255));
    cityEd:setPlaceHolder("请输入对方ID")
    cityEd:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    cityEd:setPlaceholderFontSize(30)
    cityEd:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
    cityEd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_root:addChild(cityEd)
    self.m_Ed = cityEd

    --初始化组建牌局，俱乐部data
    if(#g_dataTable == 0) then
	    local  myData = {}
		myData.u_no = Single:playerModel():getPNumber()
		myData.username = Single:playerModel():getPName()
		myData.id = Single:playerModel():getId()
		myData.headimg = Single:playerModel():getPHeadUrl()
		myData.is_host = 1

		table.insert(self.m_dataTable, myData)
	else
		self.m_dataTable = g_dataTable
	end

    --初始化联盟data
    if(#g_dataTableUnion == 0) then
        local  myData = {}
        myData.u_no = Single:playerModel():getPNumber()
        myData.username = Single:playerModel():getPName()
        myData.id = Single:playerModel():getId()
        myData.headimg = Single:playerModel():getPHeadUrl()
        myData.is_host = 1
        myData.sClubs = {}--选择的俱乐部

        table.insert(self.m_dataTableUnion, myData)

        local test = {}
        test.username = "ok1"
        test.u_no = "11"
        test.headimg = ""
        test.is_host = 0
        test.id = 1
        test.sClubs = {}--选择的俱乐部
        table.insert(self.m_dataTableUnion, test)
        
        test = {}
        test.username = "ok2"
        test.u_no = "22"
        test.headimg = ""
        test.is_host = 0
        test.id = 2
        test.sClubs = {}--选择的俱乐部
        table.insert(self.m_dataTableUnion, test)

        test = {}
        test.username = "ok1333"
        test.u_no = "33"
        test.headimg = ""
        test.is_host = 0
        test.id = 3
        test.sClubs = {}--选择的俱乐部
        table.insert(self.m_dataTableUnion, test)
    else
        --清理管理员记录
        for i = 1, #g_dataTableUnion do
            g_dataTableUnion[i].sClubs = {}
        end


        self.m_dataTableUnion = g_dataTableUnion
    end

    --listView
    self.m_listView = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
    self.m_listView:setBounceEnabled(true)
    self.m_listView:setScrollBarEnabled(false)


    --修改康超之前屏幕适配
    local rootY = self.m_root:getPositionY()
    self.m_root:setPositionY(rootY - G_SURPLUS_H)
    self.m_listView:setContentSize(cc.size(750, 945-G_SURPLUS_H))
    self.m_listView:setPositionY(G_SURPLUS_H)



    --刷新管理员列表
    self:m_funcUpdateList()

    --适配处理
    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    -- local ratio = tframesize.height/tframesize.width
    -- print("rrrrrr="..ratio)
    -- if ratio >= 1.5 then
    --     print("iiiiiihhhhhh")
    --     local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    --     local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    --     local width = framesize.width / scaleY
    --     local height = framesize.height / scaleY
    --     cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    --     local realx = (framesize.width / scaleY - 750)*0.5
    --     self:setPosition(cc.p(realx, 0))
    -- else
        
    -- end
    -- local realx = StringUtils.setKCAdapter()
    -- if realx then
    --     self:setPosition(cc.p(realx, 0))
    -- end
end

function SearchManagerLayer:updateList()
--[[
    --初始化管理员列表
    local function response(data)
        print("23334444")
        dump(data)

		self.m_listView:removeAllItems()
		
		if(data[1] == "") then
			return
		end

		--"id": "826",
		--"is_host": 0,
		--"username": "15810734528",
		--"headimg": "",

		table.sort(data, function ( a, b )
			return a.is_host > b.is_host
		end)

		for i = 1, #data do	
			local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerLayerCell.csb")
			local tRoot = cell:getChildByName("Panel_root")
			tRoot:setTouchEnabled(true)
			ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].username)
			--ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].id)
			ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].u_no)

			--添加头像
		    local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
		    ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
		    local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].headimg, tRoot, function(thead)end)
			thead:setScale(0.5)

			tRoot:removeFromParent()
			self.m_listView:pushBackCustomItem(tRoot)

			--处理删除按钮
			local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_del")
			dbtn:touchEnded(delID)
			dbtn.data = data[i]

			if(data[i].is_host == 1) then
				ccui.Helper:seekWidgetByName(tRoot, "Button_del"):setVisible(false)
			end
		end		
	end

    local tab = {}
    MainCtrol.filterNet("getHostManagerList", tab, response, PHP_POST)
]]

	self.m_listView:removeAllItems()
	local data = self.m_dataTable

	for i = 1, #data do
		local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerLayerCell.csb")
		local tRoot = cell:getChildByName("Panel_root")
		tRoot:setTouchEnabled(true)
		ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].username)
		--ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].id)
		ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].u_no)

		--添加头像
	    local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
	    ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
	    local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].headimg, tRoot, function(thead)end)
		thead:setScale(0.5)

		tRoot:removeFromParent()
		self.m_listView:pushBackCustomItem(tRoot)

		--处理删除按钮
		local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_del")
		dbtn:touchEnded(delID)
		dbtn.data = data[i]

		if(data[i].is_host == 1) then
			ccui.Helper:seekWidgetByName(tRoot, "Button_del"):setVisible(false)
		end
	end		
end

function SearchManagerLayer:updateListUnion()
    self.m_listView:removeAllItems()

    local data = self.m_dataTableUnion

    for i = 1, #data do
        local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerLayerUnionCell.csb")
        local tRoot = cell:getChildByName("Panel_root")
        tRoot:setTouchEnabled(true)
        ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].username)
        --ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].id)
        ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..data[i].u_no)

        --添加头像
        local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
        ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
        local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].headimg, tRoot, function(thead)end)
        thead:setScale(0.5)

        --选择俱乐部按钮
        local sClubBtn = ccui.Helper:seekWidgetByName(tRoot, "Button_ysz")
        sClubBtn.data = data[i]
        sClubBtn:touchEnded(sClub)

        tRoot:removeFromParent()
        self.m_listView:pushBackCustomItem(tRoot)

        --处理删除按钮
        local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_del")
        dbtn:touchEnded(delID)
        dbtn.data = data[i]

        --创建者不需显示删除，和选择俱乐部
        if(data[i].is_host == 1) then
            ccui.Helper:seekWidgetByName(tRoot, "Button_del"):setVisible(false)
            sClubBtn:setVisible(false)
        end
    end     
end

--初始化俱乐部列表
function SearchManagerLayer:initClubList()
    local function response(data)
        print("ddddhhh==")
        dump(data)

        local clubDataArr = {}
        --处理data
        local idx = 1
        for k, v in pairs(data) do  
            print("kk="..k)
            local cellDataG = {}
            cellDataG.idx = idx
            cellDataG.type = "g"
            cellDataG.name = string.upper(k)
            clubDataArr[idx] = cellDataG

            idx = idx + 1

            for i = 1, #v do 
                print("----")
                dump(v)
                local cellDataC = {}
                cellDataC.idx = idx--cell索引
                cellDataC.type = "c"--显示模式
                cellDataC.name = v[i].union_name
                cellDataC.head_img = v[i].head_img
                cellDataC.id = v[i].id--俱乐部id
                cellDataC.mNum = 0--管理员数量
                clubDataArr[idx] = cellDataC
                idx = idx + 1
            end 
        end 

        print("wccccccc---")
        dump(clubDataArr)
        self.m_clubDataArr = clubDataArr

        --local testly = require('main.SelectClubLayer'):create(clubDataArr)
        --cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
    end

    local tab = {}
    tab.fid = self.m_fid
    MainCtrol.filterNet("getUnionsClubSortByLetters", tab, response, PHP_POST)
end

--清除缓存的管理员
function SearchManagerLayer:clearManagerData()
    g_dataTable = {}
    g_dataTableUnion = {}
end

--mdata管理员数据, cid俱乐部id
--清除管理员俱乐部
function SearchManagerLayer:delManagerClub(mdata, cid)
    for i = 1, #self.m_dataTableUnion do
        if(self.m_dataTableUnion[i].u_no == mdata.u_no) then
            for j = #self.m_dataTableUnion[i].sClubs, 1, -1 do 
                if self.m_dataTableUnion[i].sClubs[j].id == cid then 
                    table.remove(self.m_dataTableUnion[i].sClubs, j) 
                end 
            end
        end
    end
end

--添加管理员就俱乐部
function SearchManagerLayer:addManagerClub(mdata, cid)
    for i = 1, #self.m_dataTableUnion do
        if(self.m_dataTableUnion[i].u_no == mdata.u_no )then
            local club = {}
            club.id = cid
            table.insert(self.m_dataTableUnion[i].sClubs, club) 
        end
    end
end

function SearchManagerLayer:create(stype, fid)
    return SearchManagerLayer.new(stype, fid)
end

return SearchManagerLayer




--[[
    --初始化管理员列表
    local function response(data)
        print("ddddhhh==")
        dump(data)

        local clubDataArr = {}
        --处理data
        local idx = 1
        for k, v in pairs(data) do  
            print("kk="..k)
            local cellDataG = {}
            cellDataG.idx = idx
            cellDataG.type = "g"
            cellDataG.name = string.upper(k)
            clubDataArr[idx] = cellDataG

            idx = idx + 1

            for i = 1, #v do 
                print("----")
                dump(v)
                local cellDataC = {}
                cellDataC.idx = idx--cell索引
                cellDataC.type = "c"--显示模式
                cellDataC.name = v[i].union_name
                cellDataC.head_img = v[i].head_img
                cellDataC.id = v[i].id--俱乐部id
                cellDataC.mNum = 0--管理员数量
                clubDataArr[idx] = cellDataC
                idx = idx + 1
            end 
        end 

        print("wccccccc---")
        dump(clubDataArr)


        local testly = require('main.SelectClubLayer'):create(clubDataArr)
        cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)
    end

    local tab = {}
    tab.fid = 347
    MainCtrol.filterNet("getUnionsClubSortByLetters", tab, response, PHP_POST)
]]