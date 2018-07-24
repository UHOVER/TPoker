--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--创建之后设置管理员
--

local g_self = nil

------------------------btn-------------------------------
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

            --如果已经存在了，就返回
            for i = #g_self.m_dataTable, 1, -1 do 
                if g_self.m_dataTable[i].id == g_self.m_rdata["id"] then
                    g_self.m_showYTJ:setVisible(true)
                    return
                end 
            end

            g_self.m_addBtn:setVisible(true)

--[[
        	if(g_self.m_Panel_searchResault.head ~= nil) then
        		g_self.m_Panel_searchResault.head:removeFromParentAndCleanup(true)
        	end
        	
        	local hx, hy = ccui.Helper:seekWidgetByName(g_self.m_root, "Image_head"):getPosition()
    		local thead = UIUtil.addShaderHead(cc.p(hx, hy), data["headimg"], g_self.m_Panel_searchResault, function(thead)end)
			thead:setScale(0.5)
			g_self.m_Panel_searchResault.head = thead
]]
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

--添加按钮
local function addID(sender)
    g_self.m_addBtn:setVisible(false)
    g_self.m_showYTJ:setVisible(false)
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
    tab['mtt_id'] = g_self.m_pjID
    MainCtrol.filterNet("appendMttMatchManager", tab, response, PHP_POST)
end

--查看按钮（非联盟）
local function checkID(sender)
    
    print("23334444=="..sender.data.id)

    local tData = {}
    tData.id = sender.data.id
    tData.m_pjID = g_self.m_pjID

    local runScene = cc.Director:getInstance():getRunningScene()
    local testly = require("main.CheckManagerLayer"):create(tData, 0)
    runScene:addChild(testly, 9999999)

	local function response(data)   
        dump(data)
	end
--[[
    local tab = {}
    tab['manager_id'] = sender.data["id"]
    MainCtrol.filterNet("removeHostManager", tab, response, PHP_POST)
]]
end

--查看按钮（联盟相关）
local function checkIDUnion(sender)
    
    print("cccuuuu=="..sender.data.id)

    local tData = {}
    tData.id = sender.data.id
    tData.m_pjID = g_self.m_pjID

    local runScene = cc.Director:getInstance():getRunningScene()
    local testly = require("main.UnionCheckLayer"):create(tData)
    runScene:addChild(testly, 9999999)
end

--分享按钮
local function fxBtn(sender)
    print("fffffxxxx=="..tostring(sender.data.u_no).."pid=="..g_self.m_pjID)
    DZWindow.shareDialog(DZWindow.SHARE_CODE, {pokerId = g_self.m_pjID, inviteCode = sender.data.invite_code})
end

--搜索俱乐部按钮
local function sClub(sender)
    
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

        local testly = require('main.SelectClubLayer'):create(clubDataArr, sender.data, 1, nil)
        cc.Director:getInstance():getRunningScene():addChild(testly, 9999999)

    end

    local tab = {}
    tab.fid = 347
    MainCtrol.filterNet("getUnionsClubSortByLetters", tab, response, PHP_POST)
end 


--类
local SearchCreateManagerLayer = class("SearchCreateManagerLayer", function ()
    return cc.Node:create()
end)

--pjID赛事牌局id
--stype是那种类型的界面1-组件牌局 2-俱乐部 31-联盟非公开赛 32-联盟公开赛
--fid俱乐部id 联盟的话就是联盟id
function SearchCreateManagerLayer:ctor(pjID, stype, fid)
	self.m_root = nil
	self.m_Panel_searchResault = nil--搜索结果层
	self.m_Text_sr = nil--提示没找到
	self.m_Ed = nil--输入框
	self.m_rdata = nil--搜索结果
    self.m_pjID = pjID--赛事牌局id
    self.m_c1 = nil--房主显示层
    self.m_c2 = nil--非房主显示层
    self.m_listView = nil--管理员列表
    self.m_listView1 = nil--
    self.m_listView2 = nil--
    self.m_dataTable = {}--存储临时管理员数据
    self.m_addBtn = nil--添加按钮
    self.m_showYTJ = nil--已添加

    self.m_stype = stype--是那种类型的界面1-组件牌局 2-俱乐部 31-联盟非公开赛 32-联盟公开赛
    self.m_fid = fid--俱乐部id 联盟的话就是联盟id
    self.m_game_mod = nil--赛事类型
    self.m_funcUpdateList = nil--更新函数

    self:init()
end

function SearchCreateManagerLayer:init()
    print("ssssssid===="..self.m_pjID)
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerCreateLayer.csb")
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
    --32-联盟公开赛
    elseif(self.m_stype == 32) then
        cs:getChildByName("Panel_root2"):setVisible(true)
        self.m_root = cs:getChildByName("Panel_root2")
    end

    
    --搜索按钮
	local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_search")
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

    --
    self.m_c1 = ccui.Helper:seekWidgetByName(self.m_root, "Panel_c1")
    self.m_c2 = ccui.Helper:seekWidgetByName(self.m_root, "Panel_c2")
    self.m_c1:setVisible(false)
    self.m_c2:setVisible(false)

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
    self.m_c1:addChild(cityEd)
    self.m_Ed = cityEd

    --listView
    self.m_listView1 = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
    self.m_listView1:setBounceEnabled(true)
    self.m_listView1:setScrollBarEnabled(false)

    self.m_listView2 = ccui.Helper:seekWidgetByName(self.m_root, "ListView_2")
    self.m_listView2:setBounceEnabled(true)
    self.m_listView2:setScrollBarEnabled(false)

    --刷新管理员列表
    self:m_funcUpdateList()

    --适配处理
    --如果遇到宽屏的 
    if( (display.width/(display.height - 220)) > 0.673249) then
        print("in hhhhhh")
        local rw = (display.height - 220)*0.673249
        local r = (display.height - 220)/1114
        self:setScale(r)
        local posx = (display.width - rw)*0.5
        self:setPositionX(posx)
    end

end

function SearchCreateManagerLayer:updateList()
    --初始化管理员列表
    local function response(data)
        print("23334444")
        dump(data)

        self.m_c1:setVisible(false)
        self.m_c2:setVisible(false)

        local MttShowCtorl = require("common.MttShowCtorl")

        --房主显示层 并且开启可以授权true
        if(data.is_host == 1 and MttShowCtorl.isAccess() == true) then
        --if(data.is_host == 1) then
            self.m_c1:setVisible(true)
            self.m_listView = self.m_listView1
        else
            self.m_c2:setVisible(true)
            self.m_listView = self.m_listView2
        end

        self.m_listView:removeAllItems()

        --"headimg"     = ""
        --"id"          = ""
        --"invite_code" = ""
        --"is_host"     = ""
        --"username"    = ""

        if(data.managers[1].id == "") then
            return
        end

        local tData = data.managers

		table.sort(tData, function ( a, b )
			return a.is_host > b.is_host
		end)

        self.m_dataTable = tData

		for i = 1, #tData do	
			local cell = cc.CSLoader:createNodeWithVisibleSize("scene/AddManagerCreateLayerCell.csb")
			local tRoot = cell:getChildByName("Panel_root")
			tRoot:setTouchEnabled(true)
			ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(tData[i].username)
			--ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..tData[i].id)
            ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID  "..tData[i].u_no)
            
            ccui.Helper:seekWidgetByName(tRoot, "Text_yqm"):setString(tData[i].invite_code)
			
            --添加头像
		    local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
		    ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
		    local thead = UIUtil.addShaderHead(cc.p(hx, hy), tData[i].headimg, tRoot, function(thead)end)
			thead:setScale(0.5)

			tRoot:removeFromParent()
			self.m_listView:pushBackCustomItem(tRoot)

			--查看按钮
			local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_check")
			dbtn:touchEnded(checkID)
			dbtn.data = tData[i]

            --分享按钮
            dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_fx")
            dbtn:touchEnded(fxBtn)
            dbtn.data = tData[i]

            --如果是房主
            if(data.is_host == 1) then
                dbtn:setVisible(true)
                ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(true)
            --不是房主
            else
                --判断id是不是跟自己一样，只能分享自己的
                dbtn:setVisible(false)
                ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(false)
                if(tonumber(tData[i].id) == tonumber(data.id)) then
                    dbtn:setVisible(true)
                    ccui.Helper:seekWidgetByName(tRoot, "Button_check"):setVisible(true)
                end
            end

             --俱乐部不显示邀请码 和 分享按钮
            if self.m_stype == 2 then
                ccui.Helper:seekWidgetByName(tRoot, "Text_yqm"):setVisible(false)
                ccui.Helper:seekWidgetByName(tRoot, "Text_m"):setVisible(false)
                dbtn:setVisible(false)
            end
		end		
--[[
		local Button_close = ccui.Helper:seekWidgetByName(root, "Button_close")
		Button_close:touchEnded(function(event)
				g_self.m_listDlg:removeFromParent()
				g_self.m_listDlg = nil
				end)
]]
	end

    local tab = {}
    tab.mtt_id = self.m_pjID
    MainCtrol.filterNet("getMttMatchManagersList", tab, response, PHP_POST)
end

function SearchCreateManagerLayer:updateListUnion()
    --[[
    --初始化管理员列表
    local function response(rdata)
        print("23334444")
        dump(rdata)

        self.m_c1:setVisible(false)
        self.m_c2:setVisible(false)

        local MttShowCtorl = require("common.MttShowCtorl")



        rdata.is_host = 1
        --房主显示层 并且开启可以授权true
        --if(rdata.is_host == 1 and MttShowCtorl.isAccess() == true) then
        if(rdata.is_host == 1) then
            self.m_c1:setVisible(true)
            self.m_listView = self.m_listView1
        else
            self.m_c2:setVisible(true)
            self.m_listView = self.m_listView2
        end

        self.m_listView:removeAllItems()


        if(rdata.managers[1].id == "") then
            return
        end

        local tData = rdata.managers

        table.sort(tData, function ( a, b )
            return a.is_host > b.is_host
        end)

        self.m_dataTable = tData
        local data = tData

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

            --选择俱乐部按钮(在该界面里，默认改为查看按钮)
            local sClubBtn = ccui.Helper:seekWidgetByName(tRoot, "Button_ysz")
            sClubBtn.data = data[i]
            sClubBtn:touchEnded(checkIDUnion)
            sClubBtn:setContentSize(cc.size(102, 50))
            sClubBtn:loadTextureNormal("common/s_ckan.png")
            sClubBtn:loadTexturePressed("common/s_ckand.png")
            sClubBtn:loadTextureDisabled("common/s_ckand.png")

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)

            --处理删除按钮,不显示删除按钮
            local dbtn = ccui.Helper:seekWidgetByName(tRoot, "Button_del")
            dbtn:setVisible(false)

            --创建者不需显示删除，和选择俱乐部
            if(data[i].is_host == 1) then
                ccui.Helper:seekWidgetByName(tRoot, "Button_del"):setVisible(false)
                sClubBtn:setVisible(false)
            end
        end     
    end

    local tab = {}
    tab.mtt_id = self.m_pjID
    MainCtrol.filterNet("getMttMatchManagersList", tab, response, PHP_POST)
    ]]
end

function SearchCreateManagerLayer:create(pjID, stype, fid)
    return SearchCreateManagerLayer.new(pjID,  stype, fid)
end

return SearchCreateManagerLayer