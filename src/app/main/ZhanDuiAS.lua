--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--战队添加删除
--

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
    StringUtils.setDZAdapter()
    -- body
end

------------------------btn-------------------------------
--返回按钮
local function handleReturn(sender)
	rebackScreen()
    g_self:removeFromParent()
    g_self = nil
end

local function doneBtn(sender)

    local function response(tData)
        print("完成")
        -- dump(tData)

        local curScene = cc.Director:getInstance():getRunningScene()
        if curScene:getChildByName("message") then
            print("clubInfoPlus")
            local message = curScene:getChildByName("message")
            local clubInfoPlus = message:getChildByName("clubInfoPlus")
            if clubInfoPlus:getChildByName("MineTeam") then
                print("MineTeam")
                local myEvent = cc.EventCustom:new("C_Event_Update_List_ZhanDui")
                local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
                customEventDispatch:dispatchEvent(myEvent)
            end
        else
            local myEvent = cc.EventCustom:new("C_Event_Update_List_ZhanDui")
            local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
            customEventDispatch:dispatchEvent(myEvent)
        end
        ViewCtrol.showTick({content = "邀请成功!"})
        rebackScreen()
        g_self:removeFromParent()
        g_self = nil
    end

    --处理选择的玩家id
    local data = g_self.m_dataTable
    -- dump(data)
    local tUids = {}

    if(data == nil) then
        return
    end

    for i = 1, #data do
        if(data[i].type == "c") then
            if(data[i].isS == 1) then
                table.insert(tUids, data[i].id)
            end
        end
    end

    if(#tUids <= 0) then
        return
    end
    
    local tab = {}
    tab['team_id'] = g_self.m_gData.team_id
    tab['club_uids'] = tUids
    tab['club_id'] = g_self.m_gData.club_id
    MainCtrol.filterNet("inviteUserJoinTeam", tab, response, PHP_POST)
end

local function delBtn(sender)

    local function response(tData)
        print("删除")
        dump(tData)

        local myEvent = cc.EventCustom:new("C_Event_Update_List_ZhanDui")
        local customEventDispatch = cc.Director:getInstance():getEventDispatcher()
        customEventDispatch:dispatchEvent(myEvent)

        rebackScreen()
        g_self:removeFromParent()
        g_self = nil

        ViewCtrol.showTick({content = "删除成功！"})
    end

    --处理选择的玩家id
    local data = g_self.m_dataTable
    local tUids = {}

    if(data == nil) then
        return
    end

    for i = 1, #data do
        if(data[i].type == "c") then
            if(data[i].isS == 1) then
                table.insert(tUids, data[i].id)
            end
        end
    end

    if(#tUids <= 0) then
        return
    end

    print("123asd")

    ViewCtrol.popHint({bgSize = cc.size(display.width-100, 300), content = "确定要删除"..#tUids.."队员吗？",
        sureFunBack = function()
            local tab = {}
            tab['team_id'] = g_self.m_gData.team_id
            tab['user_ids'] = tUids
            MainCtrol.filterNet("deleteUserFromTeam", tab, response, PHP_POST)
        end})

end


--选中俱乐部
local function selectClub(sender)
    --如果是选中状态，重置非选中状态
    if(sender.isSelect == 1) then
        sender.isSelect = 0
        sender:loadTexture("common/s_xzBtn.png")
        g_self.m_dataTable[sender.idx].isS = 0

    elseif(sender.isSelect == 0) then
        sender.isSelect = 1
        sender:loadTexture("common/s_xzsBtn.png")
        g_self.m_dataTable[sender.idx].isS = 1
    end

    dump(g_self.m_dataTable)
end

--查找按钮
local function searchID(sender)

	if(g_self.m_Ed:getText() == '') then
		return 
	end

    local dStr = g_self.m_Ed:getText()

	local data = g_self.m_dataTable
    for i = 1, #data do
        if(data[i].type == "c") then
            if(data[i].no == dStr) then
                g_self.m_listView:scrollToItem(data[i].idx - 1, cc.p(.5, .5), cc.p(.5, .5))
                local tPanel = g_self.m_listView:getItem(data[i].idx - 1)
                
                tPanel:stopAllActions()
                tPanel:runAction(cc.Sequence:create(
                    cc.TintTo:create(0.1, 46, 77, 140),
                    cc.TintTo:create(0.1, 0, 0, 0),
                    cc.TintTo:create(0.1, 46, 77, 140),
                    cc.TintTo:create(0.1, 0, 0, 0)
                ))

                return
            end
        end
    end

    ViewCtrol.popHint({popType = 1, bgSize = cc.size(display.width-100, 300), content = "未查到此ID",
    sureFunBack = function()
        g_self.m_Ed:setText("")
    end})
end

--类
local ZhanDuiAS = class("ZhanDuiAS", function ()
    return cc.Node:create()
end)

--mdata, 战队成员数据
--aos,是增加还是删除 1增加 2删除
--gData,上个界面保存的数据
function ZhanDuiAS:ctor(mdata, aos, gData)
	self.m_root = nil
	self.m_Ed = nil--输入框
	self.m_rdata = nil--搜索结果
	self.m_listView = nil--管理员列表

	self.m_dataTable = mdata
    self.m_gData = gData
    self.m_aos = aos
    self:init()
end

function ZhanDuiAS:init()
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/ZhanDuiAS.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    --搜索按钮
	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_search")
    btn:touchEnded(searchID)

    --完成按钮
    btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_done")
    

    --根据不同界面，显示不同内容
    if(self.m_aos == 1) then
        ccui.Helper:seekWidgetByName(self.m_root, "Text_ttt"):setString("添加队员")
        btn:setString("确定")
        btn:touchEnded(doneBtn)
    elseif(self.m_aos == 2) then
        ccui.Helper:seekWidgetByName(self.m_root, "Text_ttt"):setString("删除队员")
        btn:setString("删除")
        btn:touchEnded(delBtn)
    end
    
    


    --用户文本框
    local ts = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getContentSize()
    local tsw = 580
    local cityEd = ccui.EditBox:create(cc.size(tsw, ts.height), "common/com_opacity0.png");
    cityEd:setAnchorPoint(cc.p(0.5, 0.5))
    local tpx, tpy = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getPosition()
    cityEd:setPosition(cc.p(tpx - ts.width/2 + tsw/2 + 56, tpy))
    cityEd:setFontSize(34);
    cityEd:setFontColor(cc.c3b(255, 255, 255));
    cityEd:setPlaceHolder("请输入玩家ID")
    cityEd:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    cityEd:setPlaceholderFontSize(30)
    cityEd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    cityEd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_root:addChild(cityEd)
    self.m_Ed = cityEd

    --listView
    self.m_listView = ccui.Helper:seekWidgetByName(self.m_root, "ListView_1")
    self.m_listView:setBounceEnabled(true)
    self.m_listView:setScrollBarEnabled(false)

    --刷新管理员列表
    self:updateList()

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
    local realx = StringUtils.setKCAdapter()
    if realx then
        self:setPosition(cc.p(realx, 0))
    end
end

function ZhanDuiAS:updateList()
	self.m_listView:removeAllItems()
	local data = self.m_dataTable

    if(data == nil) then
        return
    end

	for i = 1, #data do
  
        if(data[i].type == "g") then
            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/SelectClubLayerLittleCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_tag"):setString(data[i].name)


            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)
        elseif(data[i].type == "c") then
     
            --cellDataC.mNum = 0--管理员数量

            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/ZhanDuiASCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setColor(cc.c3b(0, 0, 0))
            tRoot:setCascadeColorEnabled(false)
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].name)
            ccui.Helper:seekWidgetByName(tRoot, "Text_ID"):setString("ID: "..data[i].no)
            
            local btn = ccui.Helper:seekWidgetByName(tRoot, "Image_s")
            btn.idx = data[i].idx
            btn.isSelect = 0--是否被选择
            btn:touchEnded(selectClub)
    
            --队长不删除
            if(self.m_aos == 2) then
                if(data[i].team_leader == 1) then
                    btn:setVisible(false)
                end
            else
                -- exist_team 为0：没有加入任何战队；否则为加入战队的名称
                if tonumber(data[i].exist_team) == 0 then
                    btn:setVisible(true)
                else
                    btn:setVisible(false)
                    local team_icon = UIUtil.addPosSprite("bg/zd_flag.png", cc.p(tRoot:getContentSize().width-20, tRoot:getContentSize().height/2), tRoot, cc.p(1, 0.5))
                    local team_name = UIUtil.addLabelArial(data[i].exist_team, 26, cc.p(team_icon:getPositionX()-team_icon:getContentSize().width-10, tRoot:getContentSize().height/2), cc.p(1,0.5), tRoot):setColor(cc.c3b(9, 183, 66))
                end
            end

            --添加头像
            local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
            ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
            local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].head_img, tRoot, function(thead)end)
            thead:setScale(0.35)

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)
        end
	end

    
end


function ZhanDuiAS:create(mdata, aos, gData)
    return ZhanDuiAS.new(mdata, aos, gData)
end

return ZhanDuiAS