
--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local EditBox = ccui.EditBox

function EditBox:onEditHandler(callback)
    self:registerScriptEditBoxHandler(function(name, sender)
        local event = {}
        event.name = name
        event.target = sender
        callback(event)
    end)
    return self
end

function EditBox:removeEditHandler()
    self:unregisterScriptEditBoxHandler()
    return self
end

--by tanhaiting
function EditBox:setCheckTextFunc(_func)
	self.checkTextValid = _func
end

function EditBox:getCheckTextFunc()
	return self.checkTextValid
end

function EditBox.editHandler(eType,sender)
    if eType == "began" then 
    elseif eType == "changed" then 
    elseif eType == "ended" then 
    elseif eType == "return" then
        local checkTextFunc = sender:getCheckTextFunc() -- WARNING 检查函数，需要设置 
        if checkTextFunc then 
            local str = string.trim(sender:getText())
            local isValid, info, defaultStr = checkTextFunc(str)
            if not isValid then
                ViewCtrol.showTip({content = info})
                sender:setText(defaultStr or "")
            end
            local str, _ = string.trim(defaultStr or sender:getText())
            sender:setText(str)
        end
    end
end
