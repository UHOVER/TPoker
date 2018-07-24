--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--选择哪个俱乐部界面
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

    if(g_self.m_isResetScreen == 1) then
	   rebackScreen()
    end

    g_self:removeFromParent()
    g_self = nil
end

--选中俱乐部
local function selectClub(sender)
    --如果是选中状态，重置非选中状态
    if(sender.isSelect == 1) then
        sender.isSelect = 0
        sender:loadTexture("common/s_xzBtn.png")
        g_self.m_dataTable[sender.idx].mNum = g_self.m_dataTable[sender.idx].mNum - 1

        --删除对应管理员的选择的俱乐部数据
        if(g_self.m_thand ~= nil) then
            g_self.m_thand:delManagerClub(g_self.m_mData, g_self.m_dataTable[sender.idx].id)
        end
    elseif(sender.isSelect == 0) then
        sender.isSelect = 1
        sender:loadTexture("common/s_xzsBtn.png")
        g_self.m_dataTable[sender.idx].mNum = g_self.m_dataTable[sender.idx].mNum + 1

        --添加对应管理员的选择的俱乐部数据
        if(g_self.m_thand ~= nil) then
            g_self.m_thand:addManagerClub(g_self.m_mData, g_self.m_dataTable[sender.idx].id)
        end
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
            if(data[i].name == dStr) then
                g_self.m_listView:scrollToItem(data[i].idx, cc.p(.5, .5), cc.p(.5, .5))
                return
            end
        end
    end
end

--类
local SelectClubLayer = class("SelectClubLayer", function ()
    return cc.Node:create()
end)

--clubData俱乐部数据, 
--mData当前管理员数据, 
--isResetScreen是否需要移除屏幕适配,也通过这个值判断是哪个界面进来的, 1重置恢复适配 （创建赛事后界面），0-不需要恢复适配（创建赛事钱界面）
--thand上一个界面句柄
function SelectClubLayer:ctor(clubData, mData, isResetScreen, thand)
	self.m_root = nil
	self.m_Ed = nil--输入框
	self.m_rdata = nil--搜索结果
	self.m_listView = nil--管理员列表

	self.m_dataTable = clubData
    self.m_mData = mData--管理员数据
    self.m_isResetScreen = isResetScreen--是否重置屏幕适配1-是  0-否
    self.m_thand = thand
    self:init()
end

function SelectClubLayer:init()
	g_self = nil
	g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/SelectClubLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)
    --搜索按钮
	btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_search")
    btn:touchEnded(searchID)
    


    --用户文本框
    local ts = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getContentSize()
    local tsw = 580
    local cityEd = ccui.EditBox:create(cc.size(tsw, ts.height), "common/com_opacity0.png");
    cityEd:setAnchorPoint(cc.p(0.5, 0.5))
    local tpx, tpy = ccui.Helper:seekWidgetByName(self.m_root, "Image_txtbg"):getPosition()
    cityEd:setPosition(cc.p(tpx - ts.width/2 + tsw/2, tpy))
    cityEd:setFontSize(34);
    cityEd:setFontColor(cc.c3b(255, 255, 255));
    cityEd:setPlaceHolder("请输入俱乐部名称")
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

function SelectClubLayer:updateList()
	self.m_listView:removeAllItems()
	local data = self.m_dataTable

    if(data == nil) then
        return
    end
    
    local abc = ""

	for i = 1, #data do
  
        if(data[i].type == "g") then
            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/SelectClubLayerLittleCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_tag"):setString(data[i].name)

            abc = abc..data[i].name

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)
        elseif(data[i].type == "c") then
     
            --cellDataC.mNum = 0--管理员数量

            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/SelectClubLayerCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].name)
            ccui.Helper:seekWidgetByName(tRoot, "Text_yqm"):setString(tostring(data[i].mNum))

            local btn = ccui.Helper:seekWidgetByName(tRoot, "Image_select")
            btn.idx = data[i].idx
            btn.isSelect = 0--是否被选择
            btn:touchEnded(selectClub)

            local j = i

            --判断是否已经选择了该俱乐部
            for i = 1, #self.m_mData.sClubs do
                if(tostring(self.m_mData.sClubs[i].id) == tostring(data[j].id)) then
                    btn.isSelect = 1--是否被选择
                    btn:loadTexture("common/s_xzsBtn.png")
                end
            end

            --添加头像
            local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
            ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
            local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].head_img, tRoot, function(thead)end)
            thead:setScale(0.5)

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)
        end
	end

    ccui.Helper:seekWidgetByName(self.m_root, "Text_ABC"):setString(abc)
end


function SelectClubLayer:create(clubData, mData, isResetScreen, thand)
    return SelectClubLayer.new(clubData, mData, isResetScreen, thand)
end

return SelectClubLayer