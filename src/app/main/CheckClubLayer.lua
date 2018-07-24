--
-- Author: Your Name
-- Date: 2016-10-28 18:01:25
--帮助对话框
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
    g_self:removeFromParent()
    g_self = nil
    rebackScreen()
end


--类
local CheckClubLayer = class("CheckClubLayer", function ()
    return cc.Node:create()
end)

function CheckClubLayer:ctor(clubData)
    self.m_root = nil
    self.m_listView = nil--管理员列表

    self.m_dataTable = clubData--存储列表

    self:init()
end

function CheckClubLayer:init()
    g_self = nil
    g_self = self
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/CheckClubLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")

    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)
    

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

function CheckClubLayer:updateList()

    self.m_listView:removeAllItems()
    local data = self.m_dataTable

    for i = 1, #data do
        if(data[i].type == "g") then

        elseif(data[i].type == "c") then



            local cell = cc.CSLoader:createNodeWithVisibleSize("scene/CheckClubLayerCell.csb")
            local tRoot = cell:getChildByName("Panel_root")
            tRoot:setTouchEnabled(true)
            ccui.Helper:seekWidgetByName(tRoot, "Text_name"):setString(data[i].username)

            --添加头像
            local hx, hy = ccui.Helper:seekWidgetByName(tRoot, "Image_head"):getPosition()
            ccui.Helper:seekWidgetByName(tRoot, "Image_head"):setVisible(false)
            local thead = UIUtil.addShaderHead(cc.p(hx, hy), data[i].headimg, tRoot, function(thead)end)
            thead:setScale(0.5)

            tRoot:removeFromParent()
            self.m_listView:pushBackCustomItem(tRoot)
        end
    end     
end

function CheckClubLayer:create(clubData)
    return CheckClubLayer.new(clubData)
end

return CheckClubLayer