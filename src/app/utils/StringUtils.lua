local StringUtils = {}

function StringUtils.getPercentPos(xp, yp)
    local xx = xp * display.width * 0.01
    local yy = yp * display.height * 0.01
	return cc.p(xx, yy)
end

function StringUtils.getPercentSize(xp, yp, size)
    if size == nil then
        size = display.size
    end
	return cc.p(xp*size.width, yp*size.height)
end

function StringUtils.getLabelPositionX(label)
    local anchx = label:getAnchorPoint()
    local posx = label:getPositionX()
    local w = label:getContentSize().width * (1 - anchx.x)
    return posx + w + 2
end

function StringUtils.extendClass(father, child)
    local t = tolua.getpeer(father)
    if not t then
        t = {}
        tolua.setpeer(father, t)
    end
    setmetatable(t, child)
    return father
end


function StringUtils.getMaxZOrder(node)
    local zOrder = 0
    if node ~= nil then
        local nodes = node:getChildren()
        
        if nodes ~= nil then
            for i=1,#nodes do
                local childNode = nodes[i]
                zOrder = math.max(zOrder, childNode:getLocalZOrder())
            end
        end
    else
        print("StringUtils.getMaxZOrder node is nil");
    end

    zOrder = zOrder + 1
    if zOrder >= ZOR_MAX_WINDOW - 100 then
        zOrder = ZOR_MAX_WINDOW - 100
    end
    return zOrder
end

function StringUtils.copyTable(cTable)
    local tab = {}  
    
    for k, v in pairs(cTable or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = StringUtils.copyTable(v)  
        end  
    end

    return tab 
end

function StringUtils.replaceTab(tab, idx, element)
    if type(tab) ~= "table" then
        assert(nil, 'replaceTab 出错')
    end
    if tab[ idx ] == nil then
        assert(nil, 'replaceTab 越界')
    end

    table.remove(tab, idx)
    table.insert(tab, idx, element)
end

function StringUtils.linkArray(tab1, tab2)
    if type(tab1) ~= "table" or type(tab2) ~= "table" then
        assert(nil, 'replaceTab 出错')
    end

    for i=1,#tab2 do
        table.insert(tab1, #tab1+1, tab2[i])
    end
end

function StringUtils.linkArrayNew(tab1, tab2)
    if type(tab1) ~= "table" or type(tab2) ~= "table" then
        assert(nil, 'replaceTab 出错')
    end

    local rets = {}
    for i=1,#tab1 do
        table.insert(rets, #rets+1, tab1[i])
    end
    for i=1,#tab2 do
        table.insert(rets, #rets+1, tab2[i])
    end
    return rets
end


function StringUtils.threeBit(num)
    if num < 0 then
        assert(nil, 'threeBit '..num)
    end

    if num < 10 then
        return '00'..num
    elseif num < 100 then
        return '0'..num
    else
        return num
    end
end


function StringUtils.splitStr(str, sepChar)
    local startIdx = 1
    local idx = 1
    local ret = {}

    while true do
        local befIdx = string.find(str, sepChar, startIdx)
       
        if not befIdx then
            ret[ idx ] = string.sub(str, startIdx, string.len(str))
            break  
        end

        ret[ idx ] = string.sub(str, startIdx, befIdx - 1)
        startIdx = befIdx + string.len(sepChar)

        idx = idx + 1
    end

    return ret
end


-- 截取字符长度
-- sString:要切割的字符串
-- nMaxCount:字符串上限,汉字字为2的倍数
-- nShowCount:显示字母字个数，汉字字为2的倍数,可为空
-- 函数实现：截取字符串一部分，剩余用“...”替换
function StringUtils.getShortStr( sString, nMaxCount, nShowCount )
    if sString == nil or nMaxCount == nil then
        return
    end

    local sStr = sString
    local tCode = {}
    local tStr  = {}
    local nLenInByte = #sStr
    local nWidth = 0
    if nShowCount == nil then
        nShowCount = nMaxCount - 3
    end

    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i)
        local byteCount = 0
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte <223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        local char = nil
        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1)
            i = i + byteCount - 1
        end
        if byteCount == 1 then
            nWidth = nWidth + 1
            table.insert(tStr, char)
            table.insert(tCode, 1)
        elseif byteCount > 1 then
            nWidth = nWidth + 2
            table.insert(tStr, char)
            table.insert(tCode, 2)
        end
    end

    if nWidth > nMaxCount then
        local _sS = ""
        local _len = 0
        for i=1,#tStr do
            _sS = _sS .. tStr[i]
            _len = _len + tCode[i]
            if _len >= nShowCount then
                break
            end
        end
        sStr = _sS .. "..."
    end
    return sStr
end

-- 去除收尾空格
function StringUtils.trim(s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function StringUtils.checkStrLength( str, modLen )
    if str == "" then
        return ""
    end
    local strTab = {}
    for utfChar in string.gmatch(str, "[%z\1-\127\194-\244][\128-\191.]*") do  
        table.insert(strTab, utfChar)
    end
    -- dump(strTab)
    -- print(#strTab)
    -- local chiniseCount = 0
    -- local englishCount = 0
    local lenByte = 0
    local lenStr = ""

    for i,v in ipairs(strTab) do
        -- local curByte = string.byte(v)
        -- print("&&&&&&&&&&&&&&&& curByte: ".. curByte)
        local curLen = string.len(v)
        lenByte = lenByte + curLen
        if lenByte <= modLen then
            lenStr = lenStr..v
        end
        -- print("&&&&&&&&&&&&&& " .. lenStr)
        -- 英文字符
        -- if curByte <= 127 then
        --     englishCount = englishCount + 1
        -- end
        -- -- 中文字符
        -- if curByte > 127 then
        --     chiniseCount = chiniseCount + 1
        -- end
    end
    print("&&&&&&&&&&&&&& " .. lenStr)
    return lenStr
end


function StringUtils.isPhoneNumber(number)
    local numstr = tostring(number)
    if #numstr ~= 11 then
        return false
    end

    local reg = '^(1[3,4,5,7,8])[0-9]%d%d%d%d%d%d%d%d$'
    
    if string.find(numstr, reg) then
        -- local i,j = string.find(numstr, reg)
        -- print(i..'   '..j)
        return true
    end

    return false
end


-- local realx = StringUtils.setKCAdapter()
    -- if realx then
    --     _layer:setPosition(cc.p(realx, 0))
    -- end
function StringUtils.setKCAdapter()
    local realx = nil
    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local ratio = framesize.height / framesize.width

    if ratio >= 1.5 then
        local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
        local width = framesize.width / scaleY
        local height = framesize.height / scaleY
        
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)

        realx = (framesize.width / scaleY - 750) * 0.5
    end

    NewMsgMgr.updateNewMsgPos()

    return realx
end

function StringUtils.setDZAdapter()
    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local scaleX, scaleY = framesize.width / 750, framesize.height / 1334
    local width, height = framesize.width, framesize.height

    width = framesize.width / scaleX
    height = framesize.height / scaleX

    -- local tframesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local ratio = framesize.height/framesize.width
    if ratio >= 1.5 then
        cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
    end

    NewMsgMgr.updateNewMsgPos()
end


function StringUtils.recoveryAdapter(width, height)
    local isKCA = false

    local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local scaleY = framesize.height / height
    local theight = framesize.height / scaleY
    if theight == 1334 then
        isKCA = true
    end


    local ratio = framesize.height/framesize.width
    if ratio >= 1.5 then
        if isKCA then
            StringUtils.setKCAdapter()
        end
    end
end

----------------------------------------------------------------
---*** 数字携带符号位，并且返回对应显示的颜色
----------------------------------------------------------------
function StringUtils.getSymbolNumColor(num, defautColor)
    local numStr, color = tonumber(num) or 0, defaultColor or ResLib.COLOR_WHITE
    if numStr > 0  then 
        numStr, color = "+"..numStr, ResLib.COLOR_RED
    elseif numStr < 0 then 
        numStr, color = tostring(numStr), ResLib.COLOR_GREEN
    end
    return numStr, color
end

--[[
function StringUtils.splitString(  )
    
    local str = "Jimmy: 你好,世界!"
    local fontSize = 20
    local lenInByte = #str
    local width = 0
     
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1
        elseif curByte>=192 and curByte<223 then
            byteCount = 2
        elseif curByte>=224 and curByte<239 then
            byteCount = 3
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4
        end
         
        local char = string.sub(str, i, i+byteCount-1)
        i = i + byteCount -1
         
        if byteCount == 1 then
            width = width + fontSize * 0.5
        else
            width = width + fontSize
            print(char)
        end
    end
    return char
end
--]]

return StringUtils