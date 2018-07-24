local ViewBase = require("ui.ViewBase")
local protocol = class("protocol", ViewBase)
local _protocol = nil

local function Callback(  )
	-- _protocol:removeTransitAction()
	_protocol:removeFromParent()
end

function protocol:buildLayer(  )

    -- addTopBar
    UIUtil.addTopBar({backFunc = Callback, title = "游戏服务协议", parent = self})

	local winSize = cc.Director:getInstance():getVisibleSize()
    self._webView = ccexp.WebView:create()
    self._webView:setPosition(winSize.width / 2, winSize.height / 2-65)
    self._webView:setContentSize(winSize.width,  winSize.height-130)
    self._webView:loadURL("http://api.allbetspace.com/protocol")
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

function protocol:createLayer(  )
	_protocol = self
	_protocol:setSwallowTouches()
	-- _protocol:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	
	self:buildLayer()
end

return protocol