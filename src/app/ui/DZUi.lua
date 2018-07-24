local DZUi = {}

function DZUi.addTableView(tView, csize, numRow, cellBack, noRowFunc, noSizeFunc)
	local r = math.random(1,255)
	local g = math.random(1,255)
	local b = math.random(1,255)
	local r1 = math.random(1,255)
	local g1 = math.random(1,255)
	local b1 = math.random(1,255)

	local function cellSizeForTable(table,idx)
        return csize.width, csize.height
    end
    local function numberOfCellsInTableView(table)
        return numRow
    end

    local function tableCellAtIndex(table, idx)
        idx = idx + 1
        local cell = table:dequeueCell()
        local color = cc.c4b(0,0,0,0)
        -- local color = cc.c4b(r,g,b,255)
        if idx % 2 == 0 then
            color = cc.c4b(0,0,0,0)
            -- color = cc.c4b(r1,g1,b1,255)
        end

        local function addCell(pcell)
            local layer = cc.LayerColor:create(color)
            layer:setContentSize(csize)
            layer:setTag(123)
            pcell:addChild(layer)

            cellBack(idx, layer, table)
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

    if not noSizeFunc then
	    tView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
	end
    
    tView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)

    if not noRowFunc then
	    tView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	end
    tView:reloadData()
end


DZUi.SLIDER_TEN = 1
DZUi.SLIDER_SIX = 2
DZUi.SLIDER_FOUR = 3
DZUi.SLIDER_CARD_FOUR = 4
DZUi.SLIDER_CARD_FIVE = 5
DZUi.SLIDER_CARD_SIX = 6
DZUi.SLIDER_CARD_TEN = 10
DZUi.SLIDER_CARD_FIVE_NO = 7
DZUi.SLIDER_CARD_FOUR_NO = 8
DZUi.SLIDER_CARD_SEVEN = 9
DZUi.SLIDER_CARD_TWELVE = 12
DZUi.SLIDER_CARD_TWELVE_REBUY = 13
DZUi.SLIDER_CARD_EIGHT = 14
function DZUi.addUISlider(parent, tag, pos, back, dtime)
	local isSlider = false
	local lw = 600
	local tslider = nil

	local imgs = {"main/main_progress3_1.png", "main/main_progress3.png", 'main/main_thumb.png'}
	local textarr = DZConfig.gameTimes()
	local textarrLabel = {}
	local posarr = {3.5, 14.5, 24, 34.5, 46.5, 57, 67.5, 78, 88, 97.5}
	local ttfarr = {20, 81.8, 143.6, 205.4, 267.2, 329, 390.8, 452.6, 514.4, 574.2}
	local middle = 5
	local subfix = 'h'

	if tag == DZUi.SLIDER_SIX then
		imgs = {"main/main_progress5_1.png", "main/main_progress5.png", 'main/main_thumb.png'}
		textarr = DZConfig.getStartScores()
		posarr = {3, 22.2, 40.2, 59, 77.5, 97.5}
		ttfarr = {30, 135, 240, 350, 460, 565}
		middle = 10
		subfix = 'BBs'
	elseif tag == DZUi.SLIDER_FOUR then
		imgs = {"main/main_progress4_1.png", "main/main_progress4.png", 'main/main_thumb.png'}
		textarr = DZConfig.getUpTime()
		posarr = {3, 34.5, 66, 97.5}
		ttfarr = {28, 220, 405, 565}
		middle = 16
		subfix = 'mins'
	elseif tag == DZUi.SLIDER_CARD_TEN then
		imgs = {"common/com_progress10_1.png", "common/com_progress10.png", 'main/main_thumb.png'}
		textarr = DZConfig.gameTimes()
		posarr = {3.5, 14.5, 25, 35.5, 46.5, 57, 67.5, 78, 88, 97.5}
		ttfarr = {20, 81.8, 143.6, 205.4, 267.2, 329, 390.8, 452.6, 514.4, 574.2}
		middle = 5
		subfix = 'h'
	elseif tag == DZUi.SLIDER_CARD_TWELVE_REBUY then
		imgs = {"common/com_progress12_1.png", "common/com_progress12.png", 'main/main_thumb.png'}
		textarr = DZConfig.getRebuyNum(  )
		posarr = {3.5, 11.5, 19.5, 28, 36.5, 45, 54.5, 63, 71.5, 80, 89, 97.5}
		ttfarr = {20, 70, 123.6, 170.4, 223.2, 275, 325.8, 375.6, 427, 477, 530, 574.2}
		middle = 4.5
		subfix = ''
	elseif tag == DZUi.SLIDER_CARD_TWELVE then
		imgs = {"common/com_progress12_1.png", "common/com_progress12.png", 'main/main_thumb.png'}
		textarr = DZConfig.getAnte()
		posarr = {3.5, 11.5, 19.5, 28, 36.5, 45, 54.5, 63, 71.5, 80, 89, 97.5}
		ttfarr = {20, 70, 123.6, 170.4, 223.2, 275, 325.8, 375.6, 427, 477, 530, 574.2}
		middle = 4.5
		subfix = ''
	elseif tag == DZUi.SLIDER_CARD_SIX then
		imgs = {"common/com_progress6_1.png", "common/com_progress6.png", 'main/main_thumb.png'}
		textarr = DZConfig.getStartScores()
		posarr = {3, 22.2, 40.2, 59, 78.5, 97.5}
		ttfarr = {30, 135, 240, 350, 460, 565}
		middle = 10
		subfix = 'BBs'
	elseif tag == DZUi.SLIDER_CARD_SEVEN then
		imgs = {"common/com_progress7_1.png", "common/com_progress7.png", 'main/main_thumb.png'}
		textarr = DZConfig.getStartSngScores()
		posarr = {3, 18.5, 34.5, 50.5, 66.5, 81.5, 97.5}
		ttfarr = {30, 115, 205, 300, 385, 485, 565}
		middle = 7.5
		subfix = 'BBs'
	elseif tag == DZUi.SLIDER_CARD_EIGHT then
		imgs = {"common/com_progress8_1.png", "common/com_progress8.png", 'main/main_thumb.png'}
		textarr = DZConfig.getPeopleNum()
		posarr = {3, 16.5, 29.5, 43.5, 56.5, 70, 85, 97.5}
		ttfarr = {25, 100, 176.5, 251.5, 332.5, 426, 500, 574}
		middle = 7.7
		subfix = ''
	elseif tag == DZUi.SLIDER_CARD_FOUR then
		imgs = {"common/com_progress4_1.png", "common/com_progress4.png", 'main/main_thumb.png'}
		textarr = DZConfig.getUpTime()
		posarr = {3, 34.5, 66, 97.5}
		ttfarr = {28, 220, 405, 565}
		middle = 15
		subfix = 'mins'
	elseif tag == DZUi.SLIDER_CARD_FOUR_NO then
		imgs = {"common/com_progress4_1.png", "common/com_progress4.png", 'main/main_thumb.png'}
		textarr = DZConfig.getAnte()
		posarr = {3, 34.5, 66, 97.5}
		ttfarr = {28, 215, 400, 565}
		middle = 15
		subfix = ''
	elseif tag == DZUi.SLIDER_CARD_FIVE then
		imgs = {"common/com_progress5_1.png", "common/com_progress5.png", 'main/main_thumb.png'}
		textarr = DZConfig.getSngUpTimes()
		posarr = {3, 27.5, 50, 75, 97.5}
		ttfarr = {29, 163, 302, 443, 565}
		middle = 12
		subfix = 'mins'
	elseif tag == DZUi.SLIDER_CARD_FIVE_NO then
		imgs = {"common/com_progress5_1.png", "common/com_progress5.png", 'main/main_thumb.png'}
		textarr = DZConfig.stopLevel()
		posarr = {3, 27.5, 50, 75, 97.5}
		ttfarr = {29, 163, 302, 443, 565}
		middle = 12
		subfix = ''
	end
	imgs = {"common/com_progress_img_blue_1.png", "common/com_progress_img_blue.png", 'main/main_thumb.png'}

	local tlayer = cc.LayerColor:create(cc.c4b(255,0,0,0),lw,150)
	tlayer:ignoreAnchorPointForPosition(false)
	tlayer:setAnchorPoint(cc.p(0.5,0.5))
	tlayer:setPosition(pos)
	parent:addChild(tlayer)

	local function getIdx()
		local val = tslider:getValue()
		local gidx = 1

		for i=1,#posarr do
			gidx = i
			if posarr[i] > val then
				break
			end
		end

		if posarr[ gidx ] - val > middle then
			gidx = gidx - 1
		end

		if gidx < 1 then 
			gidx = 1 
		elseif gidx > #posarr then
			gidx = #posarr 
		end

		return gidx
	end

	local function onTouchEnded(touch, event)
		if not isSlider then return end
		local idx = getIdx()
		posarr[1] = 1.1
    	posarr[#textarr] = 100
		tslider:setValue(posarr[ idx ])
		isSlider = false

		--[[for i=1,#textarrLabel do
    		textarrLabel[i]:setColor(cc.c3b(128,128,128))
    		textarrLabel[i]:setSystemFontSize(20)
    	end

    	textarrLabel[idx]:setColor(cc.c3b(74,136,219))
    	textarrLabel[idx]:setSystemFontSize(22)--]]

    	back(textarr[ idx ])
	end

	local function sliderChange(sender)
		isSlider = true
		-- if sender:getValue() < 2 then
		-- 	sender:setValue(2)
		-- end
	end

	--[[for i=1,#textarr do
    	local tx = ttfarr[i]
    	local ttft = UIUtil.addLabelArial(textarr[i]..subfix, 20, cc.p(tx,40), cc.p(0.5,0.5), tlayer, cc.c3b(140,144,147))
    	textarrLabel[i] = ttft
    end--]]

    tslider = UIUtil.addSlider(imgs, cc.p(lw/2,75), tlayer, sliderChange, 1, 100)
    tslider:setAnchorPoint(0.5,0.5)
    -- tslider:setScale(0.95)
    tslider:setValue(5 + 10.2 * 9)
    

    local tnode = cc.Node:create()
    tlayer:addChild(tnode)
    local listener = cc.EventListenerTouchOneByOne:create()  
    listener:registerScriptHandler(function() return true end,cc.Handler.EVENT_TOUCH_BEGAN)  
    listener:registerScriptHandler(function()end,cc.Handler.EVENT_TOUCH_MOVED)  
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED) 
    local eventDispatcher = tnode:getEventDispatcher()  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, tnode) 


    local tidx = 1
    for i=1,#textarr do
    	if textarr[i] == dtime then
    		tidx = i
    		break
    	end
    end
    posarr[1] = 1.1
    posarr[#textarr] = 100
    tslider:setValue(posarr[tidx])

	-- textarrLabel[getIdx()]:setColor(cc.c3b(74,136,219))
    return tlayer, textarr[tidx], tslider, textarrLabel
end

return DZUi