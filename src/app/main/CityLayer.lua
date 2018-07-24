local g_self = nil


local CITY_TARGET = nil
local clubCallBack = nil

local cityData = {}

-------一些功能函数-----
-- club 新建搜索

local function clraeData(  )
    CITY_TARGET = nil
    clubCallBack = nil
    g_self:removeFromParent()
end

-- 点击城市搜索
local function searchCity( data )
    dump(data)
    AddCtrol.searchCityFunc( data.code, g_self )
end

-- 输入字符搜索
local function addEditBox( pos, parent )
    local searchStr = nil
    local btn = nil
    local tips = AddCtrol.getHolderText(  )

    local searchEdit = UIUtil.addEditBox( ResLib.COM_EDIT_WHITE, cc.size(display.width-200, 60), pos, tips, parent )
    searchEdit:setMaxLength(18)
    searchEdit:setReturnType(cc.KEYBOARD_RETURNTYPE_SEARCH)
    searchEdit:setAnchorPoint(cc.p(0.5, 0.5))
    local function callback( eventType, sender )
        if eventType == "began" then
            -- btn:setVisible(false)
        elseif eventType == "return" then
            local str = StringUtils.trim(sender:getText())
            local lenStr = ""
            if string.len(str) > 18 then
                lenStr = StringUtils.checkStrLength( str, 18 )
            else
                lenStr = str
            end
            sender:setText(lenStr)
            searchStr = lenStr
            if searchStr ~= "" then
                AddCtrol.searchStrFunc( searchStr, g_self )
            end
            -- btn:setVisible(true)
        end
    end
    
    searchEdit:registerScriptEditBoxHandler( callback )

    -- 搜索按钮
    btn = UIUtil.addPosSprite(ResLib.SEARCH_BTN, cc.p(searchEdit:getContentSize().width-30, 30), searchEdit, cc.p(0.5, 0.5))
    btn:setScale(1.5)
end


----------------------------------------
--重置四个直辖市状态
local function resetZXCity()
    --重置4个直辖市控件
    for i = 1, 4 do
        ccui.Helper:seekWidgetByName(g_self.m_zxCityArrs[i], "Image_bg"):setVisible(false)
        --ccui.Helper:seekWidgetByName(g_self.m_zxCityArrs[i], "Text_name"):setColor(cc.c3b(255, 255, 255))        
    end
end

--显示直辖市状态
local function showZXCity(idx)
    ccui.Helper:seekWidgetByName(g_self.m_zxCityArrs[idx], "Image_bg"):setVisible(true)
    --ccui.Helper:seekWidgetByName(g_self.m_zxCityArrs[idx], "Text_name"):setColor(cc.c3b(255, 255, 255)) 
end

--移动层，移出显示屏幕
local function moveLayerBack( sender )
    sender:setTouchEnabled(false)
    local tS = sender

    g_self:stopAllActions()
    g_self:runAction( cc.Sequence:create( 
        cc.EaseIn:create(cc.MoveTo:create(0.3, cc.p(-1000, g_self:getPositionY() )), 2.5),
        cc.CallFunc:create( 
            function(sender)
                tS:setTouchEnabled(true)
            end)
        ) )
end

--------------------------btn-------------------------------
local function handleReturn(sender)
    moveLayerBack( sender )
    g_self.m_searchLayer:setPositionY(-g_self.m_searchLayer:getContentSize().height)
end

--选择哪个省
local function selectS(sender)
    --if(g_self.m_isSelectCell.idx ~= sender.idx) then
        g_self.m_isSelectCell.cell:setBackGroundColor(cc.c3b(28, 37, 58))
        g_self.m_isSelectCell.cell = sender
        g_self.m_isSelectCell.idx = sender.idx
        sender:setBackGroundColor(cc.c3b(0, 11, 23))

        --重置以前选择的市区状态
        if(g_self.m_isSelectCellCity.cell~= nil) then
            g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
            ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
        end
        g_self.m_isSelectCellCity = {}

        g_self.m_tableArrs[2].data = {}
        g_self.m_tableArrs[2].data = g_self.m_data[sender.idx]["citys"]
        g_self.m_tableArrs[2]:reloadData()
    --end
end

--选择省的市区列表
local function selectCell( event )

    local sender = event.target
    
    --改变颜色
    if event.name == "began" then
        --sender:setBackGroundColor(cc.c3b(131, 192, 218))
        ccui.Helper:seekWidgetByName(sender, "Image_st"):setVisible(true)

        if(g_self.m_isSelectCellCity.cell~= nil and g_self.m_isSelectCellCity.cell ~= sender) then
             g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
             ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
        end
        
        g_self.m_isSelectCellCity.cell = sender
        g_self.m_isSelectCellCity.idx = sender.idx
               
        --重置直辖市选择
        g_self.m_selectZXCity = -1
        resetZXCity()
        
    --移动层，返回地址数据
    elseif event.name == "ended" then

        --重置数据,记录当前数据状态
        sender.data["t1Idx"] = g_self.m_isSelectCell.idx
        sender.data["t2Idx"] = sender.idx
        sender.data["tposY1"] = g_self.m_tableArrs[1]:getContentOffset().y
        sender.data["tposY2"] = g_self.m_tableArrs[2]:getContentOffset().y

        --------------------------
        if CITY_TARGET == "new" then
            clubCallBack(sender.data)
            clraeData()
        elseif CITY_TARGET == "add" then
            searchCity(sender.data)
        else
            require("main.MainLayer"):setCityValue(sender.data["name"])
            moveLayerBack( sender )
        end
        
    end
end

--选择直辖市
local function selectZXCity(sender)
    --if(g_self.m_selectZXCity ~= sender.idx) then
        g_self.m_selectZXCity = sender.idx

        --重置4个直辖市控件
        resetZXCity()

        --显示对应的城市
        showZXCity(g_self.m_selectZXCity) 

        --重置tableView
        --重置以前选择的市区状态
        if(g_self.m_isSelectCellCity.cell~= nil) then
            g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
            ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
        end

        g_self.m_isSelectCellCity = {}--选择的城市

        if CITY_TARGET == "new" then
            clubCallBack(g_self.m_zxCityDataArrs[sender.idx])
            clraeData()
        elseif CITY_TARGET == "add" then
            searchCity(g_self.m_zxCityDataArrs[sender.idx])
        else
            --重置数据,记录当前数据状态
            require("main.MainLayer"):setCityValue(g_self.m_zxCityDataArrs[sender.idx]["name"])
            moveLayerBack( sender )
        end
        
    --end
end

--点击搜索按钮弹出table
local function searchCity(sender)
    --print("iiihhhheeee")
    
    local str = g_self.m_cityEd:getText()
    local tArrs = {}

    if(str ~= "") then
        for i = 1, #g_self.m_searchData do

            local ret = string.find(g_self.m_searchData[i]["name"], str)
            
            --不为nil证明找到了
            if(ret ~= nil) then
                table.insert(tArrs, g_self.m_searchData[i])
            end
        end
    end

    --print("asdasd993234j44443")
    --dump(tArrs)

    --搜索到结果
    if(#tArrs >= 1) then

        sender:setTouchEnabled(false)
        local tS = sender

        g_self.m_searchLayer:stopAllActions()
        g_self.m_searchLayer:runAction( cc.Sequence:create( 
            cc.EaseOut:create(cc.MoveTo:create(0.3, cc.p(0, 0 )), 2.5),
            cc.CallFunc:create( 
                function(sender)
                    tS:setTouchEnabled(true)
                end)
            ) )


        g_self.m_tableArrs[3].data = tArrs
        g_self.m_tableArrs[3]:reloadData()

    --没搜索到结果
    else
        local spl = ccui.Helper:seekWidgetByName(g_self.m_root, "Panel_show")
        spl:setVisible(true)
        spl:stopAllActions()

        spl:runAction( cc.Sequence:create( 
            cc.DelayTime:create(1.5),
            cc.CallFunc:create( 
                function(sender)
                    spl:setVisible(false)
                end)
            ) )
        
    end
end

--选择搜索到的城市
local function selectSearchCity(sender)

    moveLayerBack( sender )
    g_self.m_searchLayer:setPositionY(-g_self.m_searchLayer:getContentSize().height)
    
    --重置数据,记录当前数据状态
    require("main.MainLayer"):setCityValue(sender.data["name"])

    g_self:initData(sender.data["name"])

end

------------------------------------------------------------end


-------------------------tableView--------------------------------------------
--三个更新tableView的方法-----
-----1
local function updateCellContent1(idx, layer)

    if(g_self.m_tableArrs[1].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[1].data[idx]

    local tCell = layer:getChildByName("Panel_root")
    tCell:setSwallowTouches(false)
    tCell:setBackGroundColor(cc.c3b(28, 37, 58))
    tCell.idx = idx
      
    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_name")
    txt:setString(cdata["name"])
 
    --处理被选中的颜色
    if(g_self.m_isSelectCell.cell == nil) then
        g_self.m_isSelectCell.cell = tCell
        g_self.m_isSelectCell.idx = idx
    end

    if(g_self.m_isSelectCell.idx == idx) then
        g_self.m_isSelectCell.cell:setBackGroundColor(cc.c3b(28, 37, 58))
        g_self.m_isSelectCell.cell = tCell
        tCell:setBackGroundColor(cc.c3b(0, 11, 23))
    end

    tCell:touchEnded(selectS)
end

------2
local function updateCellContent2(idx, layer)
    if(g_self.m_tableArrs[2].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[2].data[idx]

    local tCell = layer:getChildByName("Panel_root")
    tCell:setSwallowTouches(false)
    tCell.data = cdata
    tCell.idx = idx
    tCell:setBackGroundColor(cc.c3b(0, 11, 23))
    ccui.Helper:seekWidgetByName(tCell, "Image_st"):setVisible(false)

    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_name")
    txt:setString(cdata["name"])

    --处理被选中的颜色
    if(g_self.m_isSelectCellCity.idx == idx) then
        if(g_self.m_isSelectCellCity.cell ~= nil) then
            g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
            ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
        end
        g_self.m_isSelectCellCity.cell = tCell
        --tCell:setBackGroundColor(cc.c3b(131, 192, 218))
        ccui.Helper:seekWidgetByName(tCell, "Image_st"):setVisible(true)
    end

    tCell:onTouch(selectCell)

end

------3
local function updateCellContent3(idx, layer)
    if(g_self.m_tableArrs[3].data[idx] == nil) then
        return
    end

    local cdata = g_self.m_tableArrs[3].data[idx]

    local tCell = layer:getChildByName("Panel_root")
    tCell:setSwallowTouches(false)
    tCell.data = cdata
    tCell:setBackGroundColor(cc.c3b(29, 46, 70))

    local txt = ccui.Helper:seekWidgetByName(tCell, "Text_name")
    txt:setString(cdata["name"])

    --处理被选中
    tCell:touchEnded(selectSearchCity)

end


local function numberOfCellsInTableView(table)

    if(table.data == nil) then 
        return 0
    end
    
    return #table.data
end

local function cellSizeForTable(table,idx)
    return table.cellSize.width, table.cellSize.height
end

local function tableCellAtIndex(table, idx)
    idx = idx + 1--默认从0开始，lua里没0所以+1
    local cell = table:dequeueCell() 
    
    --如果table 队列里取出的cell为空，重新创建一个
    if nil == cell then
        cell = cc.TableViewCell:new()
        local layer = cc.CSLoader:createNodeWithVisibleSize("scene/CityCell"..table.tIdx..".csb")
        layer:setContentSize(table.cellSize)
        layer:setTag(123)
        cell:addChild(layer)
    end

    --根据idx，重新更新cell内容
    table.callBack(idx, cell:getChildByTag(123))

    return cell
end

--------------------------------------------------------------------------------------end


--------------类
local CityLayer = class("CityLayer", function ()
    return cc.Node:create()
end)

function CityLayer:ctor()
	self.m_root = nil
	self.m_data = nil
    self.m_searchData = {}
    self.m_tableArrs = {}--存储2个tableView
    self.m_zxCityDataArrs = {
    [1] = {["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 1, ["tposY1"] = -1240, ["tposY2"] = -340},
    [2] = {["name"]="上海市", ["code"]="310000", ["t1Idx"] = 0, ["t2Idx"] = 2, ["tposY1"] = -1240, ["tposY2"] = -340},
    [3] = {["name"]="天津市", ["code"]="120000", ["t1Idx"] = 0, ["t2Idx"] = 3, ["tposY1"] = -1240, ["tposY2"] = -340},
    [4] = {["name"]="重庆市", ["code"]="500000", ["t1Idx"] = 0, ["t2Idx"] = 4, ["tposY1"] = -1240, ["tposY2"] = -340},
    }--4个直辖市数据
    self.m_zxCityArrs = {}--4个直辖市
    self.m_callBackArrs = {[1] = updateCellContent1, [2] = updateCellContent2, [3] = updateCellContent3}
    self.m_isSelectCell = {}--选择的省份
    self.m_isSelectCellCity = {}--选择的城市
    self.m_selectZXCity = -1
    self.m_searchLayer = nil--搜索层
    self.m_cityEd = nil--编辑
    self:init()
end

function CityLayer:init()
    self.m_data = require("main.CityData")

	g_self = nil
	g_self = self

	--初始化层
    local cs = cc.CSLoader:createNodeWithVisibleSize("scene/CityLayer.csb")
    self:addChild(cs)
    self.m_root = cs:getChildByName("Panel_root")
    
    --返回按钮
    local btn = ccui.Helper:seekWidgetByName(self.m_root, "Button_back")
    btn:touchEnded(handleReturn)

    --列表
    --初始化tableView
    --创建列表1-省份列表 2-城市列表
    local panel_t = {[1] = "Panel_sTable", [2] = "Panel_cityTable", [3] = "Panel_tableSearch"}
    local data_t = {[1] = self.m_data, [2] = self.m_data[1]["citys"], [3] = {}}

    for i = 1, 3 do
        local modelP = ccui.Helper:seekWidgetByName(self.m_root, panel_t[i])
        local tLayer = cc.CSLoader:createNodeWithVisibleSize("scene/CityCell"..i..".csb")
        local tCell = tLayer:getChildByName("Panel_root")
        --print('cccccsssssss=='.._gcsize.width..",".._gcsize.height)
        --print('mmmssss=='..modelP:getContentSize().width..","..modelP:getContentSize().height)
        local tableView = cc.TableView:create(modelP:getContentSize())
        tableView.cellSize = tCell:getContentSize()
        tableView.tIdx = i
        tableView.callBack = self.m_callBackArrs[i]
        tableView.data = data_t[i]
        tableView:initWithViewSize(modelP:getContentSize())
        tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        tableView:setPosition(cc.p(0, 0))
        tableView:setDelegate()
        modelP:addChild(tableView)
        self.m_tableArrs[i] = tableView
        --注册列表相关事件
        tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)   
        tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        tableView:setBounceable(true)
        tableView:reloadData()
    end

    --初始化4个直辖市控件
    for i = 1, 4 do
        self.m_zxCityArrs[i] = ccui.Helper:seekWidgetByName(self.m_root, "Panel_city_"..i)
        ccui.Helper:seekWidgetByName(self.m_zxCityArrs[i], "Image_bg"):setVisible(false)
        ccui.Helper:seekWidgetByName(self.m_zxCityArrs[i], "Text_name"):setColor(cc.c3b(255, 255, 255))        
        self.m_zxCityArrs[i].idx = i
        self.m_zxCityArrs[i]:touchEnded(selectZXCity)
    end

    --初始化输入框
    --用户文本框
    local cityEd = ccui.EditBox:create(cc.size(500, 60),"common/com_opacity0.png");
    cityEd:setAnchorPoint(cc.p(0,0))
    cityEd:setPosition(cc.p(30, 0))
    cityEd:setFontSize(30);
    cityEd:setFontColor(cc.c3b(64, 90, 125));
    cityEd:setPlaceHolder("请搜索地域名称")
    cityEd:setPlaceholderFontColor(cc.c3b(118 - 50, 181 - 50, 255 - 50))
    cityEd:setPlaceholderFontSize(30)
    cityEd:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    cityEd:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    ccui.Helper:seekWidgetByName(self.m_root, "Image_bg"):addChild(cityEd)
    self.m_cityEd = cityEd

    
    --self.m_cityEd:setText("皇")

    --初始化位置数据
    local posY1 = self.m_tableArrs[1]:getViewSize().height - (self.m_tableArrs[1].cellSize.height*(#self.m_data))
    local posY2 = self.m_tableArrs[2]:getViewSize().height - (self.m_tableArrs[2].cellSize.height*(#self.m_data[1]["citys"]))

    for i = 1, #self.m_zxCityDataArrs do
        --{["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 0, [".tposY1"] = -1240, ["tposY2"] = -340},
        self.m_zxCityDataArrs[i].tposY1 = posY1
        self.m_zxCityDataArrs[i].tposY2 = posY2
    end

    --初始化搜索数据
    self:initSearchData()

    --print("getContentOffsety1="..self.m_tableArrs[1]:getContentOffset().y)
    --print("getContentOffsety2="..self.m_tableArrs[2]:getContentOffset().y)

    local sBtn = ccui.Helper:seekWidgetByName(self.m_root, "Button_search")
    sBtn:touchEnded(searchCity)

    --------- 俱乐部创建、搜索 ------------
    if CITY_TARGET == "new" or CITY_TARGET == "add" then
        local topBar = UIUtil.addImageView({image = "bg/bg_top_bar.png", touch = true, scale = true, size = cc.size(display.width, 129), pos = cc.p(0,display.height-130), parent = self.m_root})
        local width = topBar:getContentSize().width
        local height = topBar:getContentSize().height
        
        local backBtn = UIUtil.addImageBtn({norImg = ResLib.COM_OPACITY0, selImg = ResLib.COM_OPACITY0, scale9 = true, size = cc.size(100, 80), ah = cc.p(0,0.5), pos = cc.p(10, height/2-20), touch = true, swalTouch = false, listener = clraeData, parent = topBar})
        UIUtil.addPosSprite(ResLib.BTN_BACK, cc.p(15, backBtn:getContentSize().height/2), backBtn, cc.p(0, 0.5))
        if CITY_TARGET == "add" then
            addEditBox( cc.p(width/2+30, height/2-20), topBar )
        else
            UIUtil.addLabelArial("选择城市", 36, cc.p(width/2, height/2-20), cc.p(0.5, 0.5), topBar):setColor(cc.c3b(204, 204, 204))
        end
    end

    --初始化搜索列表
    self.m_searchLayer = ccui.Helper:seekWidgetByName(self.m_root, "Panel_tableSearch")

end

--根据城市名，处理该显示的城市信息
function CityLayer:initData(cityStr)
    
    --{["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 0, ["tposY1"] = -1240, ["tposY2"] = -340},
    local tData = nil

    for i = 1, #self.m_searchData do
        if(self.m_searchData[i]["name"] == cityStr) then
            tData = self.m_searchData[i]
        end
    end

    if(tData ~= nil) then
        if(tData["t1Idx"] == 0) then
            --重置4个直辖市控件
            resetZXCity()

            --显示对应的城市
            self.m_selectZXCity = tData["t2Idx"]
            showZXCity( self.m_selectZXCity ) 

            --重置tableView
            --重置以前选择的市区状态
            if(g_self.m_isSelectCellCity.cell~= nil) then
                g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
                ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
            end

            g_self.m_isSelectCellCity = {}--选择的城市

            local data_t = {[1] = self.m_data, [2] = self.m_data[1]["citys"]}

            self.m_tableArrs[1].data = data_t[1]
            self.m_tableArrs[2].data = data_t[2]
            self.m_tableArrs[1]:reloadData()
            self.m_tableArrs[2]:reloadData()
        else
            resetZXCity()
            self.m_selectZXCity = -1

            if(g_self.m_isSelectCellCity.cell~= nil) then
                g_self.m_isSelectCellCity.cell:setBackGroundColor(cc.c3b(0, 11, 23))
                ccui.Helper:seekWidgetByName(g_self.m_isSelectCellCity.cell, "Image_st"):setVisible(false)
            end

            self.m_isSelectCell.idx = tData["t1Idx"]
            self.m_isSelectCellCity.idx = tData["t2Idx"]
            
            self.m_tableArrs[2].data = self.m_data[tData["t1Idx"]]["citys"]
            self.m_tableArrs[1]:reloadData()
            self.m_tableArrs[2]:reloadData()
            self.m_tableArrs[1]:setContentOffset(cc.p(0, tData["tposY1"]), false)
            self.m_tableArrs[2]:setContentOffset(cc.p(0, tData["tposY2"]), false)

        end
    end
	--self.m_tableArrs[1]:setContentOffset(cc.p(0, 0), false)
end

function CityLayer:initSearchData()

    --先塞入四个直辖市
    for i = 1, #self.m_zxCityDataArrs do
        table.insert(self.m_searchData, self.m_zxCityDataArrs[i])
    end

    --table1原始位置
    local posYS = self.m_tableArrs[1]:getViewSize().height - (self.m_tableArrs[1].cellSize.height*(#self.m_data))

    for i = 1, #self.m_data do
        for j = 1, #self.m_data[i]["citys"] do
            --{["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 1, ["tposY1"] = -1240, ["tposY2"] = -340},
            local tData = self.m_data[i]["citys"][j]
            tData.t1Idx = i
            tData.t2Idx = j

            --判断 table1 是否越界，移动位置
            local maxIdx = math.floor(self.m_tableArrs[1]:getViewSize().height / self.m_tableArrs[1].cellSize.height)

            --如果超出显示范围，重新计算位置
            tData.tposY1 = posYS

            if(i > maxIdx) then
                tData.tposY1 = posYS + (i - maxIdx)*self.m_tableArrs[1].cellSize.height
            end


            --判断 table2 是否越绝，移动位置
            maxIdx = math.floor(self.m_tableArrs[2]:getViewSize().height / self.m_tableArrs[2].cellSize.height)

            local posYSt2 = self.m_tableArrs[2]:getViewSize().height - (self.m_tableArrs[2].cellSize.height*(#self.m_data[i]["citys"]))
            tData.tposY2 = posYSt2

            if(j > maxIdx) then
                tData.tposY2 = posYSt2 + (j - maxIdx)*self.m_tableArrs[2].cellSize.height
            end

            table.insert(self.m_searchData, tData)

        end
    end
end

-- 获取所有城市数据
function CityLayer.getCityData(  )
    cityData = {}
    local cityTab1 = {
    [1] = {["name"]="北京市", ["code"]="110000", ["t1Idx"] = 0, ["t2Idx"] = 1, ["tposY1"] = -1240, ["tposY2"] = -340},
    [2] = {["name"]="上海市", ["code"]="310000", ["t1Idx"] = 0, ["t2Idx"] = 2, ["tposY1"] = -1240, ["tposY2"] = -340},
    [3] = {["name"]="天津市", ["code"]="120000", ["t1Idx"] = 0, ["t2Idx"] = 3, ["tposY1"] = -1240, ["tposY2"] = -340},
    [4] = {["name"]="重庆市", ["code"]="500000", ["t1Idx"] = 0, ["t2Idx"] = 4, ["tposY1"] = -1240, ["tposY2"] = -340},
    } 
    local cityTab2 = require("main.CityData")
    for i,v in ipairs(cityTab1) do
        cityData[#cityData+1] = v
    end
    for i,v in ipairs(cityTab2) do
        for key,val in pairs(v["citys"]) do
            cityData[#cityData+1] = val
        end
    end
    -- dump(cityData)
    return cityData
end

-- 传入城市code获取城市名称
function CityLayer.getCodeOfSite( code )
    -- print(">>>>>>>>>>>>>>code : ".. code)
    if not code then
        return "北京市"
    end
    if next(cityData) == nil then
        cityData = CityLayer.getCityData()
    end
    for k,v in pairs(cityData) do
        if tonumber(v.code) == tonumber(code) then
            return v.name
        end
    end
    return "北京市"
end

-- 传入城市名称获取城市code
function CityLayer.getSiteOfCode( site )
    if not site then
        return "110000"
    end
    if(site == "北京") then
        site = "北京市"
    elseif(site == "上海") then
        site = "上海市"
    elseif(site == "天津") then
        site = "天津市"
    elseif(site == "重庆") then
        site = "重庆市"
    end
    print(">>>>>>>>>>>>>>site : ".. site)
    if next(cityData) == nil then
        cityData = CityLayer.getCityData()
    end
    -- dump(cityData)
    for k,v in pairs(cityData) do
        if tostring(v.name) == tostring(site) then
            return tonumber(v.code)
        end
    end
    return "110000"
end

function CityLayer:create(target, funcBack)
    -- club
    if target then
        CITY_TARGET = target
    else
        CITY_TARGET = nil
    end
    if funcBack then
        clubCallBack = funcBack
    else
        funcBack = nil
    end
    return CityLayer.new()
end

return CityLayer