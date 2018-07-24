local ViewBase = require("ui.ViewBase")
local SysActivity = class("SysActivity", ViewBase)
local WaitServer = require("ui.WaitServer")
local _sysActivity = nil

local function Callback(  )
	_sysActivity:removeFromParent()
    local MessageLayer = require("message.MessageLayer")
    MessageLayer.updateSystemMsg( true )
end

function SysActivity:buildLayer( param )

    -- addTopBar
    UIUtil.addTopBar({backFunc = Callback, title = "系统通知", parent = self})

    Notice.deleteMessage( 4 )

    local winSize = cc.Director:getInstance():getVisibleSize()
    self._webView = ccexp.WebView:create()
    self._webView:setPosition(winSize.width / 2, winSize.height / 2-65)
    self._webView:setContentSize(winSize.width,  winSize.height-130)

    local token = XMLHttp.getGameToken()
    print(">>>>>>>>>>> " .. token)

    local url = nil
    if param then 
        url = XMLHttp.getHttpUrl() .. "/prize?token="..token.."&mtt_id="..param.mtt_id
    else
        url = XMLHttp.getHttpUrl() .."activity?token=" .. token 
    end
    self._webView:loadURL(url)
    self._webView:setScalesPageToFit(true)
    self._webView:setOnShouldStartLoading(function(sender, url)
        print("onWebViewShouldStartLoading, url is ", url)
        -- WaitServer.showForeverWait()
        return true
    end)
    self._webView:setOnDidFinishLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)
        -- WaitServer.removeForeverWait()
    end)
    self._webView:setOnDidFailLoading(function(sender, url)
        print("onWebViewDidFinishLoading, url is ", url)
        -- WaitServer.removeForeverWait()
    end)

    self:addChild(self._webView)--]]

end

function SysActivity:ctor( param )
	_sysActivity = self
	_sysActivity:setSwallowTouches()
	_sysActivity:addTransitAction()

	UIUtil.setBgScale(ResLib.MAIN_BG, display.center, self)
	 
	self:buildLayer(param)
end

return SysActivity