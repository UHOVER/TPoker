local ViewBase = require("ui.ViewBase")
local about = class("about", ViewBase)
local _about = nil

local function Callback(  )
	_about:removeTransitAction()
end

function about:buildLayer(  )

    -- addTopBar
    UIUtil.addTopBar({backFunc = Callback, title = "关于我们", parent = self})

	local winSize = cc.Director:getInstance():getVisibleSize()
    self._webView = ccexp.WebView:create()
    self._webView:setPosition(winSize.width / 2, winSize.height / 2-65)
    self._webView:setContentSize(winSize.width,  winSize.height-130)
    self._webView:loadURL(ABOUT_US_URL)
    self._webView:setScalesPageToFit(true)
    self._webView:setOnShouldStartLoading(function(sender, url)
        print("onWebViewShouldStartLoading, url is ", url)
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)
    end)

    self:addChild(self._webView)

end

function about:ctor(  )
	_about = self
	_about:setSwallowTouches()
	_about:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self:buildLayer()
end

return about