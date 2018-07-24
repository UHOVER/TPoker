local PageTable = class('PageTable', cc.LayerColor)
local LEFT = 'left'
local RIGHT = 'right'
local CENTER = 'center'

function PageTable:proofTable(tag, noAni)
    if tag == LEFT and self._cellIdx == 1 then return end
    if tag == RIGHT and self._cellIdx == self._cellNum then return end

    if tag == LEFT then
        self._cellIdx = self._cellIdx - 1
    elseif tag == RIGHT then
        self._cellIdx = self._cellIdx + 1
    elseif tag == CENTER then
    end

    local tablev = self._tablev
    local posarr = self._posarray
    local tpos = posarr[ self._cellIdx ]

    if noAni then
        tablev:setContentOffset(tpos)
        return
    end

    tablev:setContentOffsetInDuration(tpos, 0.2)
    DZAction.delateTime(tablev, 0.24, function()
	    tablev:setContentOffset(tpos)
        self._scrollBack(self, self._cellIdx)
    end)
end


function PageTable:addTouch(dis)
    local beginx = 0
    local miny = 5
    local maxy = self._tsize.height - 5

    local function onTouchBegan(touch, event)
        local target = event:getCurrentTarget()
        local touchpos = self:convertToNodeSpace(touch:getLocation())
        if touchpos.y < miny or touchpos.y > maxy then
            return false
        end

        beginx = touch:getLocation().x
        self._isScroll = false
        return true
    end  

    local function onTouchEnded(touch, event)  
        local lastx = touch:getLocation().x
        local isScroll = self._isScroll

        local distance = dis
        local movedis = lastx - beginx
        if movedis > distance and isScroll then
            self:proofTable(LEFT)
        elseif movedis < -distance and isScroll then
            self:proofTable(RIGHT)
        elseif movedis > 0 and isScroll then
            self:proofTable(CENTER)
        elseif movedis < 0 and isScroll then
            self:proofTable(CENTER)         
        end
    end

    local tnode = cc.Node:create()
    self:addChild(tnode, 10)
    local listener = cc.EventListenerTouchOneByOne:create()  
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)  
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = tnode:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tnode)
end


function PageTable:getPage()
    return self._tablev
end

function PageTable:createPage(csize, numRow, cellBack, addx)
    self._cellNum = numRow
    self._cellIdx = math.floor(numRow / 2)
    self._csize = csize

    local function scrollViewDidScroll(view)
        self._isScroll = true 
    end 
    local function cellSizeForTable(table,idx)
        return csize.width, csize.height
    end
    local function numberOfCellsInTableView(table)
        return self._cellNum
    end

    local function tableCellAtIndex(table, idx)
        idx = idx + 1
        local cell = table:dequeueCell()
        local color = cc.c4b(255,0,0,0)
        if idx % 2 == 0 then
            color = cc.c4b(0,250,0,0)
        end

        local function addCell(pcell)
            local layer = cc.LayerColor:create(color)
            layer:setContentSize(csize)
            layer:setTag(123)
            pcell:addChild(layer)

            cellBack(idx, layer)
        end
        
        if nil == cell then
            cell = cc.TableViewCell:new()
            addCell(cell)
        else
            local layer = cell:getChildByTag(123)
            if layer then
                layer:removeFromParent()
                addCell(cell)        
            end
        end

        return cell
    end

    local tablev = UIUtil.addTableView(self._tsize, cc.p(0,0), cc.SCROLLVIEW_DIRECTION_HORIZONTAL, self)
    tablev:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tablev:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tablev:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tablev:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tablev:reloadData()
    tablev:setBounceable(false)

    self._tablev = tablev

    local posarr = {}
    for i=1,self._cellNum do
        local tx = -(i - 1) * csize.width + addx
        table.insert(posarr, #posarr + 1, cc.p(tx,0))
    end
    self._posarray = posarr


    self:proofTable(LEFT, true)
end

function PageTable:ctor(size, pos, parent, sBack)
    self._tsize = size
    self._tablev = nil
    self._csize = nil
    self._isScroll = false
    self._cellNum = 0
    self._cellIdx = 1
    self._scrollBack = sBack
    self._posarray = {}

    -- self:initWithColor(cc.c4b(255,255,255,255))
    self:setContentSize(size)
    self:setPosition(pos)
    parent:addChild(self)
end

return PageTable