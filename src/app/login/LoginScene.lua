local SceneBase = require("ui.SceneBase")
local LoginScene = class("LoginScene", SceneBase)

---适配回复
local function rebackScreen( )
    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    local width, height = framesize.width, framesize.height

    width = framesize.width / scaleX-----
    height = framesize.height / scaleX----

    local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local ratio = tframesize.height/tframesize.width
    print("exit----rrrr=="..ratio)
    if ratio >= 1.5 then
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    else
        
    end
    -- body
end

function LoginScene:initScene(  )
	rebackScreen( )
	local loginLayer = require("login.LoginLayer")
	local layer = loginLayer:create()
    layer:setName("LoginLayer")
	self:addChild(layer)
	layer:createLayer()
end

function LoginScene:startScene(  )
	local scene = LoginScene:create()
	cc.Director:getInstance():replaceScene(scene)

	scene:initScene()
end

return LoginScene

