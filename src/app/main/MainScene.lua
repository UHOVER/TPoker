local MainScene = class("MainScene", require 'ui.SceneBase')
cc.exports.MainCtrol 	= require ('main.MainCtrol')
cc.exports.MainHelp 	= require ('main.MainHelp')
cc.exports.MainModel 	= require ('model.MainModel')

local function initLayer(parent)
    -- local emitter = cc.ParticleSystemQuad:create("dzeffect/slot_paper01.plist")
    -- -- emitter:retain()
    -- emitter:setPosition(display.center)
    -- -- local sprite = cc.Sprite:create('dzeffect/achievement_star.png')
    -- -- local batch = cc.ParticleBatchNode:createWithTexture(sprite:getTexture())
    -- local batch = cc.ParticleBatchNode:create('dzeffect/slot_paper01.png')
    -- batch:addChild(emitter)
    -- parent:addChild(batch, 10)

    -- local label2 = cc.LabelAtlas:_create("012345", "font/num_b.plist")
    -- parent:addChild(label2)
    -- label2:setPosition( cc.p(310,500) )

    -- local label3 = cc.LabelAtlas:_create("12", "font/num_b1.png", 31, 56,  string.byte("0"))
    -- parent:addChild(label3)
    -- label3:setPosition( cc.p(310,700) )
    -- label3:setAnchorPoint(0,0)
    -- label3:setString('4563234324324243242')

    -- label2:setOpacity( 32 )
    -- UIUtil.addLabelImg('11', cc.p(310,700), cc.p(0.5,0.5), parent, UIUtil.FONT_B1)

    local function menuQuit(tag, sender)
        Network.close()
        os.exit()
    end

    local tab = {}
    tab['font'] = 'Arial'
    tab['size'] = 30
    UIUtil.addMenuFont(tab, '退出游戏', cc.p(display.width, display.top-50), menuQuit, parent)
end

function MainScene:initScene(isEnterHall)
    --关闭
    Storage.setIsCloseVoice(true)

    MainModel:init()

    local MainLayer = require 'main.MainLayer'
    local mainLayer = MainLayer:create()
    self:addChild(mainLayer)
    mainLayer:createLayer(isEnterHall)

    --核查砖石、记分牌
    MainCtrol.checkUserScores()
end

function MainScene:startScene(isEnterHall)

	local scene = MainScene:create()
	cc.Director:getInstance():replaceScene(scene)
	scene:initScene(isEnterHall)

    NewMsgMgr.registerDisplayScene(scene)
end

return MainScene
