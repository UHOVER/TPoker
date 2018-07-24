local DZAction = {}

function DZAction.bezierAction(time, bezier, sprite)
    local bezier = cc.BezierBy:create(time, bezier)
    sprite:runAction(bezier)
end


function DZAction.delateTime(sprite, time, back)
	if back == nil then
		back = function() end
	end
	if sprite == nil then
		sprite = cc.Sprite:create()
		cc.Director:getInstance():getRunningScene():addChild(sprite)
	end

	local callfunc = cc.CallFunc:create(back)
	local  seq = cc.Sequence:create(cc.DelayTime:create(time), callfunc)
	sprite:runAction(seq)
end


function DZAction.delateShield(time)
	local sceneing = cc.Director:getInstance():getRunningScene()
	local layer = cc.Layer:create()
	sceneing:addChild(layer, StringUtils.getMaxZOrder(sceneing))
	UIUtil.shieldLayer(layer, nil)
	
	DZAction.delateTime(layer, time, function()
		layer:removeFromParent()
	end)
end

function DZAction.scheduleTimes(sprite, time, times, back, isRightNow)
	local count = 0
	local node = sprite
	local trepeat, seq = nil, nil
	if sprite == nil then 
	 	node = cc.Node:create()
		local sceneing = cc.Director:getInstance():getRunningScene()
		sceneing:addChild(node)
	end

	local callfunc = cc.CallFunc:create(function()
		count = count + 1
		back(sprite, count)

		if count >= times  then
			if sprite == nil then 
				node:removeFromParent(true)
			else 
				node:stopAction(trepeat)
			end
		end
	end)

	if isRightNow then
		count = count + 1
		back(sprite, count)
	end

    seq = cc.Sequence:create(cc.DelayTime:create(time), callfunc)
	trepeat = cc.RepeatForever:create(seq)
	node:runAction(trepeat)
	return trepeat
end


DZAction.EASE_IN = 0
DZAction.EASE_OUT = 1
DZAction.MOVE_TO = 2
function DZAction.easeInMove(sprite, toPos, time, tag, back)
	if back == nil then
		back = function() end
	end

	local callfunc = cc.CallFunc:create(back)
	local move = cc.MoveTo:create(time, toPos)
	local ease = nil

	if tag == DZAction.EASE_IN then
		ease = cc.EaseIn:create(move, time)
	elseif tag == DZAction.EASE_OUT then
		ease = cc.EaseOut:create(move, time)
	else
		ease = move
	end

	local  seq = cc.Sequence:create(ease, callfunc)
	sprite:runAction(seq)
end


DZAction.FADE_IN = 0
DZAction.FADE_OUT = 1
DZAction.FADE_TO = 2
function DZAction.fadeInOut(sprite, time, tag, back)
	if back == nil then
		back = function() end
	end
	if not sprite then return end

	local fade = nil
	if tag == DZAction.FADE_IN then
		fade = cc.FadeIn:create(time)
	else
		fade = cc.FadeOut:create(time)
	end

	local callfunc = cc.CallFunc:create(back)
	local  seq = cc.Sequence:create(fade, callfunc)
	sprite:runAction(seq)
end

function DZAction.fadeToCallback(sprite, time, opacity, back)
	if back == nil then
		back = function() end
	end
	if not sprite then return end
	local fade = cc.FadeTo:create(time, opacity)
	local callfunc = cc.CallFunc:create(back)
	local seq = cc.Sequence:create(fade, callfunc)
	sprite:runAction(seq)
end

DZAction.CHILD_FADE_IN = 0
DZAction.CHILD_FADE_OUT = 1
function DZAction.fadeChildInOut(sprite, time, tag)
	local function getAction()
		local fade = nil
		if tag == DZAction.CHILD_FADE_IN then
			fade = cc.FadeIn:create(time)
		else
			fade = cc.FadeOut:create(time)
		end
		return fade
	end

	local function lookChild(parent)
		parent:runAction( getAction() )
		local children = parent:getChildren()

		if children then
	        for i=1,#children do
	            lookChild( children[ i ] )
	        end
    	end
	end

	lookChild(sprite)
end


function DZAction.rotateBy(sprite, time, back)
	if back == nil then
		back = function() end
	end
	local rotate = cc.RotateBy:create(time, cc.Vertex3F(0,360,0), 1, 1)
	local callfunc = cc.CallFunc:create(back)
	local seq = cc.Sequence:create(rotate, callfunc)
    sprite:runAction(seq)
end

function DZAction.flipTwoSprite(sp1, sp2, time, onComplete, onMiddle, time2)
	local tsp2 = sp2
    sp1:setVisible(true)
    sp1:setRotation3D(cc.vec3(0, 0, 0))
    tsp2:setVisible(false)
    tsp2:setRotation3D(cc.vec3(0, 270, 0))

    if not time2 then
    	time2 = time
    end

    local function backTwo()
    	if nil ~= onComplete then onComplete() end
    end

    local function onEvent(event)
		if event == "exit" then
			tsp2 = nil
		end
	end
	local tnode = cc.Node:create()
	tnode:registerScriptHandler(onEvent)
	tsp2:addChild(tnode)

    local function backOne()
    	if nil ~= onMiddle then onMiddle() end
    	sp1:setVisible(false)

    	if not tsp2 then
    		backTwo()
    		return
    	end

    	tsp2:setVisible(true)
    	
    	local rotate = cc.RotateBy:create(time2, cc.vec3(0, 90, 0), 1, 1)
    	local seq2 = cc.Sequence:create(rotate, cc.CallFunc:create(backTwo))
    	tsp2:runAction(seq2)
    end
    
    local rotate = cc.RotateBy:create(time, cc.vec3(0, 90, 0), 1, 1)
    local seq1 = cc.Sequence:create(rotate, cc.CallFunc:create(backOne))
    sp1:runAction(seq1)
end


function DZAction.progressBack(sprite, percent, time, back, toPercent)
	if back == nil then
		back = function() end
	end
	if not toPercent then toPercent = 100 end
	
	local fromTo = cc.ProgressFromTo:create(time, toPercent, percent)
	local callfunc = cc.CallFunc:create(back)
	local seq = cc.Sequence:create(fromTo, callfunc)
	sprite:runAction(seq)
end


function DZAction.ProgressToBack(nowPercent, toPercent, rtime, img, pos, parent, back)
	if back == nil then
		back = function() end
	end
	local to = cc.ProgressTo:create(rtime, toPercent)
	local callfunc = cc.CallFunc:create(back)
	local seq = cc.Sequence:create(to, callfunc)

	local pro = cc.ProgressTimer:create(cc.Sprite:create(img))
    pro:setPercentage(nowPercent)
    pro:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pro:setMidpoint(cc.p(0, 0))
    pro:setBarChangeRate(cc.p(1, 0))
    pro:setPosition(pos)
	parent:addChild(pro)

    pro:runAction(seq)

    return pro
end


function DZAction.fadeRepeat(sprite, time)
	local fadeIn = cc.FadeIn:create(time)
	local fadeOut = cc.FadeOut:create(time)
	local seq = cc.Sequence:create(fadeIn, cc.DelayTime:create(0.2), fadeOut)
	local rep = cc.RepeatForever:create(seq)
	sprite:runAction(rep)
end


function DZAction.scale(sprite, dirXY, rdirXY, time, forever, back)
	if back == nil then
		back = function() end
	end

	local callfunc = cc.CallFunc:create(back)
	local scaleby = cc.ScaleTo:create(time, dirXY.x, dirXY.y)
	local scalebyR = cc.ScaleTo:create(time, rdirXY.x, rdirXY.y)
	local seq = cc.Sequence:create(scaleby, scalebyR, callfunc)

	if forever then
		seq = cc.RepeatForever:create(seq)
	end

	sprite:runAction(seq)
end


function DZAction.showWindow(layer, back, scaleFirst, scaleLast, fadeTime, playTime)
    if layer == nil then 
        return 
    end 
    if back == nil then
    	back = function() end
    end
    if scaleFirst == nil then 
        scaleFirst = 1.1
    end 
    if scaleLast == nil then 
        scaleLast = 1
    end 
    if fadeTime == nil then 
        fadeTime = 0.2
    end 
    if playTime == nil then 
        playTime = 0.2 
    end 
    layer:setOpacity(0)

    local scale = cc.ScaleTo:create(playTime, scaleLast)
    local callfunc = cc.CallFunc:create(back)
    local spawn = cc.Spawn:create(cc.FadeIn:create(fadeTime), cc.ScaleTo:create(playTime, scaleFirst))
	local seq = cc.Sequence:create(spawn, scale, callfunc)

	layer:runAction(seq)
end

function DZAction.hideWindow(layer, back, scale, fadeTime, playTime)
    if layer == nil then 
        return 
    end 
    if back == nil then
    	back = function() end
    end
    if scale == nil then 
        scale = 0.9
    end 
    if fadeTime == nil then 
        fadeTime = 0.2
    end 
    if playTime == nil then 
        playTime = 0.2
    end 

    local spawn = cc.Spawn:create(cc.FadeIn:create(fadeTime), cc.ScaleTo:create(playTime, scale))
    local callfunc = cc.CallFunc:create(back)
    local seq = cc.Sequence:create(spawn, callfunc)
    layer:runAction(seq)
end


--sng
function DZAction.sngUPBlind(sblind)
	local currScene = cc.Director:getInstance():getRunningScene()
	local bblind = sblind * 2
	local msg = '下一手将升盲至   '..sblind..'/'..bblind

	local tsize = cc.size(450,60)
	local rect = cc.rect(0,0,0,0)
	local bg = UIUtil.scale9Sprite(rect, 'common/com_line_bg1.png', tsize, cc.p(display.cx, 0), currScene)
	bg:setLocalZOrder(StringUtils.getMaxZOrder(currScene))

	local color = cc.c3b(255,255,255)
   	local msgWin = UIUtil.addLabelBold(msg, 30, cc.p(tsize.width/2, tsize.height/2), cc.p(0.5,0.5), nil, color)
   	bg:addChild(msgWin)
   	bg:setOpacity(160)

   	bg:setPositionY(display.height * 0.7)
   	bg:setScaleY(0)

   	-- local move = cc.MoveTo:create(0.6, cc.p(display.cx, display.height * 0.7))
   	local scale0 = cc.ScaleTo:create(0.3, 1)
   	local delay = cc.DelayTime:create(2)
   	local scale = cc.ScaleTo:create(0.6,0)
	local callfunc = cc.CallFunc:create(function()
		bg:removeFromParent()
		end)
   	local seq = cc.Sequence:create(scale0, delay, scale, callfunc)
  	bg:runAction(seq)
end

function DZAction.blinkActionForever(target)
	local fadeIn = cc.FadeIn:create(0.01)
	local delay  = cc.DelayTime:create(0.7)
	local fadeOut = cc.FadeOut:create(0.01)
	local delay2 = cc.DelayTime:create(0.7)
	local seq = cc.Sequence:create(fadeIn, delay, fadeOut, delay2)
	local repeatAct = cc.RepeatForever:create(seq)
	target:runAction(repeatAct)
end

--左右的震动 time时间 shakeCount震动次数， shakeRangle震动范围, callback 晃动结束 回调
function DZAction.shakeWithTime(target, time, shakeCount, shakeRangle, scaleTarget, callback)
	local time = time or 0.5
	local shakeCount = shakeCount or 10
	local shakeRange = shakeRangle or 10
	local perUnitTime = time/shakeCount
	-- local scaleTarget = 1.15

	local shakeArray = {}
	local ptx,pty = target:getPositionX(), target:getPositionY()
	for i = 1, shakeCount do 

		if i == 1 then 
			local shakeLeft = cc.MoveTo:create(perUnitTime/2,ccp(ptx + shakeRange, pty))
			shakeArray[#shakeArray + 1] = shakeLeft
		elseif i == shakeCount then 
			local shakeRight = CCMoveTo:create(perUnitTime/2, ccp(ptx, pty))
			shakeArray[#shakeArray + 1] = shakeRight
		else
			local dir = i%2
			-- print(" dir = "..dir.." perUnitTime/2:"..perUnitTime/2)
			if dir < 1 then 
			  local shakeMoveL = CCMoveTo:create(perUnitTime,ccp(ptx - shakeRange, pty))
			  shakeArray[#shakeArray + 1] = shakeMoveL
			else
			  local shakeMoveR = CCMoveTo:create(perUnitTime,ccp(ptx + shakeRange, pty) )
			  shakeArray[#shakeArray + 1] = shakeMoveR
			end
		end
	end
	
	local seq = cc.Sequence:create(shakeArray)
	target:runAction(seq)
end


return DZAction