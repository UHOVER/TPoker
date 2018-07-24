local NewMsgMgr = {}

local NEW_MSG_PROMPT = 'NEW_MSG_PROMPT'
local _isDisplay = false
local _isDisScene = false

local function isDisplayTag()
	if _isDisScene and _isDisplay then
		return true
	end
	return false
end

local function removeNewMsg()
    local runScene = cc.Director:getInstance():getRunningScene()
    local prompt = runScene:getChildByName(NEW_MSG_PROMPT)
    if not prompt then return end
    prompt:removeFromParent()
end

local function disNewMsg()
    local runScene = cc.Director:getInstance():getRunningScene()
    local prompt = runScene:getChildByName(NEW_MSG_PROMPT)
    if prompt then 
    	-- removeNewMsg()
        return
    end

    local function msgBtn()
    	removeNewMsg()
    	ViewCtrol.showApplyList(nil)
        _isDisplay = false
    end

    local img = 'game/game_applay.png'
    local size = cc.size(160,52)
    local wsize = cc.Director:getInstance():getWinSize()
    local px = wsize.width - size.width / 2
    local pos = cc.p(px, wsize.height-130)

    local cbtn = UIUtil.controlBtn(img, img, img, nil, pos, size, msgBtn, runScene)
    cbtn:setLocalZOrder(ZOR_MAX_WINDOW)
    cbtn:setName(NEW_MSG_PROMPT)
end


function NewMsgMgr.updateNewMsgPos()
    local runScene = cc.Director:getInstance():getRunningScene()
    local prompt = runScene:getChildByName(NEW_MSG_PROMPT)
    if not prompt then return end

    local size = cc.size(160,52)
    local wsize = cc.Director:getInstance():getWinSize()
    local px = wsize.width - size.width / 2
    local pos = cc.p(px, wsize.height-130)

    prompt:setPosition(pos)
end

--通知有新消息、进入游戏请求有新消息、消息界面请求有新消息
function NewMsgMgr.setNewMsgTrue()
    local MessageCtorl = require("message.MessageCtorl")
    local isCardsNotice = MessageCtorl.getIsCardsNotice()
    if isCardsNotice then
        -- 已经在牌局请求消息界面直接返回
        return
    end
	_isDisplay = true
	NewMsgMgr.setNewMsgPrompt()
end
function NewMsgMgr.setNewMsgFalse()
	_isDisplay = false
	removeNewMsg()
end

--登录第一次、消息处理页面返回、手机进入后台再回来
NewMsgMgr.FIRST_LOGIN       = 1
NewMsgMgr.RETURN_MSGLAYER   = 2
NewMsgMgr.INTO_BACKGROUND   = 3
function NewMsgMgr.checkNewMsg(tag)
    if not XMLHttp.getLoginToken() then
        return
    end

    local MessageCtorl = require("message.MessageCtorl")
    MessageCtorl.dataStatCardNotice(function(data)
        if not data or #data == 0 then
            _isDisplay = false
        else
            _isDisplay = true
        end

        NewMsgMgr.setNewMsgPrompt()
    end, true)
end


function NewMsgMgr.setNewMsgPrompt()
	if isDisplayTag() then
		disNewMsg()
	else
		removeNewMsg()
	end
end


function NewMsgMgr.registerDisplayScene(scene)
	local function onEvent(event)
		if event == "enterTransitionFinish" then
			_isDisScene = true
			NewMsgMgr.setNewMsgPrompt()
		elseif event == "exitTransitionStart" then
			_isDisScene = false
		end
	end

	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	scene:addChild(tnode)
end

function NewMsgMgr.msgLayerRemoveMsg()
    removeNewMsg()
end


return NewMsgMgr