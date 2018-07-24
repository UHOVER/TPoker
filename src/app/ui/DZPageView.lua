local DZPageView = class("DZPageView", cc.LayerColor)

function DZPageView:ctor(pos, size)
	self._pos = pos
	self._size = size
end

function DZPageView:addPageView()
	local function pageViewEvent(sender, eventType)
		print('pageViewEvent')
	    if eventType == ccui.PageViewEventType.turning then
	        print('turnning page')
	    end
	end

	local pageView = UIUtil.addPageView(cc.size(300, 300), cc.p(100,200), ccui.PageViewDirection.DZ_HORIZONTAL, self)
	for i=1,4 do
	    local color = cc.c3b(255,255,0)
	    if i % 2 == 0 then
	        color = cc.c3b(0,255,0)
	    end
	    local layout = ccui.Layout:create()
	    layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	    layout:setBackGroundColor(color)
	    layout:setContentSize(cc.size(300, 300))
	    layout:setPosition(10, 20)
	    pageView:addPage(layout)
	end
	pageView:addEventListener(pageViewEvent)
	pageView:scrollToPage(2)


	return pageView
end

function DZPageView:addDownPage()

end


return DZPageView

-- local DZPageView = require 'ui.DZPageView'
-- local page = DZPageView:create()
-- page:addPageView()
-- cs:addChild(page)